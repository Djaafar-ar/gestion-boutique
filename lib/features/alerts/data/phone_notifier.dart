import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/settings/settings_store.dart';

/// A notification planned for later (expiry reminders).
class Reminder {
  final String key;
  final DateTime at;
  final String title;
  final String body;
  final String payload;

  const Reminder(
      {required this.key,
      required this.at,
      required this.title,
      required this.body,
      required this.payload});
}

/// Shows notifications on the phone. Tests use a fake one.
abstract class PhoneNotifier {
  Future<void> init();

  /// Asks Android 13+ for the right to show notifications.
  Future<bool> requestPermission();
  Future<bool> isAllowed();
  Future<void> openSettings();

  /// Shows (or replaces) the notification named [key].
  Future<void> show(
      {required String key,
      required String title,
      required String body,
      required String payload,
      required String channelName});
  Future<void> cancel(String key);

  /// Replaces every planned reminder with [reminders].
  Future<void> schedule(List<Reminder> reminders,
      {required String channelName});

  /// Payloads of tapped notifications.
  Stream<String> get taps;

  /// The last tapped payload not dealt with yet (for example the one that
  /// opened the app), and forgets it.
  String? takePendingTap();
}

/// Turns a key like 'lowStock:<id>' into a notification number that stays
/// the same, so a new notification replaces the old one.
int notificationIdOf(String key) {
  var hash = 0x811c9dc5;
  for (final byte in utf8.encode(key)) {
    hash = ((hash ^ byte) * 0x01000193) & 0x7fffffff;
  }
  return hash;
}

class LocalPhoneNotifier implements PhoneNotifier {
  final SettingsStore settings;
  final _plugin = FlutterLocalNotificationsPlugin();
  final _taps = StreamController<String>.broadcast();
  String? _pending;

  static const _channelId = 'shop_alerts';
  static const _scheduledKey = 'scheduled_reminders';

  LocalPhoneNotifier(this.settings);

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<void> init() async {
    tz_data.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_stat_alert')),
      onDidReceiveNotificationResponse: (response) => _tapped(response.payload),
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      _pending = launch?.notificationResponse?.payload;
    }
  }

  void _tapped(String? payload) {
    if (payload == null) return;
    _pending = payload;
    _taps.add(payload);
  }

  @override
  Future<bool> requestPermission() async =>
      await _android?.requestNotificationsPermission() ?? false;

  @override
  Future<bool> isAllowed() async =>
      await _android?.areNotificationsEnabled() ?? false;

  @override
  Future<void> openSettings() async {
    try {
      await _plugin.openAppNotificationSettings();
    } catch (e) {
      debugPrint('Cannot open notification settings: $e');
    }
  }

  NotificationDetails _details(String channelName) => NotificationDetails(
        android: AndroidNotificationDetails(_channelId, channelName,
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: const BigTextStyleInformation('')),
      );

  @override
  Future<void> show(
      {required String key,
      required String title,
      required String body,
      required String payload,
      required String channelName}) async {
    await _plugin.show(
      id: notificationIdOf(key),
      title: title,
      body: body,
      notificationDetails: _details(channelName),
      payload: payload,
    );
  }

  @override
  Future<void> cancel(String key) => _plugin.cancel(id: notificationIdOf(key));

  @override
  Future<void> schedule(List<Reminder> reminders,
      {required String channelName}) async {
    // Forget the reminders planned last time, then plan the new ones.
    final old = (settings.get(_scheduledKey) ?? '')
        .split(',')
        .where((s) => s.isNotEmpty)
        .map(int.parse);
    for (final id in old) {
      await _plugin.cancel(id: id);
    }
    final ids = <int>[];
    for (final reminder in reminders) {
      final id = notificationIdOf('reminder:${reminder.key}');
      try {
        await _plugin.zonedSchedule(
          id: id,
          // The same moment, whatever the time zone name is.
          scheduledDate: tz.TZDateTime.from(reminder.at, tz.UTC),
          notificationDetails: _details(channelName),
          // Inexact is enough for a 9:00 reminder and needs no extra
          // permission.
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          title: reminder.title,
          body: reminder.body,
          payload: reminder.payload,
        );
        ids.add(id);
      } catch (e) {
        debugPrint('Cannot plan reminder ${reminder.key}: $e');
      }
    }
    await settings.set(_scheduledKey, ids.join(','));
  }

  @override
  Stream<String> get taps => _taps.stream;

  @override
  String? takePendingTap() {
    final payload = _pending;
    _pending = null;
    return payload;
  }
}
