import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/session/session_cubit.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/billing/data/repositories/sale_repository_impl.dart';
import 'package:billing_app/features/billing/domain/entities/cart_item.dart';
import 'package:billing_app/features/billing/domain/entities/sale.dart';
import 'package:billing_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/entities/product_change.dart';
import 'package:billing_app/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:billing_app/features/shop/domain/entities/shop.dart';
import 'package:billing_app/features/stock/data/repositories/stock_repository_impl.dart';
import 'package:billing_app/features/stock/data/stock_ledger.dart';
import 'package:billing_app/features/stock/domain/entities/loss.dart';
import 'package:billing_app/features/users/domain/entities/app_user.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// Stock, sales, losses and returns working together on a real
// (in-memory) database.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late SessionCubit session;
  late ProductRepositoryImpl products;
  late StockRepositoryImpl stock;
  late SaleRepositoryImpl sales;

  const owner = AppUser(id: 'u-owner', name: 'Karim', role: UserRole.owner);
  const worker = AppUser(id: 'u-amine', name: 'Amine', role: UserRole.worker);
  const soda = Product(
      id: 'soda',
      name: 'Hamoud 33cl',
      barcode: '613',
      sellPrice: 6000,
      buyPrice: 4000);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final settings = SettingsStore(db);
    await settings.load();
    session = SessionCubit(hasOwner: true)..login(owner);
    final ledger = StockLedger(db);
    products = ProductRepositoryImpl(db, settings, session);
    stock = StockRepositoryImpl(db, settings, session, ledger, products);
    sales = SaleRepositoryImpl(db, settings, session, ledger);
    await products.addProduct(soda);
  });

  tearDown(() async {
    await session.close();
    await db.close();
  });

  Future<void> deliver(int quantity,
      {DateTime? expiry, int buyPrice = 4000}) async {
    (await stock.addDelivery(
            productId: 'soda',
            quantity: quantity,
            buyPrice: buyPrice,
            expiryDate: expiry))
        .getOrElse((f) => fail(f.message));
    // Deliveries one after the other, never at the same millisecond.
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }

  Future<Sale> sell(int quantity, {int discount = 0}) async =>
      (await sales.saveSale([CartItem(product: soda, quantity: quantity)],
              discount: discount))
          .getOrElse((f) => fail(f.message));

  Future<int> stockNow() async =>
      (await stock.getBatches('soda')).getOrElse((f) => fail(f.message)).stock;

  Future<List<int>> remainingPerBatch() async =>
      (await stock.getBatches('soda'))
          .getOrElse((f) => fail(f.message))
          .batches
          .map((b) => b.remaining)
          .toList();

  test('a delivery adds stock and records who received it', () async {
    await deliver(24, expiry: DateTime(2026, 11, 30));

    expect(await stockNow(), 24);
    final row = await db.select(db.deliveries).getSingle();
    expect(row.userId, 'u-owner');
    expect(row.expiryDate, DateTime(2026, 11, 30));
  });

  test('sales take from the batch that expires first', () async {
    await deliver(24, expiry: DateTime(2026, 11, 30));
    await deliver(10, expiry: DateTime(2026, 10, 12));

    await sell(12);

    // October (10) is emptied first, then 2 from November.
    expect(await remainingPerBatch(), [0, 22]);
    expect(await stockNow(), 22);
  });

  test('each sale line keeps the real buying price of its batches', () async {
    await deliver(2, expiry: DateTime(2026, 10, 12), buyPrice: 3000);
    await deliver(10, expiry: DateTime(2026, 11, 30), buyPrice: 4500);

    final sale = await sell(4);

    // (2 x 30,00 + 2 x 45,00) / 4 = 37,50 DA
    expect(sale.items.single.unitCost, 3750);
  });

  test('selling with no stock is allowed and shows below zero', () async {
    await sell(3);
    expect(await stockNow(), -3);

    // The forgotten delivery is entered later: 10 - 3 = 7.
    await deliver(10);
    expect(await stockNow(), 7);
  });

  test('sales from before stock tracking do not touch the stock', () async {
    final now = DateTime.now();
    await db.into(db.sales).insert(SalesCompanion.insert(
        id: 'old',
        createdAt: now,
        updatedAt: now,
        deviceId: 'd',
        number: 99,
        subtotal: 6000,
        total: 6000,
        paidNow: 6000));
    await db.into(db.saleItems).insert(SaleItemsCompanion.insert(
        id: 'old-line',
        createdAt: now,
        updatedAt: now,
        deviceId: 'd',
        saleId: 'old',
        productId: 'soda',
        productName: 'Hamoud 33cl',
        sellPrice: 6000,
        unitCost: 0,
        quantity: 1));
    await deliver(5);

    expect(await stockNow(), 5);
    // Returning that old item does not invent stock either.
    await sales.createReturn(saleId: 'old', lines: const [
      ReturnLine(saleItemId: 'old-line', quantity: 1, backToStock: true)
    ]);
    expect(await stockNow(), 5);
  });

  group('losses', () {
    test('a loss leaves the stock and is valued at buying price', () async {
      await deliver(10, buyPrice: 4000);

      final loss = (await stock.recordLoss(
              productId: 'soda', quantity: 2, reason: LossReason.damaged))
          .getOrElse((f) => fail(f.message));

      expect(await stockNow(), 8);
      expect(loss.value, 8000); // 2 x 40,00 DA
      expect(loss.userName, isNull); // no users table row in this test
    });

    test('an expired loss can take from the expired batch', () async {
      await deliver(5, expiry: DateTime(2026, 10, 1));
      await deliver(5, expiry: DateTime(2026, 12, 1));
      final batches = (await stock.getBatches('soda'))
          .getOrElse((f) => fail(f.message))
          .batches;
      final december = batches.last.deliveryId;

      await stock.recordLoss(
          productId: 'soda',
          quantity: 2,
          reason: LossReason.stolen,
          deliveryId: december);

      expect(await remainingPerBatch(), [5, 3]);
    });

    test('summary per person and period', () async {
      await deliver(10);
      session.login(worker);
      await stock.recordLoss(
          productId: 'soda', quantity: 1, reason: LossReason.staff);
      session.login(owner);
      await stock.recordLoss(
          productId: 'soda', quantity: 2, reason: LossReason.expired);

      final amine = (await stock.getLossSummary(userId: 'u-amine'))
          .getOrElse((f) => fail(f.message));
      expect((amine.count, amine.items, amine.value), (1, 1, 4000));
      final all =
          (await stock.getLossSummary()).getOrElse((f) => fail(f.message));
      expect(all.value, 12000);
    });
  });

  group('returns', () {
    test('back on the shelf: same batch, stock goes up again', () async {
      await deliver(10, expiry: DateTime(2026, 10, 12));
      await deliver(10, expiry: DateTime(2026, 11, 30));
      final sale = await sell(12); // 10 from October, 2 from November

      final refund = (await sales.createReturn(saleId: sale.id, lines: [
        ReturnLine(
            saleItemId: sale.items.single.id, quantity: 3, backToStock: true)
      ]))
          .getOrElse((f) => fail(f.message));

      expect(refund, 18000); // 3 x 60,00 DA
      // The last batch taken gets them back first: 2 to November, 1 to
      // October.
      expect(await remainingPerBatch(), [1, 10]);
      expect(await stockNow(), 11);
    });

    test('damaged: a loss is recorded but the stock does not change', () async {
      await deliver(10, buyPrice: 4000);
      final sale = await sell(2);

      await sales.createReturn(saleId: sale.id, lines: [
        ReturnLine(
            saleItemId: sale.items.single.id, quantity: 1, backToStock: false)
      ]);

      expect(await stockNow(), 8);
      final losses =
          (await stock.getLosses()).getOrElse((f) => fail(f.message));
      expect(losses.single.fromReturn, isTrue);
      expect(losses.single.reason, LossReason.damaged);
      expect(losses.single.value, 4000);
    });

    test('never more than what was sold', () async {
      await deliver(10);
      final sale = await sell(2);
      final line = sale.items.single.id;

      await sales.createReturn(saleId: sale.id, lines: [
        ReturnLine(saleItemId: line, quantity: 1, backToStock: true)
      ]);
      final tooMany = await sales.createReturn(saleId: sale.id, lines: [
        ReturnLine(saleItemId: line, quantity: 2, backToStock: true)
      ]);

      expect(tooMany.isLeft(), isTrue);
      final reloaded =
          (await sales.getSale(sale.id)).getOrElse((f) => fail(f.message));
      expect(reloaded.items.single.returned, 1);
      expect(reloaded.items.single.returnable, 1);
      expect(reloaded.refunded, 6000);
    });

    test('a discount is shared out on the refund', () async {
      await deliver(10);
      final sale = await sell(2, discount: 1200); // 120 - 12 = 108 DA

      final refund = (await sales.createReturn(saleId: sale.id, lines: [
        ReturnLine(
            saleItemId: sale.items.single.id, quantity: 1, backToStock: true)
      ]))
          .getOrElse((f) => fail(f.message));

      expect(refund, 5400); // half of 108,00 DA
    });

    test('returns are taken off the revenue of the seller', () async {
      await deliver(10);
      final sale = await sell(2);
      await sales.createReturn(saleId: sale.id, lines: [
        ReturnLine(
            saleItemId: sale.items.single.id, quantity: 1, backToStock: true)
      ]);

      final summary =
          (await sales.getSummary()).getOrElse((f) => fail(f.message));
      expect(summary.revenue, 6000);
      expect(summary.itemsSold, 1);
      expect(summary.salesCount, 1);
    });
  });

  group('discounts', () {
    test('saved on the sale and taken off the total', () async {
      final sale = await sell(2, discount: 1000);
      expect((sale.subtotal, sale.discount, sale.total, sale.paidNow),
          (12000, 1000, 11000, 11000));
    });

    test('a worker cannot pass the owner\'s limit', () async {
      await ShopRepositoryImpl(db, SettingsStore(db))
          .updateShop(const Shop(name: 'Test', maxWorkerDiscountPct: 10));
      await deliver(10);
      session.login(worker);

      // 10 % of 120 DA = 12 DA is fine, 12,01 DA is not.
      expect(
          (await sales.saveSale([const CartItem(product: soda, quantity: 2)],
                  discount: 1200))
              .isRight(),
          isTrue);
      final tooMuch = await sales.saveSale(
          [const CartItem(product: soda, quantity: 2)],
          discount: 1201);
      expect(tooMuch.getLeft().toNullable(), isA<DiscountLimitFailure>());
      expect(await sales.maxDiscountPercent(), 10);
    });

    test('the owner has no limit', () async {
      expect(await sales.maxDiscountPercent(), isNull);
      final sale = await sell(1, discount: 3000);
      expect(sale.total, 3000);
    });

    test('percent or amount, never more than the total', () {
      expect(const Discount.percent(10).centimesOf(12000), 1200);
      expect(const Discount.amount(500).centimesOf(12000), 500);
      expect(const Discount.amount(50000).centimesOf(12000), 12000);
    });
  });

  test('the Stock list shows quantity and nearest expiry', () async {
    await deliver(5, expiry: DateTime(2026, 12, 1));
    await deliver(3, expiry: DateTime(2026, 10, 20));

    final overview =
        (await stock.getOverview()).getOrElse((f) => fail(f.message));

    expect(overview['soda']!.quantity, 8);
    expect(overview['soda']!.nextExpiry, DateTime(2026, 10, 20));
  });

  test('a new buying price can update the product (with history)', () async {
    await stock.addDelivery(
        productId: 'soda',
        quantity: 5,
        buyPrice: 4500,
        updateProductBuyPrice: true);

    final product =
        (await products.getProducts()).getOrElse((f) => fail(f.message)).single;
    expect(product.buyPrice, 4500);
    final history =
        (await products.getHistory('soda')).getOrElse((f) => fail(f.message));
    expect(history.single.field, ProductField.buyPrice);
  });
}
