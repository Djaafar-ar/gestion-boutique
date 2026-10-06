import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/security/pin_hasher.dart';
import '../../../../core/settings/settings_store.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final AppDatabase db;
  final SettingsStore settings;

  UserRepositoryImpl(this.db, this.settings);

  @override
  Future<bool> hasOwner() async {
    final owner = await (db.select(db.users)
          ..where((u) => u.role.equals(UserRole.owner.name))
          ..where((u) => u.deleted.equals(false))
          ..limit(1))
        .getSingleOrNull();
    return owner != null;
  }

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
  Future<Either<Failure, AppUser>> createOwner(
      {required String name,
      required String phone,
      required String pin}) async {
    try {
      if (await hasOwner()) {
        return const Left(CacheFailure('The owner already exists'));
      }
      final owner = await db.transaction(() async {
        final owner = await _insert(name, phone, pin, UserRole.owner, null);
        // Before accounts existed, only the owner used the app.
        await (db.update(db.sales)..where((s) => s.userId.isNull()))
            .write(SalesCompanion(userId: Value(owner.id)));
        await (db.update(db.saleItems)..where((s) => s.userId.isNull()))
            .write(SaleItemsCompanion(userId: Value(owner.id)));
        await (db.update(db.products)..where((p) => p.userId.isNull()))
            .write(ProductsCompanion(userId: Value(owner.id)));
        return owner;
      });
      return Right(owner);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> addWorker(
      {required String name,
      required String phone,
      required String pin}) async {
    try {
      final ownerId = await (db.select(db.users)
            ..where((u) => u.role.equals(UserRole.owner.name)))
          .map((u) => u.id)
          .getSingleOrNull();
      return Right(await _insert(name, phone, pin, UserRole.worker, ownerId));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> updateUser(AppUser user,
      {String? newPin}) async {
    try {
      final salt = PinHasher.newSalt();
      await (db.update(db.users)..where((u) => u.id.equals(user.id)))
          .write(UsersCompanion(
        updatedAt: Value(DateTime.now()),
        name: Value(user.name.trim()),
        phone: Value(user.phone.trim()),
        // The owner can never be switched off.
        active: Value(user.isOwner || user.active),
        pinSalt: newPin == null ? const Value.absent() : Value(salt),
        pinHash: newPin == null
            ? const Value.absent()
            : Value(PinHasher.hash(newPin, salt)),
      ));
      final row = await (db.select(db.users)
            ..where((u) => u.id.equals(user.id)))
          .getSingle();
      return Right(userFromRow(row));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<AppUser?> checkPin(String userId, String pin) async {
    final row = await (db.select(db.users)
          ..where((u) => u.id.equals(userId))
          ..where((u) => u.deleted.equals(false) & u.active.equals(true)))
        .getSingleOrNull();
    if (row == null) return null;
    return PinHasher.verify(pin, row.pinSalt, row.pinHash)
        ? userFromRow(row)
        : null;
  }

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
        ));
    return AppUser(id: id, name: name.trim(), phone: phone.trim(), role: role);
  }
}

AppUser userFromRow(UserRow row) => AppUser(
      id: row.id,
      name: row.name,
      phone: row.phone,
      role: row.role == UserRole.owner.name ? UserRole.owner : UserRole.worker,
      active: row.active,
    );
