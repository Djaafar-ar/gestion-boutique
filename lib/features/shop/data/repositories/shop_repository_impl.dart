import 'dart:math';

import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/settings/settings_store.dart';
import '../../domain/entities/shop.dart';
import '../../domain/repositories/shop_repository.dart';

class ShopRepositoryImpl implements ShopRepository {
  final AppDatabase db;
  final SettingsStore settings;

  ShopRepositoryImpl(this.db, this.settings);

  @override
  Future<Either<Failure, Shop>> getShop() async {
    try {
      final row = await currentShopRow(db);
      return Right(row == null ? const Shop() : shopFromRow(row));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateShop(Shop shop) async {
    try {
      final row = await currentShopRow(db);
      final now = DateTime.now();
      if (row == null) {
        await db.into(db.shops).insert(ShopsCompanion.insert(
              id: const Uuid().v4(),
              createdAt: now,
              updatedAt: now,
              deviceId: settings.deviceId,
              name: shop.name,
              address1: Value(shop.addressLine1),
              address2: Value(shop.addressLine2),
              phone: Value(shop.phoneNumber),
              footer: Value(shop.footerText),
              shopSecret: newShopSecret(),
            ));
      } else {
        await (db.update(db.shops)..where((s) => s.id.equals(row.id)))
            .write(ShopsCompanion(
          updatedAt: Value(now),
          name: Value(shop.name),
          address1: Value(shop.addressLine1),
          address2: Value(shop.addressLine2),
          phone: Value(shop.phoneNumber),
          footer: Value(shop.footerText),
        ));
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}

/// There is only one shop per database.
Future<ShopRow?> currentShopRow(AppDatabase db) => (db.select(db.shops)
      ..where((s) => s.deleted.equals(false))
      ..limit(1))
    .getSingleOrNull();

Shop shopFromRow(ShopRow row) => Shop(
      name: row.name,
      addressLine1: row.address1,
      addressLine2: row.address2,
      phoneNumber: row.phone,
      footerText: row.footer,
    );

/// 32 random bytes as hex. Paired phones use it to prove they belong
/// to this shop.
String newShopSecret() {
  final random = Random.secure();
  return List.generate(32, (_) => random.nextInt(256))
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
}
