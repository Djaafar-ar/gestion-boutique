import 'dart:io';
import 'dart:ui';

import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/session/session_cubit.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/alerts/data/phone_notifier.dart';
import 'package:billing_app/features/backup/data/backup_service.dart';
import 'package:billing_app/features/billing/data/repositories/sale_repository_impl.dart';
import 'package:billing_app/features/billing/domain/entities/cart_item.dart';
import 'package:billing_app/features/billing/domain/entities/sale.dart';
import 'package:billing_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/sheet/data/daily_report_service.dart';
import 'package:billing_app/features/sheet/data/drive_backup_service.dart';
import 'package:billing_app/features/sheet/data/live_sales_service.dart';
import 'package:billing_app/features/sheet/data/sheet_client.dart';
import 'package:billing_app/features/sheet/data/sheet_protocol.dart';
import 'package:billing_app/features/sheet/data/sheet_service.dart';
import 'package:billing_app/features/sheet/data/sheet_settings.dart';
import 'package:billing_app/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:billing_app/features/shop/domain/entities/shop.dart';
import 'package:billing_app/features/stats/data/stats_repository.dart';
import 'package:billing_app/features/stock/data/repositories/stock_repository_impl.dart';
import 'package:billing_app/features/stock/data/stock_ledger.dart';
import 'package:billing_app/features/sync/data/sync_settings.dart';
import 'package:billing_app/features/users/domain/entities/app_user.dart';
import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_phone_notifier.dart';
import 'fakes/fake_sheet_script.dart';

