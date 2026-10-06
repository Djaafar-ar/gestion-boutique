import 'dart:async';
import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/database/app_database.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/session/session_cubit.dart';
import '../../../core/settings/settings_store.dart';
import '../data/alert_repository.dart';
import '../data/alert_rules.dart';
import '../data/phone_notifier.dart';
import '../domain/alert.dart';
import '../domain/alert_text.dart';

class AlertsState extends Equatable {
  /// Alerts of the logged-in person, unread first.
  final List<Alert> alerts;

  const AlertsState({this.alerts = const []});

  /// The number on the Alertes tab.
  int get unread => alerts.where((a) => !a.read).length;

  @override
  List<Object?> get props => [alerts];
}

/// Watches the shop data, keeps the alerts up to date, rings the phone
/// for new ones and plans expiry reminders.
class AlertsCubit extends Cubit<AlertsState> {
  final AppDatabase db;
  final AlertRepository repository;
  final PhoneNotifier notifier;
  final SettingsStore settings;
  final SessionCubit session;

  /// The language of phone notifications.
  final Locale Function() locale;

  /// More than this many new alerts at once give one summary notification.
  static const maxSeparateNotifications = 3;

  /// Expiry reminders planned ahead (Android limits alarms per app).
  static const maxReminders = 40;

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Timer? _debounce;
  Timer? _timer;
  bool _checking = false;
  bool _checkAgain = false;
  String? _plannedReminders;

  AlertsCubit({
    required this.db,
    required this.repository,
    required this.notifier,
    required this.settings,
    required this.session,
    required this.locale,
  }) : super(const AlertsState());

  /// Starts watching: after every change to the shop data (a little
  /// later, so a sale with 10 lines gives one check), every 15 minutes
  /// (expiry dates change with the day) and after each login.
  void start() {
    _subscriptions
      ..add(session.stream.listen((_) => check()))
      ..add(db
          .tableUpdates(TableUpdateQuery.onAllTables([
        db.products,
        db.deliveries,
        db.stockAllocations,
        db.sales,
        db.returns,
        db.losses,
        db.supplierPayments,
        db.customers,
        db.customerPayments,
        db.failedLogins,
        db.shops,
        db.users,
      ]))
          .listen((_) {
        _debounce?.cancel();
        _debounce = Timer(const Duration(seconds: 1), check);
      }));
    _timer = Timer.periodic(const Duration(minutes: 15), (_) => check());
    check();
  }

  /// Looks for new or solved alerts, rings for the new ones and reloads
  /// the list.
  Future<void> check({DateTime? now}) async {
    if (_checking) {
      _checkAgain = true;
      return;
    }
    _checking = true;
    try {
      final raised = await repository.refresh(now: now);
      await _notify(raised);
      await _planReminders(now ?? DateTime.now());
      await reload();
    } finally {
      _checking = false;
    }
    if (_checkAgain) {
      _checkAgain = false;
      await check(now: now);
    }
  }

  /// Reads the list again for whoever is logged in.
  Future<void> reload() async {
    final user = session.state.user;
    final alerts = user == null
        ? const <Alert>[]
        : await repository.getAlerts(userId: user.id, isOwner: user.isOwner);
    if (!isClosed) emit(AlertsState(alerts: alerts));
  }

  Future<void> markRead(String alertId) async {
    final userId = session.userId;
    if (userId == null) return;
    await repository.markRead(alertId, userId);
    await notifier.cancel(alertId);
    await reload();
  }

  Future<void> markAllRead() async {
    final user = session.state.user;
    if (user == null) return;
    await repository.markAllRead(userId: user.id, isOwner: user.isOwner);
    for (final alert in state.alerts.where((a) => !a.read)) {
      await notifier.cancel(alert.id);
    }
    await reload();
  }

  /// Whether this phone rings for [type]: switched on in the settings, and
  /// owner alerts only when the owner is the one using the phone.
  bool rings(AlertType type) =>
      settings.get(type.settingsKey) != 'false' &&
      (!type.ownerOnly || session.state.isOwner);

  Future<void> setRings(AlertType type, bool on) async {
    await settings.set(type.settingsKey, on ? null : 'false');
    _plannedReminders = null;
    await check();
  }

  Future<void> _notify(List<AlertDraft> raised) async {
    final ringing = raised.where((a) => rings(a.type)).toList();
    if (ringing.isEmpty) return;
    final l10n = lookupAppLocalizations(locale());
    try {
      if (ringing.length > maxSeparateNotifications) {
        await notifier.show(
            key: 'summary',
            title: l10n.alertsSummaryTitle(ringing.length),
            body: l10n.alertsSummaryBody,
            payload: '|/alerts',
            channelName: l10n.notificationChannel);
        return;
      }
      for (final alert in ringing) {
        final text = describeAlert(l10n, alert.type, alert.data);
        await notifier.show(
            key: alert.id,
            title: text.title,
            body: text.body,
            payload: '${alert.id}|${text.route}',
            channelName: l10n.notificationChannel);
      }
    } catch (_) {
      // A phone that refuses notifications still shows the Alertes tab.
    }
  }

  /// Plans a 9:00 reminder for the day a batch starts expiring soon and
  /// the day it is expired, so the phone rings even if the app is closed.
  Future<void> _planReminders(DateTime now) async {
    final l10n = lookupAppLocalizations(locale());
    final reminders = <Reminder>[];
    for (final batch in await upcomingExpiries(db)) {
      final expiry = batch.expiry;
      final productRoute = '/stock/product/${batch.productId}';
      final data = {
        'product': batch.productName,
        'productId': batch.productId,
        'remaining': batch.remaining,
        'date': expiry.toIso8601String(),
      };
      final soon =
          DateTime(expiry.year, expiry.month, expiry.day - batch.warnDays, 9);
      if (soon.isAfter(now) && rings(AlertType.expiringSoon)) {
        final text = describeAlert(l10n, AlertType.expiringSoon, data);
        reminders.add(Reminder(
            key: 'soon:${batch.deliveryId}',
            at: soon,
            title: text.title,
            body: text.body,
            payload: '|$productRoute'));
      }
      final expired = DateTime(expiry.year, expiry.month, expiry.day + 1, 9);
      if (expired.isAfter(now) && rings(AlertType.expired)) {
        final text = describeAlert(l10n, AlertType.expired, data);
        reminders.add(Reminder(
            key: 'expired:${batch.deliveryId}',
            at: expired,
            title: text.title,
            body: text.body,
            payload: '|$productRoute'));
      }
    }
    reminders.sort((a, b) => a.at.compareTo(b.at));
    final planned = reminders.take(maxReminders).toList();
    // Only plan again when something changed.
    final signature = planned
        .map((r) => '${r.key}@${r.at.toIso8601String()}:${r.body}')
        .join(';');
    if (signature == _plannedReminders) return;
    try {
      await notifier.schedule(planned, channelName: l10n.notificationChannel);
      _plannedReminders = signature;
    } catch (_) {
      // Reminders are a bonus: the Alertes tab still works without them.
    }
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _debounce?.cancel();
    _timer?.cancel();
    return super.close();
  }
}
