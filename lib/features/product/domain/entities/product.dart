import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name; // written in French, also printed on receipts
  final String barcode;
  final int sellPrice; // centimes
  final int buyPrice; // centimes
  final String? categoryId;
  final int lowStockThreshold;
  final bool archived;

  const Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.sellPrice,
    this.buyPrice = 0,
    this.categoryId,
    this.lowStockThreshold = 0,
    this.archived = false,
  });

  Product copyWith({
    String? name,
    String? barcode,
    int? sellPrice,
    int? buyPrice,
    String? categoryId,
    int? lowStockThreshold,
    bool? archived,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      sellPrice: sellPrice ?? this.sellPrice,
      buyPrice: buyPrice ?? this.buyPrice,
      categoryId: categoryId ?? this.categoryId,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      archived: archived ?? this.archived,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        barcode,
        sellPrice,
        buyPrice,
        categoryId,
        lowStockThreshold,
        archived,
      ];
}
