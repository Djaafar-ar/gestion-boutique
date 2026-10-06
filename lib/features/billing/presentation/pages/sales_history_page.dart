import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/session/session_cubit.dart';
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
  late Future<List<Sale>> _sales;
  final _search = TextEditingController();

  /// Only this day, or null for every day.
  DateTime? _day;

  @override
  void initState() {
    super.initState();
    _sales = _load();
  }

  /// The owner sees every sale, a worker only their own.
  Future<List<Sale>> _load() async {
    final session = context.read<SessionCubit>().state;
    final day = _day;
    final result = await sl<SaleRepository>().getSales(
      userId: session.isOwner ? null : session.user?.id,
      number: int.tryParse(_search.text.trim()),
      from: day,
      to: day?.add(const Duration(days: 1)),
    );
    return result.fold((failure) => throw failure.message, (sales) => sales);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reload() => setState(() {
        _sales = _load();
      });

  Future<void> _pickDay() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _day ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked == null) return;
    _day = startOfDay(picked);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filtered = _day != null || _search.text.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_return_outlined),
            tooltip: l10n.noReceiptReturn,
            onPressed: () async {
              await context.push('/sell/return');
              if (mounted) _reload();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: l10n.searchTicketHint,
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (_) => _reload(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: l10n.pickDate,
                  icon: const Icon(Icons.calendar_month),
                  onPressed: _pickDay,
                ),
              ],
            ),
          ),
          if (filtered)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 16),
                child: InputChip(
                  label: Text(_day == null ? l10n.seeAll : formatDate(_day!)),
                  onDeleted: () {
                    _search.clear();
                    _day = null;
                    _reload();
                  },
                ),
              ),
            ),
          Expanded(child: _list(l10n, filtered)),
        ],
      ),
    );
  }

  Widget _list(AppLocalizations l10n, bool filtered) {
    return FutureBuilder<List<Sale>>(
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
            icon: filtered
                ? Icons.search_off_rounded
                : Icons.receipt_long_outlined,
            title: filtered ? l10n.noSaleFound : l10n.historyEmptyTitle,
            message: filtered ? null : l10n.historyEmptyBody,
          );
        }

        final days = <DateTime, List<Sale>>{};
        for (final sale in sales) {
          days.putIfAbsent(startOfDay(sale.createdAt), () => []).add(sale);
        }

        return RefreshIndicator(
          onRefresh: () async {
            final next = _load();
            setState(() {
              _sales = next;
            });
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
        child: Icon(
            sale.isCredit ? Icons.menu_book_outlined : Icons.receipt_outlined,
            size: 20),
      ),
      title: Text(l10n.saleTitle(sale.number),
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text([
        formatTime(sale.createdAt),
        l10n.itemCount(sale.itemCount),
        if (sale.sellerName != null) sale.sellerName!,
        if (sale.isCredit) '${l10n.creditChip} : ${sale.customerName ?? '?'}',
      ].join(' · ')),
      trailing: Text(formatDAForUi(sale.total),
          style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: () => context.push('/sell/history/${sale.id}'),
    );
  }
}
