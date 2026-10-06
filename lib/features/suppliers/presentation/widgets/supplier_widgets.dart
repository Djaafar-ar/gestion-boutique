import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/supplier.dart';

/// What the shop owes a supplier: "left to pay", "paid in advance" or
/// "nothing to pay".
class SupplierBalanceText extends StatelessWidget {
  final int balance;
  final double fontSize;

  const SupplierBalanceText(
      {super.key, required this.balance, this.fontSize = 14});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (text, color) = balance > 0
        ? (formatDAForUi(balance), scheme.error)
        : balance < 0
            ? (l10n.supplierAdvance(formatDAForUi(-balance)), scheme.tertiary)
            : (l10n.noDebt, scheme.onSurfaceVariant);
    return Text(text,
        style: TextStyle(
            fontSize: fontSize,
            fontWeight: balance == 0 ? FontWeight.normal : FontWeight.bold,
            color: color));
  }
}

/// A small coloured label: pending (orange), validated (green),
/// rejected (red).
class PaymentStatusChip extends StatelessWidget {
  final PaymentStatus status;
  const PaymentStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (text, background, foreground) = switch (status) {
      PaymentStatus.pending => (
          l10n.statusPending,
          Colors.orange.withValues(alpha: 0.18),
          Colors.orange.shade800
        ),
      PaymentStatus.validated => (
          l10n.statusValidated,
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer
        ),
      PaymentStatus.rejected => (
          l10n.statusRejected,
          scheme.errorContainer,
          scheme.onErrorContainer
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: background, borderRadius: BorderRadius.circular(10)),
      child: Text(text,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: foreground)),
    );
  }
}
