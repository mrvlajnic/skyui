import 'package:flutter/foundation.dart';

/// Demo-only playback settings for the navigation simulation.
///
/// This is not a product setting: the real navigation would follow the vehicle
/// at 1×. It exists so the prototype can be demonstrated in a reasonable time —
/// a 15-minute route can play in 15 seconds or in real time.
class SimulationSettings extends ChangeNotifier {
  SimulationSettings._();

  static final SimulationSettings instance = SimulationSettings._();

  static const double realTimeSpeed = 1;
  static const double defaultSpeed = 20;
  static const double minSpeed = 1;
  static const double maxSpeed = 120;

  double _routeSpeed = defaultSpeed;

  /// Playback multiplier of real time. `1` is real time, `20` plays twenty
  /// times faster, and so on.
  double get routeSpeed => _routeSpeed;

  set routeSpeed(double value) {
    final next = value.clamp(minSpeed, maxSpeed).toDouble();
    if (next == _routeSpeed) return;
    _routeSpeed = next;
    notifyListeners();
  }

  bool get isRealTime => (_routeSpeed - realTimeSpeed).abs() < 0.001;

  /// How long a trip with [realDuration] takes at the current speed.
  Duration playbackDuration(Duration realDuration) {
    if (realDuration <= Duration.zero) return Duration.zero;
    return Duration(
      microseconds: (realDuration.inMicroseconds / _routeSpeed).round(),
    );
  }

  void reset() => routeSpeed = defaultSpeed;
}