/// Phase 8, owner's phone: "Ventes en direct", the evening report and
/// the daily Google Drive backup.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late SettingsStore settings;
  late SessionCubit session;
  late SaleRepositoryImpl sales;
  late FakeSheetScript script;
  late SheetClient client;
  late SheetService sheet;
  late FakeNotifier notifier;
  late LiveSalesService live;
  late DateTime now;

  const karim = AppUser(id: 'u-karim', name: 'Karim', role: UserRole.owner);
  const soda = Product(
      id: 'soda',
      name: 'Hamoud 33cl',
      barcode: '613',
      sellPrice: 6000,
      buyPrice: 4000);

  setUp(() async {
    now = DateTime.now();
    db = AppDatabase(NativeDatabase.memory());
    settings = SettingsStore(db);
    await settings.load();
    session = SessionCubit(hasOwner: true)..login(karim);
    for (final (id, name, role) in [
      ('u-karim', 'Karim', 'owner'),
      ('u-amine', 'Amine', 'worker'),
    ]) {
      await db.into(db.users).insert(UsersCompanion.insert(
          id: id,
          createdAt: now,
          updatedAt: now,
          deviceId: settings.deviceId,
          name: name,
          role: role,
          pinHash: 'x',
          pinSalt: 'y'));
    }
    await ShopRepositoryImpl(db, settings)
        .updateShop(const Shop(name: 'Épicerie El Baraka'));
    final products = ProductRepositoryImpl(db, settings, session);
    await products.addProduct(soda);
    await StockRepositoryImpl(
            db, settings, session, StockLedger(db), products)
        .addDelivery(productId: 'soda', quantity: 100, buyPrice: 4000);
    sales = SaleRepositoryImpl(db, settings, session, StockLedger(db));
    script = FakeSheetScript(now: () => now);
    client = SheetClient(script.client, settings, clock: () => now);
    sheet = SheetService(db, settings, client, clock: () => now);
    await sheet.configure(SheetConfig.decode(script.code)!);
    await settings.setSyncRole(SyncRole.hub);
    await settings.setDeviceCode('A');
    notifier = FakeNotifier();
    live = LiveSalesService(
        db: db,
        settings: settings,
        sheet: sheet,
        client: client,
        notifier: notifier,
        locale: () => const Locale('fr'),
        clock: () => now);
  });

  tearDown(() async {
    await session.close();
    await db.close();
  });

  Future<Sale> sell(int quantity) async =>
      (await sales.saveSale([CartItem(product: soda, quantity: quantity)]))
          .getOrElse((f) => fail(f.message));

  /// A sale of phone B, as the Wi-Fi sync saves it on the hub.
  Future<void> receiveByWifi(String id, int number, int total) =>
      db.into(db.sales).insert(SalesCompanion.insert(
          id: id,
          createdAt: now,
          updatedAt: now,
          deviceId: 'phone-b',
          userId: const Value('u-amine'),
          number: number,
          subtotal: total,
          total: total,
          paidNow: total));

  /// A sale of phone C, as phone C sent it to the sheet (mobile data).
  void sentToSheetByPhoneC(String id, String ticket, num totalDA) =>
      script.rows('S').add([
        id, sheetDay(now), '10:15', ticket, 'Yacine', 'C', 'Vente', //
        'Comptant', '', 1, totalDA, 0, totalDA, 20, 0, totalDA,
      ]);

  group('Ventes en direct', () {
    test('the first look is quiet; then each new sale is announced once',
        () async {
      await db.into(db.devices).insert(DevicesCompanion.insert(
          id: 'phone-b',
          createdAt: now,
          updatedAt: now,
          deviceId: 'phone-b',
          code: 'B',
          name: 'Caisse 2',
          role: 'worker'));
      await receiveByWifi('old', 1, 6000);
      await live.check();
      expect(notifier.shown, isEmpty, reason: 'what was there before');

      await sell(1); // the owner's own sale: listed, not announced
      await receiveByWifi('s-b2', 2, 12000);
      await live.check();
      expect(notifier.shown.single.title, 'Nouvelle vente n°B-2');
      expect(notifier.shown.single.body, 'Amine · 120,00 DA');
      expect(notifier.channels.single, liveSalesChannelId);

      // The same sale reaches the sheet too (phone B had mobile data).
      script.rows('S').add([
        's-b2', sheetDay(now), '10:00', 'B-2', 'Amine', 'B', 'Vente', //
        'Comptant', '', 1, 120, 0, 120, 40, 0, 120,
      ]);
      // A sale only in the sheet (phone C, away from the shop's Wi-Fi).
      sentToSheetByPhoneC('s-c1', 'C-1', 250);
      await live.check();
      expect(notifier.shown.map((n) => n.title),
          ['Nouvelle vente n°B-2', 'Nouvelle vente n°C-1']);

      final today = await live.watchToday().first;
      expect(today.map((r) => r.id).toSet(),
          {'old', 's-b2', 's-c1', ...today.where((r) => r.mine).map((r) => r.id)});
      expect(today.where((r) => r.mine), hasLength(1));
    });

    test('the owner can turn the notifications off', () async {
      await live.check();
      await settings.setLiveNotify(false);
      await receiveByWifi('s1', 1, 6000);
      await live.check();
      expect(notifier.shown, isEmpty);
      expect((await live.watchToday().first).single.id, 's1');
    });

    test('many sales at once: one notification', () async {
      await live.check();
      for (var i = 1; i <= 7; i++) {
        await receiveByWifi('s$i', i, 6000);
      }
      await live.check();
      expect(notifier.shown.single.title, '7 nouvelles ventes');
      expect(notifier.shown.single.body, 'Total : 420,00 DA');
    });

    test('a worker phone never follows the sales', () async {
      await settings.setSyncRole(SyncRole.worker);
      await live.check();
      await receiveByWifi('s1', 1, 6000);
      await live.check();
      expect(notifier.shown, isEmpty);
      expect(await live.watchToday().first, isEmpty);
    });
  });

  group('rapport du soir', () {
    late DailyReportService report;

    setUp(() {
      report = DailyReportService(
          settings: settings,
          stats: StatsRepository(db),
          sheet: sheet,
          client: client,
          notifier: notifier,
          locale: () => const Locale('fr'),
          clock: () => now);
    });

    test('the figures of the day, with the profit', () async {
      final sale = await sell(3); // 180 DA, cost 120 DA
      await sales.processReturn(saleId: sale.id, lines: [
        ReturnLine(
            saleItemId: sale.items.single.id, quantity: 1, backToStock: true),
      ]);
      final day = await report.build(now);
      expect(
          (day.sales, day.revenue, day.profit, day.cash, day.returns),
          (1, 12000, 4000, 12000, 6000));
    });

    test('the sheet wins when it knows more sales', () async {
      await sell(1);
      await sheet.sendNow();
      sentToSheetByPhoneC('s-c1', 'C-1', 250);
      final day = await report.build(now);
      expect((day.source, day.sales, day.revenue), ('sheet', 2, 31000));
      script.offline = true;
      expect((await report.build(now)).source, 'phone');
    });

    test('sent once, at the chosen time, as a private notification',
        () async {
      await settings.setDailyReportTime(21, 0);
      now = DateTime(now.year, now.month, now.day, 20, 59);
      expect(await report.runIfDue(), isNull);
      now = DateTime(now.year, now.month, now.day, 21, 5);
      final sent = await report.runIfDue();
      expect(sent, isNotNull);
      expect(notifier.shown.single.title, startsWith('Rapport du '));
      expect(notifier.shown.single.body, contains('Bénéfice'));
      expect(notifier.channels.single, dailyReportChannelId);
      expect(await report.runIfDue(), isNull, reason: 'once a day');
      expect(report.last, sent);
      expect(report.nextRun(now),
          DateTime(now.year, now.month, now.day + 1, 21));
    });

    test('never on a worker phone, and the owner can turn it off', () async {
      now = DateTime(now.year, now.month, now.day, 22);
      await settings.setSyncRole(SyncRole.worker);
      expect(await report.runIfDue(), isNull);
      await settings.setSyncRole(SyncRole.hub);
      await settings.setDailyReportOn(false);
      expect(await report.runIfDue(), isNull);
      expect(notifier.shown, isEmpty);
    });
  });

  group('sauvegarde Google Drive', () {
    late Directory dir;
    late DriveBackupService drive;
    var wifi = true;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('drive_test');
      wifi = true;
      drive = DriveBackupService(
          backups: BackupService(db, settings,
              folder: () async => dir, clock: () => now),
          sheet: sheet,
          client: client,
          settings: settings,
          onWifi: () async => wifi,
          clock: () => now);
    });

    tearDown(() => dir.delete(recursive: true));

    test('once a day, into the folder of the owner\'s Drive', () async {
      expect(drive.needsWarning, isTrue);
      expect(await drive.runIfDue(), isTrue);
      final saved = script.backups.entries.single;
      expect(saved.key, startsWith('sauvegarde_epicerie_el_baraka_'));
      final (info, _) = BackupService.read(saved.value);
      expect(info.shopName, 'Épicerie El Baraka');
      expect(script.requests.last['k'], 'r', reason: 'the read key');
      expect(drive.needsWarning, isFalse);
      expect(await drive.runIfDue(), isFalse, reason: 'already done today');
    });

    test('on mobile data it waits, unless the last one is old', () async {
      await drive.uploadNow();
      wifi = false;
      now = now.add(const Duration(days: 1));
      expect(await drive.runIfDue(), isFalse);
      now = now.add(const Duration(days: 3));
      expect(await drive.runIfDue(), isTrue);
      expect(script.backups, hasLength(2));
    });

    test('without internet: an error, tried again an hour later', () async {
      script.offline = true;
      await expectLater(drive.uploadNow(), throwsA(isA<SheetException>()));
      expect(settings.driveBackupError, 'offline');
      expect(await drive.isDue(), isFalse);
      now = now.add(const Duration(hours: 1));
      expect(await drive.isDue(), isTrue);
    });

    test('the warning after 7 days without a backup off the phone',
        () async {
      await drive.uploadNow();
      now = now.add(const Duration(days: 6));
      expect(drive.needsWarning, isFalse);
      now = now.add(const Duration(days: 2));
      expect(drive.needsWarning, isTrue);
      await settings.setBackupSharedAt(now); // sent by WhatsApp
      expect(drive.needsWarning, isFalse);
    });
  });
}
