import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/place.dart';

/// A user-facing search failure. The message is shown in the search panel.
class GeocodingException implements Exception {
  final String message;

  const GeocodingException(this.message);

  @override
  String toString() => message;
}

/// Place search behind an interface so the provider can be swapped without
/// touching the Navigation UI.
abstract class GeocodingService {
  /// Returns matches for [query], nearest to the current map area first.
  Future<List<Place>> search(String query, {int limit = 5});

  void dispose();
}

/// MapTiler Geocoding (OpenStreetMap data). Requests are metered on the
/// MapTiler key, so callers must debounce input.
class MapTilerGeocodingService implements GeocodingService {
  static const String _baseUrl = 'https://api.maptiler.com/geocoding/';
  static const int _minimumQueryLength = 3;

  final String apiKey;
  final LatLng proximity;
  final Duration timeout;
  final http.Client _client;
  final bool _ownsClient;

  MapTilerGeocodingService({
    required this.apiKey,
    this.proximity = const LatLng(44.7866, 20.4489),
    this.timeout = const Duration(seconds: 6),
    http.Client? client,
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null;

  Uri buildUri(String query, {int limit = 5}) {
    final encoded = Uri.encodeComponent(query.trim());
    return Uri.parse('$_baseUrl$encoded.json').replace(
      queryParameters: {
        'key': apiKey,
        'autocomplete': 'true',
        'limit': '$limit',
        'language': 'en',
        'proximity': '${proximity.longitude},${proximity.latitude}',
      },
    );
  }

  @override
  Future<List<Place>> search(String query, {int limit = 5}) async {
    final trimmed = query.trim();
    if (trimmed.length < _minimumQueryLength) return const [];

    try {
      final response = await _client
          .get(
            buildUri(trimmed, limit: limit),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const GeocodingException('Map key rejected');
      }
      if (response.statusCode != 200) {
        throw GeocodingException('Search unavailable (${response.statusCode})');
      }
      return parseGeocodingResponse(response.body);
    } on TimeoutException {
      throw const GeocodingException('Search timed out');
    } on GeocodingException {
      rethrow;
    } on FormatException {
      throw const GeocodingException('Unexpected search response');
    } catch (_) {
      throw const GeocodingException('Search unavailable');
    }
  }

  @override
  void dispose() {
    if (_ownsClient) _client.close();
  }
}

/// Parses a geocoding response body into places. Exposed for tests so parsing
/// can be verified without a network call.
List<Place> parseGeocodingResponse(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Unexpected geocoding response');
  }
  final features = decoded['features'];
  if (features is! List) return const [];
  return features
      .whereType<Map<String, dynamic>>()
      .map(Place.fromMapTilerFeature)
      .toList(growable: false);
}
