import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../users/domain/entities/app_user.dart';
import '../../../users/domain/repositories/user_repository.dart';
import '../../../users/presentation/widgets/user_avatar.dart';
import '../../data/login_guard.dart';
import '../widgets/pin_pad.dart';

/// Pick your name, then type your 4-digit PIN.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginGuard _guard = sl<LoginGuard>();
  late final Future<List<AppUser>> _users = _loadUsers();
  AppUser? _selected;
  String? _message;
  Timer? _lockTimer;

  Future<List<AppUser>> _loadUsers() async {
    final result = await sl<UserRepository>().getUsers(activeOnly: true);
    final users = result.getOrElse((_) => []);
    // Only one account: go straight to the PIN.
    if (users.length == 1) _selected = users.single;
    return users;
  }

  @override
  void initState() {
    super.initState();
    _tickLock();
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    super.dispose();
  }

  /// Refreshes the countdown every second while the screen is locked.
  void _tickLock() {
    _lockTimer?.cancel();
    if (!_guard.isLocked) return;
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {});
      if (!_guard.isLocked) {
        timer.cancel();
        setState(() => _message = null);
      }
    });
  }

  Future<void> _checkPin(String pin) async {
    final user = _selected;
    if (user == null || _guard.isLocked) return;
    final l10n = AppLocalizations.of(context);

    final ok = await sl<UserRepository>().checkPin(user.id, pin);
    if (!mounted) return;
    if (ok != null) {
      await _guard.recordSuccess();
      if (mounted) context.read<SessionCubit>().login(ok);
      return;
    }
    await _guard.recordFailure();
    setState(() {
      _message =
          _guard.isLocked ? null : l10n.loginWrongPin(_guard.attemptsLeft);
    });
    _tickLock();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final locked = _guard.isLocked;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<AppUser>>(
          future: _users,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final users = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              children: [
                Icon(Icons.storefront, size: 48, color: scheme.primary),
                const SizedBox(height: 12),
                Text(
                  _selected == null ? l10n.loginTitle : l10n.loginEnterPin,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                // Everyone who can log in; the chosen one is highlighted.
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final user in users)
                      _UserChoice(
                        user: user,
                        selected: user.id == _selected?.id,
                        onTap: () => setState(() {
                          _selected = user;
                          _message = null;
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_selected != null) ...[
                  SizedBox(
                    height: 24,
                    child: Text(
                      locked
                          ? l10n.loginLocked(_guard.remainingLock.inSeconds + 1)
                          : (_message ?? ''),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.error),
                    ),
                  ),
                  const SizedBox(height: 8),
                  PinPad(onCompleted: _checkPin, enabled: !locked),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _UserChoice extends StatelessWidget {
  final AppUser user;
  final bool selected;
  final VoidCallback onTap;

  const _UserChoice(
      {required this.user, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 104,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected ? scheme.primaryContainer : null,
          border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant),
        ),
        child: Column(
          children: [
            UserAvatar(user: user, radius: 26),
            const SizedBox(height: 8),
            Text(user.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(user.isOwner ? l10n.roleOwner : l10n.roleWorker,
                style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
