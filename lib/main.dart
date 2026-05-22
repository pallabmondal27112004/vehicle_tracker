import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/background_task_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/dashboard_provider.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Both services must be ready before any screen runs.
  await NotificationService.init();
  await BackgroundTaskService.init();

  runApp(const VehicleTrackingApp());
}

class VehicleTrackingApp extends StatelessWidget {
  const VehicleTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => DashboardProvider())],
      child: MaterialApp(
        title: 'TrackNova',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const DashboardScreen(),
      ),
    );
  }
}
