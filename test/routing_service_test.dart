import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';
import 'package:skyui/services/routing_service.dart';

void main() {
  Map<String, dynamic> routeFixture() => {
    'route': {
      'summary': {'totalLength': 1.24, 'totalTime': 312.5},
      'legs': [
        {
          'geometry': [
            [20.4489, 44.7866],
            [20.4521, 44.7902],
            [20.4573, 44.8178],
          ],
          'steps': [
            {
              'time': 120.0,
              'length': 0.6,
              'streetName': 'Bulevar kralja Aleksandra',
              'maneuver': {
                'instruction': 'Drive north on Bulevar kralja Aleksandra.',
                'type': 'start',
              },
              'beginIndex': 0,
              'endIndex': 1,
            },
            {
              'time': 192.5,
              'length': 0.64,
              'streetName': 'Knez Mihailova',
              'maneuver': {
                'instruction': 'Turn right onto Knez Mihailova.',
                'turnAngle': 88,
                'type': 'rightTurn',
              },
              'beginIndex': 1,
              'endIndex': 2,
            },
          ],
        },
      ],
    },
  };

  test('parses route geometry, summary and instructions', () {
    final plan = parseRouteResponse(jsonEncode(routeFixture()));

    expect(plan.geometry, hasLength(3));
    expect(plan.geometry.first.latitude, closeTo(44.7866, 1e-6));
    expect(plan.geometry.first.longitude, closeTo(20.4489, 1e-6));
    expect(plan.distanceKm, closeTo(1.24, 1e-6));
    expect(plan.durationSeconds, closeTo(312.5, 1e-6));
    expect(plan.steps, hasLength(2));
    expect(plan.steps.first.instruction, contains('north'));
    expect(plan.steps.last.maneuverType, 'rightTurn');
    expect(plan.steps.last.endIndex, 2);
  });

  test('decodes an encoded polyline geometry', () {
    String encodePolyline(List<LatLng> points, {int precision = 6}) {
      final factor = precision == 6 ? 1000000 : 100000;
      String encodeValue(int value) {
        var shifted = value < 0 ? ~(value << 1) : (value << 1);
        final buffer = StringBuffer();
        while (shifted >= 0x20) {
          buffer.writeCharCode((0x20 | (shifted & 0x1f)) + 63);
          shifted >>= 5;
        }
        buffer.writeCharCode(shifted + 63);
        return buffer.toString();
      }

      var lastLatitude = 0;
      var lastLongitude = 0;
      final buffer = StringBuffer();
      for (final point in points) {
        final latitude = (point.latitude * factor).round();
        final longitude = (point.longitude * factor).round();
        buffer.write(encodeValue(latitude - lastLatitude));
        buffer.write(encodeValue(longitude - lastLongitude));
        lastLatitude = latitude;
        lastLongitude = longitude;
      }
      return buffer.toString();
    }

    final encoded = encodePolyline(const [
      LatLng(44.786457, 20.448654),
      LatLng(44.790000, 20.452000),
    ]);

    final plan = parseRouteResponse(
      jsonEncode({
        'route': {
          'summary': {'totalLength': 0.8, 'totalTime': 120.0},
          'legs': [
            {'geometry': encoded, 'steps': <Map<String, dynamic>>[]},
          ],
        },
      }),
    );

    expect(plan.geometry, hasLength(2));
    expect(plan.geometry.first.latitude, closeTo(44.786457, 1e-5));
    expect(plan.geometry.first.longitude, closeTo(20.448654, 1e-5));
    expect(plan.geometry.last.latitude, closeTo(44.79, 1e-5));
  });

  test('builds a keyed driving request with instructions', () {
    final service = MapTilerRoutingService(apiKey: 'test-key');
    final uri = service.buildUri(
      const LatLng(44.7866, 20.4489),
      const LatLng(44.8178, 20.4573),
    );

    expect(uri.path, '/routing/v1/directions');
    expect(uri.queryParametersAll['location'], [
      '20.4489,44.7866',
      '20.4573,44.8178',
    ]);
    expect(uri.queryParameters['profile'], 'car');
    expect(uri.queryParameters['response.units'], 'km');
    expect(
      uri.queryParameters['response.additionalData.detailLevel'],
      'instructions',
    );
    expect(uri.queryParameters['key'], 'test-key');

    service.dispose();
  });

  test('maps a rejected key to a readable error', () async {
    final service = MapTilerRoutingService(
      apiKey: 'test-key',
      client: MockClient((request) async => http.Response('{}', 403)),
    );

    await expectLater(
      service.route(
        const LatLng(44.7866, 20.4489),
        const LatLng(44.8178, 20.4573),
      ),
      throwsA(
        isA<RoutingException>().having(
          (error) => error.message,
          'message',
          contains('key'),
        ),
      ),
    );

    service.dispose();
  });

  test('rejects a response without a route', () async {
    final service = MapTilerRoutingService(
      apiKey: 'test-key',
      client: MockClient((request) async => http.Response('{"route":{}}', 200)),
    );

    await expectLater(
      service.route(
        const LatLng(44.7866, 20.4489),
        const LatLng(44.8178, 20.4573),
      ),
      throwsA(isA<RoutingException>()),
    );

    service.dispose();
  });
}
