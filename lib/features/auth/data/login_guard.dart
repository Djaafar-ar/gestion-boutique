import '../../../core/settings/settings_store.dart';

/// What happens after a wrong PIN.
sealed class GuardDecision {
  const GuardDecision();
}

/// The person may try again; [triesLeft] before the next wait.
class TryAgain extends GuardDecision {
  final int triesLeft;
  const TryAgain(this.triesLeft);
}

/// The account must wait [wait] before the next try.
class MustWait extends GuardDecision {
  final Duration wait;
  const MustWait(this.wait);
}

/// Too many wrong PINs: the account must be locked.
class LockOut extends GuardDecision {
  const LockOut();
}

/// Counts wrong PINs per account on this phone and makes people wait
/// longer and longer:
///
/// - 5 wrong PINs  -> wait 30 seconds,
/// - 10 wrong PINs -> wait 5 minutes,
/// - 15 wrong PINs -> the account is locked (see `LoginService`).
///
/// Waits are measured with the app's own stopwatch, never with the
/// phone's clock, so changing the date or time does not shorten them.
/// The time left is saved regularly: closing the app pauses the wait, it
/// does not reset it.
class LoginGuard {
  static const attemptsPerStep = 5;
  static const waits = [Duration(seconds: 30), Duration(minutes: 5)];
  static const lockOutAfter = 15;

  final SettingsStore settings;
  final Duration Function() _elapsed;

  /// For each account: stopwatch time when its saved wait was last read
  /// or written.
  final Map<String, Duration> _markedAt = {};

  /// [elapsed] is a clock that only moves forward (tests pass a fake one).
  LoginGuard(this.settings, {Duration Function()? elapsed})
      : _elapsed = elapsed ?? _stopwatch();

  static Duration Function() _stopwatch() {
    final watch = Stopwatch()..start();
    return () => watch.elapsed;
  }

  static String _failuresKey(String userId) => 'login_failures_$userId';
  static String _waitKey(String userId) => 'login_wait_ms_$userId';

  /// Wrong PINs since the last good one.
  int failures(String userId) =>
      int.tryParse(settings.get(_failuresKey(userId)) ?? '') ?? 0;

  Duration remainingWait(String userId) {
    final saved = Duration(
        milliseconds: int.tryParse(settings.get(_waitKey(userId)) ?? '') ?? 0);
    if (saved == Duration.zero) return Duration.zero;
    // The countdown starts when this app session first looks at it.
    final mark = _markedAt.putIfAbsent(userId, _elapsed);
    final left = saved - (_elapsed() - mark);
    return left.isNegative ? Duration.zero : left;
  }

  /// Saves the time left. Call it every few seconds while waiting, so
  /// killing the app loses at most those few seconds of waiting.
  Future<void> saveProgress(String userId) =>
      _saveWait(userId, remainingWait(userId));

  Future<GuardDecision> recordFailure(String userId) async {
    final count = failures(userId) + 1;
    if (count >= lockOutAfter) {
      // The lock itself is kept on the account; counting starts again
      // after the owner (or the recovery code) unlocks it.
      await reset(userId);
      return const LockOut();
    }
    await settings.set(_failuresKey(userId), '$count');
    if (count % attemptsPerStep == 0) {
      final wait = waits[count ~/ attemptsPerStep - 1];
      await _saveWait(userId, wait);
      return MustWait(wait);
    }
    return TryAgain(attemptsPerStep - count % attemptsPerStep);
  }

  /// After a right PIN, an unlock or a recovery.
  Future<void> reset(String userId) async {
    await settings.set(_failuresKey(userId), null);
    await _saveWait(userId, Duration.zero);
  }

  Future<void> _saveWait(String userId, Duration wait) async {
    await settings.set(_waitKey(userId),
        wait == Duration.zero ? null : '${wait.inMilliseconds}');
    _markedAt[userId] = _elapsed();
  }
}
