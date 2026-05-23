import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/background_task_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/tracking_storage_service.dart';
import '../../data/models/tracking_data.dart';
import '../../data/repositories/tracking_repository.dart';

class TrackingProvider extends ChangeNotifier {
  final TrackingRepository _repository;
  final String vehicleId;

  TrackingData? _data;
  bool _isLoading = false;
  bool _isFetching = false;
  bool _isTrackingActive = false;
  bool _disposed = false;
  String? _error;

  final List<LatLng> _routePoints = [];
  GoogleMapController? _mapController;
  Timer? _timer;

  TrackingData? get data => _data;
  bool get isLoading => _isLoading;
  bool get isTrackingActive => _isTrackingActive;
  String? get error => _error;
  List<LatLng> get routePoints => List.unmodifiable(_routePoints);

  TrackingProvider({
    required TrackingRepository repository,
    required this.vehicleId,
  }) : _repository = repository {
    // Listen for the "Stop Tracking" notification action tap so we can clean
    // up properly while the app is in the foreground.
    NotificationService.onStopRequested = () => stopTracking();
    startTracking();
  }

  Future<void> startTracking() async {
    if (_isTrackingActive) return;
    _isTrackingActive = true;
    _safeNotify(); // update button icon immediately on tap

    _startPolling();
    NotificationService.requestPermissions();
    await TrackingStorageService.setTrackingActive(true);
    await BackgroundTaskService.startPeriodicTracking();
  }

  Future<void> stopTracking() async {
    if (!_isTrackingActive) return;
    _isTrackingActive = false;
    _timer?.cancel();
    _timer = null;
    _safeNotify(); // update button icon immediately on tap

    await TrackingStorageService.setTrackingActive(false);
    await BackgroundTaskService.stopPeriodicTracking();
    await NotificationService.cancelTrackingNotification();
    await TrackingStorageService.clear();
  }

  void _startPolling() {
    _timer?.cancel(); // guard: never run two timers at once
    _fetch();
    _timer = Timer.periodic(AppConstants.pollingInterval, (_) => _fetch());
  }

  Future<void> _fetch() async {
    if (_isFetching) return; // previous tick still in flight — skip
    _isFetching = true;

    if (_data == null) {
      _isLoading = true;
      _safeNotify();
    }

    try {
      final result = await _repository.getTracking(vehicleId);
      _data = result;
      _error = null;

      final point = LatLng(result.latitude, result.longitude);
      _routePoints.add(point);
      _animateCameraTo(point);

      // Only write the notification/storage if tracking wasn't stopped while
      // the fetch was in flight.
      if (_isTrackingActive) {
        await _syncNotificationAndStorage(result);
      }
    } catch (e) {
      if (_data == null) {
        _error = 'Could not load tracking data.\nPlease check your connection.';
      }
      // If we already have data, silently skip — the next tick will retry.
    } finally {
      _isLoading = false;
      _isFetching = false;
      _safeNotify();
    }
  }

  Future<void> _syncNotificationAndStorage(TrackingData d) async {
    await Future.wait([
      NotificationService.showTrackingNotification(
        vehicleNumber: d.vehicleNumber,
        speed: d.speed,
        latitude: d.latitude,
        longitude: d.longitude,
        updatedAt: d.timestamp,
      ),
      TrackingStorageService.saveTrackingData(
        vehicleId: vehicleId,
        vehicleNumber: d.vehicleNumber,
        latitude: d.latitude,
        longitude: d.longitude,
        speed: d.speed,
        direction: d.direction,
        course: d.course,
      ),
    ]);
  }

  Future<void> retry() async {
    _timer?.cancel();
    _error = null;
    _safeNotify();
    _startPolling();
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_data != null) {
      _animateCameraTo(LatLng(_data!.latitude, _data!.longitude));
    }
  }

  void _animateCameraTo(LatLng position) {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
  }

  // Guard so async callbacks (fetch, stop) never call notifyListeners()
  // on an already-disposed provider, which throws in debug mode.
  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    // Clear the callback so a stale closure can't fire after this instance is gone.
    NotificationService.onStopRequested = null;
    // Intentionally do NOT cancel WorkManager or the notification here.
    // Background tracking continues after the user leaves the screen.
    // The user must tap "Stop Tracking" (button or notification action) to end it.
    _mapController?.dispose();
    super.dispose();
  }
}
