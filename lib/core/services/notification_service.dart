import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'tracking_storage_service.dart';

const _channelId = 'vehicle_tracking_channel';
const _channelName = 'Vehicle Tracking';
const _notifId = 1;

// Must be a top-level function — called in a separate Dart isolate when the
// user taps a notification action while the app is NOT running.
@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse response) {
  if (response.actionId != 'stop_tracking') return;

  // App is not running. We can't reach the provider here, so we set a flag
  // in SharedPreferences. The next WorkManager task will check this flag and
  // cancel itself, breaking the background refresh loop.
  WidgetsFlutterBinding.ensureInitialized();
  TrackingStorageService.setTrackingActive(false); // fire and forget — completes before isolate dies
}

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  // Set this to get notified when the user taps "Stop Tracking" in the
  // notification while the app IS in the foreground or recently backgrounded.
  static void Function()? onStopRequested;

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS: We request permission lazily when tracking starts, not at launch.
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onForegroundResponse,
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationResponse,
    );

    await _ensureChannelExists();
  }

  static Future<void> _ensureChannelExists() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Ongoing vehicle location tracking updates',
        // Low importance so it doesn't make sounds on each 10-second update.
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
      ),
    );
  }

  // Call this when the user starts tracking so the OS permission dialog appears
  // at a natural moment, not at cold launch.
  static Future<void> requestPermissions() async {
    // Android 13+ requires POST_NOTIFICATIONS at runtime.
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    // iOS: the system notification permission dialog is shown automatically
    // the first time the app calls show(). Set requestAlertPermission: true
    // in DarwinInitializationSettings (in init()) to request it upfront instead.
  }

  // Called when the user interacts with the notification while the app is alive.
  static void _onForegroundResponse(NotificationResponse response) {
    if (response.actionId == 'stop_tracking') {
      // Signal the provider to stop everything cleanly.
      TrackingStorageService.setTrackingActive(false);
      onStopRequested?.call();
    }
  }

  static Future<void> showTrackingNotification({
    required String vehicleNumber,
    required double speed,
    required double latitude,
    required double longitude,
    required DateTime updatedAt,
  }) async {
    final body =
        '${speed.toStringAsFixed(1)} km/h  ·  ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

    const stopAction = AndroidNotificationAction(
      'stop_tracking',
      'Stop Tracking',
      // Dismiss the notification immediately when the action is tapped.
      cancelNotification: true,
    );

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Ongoing vehicle location tracking updates',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,       // User cannot swipe it away — tracking is running.
      autoCancel: false,
      showWhen: false,
      subText: 'Updated ${_hms(updatedAt)}',
      actions: const [stopAction],
    );

    // iOS background tracking note:
    // presentAlert: false keeps the notification silent when the app is in
    // the foreground — iOS handles the persistent banner differently from Android.
    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    await _plugin.show(
      _notifId,
      'Tracking: $vehicleNumber',
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  static Future<void> cancelTrackingNotification() async {
    await _plugin.cancel(_notifId);
  }

  static String _hms(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}:'
      '${dt.second.toString().padLeft(2, '0')}';
}
