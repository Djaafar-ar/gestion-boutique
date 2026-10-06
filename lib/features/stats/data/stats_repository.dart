import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/user_names.dart';
import '../../../core/utils/date_format.dart';
import '../../customers/data/customer_debts.dart';
import '../../stock/domain/entities/loss.dart';
import '../domain/stats.dart';

/// Periods longer than this are shown month by month.
const maxDaysPerDay = 62;

/// Works out the figures of the Stats tab.
class StatsRepository {
  final AppDatabase db;

  StatsRepository(this.db);

  /// Figures between [from] (included) and [to] (excluded). With [userId],
  /// only what that person did: their sales (and the returns on them),
  /// the losses they recorded and the money they received or paid.
  Future<Stats> getStats(
      {required DateTime from, required DateTime to, String? userId}) async {
    Expression<bool> period(GeneratedColumn<DateTime> createdAt) =>
        createdAt.isBiggerOrEqualValue(from) & createdAt.isSmallerThanValue(to);
    bool mine(String? id) => userId == null || id == userId;

    // Sales of the period, with their lines.
    final sales = await (db.select(db.sales)
          ..where((s) => s.deleted.equals(false) & period(s.createdAt)))
        .get()
      ..retainWhere((s) => mine(s.userId));
    final lineRows = await (db.select(db.saleItems).join([
      innerJoin(db.sales, db.sales.id.equalsExp(db.saleItems.saleId),
          useColumns: false),
    ])
          ..where(db.saleItems.deleted.equals(false) &
              db.sales.deleted.equals(false) &
              period(db.sales.createdAt)))
        .get();
    final saleIds = {for (final s in sales) s.id};
    final lines = [
      for (final row in lineRows)
        if (saleIds.contains(row.readTable(db.saleItems).saleId))
          row.readTable(db.saleItems),
    ];

    // Returns of the period. Their money counts for the person who made
    // the sale; the cash given back for the person who gave it.
    final returnRows = await (db.select(db.returns).join([
      innerJoin(db.sales, db.sales.id.equalsExp(db.returns.saleId)),
    ])
          ..where(
              db.returns.deleted.equals(false) & period(db.returns.createdAt)))
        .get();
    final sellerOfReturn = {
      for (final row in returnRows)
        row.readTable(db.returns).id: row.readTable(db.sales).userId,
    };
    final returns = returnRows.map((r) => r.readTable(db.returns)).toList();
    final itemRows = await (db.select(db.returnItems).join([
      innerJoin(
          db.saleItems, db.saleItems.id.equalsExp(db.returnItems.saleItemId)),
    ])
          ..where(db.returnItems.deleted.equals(false) &
              period(db.returnItems.createdAt)))
        .get();

    final losses = await (db.select(db.losses)
          ..where((l) => l.deleted.equals(false) & period(l.createdAt)))
        .get()
      ..retainWhere((l) => mine(l.userId));
    final payments = await (db.select(db.customerPayments)
          ..where((p) => p.deleted.equals(false) & period(p.createdAt)))
        .get();
    final supplierPayments = await (db.select(db.supplierPayments)
          ..where((p) =>
              p.deleted.equals(false) &
              p.status.equals('rejected').not() &
              period(p.createdAt)))
        .get()
      ..retainWhere((p) => mine(p.userId));

    // Tickets.
    var gross = 0, discounts = 0, total = 0, paid = 0;
    for (final sale in sales) {
      gross += sale.subtotal;
      discounts += sale.discount;
      total += sale.total;
      paid += sale.paidNow;
    }

    // Items and their buying price.
    var items = 0, cost = 0;
    final products = <String, (String, int, int)>{};
    for (final line in lines) {
      items += line.quantity;
      cost += line.unitCost * line.quantity;
      final (_, quantity, amount) =
          products[line.productId] ?? (line.productName, 0, 0);
      products[line.productId] = (
        line.productName,
        quantity + line.quantity,
        amount + line.sellPrice * line.quantity
      );
    }

    // Returns.
    var refunds = 0, returnsCount = 0, cashRefunds = 0;
    final refundsBySeller = <String?, int>{};
    for (final ret in returns) {
      final seller = sellerOfReturn[ret.id];
      if (mine(seller)) {
        refunds += ret.total;
        returnsCount++;
        refundsBySeller[seller] = (refundsBySeller[seller] ?? 0) + ret.total;
      }
      if (ret.refundMode == 'cash' && mine(ret.userId)) {
        cashRefunds += ret.total;
      }
    }
    for (final row in itemRows) {
      final item = row.readTable(db.returnItems);
      if (!mine(sellerOfReturn[item.returnId])) continue;
      items -= item.quantity;
      // Back on the shelf: the shop has the item again.
      if (item.backToStock) {
        cost -= item.quantity * row.readTable(db.saleItems).unitCost;
      }
    }

    // Losses.
    final byReason = <LossReason, int>{};
    var stockLosses = 0;
    for (final loss in losses) {
      final reason =
          LossReason.values.asNameMap()[loss.reason] ?? LossReason.other;
      final value = loss.unitCost * loss.quantity;
      byReason[reason] = (byReason[reason] ?? 0) + value;
      if (loss.returnItemId == null) stockLosses += value;
    }

    // Money taken per day (or per month), after returns.
    final byMonth = to.difference(from).inDays > maxDaysPerDay;
    DateTime bucket(DateTime d) => byMonth ? startOfMonth(d) : startOfDay(d);
    final perBucket = <DateTime, int>{};
    for (var day = bucket(from);
        day.isBefore(to);
        day = byMonth
            ? DateTime(day.year, day.month + 1)
            : DateTime(day.year, day.month, day.day + 1)) {
      perBucket[day] = 0;
    }
    for (final sale in sales) {
      final key = bucket(sale.createdAt);
      perBucket[key] = (perBucket[key] ?? 0) + sale.total;
    }
    for (final ret in returns) {
      if (!mine(sellerOfReturn[ret.id])) continue;
      final key = bucket(ret.createdAt);
      perBucket[key] = (perBucket[key] ?? 0) - ret.total;
    }

    // Per person (only when looking at everyone).
    final perWorker = <WorkerStat>[];
    if (userId == null) {
      final ids = {
        ...sales.map((s) => s.userId),
        ...payments.map((p) => p.userId),
      };
      final names = await userNames(db, ids);
      for (final id in ids) {
        final theirs = sales.where((s) => s.userId == id);
        perWorker.add(WorkerStat(
          userId: id ?? '',
          name: names[id] ?? '',
          revenue: theirs.fold(0, (a, s) => a + s.total) -
              (refundsBySeller[id] ?? 0),
          salesCount: theirs.length,
          discounts: theirs.fold(0, (a, s) => a + s.discount),
          collected: payments
              .where((p) => p.userId == id)
              .fold(0, (a, p) => a + p.amount),
        ));
      }
      perWorker.sort((a, b) => b.revenue.compareTo(a.revenue));
    }

    // Customer debts right now (whole shop).
    final debts = await customerDebts(db);
    final customers = {
      for (final c in await (db.select(db.customers)
            ..where((c) => c.deleted.equals(false)))
          .get())
        c.id: c.name,
    };
    final owing = [
      for (final MapEntry(key: id, value: debt) in debts.entries)
        if (debt > 0 && customers.containsKey(id)) (customers[id]!, debt),
    ]..sort((a, b) => b.$2.compareTo(a.$2));

    final top = [
      for (final MapEntry(key: id, value: (name, quantity, amount))
          in products.entries)
        ProductStat(id, name, quantity, amount),
    ]..sort((a, b) => b.amount.compareTo(a.amount));

    return Stats(
      from: from,
      to: to,
      grossSales: gross,
      discounts: discounts,
      salesTotal: total,
      refunds: refunds,
      returnsCount: returnsCount,
      salesCount: sales.length,
      itemsSold: items,
      cost: cost,
      lossesByReason: byReason,
      stockLosses: stockLosses,
      paidAtCounter: paid,
      onCredit: total - paid,
      customerPayments:
          payments.where((p) => mine(p.userId)).fold(0, (a, p) => a + p.amount),
      cashRefunds: cashRefunds,
      supplierPaid: supplierPayments.fold(0, (a, p) => a + p.amount),
      perDay: [
        for (final MapEntry(key: day, value: amount)
            in (perBucket.entries.toList()
              ..sort((a, b) => a.key.compareTo(b.key))))
          DayAmount(day, amount),
      ],
      byMonth: byMonth,
      topProducts: top.take(5).toList(),
      perWorker: perWorker,
      totalOwed: owing.fold(0, (a, d) => a + d.$2),
      topDebtors: owing.take(5).toList(),
    );
  }
}
