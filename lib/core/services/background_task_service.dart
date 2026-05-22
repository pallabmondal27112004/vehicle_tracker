import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../constants/app_constants.dart';
import '../network/dio_client.dart';
import 'notification_service.dart';
import 'tracking_storage_service.dart';

// Must be a top-level function — WorkManager runs this in a separate Dart isolate.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == AppConstants.bgTaskName) {
      await _runBackgroundPoll();
    }
    return true;
  });
}

Future<void> _runBackgroundPoll() async {
  WidgetsFlutterBinding.ensureInitialized();

  // If the user stopped tracking via the notification action, the flag was
  // written to SharedPreferences. We clean up and stop here.
  final isActive = await TrackingStorageService.isTrackingActive();
  if (!isActive) {
    await Workmanager().cancelByUniqueName(AppConstants.bgTaskUniqueName);
    return;
  }

  // Re-init notification plugin in this isolate before using it.
  await NotificationService.init();

  final stored = await TrackingStorageService.loadTrackingData();
  if (stored == null) return; // Nothing saved yet — skip.

  if (!AppConstants.useMockApi) {
    // Real API: fetch fresh coordinates and update the notification.
    try {
      final response = await DioClient.instance.get(
        '/api/vehicles/${stored.vehicleId}/tracking',
      );
      final json = response.data as Map<String, dynamic>;

      await NotificationService.showTrackingNotification(
        vehicleNumber: json['vehicleNumber'] as String,
        speed: (json['speed'] as num).toDouble(),
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        updatedAt: DateTime.now(),
      );
      return;
    } catch (e) {
      debugPrint('[BG] API fetch failed: $e — falling back to last known data');
    }
  }

  // Mock mode or API failure: refresh the notification timestamp so the user
  // can see the background task is still alive, but coordinates stay the same.
  await NotificationService.showTrackingNotification(
    vehicleNumber: stored.vehicleNumber,
    speed: stored.speed,
    latitude: stored.latitude,
    longitude: stored.longitude,
    updatedAt: DateTime.now(),
  );
}

class BackgroundTaskService {
  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  static Future<void> startPeriodicTracking() async {
    // Android: OS enforces a minimum interval of ~15 minutes regardless of
    // what we request. The Dart timer in TrackingProvider covers the 10-second
    // foreground updates; WorkManager is the safety net for deep background.
    //
    // iOS: WorkManager uses BGAppRefreshTask. Apple decides when to actually
    // run it (typically no more frequently than ~15 minutes, and only when
    // conditions are favorable). For reliable 10-second iOS tracking you would
    // need a server-push (silent APNs) or a CLLocationManager background mode.
    await Workmanager().registerPeriodicTask(
      AppConstants.bgTaskUniqueName,
      AppConstants.bgTaskName,
      frequency: const Duration(minutes: 15),
      // replace replaces any existing task with the same uniqueName, preventing
      // duplicates if startPeriodicTracking() is called more than once.
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static Future<void> stopPeriodicTracking() async {
    await Workmanager().cancelByUniqueName(AppConstants.bgTaskUniqueName);
  }
}
