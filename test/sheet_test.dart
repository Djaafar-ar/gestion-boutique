import 'dart:convert';

import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/session/session_cubit.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/billing/data/repositories/sale_repository_impl.dart';
import 'package:billing_app/features/billing/domain/entities/cart_item.dart';
import 'package:billing_app/features/billing/domain/entities/sale.dart';
import 'package:billing_app/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:billing_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/sheet/data/sheet_client.dart';
import 'package:billing_app/features/sheet/data/sheet_protocol.dart';
import 'package:billing_app/features/sheet/data/sheet_service.dart';
import 'package:billing_app/features/sheet/data/sheet_settings.dart';
import 'package:billing_app/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:billing_app/features/shop/domain/entities/shop.dart';
import 'package:billing_app/features/stock/data/repositories/stock_repository_impl.dart';
import 'package:billing_app/features/stock/data/stock_ledger.dart';
import 'package:billing_app/features/stock/domain/entities/loss.dart';
import 'package:billing_app/features/suppliers/data/repositories/supplier_repository_impl.dart';
import 'package:billing_app/features/sync/data/sync_protocol.dart';
import 'package:billing_app/features/sync/data/sync_settings.dart';
import 'package:billing_app/features/sync/data/sync_store.dart';
import 'package:billing_app/features/users/domain/entities/app_user.dart';
import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_sheet_script.dart';

