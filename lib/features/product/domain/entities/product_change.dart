import 'package:equatable/equatable.dart';

/// Which product field a history line is about.
enum ProductField {
  name,
  barcode,
  sellPrice,
  buyPrice,
  category,
  lowStockThreshold,
  archived;

  /// Prices are saved in centimes and shown as DA.
  bool get isMoney => this == sellPrice || this == buyPrice;
}

/// One line of a product's history: who changed what, when.
class ProductChange extends Equatable {
  final ProductField field;
  final String? oldValue;
  final String? newValue;
  final String? userName;
  final DateTime at;

  const ProductChange({
    required this.field,
    required this.oldValue,
    required this.newValue,
    required this.userName,
    required this.at,
  });

  @override
  List<Object?> get props => [field, oldValue, newValue, userName, at];
}
