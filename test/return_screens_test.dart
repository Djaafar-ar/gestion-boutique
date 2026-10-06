import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/l10n/app_localizations.dart';
import 'package:billing_app/core/service_locator.dart';
import 'package:billing_app/core/session/session_cubit.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/auth/data/login_guard.dart';
import 'package:billing_app/features/auth/data/login_service.dart';
import 'package:billing_app/features/auth/data/owner_approval.dart';
import 'package:billing_app/features/billing/data/repositories/sale_repository_impl.dart';
import 'package:billing_app/features/billing/domain/entities/cart_item.dart';
import 'package:billing_app/features/billing/domain/repositories/sale_repository.dart';
import 'package:billing_app/features/billing/presentation/pages/return_page.dart';
import 'package:billing_app/features/billing/presentation/pages/sale_detail_page.dart';
import 'package:billing_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/usecases/product_usecases.dart';
import 'package:billing_app/features/product/presentation/bloc/product_bloc.dart';
import 'package:billing_app/features/stock/data/repositories/stock_repository_impl.dart';
import 'package:billing_app/features/stock/data/stock_ledger.dart';
import 'package:billing_app/features/users/data/repositories/user_repository_impl.dart';
import 'package:billing_app/features/users/domain/entities/app_user.dart';
import 'package:billing_app/features/users/domain/repositories/user_repository.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late SessionCubit session;
  late SaleRepository sales;
  late StockRepositoryImpl stock;
  late ProductBloc productBloc;
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
    await sl.reset();
    db = AppDatabase(NativeDatabase.memory());
    final settings = SettingsStore(db);
    await settings.load();
    final users = UserRepositoryImpl(db, settings);
    karim = (await users.createOwner(name: 'Karim', phone: '', pin: '1234'))
        .getOrElse((f) => fail(f.message))
        .owner;
    amine = (await users.addWorker(
            actorId: karim.id, name: 'Amine', phone: '', pin: '5678'))
        .getOrElse((f) => fail(f.message));
    session = SessionCubit(hasOwner: true)..login(karim);
    final products = ProductRepositoryImpl(db, settings, session);
    await products.addProduct(soda);
    await products.addProduct(juice);
    stock =
        StockRepositoryImpl(db, settings, session, StockLedger(db), products);
    await stock.addDelivery(productId: 'soda', quantity: 10, buyPrice: 4000);
    await stock.addDelivery(productId: 'juice', quantity: 10, buyPrice: 14000);
    sales = SaleRepositoryImpl(db, settings, session, StockLedger(db),
        ownerApproval: ownerApprovalWith(users));
    final guard = LoginGuard(settings);
    sl
      ..registerSingleton<SaleRepository>(sales)
      ..registerSingleton<UserRepository>(users)
      ..registerSingleton(guard)
      ..registerSingleton(LoginService(users, guard));
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
    await tester.runAsync(() async => productBloc.add(LoadProducts()));

    final router = GoRouter(initialLocation: location, routes: [
      GoRoute(
        path: '/sell',
        builder: (_, __) => const Scaffold(body: Text('Vendre')),
        routes: [
          GoRoute(
              path: 'return',
              builder: (_, s) => ReturnPage(
                  exchange: s.uri.queryParameters['exchange'] == '1')),
          GoRoute(
            path: 'history/:saleId',
            builder: (_, s) =>
                SaleDetailPage(saleId: s.pathParameters['saleId']!),
            routes: [
              GoRoute(
                  path: 'exchange',
                  builder: (_, s) => ReturnPage(
                      saleId: s.pathParameters['saleId']!, exchange: true)),
            ],
          ),
        ],
      ),
    ]);
    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider.value(value: session),
        BlocProvider.value(value: productBloc),
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

  Future<int> stockOf(WidgetTester tester, String id) async =>
      (await tester.runAsync(() => stock.getBatches(id)))!
          .getOrElse((f) => fail(f.message))
          .stock;

  Future<void> pick(WidgetTester tester, String button, String product) async {
    await tester.tap(find.text(button));
    await settle(tester);
    await tester.tap(find.text(product).last);
    await settle(tester);
  }

  testWidgets('owner: return without a receipt, at today\'s price',
      (tester) async {
    await show(tester, '/sell/return');
    expect(find.text('Retour sans ticket'), findsOneWidget);

    await pick(tester, 'Ajouter un produit rendu', 'Hamoud 33cl');
    expect(find.textContaining('À rendre au client'), findsOneWidget);
    expect(find.textContaining('60,00 DA'), findsWidgets);

    await tester.tap(find.text('Valider le retour'));
    await settle(tester);
    expect(await stockOf(tester, 'soda'), 11);
  });

  testWidgets('worker: the owner types their PIN to allow it', (tester) async {
    session.login(amine);
    await show(tester, '/sell/return');
    await pick(tester, 'Ajouter un produit rendu', 'Hamoud 33cl');

    await tester.tap(find.text('Valider le retour'));
    await settle(tester);
    expect(find.text('Accord du patron'), findsOneWidget);
    expect(find.textContaining('accepté par Karim'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).last, '0000');
    await tester.tap(find.text('Continuer'));
    await settle(tester);
    expect(find.textContaining('incorrect'), findsOneWidget);
    expect(await stockOf(tester, 'soda'), 10, reason: 'nothing saved yet');

    await tester.enterText(find.byType(TextFormField).last, '1234');
    await tester.tap(find.text('Continuer'));
    await settle(tester);

    expect(find.text('Accord du patron'), findsNothing);
    expect(await stockOf(tester, 'soda'), 11);
    final saved = (await tester.runAsync(() => db.select(db.returns).get()))!;
    expect(saved.single.approvedBy, karim.id);
  });

  testWidgets('exchange: the app says what the customer pays', (tester) async {
    final ticket = (await tester.runAsync(() =>
            sales.saveSale(const [CartItem(product: soda, quantity: 2)])))!
        .getOrElse((f) => fail(f.message));
    await show(tester, '/sell/history/${ticket.id}/exchange');

    expect(find.text('Échange du ticket n°1'), findsOneWidget);
    // One soda comes back...
    await tester.tap(find.byIcon(Icons.add_circle_outline).first);
    await tester.pump();
    // ...and the customer takes a juice instead.
    await pick(tester, 'Ajouter un article pris', 'Jus Rouiba 1L');
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await settle(tester);
    expect(find.textContaining('Le client paie'), findsOneWidget);
    expect(find.textContaining('120,00 DA'), findsWidgets);

    await tester.tap(find.text("Valider l'échange"));
    await settle(tester);

    // The new ticket opens, showing the credit from the soda.
    expect(find.text('Vente n°2'), findsOneWidget);
    expect(find.text('Avoir (articles rendus)'), findsOneWidget);
    expect(await stockOf(tester, 'soda'), 9);
    expect(await stockOf(tester, 'juice'), 9);
  });

  testWidgets('exchange without anything taken is refused', (tester) async {
    await show(tester, '/sell/return?exchange=1');
    expect(find.text('Échange sans ticket'), findsOneWidget);
    await pick(tester, 'Ajouter un produit rendu', 'Hamoud 33cl');
    await tester.tap(find.text("Valider l'échange"));
    await settle(tester);
    expect(
        find.text('Ajoutez les articles pris par le client.'), findsOneWidget);
  });
}

