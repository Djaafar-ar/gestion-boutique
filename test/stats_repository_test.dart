import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/session/session_cubit.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/core/utils/date_format.dart';
import 'package:billing_app/features/billing/data/repositories/sale_repository_impl.dart';
import 'package:billing_app/features/billing/domain/entities/cart_item.dart';
import 'package:billing_app/features/billing/domain/entities/sale.dart';
import 'package:billing_app/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:billing_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/stats/data/stats_repository.dart';
import 'package:billing_app/features/stats/domain/stats.dart';
import 'package:billing_app/features/stock/data/repositories/stock_repository_impl.dart';
import 'package:billing_app/features/stock/data/stock_ledger.dart';
import 'package:billing_app/features/stock/domain/entities/loss.dart';
import 'package:billing_app/features/suppliers/data/repositories/supplier_repository_impl.dart';
import 'package:billing_app/features/users/domain/entities/app_user.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// The Stats tab figures, checked on a small day of business:
//
// - Amine sells 2 juices + 1 soda (420 DA) with a 20 DA discount: 400 DA cash.
// - Karim sells 3 sodas (180 DA) on credit to Mohamed, who pays 50 DA now.
// - Karim takes back 1 soda of Amine's ticket (back on the shelf), cash.
// - Amine throws away 2 expired sodas, receives 30 DA from Mohamed and
//   pays 100 DA to a supplier (waiting for validation).
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late SessionCubit session;
  late StatsRepository stats;
  late int refund;

  const karim = AppUser(id: 'u-karim', name: 'Karim', role: UserRole.owner);
  const amine = AppUser(id: 'u-amine', name: 'Amine', role: UserRole.worker);
  const juice = Product(
      id: 'juice',
      name: 'Jus Rouiba 1L',
      barcode: '1',
      sellPrice: 18000,
      buyPrice: 14000);
  const soda = Product(
      id: 'soda',
      name: 'Hamoud 33cl',
      barcode: '2',
      sellPrice: 6000,
      buyPrice: 4000);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final settings = SettingsStore(db);
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
    final products = ProductRepositoryImpl(db, settings, session);
    await products.addProduct(juice);
    await products.addProduct(soda);
    final stock =
        StockRepositoryImpl(db, settings, session, StockLedger(db), products);
    await stock.addDelivery(productId: 'juice', quantity: 10, buyPrice: 14000);
    await stock.addDelivery(productId: 'soda', quantity: 24, buyPrice: 4000);
    final sales = SaleRepositoryImpl(db, settings, session, StockLedger(db));
    final customers = CustomerRepositoryImpl(db, settings, session);
    final suppliers = SupplierRepositoryImpl(db, settings, session);
    final mohamed = (await customers.saveCustomer(name: 'Mohamed'))
        .getOrElse((f) => fail(f.message));
    final hamoud = (await suppliers.saveSupplier(name: 'Hamoud'))
        .getOrElse((f) => fail(f.message));

    session.login(amine);
    final ticket = (await sales.saveSale(const [
      CartItem(product: juice, quantity: 2),
      CartItem(product: soda),
    ], discount: 2000))
        .getOrElse((f) => fail(f.message));

    session.login(karim);
    await sales.saveSale(const [CartItem(product: soda, quantity: 3)],
        customerId: mohamed.id, paidNow: 5000);
    final sodaLine = ticket.items.firstWhere((l) => l.productId == 'soda');
    refund = (await sales.createReturn(saleId: ticket.id, lines: [
      ReturnLine(saleItemId: sodaLine.id, quantity: 1, backToStock: true)
    ]))
        .getOrElse((f) => fail(f.message));

    session.login(amine);
    await stock.recordLoss(
        productId: 'soda', quantity: 2, reason: LossReason.expired);
    await customers.recordPayment(customerId: mohamed.id, amount: 3000);
    await suppliers.recordPayment(supplierId: hamoud.id, amount: 10000);

    stats = StatsRepository(db);
  });

  tearDown(() async {
    await session.close();
    await db.close();
  });

  final today = startOfDay(DateTime.now());
  final tomorrow = today.add(const Duration(days: 1));

  Future<Stats> load({String? userId}) =>
      stats.getStats(from: today, to: tomorrow, userId: userId);

  test('the refund shares out the discount', () {
    expect(refund, (6000 * 40000 / 42000).round()); // 57,14 DA
  });

  group('whole shop', () {
    test('sales, discounts, returns and revenue', () async {
      final s = await load();
      expect(s.salesCount, 2);
      expect(s.grossSales, 60000);
      expect(s.discounts, 2000);
      expect(s.salesTotal, 58000);
      expect(s.refunds, refund);
      expect(s.returnsCount, 1);
      expect(s.revenue, 58000 - refund);
      expect(s.itemsSold, 5); // 6 sold, 1 brought back
      expect(s.averageTicket, 29000);
    });

    test('profit: revenue minus buying price, then minus losses', () async {
      final s = await load();
      // 2 x 140 + 1 x 40 + 3 x 40 = 440 DA, minus the soda back on the shelf.
      expect(s.cost, 40000);
      expect(s.profit, 58000 - refund - 40000);
      expect(s.lossesByReason, {LossReason.expired: 8000});
      expect(s.netProfit, s.profit - 8000);
    });

    test('cash and credit, and what should be in the drawer', () async {
      final s = await load();
      expect(s.paidAtCounter, 45000);
      expect(s.onCredit, 13000);
      expect(s.customerPayments, 3000);
      expect(s.cashRefunds, refund);
      expect(s.cashInHand, 45000 + 3000 - refund);
      expect(s.supplierPaid, 10000);
    });

    test('per person', () async {
      final s = await load();
      expect(
          s.perWorker.map((w) =>
              (w.name, w.revenue, w.salesCount, w.discounts, w.collected)),
          [
            ('Amine', 40000 - refund, 1, 2000, 3000),
            ('Karim', 18000, 1, 0, 0),
          ]);
    });

    test('best sellers and debtors', () async {
      final s = await load();
      expect(s.topProducts.map((p) => (p.name, p.quantity, p.amount)), [
        ('Jus Rouiba 1L', 2, 36000),
        ('Hamoud 33cl', 4, 24000),
      ]);
      expect(s.totalOwed, 10000);
      expect(s.topDebtors, [('Mohamed', 10000)]);
    });

    test('one bar for today', () async {
      final s = await load();
      expect(s.byMonth, isFalse);
      expect(s.perDay, [DayAmount(today, 58000 - refund)]);
    });
  });

  test('one person: only what they did', () async {
    final s = await load(userId: amine.id);
    expect(s.salesCount, 1);
    expect(s.salesTotal, 40000);
    // The return was on Amine's ticket, but Karim gave the cash back.
    expect(s.refunds, refund);
    expect(s.cashRefunds, 0);
    expect(s.itemsSold, 2);
    expect(s.cost, 28000 + 4000 - 4000);
    expect(s.lossesValue, 8000);
    expect(s.customerPayments, 3000);
    expect(s.supplierPaid, 10000);
    expect(s.paidAtCounter, 40000);
    expect(s.perWorker, isEmpty);
  });

  test('another period is empty', () async {
    final s = await stats.getStats(
        from: today.subtract(const Duration(days: 7)), to: today);
    expect(s.salesCount, 0);
    expect(s.revenue, 0);
    expect(s.perDay, hasLength(7));
    expect(s.perDay.every((d) => d.amount == 0), isTrue);
  });

  test('long periods are counted month by month', () async {
    final s = await stats.getStats(
        from: DateTime(today.year, today.month - 5), to: tomorrow);
    expect(s.byMonth, isTrue);
    expect(s.perDay, hasLength(6));
    expect(s.perDay.last.amount, 58000 - refund);
  });
}
