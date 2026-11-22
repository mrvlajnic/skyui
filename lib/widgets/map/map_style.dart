import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Basemap configuration for the map surfaces.
///
/// MapTiler supplies both the raster tiles used by `flutter_map` on Windows and
/// web and the vector style used by the MapLibre platform view on Android and
/// iOS, so both surfaces share one cartography.
///
/// The API key is injected at build time and never committed:
///
/// ```sh
/// flutter build windows --debug --dart-define=MAPTILER_KEY=your_key_here
/// ```
///
/// Desktop builds also accept a `MAPTILER_KEY` environment variable at launch,
/// so an already-built executable can be pointed at a key without rebuilding.
///
/// Without a key the map falls back to the painted fixture instead of
/// requesting tiles that would come back as an "API KEY REQUIRED" placeholder.
abstract final class MapStyle {
  static const String _compiledKey = String.fromEnvironment(
    'MAPTILER_KEY',
    defaultValue: '',
  );

  /// MapTiler style ID. `basic-v2` is the light, low-density cartography.
  static const String mapId = String.fromEnvironment(
    'MAPTILER_MAP_ID',
    defaultValue: 'basic-v2',
  );

  static const String attribution = '© MapTiler © OpenStreetMap contributors';

  static const double maxZoom = 20;
  static const int maxNativeZoom = 20;

  /// Build-time define first, then the desktop environment variable. Web
  /// builds only see the compile-time value.
  static String get apiKey {
    if (_compiledKey.isNotEmpty) return _compiledKey;
    if (kIsWeb) return '';
    return Platform.environment['MAPTILER_KEY'] ?? '';
  }

  static bool get hasApiKey => apiKey.isNotEmpty;

  static String get rasterTileUrl =>
      'https://api.maptiler.com/maps/$mapId/{z}/{x}/{y}{r}.png?key=$apiKey';

  static String get vectorStyleUrl =>
      'https://api.maptiler.com/maps/$mapId/style.json?key=$apiKey';
}
