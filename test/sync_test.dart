import 'dart:io';

import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/session/session_cubit.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/billing/data/repositories/sale_repository_impl.dart';
import 'package:billing_app/features/alerts/data/alert_repository.dart';
import 'package:billing_app/features/alerts/domain/alert.dart';
import 'package:billing_app/features/billing/domain/entities/cart_item.dart';
import 'package:billing_app/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:billing_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:billing_app/features/shop/domain/entities/shop.dart';
import 'package:billing_app/features/stock/data/repositories/stock_repository_impl.dart';
import 'package:billing_app/features/stock/data/stock_ledger.dart';
import 'package:billing_app/features/sync/data/hub_service.dart';
import 'package:billing_app/features/sync/data/merge_service.dart';
import 'package:billing_app/features/sync/data/sync_client.dart';
import 'package:billing_app/features/sync/data/sync_network.dart';
import 'package:billing_app/features/sync/data/sync_protocol.dart';
import 'package:billing_app/features/sync/data/sync_settings.dart';
import 'package:billing_app/features/sync/data/sync_store.dart';
import 'package:billing_app/features/users/data/repositories/user_repository_impl.dart';
import 'package:billing_app/features/users/domain/entities/app_user.dart';
import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// One phone: its database and what the app builds on it.
class Phone {
  final AppDatabase db;
  final SettingsStore settings;
  final SessionCubit session;
  late final SyncStore store = SyncStore(db);
  late final products = ProductRepositoryImpl(db, settings, session);
  late final stock =
      StockRepositoryImpl(db, settings, session, StockLedger(db), products);
  late final sales = SaleRepositoryImpl(db, settings, session, StockLedger(db));

  Phone._(this.db, this.settings, this.session);

  static Future<Phone> create() async {
    final db = AppDatabase(NativeDatabase.memory());
    final settings = SettingsStore(db);
    await settings.load();
    return Phone._(db, settings, SessionCubit(hasOwner: false));
  }

  Future<int> count(String table) async =>
      (await db.customSelect('SELECT COUNT(*) AS n FROM $table').getSingle())
          .data['n'] as int;

  Future<int> stockOf(String id) async =>
      (await stock.getBatches(id)).getOrElse((f) => fail(f.message)).stock;

