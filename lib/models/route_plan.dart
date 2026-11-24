import 'package:latlong2/latlong.dart';

/// One maneuver of a route, as returned by the routing provider.
class RouteStep {
  final String instruction;
  final String maneuverType;
  final double distanceKm;
  final double durationSeconds;

  /// Index range of this step inside the route geometry.
  final int beginIndex;
  final int endIndex;

  const RouteStep({
    required this.instruction,
    required this.maneuverType,
    required this.distanceKm,
    required this.durationSeconds,
    required this.beginIndex,
    required this.endIndex,
  });

  factory RouteStep.fromMapTilerStep(Map<String, dynamic> step) {
    final maneuver = step['maneuver'];
    final instruction = maneuver is Map
        ? (maneuver['instruction'] as String?)?.trim() ?? ''
        : '';
    final streetName = (step['streetName'] as String?)?.trim() ?? '';
    final fallback = streetName.isNotEmpty
        ? 'Continue on $streetName'
        : 'Continue';

    return RouteStep(
      instruction: instruction.isNotEmpty ? instruction : fallback,
      maneuverType: maneuver is Map
          ? (maneuver['type'] as String?) ?? 'none'
          : 'none',
      distanceKm: (step['length'] as num?)?.toDouble() ?? 0,
      durationSeconds: (step['time'] as num?)?.toDouble() ?? 0,
      beginIndex: (step['beginIndex'] as num?)?.toInt() ?? 0,
      endIndex: (step['endIndex'] as num?)?.toInt() ?? 0,
    );
  }
}

/// A provider-calculated driving route.
///
/// Distances are kilometres and durations seconds, matching the units the
/// routing service is asked for. The vehicle position that follows this route
/// is still simulated on desktop.
class RoutePlan {
  final List<LatLng> geometry;
  final double distanceKm;
  final double durationSeconds;
  final List<RouteStep> steps;

  const RoutePlan({
    required this.geometry,
    required this.distanceKm,
    required this.durationSeconds,
    required this.steps,
  });

  bool get hasGeometry => geometry.length >= 2;

  factory RoutePlan.fromMapTilerRoute(Map<String, dynamic> route) {
    final legs = route['legs'];
    if (legs is! List || legs.isEmpty) {
      throw const FormatException('Route has no legs');
    }

    final geometry = <LatLng>[];
    final steps = <RouteStep>[];
    var distanceKm = 0.0;
    var durationSeconds = 0.0;

    final summary = route['summary'];
    if (summary is Map) {
      distanceKm = (summary['totalLength'] as num?)?.toDouble() ?? 0;
      durationSeconds = (summary['totalTime'] as num?)?.toDouble() ?? 0;
    }

    for (final leg in legs.whereType<Map<String, dynamic>>()) {
      final legGeometry = leg['geometry'];
      if (legGeometry is String && legGeometry.isNotEmpty) {
        // The live API returns a precision-6 encoded polyline.
        geometry.addAll(_decodePolyline(legGeometry));
      } else if (legGeometry is List) {
        for (final point in legGeometry) {
          if (point is List && point.length >= 2) {
            geometry.add(
              LatLng(
                (point[1] as num).toDouble(),
                (point[0] as num).toDouble(),
              ),
            );
          }
        }
      }

      final legSteps = leg['steps'];
      if (legSteps is List) {
        for (final step in legSteps.whereType<Map<String, dynamic>>()) {
          steps.add(RouteStep.fromMapTilerStep(step));
        }
      }
    }

    if (distanceKm == 0 || durationSeconds == 0) {
      var summedDistance = 0.0;
      var summedDuration = 0.0;
      for (final leg in legs.whereType<Map<String, dynamic>>()) {
        final legSummary = leg['summary'];
        if (legSummary is Map) {
          summedDistance +=
              (legSummary['totalLength'] as num?)?.toDouble() ?? 0;
          summedDuration += (legSummary['totalTime'] as num?)?.toDouble() ?? 0;
        }
      }
      if (distanceKm == 0) distanceKm = summedDistance;
      if (durationSeconds == 0) durationSeconds = summedDuration;
    }

    if (geometry.length < 2) {
      throw const FormatException('Route has no geometry');
    }

    return RoutePlan(
      geometry: geometry,
      distanceKm: distanceKm,
      durationSeconds: durationSeconds,
      steps: steps,
    );
  }
}

/// Decodes a precision-6 encoded polyline (the format MapTiler returns).
List<LatLng> _decodePolyline(String encoded, {int precision = 6}) {
  final points = <LatLng>[];
  final factor = precision == 6 ? 1000000.0 : 100000.0;
  var index = 0;
  var latitude = 0;
  var longitude = 0;

  while (index < encoded.length) {
    var shift = 0;
    var result = 0;
    int byte;
    do {
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);
    latitude += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

    shift = 0;
    result = 0;
    do {
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);
    longitude += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

    points.add(LatLng(latitude / factor, longitude / factor));
  }

  return points;
}
