import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/supplier.dart';

abstract class SupplierRepository {
  /// Suppliers with what the shop owes them, by name.
  Future<Either<Failure, List<Supplier>>> getSuppliers(
      {bool includeArchived = false});

  Future<Either<Failure, Supplier>> getSupplier(String id);

  /// Creates ([id] null) or updates a supplier.
  Future<Either<Failure, Supplier>> saveSupplier({
    String? id,
    required String name,
    String phone = '',
    String? note,
  });

  /// Owner only: hides (or shows again) a supplier. Their history stays.
  Future<Either<Failure, void>> setArchived(String id, bool archived);

  /// Deliveries from this supplier, newest first.
  Future<Either<Failure, List<SupplierDelivery>>> getDeliveries(
      String supplierId);

  /// Payments, newest first: of one supplier and/or with one status.
  Future<Either<Failure, List<SupplierPayment>>> getPayments(
      {String? supplierId, PaymentStatus? status});

  /// Records money given to a supplier by the logged-in person: validated
  /// at once for the owner, pending (waiting for the owner) for a worker.
  Future<Either<Failure, SupplierPayment>> recordPayment({
    required String supplierId,
    required int amount,
    String? note,
  });

  /// Owner only, and only for pending payments.
  Future<Either<Failure, void>> validatePayment(String paymentId);
  Future<Either<Failure, void>> rejectPayment(String paymentId);

  /// How many payments wait for the owner.
  Future<int> pendingCount();
}
