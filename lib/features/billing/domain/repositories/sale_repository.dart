import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/cart_item.dart';
import '../entities/sale.dart';

abstract class SaleRepository {
  /// Saves the cart as a new sale with the next ticket number.
  Future<Either<Failure, Sale>> saveSale(List<CartItem> items);

  /// Sales between [from] (included) and [to] (excluded), newest first.
  Future<Either<Failure, List<Sale>>> getSales({DateTime? from, DateTime? to});

  Future<Either<Failure, Sale>> getSale(String id);
}
