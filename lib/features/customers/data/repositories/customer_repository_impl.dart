import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/user_names.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/settings/settings_store.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../customer_debts.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final AppDatabase db;
  final SettingsStore settings;
  final SessionCubit session;

  CustomerRepositoryImpl(this.db, this.settings, this.session);

  @override
  Future<Either<Failure, List<Customer>>> getCustomers(
      {bool includeArchived = false}) async {
    try {
      final query = db.select(db.customers)
        ..where((c) => c.deleted.equals(false))
        ..orderBy([(c) => OrderingTerm.asc(c.name.collate(Collate.noCase))]);
      if (!includeArchived) query.where((c) => c.active.equals(true));
      final rows = await query.get();
      final debts = await customerDebts(db);
      return Right([for (final row in rows) _toCustomer(row, debts[row.id])]);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Customer>> getCustomer(String id) async {
    try {
      final row = await (db.select(db.customers)..where((c) => c.id.equals(id)))
          .getSingleOrNull();
      if (row == null) return Left(NotFoundFailure(id));
      return Right(_toCustomer(row, await customerDebt(db, id)));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Customer>> saveCustomer({
    String? id,
    required String name,
    String phone = '',
    String? note,
    int? creditLimit,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return const Left(CacheFailure('Name required'));
    if (creditLimit != null && creditLimit < 0) {
      return const Left(CacheFailure('Invalid credit limit'));
    }
    try {
      final now = DateTime.now();
      final owner = session.state.isOwner;
      final cleanNote = note?.trim().isEmpty ?? true ? null : note!.trim();
      if (id == null) {
        final newId = const Uuid().v4();
        await db.into(db.customers).insert(CustomersCompanion.insert(
              id: newId,
              createdAt: now,
              updatedAt: now,
              deviceId: settings.deviceId,
              userId: Value(session.userId),
              name: trimmed,
              phone: Value(phone.trim()),
              note: Value(cleanNote),
              // Only the owner decides how much credit someone gets.
              creditLimit: Value(owner ? creditLimit : null),
            ));
        return await getCustomer(newId);
      }
      await (db.update(db.customers)..where((c) => c.id.equals(id))).write(
        CustomersCompanion(
          updatedAt: Value(now),
          name: Value(trimmed),
          phone: Value(phone.trim()),
          note: Value(cleanNote),
          creditLimit: owner ? Value(creditLimit) : const Value.absent(),
        ),
      );
      return await getCustomer(id);
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
      await (db.update(db.customers)..where((c) => c.id.equals(id))).write(
          CustomersCompanion(
              active: Value(!archived), updatedAt: Value(DateTime.now())));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CustomerEntry>>> getHistory(String id) async {
    try {
      final sales = await (db.select(db.sales)
            ..where((s) => s.customerId.equals(id) & s.deleted.equals(false)))
          .get();
      final saleIds = sales.map((s) => s.id).toList();
      final numbers = {for (final s in sales) s.id: s.number};
      final refunds = saleIds.isEmpty
          ? <ReturnRow>[]
          : await (db.select(db.returns)
                ..where((r) =>
                    r.saleId.isIn(saleIds) &
                    r.refundMode.equals('credit') &
                    r.deleted.equals(false)))
              .get();
      final payments = await (db.select(db.customerPayments)
            ..where((p) => p.customerId.equals(id) & p.deleted.equals(false)))
          .get();
      final names = await userNames(db, [
        ...sales.map((s) => s.userId),
        ...refunds.map((r) => r.userId),
        ...payments.map((p) => p.userId),
      ]);

      final entries = [
        for (final s in sales)
          CustomerEntry(
            kind: CustomerEntryKind.sale,
            at: s.createdAt,
            amount: s.total - s.paidNow,
            byName: names[s.userId],
            saleId: s.id,
            saleNumber: s.number,
            saleTotal: s.total,
            paidNow: s.paidNow,
          ),
        for (final r in refunds)
          CustomerEntry(
            kind: CustomerEntryKind.refund,
            at: r.createdAt,
            amount: -r.total,
            byName: names[r.userId],
            saleId: r.saleId,
            saleNumber: numbers[r.saleId],
            note: r.reason,
          ),
        for (final p in payments)
          CustomerEntry(
            kind: CustomerEntryKind.payment,
            at: p.createdAt,
            amount: -p.amount,
            byName: names[p.userId],
            note: p.note,
          ),
      ]..sort((a, b) => b.at.compareTo(a.at));
      return Right(entries);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> recordPayment({
    required String customerId,
    required int amount,
    String? note,
  }) async {
    if (amount <= 0) return const Left(CacheFailure('Amount must be > 0'));
    try {
      return await db.transaction(() async {
        final debt = await customerDebt(db, customerId);
        if (amount > debt) return Left(OverpaymentFailure(debt));
        final now = DateTime.now();
        await db.into(db.customerPayments).insert(
              CustomerPaymentsCompanion.insert(
                id: const Uuid().v4(),
                createdAt: now,
                updatedAt: now,
                deviceId: settings.deviceId,
                userId: Value(session.userId),
                customerId: customerId,
                amount: amount,
                note: Value(note?.trim().isEmpty ?? true ? null : note!.trim()),
              ),
            );
        return const Right(null);
      });
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> totalOwed() async {
    try {
      final active = await (db.select(db.customers)
            ..where((c) => c.deleted.equals(false)))
          .map((c) => c.id)
          .get();
      final debts = await customerDebts(db, ids: active);
      return Right(
          debts.values.where((d) => d > 0).fold<int>(0, (a, b) => a + b));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Customer _toCustomer(CustomerRow row, int? debt) => Customer(
        id: row.id,
        name: row.name,
        phone: row.phone,
        note: row.note,
        creditLimit: row.creditLimit,
        active: row.active,
        debt: debt ?? 0,
      );
}
