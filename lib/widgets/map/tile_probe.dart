import 'dart:io';

import 'map_style.dart';

/// Checks whether the basemap host serves real tiles.
///
/// Used to choose the painted fallback instead of a blank map when the host is
/// unreachable at runtime (offline, or a web security policy that blocks the
/// imagery). Without an API key this is `false` up front, because an
/// unauthenticated request would return a placeholder tile with an
/// "API KEY REQUIRED" watermark rather than a usable map.
Future<bool> basemapTilesReachable() async {
  if (!MapStyle.hasApiKey) return false;

  final url = MapStyle.rasterTileUrl
      .replaceFirst('{z}', '13')
      .replaceFirst('{x}', '4558')
      .replaceFirst('{y}', '2952')
      .replaceFirst('{r}', '');
  try {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
    final request = await client.openUrl('GET', Uri.parse(url));
    final response = await request.close();
    await response.drain();
    return response.statusCode == 200;
  } catch (_) {
    return false;
  }
}
