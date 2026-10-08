import 'dart:io';

import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/l10n/app_localizations.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/backup/data/backup_service.dart';
import 'package:billing_app/features/sheet/data/cloud_background.dart';
import 'package:billing_app/features/sheet/data/cloud_jobs.dart';
import 'package:billing_app/features/sheet/data/daily_report_service.dart';
import 'package:billing_app/features/sheet/data/drive_backup_service.dart';
import 'package:billing_app/features/sheet/data/live_sales_service.dart';
import 'package:billing_app/features/sheet/data/sheet_client.dart';
import 'package:billing_app/features/sheet/data/sheet_service.dart';
import 'package:billing_app/features/sheet/presentation/pages/sheet_page.dart';
import 'package:billing_app/features/sheet/presentation/sheet_cubit.dart';
import 'package:billing_app/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:billing_app/features/shop/domain/entities/shop.dart';
import 'package:billing_app/features/stats/data/stats_repository.dart';
import 'package:billing_app/features/sync/data/sync_settings.dart';
import 'package:billing_app/features/sync/data/sync_store.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_phone_notifier.dart';
import 'fakes/fake_sheet_script.dart';

class _FakeScheduler implements CloudScheduler {
  DateTime? report;
  @override
  Future<void> start() async {}
  @override
  Future<void> planDailyReport(DateTime at) async => report = at;
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late SettingsStore settings;
  late FakeSheetScript script;
  late SheetCubit cubit;
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('sheet_screens');
    db = AppDatabase(NativeDatabase.memory());
    settings = SettingsStore(db);
    await settings.load();
    await ShopRepositoryImpl(db, settings)
        .updateShop(const Shop(name: 'Épicerie El Baraka'));
    script = FakeSheetScript();
    final client = SheetClient(script.client, settings);
    final sheet = SheetService(db, settings, client);
    final notifier = FakeNotifier();
    Locale fr() => const Locale('fr');
    final jobs = CloudJobs(
      sheet: sheet,
      live: LiveSalesService(
          db: db,
          settings: settings,
          sheet: sheet,
          client: client,
          notifier: notifier,
          locale: fr),
      report: DailyReportService(
          settings: settings,
          stats: StatsRepository(db),
          sheet: sheet,
          client: client,
          notifier: notifier,
          locale: fr),
      drive: DriveBackupService(
          backups: BackupService(db, settings, folder: () async => dir),
          sheet: sheet,
          client: client,
          settings: settings,
          onWifi: () async => true),
    );
    cubit = SheetCubit(
        db: db,
        settings: settings,
        jobs: jobs,
        store: SyncStore(db),
        scheduler: _FakeScheduler());
  });

  tearDown(() async {
    if (!cubit.isClosed) await cubit.close();
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<void> show(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await tester.runAsync(cubit.refresh);
    await tester.pumpWidget(BlocProvider.value(
      value: cubit,
      child: const MaterialApp(
        locale: Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: SheetPage(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('a worker phone: the sending only, no setup, no figures',
      (tester) async {
    await tester.runAsync(() => settings.setSyncRole(SyncRole.worker));
    await show(tester);
    expect(
        find.textContaining('reçoit la configuration par la synchronisation'),
        findsOneWidget);
    expect(find.text('Scanner le code de configuration'), findsNothing);
    expect(find.text('Ventes en direct'), findsNothing);
    expect(find.text('Rapport du soir'), findsNothing);
  });

  testWidgets('the owner pastes the code: connected, history sent',
      (tester) async {
    await show(tester);
    expect(find.text('Pas encore configuré'), findsOneWidget);

    await tester.tap(find.text('Coller le code'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), script.code);
    await tester.tap(find.text('Continuer'));
    await tester.pump();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await tester.runAsync(cubit.refresh);
    await tester.pumpAndSettle();

    expect(find.text('Connecté à Google Sheet'), findsOneWidget);
    expect(find.textContaining('Connecté à « Boutique test »'), findsOneWidget);
    await tester.tap(find.text('Envoyer maintenant'));
    await tester.pump();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();
    expect(find.text('Tout est envoyé.'), findsOneWidget);

    // The owner's phone has the read key: live sales, report, Drive.
    expect(find.text('Ventes en direct'), findsWidgets);
    await tester.scrollUntilVisible(find.text('Sauvegarder maintenant'), 300);
    expect(find.text('Sauvegarder maintenant'), findsOneWidget);
    // Stops the "send in 5 seconds" timer.
    await tester.runAsync(cubit.close);
  });

  testWidgets('a code that is not ours is refused', (tester) async {
    await show(tester);
    await tester.tap(find.text('Coller le code'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '6130000000001');
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.textContaining("Ce n'est pas un code de configuration"),
        findsOneWidget);
    expect(find.text('Pas encore configuré'), findsOneWidget);
  });
}
