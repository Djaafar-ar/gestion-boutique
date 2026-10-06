import 'package:equatable/equatable.dart';

enum LossReason { damaged, expired, staff, stolen, other }

/// Items that left the shop without being sold.
class Loss extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final LossReason reason;
  final String? note;
  final int unitCost; // centimes, buying price per item
  final String? userName;
  final DateTime at;

  /// A damaged item a customer brought back.
  final bool fromReturn;

  const Loss({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.reason,
    required this.note,
    required this.unitCost,
    required this.userName,
    required this.at,
    this.fromReturn = false,
  });

  /// Money lost, at buying price (centimes).
  int get value => unitCost * quantity;

  @override
  List<Object?> get props =>
      [id, productId, quantity, reason, note, unitCost, userName, at];
}

/// Losses of a period: how many records, how many items, how much money.
class LossSummary extends Equatable {
  final int count;
  final int items;
  final int value; // centimes

  const LossSummary(
      {required this.count, required this.items, required this.value});

  static const empty = LossSummary(count: 0, items: 0, value: 0);

  @override
  List<Object?> get props => [count, items, value];
}
