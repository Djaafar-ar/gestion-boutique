import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/customer.dart';

abstract class CustomerRepository {
  /// Customers with their debt, by name. Archived ones only when asked.
  Future<Either<Failure, List<Customer>>> getCustomers(
      {bool includeArchived = false});

  Future<Either<Failure, Customer>> getCustomer(String id);

  /// Creates ([id] null) or updates a customer. Only the owner sets the
  /// [creditLimit]: for a worker it is ignored.
  Future<Either<Failure, Customer>> saveCustomer({
    String? id,
    required String name,
    String phone = '',
    String? note,
    int? creditLimit,
  });

  /// Owner only: hides (or shows again) a customer. Their history stays.
  Future<Either<Failure, void>> setArchived(String id, bool archived);

  /// Credit sales, refunds and payments, newest first, with who did them.
  Future<Either<Failure, List<CustomerEntry>>> getHistory(String id);

  /// The customer pays back [amount] centimes, received by the logged-in
  /// person. Never more than the debt ([OverpaymentFailure]).
  Future<Either<Failure, void>> recordPayment({
    required String customerId,
    required int amount,
    String? note,
  });

  /// Everything customers owe the shop (advances not counted).
  Future<Either<Failure, int>> totalOwed();
}
