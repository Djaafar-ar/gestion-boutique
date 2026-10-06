import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/app_shell.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/money.dart';
import '../../../stock/domain/entities/loss.dart';
import '../../../stock/presentation/pages/record_loss_page.dart';
import '../../../users/domain/repositories/user_repository.dart';
import '../../data/stats_repository.dart';
import '../../domain/stats.dart';
import '../stats_cubit.dart';
import '../widgets/stats_charts.dart';

/// The Stats tab. The owner sees everyone (or picks one person); a worker
/// only sees their own figures, without buying prices and profit.
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StatsCubit(
        repository: sl<StatsRepository>(),
        users: sl<UserRepository>(),
        session: context.read<SessionCubit>(),
      )..start(),
      child: const _StatsView(),
    );
  }
}

class _StatsView extends StatefulWidget {
  const _StatsView();

  @override
  State<_StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<_StatsView> {
  /// Index of the Stats tab.
  static const _statsTab = 2;

  @override
  void initState() {
    super.initState();
    currentTabIndex.addListener(_onTab);
  }

  @override
  void dispose() {
    currentTabIndex.removeListener(_onTab);
    super.dispose();
  }

  /// New sales may have been made since: reload when the tab opens.
  void _onTab() {
    if (currentTabIndex.value == _statsTab) context.read<StatsCubit>().load();
  }

  Future<void> _pickRange(StatsState state) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: DateTimeRange(
          start: state.from,
          end: state.to.subtract(const Duration(days: 1)).isAfter(now)
              ? now
              : state.to.subtract(const Duration(days: 1))),
    );
    if (picked != null && mounted) {
      await context.read<StatsCubit>().setRange(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isOwner = context.watch<SessionCubit>().state.isOwner;
    final state = context.watch<StatsCubit>().state;
    final stats = state.stats;
    final lastDay = state.to.subtract(const Duration(days: 1));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statsTitle)),
      body: RefreshIndicator(
        onRefresh: () => context.read<StatsCubit>().load(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final (period, label) in [
                  (StatsPeriod.today, l10n.today),
                  (StatsPeriod.week, l10n.periodWeek),
                  (StatsPeriod.month, l10n.periodMonth),
                ])
                  ChoiceChip(
                    label: Text(label),
                    selected: state.period == period,
                    onSelected: (_) =>
                        context.read<StatsCubit>().setPeriod(period),
                  ),
                ChoiceChip(
                  avatar: const Icon(Icons.date_range, size: 18),
                  label: Text(l10n.periodCustom),
                  selected: state.period == StatsPeriod.custom,
                  onSelected: (_) => _pickRange(state),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    state.from == startOfDay(lastDay)
                        ? formatDate(state.from)
                        : '${formatDate(state.from)} – ${formatDate(lastDay)}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (isOwner)
                  DropdownButton<String?>(
                    value: state.userId,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(value: null, child: Text(l10n.everyone)),
                      for (final user in state.users)
                        DropdownMenuItem(
                            value: user.id, child: Text(user.name)),
                    ],
                    onChanged: (id) => context.read<StatsCubit>().setUser(id),
                  ),
              ],
            ),
            if (!isOwner)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(l10n.myStatsNote,
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ),
            if (state.loading) const LinearProgressIndicator(),
            const SizedBox(height: 8),
            if (stats != null)
              ..._content(context, l10n, stats, isOwner, state),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, AppLocalizations l10n,
      Stats stats, bool isOwner, StatsState state) {
    final scheme = Theme.of(context).colorScheme;
    final everyone = state.userId == null;
    return [
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.9,
        children: [
          _Kpi(Icons.payments_outlined, l10n.statRevenue,
              formatDAForUi(stats.revenue)),
          if (isOwner)
            _Kpi(Icons.trending_up, l10n.statProfit,
                formatDAForUi(stats.netProfit),
                color: stats.netProfit < 0 ? scheme.error : null),
          _Kpi(Icons.receipt_long_outlined, l10n.statSales,
              '${stats.salesCount}'),
          _Kpi(Icons.shopping_basket_outlined, l10n.statAverageTicket,
              formatDAForUi(stats.averageTicket)),
          _Kpi(
              Icons.inventory_2_outlined, l10n.statItems, '${stats.itemsSold}'),
          _Kpi(Icons.sell_outlined, l10n.statDiscounts,
              formatDAForUi(stats.discounts)),
          _Kpi(Icons.assignment_return_outlined, l10n.statReturns,
              formatDAForUi(stats.refunds),
              note: l10n.returnsCountSub(stats.returnsCount)),
          _Kpi(Icons.trending_down, l10n.statLossesValue,
              formatDAForUi(stats.lossesValue),
              color: stats.lossesValue > 0 ? scheme.error : null),
        ],
      ),
      const SizedBox(height: 12),
      _Section(
        title: stats.byMonth ? l10n.revenuePerMonth : l10n.revenuePerDay,
        child: stats.salesCount == 0 && stats.refunds == 0
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: Text(l10n.noSalesPeriod),
              )
            : RevenueBarChart(days: stats.perDay, byMonth: stats.byMonth),
      ),
      if (isOwner)
        _Section(
          title: l10n.statProfit,
          child: Column(
            children: [
              _Line(l10n.statRevenue, stats.revenue),
              _Line(l10n.costLabel, -stats.cost),
              const Divider(),
              _Line(l10n.grossProfitLabel, stats.profit, bold: true),
              _Line(l10n.stockLossesLabel, -stats.stockLosses),
              const Divider(),
              _Line(l10n.netProfitLabel, stats.netProfit, bold: true),
            ],
          ),
        ),
      if (isOwner && everyone && stats.perWorker.isNotEmpty)
        _Section(
          title: l10n.salesPerWorker,
          child: Column(
            children: [
              for (final worker in stats.perWorker)
                ShareBar(
                  label: worker.name.isEmpty ? l10n.unknownUser : worker.name,
                  amount: worker.revenue,
                  highest: stats.perWorker.first.revenue,
                  detail: l10n.workerLine(
                      worker.salesCount,
                      formatDAForUi(worker.discounts),
                      formatDAForUi(worker.collected)),
                ),
            ],
          ),
        ),
      _Section(
        title: l10n.cashSection,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Line(l10n.paidAtCounterLabel, stats.paidAtCounter),
            _Line(l10n.customerPaymentsLabel, stats.customerPayments),
            _Line(l10n.cashRefundsLabel, -stats.cashRefunds),
            const Divider(),
            _Line(l10n.cashInHandLabel, stats.cashInHand, bold: true),
            if (stats.supplierPaid > 0) ...[
              const SizedBox(height: 8),
              Text(l10n.supplierPaidLabel(formatDAForUi(stats.supplierPaid)),
                  style:
                      TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            ],
          ],
        ),
      ),
      _Section(
        title: l10n.creditStatsSection,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LegendPieChart(slices: [
              (
                label: l10n.cashSalesLabel,
                amount: stats.paidAtCounter,
                color: scheme.primary
              ),
              (
                label: l10n.onCreditLabel,
                amount: stats.onCredit,
                color: Colors.orange
              ),
            ]),
            if (stats.salesTotal > 0) const SizedBox(height: 8),
            _Line(l10n.customerPaymentsLabel, stats.customerPayments),
            if (isOwner) ...[
              _Line(l10n.totalOwedByCustomers, stats.totalOwed, bold: true),
              if (stats.topDebtors.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(l10n.topDebtors,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                for (final (name, debt) in stats.topDebtors)
                  _Line(name, debt, color: scheme.error),
              ],
            ],
          ],
        ),
      ),
      if (stats.lossesValue > 0)
        _Section(
          title: l10n.lossesByReason,
          child: LegendPieChart(slices: [
            for (final (index, reason) in LossReason.values.indexed)
              (
                label: lossReasonLabel(l10n, reason),
                amount: stats.lossesByReason[reason] ?? 0,
                color: _palette(scheme)[index % 5],
              ),
          ]),
        ),
      if (stats.topProducts.isNotEmpty)
        _Section(
          title: l10n.topProducts,
          child: Column(
            children: [
              for (final product in stats.topProducts)
                ShareBar(
                  label: product.name,
                  amount: product.amount,
                  highest: stats.topProducts.first.amount,
                  detail: l10n.productSoldQty(product.quantity),
                ),
            ],
          ),
        ),
    ];
  }

  List<Color> _palette(ColorScheme scheme) => [
        scheme.error,
        Colors.orange,
        scheme.tertiary,
        scheme.primary,
        scheme.outline,
      ];
}

class _Kpi extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? note;
  final Color? color;

  const _Kpi(this.icon, this.label, this.value, {this.note, this.color});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: scheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12, color: scheme.onSurfaceVariant)),
                ),
              ],
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(value,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ),
            if (note != null)
              Text(note!,
                  style:
                      TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      );
}

/// A label and an amount on one line.
class _Line extends StatelessWidget {
  final String label;
  final int amount;
  final bool bold;
  final Color? color;

  const _Line(this.label, this.amount, {this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
        fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: color);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(formatDAForUi(amount), style: style),
        ],
      ),
    );
  }
}
