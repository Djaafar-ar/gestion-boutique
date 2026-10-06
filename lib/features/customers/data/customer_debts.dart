import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

/// What each customer owes, by customer id (centimes):
///
///   unpaid part of their credit sales (total - paid at the counter)
/// - refunds of returns put on their account
/// - money they paid back.
///
/// Calculated from these events every time, like the stock, so it is
/// always right once every phone has synced. With [ids], only those
/// customers; customers with nothing recorded are left out (debt 0).
Future<Map<String, int>> customerDebts(AppDatabase db,
    {Iterable<String>? ids}) async {
  final wanted = ids?.toSet();
  final debts = <String, int>{};
  void add(String? id, int? amount) {
    if (id == null || amount == null) return;
    debts[id] = (debts[id] ?? 0) + amount;
  }

  final unpaid = (db.sales.total - db.sales.paidNow).sum();
  final sales = db.selectOnly(db.sales)
    ..addColumns([db.sales.customerId, unpaid])
    ..where(db.sales.customerId.isNotNull() & db.sales.deleted.equals(false))
    ..groupBy([db.sales.customerId]);
  if (wanted != null) sales.where(db.sales.customerId.isIn(wanted));
  for (final row in await sales.get()) {
    add(row.read(db.sales.customerId), row.read(unpaid));
  }

  final refunds = db.returns.total.sum();
  final returns = db.selectOnly(db.returns).join([
    innerJoin(db.sales, db.sales.id.equalsExp(db.returns.saleId),
        useColumns: false),
  ])
    ..addColumns([db.sales.customerId, refunds])
    ..where(db.returns.refundMode.equals('credit') &
        db.returns.deleted.equals(false) &
        db.sales.customerId.isNotNull())
    ..groupBy([db.sales.customerId]);
  if (wanted != null) returns.where(db.sales.customerId.isIn(wanted));
  for (final row in await returns.get()) {
    add(row.read(db.sales.customerId), -(row.read(refunds) ?? 0));
  }

  final paid = db.customerPayments.amount.sum();
  final payments = db.selectOnly(db.customerPayments)
    ..addColumns([db.customerPayments.customerId, paid])
    ..where(db.customerPayments.deleted.equals(false))
    ..groupBy([db.customerPayments.customerId]);
  if (wanted != null) {
    payments.where(db.customerPayments.customerId.isIn(wanted));
  }
  for (final row in await payments.get()) {
    add(row.read(db.customerPayments.customerId), -(row.read(paid) ?? 0));
  }
  return debts;
}

/// What one customer owes (centimes).
Future<int> customerDebt(AppDatabase db, String customerId) async =>
    (await customerDebts(db, ids: [customerId]))[customerId] ?? 0;
