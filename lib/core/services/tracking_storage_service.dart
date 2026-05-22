import 'package:shared_preferences/shared_preferences.dart';

// All keys share this prefix to avoid clashing with other packages.
const _kPrefix = 'vt_tracking_';

class TrackingStorageService {
  static Future<void> saveTrackingData({
    required String vehicleId,
    required String vehicleNumber,
    required double latitude,
    required double longitude,
    required double speed,
    required String direction,
    required double course,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString('${_kPrefix}vehicleId', vehicleId),
      prefs.setString('${_kPrefix}vehicleNumber', vehicleNumber),
      prefs.setDouble('${_kPrefix}latitude', latitude),
      prefs.setDouble('${_kPrefix}longitude', longitude),
      prefs.setDouble('${_kPrefix}speed', speed),
      prefs.setString('${_kPrefix}direction', direction),
      prefs.setDouble('${_kPrefix}course', course),
      prefs.setInt(
          '${_kPrefix}updatedAt', DateTime.now().millisecondsSinceEpoch),
    ]);
  }

  static Future<StoredTrackingData?> loadTrackingData() async {
    final prefs = await SharedPreferences.getInstance();
    final vehicleId = prefs.getString('${_kPrefix}vehicleId');
    if (vehicleId == null) return null;

    return StoredTrackingData(
      vehicleId: vehicleId,
      vehicleNumber: prefs.getString('${_kPrefix}vehicleNumber') ?? '',
      latitude: prefs.getDouble('${_kPrefix}latitude') ?? 0,
      longitude: prefs.getDouble('${_kPrefix}longitude') ?? 0,
      speed: prefs.getDouble('${_kPrefix}speed') ?? 0,
      direction: prefs.getString('${_kPrefix}direction') ?? '',
      course: prefs.getDouble('${_kPrefix}course') ?? 0,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
          prefs.getInt('${_kPrefix}updatedAt') ?? 0),
    );
  }

  // Flag checked by the WorkManager task before showing a notification.
  // Lets us signal a stop from the notification action without needing the provider.
  static Future<void> setTrackingActive(bool active) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_kPrefix}active', active);
  }

  static Future<bool> isTrackingActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${_kPrefix}active') ?? false;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys =
        prefs.getKeys().where((k) => k.startsWith(_kPrefix)).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}

class StoredTrackingData {
  final String vehicleId;
  final String vehicleNumber;
  final double latitude;
  final double longitude;
  final double speed;
  final String direction;
  final double course;
  final DateTime updatedAt;

  const StoredTrackingData({
    required this.vehicleId,
    required this.vehicleNumber,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.direction,
    required this.course,
    required this.updatedAt,
  });
}
