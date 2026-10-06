import 'package:equatable/equatable.dart';

enum ExpiryStatus {
  /// No expiry date (non-perishable).
  none,
  ok,

  /// Expires within the shop's warning days (3 by default).
  soon,
  expired,
}

/// Works out the colour of an expiry date: expired, soon or fine.
ExpiryStatus expiryStatusOf(DateTime? expiry,
    {required int warnDays, DateTime? today}) {
  if (expiry == null) return ExpiryStatus.none;
  final now = today ?? DateTime.now();
  final day = DateTime(now.year, now.month, now.day);
  final expiryDay = DateTime(expiry.year, expiry.month, expiry.day);
  final daysLeft = expiryDay.difference(day).inDays;
  if (daysLeft < 0) return ExpiryStatus.expired;
  if (daysLeft <= warnDays) return ExpiryStatus.soon;
  return ExpiryStatus.ok;
}

/// One delivery of a product (a "batch") and how many items are left.
class StockBatch extends Equatable {
  final String deliveryId;
  final String productId;
  final int quantity;
  final int remaining;
  final int buyPrice; // centimes, per item
  final DateTime? expiryDate;
  final DateTime receivedAt;
  final String? receivedByName;
  final String? note;

  const StockBatch({
    required this.deliveryId,
    required this.productId,
    required this.quantity,
    required this.remaining,
    required this.buyPrice,
    required this.expiryDate,
    required this.receivedAt,
    this.receivedByName,
    this.note,
  });

  StockBatch withRemaining(int value) => StockBatch(
        deliveryId: deliveryId,
        productId: productId,
        quantity: quantity,
        remaining: value,
        buyPrice: buyPrice,
        expiryDate: expiryDate,
        receivedAt: receivedAt,
        receivedByName: receivedByName,
        note: note,
      );

  @override
  List<Object?> get props => [
        deliveryId,
        productId,
        quantity,
        remaining,
        buyPrice,
        expiryDate,
        receivedAt,
        receivedByName,
        note,
      ];
}

/// Stock of one product: total and the nearest expiry still on the shelf.
class ProductStock extends Equatable {
  /// Can be below zero when items were sold without a recorded delivery.
  final int quantity;
  final DateTime? nextExpiry;

  const ProductStock({required this.quantity, this.nextExpiry});

  static const empty = ProductStock(quantity: 0);

  @override
  List<Object?> get props => [quantity, nextExpiry];
}
