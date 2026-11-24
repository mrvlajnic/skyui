import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:skyui/models/place.dart';
import 'package:skyui/models/route_plan.dart';
import 'package:skyui/screens/navigation/navigation_screen_content.dart';
import 'package:skyui/screens/navigation/place_search_panel.dart';
import 'package:skyui/services/geocoding_service.dart';
import 'package:skyui/services/routing_service.dart';

class _FakeGeocodingService implements GeocodingService {
  final List<Place> results;
  int calls = 0;

  _FakeGeocodingService(this.results);

  @override
  Future<List<Place>> search(String query, {int limit = 5}) async {
    calls++;
    return results;
  }

  @override
  void dispose() {}
}

class _FakeRoutingService implements RoutingService {
  final RoutePlan plan;
  int calls = 0;
  LatLng? requestedStart;
  LatLng? requestedDestination;

  _FakeRoutingService(this.plan);

  @override
  Future<RoutePlan> route(LatLng start, LatLng destination) async {
    calls++;
    requestedStart = start;
    requestedDestination = destination;
    return plan;
  }

  @override
  void dispose() {}
}

void main() {
  const knez = Place(
    id: 'address.1',
    name: 'Knez Mihailova',
    address: 'Knez Mihailova, Belgrade, Serbia',
    coordinates: LatLng(44.8178, 20.4573),
  );
  const kalemegdan = Place(
    id: 'poi.2',
    name: 'Kalemegdan Fortress',
    address: 'Kalemegdan, Belgrade, Serbia',
    coordinates: LatLng(44.8231, 20.4499),
  );

  testWidgets('place search shows provider results and reports the choice', (
    tester,
  ) async {
    final service = _FakeGeocodingService([knez, kalemegdan]);
    SearchTarget? selectedTarget;
    Place? selectedPlace;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 380,
            height: 520,
            child: PlaceSearchPanel(
              service: service,
              unavailableReason: 'No key',
              onPlaceSelected: (target, place) {
                selectedTarget = target;
                selectedPlace = place;
              },
              onClose: () {},
            ),
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('place-search-destination')),
      'Knez',
    );
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    expect(service.calls, 1);
    expect(find.text('Knez Mihailova'), findsOneWidget);
    expect(find.text('Kalemegdan Fortress'), findsOneWidget);

    await tester.tap(find.text('Knez Mihailova'));
    await tester.pump();

    expect(selectedTarget, SearchTarget.destination);
    expect(selectedPlace, knez);
  });

  testWidgets('place search explains why it is unavailable', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 380,
            height: 520,
            child: PlaceSearchPanel(
              service: null,
              unavailableReason: 'Map key not configured.',
              onPlaceSelected: (_, _) {},
              onClose: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Map key not configured.'), findsOneWidget);

    final field = tester.widget<TextField>(
      find.byKey(const ValueKey('place-search-destination')),
    );
    expect(field.enabled, isFalse);
  });

  testWidgets('navigation search applies the selected destination', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1680, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final service = _FakeGeocodingService([knez]);
    final routing = _FakeRoutingService(
      const RoutePlan(
        geometry: [
          LatLng(44.7866, 20.4489),
          LatLng(44.8000, 20.4550),
          LatLng(44.8178, 20.4573),
        ],
        distanceKm: 8.4,
        durationSeconds: 900,
        steps: [
          RouteStep(
            instruction: 'Drive north on Knez Mihailova.',
            maneuverType: 'start',
            distanceKm: 8.4,
            durationSeconds: 900,
            beginIndex: 0,
            endIndex: 2,
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NavigationScreenContent(
            onClose: () {},
            geocodingService: service,
            routingService: routing,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('navigation-search-button')));
    await tester.pump();
    expect(find.text('Plan a route'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('place-search-destination')),
      'Knez',
    );
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
    expect(find.text('Knez Mihailova'), findsOneWidget);

    await tester.tap(find.text('Knez Mihailova'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Plan a route'), findsNothing);
    expect(find.text('Knez Mihailova'), findsOneWidget);
    expect(find.text('8.4 km · 15 min · simulated'), findsOneWidget);
    expect(find.text('Drive north on Knez Mihailova.'), findsOneWidget);
    expect(find.textContaining('remaining'), findsOneWidget);
    expect(routing.calls, 1);
    expect(routing.requestedDestination, knez.coordinates);
    expect(tester.takeException(), isNull);

    // Run the simulated drive to arrival.
    await tester.pump(const Duration(seconds: 13));
    await tester.pump();
    expect(find.text('You have arrived at your destination.'), findsOneWidget);

    // Ending guidance restores the fixture destination.
    await tester.tap(find.byKey(const ValueKey('guidance-end-button')));
    await tester.pump();
    expect(find.byKey(const ValueKey('guidance-end-button')), findsNothing);
    expect(find.text('City Center Mall'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
