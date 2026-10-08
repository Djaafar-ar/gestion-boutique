import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import '../../../core/database/app_database.dart';
import '../../../core/security/pin_hasher.dart';
import '../../../core/settings/settings_store.dart';
import '../../shop/data/repositories/shop_repository_impl.dart';
import '../../sheet/data/sheet_settings.dart';
import '../../sync/data/sync_settings.dart';

/// What a backup file says about itself (info.json inside the .zip).
class BackupInfo {
  final String shopId;
  final String shopName;
  final DateTime createdAt;

  /// The database version of the app that made it.
  final int schema;

  const BackupInfo({
    required this.shopId,
    required this.shopName,
    required this.createdAt,
    required this.schema,
  });
}

enum BackupError {
  /// Not a backup of this app (or a damaged file).
  notABackup,

  /// Made by a newer version of the app: update this phone first.
  newerVersion,

  /// A backup of another shop.
  otherShop,
  wrongPin,

  /// A worker phone gets its data from the main phone, not from a backup.
  workerPhone,
}

class BackupException implements Exception {
  final BackupError error;
  const BackupException(this.error);

  @override
  String toString() => 'BackupException(${error.name})';
}

/// Backups of the shop: one .zip file with the whole database and a small
/// info file. Restoring replaces the database when the app starts again.
class BackupService {
  final AppDatabase db;
  final SettingsStore settings;

  /// The app's own folder (the database is there).
  final Future<Directory> Function() folder;
  final DateTime Function() clock;

  static const appTag = 'gestion-boutique';
  static const _info = 'info.json';
  static const _data = 'shop.sqlite';
  static const pendingName = 'restore_pending.sqlite';

  /// Backups kept on the phone (the older ones are deleted).
  static const keepOnPhone = 10;

  BackupService(this.db, this.settings,
      {Future<Directory> Function()? folder, DateTime Function()? clock})
      : folder = folder ?? getApplicationDocumentsDirectory,
        clock = clock ?? DateTime.now;

  Future<Directory> _backupFolder() async {
    final dir = Directory(p.join((await folder()).path, 'backups'));
    await dir.create(recursive: true);
    return dir;
  }

  /// Makes a backup now, while the app runs (SQLite "VACUUM INTO" copies
  /// the database safely), and returns the .zip file. The Google Sheet
  /// read key is left out: after a restore, the owner scans the code
  /// again.
  Future<File> create() async {
    final dir = await _backupFolder();
    final now = clock();
    final copy =
        File(p.join(dir.path, 'copy_${now.microsecondsSinceEpoch}.sqlite'));
    if (await copy.exists()) await copy.delete();
    await db.customStatement('VACUUM INTO ?', [copy.path]);
    try {
      final raw = sqlite.sqlite3.open(copy.path);
      try {
        raw.execute('DELETE FROM app_settings WHERE key = ?',
            [SheetSettings.readKeyName]);
        raw.execute('VACUUM');
      } finally {
        raw.close();
      }
      final shop = await currentShopRow(db);
      final info = {
        'app': appTag,
        'format': 1,
        'shopId': shop?.id,
        'shopName': shop?.name ?? '',
        'createdAt': now.toIso8601String(),
        'schema': db.schemaVersion,
      };
      final archive = Archive()
        ..addFile(ArchiveFile.string(_info, jsonEncode(info)))
        ..addFile(ArchiveFile.bytes(_data, await copy.readAsBytes()));
      final file = File(p.join(dir.path, fileName(shop?.name ?? '', now)));
      await file.writeAsBytes(ZipEncoder().encodeBytes(archive), flush: true);
      await _prune(dir);
      return file;
    } finally {
      if (await copy.exists()) await copy.delete();
    }
  }

