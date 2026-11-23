import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:skyui/services/geocoding_service.dart';

void main() {
  test('parses geocoding features into places', () {
    final places = parseGeocodingResponse(
      jsonEncode({
        'features': [
          {
            'id': 'address.123',
            'text': 'Knez Mihailova',
            'place_name': 'Knez Mihailova, Belgrade, Serbia',
            'center': [20.4573, 44.8178],
          },
        ],
      }),
    );

    expect(places, hasLength(1));
    expect(places.single.id, 'address.123');
    expect(places.single.name, 'Knez Mihailova');
    expect(places.single.address, contains('Belgrade'));
    expect(places.single.coordinates.latitude, closeTo(44.8178, 1e-6));
    expect(places.single.coordinates.longitude, closeTo(20.4573, 1e-6));
  });

  test('builds a keyed, proximity-biased request', () {
    final service = MapTilerGeocodingService(apiKey: 'test-key');
    final uri = service.buildUri('Knez Mihailova');

    expect(uri.path, contains('Knez%20Mihailova.json'));
    expect(uri.queryParameters['key'], 'test-key');
    expect(uri.queryParameters['proximity'], '20.4489,44.7866');
    expect(uri.queryParameters['autocomplete'], 'true');
    expect(uri.queryParameters['limit'], '5');

    service.dispose();
  });

  test('skips the request for short queries', () async {
    var calls = 0;
    final service = MapTilerGeocodingService(
      apiKey: 'test-key',
      client: MockClient((request) async {
        calls++;
        return http.Response('{"features": []}', 200);
      }),
    );

    expect(await service.search('ab'), isEmpty);
    expect(calls, 0);

    service.dispose();
  });

  test('maps a rejected key to a readable error', () async {
    final service = MapTilerGeocodingService(
      apiKey: 'test-key',
      client: MockClient((request) async => http.Response('{}', 403)),
    );

    await expectLater(
      service.search('Belgrade'),
      throwsA(
        isA<GeocodingException>().having(
          (error) => error.message,
          'message',
          contains('key'),
        ),
      ),
    );

    service.dispose();
  });

  test('surfaces non-200 responses', () async {
    final service = MapTilerGeocodingService(
      apiKey: 'test-key',
      client: MockClient((request) async => http.Response('{}', 500)),
    );

    await expectLater(
      service.search('Belgrade'),
      throwsA(
        isA<GeocodingException>().having(
          (error) => error.message,
          'message',
          contains('500'),
        ),
      ),
    );

    service.dispose();
  });
}
