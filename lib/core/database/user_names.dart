import 'app_database.dart';

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
