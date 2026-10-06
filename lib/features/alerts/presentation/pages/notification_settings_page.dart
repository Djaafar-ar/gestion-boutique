import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/settings/settings_store.dart';
import '../../data/phone_notifier.dart';
import '../../domain/alert.dart';
import '../../domain/alert_text.dart';
import '../alerts_cubit.dart';

/// Owner only: which alerts also ring as phone notifications on this
/// phone. The Alertes tab always shows everything.
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late Future<bool> _allowed = sl<PhoneNotifier>().isAllowed();

  bool _isOn(AlertType type) =>
      sl<SettingsStore>().get(type.settingsKey) != 'false';

  Future<void> _set(AlertType type, bool on) async {
    await context.read<AlertsCubit>().setRings(type, on);
    if (mounted) setState(() {});
  }

  Future<void> _allow() async {
    final notifier = sl<PhoneNotifier>();
    if (!await notifier.requestPermission()) await notifier.openSettings();
    if (mounted) {
      setState(() {
        _allowed = notifier.isAllowed();
      });
    }
  }

  Future<void> _test() async {
    final l10n = AppLocalizations.of(context);
    await sl<PhoneNotifier>().show(
        key: 'test',
        title: l10n.testNotificationTitle,
        body: l10n.testNotificationBody,
        payload: '|/alerts',
        channelName: l10n.notificationChannel);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          FutureBuilder<bool>(
            future: _allowed,
            builder: (context, snapshot) {
              if (snapshot.data != false) return const SizedBox.shrink();
              return Card(
                color: scheme.errorContainer,
                child: ListTile(
                  leading: Icon(Icons.notifications_off_outlined,
                      color: scheme.onErrorContainer),
                  title: Text(l10n.notificationsBlocked,
                      style: TextStyle(color: scheme.onErrorContainer)),
                  trailing: TextButton(
                      onPressed: _allow, child: Text(l10n.openPhoneSettings)),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Text(l10n.notificationsIntro,
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final (index, type) in AlertType.values.indexed) ...[
                  if (index > 0) const Divider(height: 1),
                  SwitchListTile(
                    secondary: Icon(type.ownerOnly
                        ? Icons.admin_panel_settings_outlined
                        : Icons.groups_outlined),
                    title: Text(alertTypeName(l10n, type)),
                    value: _isOn(type),
                    onChanged: (on) => _set(type, on),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Row(
              children: [
                Icon(Icons.groups_outlined,
                    size: 18, color: scheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n.workersSeeNote,
                      style: TextStyle(
                          fontSize: 13, color: scheme.onSurfaceVariant)),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: _test,
            icon: const Icon(Icons.notifications_active_outlined),
            label: Text(l10n.sendTestNotification),
          ),
        ],
      ),
    );
  }
}
