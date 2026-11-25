import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:skyui/core/app_version.dart';

void main() {
  test('the version shown in the UI matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(
      r'^version:\s*(\S+)',
      multiLine: true,
    ).firstMatch(pubspec);

    expect(match, isNotNull, reason: 'pubspec.yaml must declare a version');
    expect(AppVersion.version, match!.group(1));
  });

  test('the build stamp is never empty', () {
    expect(AppVersion.buildStamp, isNotEmpty);
    expect(AppVersion.label, contains(AppVersion.version));
  });
}
