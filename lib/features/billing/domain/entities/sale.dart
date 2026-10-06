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
  final List<SaleLine> items;

  const Sale({
    required this.id,
    required this.number,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.paidNow,
    required this.createdAt,
    required this.items,
  });

  int get itemCount => items.fold(0, (sum, line) => sum + line.quantity);

  @override
  List<Object?> get props =>
      [id, number, subtotal, discount, total, paidNow, createdAt, items];
}
