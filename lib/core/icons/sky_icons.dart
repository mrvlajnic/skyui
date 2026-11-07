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

  /// Converted 1:1 from the user-supplied filled heated-seat glyph
  /// (`assets/icons/heated_seat.svg`): filled side-profile seat with
  /// heat waves and detail contours.
  static const SkyIconData heatedSeat = SkyIconData.svg(
    _heatedSeatPath,
    filled: true,
  );

  /// Converted 1:1 from the user-supplied filled-outline house glyph
  /// (`assets/icons/house.svg`): house outline with eaves and a bottom-
  /// center door notch; the interior is punched by the source second
  /// path (opposite winding, supported by the painter's nonzero fill).
  static const SkyIconData house = SkyIconData.svg(_housePath, filled: true);
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

/// Filled heated-seat glyph geometry, converted 1:1 from the user-supplied
/// symbol source (151x140 viewBox, background-cell rect dropped; six closed
/// sub-paths). Same coordinates as assets/icons/heated_seat.svg.
/// Filled heated-seat glyph geometry, converted 1:1 from the user-supplied
/// symbol source (151x140 viewBox, background-cell rect dropped; six closed
/// sub-paths). Same coordinates as assets/icons/heated_seat.svg.
void _heatedSeatPath(Path path) {
  path.moveTo(21.47, 1.79);
  path.cubicTo(22.40, 2.44, 22.40, 2.55, 21.22, 7.60);
  path.cubicTo(20.68, 9.86, 20.13, 12.35, 19.42, 15.73);
  path.cubicTo(18.73, 19.02, 18.18, 20.02, 16.64, 20.72);
  path.cubicTo(15.96, 21.05, 15.32, 21.18, 14.52, 21.18);
  path.cubicTo(13.37, 21.18, 13.35, 21.18, 13.18, 21.80);
  path.cubicTo(13.03, 22.29, 12.90, 22.43, 12.51, 22.43);
  path.cubicTo(12.09, 22.43, 12.03, 22.35, 12.09, 21.80);
  path.lineTo(12.15, 21.16);
  path.lineTo(10.96, 21.22);
  path.cubicTo(9.78, 21.28, 9.76, 21.30, 9.61, 21.91);
  path.cubicTo(9.45, 22.46, 9.36, 22.54, 8.92, 22.48);
  path.cubicTo(8.40, 22.43, 8.32, 22.20, 8.59, 21.51);
  path.cubicTo(8.71, 21.22, 8.59, 21.18, 7.48, 21.18);
  path.lineTo(6.24, 21.18);
  path.lineTo(6.01, 21.87);
  path.cubicTo(5.82, 22.45, 5.70, 22.54, 5.28, 22.48);
  path.cubicTo(4.75, 22.43, 4.73, 22.35, 4.94, 21.64);
  path.cubicTo(5.03, 21.30, 4.96, 21.22, 4.52, 21.13);
  path.cubicTo(4.10, 21.05, 3.73, 20.67, 2.99, 19.60);
  path.cubicTo(1.82, 17.91, 1.65, 17.34, 2.07, 16.69);
  path.cubicTo(2.64, 15.83, 3.41, 15.58, 5.30, 15.67);
  path.cubicTo(6.93, 15.75, 6.98, 15.73, 6.91, 15.37);
  path.cubicTo(6.83, 14.99, 6.41, 13.32, 6.28, 12.81);
  path.cubicTo(6.22, 12.63, 5.89, 12.58, 5.21, 12.61);
  path.cubicTo(4.13, 12.67, 4.10, 12.71, 4.38, 13.76);
  path.cubicTo(4.48, 14.16, 4.42, 14.32, 4.12, 14.47);
  path.cubicTo(3.77, 14.66, 3.69, 14.60, 3.43, 14.12);
  path.cubicTo(3.27, 13.80, 2.93, 13.34, 2.66, 13.07);
  path.cubicTo(2.39, 12.81, 2.18, 12.46, 2.18, 12.31);
  path.cubicTo(2.18, 11.96, 2.70, 11.43, 3.03, 11.43);
  path.cubicTo(3.39, 11.43, 4.29, 9.99, 4.29, 9.44);
  path.cubicTo(4.29, 9.17, 4.02, 8.44, 3.71, 7.83);
  path.cubicTo(3.01, 6.44, 3.01, 6.13, 3.64, 5.19);
  path.cubicTo(4.33, 4.18, 4.52, 4.08, 4.90, 4.56);
  path.cubicTo(5.22, 4.94, 5.22, 4.98, 4.77, 5.54);
  path.cubicTo(4.15, 6.24, 4.17, 6.40, 4.86, 7.76);
  path.cubicTo(5.53, 9.09, 5.57, 9.55, 5.05, 10.57);
  path.cubicTo(4.84, 10.99, 4.67, 11.37, 4.67, 11.43);
  path.cubicTo(4.67, 11.58, 6.53, 11.56, 6.62, 11.43);
  path.cubicTo(6.66, 11.37, 6.87, 11.06, 7.12, 10.72);
  path.cubicTo(7.64, 9.95, 7.65, 9.40, 7.16, 8.65);
  path.cubicTo(6.54, 7.74, 6.74, 6.44, 7.54, 5.94);
  path.cubicTo(7.81, 5.75, 7.94, 5.78, 8.23, 6.09);
  path.cubicTo(8.53, 6.44, 8.53, 6.47, 8.25, 6.80);
  path.cubicTo(7.83, 7.26, 7.85, 7.64, 8.30, 8.41);
  path.cubicTo(8.74, 9.13, 8.78, 9.99, 8.40, 10.66);
  path.cubicTo(7.98, 11.41, 8.06, 11.56, 8.94, 11.58);
  path.cubicTo(9.70, 11.62, 9.78, 11.56, 10.29, 10.76);
  path.lineTo(10.83, 9.88);
  path.lineTo(10.43, 8.94);
  path.cubicTo(10.05, 8.06, 10.05, 7.95, 10.29, 7.32);
  path.cubicTo(10.49, 6.88, 10.71, 6.65, 10.96, 6.65);
  path.cubicTo(11.38, 6.65, 11.69, 7.35, 11.40, 7.64);
  path.cubicTo(11.27, 7.77, 11.35, 8.12, 11.61, 8.71);
  path.cubicTo(11.98, 9.57, 11.98, 9.65, 11.69, 10.49);
  path.cubicTo(11.29, 11.60, 11.29, 11.62, 11.71, 11.62);
  path.cubicTo(12.26, 11.62, 12.51, 12.02, 12.51, 12.90);
  path.cubicTo(12.51, 13.86, 12.17, 13.99, 11.59, 13.24);
  path.cubicTo(11.38, 12.98, 11.08, 12.77, 10.89, 12.77);
  path.cubicTo(10.54, 12.77, 10.54, 12.86, 11.23, 14.79);
  path.cubicTo(11.63, 15.96, 11.63, 15.98, 12.47, 16.10);
  path.cubicTo(14.08, 16.31, 14.20, 16.27, 14.41, 15.48);
  path.cubicTo(15.06, 13.15, 16.99, 7.62, 17.31, 7.16);
  path.cubicTo(17.66, 6.68, 17.68, 6.55, 17.49, 6.05);
  path.cubicTo(17.05, 5.00, 17.96, 2.32, 18.96, 1.79);
  path.cubicTo(19.67, 1.40, 20.93, 1.40, 21.47, 1.79);
  path.close();
  path.moveTo(19.48, 2.90);
  path.cubicTo(19.27, 3.05, 18.92, 3.66, 18.73, 4.25);
  path.cubicTo(18.25, 5.61, 18.44, 6.00, 19.51, 5.92);
  path.cubicTo(19.92, 5.88, 20.32, 5.78, 20.39, 5.73);
  path.cubicTo(20.59, 5.54, 21.12, 2.95, 21.01, 2.78);
  path.cubicTo(20.85, 2.53, 19.90, 2.61, 19.48, 2.90);
  path.close();
  path.moveTo(18.58, 7.41);
  path.cubicTo(18.02, 7.85, 17.91, 8.16, 16.43, 12.86);
  path.cubicTo(14.98, 17.55, 15.15, 17.26, 13.60, 17.26);
  path.cubicTo(12.91, 17.28, 12.28, 17.32, 12.23, 17.40);
  path.cubicTo(12.17, 17.45, 12.32, 18.05, 12.55, 18.72);
  path.lineTo(12.99, 19.94);
  path.lineTo(14.33, 20.00);
  path.cubicTo(15.48, 20.04, 15.78, 19.98, 16.34, 19.61);
  path.cubicTo(17.54, 18.79, 17.60, 18.64, 18.62, 14.11);
  path.cubicTo(18.84, 13.11, 19.28, 11.16, 19.59, 9.78);
  path.cubicTo(19.92, 8.41, 20.16, 7.22, 20.16, 7.14);
  path.cubicTo(20.16, 6.88, 19.04, 7.07, 18.58, 7.41);
  path.close();
  path.moveTo(7.56, 13.19);
  path.cubicTo(7.56, 13.53, 7.71, 14.24, 7.88, 14.78);
  path.cubicTo(8.21, 15.71, 8.23, 15.73, 9.17, 15.87);
  path.cubicTo(9.68, 15.94, 10.18, 15.94, 10.27, 15.85);
  path.cubicTo(10.35, 15.77, 10.26, 15.23, 10.05, 14.66);
  path.cubicTo(9.83, 14.09, 9.62, 13.40, 9.55, 13.09);
  path.cubicTo(9.45, 12.61, 9.38, 12.58, 8.50, 12.58);
  path.cubicTo(7.54, 12.58, 7.54, 12.58, 7.56, 13.19);
  path.close();
  path.moveTo(3.25, 17.03);
  path.cubicTo(2.93, 17.28, 2.93, 17.32, 3.22, 17.85);
  path.cubicTo(3.37, 18.16, 3.75, 18.75, 4.06, 19.17);
  path.lineTo(4.59, 19.94);
  path.lineTo(6.56, 20.00);
  path.cubicTo(8.11, 20.04, 8.52, 20.00, 8.46, 19.81);
  path.cubicTo(8.40, 19.67, 8.17, 18.98, 7.94, 18.29);
  path.cubicTo(7.56, 17.15, 7.46, 17.01, 6.93, 16.90);
  path.cubicTo(5.88, 16.69, 3.62, 16.76, 3.25, 17.03);
  path.close();
  path.moveTo(8.84, 17.09);
  path.cubicTo(8.76, 17.15, 8.96, 17.84, 9.22, 18.62);
  path.lineTo(9.74, 20.04);
  path.lineTo(10.73, 20.04);
  path.cubicTo(11.29, 20.04, 11.75, 20.00, 11.75, 19.96);
  path.cubicTo(11.75, 19.69, 10.94, 17.36, 10.83, 17.30);
  path.cubicTo(10.56, 17.13, 8.96, 16.98, 8.84, 17.09);
  path.close();
}

