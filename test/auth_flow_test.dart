import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/l10n/app_localizations.dart';
import 'package:billing_app/core/service_locator.dart';
import 'package:billing_app/core/session/session_cubit.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/auth/data/login_guard.dart';
import 'package:billing_app/features/auth/presentation/pages/login_page.dart';
import 'package:billing_app/features/auth/presentation/pages/setup_page.dart';
import 'package:billing_app/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:billing_app/features/shop/domain/repositories/shop_repository.dart';
import 'package:billing_app/features/shop/domain/usecases/shop_usecases.dart';
import 'package:billing_app/features/shop/presentation/bloc/shop_bloc.dart';
import 'package:billing_app/features/users/data/repositories/user_repository_impl.dart';
import 'package:billing_app/features/users/domain/repositories/user_repository.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Screen tests for the two doors into the app: the first-launch setup
// and the PIN login. They use a real (in-memory) database.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late SessionCubit session;
  late UserRepositoryImpl users;

  setUp(() async {
    await sl.reset();
    db = AppDatabase(NativeDatabase.memory());
    final settings = SettingsStore(db);
    await settings.load();
    users = UserRepositoryImpl(db, settings);
    session = SessionCubit(hasOwner: false);
    sl
      ..registerSingleton(db)
      ..registerSingleton(settings)
      ..registerSingleton<UserRepository>(users)
      ..registerSingleton<ShopRepository>(ShopRepositoryImpl(db, settings))
      ..registerSingleton(LoginGuard(settings));
  });

  tearDown(() async {
    await session.close();
    await db.close();
    await sl.reset();
  });

  Widget app(Widget home) {
    final shopRepo = sl<ShopRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: session),
        BlocProvider(
            create: (_) => ShopBloc(
                getShopUseCase: GetShopUseCase(shopRepo),
                updateShopUseCase: UpdateShopUseCase(shopRepo))),
      ],
      child: MaterialApp(
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: home,
      ),
    );
  }

  /// Lets real database work finish, then redraws the screen.
  Future<void> settle(WidgetTester tester) async {
    await tester
        .runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();
  }

  Future<void> typePin(WidgetTester tester, String pin) async {
    for (final digit in pin.split('')) {
      await tester.tap(find.widgetWithText(FilledButton, digit));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 200));
    await settle(tester);
  }

  testWidgets('setup creates the shop and the owner, then logs in',
      (tester) async {
    await tester.pumpWidget(app(const SetupPage()));
    await settle(tester);

    // Step 1: shop
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nom de la boutique'),
        'Épicerie El Baraka');
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();

    // Step 2: owner
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Votre nom'), 'Karim');
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();

    // Step 3: PIN twice, first with a typo
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Code PIN (4 chiffres)'), '1234');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirmez le code PIN'), '1235');
    await tester.tap(find.text('Terminer'));
    await tester.pumpAndSettle();
    expect(
        find.text('Les deux codes PIN ne sont pas identiques'), findsOneWidget);
    expect(session.state.hasOwner, isFalse);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirmez le code PIN'), '1234');
    await tester.tap(find.text('Terminer'));
    await settle(tester);

    expect(session.state.hasOwner, isTrue);
    expect(session.state.user?.name, 'Karim');
    expect(session.state.isOwner, isTrue);
    final shop = await tester.runAsync(() => db.select(db.shops).getSingle());
    expect(shop!.name, 'Épicerie El Baraka');
  });

  testWidgets('login: wrong PIN is refused, right PIN opens the app',
      (tester) async {
    await tester.runAsync(() async {
      await users.createOwner(name: 'Karim', phone: '', pin: '1234');
      await users.addWorker(name: 'Amine', phone: '', pin: '5678');
    });
    session = SessionCubit(hasOwner: true);

    await tester.pumpWidget(app(const LoginPage()));
    await settle(tester);
    expect(find.text('Qui êtes-vous ?'), findsOneWidget);

    await tester.tap(find.text('Amine'));
    await tester.pumpAndSettle();
    await typePin(tester, '1234'); // the owner's PIN, not Amine's
    expect(find.textContaining('Code PIN incorrect'), findsOneWidget);
    expect(session.state.isLoggedIn, isFalse);

    await typePin(tester, '5678');
    expect(session.state.user?.name, 'Amine');
    expect(session.state.isOwner, isFalse);
  });
}
