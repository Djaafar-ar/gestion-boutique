import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/user_names.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/settings/settings_store.dart';
import '../../../customers/data/customer_debts.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../shop/data/repositories/shop_repository_impl.dart';
import '../../../stock/data/stock_ledger.dart';
import '../../../stock/domain/entities/loss.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sale_repository.dart';

class SaleRepositoryImpl implements SaleRepository {
  final AppDatabase db;
  final SettingsStore settings;
  final SessionCubit session;
  final StockLedger ledger;

  /// Checks the owner's PIN for a worker's return without a receipt and
  /// gives the owner's id, or null when the PIN is wrong.
  final Future<String?> Function(String pin)? ownerApproval;
  final Uuid _uuid = const Uuid();

  SaleRepositoryImpl(this.db, this.settings, this.session, this.ledger,
      {this.ownerApproval});

  @override
  Future<int?> maxDiscountPercent() async {
    if (session.state.isOwner) return null;
    final shop = await currentShopRow(db);
    return shop?.maxWorkerDiscountPct ?? 10;
  }

  @override
  Future<int> customerDebt(String customerId) =>
      customerDebts(db, ids: [customerId]).then((d) => d[customerId] ?? 0);

  @override
  Future<Either<Failure, Sale>> saveSale(List<CartItem> items,
      {int discount = 0,
      String? customerId,
      int paidNow = 0,
      bool allowOverLimit = false}) async {
    if (items.isEmpty) return const Left(CacheFailure('Empty cart'));
    final subtotal = items.fold<int>(0, (sum, item) => sum + item.total);
    if (discount < 0 || discount > subtotal) {
      return const Left(CacheFailure('Invalid discount'));
    }
    final total = subtotal - discount;
    // A cash sale is paid in full; a credit sale between 0 and the total.
    final paid = customerId == null ? total : paidNow;
    if (paid < 0 || paid > total) {
      return const Left(CacheFailure('Invalid amount paid'));
    }
    try {
      // Checked here too, so the rules hold whatever the screen does.
      final max = await maxDiscountPercent();
      if (max != null && discount * 100 > subtotal * max) {
        return Left(DiscountLimitFailure(max));
      }
      if (customerId != null) {
        final customer = await (db.select(db.customers)
              ..where((c) => c.id.equals(customerId)))
            .getSingleOrNull();
        if (customer == null || !customer.active) {
          return Left(NotFoundFailure(customerId));
        }
        final limit = customer.creditLimit;
        final debtAfter = await customerDebt(customerId) + total - paid;
        final mayGoOver = allowOverLimit && session.state.isOwner;
        if (limit != null && total > paid && debtAfter > limit && !mayGoOver) {
          return Left(CreditLimitFailure(limit: limit, debtAfter: debtAfter));
        }
      }

      // Everything is saved together, or nothing is saved.
      final saleId = await db.transaction(() => _insertSale(
            items: items,
            subtotal: subtotal,
            discount: discount,
            paid: paid,
            customerId: customerId,
            at: DateTime.now(),
          ));
      return await getSale(saleId);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Sale>>> getSales(
      {DateTime? from, DateTime? to, String? userId, int? number}) async {
    try {
      final query = db.select(db.sales)
        ..where((s) => s.deleted.equals(false))
        ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]);
      if (from != null) {
        query.where((s) => s.createdAt.isBiggerOrEqualValue(from));
      }
      if (to != null) query.where((s) => s.createdAt.isSmallerThanValue(to));
      if (userId != null) query.where((s) => s.userId.equals(userId));
      if (number != null) query.where((s) => s.number.equals(number));
      return Right(await _withLines(await query.get()));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Sale>> getSale(String id) async {
    try {
      final sale = await (db.select(db.sales)..where((s) => s.id.equals(id)))
          .getSingleOrNull();
      if (sale == null) return Left(NotFoundFailure(id));
      return Right((await _withLines([sale])).single);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SalesSummary>> getSummary(
      {DateTime? from, DateTime? to, String? userId}) async {
    try {
      Expression<bool> period(
          GeneratedColumn<DateTime> createdAt, GeneratedColumn<bool> deleted) {
        Expression<bool> where = deleted.equals(false);
        if (from != null) where = where & createdAt.isBiggerOrEqualValue(from);
        if (to != null) where = where & createdAt.isSmallerThanValue(to);
        return where;
      }

      Expression<bool> seller(Expression<String> column) =>
          userId == null ? const Constant(true) : column.equals(userId);
      // The seller of the ticket, or whoever took the items back when
      // there was no ticket.
      final returnSeller = coalesce([db.sales.userId, db.returns.userId]);

      final revenue = db.sales.total.sum();
      final count = db.sales.id.count();
      final totals = await (db.selectOnly(db.sales)
            ..addColumns([revenue, count])
            ..where(period(db.sales.createdAt, db.sales.deleted) &
                seller(db.sales.userId)))
          .getSingle();

      final quantity = db.saleItems.quantity.sum();
      final items = await (db.selectOnly(db.saleItems)
            ..addColumns([quantity])
            ..where(period(db.saleItems.createdAt, db.saleItems.deleted) &
                seller(db.saleItems.userId)))
          .getSingle();

      // Returns made in the period, taken off the seller's figures.
      final refunds = db.returns.total.sum();
      final refunded = await (db.selectOnly(db.returns).join([
        leftOuterJoin(db.sales, db.sales.id.equalsExp(db.returns.saleId),
            useColumns: false),
      ])
            ..addColumns([refunds])
            ..where(period(db.returns.createdAt, db.returns.deleted) &
                seller(returnSeller)))
          .getSingle();

      final returnedQty = db.returnItems.quantity.sum();
      final returnedItems = await (db.selectOnly(db.returnItems).join([
        innerJoin(db.returns, db.returns.id.equalsExp(db.returnItems.returnId),
            useColumns: false),
        leftOuterJoin(db.sales, db.sales.id.equalsExp(db.returns.saleId),
            useColumns: false),
      ])
            ..addColumns([returnedQty])
            ..where(period(db.returnItems.createdAt, db.returnItems.deleted) &
                seller(returnSeller)))
          .getSingle();

      return Right(SalesSummary(
        revenue: (totals.read(revenue) ?? 0) - (refunded.read(refunds) ?? 0),
        salesCount: totals.read(count) ?? 0,
        itemsSold: (items.read(quantity) ?? 0) -
            (returnedItems.read(returnedQty) ?? 0),
      ));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> createReturn(
          {required String saleId,
          required List<ReturnLine> lines,
          String? reason,
          bool toCredit = false}) async =>
      (await processReturn(
              saleId: saleId, lines: lines, reason: reason, toCredit: toCredit))
          .map((result) => result.refund);

  @override
  Future<Either<Failure, ReturnResult>> processReturn({
    String? saleId,
    List<ReturnLine> lines = const [],
    List<LooseReturnLine> looseLines = const [],
    List<CartItem> takes = const [],
    String? reason,
    bool toCredit = false,
    String? ownerPin,
  }) async {
    final wanted = lines.where((l) => l.quantity > 0).toList();
    final loose = looseLines.where((l) => l.quantity > 0).toList();
    final taken = takes.where((t) => t.quantity > 0).toList();
    final withReceipt = saleId != null;
    if (withReceipt ? wanted.isEmpty : loose.isEmpty) {
      return const Left(CacheFailure('Nothing to return'));
    }
    if (withReceipt ? loose.isNotEmpty : wanted.isNotEmpty) {
      return const Left(CacheFailure('Receipt and no receipt mixed'));
    }
    try {
      String? approvedBy;
      if (!withReceipt) {
        // No ticket, no customer account to put money back on.
        if (toCredit) return const Left(CacheFailure('No account'));
        // Checked here, whatever the screen does.
        if (!session.state.isOwner) {
          final approve = ownerApproval;
          approvedBy = ownerPin == null || approve == null
              ? null
              : await approve(ownerPin);
          if (approvedBy == null) return const Left(OwnerApprovalFailure());
        }
      }

      final (refund, exchangeSaleId) = await db.transaction(() async {
        final now = DateTime.now();
        final deviceId = settings.deviceId;
        final userId = session.userId;
        final returnId = _uuid.v4();
        var refund = 0;
        var index = 0;
        DateTime nextTime() => now.add(Duration(milliseconds: 10 * index++));

        if (withReceipt) {
          final sale =
              (await getSale(saleId)).getOrElse((f) => throw f.message);
          // Only a credit sale has a customer account to put money back on.
          if (toCredit && !sale.isCredit) throw 'Not a credit sale';
          final byId = {for (final line in sale.items) line.id: line};
          for (final line in wanted) {
            final saleLine = byId[line.saleItemId];
            // Never more than what was sold (minus earlier returns).
            if (saleLine == null || line.quantity > saleLine.returnable) {
              throw 'Cannot return more than sold';
            }
          }
          for (final line in wanted) {
            final saleLine = byId[line.saleItemId]!;
            final at = nextTime();
            final itemId = _uuid.v4();
            final lineRefund = sale.refundFor(saleLine, line.quantity);
            refund += lineRefund;
            await db.into(db.returnItems).insert(ReturnItemsCompanion.insert(
                  id: itemId,
                  createdAt: at,
                  updatedAt: at,
                  deviceId: deviceId,
                  userId: Value(userId),
                  returnId: returnId,
                  saleItemId: Value(line.saleItemId),
                  productId: saleLine.productId,
                  quantity: line.quantity,
                  backToStock: line.backToStock,
                  refund: lineRefund,
                ));
            if (line.backToStock) {
              // Back on the shelf, into the batch it came from.
              await ledger.putBack(
                productId: saleLine.productId,
                saleItemId: line.saleItemId,
                quantity: line.quantity,
                deviceId: deviceId,
                userId: userId,
                at: at,
              );
            } else {
              await _damaged(
                  productId: saleLine.productId,
                  quantity: line.quantity,
                  unitCost: saleLine.unitCost,
                  note: 'Retour ticket n° ${sale.ticket}',
                  returnItemId: itemId,
                  at: at);
            }
          }
        } else {
          final products = {
            for (final p in await (db.select(db.products)
                  ..where((p) => p.id.isIn(loose.map((l) => l.productId))))
                .get())
              p.id: p,
          };
          for (final line in loose) {
            final product =
                products[line.productId] ?? (throw 'Unknown product');
            final at = nextTime();
            final itemId = _uuid.v4();
            // Today's price: there is no ticket to say what was paid.
            final lineRefund = product.sellPrice * line.quantity;
            refund += lineRefund;
            await db.into(db.returnItems).insert(ReturnItemsCompanion.insert(
                  id: itemId,
                  createdAt: at,
                  updatedAt: at,
                  deviceId: deviceId,
                  userId: Value(userId),
                  returnId: returnId,
                  productId: product.id,
                  quantity: line.quantity,
                  backToStock: line.backToStock,
                  refund: lineRefund,
                  unitCost: Value(product.buyPrice),
                ));
            if (line.backToStock) {
              // Nobody knows which delivery it came from.
              await ledger.putBackWithoutBatch(
                productId: product.id,
                quantity: line.quantity,
                sourceId: itemId,
                deviceId: deviceId,
                userId: userId,
                at: at,
              );
            } else {
              await _damaged(
                  productId: product.id,
                  quantity: line.quantity,
                  unitCost: product.buyPrice,
                  note: 'Retour sans ticket',
                  returnItemId: itemId,
                  at: at);
            }
          }
        }

        // Exchange: the items taken become a new ticket, paid in cash
        // (the items brought back pay for part of it).
        String? exchangeSaleId;
        if (taken.isNotEmpty) {
          final subtotal = taken.fold<int>(0, (sum, item) => sum + item.total);
          exchangeSaleId = await _insertSale(
            items: taken,
            subtotal: subtotal,
            discount: 0,
            paid: subtotal,
            customerId: null,
            at: nextTime(),
          );
        }

        await db.into(db.returns).insert(ReturnsCompanion.insert(
              id: returnId,
              createdAt: now,
              updatedAt: now,
              deviceId: deviceId,
              userId: Value(userId),
              saleId: Value(saleId),
              total: refund,
              refundMode: Value(toCredit ? 'credit' : 'cash'),
              reason: Value(reason?.trim().isEmpty ?? true ? null : reason),
              exchangeSaleId: Value(exchangeSaleId),
              approvedBy: Value(approvedBy),
            ));
        return (refund, exchangeSaleId);
      });

      final exchangeSale = exchangeSaleId == null
          ? null
          : (await getSale(exchangeSaleId)).toNullable();
      return Right(ReturnResult(
          refund: refund, toCredit: toCredit, exchangeSale: exchangeSale));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  /// A damaged item brought back: money lost at buying price. The item
  /// already left the stock with the sale, so the stock does not change.
  Future<void> _damaged({
    required String productId,
    required int quantity,
    required int unitCost,
    required String note,
    required String returnItemId,
    required DateTime at,
  }) =>
      db.into(db.losses).insert(LossesCompanion.insert(
            id: _uuid.v4(),
            createdAt: at,
            updatedAt: at,
            deviceId: settings.deviceId,
            userId: Value(session.userId),
            productId: productId,
            quantity: quantity,
            reason: LossReason.damaged.name,
            note: Value(note),
            unitCost: unitCost,
            returnItemId: Value(returnItemId),
          ));

  /// Writes a ticket and takes its items out of the stock. Call it inside
  /// a transaction. Returns the new sale id.
  Future<String> _insertSale({
    required List<CartItem> items,
    required int subtotal,
    required int discount,
    required int paid,
    required String? customerId,
    required DateTime at,
  }) async {
    final now = at;
    final deviceId = settings.deviceId;
    final userId = session.userId;
    final saleId = _uuid.v4();
    final total = subtotal - discount;

    // Each phone counts its own tickets (the letter tells them apart).
    final maxNumber = db.sales.number.max();
    final lastNumber = await (db.selectOnly(db.sales)
          ..addColumns([maxNumber])
          ..where(db.sales.deviceId.equals(deviceId)))
        .map((row) => row.read(maxNumber))
        .getSingle();

    await db.into(db.sales).insert(SalesCompanion.insert(
          id: saleId,
          createdAt: now,
          updatedAt: now,
          deviceId: deviceId,
          userId: Value(userId),
          number: (lastNumber ?? 0) + 1,
          subtotal: subtotal,
          discount: Value(discount),
          total: total,
          paidNow: paid,
          customerId: Value(customerId),
        ));

    for (final (index, item) in items.indexed) {
      // A few milliseconds apart, so the lines keep the cart order.
      final lineTime = now.add(Duration(milliseconds: index * 10));
      final lineId = _uuid.v4();
      // Items leave the batch that expires first; the line keeps their
      // real buying price for the profit.
      final unitCost = await ledger.takeOut(
        productId: item.product.id,
        quantity: item.quantity,
        source: 'sale',
        sourceId: lineId,
        fallbackCost: item.product.buyPrice,
        deviceId: deviceId,
        userId: userId,
        at: lineTime,
      );
      await db.into(db.saleItems).insert(SaleItemsCompanion.insert(
            id: lineId,
            createdAt: lineTime,
            updatedAt: lineTime,
            deviceId: deviceId,
            userId: Value(userId),
            saleId: saleId,
            productId: item.product.id,
            productName: item.product.name,
            sellPrice: item.product.sellPrice,
            unitCost: unitCost,
            quantity: item.quantity,
          ));
    }
    return saleId;
  }

  /// Turns sale rows into sales with their lines, seller name, returned
  /// quantities and refunds.
  Future<List<Sale>> _withLines(List<SaleRow> sales) async {
    if (sales.isEmpty) return [];
    final ids = sales.map((s) => s.id).toList();

    final lines = await (db.select(db.saleItems)
          ..where((i) => i.saleId.isIn(ids) & i.deleted.equals(false)))
        .get();
    final linesBySale = <String, List<SaleItemRow>>{};
    for (final line in lines) {
      linesBySale.putIfAbsent(line.saleId, () => []).add(line);
    }

    final returnedQty = db.returnItems.quantity.sum();
    final returnedRows = await (db.selectOnly(db.returnItems)
          ..addColumns([db.returnItems.saleItemId, returnedQty])
          ..where(db.returnItems.saleItemId.isIn(lines.map((l) => l.id)) &
              db.returnItems.deleted.equals(false))
          ..groupBy([db.returnItems.saleItemId]))
        .get();
    final returned = {
      for (final row in returnedRows)
        row.read(db.returnItems.saleItemId)!: row.read(returnedQty) ?? 0,
    };

    final refundSum = db.returns.total.sum();
    final refundRows = await (db.selectOnly(db.returns)
          ..addColumns([db.returns.saleId, refundSum])
          ..where(
              db.returns.saleId.isIn(ids) & db.returns.deleted.equals(false))
          ..groupBy([db.returns.saleId]))
        .get();
    final refunded = {
      for (final row in refundRows)
        row.read(db.returns.saleId)!: row.read(refundSum) ?? 0,
    };

    final exchangeRows = await (db.selectOnly(db.returns)
          ..addColumns([db.returns.exchangeSaleId, refundSum])
          ..where(db.returns.exchangeSaleId.isIn(ids) &
              db.returns.refundMode.equals('cash') &
              db.returns.deleted.equals(false))
          ..groupBy([db.returns.exchangeSaleId]))
        .get();
    final exchangeCredit = {
      for (final row in exchangeRows)
        row.read(db.returns.exchangeSaleId)!: row.read(refundSum) ?? 0,
    };

    final names = await userNames(db, sales.map((s) => s.userId));
    final codes = await deviceCodes(db);
    final customerIds = sales.map((s) => s.customerId).whereType<String>();
    final customers = customerIds.isEmpty
        ? <String, String>{}
        : {
            for (final c in await (db.select(db.customers)
                  ..where((c) => c.id.isIn(customerIds)))
                .get())
              c.id: c.name,
          };
    return [
      for (final sale in sales)
        _toSale(
            sale,
            linesBySale[sale.id] ?? [],
            names,
            returned,
            refunded[sale.id] ?? 0,
            customers,
            exchangeCredit[sale.id] ?? 0,
            codes[sale.deviceId]),
    ];
  }

  Sale _toSale(
      SaleRow sale,
      List<SaleItemRow> lines,
      Map<String, String> names,
      Map<String, int> returned,
      int refunded,
      Map<String, String> customers,
      int exchangeCredit,
      String? deviceCode) {
    // Keep the order in which items were added to the cart.
    lines.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return Sale(
      id: sale.id,
      number: sale.number,
      subtotal: sale.subtotal,
      discount: sale.discount,
      total: sale.total,
      paidNow: sale.paidNow,
      createdAt: sale.createdAt,
      userId: sale.userId,
      sellerName: names[sale.userId],
      refunded: refunded,
      customerId: sale.customerId,
      customerName: customers[sale.customerId],
      exchangeCredit: exchangeCredit,
      deviceCode: deviceCode,
      items: lines
          .map((l) => SaleLine(
                id: l.id,
                productId: l.productId,
                productName: l.productName,
                sellPrice: l.sellPrice,
                unitCost: l.unitCost,
                quantity: l.quantity,
                returned: returned[l.id] ?? 0,
              ))
          .toList(),
    );
  }
}
