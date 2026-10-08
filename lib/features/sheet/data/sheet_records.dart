import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/user_names.dart';
import '../../../core/utils/date_format.dart';
import '../../billing/domain/entities/sale.dart';
import '../../customers/data/customer_debts.dart';
import '../../stock/data/stock_ledger.dart';
import 'sheet_protocol.dart';

/// One record as the script receives it: its kind and id, and its rows
/// for each tab (by the tab's short code, see Code.gs). `u: 1` means the
/// rows replace the earlier version (supplier payments, customer credit).
typedef SheetRecord = Map<String, Object?>;

/// The sheet is in French, like the receipts.
const _lossReasons = {
  'damaged': 'Abîmé',
  'expired': 'Périmé',
  'staff': 'Consommé (personnel)',
  'stolen': 'Volé',
  'other': 'Autre',
};

/// The product fields of the history, as the sheet shows them.
const _productFields = {
  'name': 'Nom',
  'barcode': 'Code-barres',
  'sellPrice': 'Prix de vente',
  'buyPrice': "Prix d'achat",
  'category': 'Catégorie',
  'lowStockThreshold': 'Seuil de stock bas',
  'archived': 'Archivé',
};

/// Records only the owner's phone sends, signed with the read key: they
/// hold the buying prices and the customers' debts.
const ownerOnlyKinds = {'credit', 'product'};

const _paymentStatus = {
  'pending': 'En attente',
  'validated': 'Validé',
  'rejected': 'Refusé',
};

/// Turns the records waiting in `sheet_queue` into rows of the Google
/// Sheet tabs:
/// - S "Sales": one row per sale, return, exchange or customer payment.
///   "Ventes" is 1 for a sale; returns have a negative total and profit;
///   "Encaissé" is the cash that came in (or went out).
/// - I "Sale items": one row per item sold or brought back. "Sortie de
///   stock" is what left the shelf (negative when put back).
/// - D "Stock deliveries", L "Losses", P "Supplier payments",
///   C "Customer credit" (what each customer owes now).
/// - H "Historique produits": every change of a product (name, prices...).
/// - R "Produits": each product now, with its stock and nearest expiry.
class SheetRecords {
  final AppDatabase db;

  SheetRecords(this.db);

