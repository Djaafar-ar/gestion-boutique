import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/cart_item.dart';
import '../entities/sale.dart';

abstract class SaleRepository {
  /// Saves the cart as a new sale with the next ticket number, signed by
  /// the logged-in user.
  Future<Either<Failure, Sale>> saveSale(List<CartItem> items);

  /// Sales between [from] (included) and [to] (excluded), newest first.
  /// With [userId], only that person's sales.
  Future<Either<Failure, List<Sale>>> getSales(
      {DateTime? from, DateTime? to, String? userId});

  Future<Either<Failure, Sale>> getSale(String id);

  /// Totals for a period, for everyone or only [userId].
  Future<Either<Failure, SalesSummary>> getSummary(
      {DateTime? from, DateTime? to, String? userId});
}
