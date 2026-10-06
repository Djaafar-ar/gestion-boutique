import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/l10n/app_localizations.dart';
import 'package:billing_app/core/session/session_cubit.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/billing/data/repositories/sale_repository_impl.dart';
import 'package:billing_app/features/billing/domain/entities/cart_item.dart';
import 'package:billing_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:billing_app/features/shop/domain/entities/shop.dart';
import 'package:billing_app/features/stock/data/stock_ledger.dart';
import 'package:billing_app/features/sync/data/hub_keep_alive.dart';
import 'package:billing_app/features/sync/data/hub_service.dart';
import 'package:billing_app/features/sync/data/sync_client.dart';
import 'package:billing_app/features/sync/data/sync_network.dart';
import 'package:billing_app/features/sync/data/sync_protocol.dart';
import 'package:billing_app/features/sync/data/sync_settings.dart';
import 'package:billing_app/features/sync/data/sync_store.dart';
import 'package:billing_app/features/sync/presentation/pages/sync_page.dart';
import 'package:billing_app/features/sync/presentation/sync_cubit.dart';
import 'package:billing_app/features/users/data/repositories/user_repository_impl.dart';
import 'package:billing_app/features/users/domain/entities/app_user.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeKeepAlive implements HubKeepAlive {
  bool running = false;
  @override
  Future<void> start({required String title, required String text}) async =>
      running = true;
  @override
  Future<void> stop() async => running = false;
}

/// One phone with its sync controller.
class _Phone {
  final AppDatabase db;
  final SettingsStore settings;
  final SessionCubit session;
  final SyncStore store;
  final HubService hub;
  final _FakeKeepAlive keepAlive = _FakeKeepAlive();
  late final SyncCubit cubit;

  _Phone._(this.db, this.settings, this.session, this.store)
      : hub = HubService(db, store, settings);

  _Phone(AppDatabase db, SettingsStore settings, SessionCubit session)
      : this._(db, settings, session, SyncStore(db));

  static Future<_Phone> create(
      {required bool hasOwner, SyncTransport Function()? transport}) async {
    final db = AppDatabase(NativeDatabase.memory());
    final settings = SettingsStore(db);
    await settings.load();
    final phone = _Phone(db, settings, SessionCubit(hasOwner: hasOwner));
    phone.cubit = SyncCubit(
      db: db,
      store: phone.store,
      settings: settings,
      hub: phone.hub,
      server: HubServer(phone.hub),
      client: SyncClient(db, phone.store, settings,
          transport?.call() ?? const HttpSyncTransport()),
      keepAlive: phone.keepAlive,
      session: phone.session,
      locale: () => const Locale('fr'),
      hubPort: 0,
      discoveryPort: null,
    );
    return phone;
  }

