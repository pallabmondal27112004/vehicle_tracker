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

## Networking — Why Dio is in This Project

### Short answer

Right now Dio makes **zero HTTP calls** because `useMockApi = true`.
It is included as the ready-to-use HTTP client for when you flip that flag to `false` and connect the app to a real backend.

---

### What Dio is

[Dio](https://pub.dev/packages/dio) is a powerful HTTP client for Dart/Flutter.
It replaces the built-in `http` package and adds:

| Feature | What it gives you |
|---|---|
| `BaseOptions` | Set `baseUrl`, default headers, and timeouts once — every request inherits them |
| Interceptors | Plug in logging, auth token injection, or retry logic without touching each call site |
| Timeout config | `connectTimeout` and `receiveTimeout` in one place |
| Structured errors | `DioException` carries the status code, response body, and request info together |
| Multipart / form-data | Upload files without extra packages |

---

### Where Dio lives in this project

```
lib/core/network/
└── dio_client.dart          ← single shared Dio instance (singleton)
```

```dart
// dio_client.dart
static Dio get instance {
  _instance ??= Dio(
    BaseOptions(
      baseUrl: AppConstants.trackingBaseUrl,   // e.g. https://your-api.example.com
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  return _instance!;
}
```

`DioClient.instance` is a lazy singleton — the `Dio` object is created only once the first time it is accessed, and the same instance is reused everywhere.

---

### The 2 places that actually use it

**1. Foreground tracking — `TrackingRemoteDatasource`**

```
lib/features/vehicle_tracking/data/datasources/tracking_remote_datasource.dart
```

Called every 10 seconds by `TrackingProvider._fetch()` while the tracking screen is open.

```dart
// Fires when useMockApi = false
final response = await _dio.get('/api/vehicles/$vehicleId/tracking');
return TrackingData.fromJson(response.data);
```

This is the main polling call. The full URL becomes:
`GET https://your-api.example.com/api/vehicles/1/tracking`

**2. Background tracking — `BackgroundTaskService`**

```
lib/core/services/background_task_service.dart
```

Called by WorkManager in a background isolate (every ~15 minutes on Android) even when the app is closed.

```dart
// Fires when useMockApi = false and the app is in the background
final response = await DioClient.instance.get(
  '/api/vehicles/${stored.vehicleId}/tracking',
);
// → updates the persistent notification with fresh coordinates
```

---

### Mock path vs Real path — side by side

```
useMockApi = true  (current)
─────────────────────────────────────────────────────
TrackingProvider._fetch()
    └── TrackingRepositoryImpl
            └── TrackingMockDatasource.getTracking()
                    └── pure Dart math — no network
                            └── returns fake TrackingData

useMockApi = false  (production)
─────────────────────────────────────────────────────
TrackingProvider._fetch()
    └── TrackingRepositoryImpl
            └── TrackingRemoteDatasource.getTracking()
                    └── DioClient.instance.get(...)   ← HTTP call happens here
                            └── parses JSON response
                                    └── returns real TrackingData
```

---

### How to extend Dio when going to production

Add interceptors in `DioClient` for auth and logging without touching any screen or provider code:

```dart
_instance!.interceptors.addAll([
  // Attach a Bearer token to every request
  InterceptorsWrapper(
    onRequest: (options, handler) {
      options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    },
  ),
  // Log every request/response in debug builds
  LogInterceptor(responseBody: true),
]);
```

---

## Color Palette

| Name | Hex |
|---|---|
| Primary Orange | `#FF9B00` |
| Bright Yellow | `#FFE100` |
| Golden Yellow | `#FFC900` |
| Muted Olive Yellow | `#EBE389` |