  Future<void> close() async {
    await session.close();
    await db.close();
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Phone hubPhone;
  late HubService hub;
  late PairingInfo pairing;
  late AppUser karim;
  final phones = <Phone>[];

  const soda = Product(
      id: 'soda',
      name: 'Hamoud 33cl',
      barcode: '613',
      sellPrice: 6000,
      buyPrice: 4000);

  setUp(() async {
    hubPhone = await Phone.create();
    final users = UserRepositoryImpl(hubPhone.db, hubPhone.settings);
    karim = (await users.createOwner(name: 'Karim', phone: '', pin: '1234'))
        .getOrElse((f) => fail(f.message))
        .owner;
    await users.addWorker(
        actorId: karim.id, name: 'Amine', phone: '', pin: '5678');
    hubPhone.session.login(karim);
    await ShopRepositoryImpl(hubPhone.db, hubPhone.settings)
        .updateShop(const Shop(name: 'Épicerie El Baraka'));
    await hubPhone.products.addProduct(soda);
    await hubPhone.stock
        .addDelivery(productId: 'soda', quantity: 24, buyPrice: 4000);

    hub = HubService(hubPhone.db, hubPhone.store, hubPhone.settings);
    await hub.becomeHub(name: 'Téléphone du patron');
    final keys = (await hub.shop())!;
    pairing = PairingInfo(
        host: 'hub',
        port: syncPort,
        shopId: keys.id,
        secret: keys.secret,
        shopName: keys.name);
  });

  tearDown(() async {
    for (final phone in phones) {
      await phone.close();
    }
    phones.clear();
    await hubPhone.close();
  });

  /// A new worker phone, joined to the hub.
  Future<(Phone, SyncClient)> joinWorker({SyncTransport? transport}) async {
    final phone = await Phone.create();
    phones.add(phone);
    final client = SyncClient(phone.db, phone.store, phone.settings,
        transport ?? DirectTransport(hub));
    await client.join(pairing, deviceName: 'Caisse ${phones.length + 1}');
    return (phone, client);
  }

  group('joining', () {
    test('a new phone gets the whole shop and a letter', () async {
      final (worker, _) = await joinWorker();

      expect(worker.settings.deviceCode, 'B');
      expect(worker.settings.syncRole, SyncRole.worker);
      expect((await currentShopRow(worker.db))!.name, 'Épicerie El Baraka');
      expect(await worker.count('users'), 2);
      expect(await worker.stockOf('soda'), 24);
      // People log in with their own PIN on the new phone.
      final users = UserRepositoryImpl(worker.db, worker.settings);
      expect(await users.hasOwner(), isTrue);
      final all = (await users.getUsers()).getOrElse((f) => fail(f.message));
      final amine = all.firstWhere((u) => u.name == 'Amine');
      expect(await users.checkPin(amine.id, '5678'), isNotNull);
      // Nothing to send back: everything came from the hub.
      expect(await worker.store.outboxCount(), 0);
    });

    test('the second phone gets the next letter', () async {
      await joinWorker();
      final (second, _) = await joinWorker();
      expect(second.settings.deviceCode, 'C');
      expect(await hubPhone.count('devices'), 3);
    });

    test('a wrong secret is refused', () async {
      final phone = await Phone.create();
      phones.add(phone);
      final client = SyncClient(
          phone.db, phone.store, phone.settings, DirectTransport(hub));
      final bad = PairingInfo(
          host: 'hub',
          port: syncPort,
          shopId: pairing.shopId,
          secret: 'not-the-secret',
          shopName: '');
      await expectLater(
          client.join(bad, deviceName: 'X'),
          throwsA(isA<SyncException>()
              .having((e) => e.error, 'error', SyncError.badSignature)));
      expect(await phone.count('products'), 0);
    });
  });

  group('everyday sync', () {
    test("a worker's sale reaches the owner's phone and its stock", () async {
      final (worker, client) = await joinWorker();
      final users = UserRepositoryImpl(worker.db, worker.settings);
      final amine = (await users.getUsers())
          .getOrElse((f) => fail(f.message))
          .firstWhere((u) => u.name == 'Amine');
      worker.session.login(amine);
      await worker.sales.saveSale(const [CartItem(product: soda, quantity: 3)]);
      expect(await worker.store.outboxCount(), greaterThan(0));

      final summary = await client.sync();
      expect(summary.sent, greaterThan(0));
      expect(await worker.store.outboxCount(), 0);

      expect(await hubPhone.count('sales'), 1);
      expect(await hubPhone.stockOf('soda'), 21);
      final sale = (await hubPhone.sales.getSales())
          .getOrElse((f) => fail(f.message))
          .single;
      expect(sale.sellerName, 'Amine');
    });

    test("the owner's new price reaches the worker", () async {
      final (worker, client) = await joinWorker();
      await hubPhone.products.updateProduct(soda.copyWith(sellPrice: 7000));
      await client.sync();
      final product = (await worker.products.getProducts())
          .getOrElse((f) => fail(f.message))
          .single;
      expect(product.sellPrice, 7000);
    });

    test('two workers selling: both sales everywhere, never twice', () async {
      final (b, clientB) = await joinWorker();
      final (c, clientC) = await joinWorker();
      await b.sales.saveSale(const [CartItem(product: soda, quantity: 2)]);
      await c.sales.saveSale(const [CartItem(product: soda, quantity: 5)]);

      for (var i = 0; i < 2; i++) {
        await clientB.sync();
        await clientC.sync();
      }
      for (final phone in [hubPhone, b, c]) {
        expect(await phone.count('sales'), 2);
        expect(await phone.stockOf('soda'), 17);
      }
    });

    test('a lost answer: the sale is sent again, saved once', () async {
      final lossy = _LoseFirstAnswer(DirectTransport(hub));
      final (worker, client) = await joinWorker(transport: lossy);
      await worker.sales.saveSale(const [CartItem(product: soda)]);

      lossy.loseNext = true;
      await expectLater(client.sync(), throwsA(isA<SyncException>()));
      expect(await worker.store.outboxCount(), greaterThan(0),
          reason: 'not confirmed: kept to send again');

      await client.sync();
      expect(await hubPhone.count('sales'), 1);
      expect(await hubPhone.count('sale_items'), 1);
      expect(await hubPhone.stockOf('soda'), 23);
    });

    test('a change made here and not sent yet is not overwritten', () async {
      final (worker, _) = await joinWorker();
      await worker.products.updateProduct(soda.copyWith(name: 'Hamoud 1L'));
      // A pull arrives with the hub's older version of the product.
      final hubRow = await hubPhone.db
          .customSelect("SELECT * FROM products WHERE id = 'soda'")
          .getSingle();
      await worker.store.applyFromHub([(table: 'products', data: hubRow.data)]);
      final product = (await worker.products.getProducts())
          .getOrElse((f) => fail(f.message))
          .single;
      expect(product.name, 'Hamoud 1L');
    });
  });

  group('conflicts', () {
    Future<void> setProduct(Phone phone, String name, DateTime at) =>
        (phone.db.update(phone.db.products)..where((p) => p.id.equals('soda')))
            .write(ProductsCompanion(name: Value(name), updatedAt: Value(at)));

    Future<String> nameOn(Phone phone) async =>
        (await (phone.db.select(phone.db.products)
                  ..where((p) => p.id.equals('soda')))
                .getSingle())
            .name;

    test('the last change wins, on every phone', () async {
      final (worker, client) = await joinWorker();
      final now = DateTime.now();
      await setProduct(hubPhone, 'Nom du patron', now);
      await setProduct(
          worker, 'Nom de l\'employé', now.add(const Duration(seconds: 30)));
      await client.sync();
      expect(await nameOn(hubPhone), 'Nom de l\'employé');
      expect(await nameOn(worker), 'Nom de l\'employé');

      await setProduct(
          hubPhone, 'Nom du patron 2', now.add(const Duration(minutes: 1)));
      await setProduct(
          worker, 'Ancien nom', now.add(const Duration(seconds: 40)));
      await client.sync();
      expect(await nameOn(hubPhone), 'Nom du patron 2');
      expect(await nameOn(worker), 'Nom du patron 2');
    });

    test("a worker phone with the wrong date: the hub's clock decides",
        () async {
      // The worker phone is one day behind.
      final hubLater = HubService(
          hubPhone.db, hubPhone.store, hubPhone.settings,
          clock: () => DateTime.now().add(const Duration(days: 1)));
      final (worker, client) =
          await joinWorker(transport: DirectTransport(hubLater));
      await worker.sales.saveSale(const [CartItem(product: soda)]);
      await client.sync();

      final sale = await hubPhone.db.select(hubPhone.db.sales).getSingle();
      final shift = sale.createdAt.difference(DateTime.now());
      expect(shift.inHours, closeTo(24, 1), reason: 'dated with the hub clock');
    });

    test('a small clock difference changes nothing', () async {
      final hubSoon = HubService(hubPhone.db, hubPhone.store, hubPhone.settings,
          clock: () => DateTime.now().add(const Duration(seconds: 30)));
      final (worker, client) =
          await joinWorker(transport: DirectTransport(hubSoon));
      await worker.sales.saveSale(const [CartItem(product: soda)]);
      final local = await worker.db.select(worker.db.sales).getSingle();
      await client.sync();
      final onHub = await hubPhone.db.select(hubPhone.db.sales).getSingle();
      expect(onHub.createdAt, local.createdAt);
    });
  });

  test('each phone numbers its own tickets, with its letter', () async {
    final (worker, client) = await joinWorker();
    await hubPhone.sales.saveSale(const [CartItem(product: soda)]);
    await worker.sales.saveSale(const [CartItem(product: soda)]);
    await client.sync();

    final tickets = (await hubPhone.sales.getSales())
        .getOrElse((f) => fail(f.message))
        .map((s) => s.ticket)
        .toSet();
    expect(tickets, {'1', 'B-1'});
  });

  group('duplicates', () {
    test('the same barcode made on two phones: alert, then merge',
        () async {
      final (worker, client) = await joinWorker();
      const hubCola = Product(
          id: 'cola-hub', name: 'Cola 1L', barcode: '999', sellPrice: 15000);
      const workerCola = Product(
          id: 'cola-worker', name: 'Coca 1L', barcode: '999', sellPrice: 15000);
      await hubPhone.products.addProduct(hubCola);
      await worker.products.addProduct(workerCola);
      await worker.sales.saveSale(const [CartItem(product: workerCola)]);
      await client.sync();

      final alerts = AlertRepository(hubPhone.db, hubPhone.settings);
      await alerts.refresh();
      final alert = (await alerts.getAlerts(userId: karim.id, isOwner: true))
          .singleWhere((a) => a.type == AlertType.duplicateBarcode);
      expect(alert.data['names'], contains('Coca 1L'));

      final merge = MergeService(hubPhone.db, hubPhone.session);
      expect(
          (await merge.mergeProducts(keepId: 'cola-hub', dropId: 'cola-worker'))
              .isRight(),
          isTrue);
      await alerts.refresh();
      expect(
          (await alerts.getAlerts(userId: karim.id, isOwner: true))
              .where((a) => a.type == AlertType.duplicateBarcode),
          isEmpty);
      // The worker's sale now counts for the product kept, on every phone.
      await client.sync();
      for (final phone in [hubPhone, worker]) {
        expect(await phone.stockOf('cola-hub'), -1);
        final line = await phone.db.select(phone.db.saleItems).get();
        expect(line.where((l) => l.productId == 'cola-worker'), isEmpty);
      }
    });

    test('the same customer on two phones: merge moves the debt', () async {
      final (worker, client) = await joinWorker();
      final hubCustomers = CustomerRepositoryImpl(
          hubPhone.db, hubPhone.settings, hubPhone.session);
      final workerCustomers =
          CustomerRepositoryImpl(worker.db, worker.settings, worker.session);
      final a = (await hubCustomers.saveCustomer(
              name: 'Mohamed', phone: '0555 12 34 56'))
          .getOrElse((f) => fail(f.message));
      final b = (await workerCustomers.saveCustomer(
              name: 'Mohamed S.', phone: '0555123456'))
          .getOrElse((f) => fail(f.message));
      await worker.sales
          .saveSale(const [CartItem(product: soda)], customerId: b.id);
      await client.sync();

      final alerts = AlertRepository(hubPhone.db, hubPhone.settings);
      await alerts.refresh();
      expect(
          (await alerts.getAlerts(userId: karim.id, isOwner: true))
              .map((a) => a.type),
          contains(AlertType.duplicateCustomer));

      await MergeService(hubPhone.db, hubPhone.session)
          .mergeCustomers(keepId: a.id, dropId: b.id);
      final kept = (await hubCustomers.getCustomer(a.id))
          .getOrElse((f) => fail(f.message));
      expect(kept.debt, 6000);
    });

    test('only the owner merges', () async {
      final session = SessionCubit(hasOwner: true)
        ..login(const AppUser(id: 'w', name: 'W', role: UserRole.worker));
      addTearDown(session.close);
      final result = await MergeService(hubPhone.db, session)
          .mergeProducts(keepId: 'a', dropId: 'b');
      expect(result.isLeft(), isTrue);
    });
  });

  group('refused', () {
    test('a removed phone cannot sync any more', () async {
      final (worker, client) = await joinWorker();
      await hub.removeDevice(worker.settings.deviceId);
      await expectLater(
          client.sync(),
          throwsA(isA<SyncException>()
              .having((e) => e.error, 'error', SyncError.unknownDevice)));
    });

    test('another app version is refused', () async {
      final answer = await hub.handle({
        'type': 'sync',
        'shop': pairing.shopId,
        'device': 'x',
        'schema': 1,
      });
      expect(answer['error'], 'version');
    });
  });

  test('a wiped phone has no shop left', () async {
    final (worker, _) = await joinWorker();
    await worker.store.wipe();
    expect(await worker.count('products'), 0);
    expect(await worker.count('users'), 0);
    expect(await worker.count('sync_log'), 0);
  });

  group('over the real network', () {
    late HubServer server;

    setUp(() async {
      server = HubServer(hub);
      await server.start(port: 0, discovery: 0);
    });
    tearDown(() => server.stop());

    test('join and sync over HTTP, signed both ways', () async {
      final phone = await Phone.create();
      phones.add(phone);
      final client = SyncClient(
          phone.db, phone.store, phone.settings, const HttpSyncTransport());
      final info = PairingInfo(
          host: '127.0.0.1',
          port: server.port!,
          shopId: pairing.shopId,
          secret: pairing.secret,
          shopName: '');
      expect(await client.join(info, deviceName: 'Caisse 2'), 'B');
      expect(await phone.stockOf('soda'), 24);

      await phone.sales.saveSale(const [CartItem(product: soda)]);
      await client.sync();
      expect(await hubPhone.stockOf('soda'), 23);
    });

    test('a wrong secret gets nothing', () async {
      await expectLater(
          const HttpSyncTransport().send(
              host: '127.0.0.1',
              port: server.port!,
              secret: 'wrong',
              message: {'type': 'hello', 'shop': pairing.shopId}),
          throwsA(isA<SyncException>()
              .having((e) => e.error, 'error', SyncError.badSignature)));
    });

    test('nobody there: "unreachable"', () async {
      await server.stop();
      await expectLater(
          const HttpSyncTransport(timeout: Duration(seconds: 2)).send(
              host: '127.0.0.1',
              port: 1,
              secret: pairing.secret,
              message: const {}),
          throwsA(isA<SyncException>()
              .having((e) => e.error, 'error', SyncError.unreachable)));
    });

    test('the hub is found again after its address changed', () async {
      final finder = HubFinder(
          target: InternetAddress.loopbackIPv4,
          port: server.discoveryPortInUse!);
      final found =
          await finder.find(shopId: pairing.shopId, secret: pairing.secret);
      expect(found, isNotNull);
      expect(found!.port, server.port);

      // Someone without the secret cannot pretend to be the hub.
      final fake = await finder.find(
          shopId: pairing.shopId,
          secret: 'wrong',
          timeout: const Duration(milliseconds: 500));
      expect(fake, isNull);
    });
  });
}

/// Delivers the request to the hub but loses the answer once, as when the
/// Wi-Fi drops at the wrong moment.
class _LoseFirstAnswer implements SyncTransport {
  final SyncTransport inner;
  bool loseNext = false;
  _LoseFirstAnswer(this.inner);

  @override
  Future<Map<String, Object?>> send(
      {required String host,
      required int port,
      required String secret,
      required Map<String, Object?> message}) async {
    final answer = await inner.send(
        host: host, port: port, secret: secret, message: message);
    if (loseNext) {
      loseNext = false;
      throw const SyncException(SyncError.unreachable);
    }
    return answer;
  }
}
