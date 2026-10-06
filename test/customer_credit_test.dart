import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/core/session/session_cubit.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/billing/data/repositories/sale_repository_impl.dart';
import 'package:billing_app/features/billing/domain/entities/cart_item.dart';
import 'package:billing_app/features/billing/domain/entities/sale.dart';
import 'package:billing_app/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:billing_app/features/customers/domain/entities/customer.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:billing_app/features/shop/domain/entities/shop.dart';
import 'package:billing_app/features/stock/data/stock_ledger.dart';
import 'package:billing_app/features/users/domain/entities/app_user.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// The carnet: credit sales, payments, returns and the credit limit.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late SessionCubit session;
  late SaleRepositoryImpl sales;
  late CustomerRepositoryImpl customers;

  const karim = AppUser(id: 'u-karim', name: 'Karim', role: UserRole.owner);
  const amine = AppUser(id: 'u-amine', name: 'Amine', role: UserRole.worker);

  // 650 DA a pack.
  const pack =
      Product(id: 'p1', name: 'Lait Candia', barcode: '1', sellPrice: 65000);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final settings = SettingsStore(db);
    await settings.load();
    session = SessionCubit(hasOwner: true)..login(karim);
    sales = SaleRepositoryImpl(db, settings, session, StockLedger(db));
    customers = CustomerRepositoryImpl(db, settings, session);
    // Nothing is delivered in these tests: workers may sell anyway.
    await ShopRepositoryImpl(db, settings)
        .updateShop(const Shop(name: 'Test', workersSellWithoutStock: true));
  });

  tearDown(() async {
    await session.close();
    await db.close();
  });

  Future<Customer> newCustomer({int? limit}) async => (await customers
          .saveCustomer(name: 'Mohamed', phone: '0555', creditLimit: limit))
      .getOrElse((f) => fail(f.message));

  Future<int> debtOf(String id) async =>
      (await customers.getCustomer(id)).getOrElse((f) => fail(f.message)).debt;

  Future<Sale> creditSale(String customerId,
          {int quantity = 1,
          int paidNow = 0,
          bool allowOverLimit = false}) async =>
      (await sales.saveSale([CartItem(product: pack, quantity: quantity)],
              customerId: customerId,
              paidNow: paidNow,
              allowOverLimit: allowOverLimit))
          .getOrElse((f) => fail(f.message));

  test('the unpaid part of a credit sale becomes debt', () async {
    final c = await newCustomer();
    final sale = await creditSale(c.id, quantity: 2, paidNow: 20000);

    expect(sale.isCredit, isTrue);
    expect(sale.customerName, 'Mohamed');
    expect(sale.paidNow, 20000);
    expect(sale.onCredit, 110000); // 1 300 - 200 DA
    expect(await debtOf(c.id), 110000);
  });

  test('a cash sale never touches any debt', () async {
    final c = await newCustomer();
    final sale = (await sales.saveSale(const [CartItem(product: pack)]))
        .getOrElse((f) => fail(f.message));
    expect(sale.isCredit, isFalse);
    expect(sale.paidNow, sale.total);
    expect(await debtOf(c.id), 0);
  });

  test('paying more at the counter than the total is refused', () async {
    final c = await newCustomer();
    final result = await sales.saveSale(const [CartItem(product: pack)],
        customerId: c.id, paidNow: 70000);
    expect(result.isLeft(), isTrue);
  });

  test('payments lower the debt, never below zero', () async {
    final c = await newCustomer();
    await creditSale(c.id, quantity: 2); // 1 300 DA

    expect(
        (await customers.recordPayment(customerId: c.id, amount: 50000))
            .isRight(),
        isTrue);
    expect(await debtOf(c.id), 80000);

    final tooMuch =
        await customers.recordPayment(customerId: c.id, amount: 90000);
    expect(tooMuch.getLeft().toNullable(), const OverpaymentFailure(80000));
    expect(await debtOf(c.id), 80000);
  });

  test('a return put on the account lowers the debt', () async {
    final c = await newCustomer();
    final sale = await creditSale(c.id, quantity: 2);
    final refund = await sales.createReturn(
      saleId: sale.id,
      lines: [
        ReturnLine(
            saleItemId: sale.items.single.id, quantity: 1, backToStock: true)
      ],
      toCredit: true,
    );
    expect(refund.getOrElse((f) => fail(f.message)), 65000);
    expect(await debtOf(c.id), 65000);
  });

  test('a cash refund leaves the debt as it is', () async {
    final c = await newCustomer();
    final sale = await creditSale(c.id, quantity: 2, paidNow: 130000);
    await sales.createReturn(saleId: sale.id, lines: [
      ReturnLine(
          saleItemId: sale.items.single.id, quantity: 1, backToStock: true)
    ]);
    expect(await debtOf(c.id), 0);
  });

  test('a cash sale cannot be refunded "on the account"', () async {
    final sale = (await sales.saveSale(const [CartItem(product: pack)]))
        .getOrElse((f) => fail(f.message));
    final result = await sales.createReturn(
      saleId: sale.id,
      lines: [
        ReturnLine(
            saleItemId: sale.items.single.id, quantity: 1, backToStock: true)
      ],
      toCredit: true,
    );
    expect(result.isLeft(), isTrue);
  });

  group('credit limit', () {
    test('a sale over the limit is stopped', () async {
      final c = await newCustomer(limit: 100000); // 1 000 DA
      await creditSale(c.id); // 650 DA owed

      final result = await sales
          .saveSale(const [CartItem(product: pack)], customerId: c.id);
      expect(result.getLeft().toNullable(),
          const CreditLimitFailure(limit: 100000, debtAfter: 130000));
      expect(await debtOf(c.id), 65000, reason: 'nothing saved');
    });

    test('paying enough at the counter stays under the limit', () async {
      final c = await newCustomer(limit: 100000);
      await creditSale(c.id);
      await creditSale(c.id, paidNow: 40000); // 650 + 250 = 900 DA
      expect(await debtOf(c.id), 90000);
    });

    test('the owner may still allow it', () async {
      final c = await newCustomer(limit: 100000);
      await creditSale(c.id);
      await creditSale(c.id, allowOverLimit: true);
      expect(await debtOf(c.id), 130000);
    });

    test('a worker may not, even when asking', () async {
      final c = await newCustomer(limit: 100000);
      await creditSale(c.id);
      session.login(amine);
      final result = await sales.saveSale(const [CartItem(product: pack)],
          customerId: c.id, allowOverLimit: true);
      expect(result.getLeft().toNullable(), isA<CreditLimitFailure>());
    });

    test('only the owner sets the limit', () async {
      session.login(amine);
      final c = await newCustomer(limit: 500000);
      expect(c.creditLimit, isNull);

      session.login(karim);
      final withLimit = (await customers.saveCustomer(
              id: c.id, name: 'Mohamed', creditLimit: 500000))
          .getOrElse((f) => fail(f.message));
      expect(withLimit.creditLimit, 500000);

      // A worker editing the phone number keeps the owner's limit.
      session.login(amine);
      final edited = (await customers.saveCustomer(
              id: c.id, name: 'Mohamed', phone: '0666', creditLimit: null))
          .getOrElse((f) => fail(f.message));
      expect(edited.phone, '0666');
      expect(edited.creditLimit, 500000);
    });
  });

  test('the history says what happened and who did it', () async {
    final c = await newCustomer();
    session.login(amine);
    final sale = await creditSale(c.id, quantity: 2, paidNow: 30000);
    session.login(karim);
    await db.into(db.users).insert(UsersCompanion.insert(
        id: 'u-amine',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        deviceId: 'd',
        name: 'Amine',
        role: 'worker',
        pinHash: 'x',
        pinSalt: 'y'));
    await customers.recordPayment(
        customerId: c.id, amount: 20000, note: 'Espèces');

    final history =
        (await customers.getHistory(c.id)).getOrElse((f) => fail(f.message));
    expect(history.map((e) => (e.kind, e.amount)), [
      (CustomerEntryKind.payment, -20000),
      (CustomerEntryKind.sale, 100000),
    ]);
    expect(history.last.saleTicket, sale.ticket);
    expect(history.last.byName, 'Amine');
    expect(history.first.note, 'Espèces');
  });

  test('the shop total counts only what customers owe', () async {
    final a = await newCustomer();
    final b = (await customers.saveCustomer(name: 'Yacine'))
        .getOrElse((f) => fail(f.message));
    await creditSale(a.id);
    final saleB = await creditSale(b.id, paidNow: 65000);
    // Yacine returns the item onto his account: he now has an advance.
    await sales.createReturn(saleId: saleB.id, toCredit: true, lines: [
      ReturnLine(
          saleItemId: saleB.items.single.id, quantity: 1, backToStock: true)
    ]);
    expect(await debtOf(b.id), -65000);
    expect(
        (await customers.totalOwed()).getOrElse((f) => fail(f.message)), 65000);
  });

  test('only the owner archives a customer', () async {
    final c = await newCustomer();
    session.login(amine);
    expect((await customers.setArchived(c.id, true)).getLeft().toNullable(),
        isA<PermissionFailure>());
    session.login(karim);
    await customers.setArchived(c.id, true);
    final list =
        (await customers.getCustomers()).getOrElse((f) => fail(f.message));
    expect(list, isEmpty);
  });
}
