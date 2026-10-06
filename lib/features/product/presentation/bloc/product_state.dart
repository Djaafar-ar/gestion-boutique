part of 'product_bloc.dart';

enum ProductStatus { initial, loading, loaded, error, success }

/// What just succeeded, so the screen can show the right message
/// in the current language.
enum ProductAction { added, updated, archived }

class ProductState extends Equatable {
  final ProductStatus status;
  final List<Product> products;

  /// Stock per product id (missing = never delivered = 0).
  final Map<String, ProductStock> stock;

  /// Technical error text, only set when [status] is error.
  final String? message;
  final ProductAction? action;

  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.stock = const {},
    this.message,
    this.action,
  });

  /// [message] and [action] are one-time signals: they are cleared unless
  /// passed again.
  ProductState copyWith({
    ProductStatus? status,
    List<Product>? products,
    Map<String, ProductStock>? stock,
    String? message,
    ProductAction? action,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      stock: stock ?? this.stock,
      message: message,
      action: action,
    );
  }

  /// Stock of one product (0 when it never had a delivery).
  ProductStock stockOf(String productId) =>
      stock[productId] ?? ProductStock.empty;

  @override
  List<Object?> get props => [status, products, stock, message, action];
}
