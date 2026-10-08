import 'dart:async';

import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/database/app_database.dart';
import '../../../core/settings/settings_store.dart';
import '../../sync/data/sync_settings.dart';
import '../../sync/data/sync_store.dart';
import '../data/cloud_background.dart';
import '../data/cloud_jobs.dart';
import '../data/daily_report_service.dart';
import '../data/sheet_client.dart';
import '../data/sheet_protocol.dart';
import '../data/sheet_settings.dart';

class SheetState extends Equatable {
  /// The shop has a sheet (on a worker phone: received by Wi-Fi).
  final bool configured;

  /// Not a worker phone: the owner may set the sheet up here.
  final bool ownerPhone;

  /// The read key is here: live sales, report and Drive backups.
  final bool canRead;

  /// The Gmail address of the sheet (owner's phone).
  final String? account;
  final int pending;
  final DateTime? lastSend;
  final SheetError? lastError;
  final bool sending;

  final bool liveNotify;
  final bool dailyOn;
  final int dailyHour;
  final int dailyMinute;
  final DailyReport? lastReport;

  final DateTime? lastDriveBackup;
  final SheetError? driveError;
  final bool backingUp;

  /// No backup left the phone for 7 days.
  final bool backupWarning;

  const SheetState({
    this.configured = false,
    this.ownerPhone = false,
    this.canRead = false,
    this.account,
    this.pending = 0,
    this.lastSend,
    this.lastError,
    this.sending = false,
    this.liveNotify = true,
    this.dailyOn = true,
    this.dailyHour = 21,
    this.dailyMinute = 0,
    this.lastReport,
    this.lastDriveBackup,
    this.driveError,
    this.backingUp = false,
    this.backupWarning = false,
  });

  SheetState copyWith({bool? sending, bool? backingUp}) => SheetState(
        configured: configured,
        ownerPhone: ownerPhone,
        canRead: canRead,
        account: account,
        pending: pending,
        lastSend: lastSend,
        lastError: lastError,
        sending: sending ?? this.sending,
        liveNotify: liveNotify,
        dailyOn: dailyOn,
        dailyHour: dailyHour,
        dailyMinute: dailyMinute,
        lastReport: lastReport,
        lastDriveBackup: lastDriveBackup,
        driveError: driveError,
        backingUp: backingUp ?? this.backingUp,
        backupWarning: backupWarning,
      );

  @override
  List<Object?> get props => [
        configured,
        ownerPhone,
        canRead,
        account,
        pending,
        lastSend,
        lastError,
        sending,
        liveNotify,
        dailyOn,
        dailyHour,
        dailyMinute,
        lastReport,
        lastDriveBackup,
        driveError,
        backingUp,
        backupWarning,
      ];
}

/// Plus → Google Sheet, and the Google Sheet jobs while the app is open:
/// the queue is sent a few seconds after each record, new sales are
/// looked for, the evening report and the Drive backup are done when due.
class SheetCubit extends Cubit<SheetState> {
  final AppDatabase db;
  final SettingsStore settings;
  final CloudJobs jobs;
  final SyncStore store;
  final CloudScheduler scheduler;

  /// While the app is open, everything is checked this often.
  static const every = Duration(minutes: 2);

  /// A new record is sent this long after it was saved.
  static const afterChange = Duration(seconds: 5);

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Timer? _timer;
  Timer? _sendSoon;
  Timer? _liveSoon;

  SheetCubit({
    required this.db,
    required this.settings,
    required this.jobs,
    required this.store,
    required this.scheduler,
  }) : super(const SheetState());

  /// Called once when the app starts.
  Future<void> start() async {
    await refresh();
    _subscriptions.add(db
        .tableUpdates(TableUpdateQuery.onAllTables([db.sheetQueue]))
        .listen((_) => _scheduleSend()));
    // A sale made here or received by Wi-Fi: "Ventes en direct".
    _subscriptions.add(db
        .tableUpdates(TableUpdateQuery.onAllTables([db.sales, db.returns]))
        .listen((_) => _scheduleLive()));
    _subscriptions.add(store.received.listen((_) => _scheduleLive()));
    _timer = Timer.periodic(every, (_) => runJobs());
    await scheduler.start();
    await _planReport();
    unawaited(runJobs());
  }

