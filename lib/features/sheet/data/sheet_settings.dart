import '../../../core/settings/settings_store.dart';

/// Phone settings of the Google Sheet (Phase 8). The script address and
/// the write key are on the shop record instead (they sync to the worker
/// phones); everything here stays on this phone.
extension SheetSettings on SettingsStore {
  static const readKeyName = 'sheet_read_key';
  static const _lastSend = 'sheet_last_send';
  static const _lastError = 'sheet_last_error';
  static const clockOffsetName = 'sheet_clock_offset';
  static const _liveNotify = 'live_notify';
  static const liveCursorName = 'live_sheet_cursor';
  static const liveSalesRowName = 'live_sales_rowid';
  static const liveReturnsRowName = 'live_returns_rowid';
  static const _liveChecked = 'live_last_check';
  static const _dailyOn = 'daily_report';
  static const _dailyTime = 'daily_report_time';
  static const dailyLastName = 'daily_report_last';
  static const dailyReportName = 'daily_report_json';
  static const driveLastName = 'drive_backup_last';
  static const driveTryName = 'drive_backup_try';
  static const _driveError = 'drive_backup_error';
  static const offPhoneName = 'backup_off_phone_last';

  /// Owner's phone only.
  String? get sheetReadKey => get(readKeyName);
  Future<void> setSheetReadKey(String? key) => set(readKeyName, key);

  /// When the queue was last emptied, and why the last try failed.
  DateTime? get sheetLastSend => DateTime.tryParse(get(_lastSend) ?? '');
  Future<void> setSheetLastSend(DateTime at) =>
      set(_lastSend, at.toIso8601String());
  String? get sheetLastError => get(_lastError);
  Future<void> setSheetLastError(String? error) => set(_lastError, error);

  /// How far this phone's clock is behind Google's (milliseconds).
  int get sheetClockOffset => int.tryParse(get(clockOffsetName) ?? '') ?? 0;

  /// "Ventes en direct": a notification for every sale (on by default).
  bool get liveNotify => get(_liveNotify) != 'off';
  Future<void> setLiveNotify(bool on) => set(_liveNotify, on ? null : 'off');

  DateTime? get liveLastCheck => DateTime.tryParse(get(_liveChecked) ?? '');
  Future<void> setLiveLastCheck(DateTime at) =>
      set(_liveChecked, at.toIso8601String());

  /// The evening report (on by default, at 21:00).
  bool get dailyReportOn => get(_dailyOn) != 'off';
  Future<void> setDailyReportOn(bool on) => set(_dailyOn, on ? null : 'off');

  /// Hour and minute of the evening report.
  ({int hour, int minute}) get dailyReportTime {
    final parts = (get(_dailyTime) ?? '').split(':');
    final hour = int.tryParse(parts.first);
    final minute = parts.length > 1 ? int.tryParse(parts[1]) : null;
    if (hour == null || minute == null || hour > 23 || minute > 59) {
      return (hour: 21, minute: 0);
    }
    return (hour: hour, minute: minute);
  }

  Future<void> setDailyReportTime(int hour, int minute) => set(_dailyTime,
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');

  /// Last backup saved in Google Drive.
  DateTime? get driveBackupLast => DateTime.tryParse(get(driveLastName) ?? '');
  String? get driveBackupError => get(_driveError);
  Future<void> setDriveBackupError(String? error) => set(_driveError, error);

  /// Last backup that left the phone (Google Drive, or shared by hand).
  DateTime? get backupOffPhoneLast {
    final shared = DateTime.tryParse(get(offPhoneName) ?? '');
    final drive = driveBackupLast;
    if (shared == null) return drive;
    if (drive == null) return shared;
    return drive.isAfter(shared) ? drive : shared;
  }

  Future<void> setBackupSharedAt(DateTime at) =>
      set(offPhoneName, at.toIso8601String());
}
