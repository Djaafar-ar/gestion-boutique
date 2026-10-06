import 'package:equatable/equatable.dart';

import '../../stock/domain/entities/loss.dart';

/// Money taken on one day (or one month for long periods).
class DayAmount extends Equatable {
  final DateTime day;
  final int amount; // centimes
  const DayAmount(this.day, this.amount);

  @override
  List<Object?> get props => [day, amount];
}

/// A product among the best sellers.
class ProductStat extends Equatable {
  final String productId;
  final String name;
  final int quantity;

  /// Sold at the shelf price, before ticket discounts (centimes).
  final int amount;

  const ProductStat(this.productId, this.name, this.quantity, this.amount);

  @override
  List<Object?> get props => [productId, name, quantity, amount];
}

/// What one person did in the period.
class WorkerStat extends Equatable {
  final String userId;
  final String name;

  /// Sales after discounts and returns (centimes).
  final int revenue;
  final int salesCount;
  final int discounts;

  /// Money received from customers paying back their debt.
  final int collected;

  const WorkerStat({
    required this.userId,
    required this.name,
    required this.revenue,
    required this.salesCount,
    required this.discounts,
    required this.collected,
  });

  @override
  List<Object?> get props =>
      [userId, name, revenue, salesCount, discounts, collected];
}

/// Everything shown on the Stats tab for a period (and maybe one person).
/// All amounts are centimes.
class Stats extends Equatable {
  final DateTime from;
  final DateTime to;

  /// Tickets before discounts, the discounts, and what customers had to pay.
  final int grossSales;
  final int discounts;
  final int salesTotal;

  /// Money given back (or taken off a debt) for returns in the period.
  final int refunds;
  final int returnsCount;
  final int salesCount;

  /// Items sold minus items brought back.
  final int itemsSold;

  /// Buying price of the items sold (items put back on the shelf after a
  /// return are not counted).
  final int cost;

  /// Items thrown away, eaten, stolen... at buying price, by reason
  /// (damaged items brought back by customers included).
  final Map<LossReason, int> lossesByReason;

  /// The part of the losses that does not come from returns: the cost of
  /// damaged returns is already in [cost].
  final int stockLosses;

  /// Paid at the counter, and put on customers' accounts.
  final int paidAtCounter;
  final int onCredit;

  /// Customers paying back their debt.
  final int customerPayments;

  /// Cash given back for returns.
  final int cashRefunds;

  /// Paid to suppliers (not counting rejected payments).
  final int supplierPaid;

  final List<DayAmount> perDay;

  /// True when [perDay] holds months (long periods).
  final bool byMonth;
  final List<ProductStat> topProducts;
  final List<WorkerStat> perWorker;

  /// Right now, for the whole shop (not only the period).
  final int totalOwed;
  final List<(String name, int debt)> topDebtors;

  const Stats({
    required this.from,
    required this.to,
    this.grossSales = 0,
    this.discounts = 0,
    this.salesTotal = 0,
    this.refunds = 0,
    this.returnsCount = 0,
    this.salesCount = 0,
    this.itemsSold = 0,
    this.cost = 0,
    this.lossesByReason = const {},
    this.stockLosses = 0,
    this.paidAtCounter = 0,
    this.onCredit = 0,
    this.customerPayments = 0,
    this.cashRefunds = 0,
    this.supplierPaid = 0,
    this.perDay = const [],
    this.byMonth = false,
    this.topProducts = const [],
    this.perWorker = const [],
    this.totalOwed = 0,
    this.topDebtors = const [],
  });

  /// Money really earned from sales: after discounts and returns.
  int get revenue => salesTotal - refunds;

  /// Revenue minus the buying price of what was sold.
  int get profit => revenue - cost;

  /// Profit minus the stock thrown away, eaten, stolen...
  int get netProfit => profit - stockLosses;

  int get lossesValue => lossesByReason.values.fold(0, (a, b) => a + b);

  int get averageTicket => salesCount == 0 ? 0 : salesTotal ~/ salesCount;

  /// What should be in the drawer: paid at the counter, plus customers
  /// paying their debt, minus cash given back.
  int get cashInHand => paidAtCounter + customerPayments - cashRefunds;

  @override
  List<Object?> get props => [
        from,
        to,
        grossSales,
        discounts,
        salesTotal,
        refunds,
        returnsCount,
        salesCount,
        itemsSold,
        cost,
        lossesByReason,
        stockLosses,
        paidAtCounter,
        onCredit,
        customerPayments,
        cashRefunds,
        supplierPaid,
        perDay,
        byMonth,
        topProducts,
        perWorker,
        totalOwed,
        topDebtors,
      ];
}
