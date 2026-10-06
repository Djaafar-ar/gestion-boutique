import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/money.dart';

/// A customer's debt: red when they owe, "nothing owed" at zero, and
/// "advance" when the shop owes them.
class DebtText extends StatelessWidget {
  final int debt;
  final double fontSize;

  const DebtText({super.key, required this.debt, this.fontSize = 14});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (text, color) = debt > 0
        ? (formatDAForUi(debt), scheme.error)
        : debt < 0
            ? (l10n.advanceLabel(formatDAForUi(-debt)), scheme.tertiary)
            : (l10n.noDebt, scheme.onSurfaceVariant);
    return Text(text,
        style: TextStyle(
            fontSize: fontSize,
            fontWeight: debt == 0 ? FontWeight.normal : FontWeight.bold,
            color: color));
  }
}
