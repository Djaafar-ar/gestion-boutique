import 'dart:ui';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/user_names.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/settings/settings_store.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/money.dart';
import '../../alerts/data/phone_notifier.dart';
import '../../billing/domain/entities/sale.dart';
import '../../sync/data/sync_settings.dart';
import 'sheet_client.dart';
import 'sheet_protocol.dart';
import 'sheet_service.dart';
import 'sheet_settings.dart';

/// "Ventes en direct" on the owner's phone: the day's sales and returns
/// of every phone, and a notification for each new sale.
///
/// Sales arrive two ways: by Wi-Fi sync (the phones in the shop) and from
/// the Google Sheet (phones on mobile data, read with the read key). Both
/// land in `live_sales` by ticket id, so a sale arriving both ways is
/// shown and announced once.
class LiveSalesService {
  final AppDatabase db;
  final SettingsStore settings;
  final SheetService sheet;
  final SheetClient client;
  final PhoneNotifier notifier;
  final Locale Function() locale;
  final DateTime Function() clock;

  /// More new sales than this at once: one notification for all of them.
  static const maxSingleNotifications = 5;

  LiveSalesService({
    required this.db,
    required this.settings,
    required this.sheet,
    required this.client,
    required this.notifier,
    required this.locale,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  /// Only the owner's phone follows the sales (never a worker phone).
  bool get enabled => settings.syncRole != SyncRole.worker;

  /// Takes the sales and returns saved on this phone since the last look
  /// (made here, or received by Wi-Fi). The first time, only today's,
  /// without announcing them. Sales of another day arriving late (a
  /// phone that was away) are listed but never announced.
  Future<int> checkLocal() async {
    if (!enabled) return 0;
    await settings.reload(
        [SheetSettings.liveSalesRowName, SheetSettings.liveReturnsRowName]);
    final today = startOfDay(clock());
    final codes = await deviceCodes(db);
    var added = 0;

    for (final table in ['sales', 'returns']) {
      final key = table == 'sales'
          ? SheetSettings.liveSalesRowName
          : SheetSettings.liveReturnsRowName;
      final cursor = int.tryParse(settings.get(key) ?? '');
      final List<String> ids;
      final int last;
      if (cursor == null) {
        // First look: today only, and start after the last row.
        last = (await db
                .customSelect('SELECT coalesce(max(rowid), 0) AS m FROM $table')
                .getSingle())
            .read<int>('m');
        ids = table == 'sales'
            ? await (db.selectOnly(db.sales)
                  ..addColumns([db.sales.id])
                  ..where(db.sales.createdAt.isBiggerOrEqualValue(today)))
                .map((r) => r.read(db.sales.id)!)
                .get()
            : await (db.selectOnly(db.returns)
                  ..addColumns([db.returns.id])
                  ..where(db.returns.createdAt.isBiggerOrEqualValue(today)))
                .map((r) => r.read(db.returns.id)!)
                .get();
      } else {
        final rows = await db.customSelect(
            'SELECT rowid AS r, id FROM $table WHERE rowid > ? '
            'ORDER BY rowid LIMIT 5000',
            variables: [Variable<int>(cursor)]).get();
        if (rows.isEmpty) continue;
        ids = [for (final row in rows) row.read<String>('id')];
        last = rows.last.read<int>('r');
      }
      final quiet = cursor == null;
      added += table == 'sales'
          ? await _addSales(ids, codes, today, quiet: quiet)
          : await _addReturns(ids, codes);
      await settings.set(key, '$last');
    }
    return added;
  }

  Future<int> _addSales(
      List<String> ids, Map<String, String> codes, DateTime today,
      {required bool quiet}) async {
    if (ids.isEmpty) return 0;
    final rows =
        await (db.select(db.sales)..where((s) => s.id.isIn(ids))).get();
    final names = await userNames(db, rows.map((s) => s.userId));
    var added = 0;
    for (final sale in rows) {
      final at = sale.createdAt.toLocal();
      final mine = sale.deviceId == settings.deviceId;
      added += await _add(LiveSalesCompanion.insert(
        id: sale.id,
        at: at,
        ticket: ticketLabel(sale.number, codes[sale.deviceId]),
        seller: names[sale.userId] ?? '',
        kind: 'sale',
        total: sale.total,
        mine: mine,
        notified: Value(mine || quiet || at.isBefore(today)),
      ));
    }
    return added;
  }

  /// Returns (and exchanges): money given back, never announced.
  Future<int> _addReturns(List<String> ids, Map<String, String> codes) async {
    if (ids.isEmpty) return 0;
    final rows =
        await (db.select(db.returns)..where((r) => r.id.isIn(ids))).get();
    final saleIds = rows.map((r) => r.saleId).whereType<String>();
    final tickets = {
      for (final s in await (db.select(db.sales)
            ..where((s) => s.id.isIn(saleIds)))
          .get())
        s.id: (ticketLabel(s.number, codes[s.deviceId]), s.userId),
    };
    final names = await userNames(db, [
      ...rows.map((r) => r.userId),
      ...tickets.values.map((t) => t.$2),
    ]);
    var added = 0;
    for (final ret in rows) {
      final ticket = tickets[ret.saleId];
      added += await _add(LiveSalesCompanion.insert(
        id: ret.id,
        at: ret.createdAt.toLocal(),
        ticket: ticket?.$1 ?? '',
        seller: names[ticket?.$2 ?? ret.userId] ?? '',
        kind: 'return',
        total: -ret.total,
        mine: ret.deviceId == settings.deviceId,
        notified: const Value(true),
      ));
    }
    return added;
  }

  /// Asks the sheet for the rows added since the last look ("anything
  /// since row N?": usually an answer of a few bytes). Owner's phone
  /// with the read key only. The first time, only today's rows, without
  /// announcing them.
  Future<int> checkSheet() async {
    if (!enabled || !sheet.canRead) return 0;
    final to = await sheet.target();
    final readKey = settings.sheetReadKey;
    if (to == null || readKey == null) return 0;
    await settings.reload([SheetSettings.liveCursorName]);
    var cursor = int.tryParse(settings.get(SheetSettings.liveCursorName) ?? '');
    final first = cursor == null;
    final myCode = settings.deviceCode ?? '';
    final today = startOfDay(clock());
    var added = 0;
    for (var round = 0; round < 20; round++) {
      final answer = await client.call(to.url,
          key: readKey,
          keyId: 'r',
          op: 'live',
          body: {'c': cursor, 'd': sheetDayText(clock())});
      for (final row in (answer['r'] as List? ?? const [])) {
        if (row is! List || row.length < 8) continue;
        // [id, day, time, ticket, seller, phone, type, total]
        if ('${row[5]}' == myCode) continue; // made on this phone
        final at = _parse('${row[1]}', '${row[2]}');
        if (at == null) continue;
        final isSale = row[6] == 'Vente';
        added += await _add(LiveSalesCompanion.insert(
          id: '${row[0]}',
          at: at,
          ticket: '${row[3]}',
          seller: '${row[4]}',
          kind: isSale ? 'sale' : 'return',
          total: centimesFromSheet(row[7]),
          mine: false,
          notified: Value(first || !isSale || at.isBefore(today)),
        ));
      }
      cursor = (answer['c'] as num?)?.toInt() ?? cursor;
      await settings.set(SheetSettings.liveCursorName, '$cursor');
      if (answer['m'] != true) break;
    }
    await settings.setLiveLastCheck(clock());
    return added;
  }

  Future<int> _add(LiveSalesCompanion row) =>
      db.into(db.liveSales).insert(row, mode: InsertMode.insertOrIgnore);

  static DateTime? _parse(String day, String time) {
    final date = DateTime.tryParse(day);
    if (date == null) return null;
    final parts = time.split(':');
    return DateTime(date.year, date.month, date.day,
        int.tryParse(parts.first) ?? 0,
        parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0);
  }

  /// One notification per new sale made on another phone (or one for all
  /// of them when there are many), unless the owner turned it off.
  Future<void> announce() async {
    final fresh = await (db.select(db.liveSales)
          ..where((l) => l.notified.equals(false))
          ..orderBy([(l) => OrderingTerm.asc(l.at)]))
        .get();
    if (fresh.isEmpty) return;
    await (db.update(db.liveSales)
          ..where((l) => l.id.isIn(fresh.map((f) => f.id))))
        .write(const LiveSalesCompanion(notified: Value(true)));
    if (!settings.liveNotify || !enabled) return;
    final l10n = lookupAppLocalizations(locale());
    final sales = fresh.where((f) => f.kind == 'sale' && !f.mine).toList();
    if (sales.isEmpty) return;
    if (sales.length > maxSingleNotifications) {
      await notifier.show(
        key: 'live:many',
        title: l10n.liveSalesManyTitle(sales.length),
        body: l10n.liveSalesManyBody(
            formatDA(sales.fold(0, (sum, s) => sum + s.total))),
        payload: '|/more/sheet/live',
        channelName: l10n.liveSalesChannel,
        channelId: liveSalesChannelId,
        private: true,
      );
      return;
    }
    for (final sale in sales) {
      await notifier.show(
        key: 'live:${sale.id}',
        title: l10n.liveSaleTitle(sale.ticket),
        body: l10n.liveSaleBody(sale.seller, formatDA(sale.total)),
        payload: '|/more/sheet/live',
        channelName: l10n.liveSalesChannel,
        channelId: liveSalesChannelId,
        private: true,
      );
    }
  }

  /// Looks for new sales everywhere, then announces them. Without
  /// internet, the sheet part is simply skipped.
  Future<void> check({bool withSheet = true}) async {
    await checkLocal();
    if (withSheet) {
      try {
        await checkSheet();
      } on SheetException {
        // No internet or no sheet: the Wi-Fi sales are still shown.
      }
    }
    await announce();
    await prune();
  }

  /// Forgets what is older than a few days.
  Future<void> prune() => (db.delete(db.liveSales)
        ..where((l) => l.at.isSmallerThanValue(
            clock().subtract(const Duration(days: 3)))))
      .go();

  /// Today's sales and returns, newest first.
  Stream<List<LiveSaleRow>> watchToday() => (db.select(db.liveSales)
        ..where((l) => l.at.isBiggerOrEqualValue(startOfDay(clock())))
        ..orderBy([(l) => OrderingTerm.desc(l.at)]))
      .watch();
}
