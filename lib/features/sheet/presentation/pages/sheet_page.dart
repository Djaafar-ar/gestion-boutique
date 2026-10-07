import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/app_snack.dart';
import '../../../../core/widgets/text_prompt_dialog.dart';
import '../../data/sheet_client.dart';
import '../../data/sheet_protocol.dart';
import '../sheet_cubit.dart';

/// What went wrong with the sheet, in simple words.
String sheetErrorText(AppLocalizations l10n, SheetError error) =>
    switch (error) {
      SheetError.notConfigured => l10n.sheetNotConfigured,
      SheetError.offline => l10n.sheetErrOffline,
      SheetError.access => l10n.sheetErrAccess,
      SheetError.signature => l10n.sheetErrSignature,
      SheetError.server => l10n.sheetErrServer,
    };

/// Plus → Google Sheet: the state of the sending on every phone; on the
/// owner's phone also the setup, live sales, the evening report and the
/// Google Drive backup.
class SheetPage extends StatelessWidget {
  const SheetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sheetTitle)),
      body: BlocBuilder<SheetCubit, SheetState>(
        builder: (context, state) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(l10n.sheetIntro,
                style: TextStyle(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            _StatusCard(state: state),
            if (state.ownerPhone) ...[
              _Header(l10n.sheetSetupSection),
              Card(
                child: Column(children: [
                  ListTile(
                    leading: const Icon(Icons.qr_code_scanner),
                    title: Text(l10n.sheetScan),
                    subtitle: Text(l10n.sheetScanSub),
                    onTap: () => _scan(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.content_paste),
                    title: Text(l10n.sheetPaste),
                    subtitle: Text(l10n.sheetPasteSub),
                    onTap: () => _paste(context),
                  ),
                  if (state.configured) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.link_off, color: scheme.error),
                      title: Text(l10n.sheetDisconnect),
                      onTap: () => _disconnect(context),
                    ),
                  ],
                ]),
              ),
            ],
            if (state.canRead) ...[
              _Header(l10n.liveSalesTitle),
              Card(
                child: Column(children: [
                  ListTile(
                    leading: const Icon(Icons.bolt),
                    title: Text(l10n.liveSalesTitle),
                    subtitle: Text(l10n.liveSalesSub),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/more/sheet/live'),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active_outlined),
                    title: Text(l10n.liveNotifyLabel),
                    subtitle: Text(l10n.liveNotifySub),
                    value: state.liveNotify,
                    onChanged: (on) =>
                        context.read<SheetCubit>().setLiveNotify(on),
                  ),
                ]),
              ),
            ],
            if (state.ownerPhone) ...[
              _Header(l10n.dailyReportLabel),
              Card(
                child: Column(children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.summarize_outlined),
                    title: Text(l10n.dailyReportLabel),
                    subtitle: Text(l10n.dailyReportSub),
                    value: state.dailyOn,
                    onChanged: (on) =>
                        context.read<SheetCubit>().setDailyReport(on: on),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(l10n.dailyReportTime),
                    trailing: Text(
                        '${state.dailyHour.toString().padLeft(2, '0')}:'
                        '${state.dailyMinute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    enabled: state.dailyOn,
                    onTap: () => _pickTime(context, state),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: Text(l10n.dailyReportOpen),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/more/sheet/report'),
                  ),
                ]),
              ),
            ],
            if (state.canRead) ...[
              _Header(l10n.driveSection),
              _DriveCard(state: state),
            ],
            const SizedBox(height: 16),
            Text(l10n.sheetPrivacy,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Future<void> _scan(BuildContext context) async {
    final text = await context.push<String>('/scanner');
    if (text == null || !context.mounted) return;
    await _useCode(context, text);
  }

  Future<void> _paste(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final text = await showTextPrompt(context,
        title: l10n.sheetPaste,
        hint: l10n.sheetPasteHint,
        confirmLabel: l10n.continueLabel);
    if (text == null || !context.mounted) return;
    await _useCode(context, text);
  }

  Future<void> _useCode(BuildContext context, String text) async {
    final l10n = AppLocalizations.of(context);
    final config = SheetConfig.decode(text);
    if (config == null) {
      showAppSnack(context, l10n.sheetNotConfigCode, kind: SnackKind.error);
      return;
    }
    final cubit = context.read<SheetCubit>();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(l10n.sheetChecking)),
          ]),
        ),
      ),
    );
    try {
      final name = await cubit.configure(config);
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      showAppSnack(context, l10n.sheetConfigured(name),
          kind: SnackKind.success);
    } on SheetException catch (e) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      showAppSnack(context, sheetErrorText(l10n, e.error),
          kind: SnackKind.error);
    }
  }

  Future<void> _disconnect(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SheetCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.sheetDisconnect),
        content: Text(l10n.sheetDisconnectConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.commonCancel)),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.sheetDisconnect)),
        ],
      ),
    );
    if (ok == true) await cubit.disconnect();
  }

  Future<void> _pickTime(BuildContext context, SheetState state) async {
    final cubit = context.read<SheetCubit>();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: state.dailyHour, minute: state.dailyMinute),
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!),
    );
    if (picked != null) {
      await cubit.setDailyReport(hour: picked.hour, minute: picked.minute);
    }
  }
}

