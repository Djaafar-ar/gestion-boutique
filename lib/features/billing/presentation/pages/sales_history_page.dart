import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sale_repository.dart';

/// All saved sales, newest first, grouped by day.
class SalesHistoryPage extends StatefulWidget {
  const SalesHistoryPage({super.key});

  @override
  State<SalesHistoryPage> createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends State<SalesHistoryPage> {
  late Future<List<Sale>> _sales = _load();

  Future<List<Sale>> _load() async {
    final result = await sl<SaleRepository>().getSales();
    return result.fold((failure) => throw failure.message, (sales) => sales);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: FutureBuilder<List<Sale>>(
        future: _sales,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return EmptyState(
              icon: Icons.error_outline,
              title: l10n.errorWithDetail('${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final sales = snapshot.data!;
          if (sales.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: l10n.historyEmptyTitle,
              message: l10n.historyEmptyBody,
            );
          }

          final days = <DateTime, List<Sale>>{};
          for (final sale in sales) {
            days.putIfAbsent(startOfDay(sale.createdAt), () => []).add(sale);
          }

          return RefreshIndicator(
            onRefresh: () async {
              final next = _load();
              setState(() => _sales = next);
              await next;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                for (final day in days.entries) ...[
                  _DayHeader(day: day.key, sales: day.value),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (final (index, sale) in day.value.indexed) ...[
                          if (index > 0) const Divider(),
                          _SaleTile(sale: sale),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final DateTime day;
  final List<Sale> sales;

  const _DayHeader({required this.day, required this.sales});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final today = startOfDay(DateTime.now());
    final label = day == today
        ? l10n.today
        : day == today.subtract(const Duration(days: 1))
            ? l10n.yesterday
            : formatDate(day);
    final total = sales.fold<int>(0, (sum, s) => sum + s.total);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label · ${l10n.salesCount(sales.length)}',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant),
            ),
          ),
          Text(formatDAForUi(total),
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: scheme.primary)),
        ],
      ),
    );
  }
}

class _SaleTile extends StatelessWidget {
  final Sale sale;

  const _SaleTile({required this.sale});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: scheme.secondaryContainer,
        foregroundColor: scheme.onSecondaryContainer,
        child: const Icon(Icons.receipt_outlined, size: 20),
      ),
      title: Text(l10n.saleTitle(sale.number),
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
          '${formatTime(sale.createdAt)} · ${l10n.itemCount(sale.itemCount)}'),
      trailing: Text(formatDAForUi(sale.total),
          style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: () => context.push('/sell/history/${sale.id}'),
    );
  }
}
