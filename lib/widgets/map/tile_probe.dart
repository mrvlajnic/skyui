import 'package:http/http.dart' as http;

import 'map_style.dart';

/// Checks whether the basemap host serves real tiles.
///
/// Used to choose the painted fallback instead of a blank map when the host is
/// unreachable at runtime (offline, or a web security policy that blocks the
/// imagery). Without an API key this is `false` up front, because an
/// unauthenticated request would return a placeholder tile with an
/// "API KEY REQUIRED" watermark rather than a usable map.
///
/// The probe uses `package:http` rather than `dart:io`, so it works in the
/// browser as well: `HttpClient` is not available on the web target and would
/// silently force the painted fixture on every web build.
Future<bool> basemapTilesReachable({http.Client? client}) async {
  if (!MapStyle.hasApiKey) return false;

  final url = MapStyle.rasterTileUrl
      .replaceFirst('{z}', '13')
      .replaceFirst('{x}', '4558')
      .replaceFirst('{y}', '2952')
      .replaceFirst('{r}', '');
  return probeBasemapTile(url, client: client);
}

/// Probes a concrete tile URL and reports whether the host answered `200`.
///
/// Kept separate from [basemapTilesReachable] so the HTTP behaviour can be
/// tested without a provider key: tests pass an explicit URL and a mock
/// client.
Future<bool> probeBasemapTile(
  String url, {
  http.Client? client,
  Duration timeout = const Duration(seconds: 3),
}) async {
  final ownedClient = client == null;
  final httpClient = client ?? http.Client();
  try {
    final response = await httpClient.get(Uri.parse(url)).timeout(timeout);
    return response.statusCode == 200;
  } catch (_) {
    return false;
  } finally {
    if (ownedClient) httpClient.close();
  }
}
