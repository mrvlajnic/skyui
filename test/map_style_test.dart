import 'dart:io' show Platform;

import 'package:flutter_test/flutter_test.dart';

import 'package:skyui/widgets/map/map_style.dart';

void main() {
  test('tests never resolve a real basemap key', () {
    // `flutter test` prints request URLs on failure, so a resolved key would
    // end up in the test log. The guard must return the painted-fixture path.
    expect(Platform.environment['FLUTTER_TEST'], 'true');
    expect(MapStyle.hasApiKey, isFalse);
    expect(MapStyle.apiKey, isEmpty);
  });
}
