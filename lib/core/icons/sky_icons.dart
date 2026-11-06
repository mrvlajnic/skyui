import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'sky_icon.dart';

class SkyIcons {
  SkyIcons._();

  /// Recreated 1:1 from `assets/icons/home.svg`: rounded-stroke outline
  /// house with a soft apex and a bottom-center door notch.
  static const SkyIconData home = SkyIconData.svg(_homePath);

  /// Recreated 1:1 from `assets/icons/navigation.svg`: tilted paper plane
  /// with a spine fold.
  static const SkyIconData navigation = SkyIconData.svg(_navigationPath);

  /// Recreated 1:1 from `assets/icons/music.svg`: beamed eighth-note pair.
  static const SkyIconData music = SkyIconData.svg(_musicPath);

  /// Recreated 1:1 from `assets/icons/phone.svg`: handset outline.
  static const SkyIconData phone = SkyIconData.svg(_phonePath);

  /// Recreated 1:1 from `assets/icons/vehicle.svg`: front-view car.
  static const SkyIconData vehicle = SkyIconData.svg(_vehiclePath);

  /// Recreated 1:1 from `assets/icons/settings.svg`: 8-tooth gear with a
  /// tooth centered at 12 o'clock.
  static const SkyIconData settings = SkyIconData.svg(_settingsPath);
}

void _homePath(Path path) {
  // House silhouette: roof from eave to apex to eave, walls down to a
  // rounded-corner floor that stays open where the door connects.
  path.moveTo(4.5, 10.5);
  path.lineTo(12, 3.9);
  path.lineTo(19.5, 10.5);
  path.lineTo(19.5, 18.5);
  path.arcToPoint(
    const Offset(17.5, 20.5),
    radius: const Radius.circular(2),
    clockwise: true,
  );
  path.lineTo(6.5, 20.5);
  path.arcToPoint(
    const Offset(4.5, 18.5),
    radius: const Radius.circular(2),
    clockwise: true,
  );
  path.close();

  // Door: rounded-top notch rising from the bottom edge, drawn as a second
  // sub-path so its strokes meet the floor cleanly.
  final door = Path()
    ..moveTo(9.5, 20.5)
    ..lineTo(9.5, 15.4)
    ..arcToPoint(
      const Offset(10.9, 14),
      radius: const Radius.circular(1.4),
      clockwise: true,
    )
    ..lineTo(13.1, 14)
    ..arcToPoint(
      const Offset(14.5, 15.4),
      radius: const Radius.circular(1.4),
      clockwise: true,
    )
    ..lineTo(14.5, 20.5);
  path.addPath(door, Offset.zero);
}

void _navigationPath(Path path) {
  // Tilted paper plane: tip up-right, swept wings meeting at a notch, plus
  // the spine fold from the tip to the notch.
  path.moveTo(20.4, 3.6);
  path.lineTo(3.6, 9.8);
  path.lineTo(10.2, 14.2);
  path.lineTo(14.2, 20.4);
  path.close();
  path.moveTo(20.4, 3.6);
  path.lineTo(10.2, 14.2);
}

void _musicPath(Path path) {
  // Beamed eighth-note pair: two stems, a slightly tilted beam connecting
  // their tops, and two open heads under the stems.
  path.moveTo(7.9, 4);
  path.lineTo(7.9, 15.8);
  path.moveTo(17.9, 5);
  path.lineTo(17.9, 16.8);
  path.moveTo(7.9, 4);
  path.lineTo(17.9, 5);
  path.addOval(const Rect.fromLTWH(3.65, 15.4, 4.4, 3.9));
  path.addOval(const Rect.fromLTWH(13.65, 16.4, 4.4, 3.9));
}

