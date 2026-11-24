import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/route_plan.dart';

/// A user-facing routing failure. The message is shown in the Navigation HUD.
class RoutingException implements Exception {
  final String message;

  const RoutingException(this.message);

  @override
  String toString() => message;
}

/// Route calculation behind an interface so the provider can be swapped.
abstract class RoutingService {
  /// Calculates a driving route between two coordinates.
  Future<RoutePlan> route(LatLng start, LatLng destination);

  void dispose();
}

/// MapTiler Routing API (driving profile). Requests are metered on the key.
class MapTilerRoutingService implements RoutingService {
  static const String _baseUrl =
      'https://api.maptiler.com/routing/v1/directions';

  final String apiKey;
  final String profile;
  final Duration timeout;
  final http.Client _client;
  final bool _ownsClient;

  MapTilerRoutingService({
    required this.apiKey,
    this.profile = 'car',
    this.timeout = const Duration(seconds: 8),
    http.Client? client,
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null;

  Uri buildUri(LatLng start, LatLng destination) {
    return Uri.parse(_baseUrl).replace(
      queryParameters: {
        'location': [
          '${start.longitude},${start.latitude}',
          '${destination.longitude},${destination.latitude}',
        ],
        'profile': profile,
        'response.units': 'km',
        'response.language': 'en',
        'response.additionalData.detailLevel': 'instructions',
        'key': apiKey,
      },
    );
  }

  @override
  Future<RoutePlan> route(LatLng start, LatLng destination) async {
    try {
      final response = await _client
          .get(
            buildUri(start, destination),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const RoutingException('Map key rejected');
      }
      if (response.statusCode != 200) {
        throw RoutingException('Routing unavailable (${response.statusCode})');
      }
      return parseRouteResponse(response.body);
    } on TimeoutException {
      throw const RoutingException('Routing timed out');
    } on RoutingException {
      rethrow;
    } on FormatException {
      throw const RoutingException('Unexpected routing response');
    } catch (_) {
      throw const RoutingException('Routing unavailable');
    }
  }

  @override
  void dispose() {
    if (_ownsClient) _client.close();
  }
}

/// Parses a routing response body into a [RoutePlan]. Exposed for tests.
RoutePlan parseRouteResponse(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Unexpected routing response');
  }
  final route = decoded['route'];
  if (route is! Map<String, dynamic>) {
    throw const FormatException('Routing response has no route');
  }
  return RoutePlan.fromMapTilerRoute(route);
}
