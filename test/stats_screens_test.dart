import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/l10n/app_localizations.dart';
import 'package:billing_app/core/service_locator.dart';
import 'package:billing_app/core/session/session_cubit.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/billing/data/repositories/sale_repository_impl.dart';
import 'package:billing_app/features/billing/domain/entities/cart_item.dart';
import 'package:billing_app/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:billing_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/stats/data/stats_repository.dart';
import 'package:billing_app/features/stats/presentation/pages/stats_page.dart';
import 'package:billing_app/features/stats/presentation/stats_cubit.dart';
import 'package:billing_app/features/stats/presentation/widgets/stats_charts.dart';
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

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late SessionCubit session;

  const karim = AppUser(id: 'u-karim', name: 'Karim', role: UserRole.owner);
  const amine = AppUser(id: 'u-amine', name: 'Amine', role: UserRole.worker);
  const juice = Product(
      id: 'juice',
      name: 'Jus Rouiba 1L',
      barcode: '1',
      sellPrice: 18000,
      buyPrice: 14000);

  setUp(() async {
    await sl.reset();
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
    await StockRepositoryImpl(db, settings, session, StockLedger(db), products)
        .addDelivery(productId: 'juice', quantity: 10, buyPrice: 14000);
    final sales = SaleRepositoryImpl(db, settings, session, StockLedger(db));
    final mohamed = (await CustomerRepositoryImpl(db, settings, session)
            .saveCustomer(name: 'Mohamed'))
        .getOrElse((f) => fail(f.message));
    // Karim: 2 juices cash (360 DA). Amine: 1 juice on credit (180 DA).
    await sales.saveSale(const [CartItem(product: juice, quantity: 2)]);
    session.login(amine);
    await sales
        .saveSale(const [CartItem(product: juice)], customerId: mohamed.id);
    session.login(karim);

    sl
      ..registerSingleton<StatsRepository>(StatsRepository(db))
      ..registerSingleton<UserRepository>(UserRepositoryImpl(db, settings));
  });

  tearDown(() async {
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

  Future<void> show(WidgetTester tester,
      {String language = 'fr', double height = 4800}) async {
    tester.view.physicalSize = Size(1080, height);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(BlocProvider.value(
      value: session,
      child: MaterialApp(
        locale: Locale(language),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const StatsPage(),
      ),
    ));
    await settle(tester);
  }

  testWidgets('the owner sees the whole shop, profit and each person',
      (tester) async {
    await show(tester);

    expect(find.text('Statistiques'), findsOneWidget);
    // 360 + 180 DA.
    expect(find.textContaining('540,00 DA'), findsWidgets);
    // Bought 140, sold 180: 3 x 40 DA profit.
    expect(find.text('Bénéfice net'), findsOneWidget);
    expect(find.textContaining('120,00 DA'), findsWidgets);
    expect(find.text('Ventes par personne'), findsOneWidget);
    expect(find.text('Karim'), findsWidgets);
    expect(find.text('Amine'), findsWidgets);
    expect(find.byType(RevenueBarChart), findsOneWidget);
    expect(find.text('Mohamed'), findsOneWidget, reason: 'top debtor');
  });

  testWidgets('the owner can look at one person', (tester) async {
    await show(tester);
    await tester.tap(find.text('Tout le monde'));
    await settle(tester);
    await tester.tap(find.text('Amine').last);
    await settle(tester);

    expect(find.textContaining('180,00 DA'), findsWidgets);
    expect(find.text('Ventes par personne'), findsNothing);
  });

  testWidgets('a worker only sees their own figures, without profit',
      (tester) async {
    session.login(amine);
    await show(tester);

    expect(find.text('Vous voyez seulement vos propres chiffres.'),
        findsOneWidget);
    expect(find.text('Bénéfice net'), findsNothing);
    expect(find.text('Bénéfice'), findsNothing);
    expect(find.text('Tout le monde'), findsNothing, reason: 'no picker');
    expect(find.text('Ventes par personne'), findsNothing);
    expect(find.text('Total dû par les clients'), findsNothing);
    expect(find.textContaining('540,00 DA'), findsNothing);
    expect(find.textContaining('180,00 DA'), findsWidgets);
  });

  testWidgets('this week still includes today', (tester) async {
    await show(tester);
    await tester.tap(find.text('Cette semaine'));
    await settle(tester);
    // This week includes today, so the sales are still there.
    expect(find.textContaining('540,00 DA'), findsWidgets);
  });

  testWidgets('fits a phone screen in Arabic', (tester) async {
    await show(tester, language: 'ar', height: 2400);
    expect(find.text('الإحصائيات'), findsOneWidget);
    // Scroll to the bottom: any overflow would fail the test.
    await tester.fling(
        find.byType(ListView).first, const Offset(0, -3000), 2000);
    await settle(tester);
    expect(find.text('الأكثر مبيعاً'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('periods', () {
    // Tuesday 6 October 2026.
    final now = DateTime(2026, 10, 6, 15);

    test('today, this week from Saturday, this month', () {
      expect(StatsCubit.rangeOf(StatsPeriod.today, now),
          (DateTime(2026, 10, 6), DateTime(2026, 10, 7)));
      expect(StatsCubit.rangeOf(StatsPeriod.week, now),
          (DateTime(2026, 10, 3), DateTime(2026, 10, 7)));
      expect(StatsCubit.rangeOf(StatsPeriod.month, now),
          (DateTime(2026, 10, 1), DateTime(2026, 10, 7)));
    });

    test('short amounts on the chart axis', () {
      expect(compactDA(125000000), '1,3M');
      expect(compactDA(1250000), '13k');
      expect(compactDA(250000), '2,5k');
      expect(compactDA(50000), '500');
    });
  });
}
