import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';

/// Shows the owner's recovery code ONCE. It cannot be closed until the
/// person ticks "I wrote this code down".
Future<void> showRecoveryCode(BuildContext context, String code,
    {bool replacedOld = false}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _RecoveryCodeDialog(code: code, replacedOld: replacedOld),
  );
}

class _RecoveryCodeDialog extends StatefulWidget {
  final String code;
  final bool replacedOld;

  const _RecoveryCodeDialog({required this.code, required this.replacedOld});

  @override
  State<_RecoveryCodeDialog> createState() => _RecoveryCodeDialogState();
}

class _RecoveryCodeDialogState extends State<_RecoveryCodeDialog> {
  bool _noted = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      child: AlertDialog(
        icon: Icon(Icons.key, color: scheme.primary),
        title: Text(l10n.recoveryShowTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.replacedOld) ...[
                Text(l10n.recoveryOldCodeUsed,
                    style: TextStyle(color: scheme.error)),
                const SizedBox(height: 12),
              ],
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                // The code reads left-to-right in every language.
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: SelectableText(
                    widget.code,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(l10n.recoveryShowBody),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _noted,
                title: Text(l10n.recoveryNoted),
                onChanged: (value) => setState(() => _noted = value ?? false),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(120, 44)),
            onPressed: _noted ? () => Navigator.pop(context) : null,
            child: Text(l10n.continueLabel),
          ),
        ],
      ),
    );
  }
}
