import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/user_names.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/settings/settings_store.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final AppDatabase db;
  final SettingsStore settings;
  final SessionCubit session;

  SupplierRepositoryImpl(this.db, this.settings, this.session);

  @override
  Future<Either<Failure, List<Supplier>>> getSuppliers(
      {bool includeArchived = false}) async {
    try {
      final query = db.select(db.suppliers)
        ..where((s) => s.deleted.equals(false))
        ..orderBy([(s) => OrderingTerm.asc(s.name.collate(Collate.noCase))]);
      if (!includeArchived) query.where((s) => s.active.equals(true));
      return Right(await _withTotals(await query.get()));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Supplier>> getSupplier(String id) async {
    try {
      final row = await (db.select(db.suppliers)..where((s) => s.id.equals(id)))
          .getSingleOrNull();
      if (row == null) return Left(NotFoundFailure(id));
      return Right((await _withTotals([row])).single);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Supplier>> saveSupplier({
    String? id,
    required String name,
    String phone = '',
    String? note,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return const Left(CacheFailure('Name required'));
    try {
      final now = DateTime.now();
      final cleanNote = note?.trim().isEmpty ?? true ? null : note!.trim();
      if (id == null) {
        final newId = const Uuid().v4();
        await db.into(db.suppliers).insert(SuppliersCompanion.insert(
              id: newId,
              createdAt: now,
              updatedAt: now,
              deviceId: settings.deviceId,
              userId: Value(session.userId),
              name: trimmed,
              phone: Value(phone.trim()),
              note: Value(cleanNote),
            ));
        return await getSupplier(newId);
      }
      await (db.update(db.suppliers)..where((s) => s.id.equals(id))).write(
          SuppliersCompanion(
              updatedAt: Value(now),
              name: Value(trimmed),
              phone: Value(phone.trim()),
              note: Value(cleanNote)));
      return await getSupplier(id);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setArchived(String id, bool archived) async {
    if (!session.state.isOwner) {
      return const Left(PermissionFailure('Only the owner'));
    }
    try {
      await (db.update(db.suppliers)..where((s) => s.id.equals(id))).write(
          SuppliersCompanion(
              active: Value(!archived), updatedAt: Value(DateTime.now())));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SupplierDelivery>>> getDeliveries(
      String supplierId) async {
    try {
      final rows = await (db.select(db.deliveries).join([
        leftOuterJoin(
            db.products, db.products.id.equalsExp(db.deliveries.productId)),
      ])
            ..where(db.deliveries.supplierId.equals(supplierId) &
                db.deliveries.deleted.equals(false))
            ..orderBy([OrderingTerm.desc(db.deliveries.receivedAt)]))
          .get();
      final deliveries = rows.map((r) => r.readTable(db.deliveries)).toList();
      final names = await userNames(db, deliveries.map((d) => d.userId));
      return Right([
        for (final row in rows)
          SupplierDelivery(
            id: row.readTable(db.deliveries).id,
            productName: row.readTableOrNull(db.products)?.name ?? '?',
            quantity: row.readTable(db.deliveries).quantity,
            buyPrice: row.readTable(db.deliveries).buyPrice,
            receivedAt: row.readTable(db.deliveries).receivedAt,
            receivedByName: names[row.readTable(db.deliveries).userId],
          ),
      ]);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SupplierPayment>>> getPayments(
      {String? supplierId, PaymentStatus? status}) async {
    try {
      final query = db.select(db.supplierPayments).join([
        leftOuterJoin(db.suppliers,
            db.suppliers.id.equalsExp(db.supplierPayments.supplierId)),
      ])
        ..where(db.supplierPayments.deleted.equals(false))
        ..orderBy([OrderingTerm.desc(db.supplierPayments.createdAt)]);
      if (supplierId != null) {
        query.where(db.supplierPayments.supplierId.equals(supplierId));
      }
      if (status != null) {
        query.where(db.supplierPayments.status.equals(status.name));
      }
      final rows = await query.get();
      final payments = rows.map((r) => r.readTable(db.supplierPayments));
      final names = await userNames(db, [
        ...payments.map((p) => p.userId),
        ...payments.map((p) => p.validatedBy),
      ]);
      return Right([
        for (final row in rows)
          _toPayment(row.readTable(db.supplierPayments),
              row.readTableOrNull(db.suppliers)?.name ?? '?', names),
      ]);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SupplierPayment>> recordPayment({
    required String supplierId,
    required int amount,
    String? note,
  }) async {
    if (amount <= 0) return const Left(CacheFailure('Amount must be > 0'));
    final userId = session.userId;
    if (userId == null) return const Left(PermissionFailure('Not logged in'));
    try {
      final now = DateTime.now();
      final owner = session.state.isOwner;
      final id = const Uuid().v4();
      await db.into(db.supplierPayments).insert(
            SupplierPaymentsCompanion.insert(
              id: id,
              createdAt: now,
              updatedAt: now,
              deviceId: settings.deviceId,
              userId: Value(userId),
              supplierId: supplierId,
              amount: amount,
              note: Value(note?.trim().isEmpty ?? true ? null : note!.trim()),
              // The owner's own payments need no check.
              status: owner
                  ? PaymentStatus.validated.name
                  : PaymentStatus.pending.name,
              validatedBy: Value(owner ? userId : null),
              validatedAt: Value(owner ? now : null),
            ),
          );
      final saved = await getPayments(supplierId: supplierId);
      return saved.map((list) => list.firstWhere((p) => p.id == id));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> validatePayment(String paymentId) =>
      _decide(paymentId, PaymentStatus.validated);

  @override
  Future<Either<Failure, void>> rejectPayment(String paymentId) =>
      _decide(paymentId, PaymentStatus.rejected);

  Future<Either<Failure, void>> _decide(
      String paymentId, PaymentStatus status) async {
    if (!session.state.isOwner) {
      return const Left(PermissionFailure('Only the owner'));
    }
    try {
      final now = DateTime.now();
      // Only a payment still waiting can be decided, and only once.
      final changed = await (db.update(db.supplierPayments)
            ..where((p) =>
                p.id.equals(paymentId) &
                p.status.equals(PaymentStatus.pending.name)))
          .write(SupplierPaymentsCompanion(
        status: Value(status.name),
        validatedBy: Value(session.userId),
        validatedAt: Value(now),
        updatedAt: Value(now),
      ));
      if (changed == 0) {
        return const Left(CacheFailure('Payment is not pending'));
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<int> pendingCount() async {
    final count = db.supplierPayments.id.count();
    final row = await (db.selectOnly(db.supplierPayments)
          ..addColumns([count])
          ..where(
              db.supplierPayments.status.equals(PaymentStatus.pending.name) &
                  db.supplierPayments.deleted.equals(false)))
        .getSingle();
    return row.read(count) ?? 0;
  }

  /// Adds what was delivered, paid and pending to each supplier.
  Future<List<Supplier>> _withTotals(List<SupplierRow> rows) async {
    if (rows.isEmpty) return [];
    final ids = rows.map((r) => r.id).toList();

    final value = (db.deliveries.quantity * db.deliveries.buyPrice).sum();
    final delivered = {
      for (final row in await (db.selectOnly(db.deliveries)
            ..addColumns([db.deliveries.supplierId, value])
            ..where(db.deliveries.supplierId.isIn(ids) &
                db.deliveries.deleted.equals(false))
            ..groupBy([db.deliveries.supplierId]))
          .get())
        row.read(db.deliveries.supplierId)!: row.read(value) ?? 0,
    };

    final amount = db.supplierPayments.amount.sum();
    final paid = <String, int>{};
    final pending = <String, int>{};
    for (final row in await (db.selectOnly(db.supplierPayments)
          ..addColumns([
            db.supplierPayments.supplierId,
            db.supplierPayments.status,
            amount
          ])
          ..where(db.supplierPayments.supplierId.isIn(ids) &
              db.supplierPayments.deleted.equals(false))
          ..groupBy(
              [db.supplierPayments.supplierId, db.supplierPayments.status]))
        .get()) {
      final id = row.read(db.supplierPayments.supplierId)!;
      final sum = row.read(amount) ?? 0;
      switch (row.read(db.supplierPayments.status)) {
        case 'validated':
          paid[id] = sum;
        case 'pending':
          pending[id] = sum;
      }
    }

    return [
      for (final row in rows)
        Supplier(
          id: row.id,
          name: row.name,
          phone: row.phone,
          note: row.note,
          active: row.active,
          delivered: delivered[row.id] ?? 0,
          paid: paid[row.id] ?? 0,
          pending: pending[row.id] ?? 0,
        ),
    ];
  }

  SupplierPayment _toPayment(SupplierPaymentRow row, String supplierName,
          Map<String, String> names) =>
      SupplierPayment(
        id: row.id,
        supplierId: row.supplierId,
        supplierName: supplierName,
        amount: row.amount,
        note: row.note,
        status: PaymentStatus.values.byName(row.status),
        createdAt: row.createdAt,
        paidByName: names[row.userId],
        validatedByName: names[row.validatedBy],
        validatedAt: row.validatedAt,
      );
}
