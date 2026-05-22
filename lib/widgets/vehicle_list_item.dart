import 'package:flutter/material.dart';
import '../models/vehicle.dart';

class VehicleListItem extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;

  const VehicleListItem({
    super.key,
    required this.vehicle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMoving = vehicle.speed > 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              _VehicleIcon(isMoving: isMoving),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.vehicleNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _CoordRow(
                      latitude: vehicle.latitude,
                      longitude: vehicle.longitude,
                    ),
                    const SizedBox(height: 4),
                    _StatsRow(
                      direction: vehicle.direction,
                      speed: vehicle.speed,
                      course: vehicle.course,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleIcon extends StatelessWidget {
  final bool isMoving;

  const _VehicleIcon({required this.isMoving});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: isMoving ? Colors.blueGrey[700] : Colors.grey[400],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.local_shipping, color: Colors.white, size: 22),
    );
  }
}

class _CoordRow extends StatelessWidget {
  final double latitude;
  final double longitude;

  const _CoordRow({required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.location_on, size: 13, color: Colors.grey),
        const SizedBox(width: 3),
        _Field(label: 'Lat', value: latitude.toStringAsFixed(4)),
        const SizedBox(width: 12),
        _Field(label: 'Lon', value: longitude.toStringAsFixed(4)),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final String direction;
  final double speed;
  final double course;

  const _StatsRow({
    required this.direction,
    required this.speed,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.explore, size: 13, color: Colors.grey),
        const SizedBox(width: 3),
        _Field(label: 'Dir', value: direction),
        const SizedBox(width: 12),
        _Field(label: 'Speed', value: '${speed.toStringAsFixed(1)} km/h'),
        const SizedBox(width: 12),
        _Field(label: 'Course', value: '${course.toStringAsFixed(0)}°'),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;

  const _Field({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(color: Colors.grey),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
