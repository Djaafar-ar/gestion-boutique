import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/app_user.dart';

abstract class UserRepository {
  Future<bool> hasOwner();

  /// Everyone, owner first, then workers by name.
  Future<Either<Failure, List<AppUser>>> getUsers({bool activeOnly = false});

  /// Creates the one owner account. Sales and products made before
  /// accounts existed are given to the owner.
  Future<Either<Failure, AppUser>> createOwner(
      {required String name, required String phone, required String pin});

  Future<Either<Failure, AppUser>> addWorker(
      {required String name, required String phone, required String pin});

  /// Saves name, phone and active; also changes the PIN when [newPin] is set.
  Future<Either<Failure, AppUser>> updateUser(AppUser user, {String? newPin});

  /// The user when [pin] is right and the account is active, otherwise null.
  Future<AppUser?> checkPin(String userId, String pin);
}
