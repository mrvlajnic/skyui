import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// A single device position fix.
class PositionFix {
  final LatLng coordinates;
  final double? headingDegrees;
  final double? speedMetersPerSecond;
  final double? accuracyMeters;

  const PositionFix({
    required this.coordinates,
    this.headingDegrees,
    this.speedMetersPerSecond,
    this.accuracyMeters,
  });
}

/// Device positioning behind an interface so the Navigation session can run
/// with a simulated drive on desktop and real fixes on mobile.
abstract class PositioningService {
  /// Requests permission and checks that location services are enabled.
  Future<bool> ensurePermission();

  /// Stream of device fixes. Call only after [ensurePermission] succeeds.
  Stream<PositionFix> positions();

  void dispose();
}

/// `geolocator` implementation for Android and iOS.
class GeolocatorPositioningService implements PositioningService {
  final LocationAccuracy accuracy;
  final int distanceFilterMeters;

  GeolocatorPositioningService({
    this.accuracy = LocationAccuracy.high,
    this.distanceFilterMeters = 5,
  });

  @override
  Future<bool> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  @override
  Stream<PositionFix> positions() {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilterMeters,
      ),
    ).map(
      (position) => PositionFix(
        coordinates: LatLng(position.latitude, position.longitude),
        headingDegrees: position.heading >= 0 ? position.heading : null,
        speedMetersPerSecond: position.speed >= 0 ? position.speed : null,
        accuracyMeters: position.accuracy,
      ),
    );
  }

  @override
  void dispose() {}
}
