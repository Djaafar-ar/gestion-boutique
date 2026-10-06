import 'package:equatable/equatable.dart';

enum AlertType {
  /// A worker paid a supplier: the owner must validate it.
  pendingPayment,

  /// Stock at or below the product's alert level, or below zero.
  lowStock,

  /// A batch expires within the shop's warning days.
  expiringSoon,

  /// A batch is past its expiry date and still on the shelf.
  expired,

  /// A worker received a delivery.
  newDelivery,

  /// A customer owes more than their credit limit.
  overCreditLimit,

  /// Wrong PINs were typed on an account.
  failedLogins,

  /// A worker took back items from a customer.
  returnMade;

  /// Workers only see the stock alerts; everything else is for the owner.
  bool get ownerOnly =>
      this != lowStock && this != expiringSoon && this != expired;

  /// The settings key that turns this type of phone notification on/off.
  String get settingsKey => 'notify_$name';
}

/// One alert, as shown in the Alertes tab.
class Alert extends Equatable {
  /// What it is about, for example 'lowStock:<product id>'.
  final String id;
  final AlertType type;
  final String refId;

  /// What the message needs (names, quantities...).
  final Map<String, dynamic> data;
  final DateTime createdAt;

  /// Read by the person looking at the list.
  final bool read;

  const Alert({
    required this.id,
    required this.type,
    required this.refId,
    required this.data,
    required this.createdAt,
    this.read = false,
  });

  @override
  List<Object?> get props => [id, type, refId, data, createdAt, read];
}

/// An alert the rules say should exist right now.
class AlertDraft extends Equatable {
  final String id;
  final AlertType type;
  final String refId;
  final Map<String, dynamic> data;

  /// When it happened, for alerts about something that happened (a
  /// delivery, a return). Null for alerts about a situation (low stock...),
  /// which start when they are first seen.
  final DateTime? at;

  /// A change of this value makes an active alert unread again and sends
  /// a new phone notification (for example more wrong PINs).
  final int level;

  const AlertDraft({
    required this.id,
    required this.type,
    required this.refId,
    required this.data,
    this.at,
    this.level = 0,
  });

  @override
  List<Object?> get props => [id, type, refId, data, at, level];
}
