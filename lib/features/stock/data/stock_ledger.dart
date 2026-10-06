import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/entities/stock_batch.dart';
import '../domain/stock_math.dart';

/// Reads and writes stock movements. Used inside the transactions of
/// sales, losses and returns, so a movement is never saved half-way.
class StockLedger {
  final AppDatabase db;

  StockLedger(this.db);

  /// Batches of one product with what is left in each.
  Future<BatchState> batchesOf(String productId) async {
    final all = await _compute(productId: productId);
    return all[productId] ?? const BatchState([], 0);
  }

  /// Batches of every product (for the Stock list).
  Future<Map<String, BatchState>> allBatches() => _compute();

  /// Takes [quantity] items out ("expires first" first, or [preferred]
  /// first) and returns the average buying price of those items.
  /// Items with no stock left are still recorded, priced [fallbackCost].
  Future<int> takeOut({
    required String productId,
    required int quantity,
    required String source,
    required String sourceId,
    required int fallbackCost,
    required String deviceId,
    required String? userId,
    required DateTime at,
    String? preferred,
  }) async {
    final state = await batchesOf(productId);
    final plan = planTakeOut(state, quantity,
        preferred: preferred, fallbackCost: fallbackCost);
    for (final (index, part) in plan.indexed) {
      await _insert(
        productId: productId,
        deliveryId: part.deliveryId,
        quantity: part.quantity,
        source: source,
        sourceId: sourceId,
        deviceId: deviceId,
        userId: userId,
        // Keeps the order of the parts when read back.
        at: at.add(Duration(milliseconds: index)),
      );
    }
    return averageCost(plan);
  }

  /// Puts returned items of a sale line back into the batches they came
  /// from. Sales made before stock tracking have nothing to put back.
  Future<void> putBack({
    required String productId,
    required String saleItemId,
    required int quantity,
    required String deviceId,
    required String? userId,
    required DateTime at,
  }) async {
    final moves = await (db.select(db.stockAllocations)
          ..where(
              (a) => a.sourceId.equals(saleItemId) & a.deleted.equals(false))
          ..orderBy([(a) => OrderingTerm.asc(a.createdAt)]))
        .get();
    // Per batch, in the order taken: items of this line still out.
    final outstanding = <String?, int>{};
    for (final move in moves) {
      outstanding[move.deliveryId] =
          (outstanding[move.deliveryId] ?? 0) + move.quantity;
    }
    final plan = planPutBack(
      [
        for (final entry in outstanding.entries)
          (deliveryId: entry.key, quantity: entry.value),
      ],
      quantity,
    );
    for (final (index, part) in plan.indexed) {
      await _insert(
        productId: productId,
        deliveryId: part.deliveryId,
        quantity: -part.quantity,
        source: 'return',
        sourceId: saleItemId,
        deviceId: deviceId,
        userId: userId,
        at: at.add(Duration(milliseconds: index)),
      );
    }
  }

  Future<Map<String, BatchState>> _compute({String? productId}) async {
    final deliveryQuery = db.select(db.deliveries).join([
      leftOuterJoin(db.users, db.users.id.equalsExp(db.deliveries.userId)),
    ])
      ..where(db.deliveries.deleted.equals(false));
    if (productId != null) {
      deliveryQuery.where(db.deliveries.productId.equals(productId));
    }
    final deliveries = await deliveryQuery.get();

    final taken = db.stockAllocations.quantity.sum();
    final takenQuery = db.selectOnly(db.stockAllocations)
      ..addColumns([
        db.stockAllocations.productId,
        db.stockAllocations.deliveryId,
        taken,
      ])
      ..where(db.stockAllocations.deleted.equals(false))
      ..groupBy(
          [db.stockAllocations.productId, db.stockAllocations.deliveryId]);
    if (productId != null) {
      takenQuery.where(db.stockAllocations.productId.equals(productId));
    }
    final takenRows = await takenQuery.get();

    final batchesByProduct = <String, List<StockBatch>>{};
    for (final row in deliveries) {
      final d = row.readTable(db.deliveries);
      batchesByProduct.putIfAbsent(d.productId, () => []).add(StockBatch(
            deliveryId: d.id,
            productId: d.productId,
            quantity: d.quantity,
            remaining: d.quantity,
            buyPrice: d.buyPrice,
            expiryDate: d.expiryDate,
            receivedAt: d.receivedAt,
            receivedByName: row.readTableOrNull(db.users)?.name,
            note: d.note,
          ));
    }
    final takenByProduct = <String, Map<String?, int>>{};
    for (final row in takenRows) {
      final product = row.read(db.stockAllocations.productId)!;
      takenByProduct.putIfAbsent(
              product, () => {})[row.read(db.stockAllocations.deliveryId)] =
          row.read(taken) ?? 0;
    }

    return {
      for (final id in {...batchesByProduct.keys, ...takenByProduct.keys})
        id: computeBatches(
            batchesByProduct[id] ?? [], takenByProduct[id] ?? {}),
    };
  }

  Future<void> _insert({
    required String productId,
    required String? deliveryId,
    required int quantity,
    required String source,
    required String sourceId,
    required String deviceId,
    required String? userId,
    required DateTime at,
  }) {
    return db.into(db.stockAllocations).insert(StockAllocationsCompanion.insert(
          id: const Uuid().v4(),
          createdAt: at,
          updatedAt: at,
          deviceId: deviceId,
          userId: Value(userId),
          productId: productId,
          deliveryId: Value(deliveryId),
          quantity: quantity,
          source: source,
          sourceId: sourceId,
        ));
  }
}
