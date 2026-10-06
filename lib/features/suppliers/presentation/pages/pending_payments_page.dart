import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_snack.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';
import 'supplier_detail_page.dart';

/// Owner only: supplier payments made by workers, to validate or reject.
class PendingPaymentsPage extends StatefulWidget {
  const PendingPaymentsPage({super.key});

  @override
  State<PendingPaymentsPage> createState() => _PendingPaymentsPageState();
}

class _PendingPaymentsPageState extends State<PendingPaymentsPage> {
  late Future<List<SupplierPayment>> _payments = _load();

  Future<List<SupplierPayment>> _load() async => (await sl<SupplierRepository>()
          .getPayments(status: PaymentStatus.pending))
      .getOrElse((_) => []);

  Future<void> _validate(SupplierPayment payment) async {
    final l10n = AppLocalizations.of(context);
    final result = await sl<SupplierRepository>().validatePayment(payment.id);
    if (!mounted) return;
    result.fold(
      (failure) => showAppSnack(context, l10n.errorWithDetail(failure.message),
          kind: SnackKind.error),
      (_) =>
          showAppSnack(context, l10n.paymentValidated, kind: SnackKind.success),
    );
    setState(() {
      _payments = _load();
    });
  }

  Future<void> _reject(SupplierPayment payment) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.rejectPaymentTitle),
        content: Text(l10n.rejectPaymentBody(
            formatDAForUi(payment.amount), payment.supplierName)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.commonCancel)),
          FilledButton.tonal(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.reject)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final result = await sl<SupplierRepository>().rejectPayment(payment.id);
    if (!mounted) return;
    result.fold(
      (failure) => showAppSnack(context, l10n.errorWithDetail(failure.message),
          kind: SnackKind.error),
      (_) => showAppSnack(context, l10n.paymentRejected),
    );
    setState(() {
      _payments = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pendingPaymentsTitle)),
      body: FutureBuilder<List<SupplierPayment>>(
        future: _payments,
        builder: (context, snapshot) {
          final payments = snapshot.data;
          if (payments == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (payments.isEmpty) {
            return EmptyState(
                icon: Icons.task_alt, title: l10n.noPendingPayments);
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final payment in payments)
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: PaymentTile(
                    payment: payment,
                    showSupplier: true,
                    actions: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _reject(payment),
                            icon: const Icon(Icons.close),
                            label: Text(l10n.reject),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _validate(payment),
                            icon: const Icon(Icons.check),
                            label: Text(l10n.validate),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
