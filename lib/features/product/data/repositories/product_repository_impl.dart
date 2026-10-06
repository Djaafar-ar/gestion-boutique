import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/settings/settings_store.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final AppDatabase db;
  final SettingsStore settings;

  ProductRepositoryImpl(this.db, this.settings);

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
      await (db.update(db.products)..where((p) => p.id.equals(product.id)))
          .write(ProductsCompanion(
        updatedAt: Value(DateTime.now()),
        name: Value(product.name),
        barcode: Value(product.barcode),
        sellPrice: Value(product.sellPrice),
        buyPrice: Value(product.buyPrice),
        categoryId: Value(product.categoryId),
        lowStockThreshold: Value(product.lowStockThreshold),
        archived: Value(product.archived),
      ));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  /// Hides the product. It is never erased because old sales point to it.
  @override
  Future<Either<Failure, void>> archiveProduct(String id) async {
    try {
      await (db.update(db.products)..where((p) => p.id.equals(id))).write(
          ProductsCompanion(
              archived: const Value(true), updatedAt: Value(DateTime.now())));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
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
