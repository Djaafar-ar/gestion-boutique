import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/settings/settings_store.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sale_repository.dart';

class SaleRepositoryImpl implements SaleRepository {
  final AppDatabase db;
  final SettingsStore settings;
  final SessionCubit session;
  final Uuid _uuid = const Uuid();

  SaleRepositoryImpl(this.db, this.settings, this.session);

  @override
  Future<Either<Failure, Sale>> saveSale(List<CartItem> items) async {
    if (items.isEmpty) return const Left(CacheFailure('Empty cart'));
    try {
      // Everything below is saved together, or nothing is saved.
      final saleId = await db.transaction(() async {
        final now = DateTime.now();
        final deviceId = settings.deviceId;
        final userId = Value(session.userId);
        final saleId = _uuid.v4();

        final maxNumber = db.sales.number.max();
        final lastNumber = await (db.selectOnly(db.sales)
              ..addColumns([maxNumber]))
            .map((row) => row.read(maxNumber))
            .getSingle();

        final subtotal = items.fold<int>(0, (sum, item) => sum + item.total);
        await db.into(db.sales).insert(SalesCompanion.insert(
              id: saleId,
              createdAt: now,
              updatedAt: now,
              deviceId: deviceId,
              userId: userId,
              number: (lastNumber ?? 0) + 1,
              subtotal: subtotal,
              total: subtotal,
              paidNow: subtotal,
            ));

        for (final (index, item) in items.indexed) {
          // One millisecond apart, so the lines keep the cart order.
          final lineTime = now.add(Duration(milliseconds: index));
          await db.into(db.saleItems).insert(SaleItemsCompanion.insert(
                id: _uuid.v4(),
                createdAt: lineTime,
                updatedAt: lineTime,
                deviceId: deviceId,
                userId: userId,
                saleId: saleId,
                productId: item.product.id,
                productName: item.product.name,
                sellPrice: item.product.sellPrice,
                unitCost: item.product.buyPrice,
                quantity: item.quantity,
              ));
        }
        return saleId;
      });
      return await getSale(saleId);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Sale>>> getSales(
      {DateTime? from, DateTime? to, String? userId}) async {
    try {
      final query = db.select(db.sales)
        ..where((s) => s.deleted.equals(false))
        ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]);
      if (from != null) {
        query.where((s) => s.createdAt.isBiggerOrEqualValue(from));
      }
      if (to != null) query.where((s) => s.createdAt.isSmallerThanValue(to));
      if (userId != null) query.where((s) => s.userId.equals(userId));
      final sales = await query.get();
      if (sales.isEmpty) return const Right([]);

      final lines = await (db.select(db.saleItems)
            ..where((i) =>
                i.saleId.isIn(sales.map((s) => s.id)) &
                i.deleted.equals(false)))
          .get();
      final linesBySale = <String, List<SaleItemRow>>{};
      for (final line in lines) {
        linesBySale.putIfAbsent(line.saleId, () => []).add(line);
      }
      final names = await _userNames(sales.map((s) => s.userId));
      return Right(sales
          .map((s) => _toSale(s, linesBySale[s.id] ?? [], names))
          .toList());
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
      final lines = await (db.select(db.saleItems)
            ..where((i) => i.saleId.equals(id) & i.deleted.equals(false)))
          .get();
      return Right(_toSale(sale, lines, await _userNames([sale.userId])));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SalesSummary>> getSummary(
      {DateTime? from, DateTime? to, String? userId}) async {
    try {
      Expression<bool> filter(GeneratedColumn<DateTime> createdAt,
          GeneratedColumn<String> seller, GeneratedColumn<bool> deleted) {
        Expression<bool> where = deleted.equals(false);
        if (from != null) where = where & createdAt.isBiggerOrEqualValue(from);
        if (to != null) where = where & createdAt.isSmallerThanValue(to);
        if (userId != null) where = where & seller.equals(userId);
        return where;
      }

      final revenue = db.sales.total.sum();
      final count = db.sales.id.count();
      final totals = await (db.selectOnly(db.sales)
            ..addColumns([revenue, count])
            ..where(
                filter(db.sales.createdAt, db.sales.userId, db.sales.deleted)))
          .getSingle();

      final quantity = db.saleItems.quantity.sum();
      final items = await (db.selectOnly(db.saleItems)
            ..addColumns([quantity])
            ..where(filter(db.saleItems.createdAt, db.saleItems.userId,
                db.saleItems.deleted)))
          .getSingle();

      return Right(SalesSummary(
        revenue: totals.read(revenue) ?? 0,
        salesCount: totals.read(count) ?? 0,
        itemsSold: items.read(quantity) ?? 0,
      ));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<Map<String, String>> _userNames(Iterable<String?> ids) async {
    final wanted = ids.whereType<String>().toSet();
    if (wanted.isEmpty) return {};
    final rows =
        await (db.select(db.users)..where((u) => u.id.isIn(wanted))).get();
    return {for (final row in rows) row.id: row.name};
  }

  Sale _toSale(
      SaleRow sale, List<SaleItemRow> lines, Map<String, String> names) {
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
      items: lines
          .map((l) => SaleLine(
                productId: l.productId,
                productName: l.productName,
                sellPrice: l.sellPrice,
                unitCost: l.unitCost,
                quantity: l.quantity,
              ))
          .toList(),
    );
  }
}
