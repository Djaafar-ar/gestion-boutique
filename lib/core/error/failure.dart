import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// The thing asked for does not exist (for example an unknown barcode).
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// The person is not allowed to do this (for example a worker trying to
/// reset someone else's PIN).
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// A PIN or recovery code was wrong.
class WrongSecretFailure extends Failure {
  const WrongSecretFailure(super.message);
}
