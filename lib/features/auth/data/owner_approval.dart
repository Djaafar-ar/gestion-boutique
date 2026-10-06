import '../../users/domain/repositories/user_repository.dart';

/// Checks a PIN against the owner's account. Gives the owner's id when it
/// is right, null otherwise. Used when the owner allows something on a
/// worker's screen (a return without a receipt).
///
/// Wrong PINs are counted by the screen first, through the login rules
/// (waits and lock), before this is called.
Future<String?> Function(String pin) ownerApprovalWith(UserRepository users) =>
    (pin) async {
      final all = (await users.getUsers()).getOrElse((_) => []);
      final owner = all.where((u) => u.isOwner).firstOrNull;
      if (owner == null || owner.lockedOut) return null;
      return (await users.checkPin(owner.id, pin))?.id;
    };
