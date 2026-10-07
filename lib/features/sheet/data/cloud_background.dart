import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../../core/database/app_database.dart';
import '../../../core/service_locator.dart';
import '../../../core/settings/settings_store.dart';
import '../../alerts/data/phone_notifier.dart';
import 'cloud_jobs.dart';

const _taskName = 'cloud';
const _periodicName = 'cloud-every-15-min';
const _dailyReportName = 'cloud-daily-report';

/// Plans the Google Sheet jobs with Android when the app is closed.
/// Tests use a fake one.
abstract class CloudScheduler {
  /// About every 15 minutes, when there is internet.
  Future<void> start();

  /// The evening report, at [at] (Android may run it a few minutes late).
  Future<void> planDailyReport(DateTime at);
}

class WorkmanagerCloudScheduler implements CloudScheduler {
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    await Workmanager().initialize(cloudCallbackDispatcher);
    _initialized = true;
  }

  @override
  Future<void> start() async {
    try {
      await _init();
      await Workmanager().registerPeriodicTask(_periodicName, _taskName,
          frequency: const Duration(minutes: 15),
          constraints: Constraints(networkType: NetworkType.connected),
          existingWorkPolicy: ExistingPeriodicWorkPolicy.keep);
    } catch (e) {
      // The app still sends while it is open.
      debugPrint('Background jobs unavailable: $e');
    }
  }

  @override
  Future<void> planDailyReport(DateTime at) async {
    try {
      await _init();
      final delay = at.difference(DateTime.now());
      await Workmanager().registerOneOffTask(_dailyReportName, _taskName,
          initialDelay: delay.isNegative ? Duration.zero : delay,
          existingWorkPolicy: ExistingWorkPolicy.replace);
    } catch (e) {
      debugPrint('Cannot plan the evening report: $e');
    }
  }
}

/// Called by Android in the background (the app may be closed).
@pragma('vm:entry-point')
void cloudCallbackDispatcher() {
  Workmanager().executeTask((task, input) async {
    try {
      await runCloudJobs();
    } catch (e, stack) {
      debugPrint('Background Google Sheet job failed: $e\n$stack');
    }
    // Never "failed": the next run tries again anyway.
    return true;
  });
}

/// One round of the jobs. Inside the open app, the app's own jobs run;
/// otherwise this opens the database, runs them and closes it.
Future<void> runCloudJobs() async {
  if (sl.isRegistered<CloudJobs>()) {
    await sl<CloudJobs>().run();
    if (sl.isRegistered<CloudScheduler>()) {
      final report = sl<CloudJobs>().report;
      await sl<CloudScheduler>()
          .planDailyReport(report.nextRun(DateTime.now()));
    }
    return;
  }
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  try {
    final settings = SettingsStore(db);
    await settings.load();
    final notifier = LocalPhoneNotifier(settings);
    await notifier.init();
    final jobs = CloudJobs.build(
      db: db,
      settings: settings,
      notifier: notifier,
      locale: () => notificationLocale(settings),
    );
    await jobs.run();
    if (jobs.report.enabled) {
      await WorkmanagerCloudScheduler()
          .planDailyReport(jobs.report.nextRun(DateTime.now()));
    }
  } finally {
    await db.close();
  }
}
