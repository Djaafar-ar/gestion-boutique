import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';

/// One line of a saved sale. Name and prices are the ones at sale time.
class SaleLine extends Equatable {
  /// Id of the sale line (needed to return items).
  final String id;
  final String productId;
  final String productName;
  final int sellPrice; // centimes
  final int unitCost; // centimes
  final int quantity;

  /// How many of these items customers already brought back.
  final int returned;

  const SaleLine({
    this.id = '',
    required this.productId,
    required this.productName,
    required this.sellPrice,
    required this.unitCost,
    required this.quantity,
    this.returned = 0,
  });

  int get total => sellPrice * quantity;

  /// Items that can still be returned.
  int get returnable => quantity - returned;

  @override
  List<Object?> get props =>
      [id, productId, productName, sellPrice, unitCost, quantity, returned];
}

class Sale extends Equatable {
  final String id;
  final int number;
  final int subtotal; // centimes
  final int discount; // centimes
  final int total; // centimes
  final int paidNow; // centimes
  final DateTime createdAt;

  /// Who made the sale (null for sales made before accounts existed).
  final String? userId;
  final String? sellerName;
  final List<SaleLine> items;

  /// Money already given back for returns (centimes).
  final int refunded;

  /// The customer of a credit sale (null for a cash sale).
  final String? customerId;
  final String? customerName;

  const Sale({
    required this.id,
    required this.number,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.paidNow,
    required this.createdAt,
    this.userId,
    this.sellerName,
    required this.items,
    this.refunded = 0,
    this.customerId,
    this.customerName,
  });

  /// A sale put (partly) on a customer's account.
  bool get isCredit => customerId != null;

  /// What was not paid at the counter and went on the customer's debt.
  int get onCredit => total - paidNow;

  int get itemCount => items.fold(0, (sum, line) => sum + line.quantity);

  bool get hasReturnableItems => items.any((l) => l.returnable > 0);

  /// Money given back for [quantity] items of [line]: the sale's discount
  /// is shared out, so a 10 % discount also lowers the refund by 10 %.
  int refundFor(SaleLine line, int quantity) => subtotal == 0
      ? 0
      : (line.sellPrice * quantity * total / subtotal).round();

  @override
  List<Object?> get props => [
        id,
        number,
        subtotal,
        discount,
        total,
        paidNow,
        createdAt,
        userId,
        items,
        refunded,
        customerId,
        customerName
      ];
}

/// Totals for a period: money taken (after discounts and returns),
/// number of tickets, items sold.
class SalesSummary extends Equatable {
  final int revenue; // centimes
  final int salesCount;
  final int itemsSold;

  const SalesSummary({
    required this.revenue,
    required this.salesCount,
    required this.itemsSold,
  });

  static const empty = SalesSummary(revenue: 0, salesCount: 0, itemsSold: 0);

  @override
  List<Object?> get props => [revenue, salesCount, itemsSold];
}

/// A discount for the whole ticket: an amount or a percentage.
class Discount extends Equatable {
  final bool isPercent;

  /// Centimes for an amount, or a whole percentage (10 = 10 %).
  final int value;

  const Discount.amount(this.value) : isPercent = false;
  const Discount.percent(this.value) : isPercent = true;

  /// The discount in centimes for a [subtotal], never more than it.
  int centimesOf(int subtotal) {
    final raw = isPercent ? (subtotal * value / 100).round() : value;
    return raw.clamp(0, subtotal);
  }

  @override
  List<Object?> get props => [isPercent, value];
}

/// A worker tried to give more discount than the owner allows.
class DiscountLimitFailure extends Failure {
  final int maxPercent;
  const DiscountLimitFailure(this.maxPercent)
      : super('Discount above $maxPercent %');
}

/// One line of a return: which sale line, how many, and whether the
/// items go back on the shelf or are damaged.
class ReturnLine extends Equatable {
  final String saleItemId;
  final int quantity;
  final bool backToStock;

  const ReturnLine(
      {required this.saleItemId,
      required this.quantity,
      required this.backToStock});

  @override
  List<Object?> get props => [saleItemId, quantity, backToStock];
}
