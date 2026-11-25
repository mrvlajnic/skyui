import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

/// Text shown by the compact route card on the home screen.
///
/// The navigation screen is the writer; the card is a read-only mirror, so the
/// two can never disagree about destination, instruction, remaining time or
/// arrival state.
class RouteSummary {
  final String destination;
  final String instruction;
  final String remaining;
  final String upcoming;
  final String trip;
  final bool arrived;

  const RouteSummary({
    required this.destination,
    required this.instruction,
    required this.remaining,
    required this.upcoming,
    required this.trip,
    this.arrived = false,
  });

  @override
  bool operator ==(Object other) =>
      other is RouteSummary &&
      other.destination == destination &&
      other.instruction == instruction &&
      other.remaining == remaining &&
      other.upcoming == upcoming &&
      other.trip == trip &&
      other.arrived == arrived;

  @override
  int get hashCode => Object.hash(
    destination,
    instruction,
    remaining,
    upcoming,
    trip,
    arrived,
  );
}

/// Camera and vehicle pose shared by the compact home map and the full-screen
/// navigation map.
///
/// The home card is a preview and cannot be panned, so the navigation screen is
/// the writer and the home card is the reader. When navigation moves, zooms or
/// follows the vehicle, the card behind it shows the same view; when the
/// navigation screen is opened again it resumes where it was left.
class MapViewState extends ChangeNotifier {
  MapViewState._();

  static final MapViewState instance = MapViewState._();

  static const LatLng defaultCenter = LatLng(44.7866, 20.4489); // Belgrade
  static const double defaultZoom = 13;

  LatLng _center = defaultCenter;
  double _zoom = defaultZoom;
  double _rotation = 0;
  LatLng _puck = defaultCenter;
  double _heading = 0;
  List<LatLng> _route = const [];
  RouteSummary? _summary;

  /// Separate from the map notifier: summary text changes a few times a second,
  /// while the puck publishes every frame. The compact card listens here so it
  /// does not rebuild 60 times a second.
  final ValueNotifier<RouteSummary?> summaryListenable =
      ValueNotifier<RouteSummary?>(null);

  LatLng get center => _center;
  double get zoom => _zoom;

  /// Map rotation in degrees, clockwise. Non-zero in heading-up chase mode.
  double get rotation => _rotation;
  LatLng get puck => _puck;
  double get heading => _heading;

  /// Route geometry shared with the home card. Empty when no trip is planned.
  List<LatLng> get route => _route;

  /// Compact route text. Null until the navigation screen has published one.
  RouteSummary? get summary => _summary;

  void updateCamera({
    required LatLng center,
    required double zoom,
    double? rotation,
  }) {
    final nextRotation = rotation ?? _rotation;
    if (_samePoint(center, _center) &&
        (zoom - _zoom).abs() < 0.0001 &&
        (nextRotation - _rotation).abs() < 0.0001) {
      return;
    }
    _center = center;
    _zoom = zoom;
    _rotation = nextRotation;
    notifyListeners();
  }

  void updatePuck({required LatLng position, required double heading}) {
    if (_samePoint(position, _puck) &&
        (heading - _heading).abs() < 0.0001) {
      return;
    }
    _puck = position;
    _heading = heading;
    notifyListeners();
  }

  void updateRoute(List<LatLng> route) {
    if (_sameRoute(route, _route)) return;
    _route = List<LatLng>.unmodifiable(route);
    notifyListeners();
  }

  void updateSummary(RouteSummary? summary) {
    if (summary == _summary) return;
    _summary = summary;
    summaryListenable.value = summary;
  }

  void reset() {
    final alreadyDefault = _samePoint(_center, defaultCenter) &&
        _zoom == defaultZoom &&
        _rotation == 0 &&
        _samePoint(_puck, defaultCenter) &&
        _heading == 0 &&
        _route.isEmpty &&
        _summary == null;
    if (alreadyDefault) return;
    _center = defaultCenter;
    _zoom = defaultZoom;
    _rotation = 0;
    _puck = defaultCenter;
    _heading = 0;
    _route = const [];
    _summary = null;
    summaryListenable.value = null;
    notifyListeners();
  }

  static bool _samePoint(LatLng a, LatLng b) =>
      a.latitude == b.latitude && a.longitude == b.longitude;

  static bool _sameRoute(List<LatLng> a, List<LatLng> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_samePoint(a[i], b[i])) return false;
    }
    return true;
  }
}
