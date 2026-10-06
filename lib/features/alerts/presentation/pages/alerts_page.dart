import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/alert.dart';
import '../../domain/alert_text.dart';
import '../alerts_cubit.dart';

/// The Alertes tab: unread alerts first, then the ones already read.
/// Tapping an alert marks it read and opens the page that deals with it.
class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<AlertsCubit>().state;
    final unread = state.alerts.where((a) => !a.read).toList();
    final read = state.alerts.where((a) => a.read).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.alertsTitle),
        actions: [
          if (unread.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: l10n.markAllRead,
              onPressed: () => context.read<AlertsCubit>().markAllRead(),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AlertsCubit>().check(),
        child: state.alerts.isEmpty
            ? ListView(
                children: [
                  SizedBox(
                    height: 400,
                    child: EmptyState(
                        icon: Icons.notifications_none,
                        title: l10n.alertsEmpty),
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  if (unread.isNotEmpty) ...[
                    _Header(l10n.alertsUnread(unread.length)),
                    for (final alert in unread) _AlertCard(alert: alert),
                  ],
                  if (read.isNotEmpty) ...[
                    _Header(l10n.alertsReadSection),
                    for (final alert in read) _AlertCard(alert: alert),
                  ],
                ],
              ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
        child: Text(text.toUpperCase(),
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary)),
      );
}

class _AlertCard extends StatelessWidget {
  final Alert alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = describeAlert(l10n, alert.type, alert.data);
    final (background, foreground) = switch (text.level) {
      AlertLevel.urgent => (scheme.errorContainer, scheme.onErrorContainer),
      AlertLevel.warning => (
          Colors.orange.withValues(alpha: 0.2),
          Colors.orange.shade900
        ),
      AlertLevel.info => (scheme.primaryContainer, scheme.onPrimaryContainer),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: alert.read ? null : scheme.surfaceContainerHigh,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: background,
          foregroundColor: foreground,
          child: Icon(text.icon, size: 20),
        ),
        title: Text(text.title,
            style: TextStyle(
                fontWeight: alert.read ? FontWeight.normal : FontWeight.bold)),
        subtitle: Text('${text.body}\n${formatDateTime(alert.createdAt)}'),
        isThreeLine: true,
        trailing: alert.read
            ? null
            : IconButton(
                icon: const Icon(Icons.check_circle_outline),
                tooltip: l10n.markRead,
                onPressed: () => context.read<AlertsCubit>().markRead(alert.id),
              ),
        onTap: () {
          context.read<AlertsCubit>().markRead(alert.id);
          context.push(text.route);
        },
      ),
    );
  }
}
