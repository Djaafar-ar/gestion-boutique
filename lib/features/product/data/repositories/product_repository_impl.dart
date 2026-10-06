import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/settings/settings_store.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_change.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  static const _entity = 'product';

  final AppDatabase db;
  final SettingsStore settings;
  final SessionCubit session;

  ProductRepositoryImpl(this.db, this.settings, this.session);

  /// Products that can be sold: not deleted and not archived.
  SimpleSelectStatement<$ProductsTable, ProductRow> _active() =>
      db.select(db.products)
        ..where((p) => p.deleted.equals(false) & p.archived.equals(false));

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final rows = await (_active()
            ..orderBy(
                [(p) => OrderingTerm.asc(p.name.collate(Collate.noCase))]))
          .get();
      return Right(rows.map(productFromRow).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductByBarcode(String barcode) async {
    try {
      final row = await (_active()
            ..where((p) => p.barcode.equals(barcode))
            ..limit(1))
          .getSingleOrNull();
      if (row == null) return Left(NotFoundFailure(barcode));
      return Right(productFromRow(row));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addProduct(Product product) async {
    try {
      final now = DateTime.now();
      await db.into(db.products).insert(ProductsCompanion.insert(
            id: product.id,
            createdAt: now,
            updatedAt: now,
            deviceId: settings.deviceId,
            userId: Value(session.userId),
            name: product.name,
            barcode: product.barcode,
            sellPrice: product.sellPrice,
            buyPrice: Value(product.buyPrice),
            categoryId: Value(product.categoryId),
            lowStockThreshold: Value(product.lowStockThreshold),
          ));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(Product product) async {
    try {
      await db.transaction(() async {
        final before = await (db.select(db.products)
              ..where((p) => p.id.equals(product.id)))
            .getSingle();
        final now = DateTime.now();

        await (db.update(db.products)..where((p) => p.id.equals(product.id)))
            .write(ProductsCompanion(
          updatedAt: Value(now),
          name: Value(product.name),
          barcode: Value(product.barcode),
          sellPrice: Value(product.sellPrice),
          buyPrice: Value(product.buyPrice),
          categoryId: Value(product.categoryId),
          lowStockThreshold: Value(product.lowStockThreshold),
          archived: Value(product.archived),
        ));

        final categories =
            await _categoryNames([before.categoryId, product.categoryId]);
        final changes = <ProductField, (Object?, Object?)>{
          ProductField.name: (before.name, product.name),
          ProductField.barcode: (before.barcode, product.barcode),
          ProductField.sellPrice: (before.sellPrice, product.sellPrice),
          ProductField.buyPrice: (before.buyPrice, product.buyPrice),
          // Category names are kept, so the history stays readable.
          ProductField.category: (
            categories[before.categoryId],
            categories[product.categoryId]
          ),
          ProductField.lowStockThreshold: (
            before.lowStockThreshold,
            product.lowStockThreshold
          ),
          ProductField.archived: (before.archived, product.archived),
        };
        for (final MapEntry(key: field, value: (oldValue, newValue))
            in changes.entries) {
          if (oldValue != newValue) {
            await _log(product.id, field, oldValue, newValue, now);
          }
        }
      });
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  /// Hides the product. It is never erased because old sales point to it.
  @override
  Future<Either<Failure, void>> archiveProduct(String id) async {
    try {
      await db.transaction(() async {
        final now = DateTime.now();
        await (db.update(db.products)..where((p) => p.id.equals(id))).write(
            ProductsCompanion(
                archived: const Value(true), updatedAt: Value(now)));
        await _log(id, ProductField.archived, false, true, now);
      });
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductChange>>> getHistory(
      String productId) async {
    try {
      final query = db.select(db.changeLogs).join([
        leftOuterJoin(db.users, db.users.id.equalsExp(db.changeLogs.userId)),
      ])
        ..where(db.changeLogs.entity.equals(_entity) &
            db.changeLogs.entityId.equals(productId) &
            db.changeLogs.deleted.equals(false))
        ..orderBy([OrderingTerm.desc(db.changeLogs.createdAt)]);
      final rows = await query.get();
      final changes = <ProductChange>[];
      for (final row in rows) {
        final log = row.readTable(db.changeLogs);
        final field =
            ProductField.values.where((f) => f.name == log.field).firstOrNull;
        if (field == null) continue; // written by a newer app version
        changes.add(ProductChange(
          field: field,
          oldValue: log.oldValue,
          newValue: log.newValue,
          userName: row.readTableOrNull(db.users)?.name,
          at: log.createdAt,
        ));
      }
      return Right(changes);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final rows = await (db.select(db.categories)
            ..where((c) => c.deleted.equals(false))
            ..orderBy(
                [(c) => OrderingTerm.asc(c.name.collate(Collate.noCase))]))
          .get();
      return Right(rows.map((r) => Category(id: r.id, name: r.name)).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> addCategory(String name) async {
    try {
      final trimmed = name.trim();
      // Reuse a category with the same name instead of making a double.
      final existing = await (db.select(db.categories)
            ..where((c) =>
                c.deleted.equals(false) &
                c.name.lower().equals(trimmed.toLowerCase())))
          .getSingleOrNull();
      if (existing != null) {
        return Right(Category(id: existing.id, name: existing.name));
      }
      final now = DateTime.now();
      final id = const Uuid().v4();
      await db.into(db.categories).insert(CategoriesCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            deviceId: settings.deviceId,
            userId: Value(session.userId),
            name: trimmed,
          ));
      return Right(Category(id: id, name: trimmed));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<Map<String?, String>> _categoryNames(List<String?> ids) async {
    final wanted = ids.whereType<String>().toSet();
    if (wanted.isEmpty) return {};
    final rows =
        await (db.select(db.categories)..where((c) => c.id.isIn(wanted))).get();
    return {for (final r in rows) r.id: r.name};
  }

  Future<void> _log(String productId, ProductField field, Object? oldValue,
      Object? newValue, DateTime at) {
    return db.into(db.changeLogs).insert(ChangeLogsCompanion.insert(
          id: const Uuid().v4(),
          createdAt: at,
          updatedAt: at,
          deviceId: settings.deviceId,
          userId: Value(session.userId),
          entity: _entity,
          entityId: productId,
          field: field.name,
          oldValue: Value(oldValue?.toString()),
          newValue: Value(newValue?.toString()),
        ));
  }
}

Product productFromRow(ProductRow row) => Product(
      id: row.id,
      name: row.name,
      barcode: row.barcode,
      sellPrice: row.sellPrice,
      buyPrice: row.buyPrice,
      categoryId: row.categoryId,
      lowStockThreshold: row.lowStockThreshold,
      archived: row.archived,
    );