  Future<void> close() async {
    await cubit.close();
    await session.close();
    await db.close();
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late _Phone owner;
  late AppUser karim;
  const soda =
      Product(id: 'soda', name: 'Hamoud 33cl', barcode: '613', sellPrice: 6000);

  setUp(() async {
    owner = await _Phone.create(hasOwner: true);
    final users = UserRepositoryImpl(owner.db, owner.settings);
    karim = (await users.createOwner(name: 'Karim', phone: '', pin: '1234'))
        .getOrElse((f) => fail(f.message))
        .owner;
    owner.session.login(karim);
    await ShopRepositoryImpl(owner.db, owner.settings)
        .updateShop(const Shop(name: 'Épicerie El Baraka'));
    await ProductRepositoryImpl(owner.db, owner.settings, owner.session)
        .addProduct(soda);
  });

  tearDown(() => owner.close());

  test('the owner switches the hub on and off', () async {
    await owner.cubit.start();
    expect(owner.cubit.state.role, SyncRole.none);

    await owner.cubit.startHub();
    expect(owner.cubit.state.role, SyncRole.hub);
    expect(owner.cubit.state.hubRunning, isTrue);
    expect(owner.keepAlive.running, isTrue, reason: '"Hub actif" shown');
    expect(owner.cubit.state.phones.single.code, 'A');
    expect(owner.settings.hubRunning, isTrue, reason: 'on after a restart');

    await owner.cubit.stopHub();
    expect(owner.cubit.state.hubRunning, isFalse);
    expect(owner.keepAlive.running, isFalse);
    expect(owner.settings.hubRunning, isFalse);
  });

  test('a new phone joins: its session gets the shop', () async {
    await owner.cubit.start();
    await owner.cubit.startHub();
    final keys = (await owner.hub.shop())!;
    final worker = await _Phone.create(
        hasOwner: false, transport: () => DirectTransport(owner.hub));
    addTearDown(worker.close);

    final code = await worker.cubit.join(
        PairingInfo(
            host: 'hub',
            port: syncPort,
            shopId: keys.id,
            secret: keys.secret,
            shopName: keys.name),
        deviceName: 'Caisse 2');

    expect(code, 'B');
    expect(worker.session.state.hasOwner, isTrue);
    expect(worker.session.state.isLoggedIn, isFalse, reason: 'PIN next');
    expect(worker.cubit.state.role, SyncRole.worker);
    expect(worker.cubit.state.shopName, 'Épicerie El Baraka');

    // The hub's list shows the new phone.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(owner.cubit.state.phones.map((p) => (p.code, p.name)),
        [('A', 'Karim'), ('B', 'Caisse 2')]);
  });

  test('erasing a phone empties it and goes back to the first screen',
      () async {
    await owner.cubit.start();
    await owner.cubit.eraseThisPhone();
    expect(owner.session.state.hasOwner, isFalse);
    expect(owner.cubit.state.role, SyncRole.none);
    expect(await owner.db.select(owner.db.products).get(), isEmpty);
    expect(await owner.db.select(owner.db.users).get(), isEmpty);
  });

  // ---------------------------------------------------------------- screens

  Future<void> show(WidgetTester tester, _Phone phone) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider.value(value: phone.session),
        BlocProvider.value(value: phone.cubit),
      ],
      child: const MaterialApp(
        locale: Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: SyncPage(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('owner, one phone: "make this the main phone"', (tester) async {
    await tester.runAsync(() => owner.cubit.start());
    await show(tester, owner);
    expect(
        find.text('Ce téléphone n\'est relié à aucun autre.'), findsOneWidget);
    expect(find.text('Faire de ce téléphone le téléphone principal'),
        findsOneWidget);
    expect(find.text('Rejoindre une autre boutique'), findsOneWidget);
  });

  testWidgets('worker phone: linked, sync now sends the sale', (tester) async {
    final worker = await tester.runAsync(() async {
      await owner.cubit.startHub();
      final keys = (await owner.hub.shop())!;
      final worker = await _Phone.create(
          hasOwner: false, transport: () => DirectTransport(owner.hub));
      await worker.cubit.join(
          PairingInfo(
              host: 'hub',
              port: syncPort,
              shopId: keys.id,
              secret: keys.secret,
              shopName: keys.name),
          deviceName: 'Caisse 2');
      // A sale on the worker phone, not sent yet.
      await SaleRepositoryImpl(worker.db, worker.settings, worker.session,
              StockLedger(worker.db))
          .saveSale(const [CartItem(product: soda)]);
      return worker;
    });
    addTearDown(() => tester.runAsync(worker!.close));
    await show(tester, worker!);

    expect(
        find.text('Relié à Épicerie El Baraka · téléphone B'), findsOneWidget);
    await tester.tap(find.text('Synchroniser maintenant'));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();

    expect(find.textContaining('Synchronisé'), findsOneWidget);
    final sales =
        await tester.runAsync(() => owner.db.select(owner.db.sales).get());
    expect(sales, hasLength(1));
  });
}