  /// "sauvegarde_epicerie_2026-10-07_2130.zip"
  static String fileName(String shopName, DateTime at) {
    final slug = shopName
        .toLowerCase()
        .replaceAll(RegExp('[àâä]'), 'a')
        .replaceAll(RegExp('[éèêë]'), 'e')
        .replaceAll(RegExp('[îï]'), 'i')
        .replaceAll(RegExp('[ôö]'), 'o')
        .replaceAll(RegExp('[ùûü]'), 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp('[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    String two(int n) => n.toString().padLeft(2, '0');
    return 'sauvegarde_${slug.isEmpty ? 'boutique' : slug}_'
        '${at.year}-${two(at.month)}-${two(at.day)}_'
        '${two(at.hour)}${two(at.minute)}${two(at.second)}.zip';
  }

  Future<void> _prune(Directory dir) async {
    final files = [
      for (final f in await dir.list().toList())
        if (f is File && f.path.endsWith('.zip')) (f, await f.lastModified()),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    for (final (old, _) in files.skip(keepOnPhone)) {
      await old.delete();
    }
  }

  /// Reads a backup file: its info and its database.
  static (BackupInfo, Uint8List) read(Uint8List zip) {
    try {
      final archive = ZipDecoder().decodeBytes(zip);
      final info = archive.findFile(_info)?.readBytes();
      final data = archive.findFile(_data)?.readBytes();
      if (info == null || data == null) {
        throw const BackupException(BackupError.notABackup);
      }
      final json = jsonDecode(utf8.decode(info)) as Map;
      if (json['app'] != appTag || json['shopId'] is! String) {
        throw const BackupException(BackupError.notABackup);
      }
      return (
        BackupInfo(
          shopId: json['shopId'] as String,
          shopName: '${json['shopName'] ?? ''}',
          createdAt: DateTime.parse(json['createdAt'] as String),
          schema: (json['schema'] as num).toInt(),
        ),
        data,
      );
    } on BackupException {
      rethrow;
    } catch (_) {
      throw const BackupException(BackupError.notABackup);
    }
  }

  /// Checks a backup before restoring it: from this app, not from a newer
  /// version, of this shop (any shop on a new phone), and [pin] is an
  /// owner's PIN (of this phone's shop, or of the backup on a new phone).
  ///
  /// Then makes a backup of the current data ("just in case") and leaves
  /// the backup's database ready: it replaces the current one when the
  /// app starts again ([applyPendingRestore]).
  Future<BackupInfo> prepareRestore(Uint8List zip,
      {required String pin}) async {
    final (info, data) = read(zip);
    if (info.schema > db.schemaVersion) {
      throw const BackupException(BackupError.newerVersion);
    }
    if (settings.syncRole == SyncRole.worker) {
      throw const BackupException(BackupError.workerPhone);
    }
    final shop = await currentShopRow(db);
    if (shop != null && shop.id != info.shopId) {
      throw const BackupException(BackupError.otherShop);
    }
    final dir = await folder();
    final check = File(p.join(dir.path, 'restore_check.sqlite'));
    await check.writeAsBytes(data, flush: true);
    try {
      final owners = shop != null
          ? [
              for (final u in await (db.select(db.users)
                    ..where((u) =>
                        u.role.equals('owner') & u.deleted.equals(false)))
                  .get())
                (u.pinHash, u.pinSalt),
            ]
          : _ownersIn(check.path);
      if (!owners.any((o) => PinHasher.verify(pin, o.$2, o.$1))) {
        throw const BackupException(BackupError.wrongPin);
      }
      if (shop != null) await create();
      await check.rename(p.join(dir.path, pendingName));
      return info;
    } finally {
      if (await check.exists()) await check.delete();
    }
  }

  static List<(String, String)> _ownersIn(String path) {
    try {
      final raw = sqlite.sqlite3.open(path, mode: sqlite.OpenMode.readOnly);
      try {
        return [
          for (final row in raw.select(
              "SELECT pin_hash, pin_salt FROM users WHERE role = 'owner' "
              'AND deleted = 0'))
            (row['pin_hash'] as String, row['pin_salt'] as String),
        ];
      } finally {
        raw.close();
      }
    } catch (_) {
      throw const BackupException(BackupError.notABackup);
    }
  }

  /// At start-up, before the database is opened: puts a restored backup
  /// in place of the current database. Returns true when it did.
  static Future<bool> applyPendingRestore({Directory? dir}) async {
    final folder = dir ?? await getApplicationDocumentsDirectory();
    final pending = File(p.join(folder.path, pendingName));
    if (!await pending.exists()) return false;
    final target = p.join(folder.path, '${AppDatabase.fileName}.sqlite');
    for (final suffix in ['', '-wal', '-shm', '-journal']) {
      final file = File('$target$suffix');
      if (await file.exists()) await file.delete();
    }
    await pending.rename(target);
    return true;
  }
}
