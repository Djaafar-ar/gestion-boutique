import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/session/session_cubit.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/alerts/data/alert_repository.dart';
import 'package:billing_app/features/alerts/domain/alert.dart';
import 'package:billing_app/features/auth/data/owner_approval.dart';
import 'package:billing_app/features/billing/data/repositories/sale_repository_impl.dart';
import 'package:billing_app/features/billing/domain/entities/cart_item.dart';
import 'package:billing_app/features/billing/domain/entities/sale.dart';
import 'package:billing_app/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:billing_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/stats/data/stats_repository.dart';
import 'package:billing_app/features/stock/data/repositories/stock_repository_impl.dart';
import 'package:billing_app/features/stock/data/stock_ledger.dart';
import 'package:billing_app/features/stock/domain/entities/loss.dart';
import 'package:billing_app/features/users/data/repositories/user_repository_impl.dart';
import 'package:billing_app/features/users/domain/entities/app_user.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// Returns without a receipt and exchanges.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late SettingsStore settings;
  late SessionCubit session;
  late SaleRepositoryImpl sales;
  late StockRepositoryImpl stock;
  late ProductRepositoryImpl products;
  late AppUser karim;
  late AppUser amine;

  const soda = Product(
      id: 'soda',
      name: 'Hamoud 33cl',
      barcode: '1',
      sellPrice: 6000,
      buyPrice: 4000);
  const juice = Product(
      id: 'juice',
      name: 'Jus Rouiba 1L',
      barcode: '2',
      sellPrice: 18000,
      buyPrice: 14000);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    settings = SettingsStore(db);
    await settings.load();
    final users = UserRepositoryImpl(db, settings);
    karim = (await users.createOwner(name: 'Karim', phone: '', pin: '1234'))
        .getOrElse((f) => fail(f.message))
        .owner;
    amine = (await users.addWorker(
            actorId: karim.id, name: 'Amine', phone: '', pin: '5678'))
        .getOrElse((f) => fail(f.message));
    session = SessionCubit(hasOwner: true)..login(karim);
    products = ProductRepositoryImpl(db, settings, session);
    await products.addProduct(soda);
    await products.addProduct(juice);
    stock =
        StockRepositoryImpl(db, settings, session, StockLedger(db), products);
    await stock.addDelivery(productId: 'soda', quantity: 10, buyPrice: 4000);
    await stock.addDelivery(productId: 'juice', quantity: 10, buyPrice: 14000);
    sales = SaleRepositoryImpl(db, settings, session, StockLedger(db),
        ownerApproval: ownerApprovalWith(users));
    await settings.set('alerts_since', DateTime(2020).toIso8601String());
  });

  tearDown(() async {
    await session.close();
    await db.close();
  });

  Future<int> stockOf(String id) async =>
      (await stock.getBatches(id)).getOrElse((f) => fail(f.message)).stock;

  Future<Sale> sell(List<CartItem> items) async =>
      (await sales.saveSale(items)).getOrElse((f) => fail(f.message));

  final today = DateTime.now().subtract(const Duration(hours: 1));
  final later = DateTime.now().add(const Duration(hours: 1));

  group('without a receipt', () {
    test('refunded at today\'s price, back on the shelf', () async {
      // The price went up since the customer bought it.
      await products.updateProduct(soda.copyWith(sellPrice: 7000));
      final result = (await sales.processReturn(looseLines: const [
        LooseReturnLine(productId: 'soda', quantity: 2, backToStock: true),
      ]))
          .getOrElse((f) => fail(f.message));

      expect(result.refund, 14000);
      expect(result.difference, -14000, reason: 'give back 140 DA');
      expect(await stockOf('soda'), 12);

      final stats = await StatsRepository(db).getStats(from: today, to: later);
      expect(stats.refunds, 14000);
      expect(stats.returnsCount, 1);
      expect(stats.cashRefunds, 14000);
      expect(stats.cost, -8000, reason: 'two items came back at 40 DA');
    });

    test('damaged: a loss, the stock does not change', () async {
      await sales.processReturn(looseLines: const [
        LooseReturnLine(productId: 'soda', quantity: 1, backToStock: false),
      ]);
      expect(await stockOf('soda'), 10);
      final losses =
          (await stock.getLosses()).getOrElse((f) => fail(f.message));
      expect(losses.single.reason, LossReason.damaged);
      expect(losses.single.value, 4000);
      expect(losses.single.fromReturn, isTrue);
    });

    test('a worker needs the owner\'s PIN', () async {
      session.login(amine);
      const line =
          LooseReturnLine(productId: 'soda', quantity: 1, backToStock: true);

      final none = await sales.processReturn(looseLines: const [line]);
      expect(none.getLeft().toNullable(), isA<OwnerApprovalFailure>());
      final wrong =
          await sales.processReturn(looseLines: const [line], ownerPin: '0000');
      expect(wrong.getLeft().toNullable(), isA<OwnerApprovalFailure>());
      // The worker's own PIN is not enough either.
      final own =
          await sales.processReturn(looseLines: const [line], ownerPin: '5678');
      expect(own.getLeft().toNullable(), isA<OwnerApprovalFailure>());
      expect(await stockOf('soda'), 10, reason: 'nothing saved');

      final ok =
          await sales.processReturn(looseLines: const [line], ownerPin: '1234');
      expect(ok.isRight(), isTrue);
      final saved = await db.select(db.returns).getSingle();
      expect(saved.approvedBy, karim.id);
      expect(saved.userId, amine.id);
      expect(saved.saleId, isNull);
    });

    test('alerts the owner and counts for the worker in the stats', () async {
      session.login(amine);
      await sales.processReturn(looseLines: const [
        LooseReturnLine(productId: 'soda', quantity: 1, backToStock: true),
      ], ownerPin: '1234');

      await AlertRepository(db, settings).refresh();
      final alert = (await AlertRepository(db, settings)
              .getAlerts(userId: karim.id, isOwner: true))
          .singleWhere((a) => a.type == AlertType.returnMade);
      expect(alert.data['kind'], 'noReceipt');
      expect(alert.data['amount'], 6000);

      final mine = await StatsRepository(db)
          .getStats(from: today, to: later, userId: amine.id);
      expect(mine.refunds, 6000);
      final summary = (await sales.getSummary(userId: amine.id))
          .getOrElse((f) => fail(f.message));
      expect(summary.revenue, -6000);
    });

    test('cannot go on a customer account', () async {
      final result = await sales.processReturn(looseLines: const [
        LooseReturnLine(productId: 'soda', quantity: 1, backToStock: true),
      ], toCredit: true);
      expect(result.isLeft(), isTrue);
    });
  });

  group('exchange', () {
    test('bring back a soda, take a juice: pay the difference', () async {
      final ticket = await sell(const [CartItem(product: soda, quantity: 2)]);
      final result = (await sales.processReturn(
        saleId: ticket.id,
        lines: [
          ReturnLine(
              saleItemId: ticket.items.single.id,
              quantity: 1,
              backToStock: true),
        ],
        takes: const [CartItem(product: juice)],
      ))
          .getOrElse((f) => fail(f.message));

      expect(result.refund, 6000);
      expect(result.exchangeSale!.total, 18000);
      expect(result.difference, 12000, reason: 'customer pays 120 DA');
      expect(result.exchangeSale!.exchangeCredit, 6000);
      expect(await stockOf('soda'), 9);
      expect(await stockOf('juice'), 9);

      // The old ticket shows one soda returned.
      final old =
          (await sales.getSale(ticket.id)).getOrElse((f) => fail(f.message));
      expect(old.items.single.returned, 1);

      // Drawer: 120 DA first ticket + 180 DA new one - 60 DA given back.
      final stats = await StatsRepository(db).getStats(from: today, to: later);
      expect(stats.salesCount, 2);
      expect(stats.revenue, 12000 + 18000 - 6000);
      expect(stats.cashInHand, 12000 + 12000);
    });

    test('bring back more than taken: give the rest back', () async {
      final ticket = await sell(const [CartItem(product: juice)]);
      final result = (await sales.processReturn(
        saleId: ticket.id,
        lines: [
          ReturnLine(
              saleItemId: ticket.items.single.id,
              quantity: 1,
              backToStock: true),
        ],
        takes: const [CartItem(product: soda)],
      ))
          .getOrElse((f) => fail(f.message));
      expect(result.difference, -12000);
    });

    test('a credit ticket: the refund lowers the debt, new items are paid',
        () async {
      final customers = CustomerRepositoryImpl(db, settings, session);
      final mohamed = (await customers.saveCustomer(name: 'Mohamed'))
          .getOrElse((f) => fail(f.message));
      final ticket = (await sales.saveSale(const [CartItem(product: soda)],
              customerId: mohamed.id))
          .getOrElse((f) => fail(f.message));

      final result = (await sales.processReturn(
        saleId: ticket.id,
        lines: [
          ReturnLine(
              saleItemId: ticket.items.single.id,
              quantity: 1,
              backToStock: true),
        ],
        takes: const [CartItem(product: juice)],
        toCredit: true,
      ))
          .getOrElse((f) => fail(f.message));

      expect(result.difference, 18000);
      expect(result.exchangeSale!.exchangeCredit, 0);
      expect(
          (await customers.getCustomer(mohamed.id))
              .getOrElse((f) => fail(f.message))
              .debt,
          0);
    });

    test('without a receipt too', () async {
      final result = (await sales.processReturn(
        looseLines: const [
          LooseReturnLine(productId: 'soda', quantity: 3, backToStock: true),
        ],
        takes: const [CartItem(product: juice)],
      ))
          .getOrElse((f) => fail(f.message));
      expect(result.difference, 0);
      expect(await stockOf('soda'), 13);
      expect(await stockOf('juice'), 9);
    });

    test("a worker's exchange alerts the owner", () async {
      final ticket = await sell(const [CartItem(product: soda)]);
      session.login(amine);
      await sales.processReturn(
        saleId: ticket.id,
        lines: [
          ReturnLine(
              saleItemId: ticket.items.single.id,
              quantity: 1,
              backToStock: true),
        ],
        takes: const [CartItem(product: juice)],
      );
      await AlertRepository(db, settings).refresh();
      final alert = (await AlertRepository(db, settings)
              .getAlerts(userId: karim.id, isOwner: true))
          .singleWhere((a) => a.type == AlertType.returnMade);
      expect(alert.data['kind'], 'exchange');
      expect(alert.data['amount'], 6000);
      expect(alert.data['taken'], 18000);
    });
  });

  test('nothing brought back is refused', () async {
    expect(
        (await sales.processReturn(takes: const [CartItem(product: soda)]))
            .isLeft(),
        isTrue);
  });
}
