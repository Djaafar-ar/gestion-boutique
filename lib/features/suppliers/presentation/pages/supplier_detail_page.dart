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
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../widgets/supplier_widgets.dart';

typedef _SupplierData = (
  Supplier,
  List<SupplierPayment>,
  List<SupplierDelivery>
);

/// One supplier: delivered, paid, pending, left to pay, and the lists
/// of payments and deliveries.
class SupplierDetailPage extends StatefulWidget {
  final String supplierId;

  const SupplierDetailPage({super.key, required this.supplierId});

  @override
  State<SupplierDetailPage> createState() => _SupplierDetailPageState();
}

class _SupplierDetailPageState extends State<SupplierDetailPage> {
  late Future<_SupplierData> _data = _load();

  Future<_SupplierData> _load() async {
    final repo = sl<SupplierRepository>();
    final id = widget.supplierId;
    return (
      (await repo.getSupplier(id)).getOrElse((f) => throw f.message),
      (await repo.getPayments(supplierId: id))
          .getOrElse((f) => throw f.message),
      (await repo.getDeliveries(id)).getOrElse((f) => throw f.message),
    );
  }

  void _reload() => setState(() {
        _data = _load();
      });

  Future<void> _pay(Supplier supplier) async {
    final l10n = AppLocalizations.of(context);
    final isOwner = context.read<SessionCubit>().state.isOwner;
    final result = await showAmountDialog(
      context,
      title: l10n.recordSupplierPayment,
      subtitle: supplier.name,
      notice: isOwner ? null : l10n.workerPaymentNotice,
    );
    if (result == null || !mounted) return;
    final saved = await sl<SupplierRepository>().recordPayment(
        supplierId: supplier.id, amount: result.amount, note: result.note);
    if (!mounted) return;
    saved.fold(
      (failure) => showAppSnack(context, l10n.errorWithDetail(failure.message),
          kind: SnackKind.error),
      (payment) => showAppSnack(
          context,
          payment.status == PaymentStatus.pending
              ? l10n.paymentPendingSaved
              : l10n.paymentSaved,
          kind: SnackKind.success),
    );
    _reload();
  }

  Future<void> _edit(Supplier supplier) async {
    await context.push('/suppliers/${supplier.id}/edit', extra: supplier);
    if (mounted) _reload();
  }

  Future<void> _archive(Supplier supplier) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.archiveTitle(supplier.name)),
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
    await sl<SupplierRepository>().setArchived(supplier.id, true);
    if (!mounted) return;
    showAppSnack(context, l10n.archivedDone, kind: SnackKind.success);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isOwner = context.watch<SessionCubit>().state.isOwner;

    return FutureBuilder<_SupplierData>(
      future: _data,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final supplier = data?.$1;
        return Scaffold(
          appBar: AppBar(
            title: Text(supplier?.name ?? ''),
            actions: [
              if (supplier != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: l10n.editSupplier,
                  onPressed: () => _edit(supplier),
                ),
              if (supplier != null && isOwner)
                PopupMenuButton<void>(
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      onTap: () => _archive(supplier),
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
                                Text(l10n.leftToPayLabel,
                                    style: TextStyle(
                                        color: scheme.onSurfaceVariant)),
                                const SizedBox(height: 4),
                                SupplierBalanceText(
                                    balance: supplier!.balance, fontSize: 28),
                                const SizedBox(height: 12),
                                _Row(l10n.deliveredLabel, supplier.delivered),
                                _Row(l10n.paidValidatedLabel, supplier.paid),
                                if (supplier.pending > 0)
                                  _Row(l10n.statusPending, supplier.pending,
                                      color: Colors.orange.shade800),
                                if (supplier.phone.isNotEmpty ||
                                    supplier.note != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                      [
                                        if (supplier.phone.isNotEmpty)
                                          supplier.phone,
                                        if (supplier.note != null)
                                          supplier.note!,
                                      ].join(' · '),
                                      style: TextStyle(
                                          color: scheme.onSurfaceVariant)),
                                ],
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                    onPressed: () => _pay(supplier),
                                    icon: const Icon(Icons.payments_outlined),
                                    label: Text(l10n.recordSupplierPayment),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(l10n.paymentsSection,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        if (data.$2.isEmpty)
                          _Empty(l10n.noPayments)
                        else
                          Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                for (final (index, p) in data.$2.indexed) ...[
                                  if (index > 0) const Divider(height: 1),
                                  PaymentTile(payment: p),
                                ],
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        Text(l10n.deliveriesSection,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        if (data.$3.isEmpty)
                          _Empty(l10n.noDeliveries)
                        else
                          Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                for (final (index, d) in data.$3.indexed) ...[
                                  if (index > 0) const Divider(height: 1),
                                  ListTile(
                                    title: Text(d.productName),
                                    subtitle: Text([
                                      '${d.quantity} × ${formatDAForUi(d.buyPrice)}',
                                      d.receivedByName == null
                                          ? l10n.receivedOn(
                                              formatDate(d.receivedAt))
                                          : l10n.receivedBy(
                                              formatDate(d.receivedAt),
                                              d.receivedByName!),
                                    ].join('\n')),
                                    trailing: Text(formatDAForUi(d.total),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                  ),
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

/// One supplier payment: amount, status, who paid and who decided.
class PaymentTile extends StatelessWidget {
  final SupplierPayment payment;
  final bool showSupplier;
  final Widget? actions;

  const PaymentTile(
      {super.key,
      required this.payment,
      this.showSupplier = false,
      this.actions});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = payment;
    final decidedBy = p.validatedByName;
    final details = [
      [
        formatDateTime(p.createdAt),
        if (p.paidByName != null) l10n.paidBy(p.paidByName!),
      ].join(' · '),
      if (decidedBy != null && p.status == PaymentStatus.validated)
        l10n.validatedBy(decidedBy),
      if (decidedBy != null && p.status == PaymentStatus.rejected)
        l10n.rejectedBy(decidedBy),
      if (p.note != null) p.note!,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  showSupplier ? p.supplierName : formatDAForUi(p.amount),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              if (showSupplier)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: Text(formatDAForUi(p.amount),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              PaymentStatusChip(status: p.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(details.join('\n'),
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          if (actions != null) ...[const SizedBox(height: 8), actions!],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final int amount;
  final Color? color;

  const _Row(this.label, this.amount, {this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: color))),
          Text(formatDAForUi(amount),
              style: TextStyle(fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(text,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}
