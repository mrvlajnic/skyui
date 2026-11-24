import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

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

  LatLng get center => _center;
  double get zoom => _zoom;

  /// Map rotation in degrees, clockwise. Non-zero in heading-up chase mode.
  double get rotation => _rotation;
  LatLng get puck => _puck;
  double get heading => _heading;

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

  void reset() {
    final alreadyDefault = _samePoint(_center, defaultCenter) &&
        _zoom == defaultZoom &&
        _rotation == 0 &&
        _samePoint(_puck, defaultCenter) &&
        _heading == 0;
    if (alreadyDefault) return;
    _center = defaultCenter;
    _zoom = defaultZoom;
    _rotation = 0;
    _puck = defaultCenter;
    _heading = 0;
    notifyListeners();
  }

  static bool _samePoint(LatLng a, LatLng b) =>
      a.latitude == b.latitude && a.longitude == b.longitude;
}