void _phonePath(Path path) {
  // Handset outline (24x24 stroke-icon geometry, scaled 0.85 about the
  // center so it sits comfortably inside the viewBox).
  path.moveTo(20.5, 16.18);
  path.lineTo(20.5, 18.73);
  path.arcToPoint(
    const Offset(18.65, 20.43),
    radius: const Radius.elliptical(1.7, 1.7),
    clockwise: true,
  );
  path.arcToPoint(
    const Offset(11.31, 17.82),
    radius: const Radius.elliptical(16.82, 16.82),
    clockwise: true,
  );
  path.arcToPoint(
    const Offset(6.21, 12.72),
    radius: const Radius.elliptical(16.58, 16.58),
    clockwise: true,
  );
  path.arcToPoint(
    const Offset(3.6, 5.35),
    radius: const Radius.elliptical(16.82, 16.82),
    clockwise: true,
  );
  path.arcToPoint(
    const Offset(5.29, 3.5),
    radius: const Radius.elliptical(1.7, 1.7),
    clockwise: true,
  );
  path.lineTo(7.84, 3.5);
  path.arcToPoint(
    const Offset(9.54, 4.96),
    radius: const Radius.elliptical(1.7, 1.7),
    clockwise: true,
  );
  path.arcToPoint(
    const Offset(10.14, 7.35),
    radius: const Radius.elliptical(10.91, 10.91),
    clockwise: false,
  );
  path.arcToPoint(
    const Offset(9.76, 9.14),
    radius: const Radius.elliptical(1.7, 1.7),
    clockwise: true,
  );
  path.lineTo(8.68, 10.22);
  path.arcToPoint(
    const Offset(13.78, 15.32),
    radius: const Radius.elliptical(13.6, 13.6),
    clockwise: false,
  );
  path.lineTo(14.86, 14.24);
  path.arcToPoint(
    const Offset(16.65, 13.86),
    radius: const Radius.elliptical(1.7, 1.7),
    clockwise: true,
  );
  path.arcToPoint(
    const Offset(19.04, 14.46),
    radius: const Radius.elliptical(10.91, 10.91),
    clockwise: false,
  );
  path.arcToPoint(
    const Offset(20.5, 16.18),
    radius: const Radius.elliptical(1.7, 1.7),
    clockwise: true,
  );
  path.close();
}

void _vehiclePath(Path path) {
  // Front-view car: rounded-roof body with a windshield line, headlights
  // inside, wheels tucked under the floor.
  path.moveTo(7.9, 9.6);
  path.lineTo(16.1, 9.6);
  path.arcToPoint(
    const Offset(19.6, 13.1),
    radius: const Radius.circular(3.5),
    clockwise: true,
  );
  path.lineTo(19.6, 18.8);
  path.arcToPoint(
    const Offset(18.4, 20),
    radius: const Radius.circular(1.2),
    clockwise: true,
  );
  path.lineTo(5.6, 20);
  path.arcToPoint(
    const Offset(4.4, 18.8),
    radius: const Radius.circular(1.2),
    clockwise: true,
  );
  path.lineTo(4.4, 13.1);
  path.arcToPoint(
    const Offset(7.9, 9.6),
    radius: const Radius.circular(3.5),
    clockwise: true,
  );
  path.close();
  path.moveTo(6, 13.6);
  path.lineTo(18, 13.6);
  path.moveTo(6.6, 16.6);
  path.lineTo(8.6, 16.6);
  path.moveTo(15.4, 16.6);
  path.lineTo(17.4, 16.6);
  path.addRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(6.2, 19.55, 2.6, 1.9),
      const Radius.circular(0.8),
    ),
  );
  path.addRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(15.2, 19.55, 2.6, 1.9),
      const Radius.circular(0.8),
    ),
  );
}

void _settingsPath(Path path) {
  // Gear: 8 teeth on radii 7.7/10 around (12,12), one tooth centered at
  // 12 o'clock, plus the hub circle. Same math as assets/icons/settings.svg.
  const teeth = 8;
  const valleyRadius = 7.7;
  const peakRadius = 10.0;
  const toothSpan = 12 * math.pi / 180;
  const peakSpan = 7 * math.pi / 180;
  const step = 2 * math.pi / teeth;

  var started = false;
  for (var k = 0; k < teeth; k++) {
    final base = -math.pi / 2 + k * step;
    final points = <(double, double)>[
      (valleyRadius, base - toothSpan),
      (peakRadius, base - peakSpan),
      (peakRadius, base + peakSpan),
      (valleyRadius, base + toothSpan),
    ];
    for (final (radius, angle) in points) {
      final x = 12.0 + radius * math.cos(angle);
      final y = 12.0 + radius * math.sin(angle);
      if (started) {
        path.lineTo(x, y);
      } else {
        path.moveTo(x, y);
        started = true;
      }
    }
  }
  path.close();
  path.addOval(const Rect.fromLTRB(12 - 3.4, 12 - 3.4, 12 + 3.4, 12 + 3.4));
}
