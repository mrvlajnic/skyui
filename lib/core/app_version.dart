import 'dart:io' show File, Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Version and build stamp shown in the boot screen and Settings.
///
/// [version] must stay identical to the `version:` field in `pubspec.yaml`.
/// `test/app_version_test.dart` compares the two so a release cannot drift from
/// what the UI reports.
abstract final class AppVersion {
  AppVersion._();

  static const String version = '0.3.0-alpha+1';

  /// Timestamp of the running executable, so it is obvious whether the app in
  /// front of you is the build that was just produced. On the web there is no
  /// executable to inspect, so only the version is shown.
  static String get buildStamp {
    if (kIsWeb) return 'web build';
    try {
      final modified = File(Platform.resolvedExecutable).lastModifiedSync();
      return '${modified.year}-${_two(modified.month)}-${_two(modified.day)} '
          '${_two(modified.hour)}:${_two(modified.minute)}';
    } catch (_) {
      return 'unknown build';
    }
  }

  static String get label => 'v$version · build $buildStamp';

  static String _two(int value) => value.toString().padLeft(2, '0');
}
