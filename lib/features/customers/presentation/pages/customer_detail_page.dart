import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/amount_dialog.dart';
import '../../../../core/widgets/app_snack.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../widgets/debt_text.dart';

/// One customer: what they owe, their limit, and every credit sale,
/// return and payment with who recorded it.
class CustomerDetailPage extends StatefulWidget {
  final String customerId;

  const CustomerDetailPage({super.key, required this.customerId});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  late Future<(Customer, List<CustomerEntry>)> _data = _load();

  Future<(Customer, List<CustomerEntry>)> _load() async {
    final repo = sl<CustomerRepository>();
    final customer = (await repo.getCustomer(widget.customerId))
        .getOrElse((f) => throw f.message);
    final history = (await repo.getHistory(widget.customerId))
        .getOrElse((f) => throw f.message);
    return (customer, history);
  }

  void _reload() => setState(() {
        _data = _load();
      });

  Future<void> _receivePayment(Customer customer) async {
    final l10n = AppLocalizations.of(context);
    final result = await showAmountDialog(
      context,
      title: l10n.receivePayment,
      subtitle:
          '${customer.name} · ${l10n.currentDebt(formatDA(customer.debt))}',
      max: customer.debt,
      tooHigh: (max) => l10n.paymentTooHigh(formatDA(max)),
    );
    if (result == null || !mounted) return;
    final saved = await sl<CustomerRepository>().recordPayment(
        customerId: customer.id, amount: result.amount, note: result.note);
    if (!mounted) return;
    saved.fold(
      (failure) => showAppSnack(context, l10n.errorWithDetail(failure.message),
          kind: SnackKind.error),
      (_) => showAppSnack(context, l10n.paymentSaved, kind: SnackKind.success),
    );
    _reload();
  }

  Future<void> _edit(Customer customer) async {
    await context.push('/customers/${customer.id}/edit', extra: customer);
    if (mounted) _reload();
  }

  Future<void> _archive(Customer customer) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.archiveTitle(customer.name)),
        content: Text(l10n.archiveBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.commonCancel)),
          FilledButton.tonal(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.archive)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await sl<CustomerRepository>().setArchived(customer.id, true);
    if (!mounted) return;
    showAppSnack(context, l10n.archivedDone, kind: SnackKind.success);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isOwner = context.watch<SessionCubit>().state.isOwner;

    return FutureBuilder<(Customer, List<CustomerEntry>)>(
      future: _data,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final customer = data?.$1;
        return Scaffold(
          appBar: AppBar(
            title: Text(customer?.name ?? ''),
            actions: [
              if (customer != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: l10n.editCustomer,
                  onPressed: () => _edit(customer),
                ),
              if (customer != null && isOwner)
                PopupMenuButton<void>(
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      onTap: () => _archive(customer),
                      child: Text(l10n.archive),
                    ),
                  ],
                ),
            ],
          ),
          body: snapshot.hasError
              ? EmptyState(
                  icon: Icons.error_outline,
                  title: l10n.errorWithDetail('${snapshot.error}'))
              : data == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.debtLabel,
                                    style: TextStyle(
                                        color: scheme.onSurfaceVariant)),
                                const SizedBox(height: 4),
                                DebtText(debt: customer!.debt, fontSize: 28),
                                const SizedBox(height: 8),
                                Text(
                                  [
                                    if (customer.phone.isNotEmpty)
                                      customer.phone,
                                    if (customer.creditLimit != null)
                                      l10n.creditLimitShort(
                                          formatDAForUi(customer.creditLimit!)),
                                  ].join(' · '),
                                  style:
                                      TextStyle(color: scheme.onSurfaceVariant),
                                ),
                                if (customer.overLimit) ...[
                                  const SizedBox(height: 8),
                                  Chip(
                                    avatar: Icon(Icons.warning_amber_rounded,
                                        color: scheme.error, size: 18),
                                    label: Text(l10n.overLimitBadge),
                                  ),
                                ],
                                if (customer.note != null) ...[
                                  const SizedBox(height: 8),
                                  Text(customer.note!),
                                ],
                                if (customer.debt > 0) ...[
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.icon(
                                      onPressed: () =>
                                          _receivePayment(customer),
                                      icon: const Icon(Icons.payments_outlined),
                                      label: Text(l10n.receivePayment),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(l10n.customerHistory,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        if (data.$2.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(l10n.noHistory,
                                style:
                                    TextStyle(color: scheme.onSurfaceVariant)),
                          )
                        else
                          Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                for (final (index, entry)
                                    in data.$2.indexed) ...[
                                  if (index > 0) const Divider(height: 1),
                                  _EntryTile(entry: entry),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
        );
      },
    );
  }
}

class _EntryTile extends StatelessWidget {
  final CustomerEntry entry;
  const _EntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (icon, title) = switch (entry.kind) {
      CustomerEntryKind.sale => (
          Icons.shopping_bag_outlined,
          l10n.entryCreditSale(entry.saleNumber ?? 0)
        ),
      CustomerEntryKind.payment => (Icons.payments_outlined, l10n.entryPayment),
      CustomerEntryKind.refund => (
          Icons.assignment_return_outlined,
          l10n.entryRefund(entry.saleNumber ?? 0)
        ),
    };
    final details = [
      formatDateTime(entry.at),
      if (entry.byName != null) l10n.recordedBy(entry.byName!),
      if (entry.kind == CustomerEntryKind.sale)
        l10n.entrySaleDetail(formatDAForUi(entry.saleTotal ?? 0),
            formatDAForUi(entry.paidNow ?? 0)),
      if (entry.note != null) entry.note!,
    ];
    final adds = entry.amount > 0;
    return ListTile(
      leading: Icon(icon, color: scheme.primary),
      title: Text(title),
      subtitle: Text(details.join('\n')),
      isThreeLine: details.length > 2,
      trailing: Text(
        '${adds ? '+' : '−'} ${formatDAForUi(entry.amount.abs())}',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: adds ? scheme.error : scheme.tertiary),
      ),
    );
  }
}
