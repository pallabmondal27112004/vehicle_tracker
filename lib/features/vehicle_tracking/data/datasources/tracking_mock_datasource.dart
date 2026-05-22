import 'dart:math';
import '../models/tracking_data.dart';
import 'tracking_datasource.dart';

class TrackingMockDatasource implements TrackingDatasource {
  final _random = Random();

  late double _lat;
  late double _lon;
  late double _speed;
  late double _course;
  final String _vehicleNumber;

  TrackingMockDatasource({
    required double initialLat,
    required double initialLon,
    required double initialSpeed,
    required double initialCourse,
    required String vehicleNumber,
  })  : _lat = initialLat,
        _lon = initialLon,
        _speed = initialSpeed,
        _course = initialCourse,
        _vehicleNumber = vehicleNumber;

  @override
  Future<TrackingData> getTracking(String vehicleId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Nudge position along the current course to look like real movement.
    final rad = _course * pi / 180;
    _lat += cos(rad) * 0.0003;
    _lon += sin(rad) * 0.0003;

    // Add a bit of drift so the path isn't perfectly straight.
    _lat += (_random.nextDouble() - 0.5) * 0.0001;
    _lon += (_random.nextDouble() - 0.5) * 0.0001;

    _speed = (_speed + (_random.nextDouble() - 0.5) * 4).clamp(0, 120);
    _course = (_course + (_random.nextDouble() - 0.5) * 8) % 360;

    return TrackingData(
      vehicleNumber: _vehicleNumber,
      latitude: _lat,
      longitude: _lon,
      speed: _speed,
      direction: _courseToDirection(_course),
      course: _course,
      timestamp: DateTime.now(),
    );
  }

  String _courseToDirection(double course) {
    if (course < 22.5 || course >= 337.5) return 'North';
    if (course < 67.5) return 'NE';
    if (course < 112.5) return 'East';
    if (course < 157.5) return 'SE';
    if (course < 202.5) return 'South';
    if (course < 247.5) return 'SW';
    if (course < 292.5) return 'West';
    return 'NW';
  }
}
