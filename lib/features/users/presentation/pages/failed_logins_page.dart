import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/user_repository.dart';

/// Owner only: every wrong PIN or recovery code typed, newest first.
class FailedLoginsPage extends StatefulWidget {
  const FailedLoginsPage({super.key});

  @override
  State<FailedLoginsPage> createState() => _FailedLoginsPageState();
}

class _FailedLoginsPageState extends State<FailedLoginsPage> {
  final Future<List<FailedLogin>> _attempts =
      sl<UserRepository>().getFailedLogins();

  @override
  void initState() {
    super.initState();
    // Opening the list counts as having seen the warnings.
    sl<UserRepository>().markFailedLoginsSeen();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.failedLoginsTitle)),
      body: FutureBuilder<List<FailedLogin>>(
        future: _attempts,
        builder: (context, snapshot) {
          final attempts = snapshot.data;
          if (attempts == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (attempts.isEmpty) {
            return EmptyState(
                icon: Icons.verified_user_outlined,
                title: l10n.failedLoginsEmpty);
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final (index, attempt) in attempts.indexed) ...[
                      if (index > 0) const Divider(indent: 56),
                      FailedLoginTile(attempt: attempt),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class FailedLoginTile extends StatelessWidget {
  final FailedLogin attempt;

  const FailedLoginTile({super.key, required this.attempt});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      leading: Icon(
          attempt.kind == FailedLoginKind.recovery ? Icons.key : Icons.pin,
          color: scheme.error),
      title: Text(l10n.accountLabel(attempt.accountName),
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${formatDateTime(attempt.at)} · '
          '${attempt.kind == FailedLoginKind.recovery ? l10n.recoveryCodeLabel : l10n.kindPin}'),
    );
  }
}

/// Shown to the owner right after logging in when wrong codes were typed
/// since last time. Closing it marks them as seen.
Future<void> showFailedLoginsWarning(
    BuildContext context, List<FailedLogin> attempts,
    {required VoidCallback onSeeAll}) {
  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: Icon(Icons.warning_amber_rounded,
          color: Theme.of(dialogContext).colorScheme.error),
      title: Text(l10n.failedLoginsTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(l10n.failedLoginsWarning(attempts.length)),
            const SizedBox(height: 8),
            for (final attempt in attempts.take(5))
              FailedLoginTile(attempt: attempt),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            onSeeAll();
          },
          child: Text(l10n.seeAll),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(88, 40)),
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(l10n.commonOk),
        ),
      ],
    ),
  ).whenComplete(() => sl<UserRepository>().markFailedLoginsSeen());
}
