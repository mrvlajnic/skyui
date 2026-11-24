import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import 'route_plan.dart';

/// Projects [position] onto the route and returns the fraction travelled
/// (0-1), using the precomputed cumulative kilometre marks.
///
/// The projection is done in a local equirectangular approximation, which is
/// accurate enough at city scale and avoids a heavy geodesic computation per
/// GPS fix.
double routeProgressForPosition({
  required RoutePlan route,
  required List<double> cumulativeKm,
  required LatLng position,
}) {
  if (route.geometry.length < 2 ||
      cumulativeKm.length != route.geometry.length ||
      cumulativeKm.last <= 0) {
    return 0;
  }

  final totalKm = cumulativeKm.last;
  final cosLat = math.cos(position.latitude * math.pi / 180);
  double projectX(double longitude) =>
      (longitude - position.longitude) * cosLat;
  double projectY(double latitude) => latitude - position.latitude;

  var bestDistanceSquared = double.infinity;
  var bestKm = 0.0;

  for (var index = 1; index < route.geometry.length; index++) {
    final from = route.geometry[index - 1];
    final to = route.geometry[index];

    final segmentX = projectX(to.longitude) - projectX(from.longitude);
    final segmentY = projectY(to.latitude) - projectY(from.latitude);
    final segmentLengthSquared = segmentX * segmentX + segmentY * segmentY;

    var t = 0.0;
    if (segmentLengthSquared > 0) {
      final deltaX = projectX(from.longitude);
      final deltaY = projectY(from.latitude);
      t = -(deltaX * segmentX + deltaY * segmentY) / segmentLengthSquared;
      t = t.clamp(0.0, 1.0);
    }

    final closestX = projectX(from.longitude) + segmentX * t;
    final closestY = projectY(from.latitude) + segmentY * t;
    final distanceSquared = closestX * closestX + closestY * closestY;

    if (distanceSquared < bestDistanceSquared) {
      bestDistanceSquared = distanceSquared;
      bestKm =
          cumulativeKm[index - 1] +
          (cumulativeKm[index] - cumulativeKm[index - 1]) * t;
    }
  }

  return (bestKm / totalKm).clamp(0.0, 1.0);
}
