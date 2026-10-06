import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/l10n/app_localizations.dart';
import 'package:billing_app/core/service_locator.dart';
import 'package:billing_app/core/session/session_cubit.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/alerts/data/alert_repository.dart';
import 'package:billing_app/features/alerts/domain/alert.dart';
import 'package:billing_app/features/billing/data/receipt_printer.dart';
import 'package:billing_app/features/billing/data/repositories/sale_repository_impl.dart';
import 'package:billing_app/features/billing/domain/entities/cart_item.dart';
import 'package:billing_app/features/billing/domain/entities/sale.dart';
import 'package:billing_app/features/billing/domain/repositories/sale_repository.dart';
import 'package:billing_app/features/billing/presentation/bloc/billing_bloc.dart';
import 'package:billing_app/features/billing/presentation/pages/checkout_page.dart';
import 'package:billing_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/usecases/product_usecases.dart';
import 'package:billing_app/features/product/presentation/bloc/product_bloc.dart';
import 'package:billing_app/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:billing_app/features/shop/domain/entities/shop.dart';
import 'package:billing_app/features/shop/domain/usecases/shop_usecases.dart';
import 'package:billing_app/features/shop/presentation/bloc/shop_bloc.dart';
import 'package:billing_app/features/stock/data/repositories/stock_repository_impl.dart';
import 'package:billing_app/features/stock/data/stock_ledger.dart';
import 'package:billing_app/features/users/domain/entities/app_user.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// "Les employés peuvent vendre sans stock" (off by default): a worker
// cannot sell more than the stock; the owner always can.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late SettingsStore settings;
  late SessionCubit session;
  late SaleRepositoryImpl sales;
  late StockRepositoryImpl stock;
  late ShopRepositoryImpl shops;
  late ProductRepositoryImpl products;

  const karim = AppUser(id: 'u-karim', name: 'Karim', role: UserRole.owner);
  const amine = AppUser(id: 'u-amine', name: 'Amine', role: UserRole.worker);
  const soda = Product(
      id: 'soda',
      name: 'Hamoud 33cl',
      barcode: '1',
      sellPrice: 6000,
      buyPrice: 4000);
  const juice =
      Product(id: 'juice', name: 'Jus Rouiba', barcode: '2', sellPrice: 18000);

  setUp(() async {
    await sl.reset();
    db = AppDatabase(NativeDatabase.memory());
    settings = SettingsStore(db);
    await settings.load();
    session = SessionCubit(hasOwner: true)..login(karim);
    products = ProductRepositoryImpl(db, settings, session);
    await products.addProduct(soda);
    await products.addProduct(juice);
    stock =
        StockRepositoryImpl(db, settings, session, StockLedger(db), products);
    await stock.addDelivery(productId: 'soda', quantity: 3, buyPrice: 4000);
    sales = SaleRepositoryImpl(db, settings, session, StockLedger(db));
    shops = ShopRepositoryImpl(db, settings);
    await shops.updateShop(const Shop(name: 'Épicerie'));
    await settings.set('alerts_since', DateTime(2020).toIso8601String());
  });

  tearDown(() async {
    await session.close();
    await db.close();
    await sl.reset();
  });

  Future<int> stockOf(String id) async =>
      (await stock.getBatches(id)).getOrElse((f) => fail(f.message)).stock;

  group('worker, rule off (the default)', () {
    setUp(() => session.login(amine));

    test('selling what is in stock works', () async {
      final result =
          await sales.saveSale(const [CartItem(product: soda, quantity: 3)]);
      expect(result.isRight(), isTrue);
      expect(await stockOf('soda'), 0);
    });

    test('more than the stock is refused, nothing is saved', () async {
      final result =
          await sales.saveSale(const [CartItem(product: soda, quantity: 4)]);
      expect(
          result.getLeft().toNullable(),
          isA<StockShortFailure>()
              .having((f) => f.productId, 'product', 'soda')
              .having((f) => f.available, 'available', 3)
              .having((f) => f.wanted, 'wanted', 4));
      expect(await stockOf('soda'), 3);
      expect(await db.select(db.sales).get(), isEmpty);
    });

    test('the same product on two cart lines counts together', () async {
      final result = await sales.saveSale(const [
        CartItem(product: soda, quantity: 2),
        CartItem(product: soda, quantity: 2),
      ]);
      expect(result.getLeft().toNullable(), isA<StockShortFailure>());
    });

    test('a product never delivered cannot be sold', () async {
      final result = await sales.saveSale(const [CartItem(product: juice)]);
      expect(
          result.getLeft().toNullable(),
          isA<StockShortFailure>()
              .having((f) => f.productName, 'name', 'Jus Rouiba'));
    });

    test('an exchange cannot take items that are not in stock', () async {
      session.login(karim);
      final ticket = (await sales.saveSale(const [CartItem(product: soda)]))
          .getOrElse((f) => fail(f.message));
      session.login(amine);
      final result = await sales.processReturn(
        saleId: ticket.id,
        lines: [
          ReturnLine(
              saleItemId: ticket.items.single.id,
              quantity: 1,
              backToStock: true),
        ],
        takes: const [CartItem(product: juice)],
      );
      expect(result.getLeft().toNullable(), isA<StockShortFailure>());
      expect(await db.select(db.returns).get(), isEmpty,
          reason: 'the whole exchange is cancelled');
      expect(await stockOf('soda'), 2);
    });
  });

  test('the owner can still sell without stock, with the alert', () async {
    final result =
        await sales.saveSale(const [CartItem(product: soda, quantity: 5)]);
    expect(result.isRight(), isTrue);
    expect(await stockOf('soda'), -2);

    final alerts = AlertRepository(db, settings);
    await alerts.refresh();
    final alert = (await alerts.getAlerts(userId: karim.id, isOwner: true))
        .singleWhere((a) => a.type == AlertType.lowStock);
    expect(alert.data['quantity'], -2, reason: '"Stock négatif"');
  });

  test('with the rule on, a worker can sell without stock', () async {
    await shops.updateShop(
        const Shop(name: 'Épicerie', workersSellWithoutStock: true));
    session.login(amine);
    final result =
        await sales.saveSale(const [CartItem(product: soda, quantity: 5)]);
    expect(result.isRight(), isTrue);
  });

  test('the rule is saved with the shop', () async {
    expect(
        (await shops.getShop())
            .getOrElse((f) => fail(f.message))
            .workersSellWithoutStock,
        isFalse,
        reason: 'off by default');
    await shops.updateShop(
        const Shop(name: 'Épicerie', workersSellWithoutStock: true));
    expect(
        (await shops.getShop())
            .getOrElse((f) => fail(f.message))
            .workersSellWithoutStock,
        isTrue);
  });

  testWidgets('worker checkout: the message and the delivery button',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    session.login(amine);
    sl.registerSingleton<SaleRepository>(sales);

    final productBloc = ProductBloc(
      getProductsUseCase: GetProductsUseCase(products),
      addProductUseCase: AddProductUseCase(products),
      updateProductUseCase: UpdateProductUseCase(products),
      archiveProductUseCase: ArchiveProductUseCase(products),
      stockRepository: stock,
    );
    final billing = BillingBloc(
      getProductByBarcodeUseCase: GetProductByBarcodeUseCase(products),
      saleRepository: sales,
      receiptPrinter: ReceiptPrinter(settings),
    );
    final shopBloc = ShopBloc(
        getShopUseCase: GetShopUseCase(shops),
        updateShopUseCase: UpdateShopUseCase(shops));
    addTearDown(() async {
      await billing.close();
      await productBloc.close();
      await shopBloc.close();
    });
    await tester.runAsync(() async {
      productBloc.add(LoadProducts());
      shopBloc.add(LoadShopEvent());
      billing.add(const AddProductToCartEvent(juice));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });

    final router = GoRouter(initialLocation: '/sell/checkout', routes: [
      GoRoute(
        path: '/sell',
        builder: (_, __) => const Scaffold(body: Text('Vendre')),
        routes: [
          GoRoute(path: 'checkout', builder: (_, __) => const CheckoutPage()),
        ],
      ),
      GoRoute(
          path: '/stock/delivery',
          builder: (_, s) => Scaffold(body: Text('Réception pour ${s.extra}'))),
    ]);
    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider.value(value: session),
        BlocProvider.value(value: productBloc),
        BlocProvider.value(value: billing),
        BlocProvider.value(value: shopBloc),
      ],
      child: MaterialApp.router(
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
      ),
    ));
    await tester.pumpAndSettle();

    // Before confirming, the red card already says it.
    expect(
        find.text("Stock insuffisant. Ajoutez d'abord la réception de stock."),
        findsOneWidget);

    await tester.tap(find.text('Valider sans imprimer'));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('Jus Rouiba : il reste 0 en stock.'),
        findsOneWidget);
    await tester.tap(find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Réception de stock')));
    await tester.pumpAndSettle();
    expect(find.text('Réception pour juice'), findsOneWidget);

    final saved = await tester.runAsync(() => db.select(db.sales).get());
    expect(saved, isEmpty);
  });
}
