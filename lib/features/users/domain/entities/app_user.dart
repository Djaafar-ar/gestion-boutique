import 'package:equatable/equatable.dart';

enum UserRole { owner, worker }

/// A person who uses the app: the owner or a worker.
class AppUser extends Equatable {
  final String id;
  final String name;
  final String phone;
  final UserRole role;
  final bool active;

  const AppUser({
    required this.id,
    required this.name,
    this.phone = '',
    required this.role,
    this.active = true,
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
      );

  @override
  List<Object?> get props => [id, name, phone, role, active];
}
