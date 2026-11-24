import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:skyui/services/map_view_state.dart';

void main() {
  final view = MapViewState.instance;
  setUp(view.reset);
  tearDown(view.reset);

  test('starts at the Belgrade default', () {
    expect(view.center, MapViewState.defaultCenter);
    expect(view.zoom, MapViewState.defaultZoom);
    expect(view.puck, MapViewState.defaultCenter);
  });

  test('camera updates notify and keep the latest values', () {
    var notifications = 0;
    void listener() => notifications++;
    view.addListener(listener);
    addTearDown(() => view.removeListener(listener));

    const center = LatLng(44.8, 20.5);
    view.updateCamera(center: center, zoom: 15);
    expect(view.center, center);
    expect(view.zoom, 15);
    expect(notifications, 1);

    // Identical values are not a change.
    view.updateCamera(center: center, zoom: 15);
    expect(notifications, 1);
  });

  test('camera rotation is shared and kept when omitted', () {
    view.updateCamera(
      center: MapViewState.defaultCenter,
      zoom: 15,
      rotation: -45,
    );
    expect(view.rotation, -45);

    view.updateCamera(center: MapViewState.defaultCenter, zoom: 15);
    expect(view.rotation, -45);
  });

  test('the puck and heading update independently of the camera', () {
    var notifications = 0;
    void listener() => notifications++;
    view.addListener(listener);
    addTearDown(() => view.removeListener(listener));

    const puck = LatLng(44.81, 20.46);
    view.updatePuck(position: puck, heading: 1.2);
    expect(view.puck, puck);
    expect(view.heading, 1.2);
    expect(view.center, MapViewState.defaultCenter);
    expect(notifications, 1);
  });

  test('reset returns the shared view to the default', () {
    view.updateCamera(center: const LatLng(45, 21), zoom: 16);
    view.updatePuck(position: const LatLng(45, 21), heading: 2);

    view.reset();

    expect(view.center, MapViewState.defaultCenter);
    expect(view.zoom, MapViewState.defaultZoom);
    expect(view.puck, MapViewState.defaultCenter);
    expect(view.heading, 0);
  });
}
