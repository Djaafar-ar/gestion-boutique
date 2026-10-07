import 'dart:async';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/synced_tables.dart';

/// One shared row as sent between phones: its table and its column values
/// exactly as stored (text, numbers or null).
typedef SyncRow = ({String table, Map<String, Object?> data});

/// Reads and writes the rows exchanged by the Wi-Fi sync.
///
/// Every change of a shared row lands in `sync_log` (database triggers).
/// - On the hub, the log is the list of everything to hand out, in order:
///   a worker asks "what changed after number N?".
/// - On a worker phone, the log only holds what was done on this phone and
///   not yet sent (rows received from the hub are taken out of it).
class SyncStore {
  final AppDatabase db;

  /// Fires after rows from another phone were saved, so screens reload.
  final _received = StreamController<void>.broadcast();

  SyncStore(this.db);

  Stream<void> get received => _received.stream;

  /// Something about the sync changed (a phone joined or synced).
  void changed() => _received.add(null);

  /// Changes smaller than this between two phone clocks are ignored.
  static const clockTolerance = Duration(minutes: 2);

  TableInfo _table(String name) {
    if (!syncedTables.contains(name)) throw ArgumentError('Not shared: $name');
    return db.allTables.firstWhere((t) => t.actualTableName == name);
  }

  /// The current values of the rows named by [entries].
  Future<List<SyncRow>> _rowsFor(List<SyncLogRow> entries) async {
    final idsByTable = <String, List<String>>{};
    for (final entry in entries) {
      idsByTable.putIfAbsent(entry.entity, () => []).add(entry.rowId);
    }
    final rows = <String, Map<String, Object?>>{};
    for (final MapEntry(key: table, value: ids) in idsByTable.entries) {
      _table(table); // only shared tables
      for (var i = 0; i < ids.length; i += 500) {
        final part =
            ids.sublist(i, i + 500 > ids.length ? ids.length : i + 500);
        final result = await db.customSelect(
          'SELECT * FROM $table WHERE id IN '
          '(${List.filled(part.length, '?').join(',')})',
          variables: [for (final id in part) Variable<String>(id)],
        ).get();
        for (final row in result) {
          rows['$table/${row.data['id']}'] = row.data;
        }
      }
    }
    // Keep the order of the log.
    return [
      for (final entry in entries)
        if (rows['${entry.entity}/${entry.rowId}'] case final data?)
          (table: entry.entity, data: data),
    ];
  }

  /// Hub: what changed after [cursor], oldest first.
  Future<({List<SyncRow> rows, int cursor, bool more})> changesSince(int cursor,
      {int limit = 500}) async {
    final entries = await (db.select(db.syncLog)
          ..where((l) => l.seq.isBiggerThanValue(cursor))
          ..orderBy([(l) => OrderingTerm.asc(l.seq)])
          ..limit(limit + 1))
        .get();
    final more = entries.length > limit;
    final page = entries.take(limit).toList();
    return (
      rows: await _rowsFor(page),
      cursor: page.isEmpty ? cursor : page.last.seq,
      more: more,
    );
  }

  /// Worker: what was done on this phone and not sent yet. [upTo] is the
  /// last log number included, for [clearOutbox].
  Future<({List<SyncRow> rows, int upTo})> outbox({int limit = 500}) async {
    final entries = await (db.select(db.syncLog)
          ..orderBy([(l) => OrderingTerm.asc(l.seq)])
          ..limit(limit))
        .get();
    return (
      rows: await _rowsFor(entries),
      upTo: entries.isEmpty ? 0 : entries.last.seq,
    );
  }

  /// Worker: puts every shared row of this phone in the outbox, to send
  /// them all to a hub restored from a backup. The hub keeps the newest
  /// version of each row, so nothing is counted twice.
  Future<void> queueEverything() async {
    await db.transaction(() async {
      for (final table in syncedTables) {
        await db.customStatement(
            'INSERT OR IGNORE INTO sync_log (entity, row_id) '
            "SELECT '$table', id FROM $table");
      }
    });
  }

  /// Worker: the hub has the rows up to [upTo]. A row changed again since
  /// has a bigger number, so it stays to be sent next time.
  Future<void> clearOutbox(int upTo) =>
      (db.delete(db.syncLog)..where((l) => l.seq.isSmallerOrEqualValue(upTo)))
          .go();

  Future<int> outboxCount() async {
    final count = db.syncLog.seq.count();
    return (await (db.selectOnly(db.syncLog)..addColumns([count])).getSingle())
            .read(count) ??
        0;
  }