  /// The records of [entries]. On a worker phone, [onlyDevice] leaves out
  /// what was done on other phones, and [withCredit] false leaves out the
  /// customers' debts (the owner's phone sends them).
  Future<List<SheetRecord>> build(List<SheetQueueRow> entries,
      {String? onlyDevice, bool withCredit = true}) async {
    // [withCredit] false: none of the owner's records (debts, products).
    final ids = <String, Set<String>>{};
    for (final entry in entries) {
      ids.putIfAbsent(entry.kind, () => {}).add(entry.rowId);
    }
    final ctx = await _Context.load(db);
    bool keep(String deviceId, bool deleted) =>
        !deleted && (onlyDevice == null || deviceId == onlyDevice);

    final records = <String, SheetRecord>{};
    if (ids['sale'] case final wanted?) {
      final sales =
          await (db.select(db.sales)..where((s) => s.id.isIn(wanted))).get();
      final items = await (db.select(db.saleItems)
            ..where((i) => i.saleId.isIn(wanted) & i.deleted.equals(false))
            ..orderBy([(i) => OrderingTerm.asc(i.createdAt)]))
          .get();
      await ctx.loadCustomers(db, sales.map((s) => s.customerId));
      for (final sale in sales) {
        if (!keep(sale.deviceId, sale.deleted)) continue;
        records['sale:${sale.id}'] =
            _sale(ctx, sale, items.where((i) => i.saleId == sale.id));
      }
    }
    if (ids['return'] case final wanted?) {
      final returns =
          await (db.select(db.returns)..where((r) => r.id.isIn(wanted))).get();
      final items = await (db.select(db.returnItems)
            ..where((i) => i.returnId.isIn(wanted) & i.deleted.equals(false))
            ..orderBy([(i) => OrderingTerm.asc(i.createdAt)]))
          .get();
      final saleIds = returns.map((r) => r.saleId).whereType<String>().toSet();
      final sales = {
        for (final s in await (db.select(db.sales)
              ..where((s) => s.id.isIn(saleIds)))
            .get())
          s.id: s,
      };
      final lineIds = items.map((i) => i.saleItemId).whereType<String>();
      final lines = {
        for (final l in await (db.select(db.saleItems)
              ..where((l) => l.id.isIn(lineIds)))
            .get())
          l.id: l,
      };
      await ctx.loadProducts(db, items.map((i) => i.productId));
      await ctx.loadCustomers(db, sales.values.map((s) => s.customerId));
      for (final ret in returns) {
        if (!keep(ret.deviceId, ret.deleted)) continue;
        records['return:${ret.id}'] = _return(ctx, ret, sales[ret.saleId],
            items.where((i) => i.returnId == ret.id), lines);
      }
    }
    if (ids['customerPayment'] case final wanted?) {
      final payments = await (db.select(db.customerPayments)
            ..where((p) => p.id.isIn(wanted)))
          .get();
      await ctx.loadCustomers(db, payments.map((p) => p.customerId));
      for (final p in payments) {
        if (!keep(p.deviceId, p.deleted)) continue;
        final at = p.createdAt.toLocal();
        records['customerPayment:${p.id}'] = {
          'k': 'customerPayment',
          'id': p.id,
          't': {
            'S': [
              [
                p.id, sheetDay(at), formatTime(at), '', ctx.name(p.userId), //
                ctx.code(p.deviceId), 'Paiement client', '',
                ctx.customers[p.customerId] ?? '', 0, 0, 0, 0, 0, 0,
                sheetMoney(p.amount),
              ],
            ],
          },
        };
      }
    }
    if (ids['delivery'] case final wanted?) {
      final deliveries = await (db.select(db.deliveries)
            ..where((d) => d.id.isIn(wanted)))
          .get();
      await ctx.loadProducts(db, deliveries.map((d) => d.productId));
      await ctx.loadSuppliers(db, deliveries.map((d) => d.supplierId));
      for (final d in deliveries) {
        if (!keep(d.deviceId, d.deleted)) continue;
        final at = d.receivedAt.toLocal();
        final expiry = d.expiryDate?.toLocal();
        records['delivery:${d.id}'] = {
          'k': 'delivery',
          'id': d.id,
          't': {
            'D': [
              [
                d.id, sheetDay(at), formatTime(at), //
                ctx.products[d.productId] ?? '', d.quantity,
                sheetMoney(d.buyPrice), sheetMoney(d.buyPrice * d.quantity),
                ctx.suppliers[d.supplierId] ?? '',
                expiry == null ? '' : sheetDay(expiry), ctx.name(d.userId),
                ctx.code(d.deviceId),
              ],
            ],
          },
        };
      }
    }
    if (ids['loss'] case final wanted?) {
      final losses =
          await (db.select(db.losses)..where((l) => l.id.isIn(wanted))).get();
      await ctx.loadProducts(db, losses.map((l) => l.productId));
      for (final l in losses) {
        if (!keep(l.deviceId, l.deleted)) continue;
        final at = l.createdAt.toLocal();
        records['loss:${l.id}'] = {
          'k': 'loss',
          'id': l.id,
          't': {
            'L': [
              [
                l.id, sheetDay(at), formatTime(at), //
                ctx.products[l.productId] ?? '', l.quantity,
                _lossReasons[l.reason] ?? l.reason, sheetMoney(l.unitCost),
                sheetMoney(l.unitCost * l.quantity), l.note ?? '',
                ctx.name(l.userId), ctx.code(l.deviceId),
                // A damaged item brought back by a customer already left
                // the stock with the sale.
                l.returnItemId == null ? l.quantity : 0,
              ],
            ],
          },
        };
      }
    }
    if (ids['supplierPayment'] case final wanted?) {
      final payments = await (db.select(db.supplierPayments)
            ..where((p) => p.id.isIn(wanted)))
          .get();
      await ctx.loadSuppliers(db, payments.map((p) => p.supplierId));
      for (final p in payments) {
        if (!keep(p.deviceId, p.deleted)) continue;
        final at = p.createdAt.toLocal();
        records['supplierPayment:${p.id}'] = {
          'k': 'supplierPayment',
          'id': p.id,
          'u': 1,
          't': {
            'P': [
              [
                p.id, sheetDay(at), formatTime(at), //
                ctx.suppliers[p.supplierId] ?? '', sheetMoney(p.amount),
                _paymentStatus[p.status] ?? p.status, ctx.name(p.userId),
                ctx.name(p.validatedBy), p.note ?? '', ctx.code(p.deviceId),
              ],
            ],
          },
        };
      }
    }
    if (ids['credit'] case final wanted? when withCredit) {
      final customers = await (db.select(db.customers)
            ..where((c) => c.id.isIn(wanted)))
          .get();
      final debts = await customerDebts(db, ids: wanted);
      final lastPaid = db.customerPayments.createdAt.max();
      final paidAt = {
        for (final row in await (db.selectOnly(db.customerPayments)
              ..addColumns([db.customerPayments.customerId, lastPaid])
              ..where(db.customerPayments.customerId.isIn(wanted) &
                  db.customerPayments.deleted.equals(false))
              ..groupBy([db.customerPayments.customerId]))
            .get())
          row.read(db.customerPayments.customerId)!: row.read(lastPaid),
      };
      for (final c in customers) {
        if (c.deleted) continue;
        final last = paidAt[c.id]?.toLocal();
        records['credit:${c.id}'] = {
          'k': 'credit',
          'id': c.id,
          'u': 1,
          't': {
            'C': [
              [
                c.id, c.name, sheetMoney(debts[c.id] ?? 0), //
                last == null ? '' : sheetDay(last),
              ],
            ],
          },
        };
      }
    }
    if (ids['change'] case final wanted?) {
      final changes = await (db.select(db.changeLogs)
            ..where((c) => c.id.isIn(wanted)))
          .get();
      await ctx.loadProducts(db, changes.map((c) => c.entityId));
      for (final c in changes) {
        if (!keep(c.deviceId, c.deleted) || c.entity != 'product') continue;
        final at = c.createdAt.toLocal();
        final money = c.field == 'sellPrice' || c.field == 'buyPrice';
        Object? value(String? v) {
          if (v == null) return '';
          if (money) return sheetMoney(int.tryParse(v) ?? 0);
          if (c.field == 'archived') return v == 'true' ? 'Oui' : 'Non';
          return v;
        }

        records['change:${c.id}'] = {
          'k': 'change',
          'id': c.id,
          't': {
            'H': [
              [
                c.id, sheetDay(at), formatTime(at), //
                ctx.products[c.entityId] ?? '',
                _productFields[c.field] ?? c.field, value(c.oldValue),
                value(c.newValue), ctx.name(c.userId), ctx.code(c.deviceId),
              ],
            ],
          },
        };
      }
    }
    if (ids['product'] case final wanted? when withCredit) {
      final products =
          await (db.select(db.products)..where((p) => p.id.isIn(wanted))).get();
      final categories = {
        for (final c in await db.select(db.categories).get()) c.id: c.name,
      };
      final ledger = StockLedger(db);
      for (final p in products) {
        if (p.deleted) continue;
        final batches = await ledger.batchesOf(p.id);
        final expiries = [
          for (final b in batches.onShelf)
            if (b.expiryDate case final date?) date.toLocal(),
        ]..sort();
        records['product:${p.id}'] = {
          'k': 'product',
          'id': p.id,
          'u': 1,
          't': {
            'R': [
              [
                p.id, p.name, p.barcode, categories[p.categoryId] ?? '', //
                sheetMoney(p.sellPrice), sheetMoney(p.buyPrice),
                batches.stock,
                expiries.isEmpty ? '' : sheetDay(expiries.first),
                p.archived ? 'Oui' : 'Non',
              ],
            ],
          },
        };
      }
    }
    // Keep the order of the queue.
    return [
      for (final entry in entries)
        if (records['${entry.kind}:${entry.rowId}'] case final record?) record,
    ];
  }

