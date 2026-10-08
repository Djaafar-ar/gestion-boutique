import 'dart:convert';

import 'package:path/path.dart' as p;

import '../../../core/settings/settings_store.dart';
import '../../backup/data/backup_service.dart';
import 'sheet_client.dart';
import 'sheet_protocol.dart';
import 'sheet_service.dart';
import 'sheet_settings.dart';

/// Owner's phone: once a day, a backup goes to the folder "Sauvegardes
/// Boutique" of the owner's Google Drive, through the sheet's script (it
/// keeps the last 30).
class DriveBackupService {
  final BackupService backups;
  final SheetService sheet;
  final SheetClient client;
  final SettingsStore settings;

  /// True on Wi-Fi (no mobile data used).
  final Future<bool> Function() onWifi;
  final DateTime Function() clock;

  /// After a failed try, wait this long before the next one.
  static const retryAfter = Duration(hours: 1);

  /// On mobile data, a backup is only sent when the last one is this old.
  static const mobileDataAfter = Duration(days: 3);

  /// The owner is warned when no backup left the phone for this long.
  static const warnAfter = Duration(days: 7);

  DriveBackupService({
    required this.backups,
    required this.sheet,
    required this.client,
    required this.settings,
    required this.onWifi,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  bool get enabled => sheet.canRead;

  /// No backup today yet (and no failed try in the last hour).
  Future<bool> isDue() async {
    if (!enabled) return false;
    await settings
        .reload([SheetSettings.driveLastName, SheetSettings.driveTryName]);
    final now = clock();
    final last = settings.driveBackupLast;
    if (last != null && sheetDayText(last) == sheetDayText(now)) return false;
    final tried =
        DateTime.tryParse(settings.get(SheetSettings.driveTryName) ?? '');
    return tried == null || now.difference(tried) >= retryAfter;
  }

  /// The daily backup, when it is due. On mobile data it waits for Wi-Fi,
  /// unless the last backup is already a few days old.
  Future<bool> runIfDue() async {
    if (!await isDue()) return false;
    final last = settings.driveBackupLast;
    if (last != null &&
        clock().difference(last) < mobileDataAfter &&
        !await onWifi()) {
      return false;
    }
    await uploadNow();
    return true;
  }

  /// "Sauvegarder maintenant": makes a backup and sends it to Drive.
  Future<DateTime> uploadNow() async {
    final to = await sheet.target();
    final readKey = settings.sheetReadKey;
    if (to == null || readKey == null || !enabled) {
      throw const SheetException(SheetError.notConfigured);
    }
    await settings.set(SheetSettings.driveTryName, clock().toIso8601String());
    try {
      final file = await backups.create();
      await client.call(to.url,
          key: readKey,
          keyId: 'r',
          op: 'backup',
          body: {
            'name': p.basename(file.path),
            'data': base64Encode(await file.readAsBytes()),
          },
          timeout: const Duration(minutes: 3));
    } on SheetException catch (e) {
      await settings.setDriveBackupError(e.error.name);
      rethrow;
    }
    final now = clock();
    await settings.set(SheetSettings.driveLastName, now.toIso8601String());
    await settings.setDriveBackupError(null);
    return now;
  }

  /// True when no backup left the phone for 7 days (or never).
  bool get needsWarning {
    final last = settings.backupOffPhoneLast;
    return last == null || clock().difference(last) >= warnAfter;
  }
}
