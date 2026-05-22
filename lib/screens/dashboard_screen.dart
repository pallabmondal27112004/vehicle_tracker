import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/vehicle_list_item.dart';
import '../features/vehicle_tracking/presentation/screens/vehicle_tracking_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final vehicles = provider.vehicles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Tracking'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${vehicles.length} vehicles',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ),
        ),
      ),
      body: vehicles.isEmpty
          ? const Center(child: Text('No vehicles found.'))
          : SafeArea(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  return VehicleListItem(
                    vehicle: vehicle,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              VehicleTrackingScreen(vehicle: vehicle),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
