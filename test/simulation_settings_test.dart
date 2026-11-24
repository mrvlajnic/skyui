import 'package:flutter_test/flutter_test.dart';

import 'package:skyui/services/simulation_settings.dart';

void main() {
  final settings = SimulationSettings.instance;

  setUp(settings.reset);
  tearDown(settings.reset);

  test('starts at the demo default', () {
    expect(settings.routeSpeed, SimulationSettings.defaultSpeed);
    expect(settings.isRealTime, isFalse);
  });

  test('real time plays the route in real time', () {
    settings.routeSpeed = SimulationSettings.realTimeSpeed;
    expect(settings.isRealTime, isTrue);
    expect(
      settings.playbackDuration(const Duration(minutes: 15)),
      const Duration(minutes: 15),
    );
  });

  test('a higher multiplier shortens the playback', () {
    settings.routeSpeed = 30;
    expect(
      settings.playbackDuration(const Duration(minutes: 15)),
      const Duration(seconds: 30),
    );

    settings.routeSpeed = 60;
    expect(
      settings.playbackDuration(const Duration(minutes: 15)),
      const Duration(seconds: 15),
    );
  });

  test('speed is clamped to the supported range', () {
    settings.routeSpeed = 0;
    expect(settings.routeSpeed, SimulationSettings.minSpeed);

    settings.routeSpeed = 1000;
    expect(settings.routeSpeed, SimulationSettings.maxSpeed);
  });

  test('reset returns to the demo default', () {
    settings.routeSpeed = 60;
    settings.reset();
    expect(settings.routeSpeed, SimulationSettings.defaultSpeed);
  });
}