  SheetRecord _sale(_Context ctx, SaleRow sale, Iterable<SaleItemRow> items) {
    final at = sale.createdAt.toLocal();
    final day = sheetDay(at);
    final ticket = ticketLabel(sale.number, ctx.codes[sale.deviceId]);
    final seller = ctx.name(sale.userId);
    final cost = items.fold(0, (sum, i) => sum + i.unitCost * i.quantity);
    return {
      'k': 'sale',
      'id': sale.id,
      't': {
        'S': [
          [
            sale.id, day, formatTime(at), ticket, seller, //
            ctx.code(sale.deviceId), 'Vente',
            sale.customerId == null ? 'Comptant' : 'Crédit',
            ctx.customers[sale.customerId] ?? '', 1,
            sheetMoney(sale.subtotal), sheetMoney(sale.discount),
            sheetMoney(sale.total), sheetMoney(sale.total - cost), 0,
            sheetMoney(sale.paidNow),
          ],
        ],
        'I': [
          for (final i in items)
            [
              i.id, day, ticket, i.productName, i.quantity, //
              sheetMoney(i.sellPrice), sheetMoney(i.sellPrice * i.quantity),
              sheetMoney(i.unitCost),
              sheetMoney((i.sellPrice - i.unitCost) * i.quantity), seller,
              i.quantity, 'Vente',
            ],
        ],
      },
    };
  }

