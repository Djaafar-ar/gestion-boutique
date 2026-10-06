import 'app_database.dart';

/// The letter of each phone (A for the hub, B, C... for the others), by
/// device id. Empty while the shop has only one phone.
Future<Map<String, String>> deviceCodes(AppDatabase db) async => {
      for (final d in await db.select(db.devices).get()) d.id: d.code,
    };

/// Names of the given users, by id (unknown or null ids are skipped).
/// Used to show who sold, received or paid something.
Future<Map<String, String>> userNames(
    AppDatabase db, Iterable<String?> ids) async {
  final wanted = ids.whereType<String>().toSet();
  if (wanted.isEmpty) return {};
  final rows =
      await (db.select(db.users)..where((u) => u.id.isIn(wanted))).get();
  return {for (final row in rows) row.id: row.name};
}