/// Phase 8: the records of the shop reach the Google Sheet once, signed,
/// even after a time without internet.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late SettingsStore settings;
  late SessionCubit session;
  late SaleRepositoryImpl sales;
  late StockRepositoryImpl stock;
  late FakeSheetScript script;
  late SheetService sheet;

  const karim = AppUser(id: 'u-karim', name: 'Karim', role: UserRole.owner);
  const amine = AppUser(id: 'u-amine', name: 'Amine', role: UserRole.worker);
  const soda = Product(
      id: 'soda',
      name: 'Hamoud 33cl',
      barcode: '613',
      sellPrice: 6000,
      buyPrice: 4000);

  SheetService serviceFor(FakeSheetScript s, {DateTime Function()? clock}) =>
      SheetService(db, settings, SheetClient(s.client, settings, clock: clock),
          clock: clock);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    settings = SettingsStore(db);
    await settings.load();
    session = SessionCubit(hasOwner: true)..login(karim);
    for (final user in [karim, amine]) {
      await db.into(db.users).insert(UsersCompanion.insert(
          id: user.id,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
          deviceId: settings.deviceId,
          name: user.name,
          role: user.role.name,
          pinHash: 'x',
          pinSalt: 'y'));
    }
    await ShopRepositoryImpl(db, settings)
        .updateShop(const Shop(name: 'Épicerie El Baraka'));
    final products = ProductRepositoryImpl(db, settings, session);
    await products.addProduct(soda);
    stock =
        StockRepositoryImpl(db, settings, session, StockLedger(db), products);
    await stock.addDelivery(productId: 'soda', quantity: 24, buyPrice: 4000);
    sales = SaleRepositoryImpl(db, settings, session, StockLedger(db));
    script = FakeSheetScript();
    sheet = serviceFor(script);
  });

  tearDown(() async {
    await session.close();
    await db.close();
  });

  Future<Sale> sell(int quantity, {String? customerId, int paid = 0}) async =>
      (await sales.saveSale([CartItem(product: soda, quantity: quantity)],
              customerId: customerId, paidNow: paid))
          .getOrElse((f) => fail(f.message));

  Future<void> connect() async {
    final name = await sheet.configure(SheetConfig.decode(script.code)!);
    expect(name, 'Boutique test');
  }

  group('setup', () {
    test('the configuration code: only Google script addresses', () {
      final config = SheetConfig.decode(script.code)!;
      expect(config.url, FakeSheetScript.url);
      expect(config.readKey, script.readKey);
      expect(
          SheetConfig.decode(
              script.code.replaceAll('script.google.com', 'evil.example.com')),
          isNull);
      expect(SheetConfig.decode('613'), isNull);
      expect(SheetConfig.decode('{"t":"gb-sheet","u":"x"}'), isNull);
    });

    test('nothing is queued before the setup; the setup sends the history',
        () async {
      await sell(2);
      expect(await sheet.pendingCount(), 0);

      await connect();
      // The delivery and the sale made before, and the product.
      expect(await sheet.pendingCount(), 3);
      expect(await sheet.sendNow(), 3);
      expect(script.rows('S'), hasLength(1));
      expect(script.rows('D'), hasLength(1));
      expect(await sheet.pendingCount(), 0);
    });

    test('a wrong code changes nothing', () async {
      final wrong = FakeSheetScript(writeKey: 'c' * 32);
      sheet = serviceFor(script);
      await expectLater(
          sheet.configure(SheetConfig.decode(wrong.code)!),
          throwsA(isA<SheetException>()
              .having((e) => e.error, 'error', SheetError.signature)));
      expect((await currentShopRow(db))!.sheetUrl, isNull);
      expect(settings.sheetReadKey, isNull);
    });

    test('the write key goes to the worker phones, never the read key',
        () async {
      await connect();
      final shop = (await currentShopRow(db))!;
      expect(shop.sheetWriteKey, script.writeKey);
      // Everything the hub hands out by Wi-Fi.
      final shared = jsonEncode(
          encodeRows((await SyncStore(db).changesSince(0, limit: 10000)).rows));
      expect(shared, contains(script.writeKey));
      expect(shared, isNot(contains(script.readKey)));
      expect(settings.sheetReadKey, script.readKey);
    });
  });

  group('sending', () {
    setUp(connect);

    test('without internet the queue waits, then everything goes once',
        () async {
      await sheet.sendNow();
      script.offline = true;
      await sell(1);
      await sell(2);
      await expectLater(
          sheet.sendNow(),
          throwsA(isA<SheetException>()
              .having((e) => e.error, 'error', SheetError.offline)));
      // The two sales, and their product (its stock changed).
      expect(await sheet.pendingCount(), 3);
      expect(settings.sheetLastError, 'offline');

      script.offline = false;
      expect(await sheet.sendNow(), 3);
      expect(await sheet.pendingCount(), 0);
      expect(script.rows('S'), hasLength(2));
      expect(settings.sheetLastError, isNull);
      expect(settings.sheetLastSend, isNotNull);
    });

    test('the same record sent twice (worker and owner) is written once',
        () async {
      await sell(1);
      await sheet.sendNow();
      // The owner's phone sends everything again (a new phone, a restore...)
      await sheet.queueEverything();
      await sheet.sendNow();
      expect(script.rows('S'), hasLength(1));
      expect(script.rows('I'), hasLength(1));
      expect(script.rows('D'), hasLength(1));
    });

    test('Google answers with a redirect: the answer is read with a GET',
        () async {
      script.redirect = true;
      await sell(1);
      expect(await sheet.sendNow(), 3);
      expect(script.rows('S'), hasLength(1));
    });

    test('a wrong key is refused and the records stay', () async {
      await sheet.sendNow();
      script.writeKey = 'd' * 32; // keys changed in the sheet
      await sell(1);
      await expectLater(
          sheet.sendNow(),
          throwsA(isA<SheetException>()
              .having((e) => e.error, 'error', SheetError.signature)));
      expect(await sheet.pendingCount(), 2);
    });

    test('a request copied and sent again is refused', () async {
      // A signed request, as someone could copy it on its way.
      final ts = DateTime.now().millisecondsSinceEpoch;
      final message = sheetMessage(
          op: 'ping', ts: ts, nonce: 'abc', keyId: 'w', body: '{}');
      final envelope = {
        'v': sheetProtocolVersion,
        'op': 'ping',
        'ts': ts,
        'n': 'abc',
        'k': 'w',
        'b': '{}',
        's': sheetSignature(script.writeKey, message),
      };
      expect(script.handle(envelope)['ok'], isTrue);
      expect(script.handle(envelope)['err'], 'replay');
      // Changing one letter breaks the signature.
      expect(script.handle({...envelope, 'n': 'abd', 'b': '{"x":1}'})['err'],
          'sig');
    });

    test('a phone with the wrong time corrects itself', () async {
      final late = SheetClient(script.client, settings,
          clock: () => DateTime.now().subtract(const Duration(hours: 3)));
      final answer = await late.call(FakeSheetScript.url,
          key: script.writeKey, keyId: 'w', op: 'ping', body: const {});
      expect(answer['ok'], isTrue);
      expect(settings.sheetClockOffset,
          closeTo(const Duration(hours: 3).inMilliseconds, 60000));
    });

    test('the write key cannot read the figures', () async {
      await expectLater(
          SheetClient(script.client, settings).call(FakeSheetScript.url,
              key: script.writeKey, keyId: 'w', op: 'live', body: const {}),
          throwsA(isA<SheetException>()
              .having((e) => e.error, 'error', SheetError.signature)));
    });
  });

  group('rows of the tabs', () {
    setUp(() async {
      await connect();
      await sheet.sendNow();
      script.rows('D').clear();
    });

    test('a sale: total, profit, cash, items and what left the stock',
        () async {
      final sale = (await sales.saveSale(
              const [CartItem(product: soda, quantity: 3)],
              discount: 1000))
          .getOrElse((f) => fail(f.message));
      await sheet.sendNow();
      final row = script.rows('S').single;
      expect(row[0], sale.id);
      expect(row[1], sheetDay(DateTime.now()));
      // One phone in the shop: no phone letter.
      expect(row.sublist(3, 9),
          [sale.ticket, 'Karim', '', 'Vente', 'Comptant', '']);
      // 3 x 60 DA - 10 DA discount = 170 DA; bought 3 x 40 DA = 120 DA.
      expect(row.sublist(9), [1, 180, 10, 170, 50, 0, 170]);
      final item = script.rows('I').single;
      expect(item.sublist(3), [
        'Hamoud 33cl', 3, 60, 180, 40, 60, 'Karim', 3, 'Vente', //
      ]);
    });

    test('a return and an exchange: negative total and profit, stock back',
        () async {
      final sale = await sell(3);
      final line = sale.items.single;
      await sales.processReturn(
        saleId: sale.id,
        lines: [
          ReturnLine(saleItemId: line.id, quantity: 1, backToStock: true),
          ReturnLine(saleItemId: line.id, quantity: 1, backToStock: false),
        ],
        takes: const [CartItem(product: soda)],
      );
      await sheet.sendNow();
      final returned = script.rows('S').firstWhere((r) => r[6] == 'Échange');
      // 2 x 60 DA given back, one item back on the shelf (40 DA).
      expect(returned.sublist(9), [0, 0, 0, -120, -80, 120, -120]);
      expect(returned[3], sale.ticket);
      final items =
          script.rows('I').where((r) => '${r[11]}'.startsWith('Retour'));
      expect(items.map((r) => (r[4], r[10], r[11])), [
        (-1, -1, 'Retour'),
        (-1, 0, 'Retour (abîmé)'),
      ]);
      // The new ticket of the exchange is a normal sale.
      expect(script.rows('S').where((r) => r[6] == 'Vente'), hasLength(2));
      // The damaged item: a loss that does not touch the stock again.
      final loss = script.rows('L').single;
      expect((loss[5], loss[11]), ('Abîmé', 0));
    });

    test('customer credit: debt, last payment, cash received', () async {
      final customers = CustomerRepositoryImpl(db, settings, session);
      final client =
          (await customers.saveCustomer(name: 'Hadj Ali', phone: '0555123456'))
              .getOrElse((f) => fail(f.message));
      await sell(5, customerId: client.id, paid: 10000);
      await customers.recordPayment(customerId: client.id, amount: 5000);
      await sheet.sendNow();

      final sale = script.rows('S').firstWhere((r) => r[6] == 'Vente');
      expect((sale[7], sale[8], sale[15]), ('Crédit', 'Hadj Ali', 100));
      final payment =
          script.rows('S').firstWhere((r) => r[6] == 'Paiement client');
      expect((payment[4], payment[12], payment[15]), ('Karim', 0, 50));
      // 300 DA bought, 100 DA paid at the counter, 50 DA paid back.
      final credit = script.rows('C').single;
      expect(credit.sublist(0, 3), [client.id, 'Hadj Ali', 150]);
      expect(credit[3], sheetDay(DateTime.now()));
      // No phone numbers in the sheet.
      expect(jsonEncode(script.tabs), isNot(contains('0555123456')));
    });

    test('a supplier payment is updated in place when validated', () async {
      final suppliers = SupplierRepositoryImpl(db, settings, session);
      final supplier = (await suppliers.saveSupplier(name: 'Rouiba'))
          .getOrElse((f) => fail(f.message));
      session.login(amine);
      final payment = (await suppliers.recordPayment(
              supplierId: supplier.id, amount: 200000))
          .getOrElse((f) => fail(f.message));
      await sheet.sendNow();
      expect(script.rows('P').single[5], 'En attente');

      session.login(karim);
      await suppliers.validatePayment(payment.id);
      await sheet.sendNow();
      final row = script.rows('P').single;
      expect(row.sublist(3, 8), ['Rouiba', 2000, 'Validé', 'Amine', 'Karim']);
    });

    test('deliveries and losses', () async {
      await stock.addDelivery(
          productId: 'soda',
          quantity: 12,
          buyPrice: 4200,
          expiryDate: DateTime(2026, 12, 31));
      await stock.recordLoss(
          productId: 'soda', quantity: 2, reason: LossReason.expired);
      await sheet.sendNow();
      final delivery = script.rows('D').single;
      expect(delivery.sublist(3, 9),
          ['Hamoud 33cl', 12, 42, 504, '', sheetDay(DateTime(2026, 12, 31))]);
      // The batch that expires first (bought at 42 DA) is taken.
      final loss = script.rows('L').single;
      expect(loss.sublist(3, 8), ['Hamoud 33cl', 2, 'Périmé', 42, 84]);
      expect(loss[11], 2);
    });
  });

  group('worker phone', () {
    test('sends only what was done on it, and never the debts', () async {
      await connect();
      await sheet.sendNow();
      await settings.setSyncRole(SyncRole.worker);
      session.login(amine);
      final customers = CustomerRepositoryImpl(db, settings, session);
      final client = (await customers.saveCustomer(name: 'Hadj Ali'))
          .getOrElse((f) => fail(f.message));
      await sell(1, customerId: client.id);
      // A sale of another phone, received by Wi-Fi.
      await db.into(db.sales).insert(SalesCompanion.insert(
          id: 'other',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          deviceId: 'phone-c',
          number: 1,
          subtotal: 6000,
          total: 6000,
          paidNow: 6000,
          userId: const Value('u-amine')));
      final queued = await db.select(db.sheetQueue).get();
      expect(queued.map((q) => q.kind), ['sale']);
      await sheet.sendNow();
      expect(script.rows('S').single[4], 'Amine');
      expect(script.rows('C'), isEmpty);
    });

    test('cannot set up the sheet (no read key on a worker phone)', () async {
      await settings.setSyncRole(SyncRole.worker);
      await expectLater(sheet.configure(SheetConfig.decode(script.code)!),
          throwsA(isA<SheetException>()));
      expect(settings.sheetReadKey, isNull);
    });
  });

  test('disconnecting stops the sending', () async {
    await connect();
    await sheet.disconnect();
    await sell(1);
    expect(await sheet.pendingCount(), 0);
    expect(await sheet.target(), isNull);
    expect(settings.sheetReadKey, isNull);
  });

  group('Phase 8b: everything goes to the sheet', () {
    setUp(connect);

    test("the Google account is shown on the owner's phone", () async {
      expect(settings.sheetAccount, 'boutique.elbaraka@gmail.com');
      script.email = 'autre@gmail.com';
      expect(await sheet.refreshAccount(), 'autre@gmail.com');
    });

    test('price and name changes: the history tab', () async {
      final products = ProductRepositoryImpl(db, settings, session);
      await products.updateProduct(
          soda.copyWith(sellPrice: 6500, buyPrice: 4200, name: 'Hamoud 1L'));
      await sheet.sendNow();
      final changes = {
        for (final row in script.rows('H')) row[4]: (row[5], row[6]),
      };
      expect(changes['Prix de vente'], (60, 65));
      expect(changes["Prix d'achat"], (40, 42));
      expect(changes['Nom'], ('Hamoud 33cl', 'Hamoud 1L'));
      expect(script.rows('H').first[7], 'Karim');
    });

    test('the Produits tab: price, buying price, stock, nearest expiry',
        () async {
      await stock.addDelivery(
          productId: 'soda',
          quantity: 6,
          buyPrice: 4000,
          expiryDate: DateTime(2026, 11, 30));
      await sell(4);
      await sheet.sendNow();
      final row = script.rows('R').single;
      expect(row.sublist(0, 7), ['soda', 'Hamoud 33cl', '613', '', 60, 40, 26]);
      // 4 sold from the batch that expires first: 2 left in it.
      expect(row[7], sheetDay(DateTime(2026, 11, 30)));
      expect(row[8], 'Non');
      // Updated in place, never added twice.
      await sell(1);
      await sheet.sendNow();
      expect(script.rows('R').single[6], 25);
    });

    test("debts and products need the read key: never a worker's", () async {
      await sheet.sendNow();
      script.rows('R').clear();
      // A worker phone (write key only) tries to write the Produits tab.
      await SheetClient(script.client, settings).call(FakeSheetScript.url,
          key: script.writeKey,
          keyId: 'w',
          op: 'push',
          body: {
            'r': [
              {
                'k': 'product',
                'id': 'soda',
                'u': 1,
                't': {
                  'R': [
                    ['soda', 'Faux', '', '', 0, 0, 0, '', 'Non'],
                  ],
                },
              },
            ],
          });
      expect(script.rows('R'), isEmpty);
    });

    test('returns without a ticket are named so', () async {
      await sales.processReturn(looseLines: [
        const LooseReturnLine(productId: 'soda', quantity: 1, backToStock: true),
      ]);
      await sheet.sendNow();
      expect(script.rows('S').last[6], 'Retour sans ticket');
    });
  });
}
