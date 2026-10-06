import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';

/// A customer of the "carnet" (credit book).
class Customer extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? note;

  /// Highest debt allowed (centimes), or null for no limit.
  final int? creditLimit;
  final bool active;

  /// What the customer owes right now (centimes). Below zero, the shop
  /// owes the customer (an advance, for example after a return).
  final int debt;

  const Customer({
    required this.id,
    required this.name,
    this.phone = '',
    this.note,
    this.creditLimit,
    this.active = true,
    this.debt = 0,
  });

  /// True when the debt is above the credit limit.
  bool get overLimit => creditLimit != null && debt > creditLimit!;

  @override
  List<Object?> get props => [id, name, phone, note, creditLimit, active, debt];
}

enum CustomerEntryKind {
  /// A credit sale: the unpaid part adds to the debt.
  sale,

  /// The customer paid back money.
  payment,

  /// Items returned from a credit sale: the refund lowers the debt.
  refund,
}

/// One line of a customer's history.
class CustomerEntry extends Equatable {
  final CustomerEntryKind kind;
  final DateTime at;

  /// Change of the debt (centimes): positive adds to it, negative lowers it.
  final int amount;

  /// Who recorded it (seller, cashier who took the money...).
  final String? byName;

  /// For sales and refunds: the ticket.
  final String? saleId;
  final String? saleTicket;

  /// For sales: ticket total and what was paid at the counter.
  final int? saleTotal;
  final int? paidNow;
  final String? note;

  const CustomerEntry({
    required this.kind,
    required this.at,
    required this.amount,
    this.byName,
    this.saleId,
    this.saleTicket,
    this.saleTotal,
    this.paidNow,
    this.note,
  });

  @override
  List<Object?> get props =>
      [kind, at, amount, byName, saleId, saleTicket, saleTotal, paidNow, note];
}

/// A credit sale would take the customer over their credit limit.
/// The owner may still allow it; a worker may not.
class CreditLimitFailure extends Failure {
  final int limit;

  /// The debt the sale would lead to (centimes).
  final int debtAfter;

  const CreditLimitFailure({required this.limit, required this.debtAfter})
      : super('Credit limit exceeded');

  @override
  List<Object> get props => [limit, debtAfter];
}

/// A customer cannot pay back more than they owe.
class OverpaymentFailure extends Failure {
  final int debt;
  const OverpaymentFailure(this.debt) : super('More than the debt');

  @override
  List<Object> get props => [debt];
}
