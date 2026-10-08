import 'dart:io';

import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/session/session_cubit.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/billing/data/cart_store.dart';
import 'package:billing_app/features/billing/data/receipt_printer.dart';
import 'package:billing_app/features/billing/data/repositories/sale_repository_impl.dart';
import 'package:billing_app/features/billing/domain/entities/cart_item.dart';
import 'package:billing_app/features/billing/presentation/bloc/billing_bloc.dart';
import 'package:billing_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/usecases/product_usecases.dart';
import 'package:billing_app/features/sheet/data/sheet_client.dart';
import 'package:billing_app/features/sheet/data/sheet_protocol.dart';
import 'package:billing_app/features/sheet/data/sheet_service.dart';
import 'package:billing_app/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:billing_app/features/shop/domain/entities/shop.dart';
import 'package:billing_app/features/stock/data/repositories/stock_repository_impl.dart';
import 'package:billing_app/features/stock/data/stock_ledger.dart';
import 'package:billing_app/features/sync/data/sync_store.dart';
import 'package:billing_app/features/users/domain/entities/app_user.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'fakes/fake_sheet_script.dart';

/// A ledger that "dies" while a sale is being saved: after the ticket row
/// is written, before its lines.
class _CrashingLedger extends StockLedger {
  _CrashingLedger(super.db);

  @override
  Future<int> takeOut({
    required String productId,
    required int quantity,
    required String source,
    required String sourceId,
    required int fallbackCost,
    required String deviceId,
    required String? userId,
    required DateTime at,
    String? preferred,
  }) =>
      throw StateError('The phone switched off');
}

