import '../../../core/settings/settings_store.dart';

/// Slows down PIN guessing: after [maxAttempts] wrong PINs in a row the
/// login screen waits [lockDuration]. Saved on the phone, so closing the
/// app does not reset it.
class LoginGuard {
  static const maxAttempts = 5;
  static const lockDuration = Duration(seconds: 30);

  static const _failuresKey = 'login_failures';
  static const _lockedUntilKey = 'login_locked_until';

  final SettingsStore settings;
  final DateTime Function() _now;

  LoginGuard(this.settings, {DateTime Function()? clock})
      : _now = clock ?? DateTime.now;

  int get _failures => int.tryParse(settings.get(_failuresKey) ?? '') ?? 0;

  /// How long the user must still wait, or [Duration.zero].
  Duration get remainingLock {
    final until = DateTime.tryParse(settings.get(_lockedUntilKey) ?? '');
    if (until == null) return Duration.zero;
    final left = until.difference(_now());
    return left.isNegative ? Duration.zero : left;
  }

  bool get isLocked => remainingLock > Duration.zero;

  /// Tries left before the lock.
  int get attemptsLeft => maxAttempts - _failures;

  Future<void> recordFailure() async {
    final failures = _failures + 1;
    if (failures >= maxAttempts) {
      await settings.set(_failuresKey, '0');
      await settings.set(
          _lockedUntilKey, _now().add(lockDuration).toIso8601String());
    } else {
      await settings.set(_failuresKey, '$failures');
    }
  }

  Future<void> recordSuccess() async {
    await settings.set(_failuresKey, null);
    await settings.set(_lockedUntilKey, null);
  }
}
