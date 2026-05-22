class TrackingData {
  final String vehicleNumber;
  final double latitude;
  final double longitude;
  final double speed;
  final String direction;
  final double course;
  final DateTime timestamp;

  const TrackingData({
    required this.vehicleNumber,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.direction,
    required this.course,
    required this.timestamp,
  });

  factory TrackingData.fromJson(Map<String, dynamic> json) {
    return TrackingData(
      vehicleNumber: json['vehicleNumber'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      speed: (json['speed'] as num).toDouble(),
      direction: json['direction'] as String,
      course: (json['course'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
