import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/user_repository.dart';
import '../widgets/user_avatar.dart';

/// Owner only: the owner and every worker, with a button to add one.
class WorkersPage extends StatefulWidget {
  const WorkersPage({super.key});

  @override
  State<WorkersPage> createState() => _WorkersPageState();
}

class _WorkersPageState extends State<WorkersPage> {
  late Future<List<AppUser>> _users = _load();

  Future<List<AppUser>> _load() async {
    final result = await sl<UserRepository>().getUsers();
    return result.fold((failure) => throw failure.message, (users) => users);
  }

  /// Opens the form, then reloads the list when coming back.
  Future<void> _open(String location, {AppUser? user}) async {
    await context.push(location, extra: user);
    if (mounted) {
      setState(() {
        _users = _load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.workersTitle)),
      body: FutureBuilder<List<AppUser>>(
        future: _users,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return EmptyState(
                icon: Icons.error_outline,
                title: l10n.errorWithDetail('${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!;
          final hasWorkers = users.any((u) => !u.isOwner);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final (index, user) in users.indexed) ...[
                      if (index > 0) const Divider(indent: 72),
                      ListTile(
                        leading: UserAvatar(user: user),
                        title: Text(user.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text([
                          user.isOwner ? l10n.roleOwner : l10n.roleWorker,
                          if (user.phone.isNotEmpty) user.phone,
                        ].join(' · ')),
                        trailing: user.lockedOut
                            ? _Badge(icon: Icons.lock, text: l10n.lockedBadge)
                            : !user.active
                                ? _Badge(text: l10n.inactiveBadge)
                                : const Icon(Icons.chevron_right),
                        onTap: () =>
                            _open('/more/workers/${user.id}', user: user),
                      ),
                    ],
                  ],
                ),
              ),
              if (!hasWorkers)
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: EmptyState(
                    icon: Icons.group_add_outlined,
                    title: l10n.addWorker,
                    message: l10n.noWorkersBody,
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open('/more/workers/new'),
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(l10n.addWorker),
      ),
    );
  }
}

/// Small red label such as "LOCKED" or "DISABLED".
class _Badge extends StatelessWidget {
  final String text;
  final IconData? icon;

  const _Badge({required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: icon == null
          ? null
          : Icon(icon, size: 14, color: scheme.onErrorContainer),
      label: Text(text,
          style: TextStyle(fontSize: 10, color: scheme.onErrorContainer)),
      backgroundColor: scheme.errorContainer,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}
