import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/widgets/owner_approval_dialog.dart';
import '../../../auth/presentation/widgets/pin_field.dart';
import '../../data/backup_service.dart';

String backupErrorText(AppLocalizations l10n, BackupError error) =>
    switch (error) {
      BackupError.notABackup => l10n.restoreErrNotBackup,
      BackupError.newerVersion => l10n.restoreErrNewer,
      BackupError.otherShop => l10n.restoreErrOtherShop,
      BackupError.wrongPin => l10n.restoreErrPin,
      BackupError.workerPhone => l10n.restoreErrWorker,
    };

/// Restores a backup file: from Plus → Sauvegarde (owner), or on the
/// first screen of a new phone.
class RestorePage extends StatefulWidget {
  const RestorePage({super.key});

  @override
  State<RestorePage> createState() => _RestorePageState();
}

class _RestorePageState extends State<RestorePage> {
  Uint8List? _bytes;
  BackupInfo? _info;
  String? _error;
  bool _working = false;

  bool get _newPhone => !context.read<SessionCubit>().state.hasOwner;

  Future<void> _pick() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _error = null);
    final file = await FilePicker.pickFile(dialogTitle: l10n.restorePick);
    if (file == null || !mounted) return;
    setState(() => _working = true);
    try {
      final bytes = await file.readAsBytes();
      final (info, _) = BackupService.read(bytes);
      setState(() {
        _bytes = bytes;
        _info = info;
      });
    } on BackupException catch (e) {
      setState(() => _error = backupErrorText(l10n, e.error));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _restore() async {
    final bytes = _bytes;
    if (bytes == null) return;
    final l10n = AppLocalizations.of(context);
    // The owner PIN: with the login rules when someone is logged in, the
    // backup's owner PIN on a new phone.
    final pin = _newPhone
        ? await showDialog<String>(
            context: context, builder: (_) => const _BackupPinDialog())
        : await askOwnerApproval(context);
    if (pin == null || !mounted) return;
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      await sl<BackupService>().prepareRestore(bytes, pin: pin);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.restoreReadyTitle),
          content: Text(l10n.restoreReadyBody),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.restoreClose),
            ),
          ],
        ),
      );
      // The backup replaces the database when the app starts again.
      exit(0);
    } on BackupException catch (e) {
      if (mounted) setState(() => _error = backupErrorText(l10n, e.error));
    } catch (e) {
      if (mounted) setState(() => _error = l10n.errorWithDetail('$e'));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final info = _info;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.restoreTitle),
        leading: BackButton(
            onPressed: () => _newPhone ? context.go('/setup') : context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(Icons.settings_backup_restore, size: 48, color: scheme.primary),
          const SizedBox(height: 12),
          Text(_newPhone ? l10n.restoreIntroNew : l10n.restoreIntro,
              style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _working ? null : _pick,
            icon: const Icon(Icons.folder_open),
            label: Text(l10n.restorePick),
          ),
          if (info != null) ...[
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(info.shopName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle:
                    Text(l10n.restoreMadeOn(formatDateTime(info.createdAt))),
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.restoreWarning, style: TextStyle(color: scheme.error)),
          ],
          if (_working) ...[
            const SizedBox(height: 20),
            const LinearProgressIndicator(),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: scheme.error)),
          ],
        ],
      ),
      bottomNavigationBar: info == null
          ? null
          : PrimaryButton(
              onPressed: _working ? null : _restore,
              isLoading: _working,
              icon: Icons.settings_backup_restore,
              label: l10n.restoreButton,
            ),
    );
  }
}

/// New phone: the owner PIN of the shop in the backup.
class _BackupPinDialog extends StatefulWidget {
  const _BackupPinDialog();

  @override
  State<_BackupPinDialog> createState() => _BackupPinDialogState();
}

class _BackupPinDialogState extends State<_BackupPinDialog> {
  final _formKey = GlobalKey<FormState>();
  final _pin = TextEditingController();

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.restorePinTitle),
      content: Form(
        key: _formKey,
        child: PinField(
            controller: _pin, label: l10n.loginEnterPin, anyOwnerLength: true),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel)),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _pin.text);
            }
          },
          child: Text(l10n.continueLabel),
        ),
      ],
    );
  }
}
