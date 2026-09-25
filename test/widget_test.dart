// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:skyui/main.dart';
import 'package:skyui/screens/media/media_screen_content.dart';
import 'package:skyui/screens/navigation/navigation_screen_content.dart';
import 'package:skyui/screens/phone/phone_screen.dart';
import 'package:skyui/services/drive_mode_service.dart';

void main() {
  final driveMode = DriveModeService.instance;

  setUp(() => driveMode.update(VehicleState.parked));
  tearDown(() => driveMode.update(VehicleState.parked));

  test('Drive mode notifies only on state changes', () {
    var notifications = 0;
    void listener() => notifications++;
    driveMode.state.addListener(listener);
    addTearDown(() => driveMode.state.removeListener(listener));

    expect(driveMode.isDriving, isFalse);
    driveMode.update(VehicleState.driving);
    expect(driveMode.state.value, VehicleState.driving);
    expect(driveMode.isDriving, isTrue);
    driveMode.update(VehicleState.driving);
    expect(notifications, 1);
    driveMode.toggle();
    expect(driveMode.state.value, VehicleState.parked);
    expect(notifications, 2);
  });

  testWidgets('Media locks browsing and preserves playback across drive mode', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1680, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MediaScreenContent(onClose: () {})),
      ),
    );
    expect(find.text('UP NEXT'), findsOneWidget);
    expect(find.text('Spotify'), findsOneWidget);
    await tester.tap(find.text('Cyber Sunset'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('00:00'), findsOneWidget);

    driveMode.update(VehicleState.driving);
    await tester.pump();
    expect(find.text('UP NEXT'), findsNothing);
    expect(find.text('Spotify'), findsNothing);
    expect(find.byType(ListView), findsNothing);
    expect(find.text('Cyber Sunset'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.skip_next_rounded));
    await tester.pump();
    expect(find.text('Electric Velocity'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('00:01'), findsOneWidget);

    driveMode.update(VehicleState.parked);
    await tester.pump();
    expect(find.text('UP NEXT'), findsOneWidget);
    expect(find.text('Spotify'), findsOneWidget);
    expect(find.text('Electric Velocity'), findsNWidgets(2));
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    driveMode.update(VehicleState.driving);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Media opened while driving starts without browsing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1680, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    driveMode.update(VehicleState.driving);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MediaScreenContent(onClose: () {})),
      ),
    );
    expect(find.text('UP NEXT'), findsNothing);
    expect(find.text('Spotify'), findsNothing);
    expect(find.text('Night Drive'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('Phone exposes only working tabs and requires explicit calling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1680, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PhoneScreen(onClose: () {})),
      ),
    );

    expect(find.text('Ready to call'), findsOneWidget);
    expect(find.text('Contacts'), findsNothing);
    expect(find.text('Voicemail'), findsNothing);
    var callButton = tester.widget<GestureDetector>(
      find.byKey(const ValueKey('phone-call-button')),
    );
    expect(callButton.onTap, isNull);
    final muteButton = tester.widget<InkWell>(
      find.descendant(
        of: find.byKey(const ValueKey('call-mute')),
        matching: find.byType(InkWell),
      ),
    );
    expect(muteButton.onTap, isNull);

    await tester.tap(find.text('Recent Calls'));
    await tester.pump();
    expect(find.text('Enter number'), findsNothing);
    expect(find.text('Demo Caller A'), findsOneWidget);

    await tester.tap(find.text('Demo Caller A'));
    await tester.pump();
    expect(find.text('+1 202 555 0100'), findsOneWidget);
    callButton = tester.widget<GestureDetector>(
      find.byKey(const ValueKey('phone-call-button')),
    );
    expect(callButton.onTap, isNotNull);

    await tester.tap(find.byKey(const ValueKey('phone-call-button')));
    await tester.pump();
    expect(find.text('Active demo call'), findsOneWidget);
    expect(find.byKey(const ValueKey('phone-close-button')), findsNothing);
    callButton = tester.widget<GestureDetector>(
      find.byKey(const ValueKey('phone-call-button')),
    );
    expect(callButton.onTap, isNull);
    final activeMuteButton = tester.widget<InkWell>(
      find.descendant(
        of: find.byKey(const ValueKey('call-mute')),
        matching: find.byType(InkWell),
      ),
    );
    expect(activeMuteButton.onTap, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Latest module request wins and system back closes the module', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1680, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SkyUIApp());

    await tester.tap(find.byKey(const ValueKey('sidebar-Media')));
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(find.byKey(const ValueKey('sidebar-Phone')));
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(find.byKey(const ValueKey('sidebar-Navigation')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(NavigationScreenContent), findsOneWidget);
    expect(find.byType(MediaScreenContent), findsNothing);
    expect(find.byType(PhoneScreen), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(NavigationScreenContent), findsNothing);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byKey(const ValueKey('sidebar-Media')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('sidebar-Media')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(MediaScreenContent), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Active demo call cannot be discarded by module navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1680, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SkyUIApp());
    await tester.tap(find.byKey(const ValueKey('sidebar-Phone')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('phone-call-button')));
    await tester.pump();
    final lockedNavigationButton = tester.widget<InkWell>(
      find.descendant(
        of: find.byKey(const ValueKey('sidebar-Navigation')),
        matching: find.byType(InkWell),
      ),
    );
    expect(lockedNavigationButton.onTap, isNull);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('sidebar-Media')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PhoneScreen), findsOneWidget);
    expect(find.byType(MediaScreenContent), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('End'));
    await tester.pump();
    expect(find.text('No active call'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('sidebar-Media')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(MediaScreenContent), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Call started during module exit keeps Phone open', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1680, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SkyUIApp());
    await tester.tap(find.byKey(const ValueKey('sidebar-Phone')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('5'));
    await tester.pump();

    final startCall = tester
        .widget<GestureDetector>(
          find.byKey(const ValueKey('phone-call-button')),
        )
        .onTap!;
    await tester.tap(find.byKey(const ValueKey('sidebar-Media')));
    await tester.pump(const Duration(milliseconds: 100));
    startCall();
    await tester.pump();
    expect(find.text('Active demo call'), findsOneWidget);
    final lockedNavigationButton = tester.widget<InkWell>(
      find.descendant(
        of: find.byKey(const ValueKey('sidebar-Navigation')),
        matching: find.byType(InkWell),
      ),
    );
    expect(lockedNavigationButton.onTap, isNull);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(PhoneScreen), findsOneWidget);
    expect(find.byType(MediaScreenContent), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Unavailable sidebar destinations are disabled', (tester) async {
    tester.view.physicalSize = const Size(1680, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SkyUIApp());

    final vehicleButton = find.byKey(const ValueKey('sidebar-Vehicle'));
    final settingsButton = find.byKey(const ValueKey('sidebar-Settings'));
    final vehicleTap = tester.widget<InkWell>(
      find.descendant(of: vehicleButton, matching: find.byType(InkWell)),
    );
    final settingsTap = tester.widget<InkWell>(
      find.descendant(of: settingsButton, matching: find.byType(InkWell)),
    );

    expect(vehicleTap.onTap, isNull);
    expect(settingsTap.onTap, isNull);
  });

  testWidgets('SkyUI app loads', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1680, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SkyUIApp());

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(SafeArea), findsOneWidget);
    await tester.tap(find.text('PARKED'));
    await tester.pump();
    expect(driveMode.isDriving, isTrue);
    expect(find.text('DRIVING'), findsOneWidget);
    await tester.tap(find.text('DRIVING'));
    await tester.pump();
    expect(driveMode.isDriving, isFalse);
  });
}
