import 'dart:async';

import 'package:billing_app/config/routes/app_shell.dart';
import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/l10n/app_localizations.dart';
import 'package:billing_app/core/service_locator.dart';
import 'package:billing_app/core/session/session_cubit.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/alerts/data/alert_repository.dart';
import 'package:billing_app/features/alerts/data/phone_notifier.dart';
import 'package:billing_app/features/alerts/domain/alert.dart';
import 'package:billing_app/features/alerts/presentation/alerts_cubit.dart';
import 'package:billing_app/features/alerts/presentation/pages/alerts_page.dart';
import 'package:billing_app/features/alerts/presentation/pages/notification_settings_page.dart';
import 'package:billing_app/features/billing/data/repositories/sale_repository_impl.dart';
import 'package:billing_app/features/billing/domain/entities/cart_item.dart';
import 'package:billing_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/stock/data/repositories/stock_repository_impl.dart';
import 'package:billing_app/features/stock/data/stock_ledger.dart';
import 'package:billing_app/features/suppliers/data/repositories/supplier_repository_impl.dart';
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

/// Records what would ring on the phone.
class FakeNotifier implements PhoneNotifier {
  final shown = <({String key, String title, String body, String payload})>[];
  final cancelled = <String>[];
  List<Reminder> scheduled = [];
  final _taps = StreamController<String>.broadcast();
  String? _pending;

  void tap(String payload) {
    _pending = payload;
    _taps.add(payload);
  }

  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<bool> isAllowed() async => true;
  @override
  Future<void> openSettings() async {}
  @override
  Future<void> show(
      {required String key,
      required String title,
      required String body,
      required String payload,
      required String channelName}) async {
    shown.add((key: key, title: title, body: body, payload: payload));
  }

