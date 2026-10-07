import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/money.dart';
import '../../data/cloud_jobs.dart';
import '../../data/daily_report_service.dart';
import '../sheet_cubit.dart';

/// Owner: the evening report (the last one sent, or today's so far).
class DailyReportPage extends StatefulWidget {
  const DailyReportPage({super.key});

  @override
  State<DailyReportPage> createState() => _DailyReportPageState();
}

class _DailyReportPageState extends State<DailyReportPage> {
  DailyReport? _now;
  bool _loading = false;

  Future<void> _today() async {
    setState(() => _loading = true);
    final report = await sl<CloudJobs>().report.build(DateTime.now());
    if (!mounted) return;
    setState(() {
      _now = report;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final last = context.watch<SheetCubit>().state.lastReport;
    final report = _now ?? last;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dailyReportLabel)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (report == null)
            Text(l10n.dailyReportNone)
          else
            _ReportCard(report: report),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _loading ? null : _today,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh),
            label: Text(l10n.dailyReportToday),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final DailyReport report;
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    Widget line(String label, String value, {bool strong = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            Expanded(child: Text(label)),
            Text(value,
                style: TextStyle(
                    fontWeight: strong ? FontWeight.bold : FontWeight.w500,
                    fontSize: strong ? 18 : null)),
          ]),
        );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.dailyReportTitle(formatDate(report.day)),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            line(l10n.reportSales, '${report.sales}'),
            line(l10n.reportRevenue, formatDAForUi(report.revenue),
                strong: true),
            line(l10n.reportProfit, formatDAForUi(report.profit)),
            line(l10n.reportCash, formatDAForUi(report.cash)),
            line(l10n.reportReturns, formatDAForUi(report.returns)),
            const SizedBox(height: 8),
            Text(
                report.source == 'sheet'
                    ? l10n.reportFromSheet
                    : l10n.reportFromPhone,
                style:
                    TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
