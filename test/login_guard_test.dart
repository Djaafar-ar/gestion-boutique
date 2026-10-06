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
  late DateTime now;
  late LoginGuard guard;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    settings = SettingsStore(db);
    await settings.load();
    now = DateTime(2026, 10, 6, 9);
    guard = LoginGuard(settings, clock: () => now);
  });

  tearDown(() => db.close());

  test('5 wrong PINs lock the screen for 30 seconds', () async {
    for (var i = 0; i < 4; i++) {
      await guard.recordFailure();
    }
    expect(guard.isLocked, isFalse);
    expect(guard.attemptsLeft, 1);

    await guard.recordFailure();
    expect(guard.isLocked, isTrue);
    expect(guard.remainingLock, const Duration(seconds: 30));

    now = now.add(const Duration(seconds: 29));
    expect(guard.isLocked, isTrue);

    now = now.add(const Duration(seconds: 2));
    expect(guard.isLocked, isFalse);
    expect(guard.attemptsLeft, 5);
  });

  test('the lock survives closing the app', () async {
    for (var i = 0; i < 5; i++) {
      await guard.recordFailure();
    }
    // A new start of the app reads the settings again.
    final reloaded = SettingsStore(db);
    await reloaded.load();
    expect(LoginGuard(reloaded, clock: () => now).isLocked, isTrue);
  });

  test('a right PIN resets the count', () async {
    await guard.recordFailure();
    await guard.recordFailure();
    await guard.recordSuccess();

    expect(guard.attemptsLeft, 5);
  });
}
