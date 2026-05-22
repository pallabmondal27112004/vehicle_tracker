# TrackNova

A professional Flutter vehicle tracking application that displays real-time GPS location, speed, and route history for a fleet of vehicles.

---

## Features

- **Live vehicle tracking** — polls the server every 10 seconds and animates the map to the latest position
- **Route polyline** — draws the full path traveled since tracking started
- **Background notifications** — shows a persistent notification with current speed and coordinates even when the app is in the background (WorkManager on Android)
- **Start / Stop tracking** — toggle live updates from the AppBar or dismiss via the notification action
- **Fleet dashboard** — list of all vehicles with speed, direction, and current coordinates at a glance
- **Mock mode** — built-in data simulation lets you run and test the app without a live backend

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI | Flutter (Material 3) |
| State management | Provider (`ChangeNotifier`) |
| Maps | Google Maps Flutter |
| HTTP client | Dio |
| Background tasks | WorkManager (`workmanager`) |
| Notifications | `flutter_local_notifications` |
| Local storage | SharedPreferences |

---

## Project Structure

```
lib/
├── core/
│   ├── constants/        # AppConstants (API URL, flags, intervals)
│   ├── network/          # DioClient singleton
│   ├── services/         # BackgroundTaskService, NotificationService, TrackingStorageService
│   └── theme/            # AppColors, AppTheme
├── features/
│   └── vehicle_tracking/
│       ├── data/
│       │   ├── datasources/   # TrackingMockDatasource, TrackingRemoteDatasource
│       │   ├── models/        # TrackingData
│       │   └── repositories/  # TrackingRepository
│       └── presentation/
│           ├── providers/     # TrackingProvider
│           ├── screens/       # VehicleTrackingScreen
│           └── widgets/       # VehicleInfoCard
├── models/               # Vehicle
├── providers/            # DashboardProvider
├── screens/              # DashboardScreen
└── widgets/              # VehicleListItem
```

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.10.0`
- Android SDK with `minSdk 21+`
- A valid Google Maps API key

### 1. Add your Google Maps API key

In `lib/core/constants/app_constants.dart`:

```dart
static const String googleMapsApiKey = 'YOUR_API_KEY_HERE';
```

Also set it in `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE" />
```

### 2. Switch between mock and real API

In `lib/core/constants/app_constants.dart`:

```dart
// true  → uses built-in mock data (no backend needed)
// false → calls the real REST API
static const bool useMockApi = true;
```

When `useMockApi = false`, set your backend URL:

```dart
static const String trackingBaseUrl = 'https://your-api.example.com';
```

The API endpoint must respond to:

```
GET /api/vehicles/{vehicleId}/tracking
```

with:

```json
{
  "vehicleNumber": "MH-12-AB-1234",
  "latitude": 18.5204,
  "longitude": 73.8567,
  "speed": 45.5,
  "direction": "North",
  "course": 0.0,
  "timestamp": "2026-05-22T10:30:00.000Z"
}
```

### 3. Run the app

```bash
flutter pub get
flutter run
```

---

## Color Palette

| Name | Hex |
|---|---|
| Primary Orange | `#FF9B00` |
| Bright Yellow | `#FFE100` |
| Golden Yellow | `#FFC900` |
| Muted Olive Yellow | `#EBE389` |