  @override
  Future<void> cancel(String key) async => cancelled.add(key);
  @override
  Future<void> schedule(List<Reminder> reminders,
          {required String channelName}) async =>
      scheduled = reminders;
  @override
  Stream<String> get taps => _taps.stream;
  @override
  String? takePendingTap() {
    final payload = _pending;
    _pending = null;
    return payload;
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late SettingsStore settings;
  late SessionCubit session;
  late FakeNotifier notifier;
  late AlertsCubit cubit;
  late StockRepositoryImpl stock;
  late SaleRepositoryImpl sales;
  late SupplierRepositoryImpl suppliers;

  const karim = AppUser(id: 'u-karim', name: 'Karim', role: UserRole.owner);
  const amine = AppUser(id: 'u-amine', name: 'Amine', role: UserRole.worker);
  const soda =
      Product(id: 'soda', name: 'Hamoud 33cl', barcode: '1', sellPrice: 6000);

  setUp(() async {
    await sl.reset();
    db = AppDatabase(NativeDatabase.memory());
    settings = SettingsStore(db);
    await settings.load();
    // Alerts were switched on long ago.
    await settings.set('alerts_since', DateTime(2020).toIso8601String());
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
    await products.addProduct(soda);
    stock =
        StockRepositoryImpl(db, settings, session, StockLedger(db), products);
    sales = SaleRepositoryImpl(db, settings, session, StockLedger(db));
    suppliers = SupplierRepositoryImpl(db, settings, session);
    notifier = FakeNotifier();
    cubit = AlertsCubit(
      db: db,
      repository: AlertRepository(db, settings),
      notifier: notifier,
      settings: settings,
      session: session,
      locale: () => const Locale('fr'),
    );
    sl
      ..registerSingleton<SettingsStore>(settings)
      ..registerSingleton<PhoneNotifier>(notifier)
      ..registerSingleton<UserRepository>(UserRepositoryImpl(db, settings));
  });

  tearDown(() async {
    await cubit.close();
    await session.close();
    await db.close();
    await sl.reset();
  });

  /// A worker pays a supplier (the owner must validate it).
  Future<void> workerPays() async {
    final hamoud = (await suppliers.saveSupplier(name: 'Hamoud'))
        .getOrElse((f) => fail(f.message));
    final before = session.state.user!;
    session.login(amine);
    await suppliers.recordPayment(supplierId: hamoud.id, amount: 150000);
    session.login(before);
  }

  /// Sells one soda that was never delivered: negative stock.
  Future<void> sellWithoutStock() async =>
      sales.saveSale(const [CartItem(product: soda)]);

  group('phone notifications', () {
    test('a payment to validate rings on the owner phone', () async {
      await workerPays();
      await cubit.check();

      final shown = notifier.shown.single;
      expect(shown.title, 'Paiement à valider');
      expect(shown.body, contains('Amine a payé'));
      expect(shown.body, contains('Hamoud'));
      expect(shown.payload, endsWith('|/payments'), reason: 'opens the list');
      expect(cubit.state.unread, 1);
    });

    test('only once, not at every check', () async {
      await workerPays();
      await cubit.check();
      await cubit.check();
      expect(notifier.shown, hasLength(1));
    });

    test('a worker phone never rings for owner alerts', () async {
      session.login(amine);
      await workerPays();
      await sellWithoutStock();
      await cubit.check();

      expect(
          notifier.shown.map((s) => s.title), ['Stock négatif : Hamoud 33cl']);
      expect(cubit.state.alerts.map((a) => a.type), [AlertType.lowStock]);
    });

    test('a type switched off does not ring but stays in the tab', () async {
      await settings.set(AlertType.pendingPayment.settingsKey, 'false');
      await workerPays();
      await cubit.check();

      expect(notifier.shown, isEmpty);
      expect(cubit.state.unread, 1);
    });

    test('many new alerts at once give one summary', () async {
      final products = ProductRepositoryImpl(db, settings, session);
      for (var i = 0; i < 5; i++) {
        final p = Product(id: 'p$i', name: 'P$i', barcode: 'b$i', sellPrice: 1);
        await products.addProduct(p);
        await sales.saveSale([CartItem(product: p)]);
      }
      await cubit.check();
      expect(notifier.shown.single.title, '5 nouvelles alertes');
      expect(notifier.shown.single.payload, '|/alerts');
    });

    test('expiry reminders are planned at 9:00, also for later days', () async {
      await stock.addDelivery(
          productId: 'soda',
          quantity: 10,
          buyPrice: 4000,
          expiryDate: DateTime(2026, 10, 20));
      await cubit.check(now: DateTime(2026, 10, 6, 12));

      expect(notifier.scheduled.map((r) => (r.at, r.title)), [
        (DateTime(2026, 10, 17, 9), 'Bientôt périmé : Hamoud 33cl'),
        (DateTime(2026, 10, 21, 9), 'Périmé : Hamoud 33cl'),
      ]);
    });

    test('reading an alert removes its notification', () async {
      await workerPays();
      await cubit.check();
      final alert = cubit.state.alerts.single;

      await cubit.markRead(alert.id);
      expect(notifier.cancelled, [alert.id]);
      expect(cubit.state.unread, 0);
    });
  });

  // ---------------------------------------------------------------- screens

  Future<void> pumpApp(WidgetTester tester, {required String location}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    Widget page(String name) =>
        Scaffold(appBar: AppBar(), body: Center(child: Text(name)));
    final router = GoRouter(initialLocation: location, routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => AppShell(shell: shell),
        branches: [
          for (final (path, name) in [
            ('/sell', 'Vendre'),
            ('/stock', 'Stock'),
            ('/stats', 'Stats'),
          ])
            StatefulShellBranch(routes: [
              GoRoute(path: path, builder: (_, __) => page(name)),
            ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/alerts', builder: (_, __) => const AlertsPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/more', builder: (_, __) => page('Plus')),
          ]),
        ],
      ),
      GoRoute(
          path: '/payments', builder: (_, __) => page('Paiements à valider')),
      GoRoute(
          path: '/stock/product/:id',
          builder: (_, s) => page('Produit ${s.pathParameters['id']}')),
      GoRoute(
          path: '/notifications',
          builder: (_, __) => const NotificationSettingsPage()),
    ]);
    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider.value(value: session),
        BlocProvider.value(value: cubit),
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

  testWidgets('the Alertes tab shows a badge with the number', (tester) async {
    await tester.runAsync(() async {
      await workerPays();
      await sellWithoutStock();
      await cubit.check();
    });
    await pumpApp(tester, location: '/sell');

    final badge = tester.widget<Badge>(find.byType(Badge).first);
    expect(badge.isLabelVisible, isTrue);
    expect(find.descendant(of: find.byType(Badge), matching: find.text('2')),
        findsWidgets);
  });

  testWidgets('tapping the notification opens "Paiements à valider"',
      (tester) async {
    await tester.runAsync(() async {
      await workerPays();
      await cubit.check();
    });
    await pumpApp(tester, location: '/sell');

    notifier.tap(notifier.shown.single.payload);
    await settle(tester);

    expect(find.text('Paiements à valider'), findsOneWidget);
    await tester.runAsync(() async {});
    expect(cubit.state.unread, 0, reason: 'opened = read');
  });

  testWidgets('a notification tapped before login opens after login',
      (tester) async {
    await tester.runAsync(() async {
      await workerPays();
      await cubit.check();
    });
    // The tap arrives while nobody is logged in (no shell yet).
    notifier.tap(notifier.shown.single.payload);
    await pumpApp(tester, location: '/sell');

    expect(find.text('Paiements à valider'), findsOneWidget);
  });

  testWidgets('the list: tap opens the page, mark all as read', (tester) async {
    await tester.runAsync(() async {
      await workerPays();
      await sellWithoutStock();
      await cubit.check();
    });
    await pumpApp(tester, location: '/alerts');

    expect(find.text('Paiement à valider'), findsOneWidget);
    expect(find.text('Stock négatif : Hamoud 33cl'), findsOneWidget);
    expect(find.text('2 NON LUE(S)'), findsOneWidget);

    await tester.tap(find.text('Stock négatif : Hamoud 33cl'));
    await settle(tester);
    expect(find.text('Produit soda'), findsOneWidget);

    GoRouter.of(tester.element(find.text('Produit soda'))).pop();
    await settle(tester);
    expect(find.text('1 NON LUE(S)'), findsOneWidget);
    await tester.tap(find.byTooltip('Tout marquer comme lu'));
    await settle(tester);
    expect(find.text('DÉJÀ LUES'), findsOneWidget);
    expect(cubit.state.unread, 0);
  });

  testWidgets('the owner turns a type of notification off', (tester) async {
    await pumpApp(tester, location: '/notifications');

    final paymentSwitch =
        find.widgetWithText(SwitchListTile, 'Paiements à valider');
    expect(tester.widget<SwitchListTile>(paymentSwitch).value, isTrue);
    await tester.tap(paymentSwitch);
    await settle(tester);

    expect(tester.widget<SwitchListTile>(paymentSwitch).value, isFalse);
    expect(settings.get(AlertType.pendingPayment.settingsKey), 'false');
    expect(cubit.rings(AlertType.pendingPayment), isFalse);
  });
}

/// Lets real database work finish, then redraws.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester
        .runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
  }
}
