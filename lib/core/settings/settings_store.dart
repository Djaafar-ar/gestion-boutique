import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

/// Names of the settings that belong to this phone only.
class SettingsKeys {
  static const deviceId = 'device_id';
  static const language = 'language'; // system, ar, fr, en
  static const themeMode = 'theme_mode'; // system, light, dark
  static const printerMac = 'printer_mac';
  static const printerName = 'printer_name';
  static const hiveImported = 'hive_imported';
}

/// Phone-only settings, kept in memory for instant reads and saved to the
/// database on every change.
class SettingsStore {
  final AppDatabase db;
  final Map<String, String> _cache = {};

  SettingsStore(this.db);

  /// Reads every setting once at start-up and gives this phone its own id
  /// the very first time.
  Future<void> load() async {
    final rows = await db.select(db.appSettings).get();
    _cache
      ..clear()
      ..addEntries(rows.map((r) => MapEntry(r.key, r.value)));
    if (get(SettingsKeys.deviceId) == null) {
      await set(SettingsKeys.deviceId, const Uuid().v4());
    }
  }

  String? get(String key) => _cache[key];

  /// Saves a setting. A null [value] removes it.
  Future<void> set(String key, String? value) async {
    if (value == null) {
      _cache.remove(key);
      await (db.delete(db.appSettings)..where((t) => t.key.equals(key))).go();
    } else {
      _cache[key] = value;
      await db.into(db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: key, value: value));
    }
  }

  /// The unique id of this phone, written on every record it creates.
  String get deviceId => _cache[SettingsKeys.deviceId]!;
}
