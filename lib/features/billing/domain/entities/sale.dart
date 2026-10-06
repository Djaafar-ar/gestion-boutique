import 'package:equatable/equatable.dart';

/// One line of a saved sale. Name and prices are the ones at sale time.
class SaleLine extends Equatable {
  final String productId;
  final String productName;
  final int sellPrice; // centimes
  final int unitCost; // centimes
  final int quantity;

  const SaleLine({
    required this.productId,
    required this.productName,
    required this.sellPrice,
    required this.unitCost,
    required this.quantity,
  });

  int get total => sellPrice * quantity;

  @override
  List<Object?> get props =>
      [productId, productName, sellPrice, unitCost, quantity];
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
  });

  int get itemCount => items.fold(0, (sum, line) => sum + line.quantity);

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
        items
      ];
}

/// Totals for a period: money taken, number of tickets, items sold.
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
