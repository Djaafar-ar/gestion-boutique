import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/loss.dart';
import '../entities/stock_batch.dart';

abstract class StockRepository {
  /// Stock of every product, by product id.
  Future<Either<Failure, Map<String, ProductStock>>> getOverview();

  /// Batches of one product, "expires first" first, and the total.
  Future<Either<Failure, ({List<StockBatch> batches, int stock})>> getBatches(
      String productId);

  /// Records a delivery, signed by the logged-in person, optionally from
  /// [supplierId] (what the shop owes them goes up). When
  /// [updateProductBuyPrice] is true the product's buying price becomes
  /// [buyPrice] (written in the product history).
  Future<Either<Failure, void>> addDelivery({
    required String productId,
    required int quantity,
    required int buyPrice,
    DateTime? expiryDate,
    String? note,
    String? supplierId,
    bool updateProductBuyPrice = false,
  });

  /// Takes the items out of the stock (from [deliveryId] first if given)
  /// and records the loss at buying price.
  Future<Either<Failure, Loss>> recordLoss({
    required String productId,
    required int quantity,
    required LossReason reason,
    String? note,
    String? deliveryId,
  });

  /// Newest first.
  Future<Either<Failure, List<Loss>>> getLosses(
      {DateTime? from, DateTime? to, String? userId});

  Future<Either<Failure, LossSummary>> getLossSummary(
      {DateTime? from, DateTime? to, String? userId});
}
