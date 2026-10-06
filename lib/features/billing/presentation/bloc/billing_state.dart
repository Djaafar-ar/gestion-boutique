part of 'billing_bloc.dart';

enum BillingError { productNotFound, saveFailed }

class BillingState extends Equatable {
  final List<CartItem> cartItems;
  final bool isProcessing;

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
    this.error,
    this.errorDetail,
    this.completedSale,
    this.printOutcome,
  });

  /// Cart total in centimes.
  int get totalAmount => cartItems.fold(0, (sum, item) => sum + item.total);

  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  BillingState copyWith({
    List<CartItem>? cartItems,
    bool? isProcessing,
    BillingError? error,
    String? errorDetail,
  }) {
    return BillingState(
      cartItems: cartItems ?? this.cartItems,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      errorDetail: errorDetail,
    );
  }

  @override
  List<Object?> get props => [
        cartItems,
        isProcessing,
        error,
        errorDetail,
        completedSale,
        printOutcome
      ];
}
