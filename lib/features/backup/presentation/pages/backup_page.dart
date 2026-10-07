import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/settings/settings_store.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/app_snack.dart';
import '../../../sheet/data/sheet_settings.dart';
import '../../../sheet/presentation/sheet_cubit.dart';
import '../../data/backup_service.dart';

/// Owner: make a backup and send it off the phone, or restore one.
class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  bool _working = false;

  Future<void> _share() async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SheetCubit>();
    setState(() => _working = true);
    try {
      final file = await sl<BackupService>().create();
      final result = await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: 'application/zip')],
        subject: l10n.backupShareSubject,
      ));
      if (result.status == ShareResultStatus.success) {
        await cubit.backupShared();
      }
    } catch (e) {
      if (mounted) {
        showAppSnack(context, l10n.errorWithDetail('$e'),
            kind: SnackKind.error);
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final state = context.watch<SheetCubit>().state;
    final last = sl<SettingsStore>().backupOffPhoneLast;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.backupIntro,
              style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          if (state.backupWarning)
            Card(
              color: scheme.errorContainer,
              child: ListTile(
                leading:
                    Icon(Icons.warning_amber, color: scheme.onErrorContainer),
                title: Text(l10n.backupWarning,
                    style: TextStyle(color: scheme.onErrorContainer)),
              ),
            ),
          Card(
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.history),
                title: Text(last == null
                    ? l10n.backupNeverOff
                    : l10n.backupLastOff(formatDateTime(last))),
              ),
              const Divider(height: 1),
              ListTile(
                leading: _working
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.ios_share),
                title: Text(l10n.backupShare),
                subtitle: Text(l10n.backupShareSub),
                enabled: !_working,
                onTap: _share,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.add_to_drive),
                title: Text(l10n.backupDriveTile),
                subtitle: Text(state.canRead
                    ? l10n.backupDriveOn
                    : l10n.backupDriveOff),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/more/sheet'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.settings_backup_restore,
                    color: scheme.error),
                title: Text(l10n.restoreTitle),
                subtitle: Text(l10n.restoreSub),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/restore'),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          Text(l10n.backupPrivate,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
