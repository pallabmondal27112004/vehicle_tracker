import 'package:flutter_test/flutter_test.dart';
import 'package:vehicletracking/main.dart';

void main() {
  testWidgets('Dashboard screen loads with vehicle list', (WidgetTester tester) async {
    await tester.pumpWidget(const VehicleTrackingApp());
    await tester.pump();

    expect(find.text('Vehicle Tracking'), findsOneWidget);
    expect(find.text('MH-12-AB-1234'), findsOneWidget);
  });
}
