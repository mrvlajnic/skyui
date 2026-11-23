import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:skyui/models/place.dart';
import 'package:skyui/screens/navigation/navigation_screen_content.dart';
import 'package:skyui/screens/navigation/place_search_panel.dart';
import 'package:skyui/services/geocoding_service.dart';

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
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NavigationScreenContent(
            onClose: () {},
            geocodingService: service,
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

    expect(find.text('Plan a route'), findsNothing);
    expect(find.text('Knez Mihailova'), findsOneWidget);
    expect(find.text('Search result · simulated route'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
