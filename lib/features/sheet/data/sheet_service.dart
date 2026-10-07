import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/settings/settings_store.dart';
import '../../shop/data/repositories/shop_repository_impl.dart';
import '../../sync/data/sync_settings.dart';
import 'sheet_client.dart';
import 'sheet_protocol.dart';
import 'sheet_records.dart';
import 'sheet_settings.dart';

/// Sets up the Google Sheet and sends it the records waiting in the queue.
class SheetService {
  final AppDatabase db;
  final SettingsStore settings;
  final SheetClient client;
  final SheetRecords records;
  final DateTime Function() clock;

  /// Records sent in one request: small requests on mobile data.
  static const batchSize = 100;

  bool _sending = false;

  SheetService(this.db, this.settings, this.client,
      {SheetRecords? records, DateTime Function()? clock})
      : records = records ?? SheetRecords(db),
        clock = clock ?? DateTime.now;

  /// The script address and write key of the shop, or null.
  Future<({String url, String writeKey})?> target() async {
    final shop = await currentShopRow(db);
    final url = shop?.sheetUrl, key = shop?.sheetWriteKey;
    if (url == null || key == null) return null;
    return (url: url, writeKey: key);
  }

  /// Whether this phone can read the figures (the owner's phone).
  bool get canRead =>
      settings.sheetReadKey != null && settings.syncRole != SyncRole.worker;

  /// Owner: uses the scanned [config]. Checks both keys with the script
  /// first, so a wrong code changes nothing. The address and the write
  /// key go on the shop record (the worker phones get them by Wi-Fi);
  /// the read key stays on this phone. With a new sheet, everything
  /// already in the shop is queued once.
  Future<String> configure(SheetConfig config) async {
    if (settings.syncRole == SyncRole.worker) {
      throw const SheetException(SheetError.notConfigured, 'worker phone');
    }
    final answer = await client.call(config.url,
        key: config.writeKey, keyId: 'w', op: 'ping', body: const {});
    final readKey = config.readKey;
    if (readKey != null) {
      await client.call(config.url,
          key: readKey, keyId: 'r', op: 'ping', body: const {});
    }
    final shop = await currentShopRow(db);
    if (shop == null) {
      throw const SheetException(SheetError.notConfigured, 'no shop');
    }
    final newSheet = shop.sheetUrl != config.url;
    await (db.update(db.shops)..where((s) => s.id.equals(shop.id))).write(
        ShopsCompanion(
            sheetUrl: Value(config.url),
            sheetWriteKey: Value(config.writeKey),
            updatedAt: Value(clock())));
    await settings.setSheetReadKey(readKey);
    await settings.setSheetLastError(null);
    if (newSheet) await queueEverything();
    return '${answer['name'] ?? ''}';
  }

  /// Owner: stops sending to the sheet (on every phone, after Wi-Fi sync).
  Future<void> disconnect() async {
    final shop = await currentShopRow(db);
    if (shop != null) {
      await (db.update(db.shops)..where((s) => s.id.equals(shop.id))).write(
          ShopsCompanion(
              sheetUrl: const Value(null),
              sheetWriteKey: const Value(null),
              updatedAt: Value(clock())));
    }
    await settings.setSheetReadKey(null);
    await db.delete(db.sheetQueue).go();
  }

  /// Queues every record of the shop, oldest first (a new sheet).
  Future<void> queueEverything() => db.customStatement('''
INSERT OR IGNORE INTO sheet_queue (kind, row_id)
SELECT kind, id FROM (
  SELECT 'sale' AS kind, id, created_at AS at FROM sales WHERE deleted = 0
  UNION ALL SELECT 'return', id, created_at FROM returns WHERE deleted = 0
  UNION ALL SELECT 'customerPayment', id, created_at FROM customer_payments
    WHERE deleted = 0
  UNION ALL SELECT 'delivery', id, created_at FROM deliveries WHERE deleted = 0
  UNION ALL SELECT 'loss', id, created_at FROM losses WHERE deleted = 0
  UNION ALL SELECT 'supplierPayment', id, created_at FROM supplier_payments
    WHERE deleted = 0
  UNION ALL SELECT 'credit', id, '9' FROM customers WHERE deleted = 0
    AND (id IN (SELECT customer_id FROM sales WHERE customer_id IS NOT NULL)
      OR id IN (SELECT customer_id FROM customer_payments))
) ORDER BY at''');

  Future<int> pendingCount() async {
    final count = db.sheetQueue.seq.count();
    return (await (db.selectOnly(db.sheetQueue)..addColumns([count]))
                .getSingle())
            .read(count) ??
        0;
  }

  /// Sends the queue, [batchSize] records at a time. A batch leaves the
  /// queue only once the script has confirmed it; without internet
  /// everything stays and goes next time. Returns how many were sent.
  Future<int> sendNow() async {
    if (_sending) return 0;
    _sending = true;
    try {
      final to = await target();
      if (to == null) throw const SheetException(SheetError.notConfigured);
      final worker = settings.syncRole == SyncRole.worker;
      var sent = 0;
      while (true) {
        final entries = await (db.select(db.sheetQueue)
              ..orderBy([(q) => OrderingTerm.asc(q.seq)])
              ..limit(batchSize))
            .get();
        if (entries.isEmpty) break;
        final batch = await records.build(entries,
            onlyDevice: worker ? settings.deviceId : null,
            withCredit: !worker);
        if (batch.isNotEmpty) {
          await client.call(to.url,
              key: to.writeKey, keyId: 'w', op: 'push', body: {'r': batch});
        }
        // A record changed again meanwhile got a new number: it stays.
        await (db.delete(db.sheetQueue)
              ..where((q) => q.seq.isIn(entries.map((e) => e.seq))))
            .go();
        sent += batch.length;
        if (entries.length < batchSize) break;
      }
      await settings.setSheetLastSend(clock());
      await settings.setSheetLastError(null);
      return sent;
    } on SheetException catch (e) {
      await settings.setSheetLastError(e.error.name);
      rethrow;
    } finally {
      _sending = false;
    }
  }
}
