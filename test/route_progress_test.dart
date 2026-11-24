import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:skyui/models/route_plan.dart';
import 'package:skyui/models/route_progress.dart';

void main() {
  const route = RoutePlan(
    geometry: [
      LatLng(44.7866, 20.4489),
      LatLng(44.7866, 20.4589),
      LatLng(44.7866, 20.4689),
    ],
    distanceKm: 1.58,
    durationSeconds: 200,
    steps: [],
  );
  const cumulative = [0.0, 0.79, 1.58];

  test('projection reaches 0 at the start and 1 at the end', () {
    expect(
      routeProgressForPosition(
        route: route,
        cumulativeKm: cumulative,
        position: route.geometry.first,
      ),
      closeTo(0, 0.001),
    );
    expect(
      routeProgressForPosition(
        route: route,
        cumulativeKm: cumulative,
        position: route.geometry.last,
      ),
      closeTo(1, 0.001),
    );
  });

  test('projection interpolates along a segment', () {
    const midpoint = LatLng(44.7866, 20.4539);
    expect(
      routeProgressForPosition(
        route: route,
        cumulativeKm: cumulative,
        position: midpoint,
      ),
      closeTo(0.25, 0.01),
    );
  });

  test('an off-route position snaps to the nearest point', () {
    const offRoute = LatLng(44.7871, 20.4539);
    expect(
      routeProgressForPosition(
        route: route,
        cumulativeKm: cumulative,
        position: offRoute,
      ),
      closeTo(0.25, 0.01),
    );
  });

  test('degenerate routes report no progress', () {
    const single = RoutePlan(
      geometry: [LatLng(44.7866, 20.4489)],
      distanceKm: 0,
      durationSeconds: 0,
      steps: [],
    );
    expect(
      routeProgressForPosition(
        route: single,
        cumulativeKm: const [0],
        position: const LatLng(44.7866, 20.4489),
      ),
      0,
    );
  });
}
