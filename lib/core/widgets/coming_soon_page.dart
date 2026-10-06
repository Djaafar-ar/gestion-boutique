import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'empty_state.dart';

enum _Section { stats, alerts }

/// Placeholder for the tabs that are built in later phases.
class ComingSoonPage extends StatelessWidget {
  final _Section _section;

  const ComingSoonPage.stats({super.key}) : _section = _Section.stats;
  const ComingSoonPage.alerts({super.key}) : _section = _Section.alerts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (title, message, icon) = switch (_section) {
      _Section.stats => (l10n.navStats, l10n.comingSoonStats, Icons.insights),
      _Section.alerts => (
          l10n.navAlerts,
          l10n.comingSoonAlerts,
          Icons.notifications_none
        ),
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyState(
        icon: icon,
        title: l10n.comingSoonTitle,
        message: message,
      ),
    );
  }
}
