import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/l10n/app_localizations.dart';
import 'package:billing_app/core/service_locator.dart';
import 'package:billing_app/core/session/session_cubit.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/repositories/product_repository.dart';
import 'package:billing_app/features/product/domain/usecases/product_usecases.dart';
import 'package:billing_app/features/product/presentation/bloc/product_bloc.dart';
import 'package:billing_app/features/product/presentation/pages/product_list_page.dart';
import 'package:billing_app/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:billing_app/features/shop/domain/usecases/shop_usecases.dart';
import 'package:billing_app/features/shop/presentation/bloc/shop_bloc.dart';
import 'package:billing_app/features/stock/data/repositories/stock_repository_impl.dart';
import 'package:billing_app/features/stock/data/stock_ledger.dart';
import 'package:billing_app/features/stock/domain/repositories/stock_repository.dart';
import 'package:billing_app/features/stock/presentation/pages/add_delivery_page.dart';
import 'package:billing_app/features/stock/presentation/pages/product_detail_page.dart';
import 'package:billing_app/features/stock/presentation/pages/record_loss_page.dart';
import 'package:billing_app/features/users/domain/entities/app_user.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// Screen tests for the Stock tab with a real (in-memory) database.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late SettingsStore settings;
  late SessionCubit session;
  late StockRepository stock;
  late ProductBloc productBloc;

  const soda =
      Product(id: 'soda', name: 'Hamoud 33cl', barcode: '613', sellPrice: 6000);

  setUp(() async {
    await sl.reset();
    db = AppDatabase(NativeDatabase.memory());
    settings = SettingsStore(db);
    await settings.load();
    session = SessionCubit(hasOwner: true)
      ..login(const AppUser(id: 'o', name: 'Karim', role: UserRole.owner));
    final products = ProductRepositoryImpl(db, settings, session);
    stock =
        StockRepositoryImpl(db, settings, session, StockLedger(db), products);
    sl
      ..registerSingleton<ProductRepository>(products)
      ..registerSingleton<StockRepository>(stock);
    await products.addProduct(soda);
    productBloc = ProductBloc(
      getProductsUseCase: GetProductsUseCase(products),
      addProductUseCase: AddProductUseCase(products),
      updateProductUseCase: UpdateProductUseCase(products),
      archiveProductUseCase: ArchiveProductUseCase(products),
      stockRepository: stock,
    );
  });

  tearDown(() async {
    await productBloc.close();
    await session.close();
    await db.close();
    await sl.reset();
  });

  /// Lets real database work finish, then redraws.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester
          .runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();
    }
  }

  Future<void> show(WidgetTester tester, String location) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    final shopRepo = ShopRepositoryImpl(db, settings);
    final router = GoRouter(initialLocation: location, routes: [
      GoRoute(path: '/stock', builder: (_, __) => const ProductListPage()),
      GoRoute(
          path: '/stock/product/:id',
          builder: (_, s) =>
              ProductDetailPage(productId: s.pathParameters['id']!)),
      GoRoute(
          path: '/stock/delivery',
          builder: (_, s) => AddDeliveryPage(productId: s.extra as String?)),
      GoRoute(
          path: '/stock/loss',
          builder: (_, s) => RecordLossPage(productId: s.extra as String?)),
    ]);
    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider.value(value: session),
        BlocProvider.value(value: productBloc),
        BlocProvider(
            create: (_) => ShopBloc(
                getShopUseCase: GetShopUseCase(shopRepo),
                updateShopUseCase: UpdateShopUseCase(shopRepo))),
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
    await settle(tester);
  }

  testWidgets('the Stock list shows each product\'s quantity', (tester) async {
    await tester.runAsync(() async {
      await stock.addDelivery(productId: 'soda', quantity: 12, buyPrice: 4000);
      productBloc.add(LoadProducts());
    });
    await show(tester, '/stock');

    expect(find.text('Hamoud 33cl'), findsOneWidget);
    expect(find.text('Stock : 12'), findsOneWidget);
  });

  testWidgets('a product never delivered shows "Rupture"', (tester) async {
    await tester.runAsync(() async => productBloc.add(LoadProducts()));
    await show(tester, '/stock');
    expect(find.text('Rupture'), findsOneWidget);
  });

  testWidgets('receiving stock with a quantity adds it', (tester) async {
    await tester.runAsync(() async => productBloc.add(LoadProducts()));
    await show(tester, '/stock');
    // Open the delivery page for the soda directly.
    GoRouter.of(tester.element(find.byType(ProductListPage)))
        .push('/stock/delivery', extra: 'soda');
    await settle(tester);

    expect(find.text('Hamoud 33cl'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '24');
    await tester.tap(find.text('Ajouter au stock'));
    await settle(tester);

    final left = await tester.runAsync(() => stock.getBatches('soda'));
    expect(left!.getOrElse((f) => fail(f.message)).stock, 24);
    expect(find.text('Stock : 24'), findsOneWidget,
        reason: 'back on the list, refreshed');
  });

  testWidgets('a quantity is required', (tester) async {
    await tester.runAsync(() async => productBloc.add(LoadProducts()));
    await show(tester, '/stock');
    GoRouter.of(tester.element(find.byType(ProductListPage)))
        .push('/stock/delivery', extra: 'soda');
    await settle(tester);

    await tester.tap(find.text('Ajouter au stock'));
    await settle(tester);

    expect(find.text('Entrez une quantité (au moins 1)'), findsOneWidget);
  });

  testWidgets('the product page lists batches with their expiry',
      (tester) async {
    await tester.runAsync(() async {
      await stock.addDelivery(
          productId: 'soda',
          quantity: 10,
          buyPrice: 4000,
          expiryDate: DateTime(2030, 1, 15));
      productBloc.add(LoadProducts());
    });
    await show(tester, '/stock/product/soda');

    expect(find.text('10 sur 10'), findsOneWidget);
    expect(find.textContaining('15/01/2030'), findsOneWidget);
    expect(find.text('Réception de stock'), findsOneWidget);
    expect(find.text('Déclarer une perte'), findsOneWidget);
  });

  testWidgets('recording a loss shows the money lost', (tester) async {
    await tester.runAsync(() async {
      await stock.addDelivery(productId: 'soda', quantity: 10, buyPrice: 4000);
      productBloc.add(LoadProducts());
    });
    await show(tester, '/stock');
    GoRouter.of(tester.element(find.byType(ProductListPage)))
        .push('/stock/loss', extra: 'soda');
    await settle(tester);

    await tester.enterText(find.byType(TextFormField).first, '3');
    await tester.pump();
    expect(find.textContaining('120,00 DA'), findsOneWidget); // 3 x 40 DA

    await tester.tap(find.text('Enregistrer la perte'));
    await settle(tester);
    final left = await tester.runAsync(() => stock.getBatches('soda'));
    expect(left!.getOrElse((f) => fail(f.message)).stock, 7);
  });
}
