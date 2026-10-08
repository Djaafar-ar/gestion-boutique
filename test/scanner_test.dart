import 'dart:async';

import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/l10n/app_localizations.dart';
import 'package:billing_app/core/scanner/barcode_scan_service.dart';
import 'package:billing_app/core/scanner/scan_listener.dart';
import 'package:billing_app/core/scanner/spp_link.dart';
import 'package:billing_app/core/service_locator.dart';
import 'package:billing_app/core/session/session_cubit.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/repositories/product_repository.dart';
import 'package:billing_app/features/product/domain/usecases/product_usecases.dart';
import 'package:billing_app/features/product/presentation/bloc/product_bloc.dart';
import 'package:billing_app/features/product/presentation/pages/add_product_page.dart';
import 'package:billing_app/features/product/presentation/pages/product_list_page.dart';
import 'package:billing_app/features/settings/presentation/pages/scanner_device_page.dart';
import 'package:billing_app/features/stock/data/repositories/stock_repository_impl.dart';
import 'package:billing_app/features/stock/data/stock_ledger.dart';
import 'package:billing_app/features/stock/presentation/widgets/product_picker.dart';
import 'package:billing_app/features/users/domain/entities/app_user.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class FakeSppLink implements SppLink {
  final events$ = StreamController<SppEvent>.broadcast();
  var beeps = 0;
  var connects = 0;
  var answer = true;
  @override
  Future<List<BtDevice>> bondedDevices() async =>
      const [BtDevice('Scanner NT-1228', '00:11:22:33:44:55')];
  @override
  Future<bool> connect(String address) async {
    connects++;
    return answer;
  }

  @override
  Future<void> disconnect() async {}
  @override
  Stream<SppEvent> get events => events$.stream;
  @override
  Future<void> beep() async => beeps++;
}

/// A screen that keeps what it was given.
class _Target implements ScanTarget {
  final codes = <String>[];
  bool active = true;
  bool accept = true;
  @override
  bool get acceptsScans => active;
  @override
  bool onScan(String code) {
    codes.add(code);
    return accept;
  }
}

