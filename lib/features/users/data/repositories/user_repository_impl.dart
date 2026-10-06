import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/security/pin_hasher.dart';
import '../../../../core/security/recovery_code.dart';
import '../../../../core/settings/settings_store.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final AppDatabase db;
  final SettingsStore settings;

  UserRepositoryImpl(this.db, this.settings);

  @override
  Future<bool> hasOwner() async => await _ownerRow() != null;

  @override
  Future<Either<Failure, List<AppUser>>> getUsers(
      {bool activeOnly = false}) async {
    try {
      final query = db.select(db.users)..where((u) => u.deleted.equals(false));
      if (activeOnly) query.where((u) => u.active.equals(true));
      final users = (await query.get()).map(userFromRow).toList()
        ..sort((a, b) {
          if (a.isOwner != b.isOwner) return a.isOwner ? -1 : 1;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
      return Right(users);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<AppUser?> getUser(String id) async {
    final row = await _row(id);
    return row == null ? null : userFromRow(row);
  }

  @override
  Future<Either<Failure, OwnerSetup>> createOwner(
      {required String name,
      required String phone,
      required String pin}) async {
    try {
      if (!PinHasher.ownerLengths
          .any((l) => PinHasher.isValidPin(pin, length: l))) {
        return const Left(CacheFailure('Invalid PIN'));
      }
      if (await hasOwner()) {
        return const Left(PermissionFailure('The owner already exists'));
      }
      final code = RecoveryCode.generate();
      final owner = await db.transaction(() async {
        final owner = await _insert(name, phone, pin, UserRole.owner, null);
        await _saveRecoveryCode(owner.id, code);
        // Before accounts existed, only the owner used the app.
        await (db.update(db.sales)..where((s) => s.userId.isNull()))
            .write(SalesCompanion(userId: Value(owner.id)));
        await (db.update(db.saleItems)..where((s) => s.userId.isNull()))
            .write(SaleItemsCompanion(userId: Value(owner.id)));
        await (db.update(db.products)..where((p) => p.userId.isNull()))
            .write(ProductsCompanion(userId: Value(owner.id)));
        return owner;
      });
      return Right((owner: owner, recoveryCode: code));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> addWorker(
      {required String actorId,
      required String name,
      required String phone,
      required String pin}) async {
    try {
      final denied = await _requireOwner(actorId);
      if (denied != null) return Left(denied);
      if (!PinHasher.isValidPin(pin)) {
        return const Left(CacheFailure('Invalid PIN'));
      }
      return Right(await _insert(name, phone, pin, UserRole.worker, actorId));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> updateUser(
      {required String actorId, required AppUser user}) async {
    try {
      final denied = await _requireOwner(actorId);
      if (denied != null) return Left(denied);
      await _write(
          user.id,
          UsersCompanion(
            name: Value(user.name.trim()),
            phone: Value(user.phone.trim()),
            // The owner can never be switched off.
            active: Value(user.isOwner || user.active),
          ));
      return Right((await getUser(user.id))!);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> changeOwnPin(
      {required String userId,
      required String currentPin,
      required String newPin}) async {
    try {
      final row = await _row(userId);
      if (row == null) return Left(NotFoundFailure(userId));
      if (!PinHasher.verify(currentPin, row.pinSalt, row.pinHash)) {
        return const Left(WrongSecretFailure('Wrong current PIN'));
      }
      final isOwner = row.role == UserRole.owner.name;
      final allowed =
          isOwner ? PinHasher.ownerLengths : [PinHasher.workerLength];
      if (!allowed.any((l) => PinHasher.isValidPin(newPin, length: l))) {
        return const Left(CacheFailure('Invalid PIN'));
      }
      await _write(userId, _newPin(newPin));
      return Right((await getUser(userId))!);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> resetWorkerPin(
      {required String actorId,
      required String workerId,
      required String newPin}) async {
    try {
      final denied =
          await _requireOwner(actorId) ?? await _requireWorker(workerId);
      if (denied != null) return Left(denied);
      if (!PinHasher.isValidPin(newPin)) {
        return const Left(CacheFailure('Invalid PIN'));
      }
      await _write(
          workerId, _newPin(newPin).copyWith(lockedOut: const Value(false)));
      return Right((await getUser(workerId))!);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> unlockWorker(
      {required String actorId, required String workerId}) async {
    try {
      final denied =
          await _requireOwner(actorId) ?? await _requireWorker(workerId);
      if (denied != null) return Left(denied);
      await _write(workerId, const UsersCompanion(lockedOut: Value(false)));
      return Right((await getUser(workerId))!);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<AppUser?> checkPin(String userId, String pin) async {
    final row = await _row(userId);
    if (row == null || !row.active) return null;
    return PinHasher.verify(pin, row.pinSalt, row.pinHash)
        ? userFromRow(row)
        : null;
  }

  @override
  Future<void> setLockedOut(String userId) =>
      _write(userId, const UsersCompanion(lockedOut: Value(true)));

  @override
  Future<bool> ownerHasRecoveryCode() async =>
      (await _ownerRow())?.recoveryHash != null;

  @override
  Future<Either<Failure, String>> createRecoveryCode(
      {required String ownerId, required String currentPin}) async {
    try {
      final row = await _row(ownerId);
      if (row == null || row.role != UserRole.owner.name) {
        return const Left(PermissionFailure('Owner only'));
      }
      if (!PinHasher.verify(currentPin, row.pinSalt, row.pinHash)) {
        return const Left(WrongSecretFailure('Wrong current PIN'));
      }
      final code = RecoveryCode.generate();
      await _saveRecoveryCode(ownerId, code);
      return Right(code);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OwnerSetup>> recoverOwner(
      {required String code, required String newPin}) async {
    try {
      final row = await _ownerRow();
      if (row == null) return const Left(NotFoundFailure('owner'));
      final hash = row.recoveryHash, salt = row.recoverySalt;
      final typed = RecoveryCode.normalize(code);
      if (hash == null ||
          salt == null ||
          !PinHasher.verify(typed, salt, hash)) {
        await logFailedLogin(row.id, FailedLoginKind.recovery);
        return const Left(WrongSecretFailure('Wrong recovery code'));
      }
      if (!PinHasher.ownerLengths
          .any((l) => PinHasher.isValidPin(newPin, length: l))) {
        return const Left(CacheFailure('Invalid PIN'));
      }
      // A used code is replaced at once, so it can never be used twice.
      final fresh = RecoveryCode.generate();
      await db.transaction(() async {
        await _write(
            row.id, _newPin(newPin).copyWith(lockedOut: const Value(false)));
        await _saveRecoveryCode(row.id, fresh);
      });
      return Right((owner: (await getUser(row.id))!, recoveryCode: fresh));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<void> logFailedLogin(String accountId, FailedLoginKind kind) {
    final now = DateTime.now();
    return db.into(db.failedLogins).insert(FailedLoginsCompanion.insert(
          id: const Uuid().v4(),
          createdAt: now,
          updatedAt: now,
          deviceId: settings.deviceId,
          accountId: accountId,
          kind: kind.name,
        ));
  }

  @override
  Future<List<FailedLogin>> getFailedLogins(
      {bool unseenOnly = false, int limit = 200}) async {
    final query = db.select(db.failedLogins).join([
      leftOuterJoin(db.users, db.users.id.equalsExp(db.failedLogins.accountId)),
    ])
      ..where(db.failedLogins.deleted.equals(false))
      ..orderBy([OrderingTerm.desc(db.failedLogins.createdAt)])
      ..limit(limit);
    if (unseenOnly) query.where(db.failedLogins.seen.equals(false));
    final rows = await query.get();
    return [
      for (final row in rows)
        FailedLogin(
          accountId: row.readTable(db.failedLogins).accountId,
          accountName: row.readTableOrNull(db.users)?.name ?? '?',
          kind: row.readTable(db.failedLogins).kind ==
                  FailedLoginKind.recovery.name
              ? FailedLoginKind.recovery
              : FailedLoginKind.pin,
          at: row.readTable(db.failedLogins).createdAt,
        ),
    ];
  }

  @override
  Future<void> markFailedLoginsSeen() async {
    await (db.update(db.failedLogins)..where((f) => f.seen.equals(false)))
        .write(FailedLoginsCompanion(
            seen: const Value(true), updatedAt: Value(DateTime.now())));
  }

  // ---------------------------------------------------------------------

  Future<UserRow?> _row(String id) => (db.select(db.users)
        ..where((u) => u.id.equals(id) & u.deleted.equals(false)))
      .getSingleOrNull();

  Future<UserRow?> _ownerRow() => (db.select(db.users)
        ..where(
            (u) => u.role.equals(UserRole.owner.name) & u.deleted.equals(false))
        ..limit(1))
      .getSingleOrNull();

  /// Null when [actorId] is the active owner, otherwise the refusal.
  Future<Failure?> _requireOwner(String actorId) async {
    final actor = await _row(actorId);
    if (actor == null || !actor.active || actor.role != UserRole.owner.name) {
      return const PermissionFailure('Owner only');
    }
    return null;
  }

  /// Null when [userId] is a worker account, otherwise the refusal.
  Future<Failure?> _requireWorker(String userId) async {
    final row = await _row(userId);
    if (row == null) return NotFoundFailure(userId);
    if (row.role != UserRole.worker.name) {
      return const PermissionFailure('Not a worker account');
    }
    return null;
  }

  UsersCompanion _newPin(String pin) {
    final salt = PinHasher.newSalt();
    return UsersCompanion(
      pinHash: Value(PinHasher.hash(pin, salt)),
      pinSalt: Value(salt),
      pinLength: Value(pin.length),
    );
  }

  Future<void> _saveRecoveryCode(String ownerId, String code) {
    final salt = PinHasher.newSalt();
    return _write(
        ownerId,
        UsersCompanion(
          recoveryHash:
              Value(PinHasher.hash(RecoveryCode.normalize(code), salt)),
          recoverySalt: Value(salt),
        ));
  }

  Future<void> _write(String userId, UsersCompanion changes) =>
      (db.update(db.users)..where((u) => u.id.equals(userId)))
          .write(changes.copyWith(updatedAt: Value(DateTime.now())));

  Future<AppUser> _insert(String name, String phone, String pin, UserRole role,
      String? createdBy) async {
    final now = DateTime.now();
    final id = const Uuid().v4();
    final salt = PinHasher.newSalt();
    await db.into(db.users).insert(UsersCompanion.insert(
          id: id,
          createdAt: now,
          updatedAt: now,
          deviceId: settings.deviceId,
          userId: Value(createdBy ?? id),
          name: name.trim(),
          phone: Value(phone.trim()),
          role: role.name,
          pinHash: PinHasher.hash(pin, salt),
          pinSalt: salt,
          pinLength: Value(pin.length),
        ));
    return (await getUser(id))!;
  }
}

AppUser userFromRow(UserRow row) => AppUser(
      id: row.id,
      name: row.name,
      phone: row.phone,
      role: row.role == UserRole.owner.name ? UserRole.owner : UserRole.worker,
      active: row.active,
      pinLength: row.pinLength,
      lockedOut: row.lockedOut,
    );
