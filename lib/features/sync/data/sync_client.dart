import '../../../core/database/app_database.dart';
import '../../../core/settings/settings_store.dart';
import 'sync_network.dart';
import 'sync_protocol.dart';
import 'sync_settings.dart';
import 'sync_store.dart';

/// What one sync did.
typedef SyncSummary = ({int sent, int received});

/// A worker phone's side of the sync: joining the shop, then sending what
/// was done here and receiving what was done elsewhere.
class SyncClient {
  final AppDatabase db;
  final SyncStore store;
  final SettingsStore settings;
  final SyncTransport transport;

  /// Finds the hub again when its address changed. Null in tests.
  final HubFinder? finder;
  final DateTime Function() clock;

  SyncClient(this.db, this.store, this.settings, this.transport,
      {this.finder, DateTime Function()? clock})
      : clock = clock ?? DateTime.now;

  /// Links this (empty) phone to the hub of the pairing QR code, then
  /// downloads the whole shop. Returns this phone's letter.
  Future<String> join(PairingInfo info, {required String deviceName}) async {
    final answer = await transport.send(
      host: info.host,
      port: info.port,
      secret: info.secret,
      message: {
        'type': 'hello',
        'shop': info.shopId,
        'device': settings.deviceId,
        'name': deviceName,
        'schema': db.schemaVersion,
        'now': clock().toIso8601String(),
      },
    );
    final code = answer['code'] as String;
    await settings.setHub(
        host: info.host,
        port: info.port,
        shopId: info.shopId,
        secret: info.secret);
    await settings.setSyncCursor(0);
    await settings.setDeviceCode(code);
    await settings.setSyncRole(SyncRole.worker);
    await sync();
    return code;
  }

  /// Sends everything not sent yet, then receives everything new, page by
  /// page. Safe to stop at any moment: what was not confirmed is sent
  /// again next time, and the hub ignores what it already has.
  Future<SyncSummary> sync() async {
    final shopId = settings.syncShopId;
    final secret = settings.syncSecret;
    if (settings.syncRole != SyncRole.worker ||
        shopId == null ||
        secret == null) {
      throw const SyncException(SyncError.unknownDevice);
    }
    var sent = 0, received = 0;
    for (var round = 0; round < 1000; round++) {
      final outbox = await store.outbox(limit: syncPageSize);
      final resend = settings.resendAll;
      final answer = await _send(shopId, secret, {
        'type': 'sync',
        'shop': shopId,
        'device': settings.deviceId,
        'schema': db.schemaVersion,
        'now': clock().toIso8601String(),
        // While sending everything again, nothing is downloaded yet.
        'cursor': resend ? _nothing : settings.syncCursor,
        'rows': encodeRows(outbox.rows),
      });
      // The hub has them now.
      await store.clearOutbox(outbox.upTo);
      sent += outbox.rows.length;

      // The hub was restored from a backup: it may have lost what was
      // done after that backup. This phone sends it everything it has,
      // then downloads everything again.
      final epoch = answer['epoch'] as String?;
      if (epoch != null && epoch != settings.hubEpoch) {
        final known = settings.hubEpoch;
        await settings.setHubEpoch(epoch);
        if (known != null) {
          await store.queueEverything();
          await settings.setResendAll(true);
          continue;
        }
      }
      if (resend) {
        if (outbox.rows.length < syncPageSize) {
          await settings.setResendAll(false);
          await settings.setSyncCursor(0);
        }
        continue;
      }
      final rows = decodeRows(answer['rows']);
      await store.applyFromHub(rows);
      received += rows.length;
      await settings.setSyncCursor((answer['cursor'] as num).toInt());
      if (answer['more'] != true && outbox.rows.length < syncPageSize) break;
    }
    await settings.setLastSync(clock());
    return (sent: sent, received: received);
  }

  /// A cursor after every change: the hub answers with no rows.
  static const _nothing = 1 << 52;

  Future<Map<String, Object?>> _send(
      String shopId, String secret, Map<String, Object?> message) async {
    final host = settings.hubHost;
    if (host == null) throw const SyncException(SyncError.unknownDevice);
    try {
      return await transport.send(
          host: host, port: settings.hubPort, secret: secret, message: message);
    } on SyncException catch (e) {
      final finder = this.finder;
      if (e.error != SyncError.unreachable || finder == null) rethrow;
      // The hub may have a new address: ask on the Wi-Fi, then try again.
      final found = await finder.find(shopId: shopId, secret: secret);
      if (found == null || found.host == host) rethrow;
      await settings.setHubHost(found.host);
      return transport.send(
          host: found.host, port: found.port, secret: secret, message: message);
    }
  }
}