  /// Hub: saves rows sent by a worker phone. [clockOffset] is how far the
  /// worker's clock is behind the hub's; dates are corrected when it is
  /// more than a couple of minutes.
  ///
  /// A row already on the hub is only replaced by a newer version (last
  /// change wins, by the hub's clock). Sales, deliveries, payments... are
  /// never changed after they are made, so they never conflict: they are
  /// simply added, and a row received twice is saved once.
  Future<void> applyFromWorker(List<SyncRow> rows,
      {Duration clockOffset = Duration.zero}) async {
    if (rows.isEmpty) return;
    final correct = clockOffset.abs() > clockTolerance;
    final tables = <TableInfo>{};
    await db.transaction(() async {
      for (final row in rows) {
        final table = _table(row.table);
        final data = Map<String, Object?>.of(row.data);
        if (correct) {
          for (final column in ['created_at', 'updated_at']) {
            final date = _date(data[column]);
            if (date != null) {
              data[column] =
                  db.typeMapping.mapToSqlVariable(date.add(clockOffset));
            }
          }
        }
        final local = await db.customSelect(
            'SELECT updated_at FROM ${row.table} WHERE id = ?',
            variables: [Variable<String>('${data['id']}')]).getSingleOrNull();
        if (local != null) {
          final mine = _date(local.data['updated_at']);
          final theirs = _date(data['updated_at']);
          // Equal or older: keep what the hub has.
          if (mine != null && theirs != null && !theirs.isAfter(mine)) {
            continue;
          }
        }
        await _upsert(table, data);
        tables.add(table);
      }
    });
    if (tables.isNotEmpty) _received.add(null);
  }

  /// Worker: saves rows from the hub as they are (the hub decides). Rows
  /// changed on this phone and not sent yet are kept: they go to the hub
  /// next, and the hub decides then. Received rows are not sent back.
  Future<void> applyFromHub(List<SyncRow> rows) async {
    if (rows.isEmpty) return;
    await db.transaction(() async {
      final pending = {
        for (final entry in await db.select(db.syncLog).get())
          '${entry.entity}/${entry.rowId}',
      };
      final maxSeq = db.syncLog.seq.max();
      final before =
          (await (db.selectOnly(db.syncLog)..addColumns([maxSeq])).getSingle())
                  .read(maxSeq) ??
              0;
      for (final row in rows) {
        if (pending.contains('${row.table}/${row.data['id']}')) continue;
        await _upsert(_table(row.table), row.data);
      }
      // The triggers logged the received rows: they are not ours to send.
      await (db.delete(db.syncLog)
            ..where((l) => l.seq.isBiggerThanValue(before)))
          .go();
    });
    _received.add(null);
  }

  /// Inserts the row, or updates it when its id exists. Only the columns
  /// this version of the app knows are written.
  Future<void> _upsert(TableInfo table, Map<String, Object?> data) {
    final columns = [
      for (final column in table.$columns)
        if (data.containsKey(column.name)) column.name,
    ];
    final updates = [
      for (final column in columns)
        if (column != 'id') '$column = excluded.$column',
    ];
    return db.customInsert(
      'INSERT INTO ${table.actualTableName} (${columns.join(', ')}) '
      'VALUES (${List.filled(columns.length, '?').join(', ')}) '
      'ON CONFLICT(id) DO UPDATE SET ${updates.join(', ')}',
      variables: [for (final column in columns) _variable(data[column])],
      updates: {table},
    );
  }

  static Variable _variable(Object? value) => switch (value) {
        null => const Variable<String>(null),
        final int v => Variable<int>(v),
        final double v => Variable<double>(v),
        final String v => Variable<String>(v),
        final bool v => Variable<int>(v ? 1 : 0),
        _ => Variable<String>('$value'),
      };

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;

  /// Erases every shop row on this phone (before it joins another shop).
  /// Phone settings (language, printer...) are kept.
  Future<void> wipe() async {
    await db.transaction(() async {
      for (final table in syncedTables) {
        await db.customStatement('DELETE FROM $table');
      }
      await db.delete(db.alertReads).go();
      await db.delete(db.alerts).go();
      await db.delete(db.syncLog).go();
      await db.delete(db.sheetQueue).go();
      await db.delete(db.liveSales).go();
    });
    db.notifyUpdates({
      for (final table in db.allTables) TableUpdate.onTable(table),
    });
  }
}
