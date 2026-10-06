part of 'billing_bloc.dart';

enum BillingError {
  productNotFound,
  saveFailed,
  discountTooHigh,

  /// Credit sale without a customer.
  customerMissing,

  /// Over the customer's credit limit (see [BillingState.creditLimit]).
  creditLimit,

  /// A worker selling more than the stock (see [BillingState.stockShort]).
  stockShort,
}

class BillingState extends Equatable {
  final List<CartItem> cartItems;
  final bool isProcessing;

  /// Discount on the whole ticket, or null.
  final Discount? discount;

  /// Credit sale: [customer] pays [paidNow] now, the rest goes on their
  /// account.
  final bool onCredit;
  final Customer? customer;
  final int paidNow;

  /// One-time signals, cleared by the next change unless passed again.
  final BillingError? error;
  final String? errorDetail;

  /// Details of a [BillingError.creditLimit].
  final CreditLimitFailure? creditLimit;

  /// Details of a [BillingError.stockShort].
  final StockShortFailure? stockShort;

  /// Set right after a successful checkout.
  final Sale? completedSale;

  /// Result of printing [completedSale], or null when printing was not asked.
  final PrintOutcome? printOutcome;

  const BillingState({
    this.cartItems = const [],
    this.isProcessing = false,
    this.discount,
    this.onCredit = false,
    this.customer,
    this.paidNow = 0,
    this.error,
    this.errorDetail,
    this.creditLimit,
    this.stockShort,
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

  /// Paid at the counter: everything for cash, [paidNow] (never more than
  /// the total) on credit.
  int get paidAtCounter =>
      onCredit ? paidNow.clamp(0, totalAmount) : totalAmount;

  /// What goes on the customer's account.
  int get leftOnCredit => totalAmount - paidAtCounter;

  /// The customer's debt after this sale (credit sales only).
  int? get debtAfter =>
      onCredit && customer != null ? customer!.debt + leftOnCredit : null;

  /// True when this credit sale goes over the customer's credit limit.
  bool get overCreditLimit {
    final limit = customer?.creditLimit;
    final after = debtAfter;
    return limit != null && after != null && leftOnCredit > 0 && after > limit;
  }

  /// [clearDiscount] removes the discount, [clearCustomer] the customer.
  BillingState copyWith({
    List<CartItem>? cartItems,
    bool? isProcessing,
    Discount? discount,
    bool clearDiscount = false,
    bool? onCredit,
    Customer? customer,
    bool clearCustomer = false,
    int? paidNow,
    BillingError? error,
    String? errorDetail,
    CreditLimitFailure? creditLimit,
    StockShortFailure? stockShort,
  }) {
    return BillingState(
      cartItems: cartItems ?? this.cartItems,
      isProcessing: isProcessing ?? this.isProcessing,
      discount: clearDiscount ? null : (discount ?? this.discount),
      onCredit: onCredit ?? this.onCredit,
      customer: clearCustomer ? null : (customer ?? this.customer),
      paidNow: paidNow ?? this.paidNow,
      error: error,
      errorDetail: errorDetail,
      creditLimit: creditLimit,
      stockShort: stockShort,
    );
  }

  @override
  List<Object?> get props => [
        cartItems,
        isProcessing,
        discount,
        onCredit,
        customer,
        paidNow,
        error,
        errorDetail,
        creditLimit,
        stockShort,
        completedSale,
        printOutcome
      ];
}
