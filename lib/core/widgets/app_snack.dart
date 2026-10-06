import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum SnackKind { info, success, error }

/// Shows a short message at the bottom of the screen.
void showAppSnack(BuildContext context, String message,
    {SnackKind kind = SnackKind.info}) {
  final scheme = Theme.of(context).colorScheme;
  final Color? background = switch (kind) {
    SnackKind.success => AppTheme.success,
    SnackKind.error => scheme.error,
    SnackKind.info => null,
  };
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message,
          style: background == null
              ? null
              : TextStyle(
                  color:
                      kind == SnackKind.error ? scheme.onError : Colors.white)),
      backgroundColor: background,
    ));
}
