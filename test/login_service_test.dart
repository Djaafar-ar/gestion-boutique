import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/auth/data/login_guard.dart';
import 'package:billing_app/features/auth/data/login_service.dart';
import 'package:billing_app/features/users/data/repositories/user_repository_impl.dart';
import 'package:billing_app/features/users/domain/entities/app_user.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late UserRepositoryImpl users;
  late Duration elapsed;
  late LoginService login;
  late AppUser owner;
  late AppUser amine;
  late String recoveryCode;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final settings = SettingsStore(db);
    await settings.load();
    users = UserRepositoryImpl(db, settings);
    elapsed = Duration.zero;
    login = LoginService(users, LoginGuard(settings, elapsed: () => elapsed));
    final setup =
        (await users.createOwner(name: 'Karim', phone: '', pin: '1234'))
            .getOrElse((f) => fail(f.message));
    owner = setup.owner;
    recoveryCode = setup.recoveryCode;
    amine = (await users.addWorker(
            actorId: owner.id, name: 'Amine', phone: '', pin: '5678'))
        .getOrElse((f) => fail(f.message));
  });

  tearDown(() => db.close());

  /// Types a wrong PIN [times] times and lets each wait pass.
  Future<LoginResult> wrongPins(String userId, int times) async {
    late LoginResult last;
    for (var i = 0; i < times; i++) {
      last = await login.tryPin(userId, '0000');
      if (last is LoginMustWait) elapsed += last.wait;
    }
    return last;
  }

  test('the right PIN logs in', () async {
    final result = await login.tryPin(amine.id, '5678');
    expect((result as LoginSuccess).user.name, 'Amine');
  });

  test('during a wait even the right PIN is refused', () async {
    expect(await wrongPins(amine.id, 4), isA<LoginWrongPin>());
    final fifth = await login.tryPin(amine.id, '0000');
    expect(fifth, isA<LoginMustWait>());

    expect(await login.tryPin(amine.id, '5678'), isA<LoginMustWait>());
    elapsed += const Duration(seconds: 30);
    expect(await login.tryPin(amine.id, '5678'), isA<LoginSuccess>());
  });

  test('15 wrong PINs lock a worker until the owner unlocks', () async {
    expect(await wrongPins(amine.id, 15), isA<LoginLockedOut>());
    expect((await users.getUser(amine.id))!.lockedOut, isTrue);

    // Waiting does not help, nor does the right PIN.
    elapsed += const Duration(days: 1);
    expect(await login.tryPin(amine.id, '5678'), isA<LoginLockedOut>());

    // Only the owner can unlock.
    final byWorker =
        await login.unlockWorker(actorId: amine.id, workerId: amine.id);
    expect(byWorker.isLeft(), isTrue);
    await login.unlockWorker(actorId: owner.id, workerId: amine.id);

    expect(await login.tryPin(amine.id, '5678'), isA<LoginSuccess>());
  });

  test('a locked owner gets back in only with the recovery code', () async {
    expect(await wrongPins(owner.id, 15), isA<LoginLockedOut>());
    expect(await login.tryPin(owner.id, '1234'), isA<LoginLockedOut>());

    final recovered =
        await login.recoverOwner(code: recoveryCode, newPin: '4321');
    expect(recovered.isRight(), isTrue);

    expect(await login.tryPin(owner.id, '4321'), isA<LoginSuccess>());
  });

  test('every wrong PIN is recorded with the account', () async {
    await wrongPins(amine.id, 3);
    await wrongPins(owner.id, 1);

    final attempts = await users.getFailedLogins(unseenOnly: true);
    expect(attempts, hasLength(4));
    expect(attempts.where((a) => a.accountName == 'Amine'), hasLength(3));
    expect(attempts.every((a) => a.kind == FailedLoginKind.pin), isTrue);
  });

  test('a disabled account cannot log in', () async {
    await users.updateUser(
        actorId: owner.id, user: amine.copyWith(active: false));
    expect(await login.tryPin(amine.id, '5678'), isNot(isA<LoginSuccess>()));
  });
}
