import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/settings/settings_store.dart';
import '../domain/alert.dart';
import 'alert_rules.dart';

/// Keeps the alerts table up to date and remembers who read what.
class AlertRepository {
  final AppDatabase db;
  final SettingsStore settings;

  AlertRepository(this.db, this.settings);

  static const _sinceKey = 'alerts_since';

  /// Looks at the shop data again: new problems become alerts, solved
  /// ones disappear. Returns the alerts that are new (or came back, or got
  /// worse), which deserve a phone notification.
  Future<List<AlertDraft>> refresh({DateTime? now}) async {
    final at = now ?? DateTime.now();
    final sinceText = settings.get(_sinceKey);
    final since = sinceText == null ? at : DateTime.parse(sinceText);
    if (sinceText == null) await settings.set(_sinceKey, at.toIso8601String());

    final drafts = await currentAlerts(db, now: at, since: since);
    final raised = <AlertDraft>[];
    await db.transaction(() async {
      final existing = {
        for (final row in await db.select(db.alerts).get()) row.id: row,
      };
      for (final draft in drafts) {
        final row = existing.remove(draft.id);
        final data = jsonEncode({...draft.data, '_level': draft.level});
        if (row == null) {
          await db.into(db.alerts).insert(AlertsCompanion.insert(
                id: draft.id,
                type: draft.type.name,
                refId: draft.refId,
                data: Value(data),
                ownerOnly: draft.type.ownerOnly,
                createdAt: draft.at ?? at,
                updatedAt: at,
              ));
          raised.add(draft);
          continue;
        }
        final oldLevel = (jsonDecode(row.data) as Map)['_level'] as int? ?? 0;
        final comesBack = !row.active || draft.level > oldLevel;
        await (db.update(db.alerts)..where((a) => a.id.equals(draft.id)))
            .write(AlertsCompanion(
          data: Value(data),
          active: const Value(true),
          updatedAt: Value(at),
          createdAt: comesBack ? Value(draft.at ?? at) : const Value.absent(),
        ));
        if (comesBack) {
          // Unread again for everyone.
          await (db.delete(db.alertReads)
                ..where((r) => r.alertId.equals(draft.id)))
              .go();
          raised.add(draft);
        }
      }
      // What is left is solved.
      final solved = existing.values.where((r) => r.active).map((r) => r.id);
      if (solved.isNotEmpty) {
        await (db.update(db.alerts)..where((a) => a.id.isIn(solved))).write(
            AlertsCompanion(active: const Value(false), updatedAt: Value(at)));
      }
    });
    return raised;
  }

  /// Active alerts for one person, unread first, then newest first.
  /// Workers only get the stock alerts.
  Future<List<Alert>> getAlerts(
      {required String userId, required bool isOwner}) async {
    final query = db.select(db.alerts).join([
      leftOuterJoin(
          db.alertReads,
          db.alertReads.alertId.equalsExp(db.alerts.id) &
              db.alertReads.userId.equals(userId)),
    ])
      ..where(db.alerts.active.equals(true));
    if (!isOwner) query.where(db.alerts.ownerOnly.equals(false));
    final alerts = [
      for (final row in await query.get())
        if (AlertType.values.asNameMap()[row.readTable(db.alerts).type]
            case final type?)
          Alert(
            id: row.readTable(db.alerts).id,
            type: type,
            refId: row.readTable(db.alerts).refId,
            data: Map<String, dynamic>.from(
                jsonDecode(row.readTable(db.alerts).data) as Map),
            createdAt: row.readTable(db.alerts).createdAt,
            read: row.readTableOrNull(db.alertReads) != null,
          ),
    ];
    alerts.sort((a, b) {
      if (a.read != b.read) return a.read ? 1 : -1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return alerts;
  }

  Future<void> markRead(String alertId, String userId) =>
      db.into(db.alertReads).insertOnConflictUpdate(AlertReadsCompanion.insert(
          alertId: alertId, userId: userId, readAt: DateTime.now()));

  Future<void> markAllRead(
      {required String userId, required bool isOwner}) async {
    final alerts = await getAlerts(userId: userId, isOwner: isOwner);
    await db.batch((batch) {
      for (final alert in alerts.where((a) => !a.read)) {
        batch.insert(
            db.alertReads,
            AlertReadsCompanion.insert(
                alertId: alert.id, userId: userId, readAt: DateTime.now()),
            mode: InsertMode.insertOrReplace);
      }
    });
  }
}
