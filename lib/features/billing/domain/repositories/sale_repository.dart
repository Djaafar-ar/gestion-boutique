import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/cart_item.dart';
import '../entities/sale.dart';

abstract class SaleRepository {
  /// Saves the cart as a new sale with the next ticket number, signed by
  /// the logged-in user. Items leave the stock "expires first" first.
  /// A worker's [discount] (centimes) may not pass the owner's limit
  /// ([DiscountLimitFailure]).
  ///
  /// With [customerId] it is a credit sale: [paidNow] (default 0) is paid
  /// at the counter and the rest goes on the customer's debt. Going over
  /// the customer's credit limit gives a [CreditLimitFailure], unless the
  /// owner confirms with [allowOverLimit] (a worker never can).
  Future<Either<Failure, Sale>> saveSale(List<CartItem> items,
      {int discount = 0,
      String? customerId,
      int paidNow = 0,
      bool allowOverLimit = false});

  /// What a customer owes right now (centimes), for the receipt.
  Future<int> customerDebt(String customerId);

  /// The highest discount the logged-in person may give, in percent, or
  /// null for no limit (the owner).
  Future<int?> maxDiscountPercent();

  /// Sales between [from] (included) and [to] (excluded), newest first.
  /// With [userId], only that person's sales; with [number], only that
  /// ticket.
  Future<Either<Failure, List<Sale>>> getSales(
      {DateTime? from, DateTime? to, String? userId, int? number});

  Future<Either<Failure, Sale>> getSale(String id);

  /// Totals for a period, for everyone or only [userId]. Returns made in
  /// the period are taken off the revenue of the person who sold.
  Future<Either<Failure, SalesSummary>> getSummary(
      {DateTime? from, DateTime? to, String? userId});

  /// Customer brings items back: items back on the shelf (same batch) or
  /// recorded as a loss when damaged. The refund is given in cash, or for
  /// a credit sale with [toCredit] taken off the customer's debt.
  /// Returns the refund (centimes).
  Future<Either<Failure, int>> createReturn(
      {required String saleId,
      required List<ReturnLine> lines,
      String? reason,
      bool toCredit = false});
}