  SheetRecord _return(_Context ctx, ReturnRow ret, SaleRow? sale,
      Iterable<ReturnItemRow> items, Map<String, SaleItemRow> lines) {
    final at = ret.createdAt.toLocal();
    final day = sheetDay(at);
    final ticket =
        sale == null ? '' : ticketLabel(sale.number, ctx.codes[sale.deviceId]);
    // Like the Stats tab: the money of a return counts for who sold.
    final seller = ctx.name(sale?.userId ?? ret.userId);
    var costBack = 0;
    final rows = <List<Object?>>[];
    for (final item in items) {
      final line = lines[item.saleItemId];
      final unitCost = line?.unitCost ?? item.unitCost ?? 0;
      // Back on the shelf: the shop has the item (and its cost) again.
      final back = item.backToStock ? unitCost * item.quantity : 0;
      costBack += back;
      rows.add([
        item.id, day, ticket, //
        line?.productName ?? ctx.products[item.productId] ?? '',
        -item.quantity,
        item.quantity == 0 ? 0 : sheetMoney(item.refund) / item.quantity,
        sheetMoney(-item.refund), sheetMoney(unitCost),
        sheetMoney(back - item.refund), seller,
        item.backToStock ? -item.quantity : 0,
        item.backToStock ? 'Retour' : 'Retour (abîmé)',
      ]);
    }
    final toCredit = ret.refundMode == 'credit';
    return {
      'k': 'return',
      'id': ret.id,
      't': {
        'S': [
          [
            ret.id, day, formatTime(at), ticket, seller, //
            ctx.code(ret.deviceId),
            switch ((ret.exchangeSaleId == null, sale == null)) {
              (true, false) => 'Retour',
              (true, true) => 'Retour sans ticket',
              (false, false) => 'Échange',
              (false, true) => 'Échange sans ticket',
            },
            toCredit ? 'Crédit' : 'Comptant',
            ctx.customers[sale?.customerId] ?? '', 0, 0, 0,
            sheetMoney(-ret.total), sheetMoney(costBack - ret.total),
            sheetMoney(ret.total), toCredit ? 0 : sheetMoney(-ret.total),
          ],
        ],
        'I': rows,
      },
    };
  }
}

/// Names and letters looked up once per batch.
class _Context {
  final Map<String, String> names;
  final Map<String, String> codes;
  final Map<String?, String> products = {};
  final Map<String?, String> suppliers = {};
  final Map<String?, String> customers = {};

  _Context(this.names, this.codes);

  static Future<_Context> load(AppDatabase db) async => _Context(
        {for (final u in await db.select(db.users).get()) u.id: u.name},
        await deviceCodes(db),
      );

  String name(String? userId) => names[userId] ?? '';

  /// The phone's letter, empty while the shop has one phone.
  String code(String deviceId) => codes[deviceId] ?? '';

  Future<void> loadProducts(AppDatabase db, Iterable<String> ids) async {
    final wanted = ids.toSet()..removeAll(products.keys);
    if (wanted.isEmpty) return;
    for (final p in await (db.select(db.products)
          ..where((p) => p.id.isIn(wanted)))
        .get()) {
      products[p.id] = p.name;
    }
  }

  Future<void> loadSuppliers(AppDatabase db, Iterable<String?> ids) async {
    final wanted = ids.whereType<String>().toSet()..removeAll(suppliers.keys);
    if (wanted.isEmpty) return;
    for (final s in await (db.select(db.suppliers)
          ..where((s) => s.id.isIn(wanted)))
        .get()) {
      suppliers[s.id] = s.name;
    }
  }

  Future<void> loadCustomers(AppDatabase db, Iterable<String?> ids) async {
    final wanted = ids.whereType<String>().toSet()..removeAll(customers.keys);
    if (wanted.isEmpty) return;
    for (final c in await (db.select(db.customers)
          ..where((c) => c.id.isIn(wanted)))
        .get()) {
      customers[c.id] = c.name;
    }
  }
}
