import 'package:equatable/equatable.dart';

class Shop extends Equatable {
  final String name;
  final String addressLine1;
  final String addressLine2;
  final String phoneNumber;
  final String footerText;

  /// Products expiring within this many days are shown in orange.
  final int expiryWarnDays;

  /// Highest discount a worker may give, in percent.
  final int maxWorkerDiscountPct;

  /// When false (the default), a worker cannot sell more than the stock
  /// recorded. The owner always can.
  final bool workersSellWithoutStock;

  const Shop({
    this.name = '',
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.phoneNumber = '',
    this.footerText = '',
    this.expiryWarnDays = 3,
    this.maxWorkerDiscountPct = 10,
    this.workersSellWithoutStock = false,
  });

  Shop copyWith({
    String? name,
    String? addressLine1,
    String? addressLine2,
    String? phoneNumber,
    String? footerText,
    int? expiryWarnDays,
    int? maxWorkerDiscountPct,
    bool? workersSellWithoutStock,
  }) {
    return Shop(
      name: name ?? this.name,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      footerText: footerText ?? this.footerText,
      expiryWarnDays: expiryWarnDays ?? this.expiryWarnDays,
      maxWorkerDiscountPct: maxWorkerDiscountPct ?? this.maxWorkerDiscountPct,
      workersSellWithoutStock:
          workersSellWithoutStock ?? this.workersSellWithoutStock,
    );
  }

  @override
  List<Object?> get props => [
        name,
        addressLine1,
        addressLine2,
        phoneNumber,
        footerText,
        expiryWarnDays,
        maxWorkerDiscountPct,
        workersSellWithoutStock
      ];
}
