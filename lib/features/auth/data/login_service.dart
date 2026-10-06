import 'package:fpdart/fpdart.dart';

import '../../../core/error/failure.dart';
import '../../users/domain/entities/app_user.dart';
import '../../users/domain/repositories/user_repository.dart';
import 'login_guard.dart';

/// Result of typing a PIN on the login screen.
sealed class LoginResult {
  const LoginResult();
}

class LoginSuccess extends LoginResult {
  final AppUser user;
  const LoginSuccess(this.user);
}

class LoginWrongPin extends LoginResult {
  /// Tries left before the next wait.
  final int triesLeft;
  const LoginWrongPin(this.triesLeft);
}

class LoginMustWait extends LoginResult {
  final Duration wait;
  const LoginMustWait(this.wait);
}

class LoginLockedOut extends LoginResult {
  const LoginLockedOut();
}

/// The login rules in one place: waits, account locks, the record of
/// every failed attempt, and unlocking.
class LoginService {
  final UserRepository users;
  final LoginGuard guard;

  LoginService(this.users, this.guard);

  /// What the login screen should show before anyone types: null when a
  /// PIN can be typed now.
  Future<LoginResult?> status(String userId) async {
    final user = await users.getUser(userId);
    if (user == null || user.lockedOut) return const LoginLockedOut();
    final wait = guard.remainingWait(userId);
    return wait > Duration.zero ? LoginMustWait(wait) : null;
  }

  Future<LoginResult> tryPin(String userId, String pin) async {
    final blocked = await status(userId);
    // Even the right PIN is refused during a wait or a lock.
    if (blocked != null) return blocked;

    final user = await users.checkPin(userId, pin);
    if (user != null) {
      await guard.reset(userId);
      return LoginSuccess(user);
    }

    await users.logFailedLogin(userId, FailedLoginKind.pin);
    switch (await guard.recordFailure(userId)) {
      case LockOut():
        await users.setLockedOut(userId);
        return const LoginLockedOut();
      case MustWait(:final wait):
        return LoginMustWait(wait);
      case TryAgain(:final triesLeft):
        return LoginWrongPin(triesLeft);
    }
  }

  /// Owner forgot or locked their PIN: the recovery code sets a new one.
  Future<Either<Failure, OwnerSetup>> recoverOwner(
      {required String code, required String newPin}) async {
    final result = await users.recoverOwner(code: code, newPin: newPin);
    final owner = result.toNullable()?.owner;
    if (owner != null) await guard.reset(owner.id);
    return result;
  }

  /// Owner only: unlocks a worker locked after too many wrong PINs.
  Future<Either<Failure, AppUser>> unlockWorker(
      {required String actorId, required String workerId}) async {
    final result =
        await users.unlockWorker(actorId: actorId, workerId: workerId);
    if (result.isRight()) await guard.reset(workerId);
    return result;
  }

  /// Owner only: gives a worker a new PIN (and unlocks them).
  Future<Either<Failure, AppUser>> resetWorkerPin(
      {required String actorId,
      required String workerId,
      required String newPin}) async {
    final result = await users.resetWorkerPin(
        actorId: actorId, workerId: workerId, newPin: newPin);
    if (result.isRight()) await guard.reset(workerId);
    return result;
  }
}