  void _scheduleSend() {
    _sendSoon?.cancel();
    _sendSoon = Timer(afterChange, () async {
      if (state.configured && !state.sending) await sendNow(quiet: true);
    });
  }

  void _scheduleLive() {
    if (!jobs.live.enabled) return;
    _liveSoon?.cancel();
    _liveSoon = Timer(const Duration(seconds: 1), () async {
      try {
        await jobs.live.check(withSheet: false);
      } catch (_) {
        // Shown again at the next check.
      }
    });
  }

  Future<void> _planReport() async {
    if (jobs.report.enabled) {
      await scheduler.planDailyReport(jobs.report.nextRun(DateTime.now()));
    }
  }

  /// Every part of the Google Sheet work, once.
  Future<void> runJobs() async {
    if (isClosed) return;
    await jobs.run();
    await refresh();
  }

  Future<void> refresh() async {
    if (isClosed) return;
    await settings.reload([
      SheetSettings.driveLastName,
      SheetSettings.dailyReportName,
      SheetSettings.offPhoneName,
    ]);
    final target = await jobs.sheet.target();
    final pending = await jobs.sheet.pendingCount();
    final time = settings.dailyReportTime;
    if (isClosed) return;
    emit(SheetState(
      configured: target != null,
      ownerPhone: settings.syncRole != SyncRole.worker,
      canRead: jobs.sheet.canRead,
      account: jobs.sheet.canRead ? settings.sheetAccount : null,
      pending: pending,
      lastSend: settings.sheetLastSend,
      lastError: SheetError.values.asNameMap()[settings.sheetLastError],
      sending: state.sending,
      liveNotify: settings.liveNotify,
      dailyOn: settings.dailyReportOn,
      dailyHour: time.hour,
      dailyMinute: time.minute,
      lastReport: jobs.report.last,
      lastDriveBackup: settings.driveBackupLast,
      driveError: SheetError.values.asNameMap()[settings.driveBackupError],
      backingUp: state.backingUp,
      backupWarning:
          settings.syncRole != SyncRole.worker && jobs.drive.needsWarning,
    ));
  }

  /// "Envoyer maintenant". Returns how many records were sent; throws a
  /// [SheetException] (unless [quiet]).
  Future<int> sendNow({bool quiet = false}) async {
    emit(state.copyWith(sending: true));
    try {
      return await jobs.sheet.sendNow();
    } on SheetException {
      if (!quiet) rethrow;
      return 0;
    } finally {
      if (!isClosed) emit(state.copyWith(sending: false));
      await refresh();
    }
  }

  /// Owner: the scanned configuration code. Returns the sheet's name.
  Future<String> configure(SheetConfig config) async {
    final name = await jobs.sheet.configure(config);
    await refresh();
    _scheduleSend();
    unawaited(runJobs());
    return name;
  }

  /// The page opens: which Google account? (quietly, without internet
  /// the last one known is shown).
  Future<void> refreshAccount() async {
    try {
      await jobs.sheet.refreshAccount();
    } on SheetException {
      return;
    }
    await refresh();
  }

  Future<void> disconnect() async {
    await jobs.sheet.disconnect();
    await refresh();
  }

  Future<void> setLiveNotify(bool on) async {
    await settings.setLiveNotify(on);
    await refresh();
  }

  Future<void> setDailyReport({bool? on, int? hour, int? minute}) async {
    if (on != null) await settings.setDailyReportOn(on);
    if (hour != null && minute != null) {
      await settings.setDailyReportTime(hour, minute);
    }
    await _planReport();
    await refresh();
  }

  /// "Sauvegarder maintenant" (Google Drive).
  Future<void> backupNow() async {
    emit(state.copyWith(backingUp: true));
    try {
      await jobs.drive.uploadNow();
    } finally {
      if (!isClosed) emit(state.copyWith(backingUp: false));
      await refresh();
    }
  }

  /// The owner shared a backup by hand (WhatsApp, USB...).
  Future<void> backupShared() async {
    await settings.setBackupSharedAt(DateTime.now());
    await refresh();
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _timer?.cancel();
    _sendSoon?.cancel();
    _liveSoon?.cancel();
    return super.close();
  }
}
