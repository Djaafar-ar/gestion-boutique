import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/session/session_cubit.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/alerts/data/alert_repository.dart';
import 'package:billing_app/features/alerts/domain/alert.dart';
import 'package:billing_app/features/billing/data/repositories/sale_repository_impl.dart';
import 'package:billing_app/features/billing/domain/entities/cart_item.dart';
import 'package:billing_app/features/billing/domain/entities/sale.dart';
import 'package:billing_app/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:billing_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/stock/data/repositories/stock_repository_impl.dart';
import 'package:billing_app/features/stock/data/stock_ledger.dart';
import 'package:billing_app/features/stock/domain/entities/loss.dart';
import 'package:billing_app/features/suppliers/data/repositories/supplier_repository_impl.dart';
import 'package:billing_app/features/users/domain/entities/app_user.dart';
import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// Which alerts exist, when they come back, and who sees them.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late SettingsStore settings;
  late SessionCubit session;
  late AlertRepository alerts;
  late ProductRepositoryImpl products;
  late StockRepositoryImpl stock;
  late SaleRepositoryImpl sales;

  const karim = AppUser(id: 'u-karim', name: 'Karim', role: UserRole.owner);
  const amine = AppUser(id: 'u-amine', name: 'Amine', role: UserRole.worker);
  // No alert level unless a test sets one.
  const soda =
      Product(id: 'soda', name: 'Hamoud 33cl', barcode: '1', sellPrice: 6000);

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
          deviceId: 'd',
          name: user.name,
          role: user.role.name,
          pinHash: 'x',
          pinSalt: 'y'));
    }
    products = ProductRepositoryImpl(db, settings, session);
    await products.addProduct(soda);
    stock =
        StockRepositoryImpl(db, settings, session, StockLedger(db), products);
    sales = SaleRepositoryImpl(db, settings, session, StockLedger(db));
    alerts = AlertRepository(db, settings);
    // Alerts are switched on before anything in these tests happens.
    await settings.set('alerts_since', DateTime(2020).toIso8601String());
  });

  tearDown(() async {
    await session.close();
    await db.close();
  });

  Future<List<Alert>> visible(AppUser user) =>
      alerts.getAlerts(userId: user.id, isOwner: user.isOwner);

  Future<Set<AlertType>> types(AppUser user) async =>
      (await visible(user)).map((a) => a.type).toSet();

  Future<void> sell(int quantity) async {
    final sale =
        await sales.saveSale([CartItem(product: soda, quantity: quantity)]);
    sale.getOrElse((f) => fail(f.message));
  }

  group('low stock', () {
    // Alert from 5 left.
    setUp(() => products.updateProduct(soda.copyWith(lowStockThreshold: 5)));

    test('appears at the alert level and goes away after a delivery', () async {
      await stock.addDelivery(productId: 'soda', quantity: 10, buyPrice: 4000);
      expect(await alerts.refresh(), isEmpty);

      await sell(5); // 5 left
      final raised = await alerts.refresh();
      expect(raised.map((a) => a.type), [AlertType.lowStock]);
      final alert = (await visible(karim)).single;
      expect(alert.data['quantity'], 5);
      expect(alert.data['product'], 'Hamoud 33cl');

      await stock.addDelivery(productId: 'soda', quantity: 24, buyPrice: 4000);
      expect(await alerts.refresh(), isEmpty);
      expect(await visible(karim), isEmpty);
    });

    test('is not repeated while nothing changes', () async {
      await sell(1); // below zero
      expect(await alerts.refresh(), hasLength(1));
      expect(await alerts.refresh(), isEmpty);
    });

    test('comes back unread when it happens again', () async {
      await stock.addDelivery(productId: 'soda', quantity: 6, buyPrice: 4000);
      await sell(2);
      await alerts.refresh();
      await alerts.markRead('lowStock:soda', karim.id);
      expect((await visible(karim)).single.read, isTrue);

      await stock.addDelivery(productId: 'soda', quantity: 20, buyPrice: 4000);
      await alerts.refresh(); // solved
      await sell(22); // 2 left
      expect(await alerts.refresh(), hasLength(1));
      expect((await visible(karim)).single.read, isFalse);
    });

    test('running out is worse than being low: notified again', () async {
      await stock.addDelivery(productId: 'soda', quantity: 6, buyPrice: 4000);
      await sell(2); // 4 left
      expect(await alerts.refresh(), hasLength(1));
      await sell(4); // 0 left
      expect(await alerts.refresh(), hasLength(1));
      await sell(1); // -1: sold without stock
      expect(await alerts.refresh(), hasLength(1));
      expect((await visible(karim)).single.data['quantity'], -1);
    });

    test('no alert level and some stock: no alert', () async {
      await products.addProduct(const Product(
          id: 'salt', name: 'Sel', barcode: '2', sellPrice: 3000));
      await stock.addDelivery(productId: 'salt', quantity: 1, buyPrice: 2000);
      await alerts.refresh();
      expect((await visible(karim)).where((a) => a.refId == 'salt'), isEmpty);
    });
  });

  group('expiry', () {
    final today = DateTime(2026, 10, 6, 10);

    test('soon, then expired, then gone once thrown away', () async {
      await stock.addDelivery(
          productId: 'soda',
          quantity: 10,
          buyPrice: 4000,
          expiryDate: DateTime(2026, 10, 8));

      await alerts.refresh(now: DateTime(2026, 10, 1));
      expect(await types(karim), isEmpty, reason: '7 days left');

      await alerts.refresh(now: today);
      expect(await types(karim), {AlertType.expiringSoon});

      await alerts.refresh(now: DateTime(2026, 10, 9));
      final expired = (await visible(karim)).single;
      expect(expired.type, AlertType.expired);
      expect(expired.data['remaining'], 10);

      final batch = (await stock.getBatches('soda'))
          .getOrElse((f) => fail(f.message))
          .batches
          .single;
      await stock.recordLoss(
          productId: 'soda',
          quantity: 10,
          reason: LossReason.expired,
          deliveryId: batch.deliveryId);
      await alerts.refresh(now: DateTime(2026, 10, 9));
      expect(await types(karim), isEmpty);
    });
  });

  test('supplier payments to validate: owner only, gone once decided',
      () async {
    final suppliers = SupplierRepositoryImpl(db, settings, session);
    final hamoud = (await suppliers.saveSupplier(name: 'Hamoud'))
        .getOrElse((f) => fail(f.message));
    session.login(amine);
    final payment =
        (await suppliers.recordPayment(supplierId: hamoud.id, amount: 50000))
            .getOrElse((f) => fail(f.message));

    final raised = await alerts.refresh();
    expect(raised.single.type, AlertType.pendingPayment);
    final alert = (await visible(karim)).single;
    expect(alert.data, containsPair('by', 'Amine'));
    expect(alert.data, containsPair('supplier', 'Hamoud'));
    expect(await visible(amine), isEmpty, reason: 'not for workers');

    session.login(karim);
    await suppliers.validatePayment(payment.id);
    await alerts.refresh();
    expect(await visible(karim), isEmpty);
  });

  test('customer over the credit limit', () async {
    final customers = CustomerRepositoryImpl(db, settings, session);
    final mohamed =
        (await customers.saveCustomer(name: 'Mohamed', creditLimit: 10000))
            .getOrElse((f) => fail(f.message));
    await sales.saveSale(const [CartItem(product: soda, quantity: 2)],
        customerId: mohamed.id, allowOverLimit: true);

    await alerts.refresh();
    final alert = (await visible(karim))
        .firstWhere((a) => a.type == AlertType.overCreditLimit);
    expect(alert.data, containsPair('debt', 12000));
    expect(alert.data, containsPair('limit', 10000));
    expect(await types(amine), isNot(contains(AlertType.overCreditLimit)));

    await customers.recordPayment(customerId: mohamed.id, amount: 5000);
    await alerts.refresh();
    expect(await types(karim), isNot(contains(AlertType.overCreditLimit)));
  });

  test('wrong PINs: one alert per account, notified again when more come',
      () async {
    Future<void> wrongPin() =>
        db.into(db.failedLogins).insert(FailedLoginsCompanion.insert(
            id: '${DateTime.now().microsecondsSinceEpoch}',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            deviceId: 'd',
            accountId: karim.id,
            kind: 'pin'));
    await wrongPin();
    await wrongPin();
    expect(await alerts.refresh(), hasLength(1));
    expect((await visible(karim)).single.data['count'], 2);
    expect(await visible(amine), isEmpty);

    await alerts.markRead('failedLogins:${karim.id}', karim.id);
    await wrongPin();
    expect(await alerts.refresh(), hasLength(1));
    expect((await visible(karim)).single.read, isFalse);

    // Seen on the security page: solved.
    await db
        .update(db.failedLogins)
        .write(const FailedLoginsCompanion(seen: Value(true)));
    await alerts.refresh();
    expect(await visible(karim), isEmpty);
  });

  test("a worker's delivery and return alert the owner, not the owner's own",
      () async {
    await stock.addDelivery(productId: 'soda', quantity: 30, buyPrice: 4000);
    session.login(amine);
    await stock.addDelivery(productId: 'soda', quantity: 12, buyPrice: 4000);
    final sale =
        (await sales.saveSale(const [CartItem(product: soda, quantity: 2)]))
            .getOrElse((f) => fail(f.message));
    await sales.createReturn(saleId: sale.id, lines: [
      ReturnLine(
          saleItemId: sale.items.single.id, quantity: 1, backToStock: true)
    ]);

    await alerts.refresh();
    final owner = await visible(karim);
    final delivery = owner.singleWhere((a) => a.type == AlertType.newDelivery);
    expect(delivery.data, containsPair('quantity', 12));
    expect(delivery.data, containsPair('by', 'Amine'));
    final ret = owner.singleWhere((a) => a.type == AlertType.returnMade);
    expect(ret.data, containsPair('number', sale.number));
    expect(await visible(amine), isEmpty);
  });

  test('things that happened before alerts were switched on are ignored',
      () async {
    session.login(amine);
    await stock.addDelivery(productId: 'soda', quantity: 12, buyPrice: 4000);
    await settings.set('alerts_since',
        DateTime.now().add(const Duration(minutes: 1)).toIso8601String());
    await alerts.refresh();
    expect(await types(karim), isEmpty);
  });

  test('reading is per person', () async {
    await sell(1);
    await alerts.refresh();
    await alerts.markAllRead(userId: amine.id, isOwner: false);
    expect((await visible(amine)).single.read, isTrue);
    expect((await visible(karim)).single.read, isFalse);
  });

  test('unread first, then newest first', () async {
    final suppliers = SupplierRepositoryImpl(db, settings, session);
    final hamoud = (await suppliers.saveSupplier(name: 'Hamoud'))
        .getOrElse((f) => fail(f.message));
    session.login(amine);
    await suppliers.recordPayment(supplierId: hamoud.id, amount: 100);
    await alerts.refresh();
    await sell(1);
    await alerts.refresh();
    await alerts.markRead('lowStock:soda', karim.id);

    final list = await visible(karim);
    expect(list.map((a) => (a.type, a.read)), [
      (AlertType.pendingPayment, false),
      (AlertType.lowStock, true),
    ]);
  });
}
