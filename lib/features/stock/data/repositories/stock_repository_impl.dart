import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/settings/settings_store.dart';
import '../../../product/data/repositories/product_repository_impl.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../domain/entities/loss.dart';
import '../../domain/entities/stock_batch.dart';
import '../../domain/repositories/stock_repository.dart';
import '../stock_ledger.dart';

class StockRepositoryImpl implements StockRepository {
  final AppDatabase db;
  final SettingsStore settings;
  final SessionCubit session;
  final StockLedger ledger;
  final ProductRepository products;

  StockRepositoryImpl(
      this.db, this.settings, this.session, this.ledger, this.products);

  @override
  Future<Either<Failure, Map<String, ProductStock>>> getOverview() async {
    try {
      final all = await ledger.allBatches();
      return Right({
        for (final MapEntry(key: id, value: state) in all.entries)
          id: ProductStock(
            quantity: state.stock,
            nextExpiry: state.onShelf
                .map((b) => b.expiryDate)
                .whereType<DateTime>()
                .fold<DateTime?>(
                    null, (min, e) => min == null || e.isBefore(min) ? e : min),
          ),
      });
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ({List<StockBatch> batches, int stock})>> getBatches(
      String productId) async {
    try {
      final state = await ledger.batchesOf(productId);
      return Right((batches: state.batches, stock: state.stock));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addDelivery({
    required String productId,
    required int quantity,
    required int buyPrice,
    DateTime? expiryDate,
    String? note,
    String? supplierId,
    bool updateProductBuyPrice = false,
  }) async {
    if (quantity <= 0) return const Left(CacheFailure('Quantity must be > 0'));
    try {
      final now = DateTime.now();
      await db.into(db.deliveries).insert(DeliveriesCompanion.insert(
            id: const Uuid().v4(),
            createdAt: now,
            updatedAt: now,
            deviceId: settings.deviceId,
            userId: Value(session.userId),
            productId: productId,
            quantity: quantity,
            buyPrice: buyPrice,
            expiryDate: Value(expiryDate == null
                ? null
                : DateTime(expiryDate.year, expiryDate.month, expiryDate.day)),
            receivedAt: now,
            supplierId: Value(supplierId),
            note: Value(note?.trim().isEmpty ?? true ? null : note!.trim()),
          ));
      if (updateProductBuyPrice) {
        final row = await (db.select(db.products)
              ..where((p) => p.id.equals(productId)))
            .getSingle();
        if (row.buyPrice != buyPrice) {
          // Goes through the product code so the change is in the history.
          await products
              .updateProduct(productFromRow(row).copyWith(buyPrice: buyPrice));
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Loss>> recordLoss({
    required String productId,
    required int quantity,
    required LossReason reason,
    String? note,
    String? deliveryId,
  }) async {
    if (quantity <= 0) return const Left(CacheFailure('Quantity must be > 0'));
    try {
      final id = const Uuid().v4();
      await db.transaction(() async {
        final now = DateTime.now();
        final product = await (db.select(db.products)
              ..where((p) => p.id.equals(productId)))
            .getSingle();
        final unitCost = await ledger.takeOut(
          productId: productId,
          quantity: quantity,
          source: 'loss',
          sourceId: id,
          preferred: deliveryId,
          fallbackCost: product.buyPrice,
          deviceId: settings.deviceId,
          userId: session.userId,
          at: now,
        );
        await db.into(db.losses).insert(LossesCompanion.insert(
              id: id,
              createdAt: now,
              updatedAt: now,
              deviceId: settings.deviceId,
              userId: Value(session.userId),
              productId: productId,
              quantity: quantity,
              reason: reason.name,
              note: Value(note?.trim().isEmpty ?? true ? null : note!.trim()),
              unitCost: unitCost,
              deliveryId: Value(deliveryId),
            ));
      });
      final losses = await _losses(id: id);
      return Right(losses.single);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Loss>>> getLosses(
      {DateTime? from, DateTime? to, String? userId}) async {
    try {
      return Right(await _losses(from: from, to: to, userId: userId));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LossSummary>> getLossSummary(
      {DateTime? from, DateTime? to, String? userId}) async {
    try {
      final losses = await _losses(from: from, to: to, userId: userId);
      return Right(LossSummary(
        count: losses.length,
        items: losses.fold(0, (sum, l) => sum + l.quantity),
        value: losses.fold(0, (sum, l) => sum + l.value),
      ));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<List<Loss>> _losses(
      {String? id, DateTime? from, DateTime? to, String? userId}) async {
    final query = db.select(db.losses).join([
      innerJoin(db.products, db.products.id.equalsExp(db.losses.productId)),
      leftOuterJoin(db.users, db.users.id.equalsExp(db.losses.userId)),
    ])
      ..where(db.losses.deleted.equals(false))
      ..orderBy([OrderingTerm.desc(db.losses.createdAt)]);
    if (id != null) query.where(db.losses.id.equals(id));
    if (from != null) {
      query.where(db.losses.createdAt.isBiggerOrEqualValue(from));
    }
    if (to != null) query.where(db.losses.createdAt.isSmallerThanValue(to));
    if (userId != null) query.where(db.losses.userId.equals(userId));

    return [
      for (final row in await query.get())
        _toLoss(row.readTable(db.losses), row.readTable(db.products).name,
            row.readTableOrNull(db.users)?.name),
    ];
  }

  Loss _toLoss(LossRow row, String productName, String? userName) => Loss(
        id: row.id,
        productId: row.productId,
        productName: productName,
        quantity: row.quantity,
        reason: LossReason.values.firstWhere((r) => r.name == row.reason,
            orElse: () => LossReason.other),
        note: row.note,
        unitCost: row.unitCost,
        userName: userName,
        at: row.createdAt,
        fromReturn: row.returnItemId != null,
      );
}
