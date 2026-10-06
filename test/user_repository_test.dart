import 'package:billing_app/core/database/app_database.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/core/security/pin_hasher.dart';
import 'package:billing_app/core/security/recovery_code.dart';
import 'package:billing_app/core/settings/settings_store.dart';
import 'package:billing_app/features/users/data/repositories/user_repository_impl.dart';
import 'package:billing_app/features/users/domain/entities/app_user.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' show Either;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late UserRepositoryImpl repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final settings = SettingsStore(db);
    await settings.load();
    repo = UserRepositoryImpl(db, settings);
  });

  tearDown(() => db.close());

  /// The value of a successful result; the test fails otherwise.
  T ok<T>(Either<Failure, T> result) =>
      result.getOrElse((failure) => fail(failure.message));

  /// The refusal of a failed result; the test fails if it succeeded.
  Failure refused<T>(Either<Failure, T> result) =>
      result.getLeft().toNullable() ?? fail('expected a refusal');

  Future<AppUser> makeOwner({String pin = '1234'}) async =>
      ok(await repo.createOwner(name: 'Karim', phone: '', pin: pin)).owner;

  Future<AppUser> makeWorker(AppUser owner, String name, String pin) async =>
      ok(await repo.addWorker(
          actorId: owner.id, name: name, phone: '', pin: pin));

  group('PIN storage', () {
    test('the PIN itself is never stored', () async {
      await makeOwner();
      final row = await db.select(db.users).getSingle();

      expect(row.pinHash, isNot(contains('1234')));
      expect(row.pinHash, hasLength(64));
      expect(PinHasher.verify('1234', row.pinSalt, row.pinHash), isTrue);
    });

    test('same PIN, different people, different hashes', () {
      final a = PinHasher.hash('0000', PinHasher.newSalt());
      final b = PinHasher.hash('0000', PinHasher.newSalt());
      expect(a, isNot(b));
    });

    test('PIN lengths', () {
      expect(PinHasher.isValidPin('0123'), isTrue);
      expect(PinHasher.isValidPin('012345'), isFalse);
      expect(PinHasher.isValidPin('012345', length: 6), isTrue);
      expect(PinHasher.isValidPin('12a4'), isFalse);
    });
  });

  group('owner', () {
    test('first launch: exactly one owner', () async {
      expect(await repo.hasOwner(), isFalse);
      final owner = await makeOwner();
      expect(owner.isOwner, isTrue);
      expect(await repo.hasOwner(), isTrue);

      refused(await repo.createOwner(name: 'Other', phone: '', pin: '0000'));
    });

    test('the owner may choose a 6-digit PIN, a worker may not', () async {
      final owner = await makeOwner(pin: '123456');
      expect(owner.pinLength, 6);
      expect(await repo.checkPin(owner.id, '123456'), isNotNull);

      refused(await repo.addWorker(
          actorId: owner.id, name: 'Amine', phone: '', pin: '123456'));
    });

    test('earlier sales go to the owner', () async {
      final now = DateTime.now();
      await db.into(db.sales).insert(SalesCompanion.insert(
          id: 's1',
          createdAt: now,
          updatedAt: now,
          deviceId: 'd',
          number: 1,
          subtotal: 100,
          total: 100,
          paidNow: 100));

      final owner = await makeOwner();

      expect((await db.select(db.sales).getSingle()).userId, owner.id);
    });

    test('the owner can never be switched off', () async {
      final owner = await makeOwner();
      final saved = ok(await repo.updateUser(
          actorId: owner.id, user: owner.copyWith(active: false)));
      expect(saved.active, isTrue);
    });
  });

  group('who may change a PIN', () {
    test('anyone can change their OWN PIN with the current one', () async {
      final owner = await makeOwner();
      final amine = await makeWorker(owner, 'Amine', '5678');

      final wrong = refused(await repo.changeOwnPin(
          userId: amine.id, currentPin: '0000', newPin: '1111'));
      expect(wrong, isA<WrongSecretFailure>());

      ok(await repo.changeOwnPin(
          userId: amine.id, currentPin: '5678', newPin: '1111'));
      expect(await repo.checkPin(amine.id, '1111'), isNotNull);
      expect(await repo.checkPin(amine.id, '5678'), isNull);
    });

    test('a worker cannot pick a 6-digit PIN for themselves', () async {
      final owner = await makeOwner();
      final amine = await makeWorker(owner, 'Amine', '5678');
      refused(await repo.changeOwnPin(
          userId: amine.id, currentPin: '5678', newPin: '123456'));
    });

    test("a worker can never reset someone else's PIN", () async {
      final owner = await makeOwner();
      final amine = await makeWorker(owner, 'Amine', '5678');
      final yacine = await makeWorker(owner, 'Yacine', '2222');

      final result = await repo.resetWorkerPin(
          actorId: amine.id, workerId: yacine.id, newPin: '0000');

      expect(refused(result), isA<PermissionFailure>());
      expect(await repo.checkPin(yacine.id, '2222'), isNotNull);
    });

    test('a worker cannot add, edit or unlock accounts', () async {
      final owner = await makeOwner();
      final amine = await makeWorker(owner, 'Amine', '5678');

      expect(
          refused(await repo.addWorker(
              actorId: amine.id, name: 'X', phone: '', pin: '1111')),
          isA<PermissionFailure>());
      expect(
          refused(await repo.updateUser(
              actorId: amine.id, user: owner.copyWith(name: 'Hacked'))),
          isA<PermissionFailure>());
      expect(
          refused(
              await repo.unlockWorker(actorId: amine.id, workerId: amine.id)),
          isA<PermissionFailure>());
    });

    test('the owner resets a worker PIN, which also unlocks it', () async {
      final owner = await makeOwner();
      final amine = await makeWorker(owner, 'Amine', '5678');
      await repo.setLockedOut(amine.id);

      final reset = ok(await repo.resetWorkerPin(
          actorId: owner.id, workerId: amine.id, newPin: '9999'));

      expect(reset.lockedOut, isFalse);
      expect(await repo.checkPin(amine.id, '9999'), isNotNull);
    });

    test('the reset tool cannot be used on the owner account', () async {
      final owner = await makeOwner();
      final result = await repo.resetWorkerPin(
          actorId: owner.id, workerId: owner.id, newPin: '0000');
      expect(refused(result), isA<PermissionFailure>());
    });

    test('a disabled worker cannot log in', () async {
      final owner = await makeOwner();
      final amine = await makeWorker(owner, 'Amine', '5678');
      await repo.updateUser(
          actorId: owner.id, user: amine.copyWith(active: false));

      expect(await repo.checkPin(amine.id, '5678'), isNull);
      final active = ok(await repo.getUsers(activeOnly: true));
      expect(active.map((u) => u.name), ['Karim']);
    });
  });

  group('recovery code', () {
    test('made at setup, it resets the PIN and unlocks the owner', () async {
      final setup =
          ok(await repo.createOwner(name: 'Karim', phone: '', pin: '1234'));
      await repo.setLockedOut(setup.owner.id);

      // Typed in lower case with spaces: still accepted.
      final typed = setup.recoveryCode.toLowerCase().replaceAll('-', ' ');
      final recovered =
          ok(await repo.recoverOwner(code: typed, newPin: '654321'));

      expect(recovered.owner.lockedOut, isFalse);
      expect(recovered.owner.pinLength, 6);
      expect(await repo.checkPin(setup.owner.id, '654321'), isNotNull);
      // A used code is replaced: the old one no longer works.
      expect(recovered.recoveryCode, isNot(setup.recoveryCode));
      refused(
          await repo.recoverOwner(code: setup.recoveryCode, newPin: '1111'));
    });

    test('a wrong code fails and is recorded', () async {
      final owner = await makeOwner();

      final result =
          await repo.recoverOwner(code: 'AAAA-BBBB-CCCC', newPin: '1111');

      expect(refused(result), isA<WrongSecretFailure>());
      expect(await repo.checkPin(owner.id, '1234'), isNotNull);
      final attempts = await repo.getFailedLogins();
      expect(attempts.single.kind, FailedLoginKind.recovery);
    });

    test('the code itself is never stored', () async {
      final setup =
          ok(await repo.createOwner(name: 'Karim', phone: '', pin: '1234'));
      final row = await db.select(db.users).getSingle();
      expect(row.recoveryHash,
          isNot(contains(RecoveryCode.normalize(setup.recoveryCode))));
    });

    test('a new code needs the current PIN and replaces the old', () async {
      final setup =
          ok(await repo.createOwner(name: 'Karim', phone: '', pin: '1234'));
      final id = setup.owner.id;

      refused(await repo.createRecoveryCode(ownerId: id, currentPin: '0000'));
      final fresh =
          ok(await repo.createRecoveryCode(ownerId: id, currentPin: '1234'));

      refused(
          await repo.recoverOwner(code: setup.recoveryCode, newPin: '1111'));
      ok(await repo.recoverOwner(code: fresh, newPin: '2222'));
    });

    test('codes look like XXXX-XXXX-XXXX with easy letters', () {
      final code = RecoveryCode.generate();
      expect(
          code, matches(RegExp(r'^[A-HJ-NP-Z2-9]{4}(-[A-HJ-NP-Z2-9]{4}){2}$')));
      expect(RecoveryCode.normalize(' k7qm-3wzd hp9x '), 'K7QM3WZDHP9X');
    });
  });

  test('failed attempts are listed newest first and can be marked seen',
      () async {
    final owner = await makeOwner();
    final amine = await makeWorker(owner, 'Amine', '5678');
    await repo.logFailedLogin(amine.id, FailedLoginKind.pin);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.logFailedLogin(owner.id, FailedLoginKind.pin);

    final unseen = await repo.getFailedLogins(unseenOnly: true);
    expect(unseen.map((a) => a.accountName), ['Karim', 'Amine']);

    await repo.markFailedLoginsSeen();
    expect(await repo.getFailedLogins(unseenOnly: true), isEmpty);
    expect(await repo.getFailedLogins(), hasLength(2));
  });

  test('list: owner first, then workers by name', () async {
    final owner = await makeOwner();
    await makeWorker(owner, 'Yacine', '1111');
    await makeWorker(owner, 'amine', '2222');

    final users = ok(await repo.getUsers());
    expect(users.map((u) => u.name), ['Karim', 'amine', 'Yacine']);
  });
}