/// The Bluetooth barcode scanner ("douchette") on every screen that scans.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SettingsStore settings;
  late FakeSppLink spp;
  late BarcodeScanService scanner;
  late ProductBloc productBloc;
  late SessionCubit session;

  const soda = Product(
      id: 'soda', name: 'Hamoud 33cl', barcode: '6130000001', sellPrice: 6000);

  setUp(() async {
    await sl.reset();
    db = AppDatabase(NativeDatabase.memory());
    settings = SettingsStore(db);
    await settings.load();
    spp = FakeSppLink();
    scanner = BarcodeScanService(spp, settings);
    sl.registerSingleton(scanner);
    session = SessionCubit(hasOwner: true)
      ..login(const AppUser(id: 'o', name: 'Karim', role: UserRole.owner));
    final products = ProductRepositoryImpl(db, settings, session);
    sl.registerSingleton<ProductRepository>(products);
    await products.addProduct(soda);
    productBloc = ProductBloc(
      getProductsUseCase: GetProductsUseCase(products),
      addProductUseCase: AddProductUseCase(products),
      updateProductUseCase: UpdateProductUseCase(products),
      archiveProductUseCase: ArchiveProductUseCase(products),
      stockRepository: StockRepositoryImpl(
          db, settings, session, StockLedger(db), products),
    );
  });

  tearDown(() async {
    await scanner.stop();
    await productBloc.close();
    await session.close();
    await db.close();
    await sl.reset();
  });

  /// What a keyboard scanner (or the PC keyboard of the emulator) types.
  Future<void> typeBarcode(WidgetTester tester, String code) async {
    for (final char in code.split('')) {
      await tester.sendKeyEvent(LogicalKeyboardKey(char.codeUnitAt(0)),
          character: char);
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
  }

  Widget app({required Widget home, GoRouter? router}) {
    Widget wrap(Widget child) => MultiBlocProvider(
          providers: [BlocProvider.value(value: productBloc)],
          child: child,
        );
    const delegates = [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];
    if (router != null) {
      return wrap(MaterialApp.router(
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: delegates,
          routerConfig: router));
    }
    return wrap(MaterialApp(
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: delegates,
        home: home));
  }

  Future<void> loadProducts(WidgetTester tester) async {
    await tester.runAsync(() async {
      productBloc.add(LoadProducts());
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
  }

  group('keyboard scanners (HID)', () {
    testWidgets('a barcode then Enter goes to the screen on top, with a beep',
        (tester) async {
      scanner.start();
      final below = _Target(), top = _Target();
      scanner
        ..register(below)
        ..register(top);
      await typeBarcode(tester, '6130000001');
      expect(top.codes, ['6130000001']);
      expect(below.codes, isEmpty);
      expect(spp.beeps, 1);

      // An unknown barcode: no beep (the screen shows a message).
      top.accept = false;
      await typeBarcode(tester, '999');
      expect(spp.beeps, 1);

      // The top screen is hidden: the one below gets it.
      top.active = false;
      await typeBarcode(tester, '614');
      expect(below.codes, ['614']);
    });

    testWidgets('a slow pause starts a new barcode; too short is ignored',
        (tester) async {
      var now = DateTime(2026, 10, 8, 10);
      scanner = BarcodeScanService(spp, settings, clock: () => now);
      final target = _Target();
      scanner.register(target);
      KeyDownEvent key(String c) => KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyA,
          logicalKey: LogicalKeyboardKey(c.codeUnitAt(0)),
          character: c,
          timeStamp: Duration.zero);
      const enter = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.enter,
          logicalKey: LogicalKeyboardKey.enter,
          timeStamp: Duration.zero);
      scanner.handleKey(key('1'));
      now = now.add(const Duration(seconds: 5)); // someone walked away
      for (final c in '6130'.split('')) {
        scanner.handleKey(key(c));
      }
      expect(scanner.handleKey(enter), isTrue);
      expect(target.codes, ['6130']);
      scanner.handleKey(key('7'));
      scanner.handleKey(enter);
      expect(target.codes, ['6130'], reason: '1 character is not a barcode');
      // Enter alone is left to the screen (a button...).
      expect(scanner.handleKey(enter), isFalse);
    });

    testWidgets('while typing in a text field, the field gets the keys',
        (tester) async {
      scanner.start();
      final target = _Target();
      scanner.register(target);
      await tester.pumpWidget(app(
          home: const Scaffold(body: TextField(autofocus: true))));
      await tester.pump();
      await typeBarcode(tester, '6130000001');
      expect(target.codes, isEmpty);
    });
  });

  group('screens', () {
    testWidgets('the page on top gets the scan, not the one below',
        (tester) async {
      scanner.start();
      final got = <String>[];
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigator,
        home: ScanListener(
            onScan: (c) {
              got.add('below:$c');
              return true;
            },
            child: const Scaffold()),
      ));
      navigator.currentState!.push(MaterialPageRoute<void>(
          builder: (_) => ScanListener(
              onScan: (c) {
                got.add('top:$c');
                return true;
              },
              child: const Scaffold())));
      await tester.pumpAndSettle();
      await typeBarcode(tester, '111');
      navigator.currentState!.pop();
      await tester.pumpAndSettle();
      await typeBarcode(tester, '222');
      // A dialog over the page: nobody gets it.
      showDialog<void>(
          context: navigator.currentContext!,
          builder: (_) => const AlertDialog(content: Text('?')));
      await tester.pumpAndSettle();
      await typeBarcode(tester, '333');
      expect(got, ['top:111', 'below:222']);
    });

    testWidgets('product picker: a scan picks the product', (tester) async {
      await loadProducts(tester);
      Product? picked;
      await tester.pumpWidget(app(
          home: Builder(
              builder: (context) => Scaffold(
                  body: TextButton(
                      onPressed: () async => picked = await pickProduct(context),
                      child: const Text('pick'))))));
      await tester.tap(find.text('pick'));
      await tester.pumpAndSettle();
      // A keyboard scanner types into the search field, then Enter.
      await tester.enterText(find.byType(TextField), soda.barcode);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(picked, soda);
    });

    testWidgets('search: known barcode found; unknown: message and create',
        (tester) async {
      scanner.start();
      await loadProducts(tester);
      final router = GoRouter(initialLocation: '/stock', routes: [
        GoRoute(
            path: '/stock',
            builder: (_, __) => const ProductListPage(),
            routes: [
              GoRoute(
                  path: 'add',
                  builder: (_, s) =>
                      AddProductPage(initialBarcode: s.extra as String?)),
            ]),
      ]);
      await tester.pumpWidget(app(home: const SizedBox(), router: router));
      await tester.pumpAndSettle();
      // Nothing to tap first: the scan goes straight to the page.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await typeBarcode(tester, soda.barcode);
      expect(find.widgetWithText(TextField, 'Hamoud 33cl'), findsOneWidget);
      expect(spp.beeps, 1);

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await typeBarcode(tester, '6139999999');
      expect(find.text('Code-barres inconnu : 6139999999'), findsOneWidget);
      await tester.tap(find.text('Créer le produit'));
      await tester.pumpAndSettle();
      // The new product form, barcode already filled in.
      expect(find.widgetWithText(TextFormField, '6139999999'), findsOneWidget);

      // On that form, the next scan fills the barcode field.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await typeBarcode(tester, '6131111111');
      expect(find.widgetWithText(TextFormField, '6131111111'), findsOneWidget);
    });

    testWidgets('Douchette page: test area, SPP connect and reconnect',
        (tester) async {
      scanner.start();
      await loadProducts(tester);
      await tester.pumpWidget(app(home: ScannerDevicePage(service: scanner)));
      await tester.pumpAndSettle();
      await typeBarcode(tester, soda.barcode);
      expect(find.text('Scan n°1 reçu : 6130000001'), findsOneWidget);
      expect(find.text('Produit : Hamoud 33cl'), findsOneWidget);

      await tester.scrollUntilVisible(
          find.text('Voir les appareils associés'), 200);
      await tester.tap(find.text('Voir les appareils associés'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Scanner NT-1228'), 200);
      await tester.tap(find.text('Scanner NT-1228'));
      await tester.pumpAndSettle();
      expect(scanner.sppStatus.value, SppStatus.connected);
      expect(scanner.sppAddress, '00:11:22:33:44:55');

      // A barcode over the serial link.
      spp.events$.add(const SppCode('6130000001'));
      await tester.pumpAndSettle();
      expect(find.text('Scan n°2 reçu : 6130000001', skipOffstage: false),
          findsOneWidget);

      // Switched off: it reconnects by itself.
      spp.events$.add(const SppDisconnected());
      await tester.pump();
      expect(scanner.sppStatus.value, SppStatus.disconnected);
      await tester.pump(BarcodeScanService.retryEvery);
      await tester.pumpAndSettle();
      expect(spp.connects, 2);
      expect(scanner.sppStatus.value, SppStatus.connected);
      await scanner.forget();
    });
  });

  test('the remembered SPP scanner is connected at start', () async {
    await settings.set('scanner_spp_address', '00:11');
    final again = BarcodeScanService(spp, settings)..start();
    await Future<void>.delayed(Duration.zero);
    expect(spp.connects, 1);
    await again.stop();
  });
}
