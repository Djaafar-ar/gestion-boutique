import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/database/app_database.dart';
import '../../../core/settings/settings_store.dart';
import '../../alerts/data/phone_notifier.dart';
import '../../backup/data/backup_service.dart';
import '../../stats/data/stats_repository.dart';
import 'daily_report_service.dart';
import 'drive_backup_service.dart';
import 'live_sales_service.dart';
import 'sheet_client.dart';
import 'sheet_service.dart';

/// Everything the Google Sheet part does from time to time: send the
/// queue, look for new sales (owner), the evening report (owner) and the
/// daily Drive backup (owner). Run by the app while it is open, and by
/// Android about every 15 minutes when it is closed.
class CloudJobs {
  final SheetService sheet;
  final LiveSalesService live;
  final DailyReportService report;
  final DriveBackupService drive;

  CloudJobs(
      {required this.sheet,
      required this.live,
      required this.report,
      required this.drive});

  /// Builds the jobs of one phone (the app and the background job share
  /// this, each with its own database connection and notifier).
  factory CloudJobs.build({
    required AppDatabase db,
    required SettingsStore settings,
    required PhoneNotifier notifier,
    required Locale Function() locale,
    http.Client? httpClient,
    Future<bool> Function()? onWifi,
  }) {
    final client = SheetClient(httpClient ?? http.Client(), settings);
    final sheet = SheetService(db, settings, client);
    return CloudJobs(
      sheet: sheet,
      live: LiveSalesService(
          db: db,
          settings: settings,
          sheet: sheet,
          client: client,
          notifier: notifier,
          locale: locale),
      report: DailyReportService(
          settings: settings,
          stats: StatsRepository(db),
          sheet: sheet,
          client: client,
          notifier: notifier,
          locale: locale),
      drive: DriveBackupService(
          backups: BackupService(db, settings),
          sheet: sheet,
          client: client,
          settings: settings,
          onWifi: onWifi ?? isOnWifi),
    );
  }

  /// One round. Each part fails alone (no internet...) without stopping
  /// the others.
  Future<void> run({bool liveFromSheet = true}) async {
    Future<void> guard(String name, Future<void> Function() job) async {
      try {
        await job();
      } catch (e) {
        debugPrint('Google Sheet $name: $e');
      }
    }

    await guard('send', () async {
      if (await sheet.target() != null && await sheet.pendingCount() > 0) {
        await sheet.sendNow();
      }
    });
    if (live.enabled) {
      await guard('live', () => live.check(withSheet: liveFromSheet));
    }
    await guard('report', () => report.runIfDue());
    await guard('backup', () => drive.runIfDue());
  }
}

/// True when the phone uses Wi-Fi (or a cable), not mobile data.
Future<bool> isOnWifi() async {
  try {
    final kinds = await Connectivity().checkConnectivity();
    return kinds.contains(ConnectivityResult.wifi) ||
        kinds.contains(ConnectivityResult.ethernet);
  } catch (_) {
    return false;
  }
}
