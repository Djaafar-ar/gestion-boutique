import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Asks before merging [from] into [into]: [body] explains what moves.
Future<bool> confirmMerge(BuildContext context,
    {required String into, required String body}) async {
  final l10n = AppLocalizations.of(context);
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.mergeTitle(into)),
          content: Text(body),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.commonCancel)),
            FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(l10n.merge)),
          ],
        ),
      ) ??
      false;
}
