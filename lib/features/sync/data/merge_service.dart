import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/database/app_database.dart';
import '../../../core/error/failure.dart';
import '../../../core/session/session_cubit.dart';

/// Owner only: joins two records that are the same thing (often made on
/// two phones before they synced). Everything of the one dropped moves to
/// the one kept, then the dropped one is archived. Nothing is deleted.
class MergeService {
  final AppDatabase db;
  final SessionCubit session;

  MergeService(this.db, this.session);

  /// Sales, stock, losses and returns of [dropId] go to [keepId].
  Future<Either<Failure, void>> mergeProducts(
          {required String keepId, required String dropId}) =>
      _merge(keepId, dropId, moves: [
        ('sale_items', 'product_id'),
        ('deliveries', 'product_id'),
        ('stock_allocations', 'product_id'),
        ('losses', 'product_id'),
        ('return_items', 'product_id'),
        ('change_logs', 'entity_id'),
      ], archive: (
        'products',
        'archived = 1'
      ));

  /// Credit sales and payments (so the debt) of [dropId] go to [keepId].
  Future<Either<Failure, void>> mergeCustomers(
          {required String keepId, required String dropId}) =>
      _merge(keepId, dropId, moves: [
        ('sales', 'customer_id'),
        ('customer_payments', 'customer_id'),
      ], archive: (
        'customers',
        'active = 0'
      ));

  Future<Either<Failure, void>> _merge(String keepId, String dropId,
      {required List<(String, String)> moves,
      required (String, String) archive}) async {
    if (!session.state.isOwner) {
      return const Left(PermissionFailure('Only the owner'));
    }
    if (keepId == dropId) return const Left(CacheFailure('Same record'));
    try {
      // A new "changed" time, so the move reaches the other phones.
      final now = db.typeMapping.mapToSqlVariable(DateTime.now());
      final tables = {
        for (final (name, _) in [...moves, archive])
          db.allTables.firstWhere((t) => t.actualTableName == name),
      };
      await db.transaction(() async {
        for (final (table, column) in moves) {
          await db.customUpdate(
            'UPDATE $table SET $column = ?, updated_at = ? WHERE $column = ?',
            variables: [
              Variable<String>(keepId),
              Variable(now),
              Variable<String>(dropId)
            ],
            updates: tables,
          );
        }
        final (table, set) = archive;
        await db.customUpdate(
          'UPDATE $table SET $set, updated_at = ? WHERE id = ?',
          variables: [Variable(now), Variable<String>(dropId)],
          updates: tables,
        );
      });
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
