import '../datasources/tracking_datasource.dart';
import '../models/tracking_data.dart';

abstract class TrackingRepository {
  Future<TrackingData> getTracking(String vehicleId);
}

class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingDatasource _datasource;

  TrackingRepositoryImpl(this._datasource);

  @override
  Future<TrackingData> getTracking(String vehicleId) {
    return _datasource.getTracking(vehicleId);
  }
}
