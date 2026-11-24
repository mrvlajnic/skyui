import 'dart:io' show Directory, File, Platform;

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

  /// Build-time define first, then the desktop environment variable, then a
  /// local key file. Web builds only see the compile-time value.
  static String get apiKey {
    final cached = _resolvedKey;
    if (cached != null) return cached;
    final resolved = _resolveApiKey();
    _resolvedKey = resolved;
    return resolved;
  }

  static String? _resolvedKey;

  static String _resolveApiKey() {
    // `flutter test` prints failing request URLs, including the `key` query
    // parameter. Never resolve a real provider key in that environment; the
    // painted fixture is the correct map for tests anyway.
    if (!kIsWeb && Platform.environment['FLUTTER_TEST'] == 'true') return '';
    if (_compiledKey.isNotEmpty) return _compiledKey;
    if (kIsWeb) return '';
    final fromEnvironment = Platform.environment['MAPTILER_KEY'];
    if (fromEnvironment != null && fromEnvironment.trim().isNotEmpty) {
      return fromEnvironment.trim();
    }
    return _readKeyFile();
  }

  /// Reads a git-ignored key file so `flutter run` and IDE builds do not need
  /// the `--dart-define` flag. Searches upward from the working directory and
  /// from the executable, which covers both `flutter run` (project root) and a
  /// debug build launched from `build/windows/.../Debug`.
  static String _readKeyFile() {
    const fileNames = ['maptiler_key.txt', '.maptiler_key'];
    final starts = <String>{
      Directory.current.path,
      File(Platform.resolvedExecutable).parent.path,
    };
    for (final name in fileNames) {
      for (final start in starts) {
        var directory = Directory(start);
        for (var depth = 0; depth < 6; depth++) {
          final file = File('${directory.path}${Platform.pathSeparator}$name');
          if (file.existsSync()) {
            final value = file.readAsStringSync().trim();
            if (value.isNotEmpty) return value;
          }
          final parent = directory.parent;
          if (parent.path == directory.path) break;
          directory = parent;
        }
      }
    }
    return '';
  }

  static bool get hasApiKey => apiKey.isNotEmpty;

  static String get rasterTileUrl =>
      'https://api.maptiler.com/maps/$mapId/{z}/{x}/{y}{r}.png?key=$apiKey';

  static String get vectorStyleUrl =>
      'https://api.maptiler.com/maps/$mapId/style.json?key=$apiKey';
}
