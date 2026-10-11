import 'package:geolocator/geolocator.dart';

enum LocationProblem { serviceOff, denied }

class LocationResult {
  const LocationResult.ok(this.lat, this.lng) : problem = null;
  const LocationResult.failed(this.problem)
      : lat = null,
        lng = null;

  final double? lat;
  final double? lng;
  final LocationProblem? problem;
}

/// Asks for location only when the user taps "My location", never in the
/// background, and never sends it anywhere.
class LocationService {
  const LocationService();

  Future<LocationResult> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const LocationResult.failed(LocationProblem.serviceOff);
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return const LocationResult.failed(LocationProblem.denied);
    }
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return LocationResult.ok(p.latitude, p.longitude);
  }
}
