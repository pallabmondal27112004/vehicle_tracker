import 'package:flutter/foundation.dart';
import '../models/vehicle.dart';

class DashboardProvider extends ChangeNotifier {
  List<Vehicle> _vehicles = [];

  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);

  DashboardProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    _vehicles = [
      const Vehicle(
        id: '1',
        vehicleNumber: 'MH-12-AB-1234',
        latitude: 18.5204,
        longitude: 73.8567,
        direction: 'North',
        speed: 45.5,
        course: 0.0,
      ),
      const Vehicle(
        id: '2',
        vehicleNumber: 'KA-01-MN-5678',
        latitude: 12.9716,
        longitude: 77.5946,
        direction: 'NE',
        speed: 62.0,
        course: 45.0,
      ),
      const Vehicle(
        id: '3',
        vehicleNumber: 'DL-04-CD-9900',
        latitude: 28.6139,
        longitude: 77.2090,
        direction: 'South',
        speed: 30.0,
        course: 180.0,
      ),
      const Vehicle(
        id: '4',
        vehicleNumber: 'TN-09-EF-3344',
        latitude: 13.0827,
        longitude: 80.2707,
        direction: 'West',
        speed: 55.8,
        course: 270.0,
      ),
      const Vehicle(
        id: '5',
        vehicleNumber: 'GJ-18-XY-7721',
        latitude: 23.0225,
        longitude: 72.5714,
        direction: 'NW',
        speed: 0.0,
        course: 315.0,
      ),
      const Vehicle(
        id: '6',
        vehicleNumber: 'RJ-14-PQ-4456',
        latitude: 26.9124,
        longitude: 75.7873,
        direction: 'SE',
        speed: 78.3,
        course: 135.0,
      ),
    ];
    notifyListeners();
  }
}
