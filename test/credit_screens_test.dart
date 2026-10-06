import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/l10n/app_localizations.dart';
import 'package:billing_app/core/service_locator.dart';
import 'package:billing_app/core/session/session_cubit.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/billing/data/receipt_printer.dart';
import 'package:billing_app/features/billing/data/repositories/sale_repository_impl.dart';
import 'package:billing_app/features/billing/domain/entities/cart_item.dart';
import 'package:billing_app/features/billing/domain/entities/sale.dart';
import 'package:billing_app/features/billing/domain/repositories/sale_repository.dart';
import 'package:billing_app/features/billing/presentation/bloc/billing_bloc.dart';
import 'package:billing_app/features/billing/presentation/pages/checkout_page.dart';
import 'package:billing_app/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:billing_app/features/customers/domain/entities/customer.dart';
import 'package:billing_app/features/customers/domain/repositories/customer_repository.dart';
import 'package:billing_app/features/customers/presentation/pages/customer_detail_page.dart';
import 'package:billing_app/features/customers/presentation/pages/customer_form_page.dart';
import 'package:billing_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/repositories/product_repository.dart';
import 'package:billing_app/features/product/domain/usecases/product_usecases.dart';
import 'package:billing_app/features/product/presentation/bloc/product_bloc.dart';
import 'package:billing_app/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:billing_app/features/shop/domain/usecases/shop_usecases.dart';
import 'package:billing_app/features/shop/presentation/bloc/shop_bloc.dart';
import 'package:billing_app/features/stock/data/repositories/stock_repository_impl.dart';
import 'package:billing_app/features/stock/data/stock_ledger.dart';
import 'package:billing_app/features/stock/domain/repositories/stock_repository.dart';
import 'package:billing_app/features/stock/presentation/pages/add_delivery_page.dart';
import 'package:billing_app/features/suppliers/data/repositories/supplier_repository_impl.dart';
import 'package:billing_app/features/suppliers/domain/entities/supplier.dart';
import 'package:billing_app/features/suppliers/domain/repositories/supplier_repository.dart';
import 'package:billing_app/features/suppliers/presentation/pages/pending_payments_page.dart';
import 'package:billing_app/features/suppliers/presentation/pages/supplier_detail_page.dart';
import 'package:billing_app/features/suppliers/presentation/pages/supplier_form_page.dart';
import 'package:billing_app/features/users/domain/entities/app_user.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// Screen tests for Phase 4: credit at checkout, the carnet, suppliers
// and payments to validate, with a real (in-memory) database.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late SettingsStore settings;
  late SessionCubit session;
  late SaleRepository sales;
  late CustomerRepository customers;
  late SupplierRepository suppliers;
  late StockRepository stock;
  late ProductBloc productBloc;
  late BillingBloc billingBloc;

  const karim = AppUser(id: 'u-karim', name: 'Karim', role: UserRole.owner);
  const amine = AppUser(id: 'u-amine', name: 'Amine', role: UserRole.worker);
  // 650 DA.
  const milk =
      Product(id: 'milk', name: 'Lait Candia', barcode: '1', sellPrice: 65000);

  setUp(() async {
    await sl.reset();
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
    final products = ProductRepositoryImpl(db, settings, session);
    await products.addProduct(milk);
    stock =
        StockRepositoryImpl(db, settings, session, StockLedger(db), products);
    sales = SaleRepositoryImpl(db, settings, session, StockLedger(db));
    customers = CustomerRepositoryImpl(db, settings, session);
    suppliers = SupplierRepositoryImpl(db, settings, session);
    sl
      ..registerSingleton<ProductRepository>(products)
      ..registerSingleton<StockRepository>(stock)
      ..registerSingleton<SaleRepository>(sales)
      ..registerSingleton<CustomerRepository>(customers)
      ..registerSingleton<SupplierRepository>(suppliers);
    productBloc = ProductBloc(
      getProductsUseCase: GetProductsUseCase(products),
      addProductUseCase: AddProductUseCase(products),
      updateProductUseCase: UpdateProductUseCase(products),
      archiveProductUseCase: ArchiveProductUseCase(products),
      stockRepository: stock,
    );
    billingBloc = BillingBloc(
      getProductByBarcodeUseCase: GetProductByBarcodeUseCase(products),
      saleRepository: sales,
      receiptPrinter: ReceiptPrinter(settings),
    );
  });

  tearDown(() async {
    await billingBloc.close();
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
      GoRoute(
        path: '/sell',
        builder: (_, __) => const Scaffold(body: Text('Vendre')),
        routes: [
          GoRoute(path: 'checkout', builder: (_, __) => const CheckoutPage()),
        ],
      ),
      GoRoute(
          path: '/stock/delivery',
          builder: (_, s) => AddDeliveryPage(productId: s.extra as String?)),
      GoRoute(
        path: '/customers/new',
        builder: (_, __) => const CustomerFormPage(),
      ),
      GoRoute(
        path: '/customers/:id',
        builder: (_, s) =>
            CustomerDetailPage(customerId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/suppliers/new',
        builder: (_, __) => const SupplierFormPage(),
      ),
      GoRoute(
        path: '/suppliers/:id',
        builder: (_, s) =>
            SupplierDetailPage(supplierId: s.pathParameters['id']!),
      ),
      GoRoute(
          path: '/payments', builder: (_, __) => const PendingPaymentsPage()),
    ]);
    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider.value(value: session),
        BlocProvider.value(value: productBloc),
        BlocProvider.value(value: billingBloc),
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

  Future<Customer> addCustomer(WidgetTester tester, {int? limit}) async {
    final result = await tester.runAsync(() => customers.saveCustomer(
        name: 'Mohamed', phone: '0555', creditLimit: limit));
    return result!.getOrElse((f) => fail(f.message));
  }

  Future<int> debtOf(WidgetTester tester, String id) async =>
      (await tester.runAsync(() => customers.getCustomer(id)))!
          .getOrElse((f) => fail(f.message))
          .debt;

  Future<List<Sale>> savedSales(WidgetTester tester) async =>
      (await tester.runAsync(() => sales.getSales()))!
          .getOrElse((f) => fail(f.message));

  group('checkout on credit', () {
    testWidgets('pick a customer, pay part now, the rest is owed',
        (tester) async {
      final mohamed = await addCustomer(tester);
      billingBloc.add(const AddProductToCartEvent(milk));
      billingBloc.add(const UpdateQuantityEvent('milk', 2)); // 1 300 DA
      await show(tester, '/sell/checkout');

      await tester.tap(find.text('Crédit'));
      await settle(tester);
      await tester.tap(find.text('Choisir un client'));
      await settle(tester);
      await tester.tap(find.text('Mohamed'));
      await settle(tester);

      await tester.enterText(
          find.widgetWithText(TextField, 'Payé maintenant'), '300');
      await settle(tester);
      expect(find.textContaining('1 000,00 DA'), findsWidgets,
          reason: 'left on credit and the new debt');

      await tester.tap(find.text('Valider sans imprimer'));
      await settle(tester);

      expect(find.textContaining('sur le compte de Mohamed'), findsOneWidget);
      expect(find.text('Vendre'), findsOneWidget, reason: 'back to selling');
      expect(await debtOf(tester, mohamed.id), 100000);
      final sale = (await savedSales(tester)).single;
      expect((sale.customerName, sale.paidNow), ('Mohamed', 30000));
    });

    testWidgets('credit needs a customer', (tester) async {
      billingBloc.add(const AddProductToCartEvent(milk));
      await show(tester, '/sell/checkout');

      await tester.tap(find.text('Crédit'));
      await settle(tester);
      await tester.tap(find.text('Valider sans imprimer'));
      await settle(tester);

      expect(find.text('Choisissez un client pour une vente à crédit.'),
          findsOneWidget);
      expect(await savedSales(tester), isEmpty);
    });

    testWidgets('a worker cannot go over the credit limit', (tester) async {
      final mohamed = await addCustomer(tester, limit: 100000); // 1 000 DA
      session.login(amine);
      billingBloc
        ..add(const AddProductToCartEvent(milk))
        ..add(const UpdateQuantityEvent('milk', 2))
        ..add(const SetCreditModeEvent(true))
        ..add(SetCustomerEvent(mohamed));
      await show(tester, '/sell/checkout');

      expect(
          find.textContaining('Dépasse la limite de crédit'), findsOneWidget);
      await tester.tap(find.text('Valider sans imprimer'));
      await settle(tester);

      expect(find.textContaining('Demandez au patron'), findsOneWidget);
      expect(await savedSales(tester), isEmpty);
    });

    testWidgets('the owner is asked and may allow it', (tester) async {
      final mohamed = await addCustomer(tester, limit: 100000);
      billingBloc
        ..add(const AddProductToCartEvent(milk))
        ..add(const UpdateQuantityEvent('milk', 2))
        ..add(const SetCreditModeEvent(true))
        ..add(SetCustomerEvent(mohamed));
      await show(tester, '/sell/checkout');

      await tester.tap(find.text('Valider sans imprimer'));
      await settle(tester);
      expect(find.text('Limite de crédit dépassée'), findsOneWidget);
      await tester.tap(find.text('Autoriser'));
      await settle(tester);

      expect(await debtOf(tester, mohamed.id), 130000);
    });

    testWidgets('a cash sale stays a cash sale', (tester) async {
      billingBloc.add(const AddProductToCartEvent(milk));
      await show(tester, '/sell/checkout');
      await tester.tap(find.text('Valider sans imprimer'));
      await settle(tester);

      final sale = (await savedSales(tester)).single;
      expect(sale.isCredit, isFalse);
      expect(sale.paidNow, sale.total);
    });
  });

  group('customer page', () {
    testWidgets('receiving a payment lowers the debt', (tester) async {
      final mohamed = await addCustomer(tester);
      await tester.runAsync(() => sales.saveSale(
          [const CartItem(product: milk, quantity: 2)],
          customerId: mohamed.id));
      await show(tester, '/customers/${mohamed.id}');

      expect(find.textContaining('1 300,00 DA'), findsWidgets);
      expect(find.text('Vente à crédit n°1'), findsOneWidget);

      await tester.tap(find.text('Encaisser un paiement'));
      await settle(tester);
      // More than the debt is refused in the dialog.
      await tester.enterText(find.widgetWithText(TextField, 'Montant'), '2000');
      await tester.tap(find.text('Enregistrer'));
      await tester.pump();
      expect(find.textContaining('Plus que la dette'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Montant'), '500');
      await tester.tap(find.text('Enregistrer'));
      await settle(tester);

      expect(await debtOf(tester, mohamed.id), 80000);
      expect(find.text('Paiement reçu'), findsOneWidget);
      expect(find.textContaining('par Karim'), findsWidgets);
    });

    testWidgets('a worker cannot set the credit limit', (tester) async {
      session.login(amine);
      await show(tester, '/customers/new');
      // Name, phone, then the credit limit.
      final limit =
          tester.widget<TextFormField>(find.byType(TextFormField).at(2));
      expect(limit.enabled, isFalse);
      expect(find.text('Seul le patron fixe la limite de crédit.'),
          findsOneWidget);
    });
  });

  group('suppliers', () {
    Future<Supplier> addSupplier(WidgetTester tester) async =>
        (await tester.runAsync(() => suppliers.saveSupplier(name: 'Hamoud')))!
            .getOrElse((f) => fail(f.message));

    testWidgets("a worker's payment waits for the owner", (tester) async {
      final hamoud = await addSupplier(tester);
      session.login(amine);
      await show(tester, '/suppliers/${hamoud.id}');

      await tester.tap(find.text('Enregistrer un paiement'));
      await settle(tester);
      expect(find.textContaining('Le patron devra valider'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, 'Montant'), '1500');
      await tester.tap(find.text('Enregistrer'));
      await settle(tester);

      expect(find.text('Paiement envoyé au patron pour validation'),
          findsOneWidget);
      expect(find.text('En attente'), findsWidgets);
      expect(await tester.runAsync(suppliers.pendingCount), 1);
    });

    testWidgets('the owner validates it from the list', (tester) async {
      final hamoud = await addSupplier(tester);
      session.login(amine);
      await tester.runAsync(
          () => suppliers.recordPayment(supplierId: hamoud.id, amount: 150000));
      session.login(karim);
      await show(tester, '/payments');

      expect(find.text('Hamoud'), findsOneWidget);
      expect(find.textContaining('Payé par Amine'), findsOneWidget);
      await tester.tap(find.text('Valider'));
      await settle(tester);

      expect(find.text('Aucun paiement en attente.'), findsOneWidget);
      final loaded =
          (await tester.runAsync(() => suppliers.getSupplier(hamoud.id)))!
              .getOrElse((f) => fail(f.message));
      expect(loaded.paid, 150000);
    });

    testWidgets('a delivery can name its supplier', (tester) async {
      final hamoud = await addSupplier(tester);
      // The delivery page finds the product in the product list.
      await tester.runAsync(() async => productBloc.add(LoadProducts()));
      await show(tester, '/sell');
      GoRouter.of(tester.element(find.text('Vendre')))
          .push('/stock/delivery', extra: 'milk');
      await settle(tester);

      await tester.tap(find.text('Aucun fournisseur'));
      await settle(tester);
      await tester.tap(find.text('Hamoud'));
      await settle(tester);
      expect(find.text('Hamoud'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, '10');
      await tester.enterText(find.byType(TextFormField).at(1), '500');
      await tester.tap(find.text('Ajouter au stock'));
      await settle(tester);

      final loaded =
          (await tester.runAsync(() => suppliers.getSupplier(hamoud.id)))!
              .getOrElse((f) => fail(f.message));
      expect(loaded.delivered, 500000); // 10 x 500 DA
    });
  });
}
