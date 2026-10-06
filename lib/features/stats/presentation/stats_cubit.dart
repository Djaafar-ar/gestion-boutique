import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/session/session_cubit.dart';
import '../../../core/utils/date_format.dart';
import '../../users/domain/entities/app_user.dart';
import '../../users/domain/repositories/user_repository.dart';
import '../data/stats_repository.dart';
import '../domain/stats.dart';

enum StatsPeriod { today, week, month, custom }

class StatsState extends Equatable {
  final StatsPeriod period;
  final DateTime from;

  /// Excluded: the day after the last day shown.
  final DateTime to;

  /// Whose figures (null = everyone). Workers only ever see their own.
  final String? userId;
  final List<AppUser> users;
  final Stats? stats;
  final bool loading;

  const StatsState({
    required this.period,
    required this.from,
    required this.to,
    this.userId,
    this.users = const [],
    this.stats,
    this.loading = true,
  });

  StatsState copyWith({
    StatsPeriod? period,
    DateTime? from,
    DateTime? to,
    String? userId,
    bool everyone = false,
    List<AppUser>? users,
    Stats? stats,
    bool? loading,
  }) =>
      StatsState(
        period: period ?? this.period,
        from: from ?? this.from,
        to: to ?? this.to,
        userId: everyone ? null : (userId ?? this.userId),
        users: users ?? this.users,
        stats: stats ?? this.stats,
        loading: loading ?? this.loading,
      );

  @override
  List<Object?> get props => [period, from, to, userId, users, stats, loading];
}

/// The Stats tab: which period and whose figures, and the figures.
class StatsCubit extends Cubit<StatsState> {
  final StatsRepository repository;
  final UserRepository users;
  final SessionCubit session;

  StatsCubit(
      {required this.repository,
      required this.users,
      required this.session,
      DateTime? now})
      : super(_initial(session, now ?? DateTime.now()));

  static StatsState _initial(SessionCubit session, DateTime now) {
    final (from, to) = rangeOf(StatsPeriod.today, now);
    return StatsState(
      period: StatsPeriod.today,
      from: from,
      to: to,
      // A worker is locked to their own figures.
      userId: session.state.isOwner ? null : session.userId,
    );
  }

  /// Today, this week (from Saturday) or this month.
  static (DateTime, DateTime) rangeOf(StatsPeriod period, DateTime now) {
    final today = startOfDay(now);
    return switch (period) {
      StatsPeriod.week => (
          startOfWeek(now),
          DateTime(today.year, today.month, today.day + 1)
        ),
      StatsPeriod.month => (
          startOfMonth(now),
          DateTime(today.year, today.month, today.day + 1)
        ),
      _ => (today, DateTime(today.year, today.month, today.day + 1)),
    };
  }

  Future<void> start() async {
    if (session.state.isOwner) {
      final all = (await users.getUsers()).getOrElse((_) => []);
      if (!isClosed) emit(state.copyWith(users: all));
    }
    await load();
  }

  Future<void> load() async {
    if (isClosed) return;
    emit(state.copyWith(loading: true));
    final stats = await repository.getStats(
        from: state.from, to: state.to, userId: state.userId);
    if (!isClosed) emit(state.copyWith(stats: stats, loading: false));
  }

  Future<void> setPeriod(StatsPeriod period, {DateTime? now}) async {
    final (from, to) = rangeOf(period, now ?? DateTime.now());
    emit(state.copyWith(period: period, from: from, to: to));
    await load();
  }

  /// [first] and [last] are days, both included.
  Future<void> setRange(DateTime first, DateTime last) async {
    emit(state.copyWith(
        period: StatsPeriod.custom,
        from: startOfDay(first),
        to: DateTime(last.year, last.month, last.day + 1)));
    await load();
  }

  /// Owner only: everyone (null) or one person.
  Future<void> setUser(String? userId) async {
    if (!session.state.isOwner) return;
    emit(userId == null
        ? state.copyWith(everyone: true)
        : state.copyWith(userId: userId));
    await load();
  }
}