/// Filled-outline house glyph, converted 1:1 from the user-supplied
/// symbol source (633x512 viewBox, background-cell rect dropped; two
/// closed sub-paths with opposite winding). Same coordinates as
/// assets/icons/house.svg.
void _housePath(Path path) {
  path.moveTo(12.65, 2.58);
  path.cubicTo(12.77, 2.63, 12.91, 2.73, 12.98, 2.78);
  path.cubicTo(14.09, 3.78, 16.71, 6.21, 16.89, 6.40);
  path.cubicTo(16.94, 6.46, 17.29, 6.79, 17.67, 7.13);
  path.cubicTo(18.05, 7.48, 18.54, 7.94, 18.75, 8.15);
  path.cubicTo(19.25, 8.63, 19.23, 8.61, 20.08, 9.40);
  path.cubicTo(21.42, 10.65, 22.38, 11.59, 22.44, 11.70);
  path.cubicTo(22.54, 11.89, 22.52, 12.06, 22.34, 12.23);
  path.cubicTo(22.22, 12.35, 22.14, 12.39, 22.01, 12.39);
  path.cubicTo(21.82, 12.39, 21.80, 12.38, 21.01, 11.65);
  path.cubicTo(20.78, 11.43, 20.57, 11.26, 20.54, 11.26);
  path.cubicTo(20.51, 11.26, 20.51, 12.88, 20.53, 15.68);
  path.cubicTo(20.55, 20.49, 20.55, 20.55, 20.30, 20.93);
  path.cubicTo(20.17, 21.12, 19.89, 21.33, 19.59, 21.43);
  path.cubicTo(19.44, 21.49, 18.89, 21.50, 16.78, 21.52);
  path.lineTo(14.16, 21.54);
  path.lineTo(14.00, 21.38);
  path.lineTo(13.83, 21.21);
  path.lineTo(13.83, 19.04);
  path.cubicTo(13.83, 15.47, 13.82, 15.26, 13.72, 15.14);
  path.cubicTo(13.63, 15.05, 13.59, 15.05, 12.03, 15.05);
  path.lineTo(10.43, 15.05);
  path.lineTo(10.33, 15.17);
  path.cubicTo(10.23, 15.29, 10.23, 15.33, 10.23, 18.28);
  path.lineTo(10.23, 21.26);
  path.lineTo(10.09, 21.40);
  path.lineTo(9.95, 21.54);
  path.lineTo(7.26, 21.53);
  path.cubicTo(4.81, 21.51, 4.56, 21.50, 4.39, 21.43);
  path.cubicTo(4.13, 21.31, 3.80, 21.04, 3.71, 20.86);
  path.cubicTo(3.51, 20.46, 3.50, 20.44, 3.50, 15.77);
  path.cubicTo(3.50, 13.32, 3.49, 11.30, 3.48, 11.29);
  path.cubicTo(3.46, 11.27, 3.17, 11.52, 2.83, 11.83);
  path.cubicTo(2.26, 12.34, 2.19, 12.39, 2.03, 12.39);
  path.cubicTo(1.77, 12.39, 1.57, 12.20, 1.53, 11.93);
  path.lineTo(1.50, 11.72);
  path.lineTo(1.99, 11.25);
  path.cubicTo(2.51, 10.74, 3.85, 9.48, 7.56, 6.00);
  path.cubicTo(9.17, 4.48, 10.81, 2.96, 11.02, 2.79);
  path.cubicTo(11.36, 2.51, 11.58, 2.44, 12.03, 2.46);
  path.cubicTo(12.33, 2.47, 12.49, 2.50, 12.65, 2.58);
  path.close();
  path.moveTo(11.86, 3.45);
  path.cubicTo(11.71, 3.49, 11.04, 4.07, 9.88, 5.19);
  path.cubicTo(9.56, 5.49, 9.15, 5.88, 8.95, 6.07);
  path.cubicTo(8.76, 6.25, 8.36, 6.62, 8.08, 6.90);
  path.cubicTo(7.79, 7.17, 7.28, 7.64, 6.96, 7.93);
  path.cubicTo(6.64, 8.23, 6.19, 8.65, 5.97, 8.86);
  path.cubicTo(5.74, 9.08, 5.34, 9.46, 5.07, 9.72);
  path.cubicTo(4.79, 9.97, 4.56, 10.21, 4.53, 10.24);
  path.cubicTo(4.51, 10.27, 4.50, 12.55, 4.51, 15.31);
  path.lineTo(4.52, 20.31);
  path.lineTo(4.66, 20.43);
  path.lineTo(4.79, 20.54);
  path.lineTo(7.01, 20.54);
  path.lineTo(9.24, 20.54);
  path.lineTo(9.24, 17.82);
  path.cubicTo(9.24, 15.19, 9.24, 15.09, 9.34, 14.84);
  path.cubicTo(9.40, 14.65, 9.50, 14.51, 9.65, 14.38);
  path.cubicTo(10.02, 14.06, 10.11, 14.05, 12.14, 14.06);
  path.lineTo(13.90, 14.07);
  path.lineTo(14.16, 14.22);
  path.cubicTo(14.44, 14.37, 14.59, 14.55, 14.72, 14.86);
  path.cubicTo(14.79, 15.05, 14.80, 15.35, 14.83, 17.79);
  path.lineTo(14.85, 20.52);
  path.lineTo(17.00, 20.53);
  path.cubicTo(19.45, 20.54, 19.43, 20.55, 19.52, 20.21);
  path.cubicTo(19.55, 20.08, 19.56, 18.63, 19.54, 15.20);
  path.cubicTo(19.52, 12.55, 19.50, 10.34, 19.49, 10.28);
  path.cubicTo(19.47, 10.20, 18.32, 9.08, 17.22, 8.08);
  path.cubicTo(16.72, 7.63, 15.03, 6.04, 14.28, 5.33);
  path.cubicTo(13.29, 4.39, 12.54, 3.70, 12.37, 3.58);
  path.cubicTo(12.16, 3.42, 12.05, 3.40, 11.86, 3.45);
  path.close();
}
