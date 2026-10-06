import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/settings/settings_store.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sale_repository.dart';

class SaleRepositoryImpl implements SaleRepository {
  final AppDatabase db;
  final SettingsStore settings;
  final Uuid _uuid = const Uuid();

  SaleRepositoryImpl(this.db, this.settings);

  @override
  Future<Either<Failure, Sale>> saveSale(List<CartItem> items) async {
    if (items.isEmpty) return const Left(CacheFailure('Empty cart'));
    try {
      // Everything below is saved together, or nothing is saved.
      final saleId = await db.transaction(() async {
        final now = DateTime.now();
        final deviceId = settings.deviceId;
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
              number: (lastNumber ?? 0) + 1,
              subtotal: subtotal,
              total: subtotal,
              paidNow: subtotal,
            ));

        for (final item in items) {
          await db.into(db.saleItems).insert(SaleItemsCompanion.insert(
                id: _uuid.v4(),
                createdAt: now,
                updatedAt: now,
                deviceId: deviceId,
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
      {DateTime? from, DateTime? to}) async {
    try {
      final query = db.select(db.sales)
        ..where((s) => s.deleted.equals(false))
        ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]);
      if (from != null) {
        query.where((s) => s.createdAt.isBiggerOrEqualValue(from));
      }
      if (to != null) query.where((s) => s.createdAt.isSmallerThanValue(to));
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
      return Right(
          sales.map((s) => _toSale(s, linesBySale[s.id] ?? [])).toList());
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
      return Right(_toSale(sale, lines));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Sale _toSale(SaleRow sale, List<SaleItemRow> lines) {
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
