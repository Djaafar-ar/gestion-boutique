import 'package:equatable/equatable.dart';

enum UserRole { owner, worker }

/// A person who uses the app: the owner or a worker.
class AppUser extends Equatable {
  final String id;
  final String name;
  final String phone;
  final UserRole role;
  final bool active;

  /// How many digits the PIN has (4, or 6 for an owner who chose it).
  final int pinLength;

  /// Locked after too many wrong PINs.
  final bool lockedOut;

  const AppUser({
    required this.id,
    required this.name,
    this.phone = '',
    required this.role,
    this.active = true,
    this.pinLength = 4,
    this.lockedOut = false,
  });

  bool get isOwner => role == UserRole.owner;

  /// One or two letters for the round avatar: "Amine Kaci" -> "AK".
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final letters = parts
        .take(2)
        .map((p) => String.fromCharCode(p.runes.first).toUpperCase());
    return letters.isEmpty ? '?' : letters.join();
  }

  AppUser copyWith({String? name, String? phone, bool? active}) => AppUser(
        id: id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        role: role,
        active: active ?? this.active,
        pinLength: pinLength,
        lockedOut: lockedOut,
      );

  @override
  List<Object?> get props =>
      [id, name, phone, role, active, pinLength, lockedOut];
}

enum FailedLoginKind { pin, recovery }

/// A wrong PIN or recovery code typed for [accountName]'s account.
class FailedLogin extends Equatable {
  final String accountId;
  final String accountName;
  final FailedLoginKind kind;
  final DateTime at;

  const FailedLogin({
    required this.accountId,
    required this.accountName,
    required this.kind,
    required this.at,
  });

  @override
  List<Object?> get props => [accountId, accountName, kind, at];
}
