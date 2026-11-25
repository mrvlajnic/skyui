import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:skyui/services/map_view_state.dart';
import 'package:skyui/widgets/cards/navigation_card.dart';

void main() {
  tearDown(MapViewState.instance.reset);

  Widget harness() {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 420,
            height: 620,
            child: NavigationCard(),
          ),
        ),
      ),
    );
  }

  testWidgets('compact card mirrors the shared route summary', (tester) async {
    MapViewState.instance.updateSummary(
      const RouteSummary(
        destination: 'City Center Mall',
        instruction: 'Turn right onto Main Street',
        remaining: '8.5 km · 12 min',
        upcoming: 'In 300 m',
        trip: '8.5 km · 12 min',
      ),
    );

    await tester.pumpWidget(harness());

    expect(find.text('City Center Mall'), findsOneWidget);
    expect(find.text('Turn right onto Main Street'), findsOneWidget);
    expect(find.text('8.5 km · 12 min'), findsWidgets);
    expect(find.text('In 300 m'), findsWidgets);
  });

  testWidgets('compact card keeps an explicit empty state', (tester) async {
    await tester.pumpWidget(harness());

    expect(find.text('No route'), findsOneWidget);
    expect(find.text('Open Navigation to plan a trip'), findsOneWidget);
  });
}