class _StatusCard extends StatelessWidget {
  final SheetState state;
  const _StatusCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    if (!state.configured) {
      return Card(
        child: ListTile(
          leading: Icon(Icons.cloud_off, color: scheme.onSurfaceVariant),
          title: Text(l10n.sheetNotConfigured,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(state.ownerPhone
              ? l10n.sheetNotConfiguredOwner
              : l10n.sheetNotConfiguredWorker),
        ),
      );
    }
    final lastSend = state.lastSend;
    final error = state.lastError;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.cloud_done, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(l10n.sheetConnected,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ]),
            const SizedBox(height: 12),
            Text(state.pending == 0
                ? l10n.sheetAllSent
                : l10n.sheetPending(state.pending)),
            const SizedBox(height: 4),
            Text(
                lastSend == null
                    ? l10n.sheetNeverSent
                    : l10n.sheetLastSend(formatDateTime(lastSend)),
                style: TextStyle(color: scheme.onSurfaceVariant)),
            if (error != null && state.pending > 0) ...[
              const SizedBox(height: 8),
              Text(sheetErrorText(l10n, error),
                  style: TextStyle(color: scheme.error)),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton.tonalIcon(
                onPressed: state.sending ? null : () => _send(context),
                icon: state.sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(l10n.sheetSendNow),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      final sent = await context.read<SheetCubit>().sendNow();
      if (context.mounted) {
        showAppSnack(context, l10n.sheetSent(sent), kind: SnackKind.success);
      }
    } on SheetException catch (e) {
      if (context.mounted) {
        showAppSnack(context, sheetErrorText(l10n, e.error),
            kind: SnackKind.error);
      }
    }
  }
}

class _DriveCard extends StatelessWidget {
  final SheetState state;
  const _DriveCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final last = state.lastDriveBackup;
    final error = state.driveError;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(last == null
                ? l10n.driveNever
                : l10n.driveLast(formatDateTime(last))),
            if (state.backupWarning) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: scheme.errorContainer,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Icon(Icons.warning_amber, color: scheme.onErrorContainer),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(l10n.backupWarning,
                          style: TextStyle(color: scheme.onErrorContainer))),
                ]),
              ),
            ],
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(sheetErrorText(l10n, error),
                  style: TextStyle(color: scheme.error)),
            ],
            const SizedBox(height: 8),
            Text(l10n.driveInfo,
                style:
                    TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton.icon(
                onPressed: state.backingUp ? null : () => _backup(context),
                icon: state.backingUp
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.backup_outlined),
                label: Text(l10n.driveBackupNow),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _backup(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      await context.read<SheetCubit>().backupNow();
      if (context.mounted) {
        showAppSnack(context, l10n.driveDone, kind: SnackKind.success);
      }
    } on SheetException catch (e) {
      if (context.mounted) {
        showAppSnack(context, sheetErrorText(l10n, e.error),
            kind: SnackKind.error);
      }
    } catch (_) {
      if (context.mounted) {
        showAppSnack(context, l10n.sheetErrServer, kind: SnackKind.error);
      }
    }
  }
}

class _Header extends StatelessWidget {
  final String title;
  const _Header(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(8, 20, 8, 8),
        child: Text(title.toUpperCase(),
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Theme.of(context).colorScheme.primary)),
      );
}
