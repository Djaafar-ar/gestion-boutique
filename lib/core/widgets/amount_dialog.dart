import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../utils/money.dart';

/// What [showAmountDialog] returns: an amount in centimes and a note.
typedef AmountAndNote = ({int amount, String note});

/// Asks for an amount of money (and an optional note). [max] (centimes)
/// refuses anything above it with [tooHigh]. [notice] is shown above the
/// field, for example "the owner will validate this payment".
///
/// The dialog owns its text controllers, so they are only thrown away
/// once it has fully closed.
Future<AmountAndNote?> showAmountDialog(
  BuildContext context, {
  required String title,
  String? subtitle,
  String? notice,
  int? max,
  String Function(int max)? tooHigh,
}) {
  return showDialog<AmountAndNote>(
    context: context,
    builder: (_) => _AmountDialog(
        title: title,
        subtitle: subtitle,
        notice: notice,
        max: max,
        tooHigh: tooHigh),
  );
}

class _AmountDialog extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? notice;
  final int? max;
  final String Function(int max)? tooHigh;

  const _AmountDialog(
      {required this.title,
      this.subtitle,
      this.notice,
      this.max,
      this.tooHigh});

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = AppLocalizations.of(context);
    final amount = parseDA(_amount.text);
    if (amount == null || amount <= 0) {
      setState(() => _error = l10n.amountInvalid);
      return;
    }
    final max = widget.max;
    if (max != null && amount > max) {
      setState(() => _error = widget.tooHigh?.call(max) ?? l10n.amountInvalid);
      return;
    }
    Navigator.pop<AmountAndNote>(
        context, (amount: amount, note: _note.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.subtitle != null) ...[
              Text(widget.subtitle!,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
            ],
            if (widget.notice != null) ...[
              Text(widget.notice!,
                  style: TextStyle(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _amount,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.paymentAmountLabel,
                hintText: '0,00',
                suffixText: 'DA',
                errorText: _error,
                errorMaxLines: 2,
              ),
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              decoration: InputDecoration(labelText: l10n.noteOptional),
              onSubmitted: (_) => _save(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel)),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(88, 40)),
          onPressed: _save,
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
