import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:skyui/main.dart';
import 'package:skyui/screens/navigation/navigation_screen_content.dart';
import 'package:skyui/services/drive_mode_service.dart';
import 'package:skyui/services/map_view_state.dart';
import 'package:skyui/services/simulation_settings.dart';

void main() {
  setUp(() {
    DriveModeService.instance.update(VehicleState.parked);
    MapViewState.instance.reset();
    SimulationSettings.instance.reset();
  });
  tearDown(() {
    DriveModeService.instance.update(VehicleState.parked);
    MapViewState.instance.reset();
    SimulationSettings.instance.reset();
  });

  Future<void> open(WidgetTester tester, String destination) async {
    await tester.tap(find.byKey(ValueKey('sidebar-$destination')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('navigation keeps its state when the panel closes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1680, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SkyUIApp());

    await open(tester, 'Navigation');
    expect(find.byType(NavigationScreenContent), findsOneWidget);
    final stateBefore = tester.state(
      find.byType(NavigationScreenContent, skipOffstage: false),
    );
    final route = List.of(MapViewState.instance.route);
    expect(route, isNotEmpty);

    await open(tester, 'Home');

    // Offstage, not disposed: the widget is hidden from finders and paint but
    // still in the tree, and the same State instance is kept.
    expect(find.byType(NavigationScreenContent), findsNothing);
    final hidden = find.byType(
      NavigationScreenContent,
      skipOffstage: false,
    );
    expect(hidden, findsOneWidget);
    expect(identical(tester.state(hidden), stateBefore), isTrue);
    expect(MapViewState.instance.route, route);

    await open(tester, 'Navigation');
    expect(find.byType(NavigationScreenContent), findsOneWidget);
    expect(
      identical(
        tester.state(find.byType(NavigationScreenContent, skipOffstage: false)),
        stateBefore,
      ),
      isTrue,
    );
    expect(MapViewState.instance.route, route);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching modules does not recreate the navigation session', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1680, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SkyUIApp());

    await open(tester, 'Navigation');
    final stateBefore = tester.state(
      find.byType(NavigationScreenContent, skipOffstage: false),
    );
    final route = List.of(MapViewState.instance.route);

    await open(tester, 'Media');
    expect(
      find.byType(NavigationScreenContent, skipOffstage: false),
      findsOneWidget,
    );
    expect(
      identical(
        tester.state(find.byType(NavigationScreenContent, skipOffstage: false)),
        stateBefore,
      ),
      isTrue,
    );

    await open(tester, 'Navigation');
    expect(
      identical(
        tester.state(find.byType(NavigationScreenContent, skipOffstage: false)),
        stateBefore,
      ),
      isTrue,
    );
    expect(MapViewState.instance.route, route);
    expect(tester.takeException(), isNull);
  });
}
