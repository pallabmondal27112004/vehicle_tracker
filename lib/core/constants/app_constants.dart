class AppConstants {
  // Toggle to false and set trackingBaseUrl when a real API is available.
  static const bool useMockApi = true;

  static const String trackingBaseUrl = 'https://your-api.example.com';

  // Replace with your actual Google Maps API key.
  static const String googleMapsApiKey =
      'AIzaSyAhLOc4xrSf45wrgiQ5IYtaV0MR2VlT-UM';

  static const Duration pollingInterval = Duration(seconds: 10);

  // WorkManager task identifiers.
  // uniqueName is what we use to register/cancel; taskName is what shows in the callback.
  static const String bgTaskUniqueName = 'com.vehicletracking.background_poll';
  static const String bgTaskName = 'background_tracking_poll';
}
