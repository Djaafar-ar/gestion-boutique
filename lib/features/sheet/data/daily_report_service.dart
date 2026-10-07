import 'dart:convert';
import 'dart:ui';

import 'package:equatable/equatable.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/settings/settings_store.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/money.dart';
import '../../alerts/data/phone_notifier.dart';
import '../../stats/data/stats_repository.dart';
import '../../sync/data/sync_settings.dart';
import 'sheet_client.dart';
import 'sheet_protocol.dart';
import 'sheet_service.dart';
import 'sheet_settings.dart';

/// The figures of one day, as sent to the owner in the evening.
class DailyReport extends Equatable {
  final DateTime day;
  final int sales;
  final int revenue; // centimes, after discounts and returns
  final int profit;
  final int cash; // "Argent en caisse"
  final int returns;

  /// Where the figures come from: 'sheet' (every phone that had internet)
  /// or 'phone' (this phone's database, after Wi-Fi sync).
  final String source;

  const DailyReport({
    required this.day,
    required this.sales,
    required this.revenue,
    required this.profit,
    required this.cash,
    required this.returns,
    required this.source,
  });

  Map<String, Object?> toJson() => {
        'day': day.toIso8601String(),
        'sales': sales,
        'revenue': revenue,
        'profit': profit,
        'cash': cash,
        'returns': returns,
        'source': source,
      };

  static DailyReport? fromJson(String? text) {
    if (text == null) return null;
    try {
      final data = jsonDecode(text) as Map;
      return DailyReport(
        day: DateTime.parse(data['day'] as String),
        sales: data['sales'] as int,
        revenue: data['revenue'] as int,
        profit: data['profit'] as int,
        cash: data['cash'] as int,
        returns: data['returns'] as int,
        source: data['source'] as String,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props =>
      [day, sales, revenue, profit, cash, returns, source];
}

/// Owner's phone: every evening (21:00 unless changed), a notification
/// with the day's sales, revenue, profit, cash and returns.
class DailyReportService {
  final SettingsStore settings;
  final StatsRepository stats;
  final SheetService sheet;
  final SheetClient client;
  final PhoneNotifier notifier;
  final Locale Function() locale;
  final DateTime Function() clock;

  DailyReportService({
    required this.settings,
    required this.stats,
    required this.sheet,
    required this.client,
    required this.notifier,
    required this.locale,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  /// Never on a worker phone: profit stays with the owner.
  bool get enabled =>
      settings.syncRole != SyncRole.worker && settings.dailyReportOn;

  /// Today's report time.
  DateTime timeOn(DateTime day) {
    final time = settings.dailyReportTime;
    return DateTime(day.year, day.month, day.day, time.hour, time.minute);
  }

  /// The next report time from [now].
  DateTime nextRun(DateTime now) {
    final today = timeOn(now);
    return now.isBefore(today)
        ? today
        : timeOn(DateTime(now.year, now.month, now.day + 1));
  }

  /// The report time has passed today and the report was not sent yet.
  Future<bool> isDue() async {
    if (!enabled) return false;
    final now = clock();
    if (now.isBefore(timeOn(now))) return false;
    await settings.reload([SheetSettings.dailyLastName]);
    return settings.get(SheetSettings.dailyLastName) != sheetDayText(now);
  }

  /// The figures of [day]: from the phone, and from the sheet when it can
  /// be read. The one that knows more sales wins (the sheet has the
  /// phones on mobile data, this phone has those synced by Wi-Fi).
  Future<DailyReport> build(DateTime day) async {
    final from = startOfDay(day);
    final local = await stats.getStats(
        from: from, to: DateTime(from.year, from.month, from.day + 1));
    final phone = DailyReport(
      day: from,
      sales: local.salesCount,
      revenue: local.revenue,
      profit: local.profit,
      cash: local.cashInHand,
      returns: local.refunds,
      source: 'phone',
    );
    final to = await sheet.target();
    final readKey = settings.sheetReadKey;
    if (to == null || readKey == null || !sheet.canRead) return phone;
    try {
      final answer = await client.call(to.url,
          key: readKey,
          keyId: 'r',
          op: 'summary',
          body: {'d': sheetDayText(from)});
      final fromSheet = DailyReport(
        day: from,
        sales: (answer['sales'] as num? ?? 0).toInt(),
        revenue: centimesFromSheet(answer['revenue']),
        profit: centimesFromSheet(answer['profit']),
        cash: centimesFromSheet(answer['cash']),
        returns: centimesFromSheet(answer['returns']),
        source: 'sheet',
      );
      return fromSheet.sales > phone.sales ? fromSheet : phone;
    } on SheetException {
      return phone;
    }
  }

  /// Sends today's report when it is time. The phone's queue goes first,
  /// so the sheet has this phone's sales too.
  Future<DailyReport?> runIfDue() async {
    if (!await isDue()) return null;
    try {
      await sheet.sendNow();
    } on SheetException {
      // Not set up or no internet: the phone's figures are used.
    }
    final now = clock();
    final report = await build(now);
    await settings.set(SheetSettings.dailyLastName, sheetDayText(now));
    await settings.set(
        SheetSettings.dailyReportName, jsonEncode(report.toJson()));
    await show(report);
    return report;
  }

  Future<void> show(DailyReport report) async {
    final l10n = lookupAppLocalizations(locale());
    await notifier.show(
      key: 'daily-report',
      title: l10n.dailyReportTitle(formatDate(report.day)),
      body: l10n.dailyReportBody(
        report.sales,
        formatDA(report.revenue),
        formatDA(report.profit),
        formatDA(report.cash),
        formatDA(report.returns),
      ),
      payload: '|/more/sheet/report',
      channelName: l10n.dailyReportChannel,
      channelId: dailyReportChannelId,
      private: true,
    );
  }

  /// The last report sent (for the report page).
  DailyReport? get last =>
      DailyReport.fromJson(settings.get(SheetSettings.dailyReportName));
}
