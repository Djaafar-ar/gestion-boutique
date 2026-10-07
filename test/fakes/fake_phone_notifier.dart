import 'dart:async';

import 'package:billing_app/features/alerts/data/phone_notifier.dart';

/// Remembers the notifications instead of showing them.
class FakeNotifier implements PhoneNotifier {
  final shown = <({String key, String title, String body, String payload})>[];
  final cancelled = <String>[];
  final channels = <String>[];
  List<Reminder> scheduled = [];
  final _taps = StreamController<String>.broadcast();
  String? _pending;

  void tap(String payload) {
    _pending = payload;
    _taps.add(payload);
  }

  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<bool> isAllowed() async => true;
  @override
  Future<void> openSettings() async {}
  @override
  Future<void> show(
      {required String key,
      required String title,
      required String body,
      required String payload,
      required String channelName,
      String channelId = alertsChannelId,
      bool private = false}) async {
    shown.add((key: key, title: title, body: body, payload: payload));
    channels.add(channelId);
  }

  @override
  Future<void> cancel(String key) async => cancelled.add(key);
  @override
  Future<void> schedule(List<Reminder> reminders,
          {required String channelName}) async =>
      scheduled = reminders;
  @override
  Stream<String> get taps => _taps.stream;
  @override
  String? takePendingTap() {
    final payload = _pending;
    _pending = null;
    return payload;
  }
}
