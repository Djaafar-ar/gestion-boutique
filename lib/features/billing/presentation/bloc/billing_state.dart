part of 'billing_bloc.dart';

enum BillingError { productNotFound, saveFailed, discountTooHigh }

class BillingState extends Equatable {
  final List<CartItem> cartItems;
  final bool isProcessing;

  /// Discount on the whole ticket, or null.
  final Discount? discount;

  /// One-time signals, cleared by the next change unless passed again.
  final BillingError? error;
  final String? errorDetail;

  /// Set right after a successful checkout.
  final Sale? completedSale;

  /// Result of printing [completedSale], or null when printing was not asked.
  final PrintOutcome? printOutcome;

  const BillingState({
    this.cartItems = const [],
    this.isProcessing = false,
    this.discount,
    this.error,
    this.errorDetail,
    this.completedSale,
    this.printOutcome,
  });

  /// Cart total before discount, in centimes.
  int get subtotal => cartItems.fold(0, (sum, item) => sum + item.total);

  /// Discount in centimes (never more than the subtotal).
  int get discountAmount => discount?.centimesOf(subtotal) ?? 0;

  /// What the customer pays, in centimes.
  int get totalAmount => subtotal - discountAmount;

  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  /// [clearDiscount] removes the discount.
  BillingState copyWith({
    List<CartItem>? cartItems,
    bool? isProcessing,
    Discount? discount,
    bool clearDiscount = false,
    BillingError? error,
    String? errorDetail,
  }) {
    return BillingState(
      cartItems: cartItems ?? this.cartItems,
      isProcessing: isProcessing ?? this.isProcessing,
      discount: clearDiscount ? null : (discount ?? this.discount),
      error: error,
      errorDetail: errorDetail,
    );
  }

  @override
  List<Object?> get props => [
        cartItems,
        isProcessing,
        discount,
        error,
        errorDetail,
        completedSale,
        printOutcome
      ];
}
