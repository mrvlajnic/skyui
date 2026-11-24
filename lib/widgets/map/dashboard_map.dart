import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as maplibre;

import '../../services/map_view_state.dart';
import 'map_attribution.dart';
import 'map_style.dart';
import 'map_vehicle_puck.dart';
import 'route_preview_map.dart';
import 'tile_probe.dart';

/// Real map shown by the compact navigation card.
///
/// Uses the `maplibre_gl` platform view on Android and iOS, the only platforms
/// that plugin supports, and `flutter_map` with MapTiler raster tiles on
/// desktop and web. When tiles are unreachable (no API key, offline, or a
/// provider rejection) the painted
/// [RoutePreviewMap] fixture is shown so the panel never renders a broken
/// surface.
///
/// All route, position, and trip values remain simulated fixtures; no GPS,
/// map provider, or route engine is integrated.
class DashboardMap extends StatefulWidget {
  const DashboardMap({super.key});

  static const LatLng center = LatLng(44.7866, 20.4489); // Belgrade
  static const double zoom = 13;

  @override
  State<DashboardMap> createState() => _DashboardMapState();
}

class _DashboardMapState extends State<DashboardMap> {
  bool _tilesReachable = false;

  /// Mirrors the navigation screen's camera and vehicle pose.
  final MapController _mapController = MapController();
  bool _mapReady = false;

  /// `maplibre_gl` only has a native platform view on Android and iOS.
  ///
  /// Widget tests report the Android target without a registered plugin
  /// channel, and disposing that phantom view throws inside `maplibre_gl`, so
  /// the `FLUTTER_TEST` marker (set by the Flutter test runner) opts out too.
  bool get _usesMaplibre {
    if (!MapStyle.hasApiKey) return false;
    if (kIsWeb) return false;
    if (Platform.environment['FLUTTER_TEST'] == 'true') return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  void initState() {
    super.initState();
    MapViewState.instance.addListener(_onViewStateChanged);
    // Widget tests stay offline and deterministic.
    if (_usesMaplibre || const bool.fromEnvironment('FLUTTER_TEST')) return;
    _probeTileServer();
  }

  @override
  void dispose() {
    MapViewState.instance.removeListener(_onViewStateChanged);
    _mapController.dispose();
    super.dispose();
  }

  void _onViewStateChanged() {
    if (!mounted) return;
    final view = MapViewState.instance;
    if (_mapReady) {
      _mapController.move(view.center, view.zoom);
    }
    setState(() {});
  }

  /// Short reachability probe; on failure the painted fixture is used.
  Future<void> _probeTileServer() async {
    final reachable = await basemapTilesReachable();
    if (!mounted) return;
    setState(() => _tilesReachable = reachable);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: _usesMaplibre
          ? _maplibreMap()
          : _tilesReachable
          ? _tileMap(context)
          : const RoutePreviewMap(),
    );
  }

  Widget _maplibreMap() {
    return Stack(
      fit: StackFit.expand,
      children: [
        maplibre.MapLibreMap(
          styleString: MapStyle.vectorStyleUrl,
          initialCameraPosition: maplibre.CameraPosition(
            target: maplibre.LatLng(
              MapViewState.instance.center.latitude,
              MapViewState.instance.center.longitude,
            ),
            zoom: MapViewState.instance.zoom,
          ),
          // The compact card expands on tap; map gestures stay out of the way.
          dragEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          zoomGesturesEnabled: false,
          scrollGesturesEnabled: false,
          compassEnabled: false,
          myLocationEnabled: false,
          logoEnabled: false,
        ),
        const MapAttribution(
          alignment: Alignment.topRight,
          text: MapStyle.attribution,
        ),
      ],
    );
  }

  Widget _tileMap(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: MapViewState.instance.center,
        initialZoom: MapViewState.instance.zoom,
        backgroundColor: const Color(0xFFEFEEEA),
        interactionOptions:
            const InteractionOptions(flags: InteractiveFlag.none),
        onMapReady: () => _mapReady = true,
      ),
      children: [
        TileLayer(
          urlTemplate: MapStyle.rasterTileUrl,
          userAgentPackageName: 'skyui',
          maxZoom: MapStyle.maxZoom,
          retinaMode: RetinaMode.isHighDensity(context),
        ),
        const MapAttribution(
          alignment: Alignment.topRight,
          text: MapStyle.attribution,
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: MapViewState.instance.puck,
              width: 32,
              height: 32,
              child: Transform.rotate(
                angle: MapViewState.instance.heading,
                child: const MapVehiclePuck(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
