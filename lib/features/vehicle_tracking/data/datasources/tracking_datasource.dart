import '../models/tracking_data.dart';

abstract class TrackingDatasource {
  Future<TrackingData> getTracking(String vehicleId);
}
