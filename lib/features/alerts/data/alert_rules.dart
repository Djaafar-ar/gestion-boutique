import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../customers/data/customer_debts.dart';
import '../../shop/data/repositories/shop_repository_impl.dart';
import '../../stock/data/stock_ledger.dart';
import '../../stock/domain/entities/stock_batch.dart';
import '../domain/alert.dart';

/// Alerts about something that happened (a delivery, a return) are kept
/// this long.
const eventAlertDays = 30;

/// Works out every alert that should exist right now, from the shop data.
///
/// Alerts about something that happened only count what happened after
/// [since] (when alerts were switched on), so updating the app does not
/// bring up months of old deliveries.
Future<List<AlertDraft>> currentAlerts(AppDatabase db,
    {required DateTime now, required DateTime since}) async {
  final drafts = <AlertDraft>[];
  final shop = await currentShopRow(db);
  final warnDays = shop?.expiryWarnDays ?? 3;

  final users = {
    for (final u in await db.select(db.users).get()) u.id: u,
  };
  String? nameOf(String? id) => users[id]?.name;
  bool byWorker(String? id) => users[id]?.role == 'worker';

  // Stock: low or below zero, then batches expiring or expired.
  final products = {
    for (final p in await (db.select(db.products)
          ..where((p) => p.deleted.equals(false) & p.archived.equals(false)))
        .get())
      p.id: p,
  };
  final batches = await StockLedger(db).allBatches();
  for (final product in products.values) {
    final state = batches[product.id];
    final stock = state?.stock ?? 0;
    final threshold = product.lowStockThreshold;
    if (stock < 0 || (threshold > 0 && stock <= threshold)) {
      drafts.add(AlertDraft(
        id: 'lowStock:${product.id}',
        type: AlertType.lowStock,
        refId: product.id,
        data: {
          'product': product.name,
          'productId': product.id,
          'quantity': stock,
          'threshold': threshold,
        },
        // Running out, then selling without stock, are worth a new alert.
        level: stock < 0 ? 2 : (stock == 0 ? 1 : 0),
      ));
    }
    for (final batch in state?.onShelf ?? const <StockBatch>[]) {
      final status =
          expiryStatusOf(batch.expiryDate, warnDays: warnDays, today: now);
      if (status != ExpiryStatus.soon && status != ExpiryStatus.expired) {
        continue;
      }
      final type = status == ExpiryStatus.expired
          ? AlertType.expired
          : AlertType.expiringSoon;
      drafts.add(AlertDraft(
        id: '${type.name}:${batch.deliveryId}',
        type: type,
        refId: batch.deliveryId,
        data: {
          'product': product.name,
          'productId': product.id,
          'remaining': batch.remaining,
          'date': batch.expiryDate!.toIso8601String(),
        },
      ));
    }
  }

  // Supplier payments waiting for the owner.
  final pending = await (db.select(db.supplierPayments).join([
    leftOuterJoin(db.suppliers,
        db.suppliers.id.equalsExp(db.supplierPayments.supplierId)),
  ])
        ..where(db.supplierPayments.status.equals('pending') &
            db.supplierPayments.deleted.equals(false)))
      .get();
  for (final row in pending) {
    final payment = row.readTable(db.supplierPayments);
    drafts.add(AlertDraft(
      id: 'pendingPayment:${payment.id}',
      type: AlertType.pendingPayment,
      refId: payment.id,
      data: {
        'supplier': row.readTableOrNull(db.suppliers)?.name ?? '?',
        'amount': payment.amount,
        'by': nameOf(payment.userId) ?? '?',
      },
      at: payment.createdAt,
    ));
  }

  // Customers above their credit limit.
  final limited = await (db.select(db.customers)
        ..where((c) =>
            c.deleted.equals(false) &
            c.active.equals(true) &
            c.creditLimit.isNotNull()))
      .get();
  if (limited.isNotEmpty) {
    final debts = await customerDebts(db, ids: limited.map((c) => c.id));
    for (final customer in limited) {
      final debt = debts[customer.id] ?? 0;
      if (debt <= customer.creditLimit!) continue;
      drafts.add(AlertDraft(
        id: 'overCreditLimit:${customer.id}',
        type: AlertType.overCreditLimit,
        refId: customer.id,
        data: {
          'customer': customer.name,
          'customerId': customer.id,
          'debt': debt,
          'limit': customer.creditLimit,
        },
      ));
    }
  }

  // Wrong PINs the owner has not looked at yet, per account.
  final attempts = await (db.select(db.failedLogins)
        ..where((f) => f.seen.equals(false) & f.deleted.equals(false)))
      .get();
  final perAccount = <String, int>{};
  for (final attempt in attempts) {
    perAccount[attempt.accountId] = (perAccount[attempt.accountId] ?? 0) + 1;
  }
  for (final MapEntry(key: accountId, value: count) in perAccount.entries) {
    drafts.add(AlertDraft(
      id: 'failedLogins:$accountId',
      type: AlertType.failedLogins,
      refId: accountId,
      data: {'name': nameOf(accountId) ?? '?', 'count': count},
      level: count,
    ));
  }

  // Deliveries and returns made by workers.
  final recent = now.subtract(const Duration(days: eventAlertDays));
  final from = since.isAfter(recent) ? since : recent;
  final deliveries = await (db.select(db.deliveries)
        ..where((d) =>
            d.deleted.equals(false) & d.createdAt.isBiggerOrEqualValue(from)))
      .get();
  for (final delivery in deliveries) {
    if (!byWorker(delivery.userId)) continue;
    drafts.add(AlertDraft(
      id: 'newDelivery:${delivery.id}',
      type: AlertType.newDelivery,
      refId: delivery.id,
      data: {
        'product': products[delivery.productId]?.name ?? '?',
        'productId': delivery.productId,
        'quantity': delivery.quantity,
        'by': nameOf(delivery.userId) ?? '?',
      },
      at: delivery.createdAt,
    ));
  }
  final returns = await (db.select(db.returns).join([
    innerJoin(db.sales, db.sales.id.equalsExp(db.returns.saleId)),
  ])
        ..where(db.returns.deleted.equals(false) &
            db.returns.createdAt.isBiggerOrEqualValue(from)))
      .get();
  for (final row in returns) {
    final ret = row.readTable(db.returns);
    if (!byWorker(ret.userId)) continue;
    drafts.add(AlertDraft(
      id: 'returnMade:${ret.id}',
      type: AlertType.returnMade,
      refId: ret.id,
      data: {
        'saleId': ret.saleId,
        'number': row.readTable(db.sales).number,
        'amount': ret.total,
        'by': nameOf(ret.userId) ?? '?',
      },
      at: ret.createdAt,
    ));
  }
  return drafts;
}

/// A batch still on the shelf with an expiry date, for reminders.
typedef ExpiringBatch = ({
  String deliveryId,
  String productId,
  String productName,
  int remaining,
  DateTime expiry,
  int warnDays,
});

/// Every batch still on the shelf that has an expiry date.
Future<List<ExpiringBatch>> upcomingExpiries(AppDatabase db) async {
  final warnDays = (await currentShopRow(db))?.expiryWarnDays ?? 3;
  final products = {
    for (final p in await (db.select(db.products)
          ..where((p) => p.deleted.equals(false) & p.archived.equals(false)))
        .get())
      p.id: p.name,
  };
  final batches = await StockLedger(db).allBatches();
  return [
    for (final MapEntry(key: productId, value: state) in batches.entries)
      if (products[productId] case final name?)
        for (final batch in state.onShelf)
          if (batch.expiryDate case final expiry?)
            (
              deliveryId: batch.deliveryId,
              productId: productId,
              productName: name,
              remaining: batch.remaining,
              expiry: expiry,
              warnDays: warnDays,
            ),
  ];
}
