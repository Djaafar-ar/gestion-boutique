import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/auth/data/login_guard.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late SettingsStore settings;

  /// A fake stopwatch the test moves by hand.
  late Duration elapsed;
  late LoginGuard guard;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    settings = SettingsStore(db);
    await settings.load();
    elapsed = Duration.zero;
    guard = LoginGuard(settings, elapsed: () => elapsed);
  });

  tearDown(() => db.close());

  Future<GuardDecision> fail(int times) async {
    late GuardDecision last;
    for (var i = 0; i < times; i++) {
      last = await guard.recordFailure('amine');
    }
    return last;
  }

  test('the waits get longer: 30 s, then 5 min, then a lock', () async {
    expect(await fail(4), isA<TryAgain>());
    expect(((await fail(1)) as MustWait).wait, const Duration(seconds: 30));
    expect(guard.remainingWait('amine'), const Duration(seconds: 30));

    elapsed += const Duration(seconds: 30);
    expect(guard.remainingWait('amine'), Duration.zero);

    expect(await fail(4), isA<TryAgain>());
    expect(((await fail(1)) as MustWait).wait, const Duration(minutes: 5));

    elapsed += const Duration(minutes: 5);
    expect(await fail(4), isA<TryAgain>());
    expect(await fail(1), isA<LockOut>());
  });

  test('tries left before the next wait', () async {
    expect(((await fail(1)) as TryAgain).triesLeft, 4);
    expect(((await fail(3)) as TryAgain).triesLeft, 1);
  });

  test('each account has its own count', () async {
    await fail(5);
    expect(guard.remainingWait('amine'), greaterThan(Duration.zero));
    expect(guard.remainingWait('yacine'), Duration.zero);
    expect(guard.failures('yacine'), 0);
  });

  test('changing the phone date or time does not shorten a wait', () async {
    await fail(5);
    // The guard never reads the phone clock, only its own stopwatch:
    // a date set one year ahead changes nothing.
    elapsed += const Duration(seconds: 10);
    expect(guard.remainingWait('amine'), const Duration(seconds: 20));
  });

  test('closing the app pauses the wait, it does not reset it', () async {
    await fail(10); // 5 minutes
    elapsed += const Duration(minutes: 2);
    await guard.saveProgress('amine');

    // App closed for an hour, then opened again: a new guard with a new
    // stopwatch starting at zero.
    final reloaded = SettingsStore(db);
    await reloaded.load();
    final afterRestart = LoginGuard(reloaded, elapsed: () => Duration.zero);

    expect(afterRestart.remainingWait('amine'), const Duration(minutes: 3));
    expect(afterRestart.failures('amine'), 10);
  });

  test('a right PIN (or an unlock) starts counting from zero', () async {
    await fail(7);
    await guard.reset('amine');

    expect(guard.failures('amine'), 0);
    expect(guard.remainingWait('amine'), Duration.zero);
  });
}
