part of 'product_bloc.dart';

enum ProductStatus { initial, loading, loaded, error, success }

/// What just succeeded, so the screen can show the right message
/// in the current language.
enum ProductAction { added, updated, archived }

class ProductState extends Equatable {
  final ProductStatus status;
  final List<Product> products;

  /// Technical error text, only set when [status] is error.
  final String? message;
  final ProductAction? action;

  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.message,
    this.action,
  });

  /// [message] and [action] are one-time signals: they are cleared unless
  /// passed again.
  ProductState copyWith({
    ProductStatus? status,
    List<Product>? products,
    String? message,
    ProductAction? action,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      message: message,
      action: action,
    );
  }

  @override
  List<Object?> get props => [status, products, message, action];
}
