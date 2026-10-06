import 'package:equatable/equatable.dart';

/// Someone the shop buys from, with what the shop owes them.
class Supplier extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? note;
  final bool active;

  /// Value of everything delivered (quantity x buying price, centimes).
  final int delivered;

  /// Payments validated by the owner (centimes).
  final int paid;

  /// Payments made by workers that the owner has not validated yet.
  final int pending;

  const Supplier({
    required this.id,
    required this.name,
    this.phone = '',
    this.note,
    this.active = true,
    this.delivered = 0,
    this.paid = 0,
    this.pending = 0,
  });

  /// What the shop still owes. Pending payments do not count until the
  /// owner validates them. Below zero, the shop paid in advance.
  int get balance => delivered - paid;

  @override
  List<Object?> get props =>
      [id, name, phone, note, active, delivered, paid, pending];
}

enum PaymentStatus { pending, validated, rejected }

/// Money given to a supplier.
class SupplierPayment extends Equatable {
  final String id;
  final String supplierId;
  final String supplierName;
  final int amount; // centimes
  final String? note;
  final PaymentStatus status;
  final DateTime createdAt;

  /// Who paid.
  final String? paidByName;

  /// Who validated or rejected it, and when (owner).
  final String? validatedByName;
  final DateTime? validatedAt;

  const SupplierPayment({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.amount,
    this.note,
    required this.status,
    required this.createdAt,
    this.paidByName,
    this.validatedByName,
    this.validatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        supplierId,
        supplierName,
        amount,
        note,
        status,
        createdAt,
        paidByName,
        validatedByName,
        validatedAt
      ];
}

/// One delivery received from a supplier.
class SupplierDelivery extends Equatable {
  final String id;
  final String productName;
  final int quantity;
  final int buyPrice; // centimes per item
  final DateTime receivedAt;
  final String? receivedByName;

  const SupplierDelivery({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.buyPrice,
    required this.receivedAt,
    this.receivedByName,
  });

  int get total => quantity * buyPrice;

  @override
  List<Object?> get props =>
      [id, productName, quantity, buyPrice, receivedAt, receivedByName];
}
