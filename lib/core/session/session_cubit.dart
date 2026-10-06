import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/users/domain/entities/app_user.dart';

class SessionState extends Equatable {
  /// False until the owner account is created (first launch).
  final bool hasOwner;

  /// Who is using the app right now, or null on the login screen.
  final AppUser? user;

  const SessionState({required this.hasOwner, this.user});

  bool get isLoggedIn => user != null;
  bool get isOwner => user?.isOwner ?? false;

  @override
  List<Object?> get props => [hasOwner, user];
}

/// Remembers who is logged in on this phone. Every sale, product change
/// and (later) stock entry is signed with [userId].
class SessionCubit extends Cubit<SessionState> {
  SessionCubit({required bool hasOwner})
      : super(SessionState(hasOwner: hasOwner));

  String? get userId => state.user?.id;

  void ownerCreated(AppUser owner) =>
      emit(SessionState(hasOwner: true, user: owner));

  void login(AppUser user) =>
      emit(SessionState(hasOwner: state.hasOwner, user: user));

  void logout() => emit(SessionState(hasOwner: state.hasOwner));

  /// Keeps the session up to date after the logged-in user edits
  /// their own name or phone.
  void userUpdated(AppUser user) {
    if (user.id == state.user?.id) login(user);
  }
}
