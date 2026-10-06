import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/core/session/session_cubit.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/stock/data/repositories/stock_repository_impl.dart';
import 'package:billing_app/features/stock/data/stock_ledger.dart';
import 'package:billing_app/features/suppliers/data/repositories/supplier_repository_impl.dart';
import 'package:billing_app/features/suppliers/domain/entities/supplier.dart';
import 'package:billing_app/features/users/domain/entities/app_user.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// Suppliers: what the shop owes, and payments waiting for the owner.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late SessionCubit session;
  late SupplierRepositoryImpl suppliers;
  late StockRepositoryImpl stock;

  const karim = AppUser(id: 'u-karim', name: 'Karim', role: UserRole.owner);
  const amine = AppUser(id: 'u-amine', name: 'Amine', role: UserRole.worker);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final settings = SettingsStore(db);
    await settings.load();
    session = SessionCubit(hasOwner: true)..login(karim);
    final products = ProductRepositoryImpl(db, settings, session);
    await products.addProduct(const Product(
        id: 'p1', name: 'Hamoud 33cl', barcode: '1', sellPrice: 6000));
    stock =
        StockRepositoryImpl(db, settings, session, StockLedger(db), products);
    suppliers = SupplierRepositoryImpl(db, settings, session);
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
  });

  tearDown(() async {
    await session.close();
    await db.close();
  });

  Future<Supplier> hamoud() async =>
      (await suppliers.saveSupplier(name: 'Hamoud Boualem', phone: '021'))
          .getOrElse((f) => fail(f.message));

  Future<Supplier> reload(String id) async =>
      (await suppliers.getSupplier(id)).getOrElse((f) => fail(f.message));

  test('deliveries from a supplier add to what the shop owes', () async {
    final s = await hamoud();
    // 24 x 40 DA + 10 x 45 DA = 1 410 DA
    await stock.addDelivery(
        productId: 'p1', quantity: 24, buyPrice: 4000, supplierId: s.id);
    await stock.addDelivery(
        productId: 'p1', quantity: 10, buyPrice: 4500, supplierId: s.id);
    await stock.addDelivery(productId: 'p1', quantity: 5, buyPrice: 4000);

    final loaded = await reload(s.id);
    expect(loaded.delivered, 141000);
    expect(loaded.balance, 141000);

    final deliveries =
        (await suppliers.getDeliveries(s.id)).getOrElse((f) => fail(f.message));
    expect(deliveries, hasLength(2));
    expect(deliveries.first.productName, 'Hamoud 33cl');
    expect(deliveries.first.receivedByName, 'Karim');
  });

  test("the owner's payment counts at once", () async {
    final s = await hamoud();
    await stock.addDelivery(
        productId: 'p1', quantity: 24, buyPrice: 4000, supplierId: s.id);
    final payment = (await suppliers.recordPayment(
            supplierId: s.id, amount: 50000, note: 'Chèque'))
        .getOrElse((f) => fail(f.message));

    expect(payment.status, PaymentStatus.validated);
    expect(payment.validatedByName, 'Karim');
    expect((await reload(s.id)).balance, 46000);
  });

  test("a worker's payment waits and does not count yet", () async {
    final s = await hamoud();
    await stock.addDelivery(
        productId: 'p1', quantity: 24, buyPrice: 4000, supplierId: s.id);
    session.login(amine);
    final payment =
        (await suppliers.recordPayment(supplierId: s.id, amount: 50000))
            .getOrElse((f) => fail(f.message));

    expect(payment.status, PaymentStatus.pending);
    expect(payment.paidByName, 'Amine');
    final loaded = await reload(s.id);
    expect(loaded.balance, 96000, reason: 'pending is not counted');
    expect(loaded.pending, 50000);
    expect(await suppliers.pendingCount(), 1);
  });

  test('validating counts it; rejecting never does', () async {
    final s = await hamoud();
    await stock.addDelivery(
        productId: 'p1', quantity: 24, buyPrice: 4000, supplierId: s.id);
    session.login(amine);
    final first =
        (await suppliers.recordPayment(supplierId: s.id, amount: 30000))
            .getOrElse((f) => fail(f.message));
    final second =
        (await suppliers.recordPayment(supplierId: s.id, amount: 20000))
            .getOrElse((f) => fail(f.message));

    session.login(karim);
    expect((await suppliers.validatePayment(first.id)).isRight(), isTrue);
    expect((await suppliers.rejectPayment(second.id)).isRight(), isTrue);

    final loaded = await reload(s.id);
    expect(loaded.balance, 66000);
    expect(loaded.pending, 0);
    expect(await suppliers.pendingCount(), 0);

    final payments = (await suppliers.getPayments(supplierId: s.id))
        .getOrElse((f) => fail(f.message));
    final validated = payments.firstWhere((p) => p.id == first.id);
    expect(validated.validatedByName, 'Karim');
    expect(validated.validatedAt, isNotNull);
  });

  test('a decision is final', () async {
    final s = await hamoud();
    session.login(amine);
    final p = (await suppliers.recordPayment(supplierId: s.id, amount: 1000))
        .getOrElse((f) => fail(f.message));
    session.login(karim);
    await suppliers.rejectPayment(p.id);
    expect((await suppliers.validatePayment(p.id)).isLeft(), isTrue);
    expect((await reload(s.id)).paid, 0);
  });

  test('workers cannot validate or reject', () async {
    final s = await hamoud();
    session.login(amine);
    final p = (await suppliers.recordPayment(supplierId: s.id, amount: 1000))
        .getOrElse((f) => fail(f.message));
    expect((await suppliers.validatePayment(p.id)).getLeft().toNullable(),
        isA<PermissionFailure>());
    expect((await suppliers.rejectPayment(p.id)).getLeft().toNullable(),
        isA<PermissionFailure>());
    expect(await suppliers.pendingCount(), 1);
  });

  test('the list of payments to validate shows only pending ones', () async {
    final s = await hamoud();
    await suppliers.recordPayment(supplierId: s.id, amount: 1000); // owner
    session.login(amine);
    await suppliers.recordPayment(supplierId: s.id, amount: 2000);
    final pending = (await suppliers.getPayments(status: PaymentStatus.pending))
        .getOrElse((f) => fail(f.message));
    expect(pending.map((p) => (p.amount, p.supplierName)),
        [(2000, 'Hamoud Boualem')]);
  });

  test('a zero payment is refused', () async {
    final s = await hamoud();
    expect(
        (await suppliers.recordPayment(supplierId: s.id, amount: 0)).isLeft(),
        isTrue);
  });
}
