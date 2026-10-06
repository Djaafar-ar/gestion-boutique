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
import '../../data/login_service.dart';
import '../widgets/pin_pad.dart';
import 'recovery_page.dart';

/// Pick your name, then type your PIN.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginService _login = sl<LoginService>();
  late Future<List<AppUser>> _users = _loadUsers();
  AppUser? _selected;

  /// Why the PIN pad is blocked (wait or lock), or null.
  LoginResult? _blocked;
  String? _message;
  bool _checking = false;
  Timer? _timer;

  Future<List<AppUser>> _loadUsers() async {
    final result = await sl<UserRepository>().getUsers(activeOnly: true);
    final users = result.getOrElse((_) => []);
    // Only one account: go straight to the PIN.
    if (users.length == 1 && _selected == null) await _select(users.single);
    return users;
  }

  @override
  void dispose() {
    _timer?.cancel();
    final user = _selected;
    if (user != null) sl<LoginGuard>().saveProgress(user.id);
    super.dispose();
  }

  Future<void> _select(AppUser user) async {
    final status = await _login.status(user.id);
    if (!mounted) return;
    setState(() {
      _selected = user;
      _message = null;
      _blocked = status;
    });
    _startCountdown();
  }

  /// While waiting: redraw every second and save the time left, so
  /// closing the app pauses the wait instead of cancelling it.
  void _startCountdown() {
    _timer?.cancel();
    if (_blocked is! LoginMustWait) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final user = _selected;
      if (!mounted || user == null) return timer.cancel();
      await sl<LoginGuard>().saveProgress(user.id);
      final status = await _login.status(user.id);
      if (!mounted) return;
      setState(() => _blocked = status);
      if (status is! LoginMustWait) timer.cancel();
    });
  }

  Future<void> _checkPin(String pin) async {
    final user = _selected;
    if (user == null || _checking) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _checking = true);
    final result = await _login.tryPin(user.id, pin);
    if (!mounted) return;
    setState(() => _checking = false);

    switch (result) {
      case LoginSuccess(:final user):
        context.read<SessionCubit>().login(user);
      case LoginWrongPin(:final triesLeft):
        setState(() => _message = l10n.loginWrongPin(triesLeft));
      case LoginMustWait() || LoginLockedOut():
        setState(() {
          _message = null;
          _blocked = result;
          // Show the lock icon on the account right away.
          if (result is LoginLockedOut) _users = _loadUsers();
        });
        _startCountdown();
    }
  }

  Future<void> _openRecovery() async {
    final recovered = await Navigator.of(context)
        .push<AppUser>(MaterialPageRoute(builder: (_) => const RecoveryPage()));
    if (recovered != null && mounted) {
      context.read<SessionCubit>().login(recovered);
    } else if (mounted) {
      // The owner may have been unlocked; reload the list and status.
      setState(() {
        _users = _loadUsers();
      });
      final user = _selected;
      if (user != null) await _select(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final selected = _selected;

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
                  selected == null ? l10n.loginTitle : l10n.loginEnterPin,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final user in users)
                      _UserChoice(
                        user: user,
                        selected: user.id == selected?.id,
                        onTap: () => _select(user),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                if (selected != null) ..._pinArea(l10n, scheme, selected),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _pinArea(
      AppLocalizations l10n, ColorScheme scheme, AppUser user) {
    final blocked = _blocked;
    final text = switch (blocked) {
      LoginMustWait(:final wait) => l10n.loginWait(_minutesSeconds(wait)),
      LoginLockedOut() =>
        user.isOwner ? l10n.loginLockedOwner : l10n.loginLockedWorker,
      _ => _message ?? '',
    };
    return [
      Text(text,
          textAlign: TextAlign.center, style: TextStyle(color: scheme.error)),
      if (blocked is LoginMustWait)
        Text(l10n.loginWaitPaused,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
      const SizedBox(height: 8),
      if (blocked is! LoginLockedOut)
        PinPad(
          key: ValueKey(user.id),
          length: user.pinLength,
          onCompleted: _checkPin,
          enabled: blocked == null && !_checking,
        ),
      if (user.isOwner)
        TextButton.icon(
          onPressed: _openRecovery,
          icon: const Icon(Icons.key),
          label: Text(l10n.forgotPin),
        ),
    ];
  }

  /// 125 seconds -> "2:05".
  String _minutesSeconds(Duration wait) {
    final seconds = wait.inSeconds + (wait.inMilliseconds % 1000 > 0 ? 1 : 0);
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
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
            if (user.lockedOut) Icon(Icons.lock, size: 14, color: scheme.error),
          ],
        ),
      ),
    );
  }
}
