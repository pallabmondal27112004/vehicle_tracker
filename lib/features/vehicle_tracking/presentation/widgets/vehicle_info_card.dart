import 'package:flutter/material.dart';
import '../../data/models/tracking_data.dart';

class VehicleInfoCard extends StatelessWidget {
  final TrackingData data;

  const VehicleInfoCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isMoving = data.speed > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                data.vehicleNumber,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _StatusBadge(isMoving: isMoving),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _InfoTile(label: 'Speed', value: '${data.speed.toStringAsFixed(1)} km/h'),
              _InfoTile(label: 'Direction', value: data.direction),
              _InfoTile(label: 'Course', value: '${data.course.toStringAsFixed(0)}°'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _InfoTile(label: 'Latitude', value: data.latitude.toStringAsFixed(5)),
              _InfoTile(label: 'Longitude', value: data.longitude.toStringAsFixed(5)),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isMoving;

  const _StatusBadge({required this.isMoving});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isMoving ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isMoving ? 'Moving' : 'Parked',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isMoving ? Colors.green.shade700 : Colors.grey.shade600,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
