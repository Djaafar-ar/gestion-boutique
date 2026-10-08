part of 'billing_bloc.dart';

abstract class BillingEvent extends Equatable {
  const BillingEvent();
  @override
  List<Object> get props => [];
}

/// The cart saved before the app stopped comes back.
class RestoreCartEvent extends BillingEvent {
  const RestoreCartEvent();
}

class ScanBarcodeEvent extends BillingEvent {
  final String barcode;
  const ScanBarcodeEvent(this.barcode);
  @override
  List<Object> get props => [barcode];
}

class AddProductToCartEvent extends BillingEvent {
  final Product product;
  const AddProductToCartEvent(this.product);
  @override
  List<Object> get props => [product];
}

class RemoveProductFromCartEvent extends BillingEvent {
  final String productId;
  const RemoveProductFromCartEvent(this.productId);
  @override
  List<Object> get props => [productId];
}

class UpdateQuantityEvent extends BillingEvent {
  final String productId;
  final int quantity;
  const UpdateQuantityEvent(this.productId, this.quantity);
  @override
  List<Object> get props => [productId, quantity];
}

class ClearCartEvent extends BillingEvent {}

/// Sets (or with null removes) the discount on the whole ticket.
class SetDiscountEvent extends BillingEvent {
  final Discount? discount;
  const SetDiscountEvent(this.discount);
  @override
  List<Object> get props => [discount ?? 'none'];
}

/// Cash (false) or credit (true) sale.
class SetCreditModeEvent extends BillingEvent {
  final bool onCredit;
  const SetCreditModeEvent(this.onCredit);
  @override
  List<Object> get props => [onCredit];
}

/// The customer of a credit sale (null to remove).
class SetCustomerEvent extends BillingEvent {
  final Customer? customer;
  const SetCustomerEvent(this.customer);
  @override
  List<Object> get props => [customer ?? 'none'];
}

/// What the customer pays now on a credit sale (centimes).
class SetPaidNowEvent extends BillingEvent {
  final int paidNow;
  const SetPaidNowEvent(this.paidNow);
  @override
  List<Object> get props => [paidNow];
}

/// Saves the cart as a sale, and prints the receipt when [print] is true.
/// [allowOverLimit]: the owner confirmed going over a credit limit.
class CheckoutEvent extends BillingEvent {
  final bool print;
  final Shop shop;
  final bool allowOverLimit;

  const CheckoutEvent(
      {required this.print, required this.shop, this.allowOverLimit = false});

  @override
  List<Object> get props => [print, shop, allowOverLimit];
}
