import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../models/vehicle.dart';
import '../../data/datasources/tracking_mock_datasource.dart';
import '../../data/datasources/tracking_remote_datasource.dart';
import '../../data/repositories/tracking_repository.dart';
import '../providers/tracking_provider.dart';
import '../widgets/vehicle_info_card.dart';

class VehicleTrackingScreen extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleTrackingScreen({super.key, required this.vehicle});

  TrackingRepository _buildRepository() {
    if (AppConstants.useMockApi) {
      return TrackingRepositoryImpl(
        TrackingMockDatasource(
          initialLat: vehicle.latitude,
          initialLon: vehicle.longitude,
          initialSpeed: vehicle.speed,
          initialCourse: vehicle.course,
          vehicleNumber: vehicle.vehicleNumber,
        ),
      );
    }
    return TrackingRepositoryImpl(TrackingRemoteDatasource());
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrackingProvider(
        repository: _buildRepository(),
        vehicleId: vehicle.id,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(vehicle.vehicleNumber),
          backgroundColor: Colors.blueGrey[800],
          foregroundColor: Colors.white,
          actions: [
            // Toggle button — visible in AppBar so it's always reachable
            Consumer<TrackingProvider>(
              builder: (context, provider, _) {
                final active = provider.isTrackingActive;
                return IconButton(
                  icon: Icon(
                    active ? Icons.pause_circle_outline : Icons.play_circle_outline,
                  ),
                  tooltip: active ? 'Stop Tracking' : 'Resume Tracking',
                  onPressed: () {
                    if (active) {
                      provider.stopTracking();
                    } else {
                      provider.startTracking();
                    }
                  },
                );
              },
            ),
          ],
        ),
        body: Consumer<TrackingProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const _LoadingView();
            }
            if (provider.error != null && provider.data == null) {
              return _ErrorView(
                message: provider.error!,
                onRetry: provider.retry,
              );
            }
            return _MapView(vehicle: vehicle, provider: provider);
          },
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading vehicle location...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.signal_wifi_connected_no_internet_4,
                size: 56, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[700],
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapView extends StatelessWidget {
  final Vehicle vehicle;
  final TrackingProvider provider;

  const _MapView({required this.vehicle, required this.provider});

  @override
  Widget build(BuildContext context) {
    final data = provider.data!;
    final currentPos = LatLng(data.latitude, data.longitude);

    final markers = {
      Marker(
        markerId: MarkerId(vehicle.id),
        position: currentPos,
        infoWindow: InfoWindow(
          title: vehicle.vehicleNumber,
          snippet:
              '${data.speed.toStringAsFixed(1)} km/h · ${data.direction}',
        ),
      ),
    };

    final polylines = provider.routePoints.length > 1
        ? {
            Polyline(
              polylineId: const PolylineId('route'),
              points: provider.routePoints,
              color: Colors.blueGrey,
              width: 4,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
            ),
          }
        : <Polyline>{};

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition:
                    CameraPosition(target: currentPos, zoom: 15),
                markers: markers,
                polylines: polylines,
                onMapCreated: provider.onMapCreated,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
              // Small status pill — shows whether live updates are running.
              Positioned(
                top: 12,
                left: 12,
                child: _TrackingBadge(isActive: provider.isTrackingActive),
              ),
            ],
          ),
        ),
        VehicleInfoCard(data: data),
      ],
    );
  }
}

class _TrackingBadge extends StatelessWidget {
  final bool isActive;

  const _TrackingBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.shade700.withValues(alpha: 0.9)
            : Colors.grey.shade700.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Live' : 'Paused',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
