import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/app_user.dart';

/// Result of creating the owner: the account and its recovery code,
/// which is shown once and never stored as is.
typedef OwnerSetup = ({AppUser owner, String recoveryCode});

/// Every method that changes someone else's account takes the [actorId]
/// of the logged-in person and checks in the database that they are
/// allowed to do it, so the rules hold even if a screen forgets one.
abstract class UserRepository {
  Future<bool> hasOwner();

  /// Everyone, owner first, then workers by name.
  Future<Either<Failure, List<AppUser>>> getUsers({bool activeOnly = false});

  Future<AppUser?> getUser(String id);

  /// Creates the one owner account with a 4- or 6-digit PIN. Sales and
  /// products made before accounts existed are given to the owner.
  Future<Either<Failure, OwnerSetup>> createOwner(
      {required String name, required String phone, required String pin});

  /// Owner only. Workers always have a 4-digit PIN.
  Future<Either<Failure, AppUser>> addWorker(
      {required String actorId,
      required String name,
      required String phone,
      required String pin});

  /// Owner only: name, phone and active. Never the PIN.
  Future<Either<Failure, AppUser>> updateUser(
      {required String actorId, required AppUser user});

  /// Anyone, for their OWN account only, with their current PIN.
  /// Only the owner may pick a 6-digit PIN.
  Future<Either<Failure, AppUser>> changeOwnPin(
      {required String userId,
      required String currentPin,
      required String newPin});

  /// Owner only, for a worker: sets a new PIN and unlocks the account.
  Future<Either<Failure, AppUser>> resetWorkerPin(
      {required String actorId,
      required String workerId,
      required String newPin});

  /// Owner only, for a worker locked after too many wrong PINs.
  Future<Either<Failure, AppUser>> unlockWorker(
      {required String actorId, required String workerId});

  /// The user when [pin] is right and the account is active, otherwise
  /// null. Locks are checked by the login service, not here.
  Future<AppUser?> checkPin(String userId, String pin);

  Future<void> setLockedOut(String userId);

  Future<bool> ownerHasRecoveryCode();

  /// Owner only, with their current PIN: makes a new recovery code (the
  /// old one stops working) and returns it to show once.
  Future<Either<Failure, String>> createRecoveryCode(
      {required String ownerId, required String currentPin});

  /// With the right recovery code: new owner PIN, account unlocked, and a
  /// fresh recovery code (the used one stops working).
  Future<Either<Failure, OwnerSetup>> recoverOwner(
      {required String code, required String newPin});

  Future<void> logFailedLogin(String accountId, FailedLoginKind kind);

  /// Newest first.
  Future<List<FailedLogin>> getFailedLogins(
      {bool unseenOnly = false, int limit = 200});

  Future<void> markFailedLoginsSeen();
}
