import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Keeps the owner's phone answering while the app is in the background:
/// an Android "foreground service" with a permanent "Hub actif"
/// notification, and the Wi-Fi kept awake. Tests use a fake one.
abstract class HubKeepAlive {
  Future<void> start({required String title, required String text});
  Future<void> stop();
}

class ForegroundHubKeepAlive implements HubKeepAlive {
  bool _initialized = false;

  void _init(String channelName) {
    if (_initialized) return;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'shop_hub',
        channelName: channelName,
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
    _initialized = true;
  }

  @override
  Future<void> start({required String title, required String text}) async {
    try {
      _init(title);
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.updateService(
            notificationTitle: title, notificationText: text);
        return;
      }
      await FlutterForegroundTask.startService(
        serviceTypes: [ForegroundServiceTypes.specialUse],
        notificationTitle: title,
        notificationText: text,
      );
    } catch (e) {
      // The hub still works while the app is open.
      debugPrint('Hub keep-alive unavailable: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await FlutterForegroundTask.stopService();
    } catch (e) {
      debugPrint('Hub keep-alive stop: $e');
    }
  }
}