/// "Never lose data": a sale is saved completely or not at all, even when
/// the phone stops in the middle; the cart comes back after a crash.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory dir;
  late AppDatabase db;
  late SettingsStore settings;
  late SessionCubit session;
  late ProductRepositoryImpl products;

  const karim = AppUser(id: 'u-karim', name: 'Karim', role: UserRole.owner);
  const soda = Product(
      id: 'soda',
      name: 'Hamoud 33cl',
      barcode: '613',
      sellPrice: 6000,
      buyPrice: 4000);
  const jus = Product(
      id: 'jus', name: 'Jus Rouiba', barcode: '614', sellPrice: 18000);

  File dbFile([Directory? folder]) =>
      File(p.join((folder ?? dir).path, '${AppDatabase.fileName}.sqlite'));

  Future<void> open() async {
    db = AppDatabase(NativeDatabase(dbFile()));
    settings = SettingsStore(db);
    await settings.load();
    products = ProductRepositoryImpl(db, settings, session);
  }

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('durability');
    session = SessionCubit(hasOwner: true)..login(karim);
    await open();
    await ShopRepositoryImpl(db, settings)
        .updateShop(const Shop(name: 'Épicerie'));
    await products.addProduct(soda);
    await products.addProduct(jus);
    await StockRepositoryImpl(db, settings, session, StockLedger(db), products)
        .addDelivery(productId: 'soda', quantity: 10, buyPrice: 4000);
  });

  tearDown(() async {
    await session.close();
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<int> count(AppDatabase on, String table) async =>
      (await on.customSelect('SELECT COUNT(*) AS n FROM $table').getSingle())
          .read<int>('n');

  test('the database waits for the storage before saying "saved"', () async {
    final sync = await db.customSelect('PRAGMA synchronous').getSingle();
    final journal = await db.customSelect('PRAGMA journal_mode').getSingle();
    expect(sync.data.values.single, 2, reason: '2 = FULL');
    expect(journal.data.values.single, 'delete',
        reason: 'a rollback journal undoes half-written changes');
  });

  test('a crash in the middle of a sale leaves no half-saved sale', () async {
    final sales = SaleRepositoryImpl(db, settings, session, _CrashingLedger(db));
    final result = await sales
        .saveSale(const [CartItem(product: soda, quantity: 2)]);
    expect(result.isLeft(), isTrue);
    for (final table in ['sales', 'sale_items', 'stock_allocations']) {
      expect(await count(db, table), 0, reason: table);
    }
    // Nothing waits to be sent for a sale that does not exist.
    final log = await (db.select(db.syncLog)
          ..where((l) => l.entity.equals('sales')))
        .get();
    expect(log, isEmpty);
    expect((await StockLedger(db).batchesOf('soda')).stock, 10);
  });

  test('a power cut while a sale is written: the file is fine at restart',
      () async {
    final sales = SaleRepositoryImpl(db, settings, session, StockLedger(db));
    await sales.saveSale(const [CartItem(product: soda)]); // saved before

    // The phone dies while the next sale is being written: what is on the
    // storage at that moment (database file and its journal) is copied.
    final cut = await Directory.systemTemp.createTemp('power_cut');
    await expectLater(
      db.transaction(() async {
        await db.into(db.sales).insert(SalesCompanion.insert(
            id: 'half',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            deviceId: settings.deviceId,
            number: 2,
            subtotal: 6000,
            total: 6000,
            paidNow: 6000));
        for (final suffix in ['', '-journal', '-wal']) {
          final file = File('${dbFile().path}$suffix');
          if (file.existsSync()) {
            file.copySync('${dbFile(cut).path}$suffix');
          }
        }
        throw StateError('power cut');
      }),
      throwsStateError,
    );

    // The phone starts again on what was on the storage.
    final restarted = AppDatabase(NativeDatabase(dbFile(cut)));
    final check = await restarted.customSelect('PRAGMA integrity_check').get();
    expect(check.single.data.values.single, 'ok');
    expect(await count(restarted, 'sales'), 1, reason: 'the saved sale only');
    expect(await count(restarted, 'sale_items'), 1);
    await restarted.close();
    await cut.delete(recursive: true);
  });

  test('a crash while receiving a sync: nothing half-applied', () async {
    final store = SyncStore(db);
    final product = (await db.customSelect("SELECT * FROM products WHERE id = 'soda'")
            .getSingle())
        .data;
    await expectLater(
      store.applyFromHub([
        (table: 'products', data: {...product, 'id': 'new', 'barcode': '9'}),
        (table: 'not_a_table', data: {'id': 'x'}),
      ]),
      throwsArgumentError,
    );
    expect(
        await (db.select(db.products)..where((p) => p.id.equals('new')))
            .getSingleOrNull(),
        isNull);
  });

  test('a crash while sending to the sheet: sent again, written once',
      () async {
    final script = FakeSheetScript();
    final sheet = SheetService(
        db, settings, SheetClient(script.client, settings));
    await sheet.configure(SheetConfig.decode(script.code)!);
    // The script writes the rows, then the answer is lost.
    script.loseNextAnswer = true;
    await expectLater(sheet.sendNow(), throwsA(isA<SheetException>()));
    expect(await sheet.pendingCount(), greaterThan(0),
        reason: 'not confirmed: still in the queue');
    expect(script.rows('D'), hasLength(1));

    await sheet.sendNow();
    expect(await sheet.pendingCount(), 0);
    expect(script.rows('D'), hasLength(1), reason: 'not twice');
  });

  test('the cart comes back after the app stopped suddenly', () async {
    BillingBloc newBloc() => BillingBloc(
          getProductByBarcodeUseCase: GetProductByBarcodeUseCase(products),
          saleRepository:
              SaleRepositoryImpl(db, settings, session, StockLedger(db)),
          receiptPrinter: ReceiptPrinter(settings),
          cartStore: CartStore(settings, products),
        );
    final before = newBloc();
    before
      ..add(const AddProductToCartEvent(soda))
      ..add(const AddProductToCartEvent(soda))
      ..add(const AddProductToCartEvent(jus));
    await Future<void>.delayed(const Duration(milliseconds: 200));
    // The app is killed: no goodbye, the bloc is simply gone.

    // The owner changed a price meanwhile (on another phone, by sync).
    await products.updateProduct(jus.copyWith(sellPrice: 19000));
    final after = newBloc()..add(const RestoreCartEvent());
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(after.state.cartItems.map((i) => (i.product.id, i.quantity)),
        [('soda', 2), ('jus', 1)]);
    expect(after.state.cartItems.last.product.sellPrice, 19000);

    // Emptied (sale done, or next customer): nothing comes back.
    after.add(ClearCartEvent());
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(settings.get(CartStore.key), isNull);
    await before.close();
    await after.close();
  });
}
