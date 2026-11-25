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
/// Uses the `maplibre_gl` platform view on the Android/iOS compact card and
/// `flutter_map` with MapTiler raster tiles on desktop, web and the full-screen
/// navigation module. When tiles are unreachable (no API key, offline, or a
/// provider rejection) the painted [RoutePreviewMap] fixture is shown so the
/// panel never renders a broken surface.
///
/// Camera, puck and route come from [MapViewState], which the navigation screen
/// publishes. Device GPS drives the puck on Android/iOS; desktop and web use the
/// simulated drive.
class DashboardMap extends StatefulWidget {
  const DashboardMap({super.key});

  @override
  State<DashboardMap> createState() => _DashboardMapState();
}

class _DashboardMapState extends State<DashboardMap> {
  bool _tilesReachable = false;

  /// Mirrors the navigation screen's camera and vehicle pose.
  final MapController _mapController = MapController();
  bool _mapReady = false;
  LatLng? _lastCenter;
  double? _lastZoom;
  double? _lastRotation;

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
    if (!mounted || !_mapReady) return;
    final view = MapViewState.instance;

    // Camera changes are applied only when they actually changed. The puck and
    // route rebuild through their own listeners, so a per-frame puck update
    // does not rebuild the whole map.
    final center = view.center;
    final lastCenter = _lastCenter;
    if (lastCenter == null ||
        lastCenter.latitude != center.latitude ||
        lastCenter.longitude != center.longitude ||
        _lastZoom != view.zoom) {
      _lastCenter = center;
      _lastZoom = view.zoom;
      _mapController.move(center, view.zoom);
    }
    final lastRotation = _lastRotation;
    if (lastRotation == null ||
        (lastRotation - view.rotation).abs() > 0.01) {
      _lastRotation = view.rotation;
      _mapController.rotate(view.rotation);
    }
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
        initialRotation: MapViewState.instance.rotation,
        backgroundColor: const Color(0xFFEFEEEA),
        interactionOptions:
            const InteractionOptions(flags: InteractiveFlag.none),
        onMapReady: () {
          final view = MapViewState.instance;
          _lastCenter = view.center;
          _lastZoom = view.zoom;
          _lastRotation = view.rotation;
          _mapReady = true;
        },
      ),
      children: [
        TileLayer(
          urlTemplate: MapStyle.rasterTileUrl,
          userAgentPackageName: 'skyui',
          maxZoom: MapStyle.maxZoom,
          retinaMode: RetinaMode.isHighDensity(context),
          // No per-tile fade: the preview follows a moving camera every frame.
          tileDisplay: const TileDisplay.instantaneous(),
          panBuffer: 2,
        ),
        const MapAttribution(
          alignment: Alignment.topRight,
          text: MapStyle.attribution,
        ),
        ListenableBuilder(
          listenable: MapViewState.instance,
          builder: (context, _) {
            final route = MapViewState.instance.route;
            if (route.isEmpty) return const SizedBox.shrink();
            return PolylineLayer(
              polylines: [
                Polyline(
                  points: route,
                  strokeWidth: 9,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
                Polyline(
                  points: route,
                  strokeWidth: 5,
                  color: const Color(0xFFFF8A00),
                ),
              ],
            );
          },
        ),
        ListenableBuilder(
          listenable: MapViewState.instance,
          builder: (context, _) {
            final view = MapViewState.instance;
            return MarkerLayer(
              markers: [
                Marker(
                  point: view.puck,
                  width: 32,
                  height: 32,
                  child: Transform.rotate(
                    angle: view.heading,
                    child: const MapVehiclePuck(),
                  ),
                ),
                if (view.route.isNotEmpty)
                  Marker(
                    point: view.route.last,
                    width: 18,
                    height: 18,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8A00),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
