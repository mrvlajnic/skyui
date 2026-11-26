import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:skyui/services/map_view_state.dart';
import 'package:skyui/widgets/map/dashboard_map.dart';
import 'package:skyui/widgets/map/route_preview_map.dart';

void main() {
  testWidgets('home fallback map draws no route until one is published', (
    tester,
  ) async {
    MapViewState.instance.reset();

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(width: 320, height: 400, child: DashboardMap()),
          ),
        ),
      ),
    );

    final emptyMap = tester.widget<RoutePreviewMap>(
      find.byType(RoutePreviewMap),
    );
    expect(emptyMap.route, isEmpty);

    MapViewState.instance.updateRoute(const [
      LatLng(44.80530, 20.44645),
      LatLng(44.81190, 20.45470),
    ]);
    await tester.pump();

    final routedMap = tester.widget<RoutePreviewMap>(
      find.byType(RoutePreviewMap),
    );
    expect(routedMap.route, hasLength(2));

    MapViewState.instance.reset();
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
