import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:skyui/widgets/map/tile_probe.dart';

void main() {
  test('a 200 response means the tile host is reachable', () async {
    final client = MockClient((request) async => http.Response('', 200));

    expect(
      await probeBasemapTile('https://tiles.test/13/1/1.png', client: client),
      isTrue,
    );
  });

  test('a non-200 response means the host is not usable', () async {
    final client = MockClient((request) async => http.Response('', 403));

    expect(
      await probeBasemapTile('https://tiles.test/13/1/1.png', client: client),
      isFalse,
    );
  });

  test('a transport error falls back instead of throwing', () async {
    final client = MockClient(
      (request) async => throw http.ClientException('offline'),
    );

    expect(
      await probeBasemapTile('https://tiles.test/13/1/1.png', client: client),
      isFalse,
    );
  });

  test('a slow host times out instead of blocking the map', () async {
    // Never completes; the timeout timer is the only pending work.
    final client = MockClient(
      (request) => Completer<http.Response>().future,
    );

    expect(
      await probeBasemapTile(
        'https://tiles.test/13/1/1.png',
        client: client,
        timeout: const Duration(milliseconds: 10),
      ),
      isFalse,
    );
  });

  test('the keyless fallback probes the fallback tile host', () async {
    final client = MockClient((request) async {
      expect(request.url.host, 'server.arcgisonline.com');
      return http.Response('', 200);
    });

    expect(await basemapTilesReachable(client: client), isTrue);
  });
}
