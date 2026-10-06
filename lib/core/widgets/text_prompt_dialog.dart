import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Asks for one line of text. Returns it, or null if cancelled.
///
/// The dialog owns its text controller, so the controller is only thrown
/// away once the dialog has fully closed (after its closing animation).
/// Disposing it right after `showDialog` returns crashes the app with
/// "_dependents.isEmpty".
Future<String?> showTextPrompt(
  BuildContext context, {
  required String title,
  String? hint,
  required String confirmLabel,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) =>
        _TextPromptDialog(title: title, hint: hint, confirmLabel: confirmLabel),
  );
}

class _TextPromptDialog extends StatefulWidget {
  final String title;
  final String? hint;
  final String confirmLabel;

  const _TextPromptDialog(
      {required this.title, this.hint, required this.confirmLabel});

  @override
  State<_TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<_TextPromptDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: widget.hint),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel)),
        FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(88, 40)),
            onPressed: () => Navigator.pop(context, _controller.text),
            child: Text(widget.confirmLabel)),
      ],
    );
  }
}
