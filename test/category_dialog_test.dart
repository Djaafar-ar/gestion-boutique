import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/l10n/app_localizations.dart';
import 'package:billing_app/core/service_locator.dart';
import 'package:billing_app/core/session/session_cubit.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:billing_app/features/product/domain/repositories/product_repository.dart';
import 'package:billing_app/features/product/presentation/widgets/product_form_fields.dart';
import 'package:billing_app/features/users/domain/entities/app_user.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Adding a category from the product form (the dialog used to crash with
// "_dependents.isEmpty" because its text box was thrown away too early).
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late SessionCubit session;
  late ProductRepository products;

  setUp(() async {
    await sl.reset();
    db = AppDatabase(NativeDatabase.memory());
    final settings = SettingsStore(db);
    await settings.load();
    session = SessionCubit(hasOwner: true)
      ..login(const AppUser(id: 'o', name: 'Karim', role: UserRole.owner));
    products = ProductRepositoryImpl(db, settings, session);
    sl.registerSingleton<ProductRepository>(products);
  });

  tearDown(() async {
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

  Future<ProductFormValues> show(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    final values = ProductFormValues();
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('fr'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: SingleChildScrollView(
          child: Form(child: ProductFormFields(values: values)),
        ),
      ),
    ));
    await settle(tester);
    return values;
  }

  Future<void> openNewCategory(WidgetTester tester) async {
    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nouvelle catégorie…').last);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
  }

  testWidgets('adding a category selects it, without an error', (tester) async {
    final values = await show(tester);
    await openNewCategory(tester);

    await tester.enterText(find.byType(TextField).last, 'Boissons');
    await tester.tap(find.text('Ajouter'));
    await settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Boissons'), findsOneWidget, reason: 'now selected');

    final saved = await tester.runAsync(() => products.getCategories());
    final categories = saved!.getOrElse((f) => fail(f.message));
    expect(categories.map((c) => c.name), ['Boissons']);

    await tester.enterText(find.byType(TextFormField).at(0), 'Hamoud 33cl');
    await tester.enterText(find.byType(TextFormField).at(1), '60');
    final form = tester.state<FormState>(find.byType(Form));
    expect(form.validate(), isTrue);
    form.save();
    expect(values.categoryId, categories.single.id);
  });

  testWidgets('pressing Enter in the dialog also adds it', (tester) async {
    await show(tester);
    await openNewCategory(tester);

    await tester.enterText(find.byType(TextField).last, 'Épicerie');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Épicerie'), findsOneWidget);
  });

  testWidgets('cancelling adds nothing and goes back to "no category"',
      (tester) async {
    await show(tester);
    await openNewCategory(tester);

    await tester.enterText(find.byType(TextField).last, 'Oubli');
    await tester.tap(find.text('Annuler'));
    await settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Sans catégorie'), findsOneWidget);
    final saved = await tester.runAsync(() => products.getCategories());
    expect(saved!.getOrElse((f) => fail(f.message)), isEmpty);
  });
}
