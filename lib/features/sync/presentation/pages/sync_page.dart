import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/app_snack.dart';
import '../../../auth/presentation/widgets/owner_approval_dialog.dart';
import '../../data/sync_protocol.dart';
import '../../data/sync_settings.dart';
import '../sync_cubit.dart';

/// What to tell people when a sync fails.
String syncErrorText(AppLocalizations l10n, SyncError? error) =>
    switch (error) {
      SyncError.unreachable => l10n.syncErrUnreachable,
      SyncError.badSignature => l10n.syncErrSignature,
      SyncError.version => l10n.syncErrVersion,
      SyncError.unknownDevice => l10n.syncErrRemoved,
      _ => l10n.syncErrOther,
    };

/// Plus → Synchronisation Wi-Fi. On the owner's phone: the hub, the code
/// to link a phone and the linked phones. On a worker's phone: when it
/// last synced, and "Sync now".
class SyncPage extends StatelessWidget {
  const SyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<SyncCubit>().state;
    final isOwner = context.watch<SessionCubit>().state.isOwner;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.syncTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: switch (state.role) {
          SyncRole.none => _standalone(context, l10n, isOwner),
          SyncRole.hub => _hub(context, l10n, state, isOwner),
          SyncRole.worker => _worker(context, l10n, state),
        },
      ),
    );
  }

  List<Widget> _standalone(
      BuildContext context, AppLocalizations l10n, bool isOwner) {
    final scheme = Theme.of(context).colorScheme;
    return [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.wifi_tethering, size: 40, color: scheme.primary),
              const SizedBox(height: 8),
              Text(l10n.syncStandaloneTitle,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(l10n.syncStandaloneBody,
                  style: TextStyle(color: scheme.onSurfaceVariant)),
              if (isOwner) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.read<SyncCubit>().startHub(),
                    icon: const Icon(Icons.hub_outlined),
                    label: Text(l10n.becomeHub),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      if (isOwner) ...[
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: Icon(Icons.phonelink_erase, color: scheme.error),
            title: Text(l10n.leaveShop),
            subtitle: Text(l10n.leaveShopSub),
            onTap: () => _erase(context, l10n),
          ),
        ),
      ],
    ];
  }

  Future<void> _erase(BuildContext context, AppLocalizations l10n) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded,
            color: Theme.of(dialogContext).colorScheme.error),
        title: Text(l10n.leaveShop),
        content: Text(l10n.leaveShopBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.commonCancel)),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.leaveShopConfirm),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    // The owner confirms with their PIN: this erases everything.
    final pin = await askOwnerApproval(context);
    if (pin == null || !context.mounted) return;
    await context.read<SyncCubit>().eraseThisPhone();
  }

  List<Widget> _hub(BuildContext context, AppLocalizations l10n,
      SyncState state, bool isOwner) {
    final scheme = Theme.of(context).colorScheme;
    final cubit = context.read<SyncCubit>();
    return [
      Card(
        child: Column(
          children: [
            SwitchListTile(
              secondary: Icon(Icons.hub_outlined,
                  color: state.hubRunning ? scheme.primary : null),
              title: Text(state.hubRunning ? l10n.hubActive : l10n.hubStopped),
              subtitle: state.hubRunning
                  ? Text(state.hubAddress == null
                      ? l10n.hubNoWifi
                      : l10n.hubAddress(state.hubAddress!))
                  : null,
              value: state.hubRunning,
              onChanged: isOwner
                  ? (on) => on ? cubit.startHub() : cubit.stopHub()
                  : null,
            ),
            if (state.hubRunning)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(l10n.hubKeepOpen,
                    style: TextStyle(
                        fontSize: 12, color: scheme.onSurfaceVariant)),
              ),
          ],
        ),
      ),
      if (isOwner && state.hubRunning) ...[
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.qr_code_2),
            title: Text(l10n.pairTitle),
            subtitle: Text(l10n.showPairingCode),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCode(context, l10n),
          ),
        ),
      ],
      const SizedBox(height: 16),
      Text(l10n.linkedPhones, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      if (state.phones.where((p) => !p.isHub).isEmpty)
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(l10n.noLinkedPhones,
              style: TextStyle(color: scheme.onSurfaceVariant)),
        ),
      Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (final phone in state.phones)
              ListTile(
                leading: CircleAvatar(child: Text(phone.code)),
                title: Text(phone.name),
                subtitle: Text(phone.isThisPhone
                    ? l10n.thisPhone
                    : phone.lastSync == null
                        ? l10n.neverSynced
                        : l10n.lastSyncAt(formatDateTime(phone.lastSync!))),
                trailing: isOwner && !phone.isHub
                    ? IconButton(
                        icon: const Icon(Icons.link_off),
                        tooltip: l10n.removePhone,
                        onPressed: () => _remove(context, l10n, phone),
                      )
                    : null,
              ),
          ],
        ),
      ),
    ];
  }

  Future<void> _showCode(BuildContext context, AppLocalizations l10n) async {
    final info = await context.read<SyncCubit>().pairingInfo();
    if (!context.mounted) return;
    if (info == null) {
      showAppSnack(context, l10n.hubNoWifi, kind: SnackKind.error);
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.pairTitle),
        content: SizedBox(
          width: 280,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Black on white, also in dark mode, so cameras read it.
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: PrettyQrView.data(
                    data: info.encode(),
                    decoration: const PrettyQrDecoration(
                        shape: PrettyQrSquaresSymbol(color: Colors.black)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('${info.shopName} · ${info.host}:${info.port}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(l10n.pairBody, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.commonOk)),
        ],
      ),
    );
  }

  Future<void> _remove(
      BuildContext context, AppLocalizations l10n, LinkedPhone phone) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.removePhone),
        content: Text(l10n.removePhoneBody(phone.name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.commonCancel)),
          FilledButton.tonal(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.removePhone)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await context.read<SyncCubit>().removePhone(phone.id);
    if (context.mounted) {
      showAppSnack(context, l10n.phoneRemoved, kind: SnackKind.success);
    }
  }

  List<Widget> _worker(
      BuildContext context, AppLocalizations l10n, SyncState state) {
    final scheme = Theme.of(context).colorScheme;
    final syncing = state.status == SyncStatus.syncing;
    final summary = state.lastSummary;
    return [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(child: Text(state.deviceCode ?? '?')),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                        l10n.linkedTo(
                            state.shopName ?? '', state.deviceCode ?? '?'),
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(state.lastSync == null
                  ? l10n.neverSynced
                  : l10n.lastSyncAt(formatDateTime(state.lastSync!))),
              if (state.pending > 0)
                Text(l10n.pendingChanges(state.pending),
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              if (state.status == SyncStatus.ok && summary != null)
                Text(l10n.syncDone(summary.sent, summary.received),
                    style: TextStyle(color: scheme.primary)),
              if (state.status == SyncStatus.error) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.wifi_off, color: scheme.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(syncErrorText(l10n, state.error),
                          style: TextStyle(color: scheme.error)),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: syncing
                      ? null
                      : () => context.read<SyncCubit>().syncNow(),
                  icon: syncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.sync),
                  label: Text(syncing ? l10n.syncing : l10n.syncNow),
                ),
              ),
              const SizedBox(height: 8),
              Text(l10n.syncAuto,
                  style:
                      TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    ];
  }
}
