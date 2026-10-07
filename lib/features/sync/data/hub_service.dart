import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/settings/settings_store.dart';
import '../../shop/data/repositories/shop_repository_impl.dart';
import 'sync_protocol.dart';
import 'sync_settings.dart';
import 'sync_store.dart';

/// Letters given to the phones: the hub is 'A'.
const hubCode = 'A';
const _workerCodes = 'BCDEFGHIJKLMNOPQRSTUVWXYZ';

/// The shop as the sync needs it.
typedef ShopKeys = ({String id, String secret, String name});

/// What the owner's phone answers to the worker phones. It does not know
/// about the network: [HubServer] passes the messages in and out.
class HubService {
  final AppDatabase db;
  final SyncStore store;
  final SettingsStore settings;
  final DateTime Function() clock;

  HubService(this.db, this.store, this.settings, {DateTime Function()? clock})
      : clock = clock ?? DateTime.now;

  Future<ShopKeys?> shop() async {
    final row = await currentShopRow(db);
    if (row == null) return null;
    return (id: row.id, secret: row.shopSecret, name: row.name);
  }

  /// Changes after the hub's data was restored from a backup (see
  /// [SyncClient.sync]).
  Future<String> epoch() async {
    final current = settings.syncEpoch;
    if (current != null) return current;
    final fresh = const Uuid().v4();
    await settings.setSyncEpoch(fresh);
    return fresh;
  }

  /// Makes this phone the hub of the shop (letter A).
  Future<void> becomeHub({required String name}) async {
    await _register(settings.deviceId, name: name, role: 'hub', code: hubCode);
    await settings.setSyncRole(SyncRole.hub);
    await settings.setDeviceCode(hubCode);
  }

  /// Answers one message from a worker phone.
  Future<Map<String, Object?>> handle(Map<String, Object?> message) async {
    final keys = await shop();
    if (keys == null || message['shop'] != keys.id) {
      return _error(SyncError.badSignature);
    }
    // Different app versions would not understand each other's rows.
    if (message['schema'] != db.schemaVersion) {
      return _error(SyncError.version);
    }
    final deviceId = message['device'] as String?;
    if (deviceId == null) return _error(SyncError.other);
    final now = clock();

    switch (message['type']) {
      case 'hello':
        final code = await _register(deviceId,
            name: '${message['name'] ?? ''}', role: 'worker');
        store.changed();
        return {'ok': true, 'code': code, 'shopName': keys.name, 'now': '$now'};
      case 'sync':
        final device = await (db.select(db.devices)
              ..where((d) => d.id.equals(deviceId)))
            .getSingleOrNull();
        if (device == null || device.deleted || device.role != 'worker') {
          return _error(SyncError.unknownDevice);
        }
        // The worker's clock may be wrong: dates are put right.
        final theirNow = DateTime.tryParse('${message['now']}');
        final offset =
            theirNow == null ? Duration.zero : now.difference(theirNow);
        await store.applyFromWorker(decodeRows(message['rows']),
            clockOffset: offset);
        final changes = await store.changesSince(
            (message['cursor'] as num?)?.toInt() ?? 0,
            limit: syncPageSize);
        await settings.setLastSyncOf(deviceId, now);
        store.changed();
        return {
          'ok': true,
          'cursor': changes.cursor,
          'more': changes.more,
          'rows': encodeRows(changes.rows),
          'now': '$now',
          'epoch': await epoch(),
        };
      default:
        return _error(SyncError.other);
    }
  }

  /// Adds a phone to the shop (or brings back a removed one) and returns
  /// its letter.
  Future<String> _register(String deviceId,
      {required String name, required String role, String? code}) async {
    final now = clock();
    final existing = await (db.select(db.devices)
          ..where((d) => d.id.equals(deviceId)))
        .getSingleOrNull();
    if (existing != null) {
      await (db.update(db.devices)..where((d) => d.id.equals(deviceId))).write(
          DevicesCompanion(
              name: name.trim().isEmpty ? const Value.absent() : Value(name),
              deleted: const Value(false),
              updatedAt: Value(now)));
      return existing.code;
    }
    final used = {
      for (final d in await db.select(db.devices).get()) d.code,
    };
    final newCode = code ??
        _workerCodes.split('').firstWhere((c) => !used.contains(c),
            orElse: () => 'Z${used.length}');
    await db.into(db.devices).insert(DevicesCompanion.insert(
          id: deviceId,
          createdAt: now,
          updatedAt: now,
          deviceId: settings.deviceId,
          code: newCode,
          name: name.trim().isEmpty ? newCode : name.trim(),
          role: role,
        ));
    return newCode;
  }

  /// Owner: a phone that may no longer sync (lost, given away...).
  Future<void> removeDevice(String deviceId) async {
    await (db.update(db.devices)..where((d) => d.id.equals(deviceId))).write(
        DevicesCompanion(
            deleted: const Value(true), updatedAt: Value(clock())));
  }

  static Map<String, Object?> _error(SyncError error) =>
      {'ok': false, 'error': error.name};
}
