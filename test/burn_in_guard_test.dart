import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:skyui/core/display/burn_in_policy.dart';
import 'package:skyui/services/drive_mode_service.dart';
import 'package:skyui/widgets/display/burn_in_guard.dart';

const BurnInPolicy _fastPolicy = BurnInPolicy(
  shiftPeriod: Duration(seconds: 4),
  shiftSteps: 8,
  idleDimAfter: Duration(seconds: 2),
  dimTransition: Duration(milliseconds: 100),
);

const ValueKey<String> _shiftKey = ValueKey('burn-in-shift');
const ValueKey<String> _wakeKey = ValueKey('burn-in-wake');

Widget _harness({required bool enabled, BurnInPolicy policy = _fastPolicy}) {
  return MaterialApp(
    home: BurnInGuard(
      enabled: enabled,
      policy: policy,
      child: const Scaffold(body: Center(child: Text('CONTENT'))),
    ),
  );
}

Offset _translation(WidgetTester tester) {
  final transform = tester.widget<Transform>(find.byKey(_shiftKey));
  final translation = transform.transform.getTranslation();
  return Offset(translation.x, translation.y);
}

void main() {
  final driveMode = DriveModeService.instance;

  setUp(() => driveMode.update(VehicleState.parked));
  tearDown(() => driveMode.update(VehicleState.parked));

  testWidgets('disabled guard leaves the tree untouched', (tester) async {
    await tester.pumpWidget(_harness(enabled: false));

    expect(find.byKey(_shiftKey), findsNothing);
    expect(find.text('CONTENT'), findsOneWidget);

    await tester.pump(const Duration(seconds: 10));
    expect(find.byKey(_wakeKey), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('enabled guard shifts the surface as time passes', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(enabled: true));

    expect(find.byKey(_shiftKey), findsOneWidget);
    expect(_translation(tester), Offset.zero);

    // One step per 500 ms; after 1 s the surface has moved.
    await tester.pump(const Duration(seconds: 1));
    final moved = _translation(tester);
    expect(moved, isNot(Offset.zero));
    expect(moved.dx.abs(), lessThanOrEqualTo(_fastPolicy.shiftAmplitude));
    expect(moved.dy.abs(), lessThanOrEqualTo(_fastPolicy.shiftAmplitude));

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('parked and untouched dims, and the first tap only wakes', (
    tester,
  ) async {
    var contentTaps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: BurnInGuard(
          enabled: true,
          policy: _fastPolicy,
          child: Scaffold(
            body: Center(
              child: GestureDetector(
                onTap: () => contentTaps++,
                child: const Text('CONTENT'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(_wakeKey), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(_wakeKey), findsOneWidget);

    // Waking must not press the control underneath.
    await tester.tap(find.byKey(_wakeKey));
    await tester.pump();
    expect(find.byKey(_wakeKey), findsNothing);
    expect(contentTaps, 0);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a driving car is never dimmed', (tester) async {
    driveMode.update(VehicleState.driving);
    await tester.pumpWidget(_harness(enabled: true));

    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(_wakeKey), findsNothing);

    // Parking restarts the idle timer. The controller's first tick defines
    // its start time, so let the ticker start before advancing the clock.
    driveMode.update(VehicleState.parked);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(_wakeKey), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
