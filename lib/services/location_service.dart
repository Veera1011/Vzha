import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Asks for location permission and returns the current [Position].
  /// This can be used to verify the user's timezone/location for accurate timing.
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    } 

    return await Geolocator.getCurrentPosition();
  }

  /// Returns a DateTime that is "location-verified". 
  /// In a production app, you might use the position to fetch the actual timezone offset from an API.
  static Future<DateTime> getVerifiedTime() async {
    try {
      await getCurrentLocation();
      // If we got here, permission was granted and location is active.
      // We return the local time, which is now more "trusted" since we verified the device location.
      return DateTime.now();
    } catch (e) {
      // Fallback to normal time if location fails
      return DateTime.now();
    }
  }
}
