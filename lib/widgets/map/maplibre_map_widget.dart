import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// A compact MapLibre map widget for embedding in the home dashboard.
/// Uses free MapLibre demo tiles with a dark automotive style.
class VeltronMapWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final LatLng initialCenter;
  final double initialZoom;
  final bool showUserLocation;
  final VoidCallback? onMapTap;

  const VeltronMapWidget({
    super.key,
    this.width,
    this.height,
    this.initialCenter = const LatLng(44.7866, 20.4489), // Belgrade
    this.initialZoom = 13.0,
    this.showUserLocation = true,
    this.onMapTap,
  });

  @override
  State<VeltronMapWidget> createState() => _VeltronMapWidgetState();
}

class _VeltronMapWidgetState extends State<VeltronMapWidget> {
  MapLibreMapController? _controller;
  bool _styleLoaded = false;

  static const String _styleUrl = 'https://demotiles.maplibre.org/style.json';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: MapLibreMap(
          initialCameraPosition: CameraPosition(
            target: widget.initialCenter,
            zoom: widget.initialZoom,
          ),
          styleString: _styleUrl,
          onMapCreated: _onMapCreated,
          onStyleLoadedCallback: _onStyleLoaded,
          myLocationEnabled: widget.showUserLocation,
          myLocationTrackingMode: MyLocationTrackingMode.tracking,
          compassEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
        ),
      ),
    );
  }

  void _onMapCreated(MapLibreMapController controller) {
    _controller = controller;
  }

  void _onStyleLoaded() {
    _styleLoaded = true;
    _addRouteLayer();
  }

  Future<void> _addRouteLayer() async {
    if (_controller == null || !_styleLoaded) return;

    // Add a GeoJSON source for the route
    await _controller!.addGeoJsonSource(
      'route',
      {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'properties': {},
            'geometry': {
              'type': 'LineString',
              'coordinates': [
                [20.4489, 44.7866],
                [20.4612, 44.8125],
              ],
            },
          },
        ],
      },
    );

    // Add a line layer for the route
    await _controller!.addLineLayer(
      'route',
      'route-layer',
      LineLayerProperties(
        lineColor: '#FF8A00',
        lineWidth: 4.0,
        lineCap: 'round',
        lineJoin: 'round',
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

/// A simpler static map image widget for even lighter embedding
/// (fallback when MapLibre isn't needed)
class StaticMapWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final LatLng center;
  final int zoom;

  const StaticMapWidget({
    super.key,
    this.width,
    this.height,
    this.center = const LatLng(44.7866, 20.4489),
    this.zoom = 13,
  });

  @override
  Widget build(BuildContext context) {
    // Using static map image from OSM as ultra-light fallback
    final url = 'https://staticmap.openstreetmap.de/staticmap.php'
        '?center=${center.latitude},${center.longitude}'
        '&zoom=$zoom'
        '&size=${(width ?? 400).round()}x${(height ?? 300).round()}'
        '&markers=${center.latitude},${center.longitude},red-pushpin';

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: const Color(0xFF090B12),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF8A00),
                  strokeWidth: 2,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFF090B12),
            child: const Center(
              child: Icon(Icons.map_outlined, color: Colors.white38, size: 48),
            ),
          ),
        ),
      ),
    );
  }
}