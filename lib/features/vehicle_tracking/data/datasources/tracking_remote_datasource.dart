import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/tracking_data.dart';
import 'tracking_datasource.dart';

class TrackingRemoteDatasource implements TrackingDatasource {
  final Dio _dio;

  TrackingRemoteDatasource() : _dio = DioClient.instance;

  @override
  Future<TrackingData> getTracking(String vehicleId) async {
    final response = await _dio.get('/api/vehicles/$vehicleId/tracking');
    return TrackingData.fromJson(response.data as Map<String, dynamic>);
  }
}
