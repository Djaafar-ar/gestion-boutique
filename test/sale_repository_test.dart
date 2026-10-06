import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/session/session_cubit.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/billing/data/repositories/sale_repository_impl.dart';
import 'package:billing_app/features/billing/domain/entities/cart_item.dart';
import 'package:billing_app/features/billing/domain/entities/sale.dart';
import 'package:billing_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/stock/data/stock_ledger.dart';
import 'package:billing_app/features/users/domain/entities/app_user.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late SaleRepositoryImpl repo;
  late ProductRepositoryImpl products;
  late SessionCubit session;

  const amine = AppUser(id: 'u-amine', name: 'Amine', role: UserRole.worker);
  const karim = AppUser(id: 'u-karim', name: 'Karim', role: UserRole.owner);

  const juice = Product(
      id: 'p1',
      name: 'Jus Rouiba 1L',
      barcode: '111',
      sellPrice: 18000,
      buyPrice: 14000);
  const soda =
      Product(id: 'p2', name: 'Hamoud 33cl', barcode: '222', sellPrice: 6000);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final settings = SettingsStore(db);
    await settings.load();
    session = SessionCubit(hasOwner: true)..login(amine);
    repo = SaleRepositoryImpl(db, settings, session, StockLedger(db));
    products = ProductRepositoryImpl(db, settings, session);
  });

  tearDown(() async {
    await session.close();
    await db.close();
  });

  test('a saved sale keeps its lines, prices and total', () async {
    final result = await repo.saveSale(const [
      CartItem(product: juice, quantity: 2),
      CartItem(product: soda, quantity: 1),
    ]);
    final sale = result.getOrElse((f) => fail(f.message));

    expect(sale.number, 1);
    expect(sale.subtotal, 42000);
    expect(sale.total, 42000);
    expect(sale.paidNow, 42000);
    expect(sale.discount, 0);
    expect(sale.items, hasLength(2));
    expect(sale.items.first.productName, 'Jus Rouiba 1L');
    expect(sale.items.first.unitCost, 14000);
    expect(sale.itemCount, 3);
  });

  test('ticket numbers go up by one', () async {
    const cart = [CartItem(product: soda)];
    await repo.saveSale(cart);
    await repo.saveSale(cart);
    final third = (await repo.saveSale(cart)).getOrElse((f) => fail(f.message));

    expect(third.number, 3);
  });

  test('changing a product later does not change old sales', () async {
    await products.addProduct(juice);
    final sale = (await repo.saveSale(const [CartItem(product: juice)]))
        .getOrElse((f) => fail(f.message));

    // The juice now costs more, but the old sale keeps 180,00 DA.
    await products.updateProduct(
        juice.copyWith(name: 'Jus Rouiba 1L (nouveau)', sellPrice: 20000));
    final reloaded =
        (await repo.getSale(sale.id)).getOrElse((f) => fail(f.message));
    expect(reloaded.items.single.sellPrice, 18000);
    expect(reloaded.items.single.productName, 'Jus Rouiba 1L');
  });

  test('history lists newest first and filters by date', () async {
    await repo.saveSale(const [CartItem(product: juice)]);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.saveSale(const [CartItem(product: soda)]);

    final all = (await repo.getSales()).getOrElse((f) => fail(f.message));
    expect(all.map((s) => s.number), [2, 1]);

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final none =
        (await repo.getSales(from: tomorrow)).getOrElse((f) => fail(f.message));
    expect(none, isEmpty);
  });

  test('an empty cart is never saved', () async {
    final result = await repo.saveSale(const []);
    expect(result.isLeft(), isTrue);
    expect(await db.select(db.sales).get(), isEmpty);
  });

  test('each sale remembers who made it', () async {
    final sale = (await repo.saveSale(const [CartItem(product: soda)]))
        .getOrElse((f) => fail(f.message));

    expect(sale.userId, 'u-amine');
    final lines = await db.select(db.saleItems).get();
    expect(lines.single.userId, 'u-amine');
  });

  test('summary adds up revenue, tickets and items per person', () async {
    await repo.saveSale(const [CartItem(product: juice, quantity: 2)]);
    await repo.saveSale(const [CartItem(product: soda, quantity: 3)]);
    session.login(karim);
    await repo.saveSale(const [CartItem(product: juice)]);

    final amineTotals = (await repo.getSummary(userId: 'u-amine'))
        .getOrElse((f) => fail(f.message));
    expect(amineTotals.revenue, 2 * 18000 + 3 * 6000);
    expect(amineTotals.salesCount, 2);
    expect(amineTotals.itemsSold, 5);

    final everyone =
        (await repo.getSummary()).getOrElse((f) => fail(f.message));
    expect(everyone.salesCount, 3);
    expect(everyone.revenue, 2 * 18000 + 3 * 6000 + 18000);

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final future = (await repo.getSummary(from: tomorrow))
        .getOrElse((f) => fail(f.message));
    expect(future, SalesSummary.empty);
  });

  test('history can show one person only', () async {
    await repo.saveSale(const [CartItem(product: soda)]);
    session.login(karim);
    await repo.saveSale(const [CartItem(product: juice)]);

    final mine = (await repo.getSales(userId: 'u-karim'))
        .getOrElse((f) => fail(f.message));
    expect(mine.map((s) => s.number), [2]);
  });
}
