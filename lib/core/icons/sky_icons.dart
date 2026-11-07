import 'package:flutter/material.dart';

import 'sky_icon.dart';

class SkyIcons {
  SkyIcons._();

  /// Recreated 1:1 from `assets/icons/home.svg`: rounded-stroke outline
  /// house with a soft apex and a bottom-center door notch.
  static const SkyIconData home = SkyIconData.svg(_homePath);

  /// Converted 1:1 from the user-supplied filled navigation glyph
  /// (`assets/icons/navigation.svg`): tilted paper plane.
  static const SkyIconData navigation = SkyIconData.svg(
    _navigationPath,
    filled: true,
  );

  /// Converted 1:1 from the user-supplied filled media glyph
  /// (`assets/icons/music.svg`): beamed eighth-note pair.
  static const SkyIconData music = SkyIconData.svg(_musicPath, filled: true);

  /// Converted 1:1 from the user-supplied filled phone glyph
  /// (`assets/icons/phone.svg`): handset outline.
  static const SkyIconData phone = SkyIconData.svg(_phonePath, filled: true);

  /// Recreated 1:1 from `assets/icons/vehicle.svg`: front-view car.
  static const SkyIconData vehicle = SkyIconData.svg(_vehiclePath);

  /// Converted 1:1 from the user-supplied filled settings glyph
  /// (`assets/icons/settings.svg`): gear with a center hub.
  static const SkyIconData settings = SkyIconData.svg(
    _settingsPath,
    filled: true,
  );

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

/// Filled navigation glyph, converted 1:1 from the user-supplied
/// symbol source (84x79 viewBox, background-cell rect dropped; two
/// closed sub-paths with opposite winding). Same coordinates as
/// assets/icons/navigation.svg.
void _navigationPath(Path path) {
  path.moveTo(22.33, 1.90);
  path.cubicTo(22.54, 2.23, 19.86, 9.09, 15.97, 18.30);
  path.cubicTo(15.01, 20.47, 14.00, 22.31, 13.67, 22.40);
  path.cubicTo(13.21, 22.48, 12.79, 21.52, 12.12, 18.42);
  path.cubicTo(11.62, 16.16, 11.07, 14.20, 10.91, 14.03);
  path.cubicTo(10.78, 13.86, 8.65, 13.53, 6.18, 13.23);
  path.cubicTo(2.88, 12.90, 1.66, 12.61, 1.66, 12.19);
  path.cubicTo(1.66, 11.73, 20.78, 1.65, 21.82, 1.61);
  path.cubicTo(21.99, 1.56, 22.20, 1.73, 22.33, 1.90);
  path.close();
  path.moveTo(11.95, 7.80);
  path.lineTo(4.01, 11.81);
  path.lineTo(7.85, 12.23);
  path.cubicTo(9.94, 12.48, 11.74, 12.77, 11.87, 12.86);
  path.cubicTo(11.95, 12.98, 12.37, 14.36, 12.79, 16.00);
  path.cubicTo(13.21, 17.58, 13.67, 19.05, 13.79, 19.26);
  path.cubicTo(13.92, 19.43, 14.50, 18.46, 15.05, 17.17);
  path.cubicTo(15.59, 15.83, 17.01, 12.36, 18.27, 9.47);
  path.cubicTo(19.48, 6.54, 20.49, 4.03, 20.49, 3.91);
  path.cubicTo(20.49, 3.49, 20.11, 3.66, 11.95, 7.80);
  path.close();
}

/// Filled media glyph, converted 1:1 from the user-supplied
/// symbol source (70x89 viewBox, background-cell rect dropped; four
/// closed sub-paths with opposite winding). Same coordinates as
/// assets/icons/music.svg.
void _musicPath(Path path) {
  path.moveTo(21.22, 2.71);
  path.cubicTo(21.47, 3.43, 21.60, 6.79, 21.51, 11.04);
  path.cubicTo(21.39, 18.02, 21.34, 18.23, 20.37, 19.04);
  path.cubicTo(19.05, 20.10, 16.75, 20.10, 15.64, 19.00);
  path.cubicTo(13.18, 16.53, 16.41, 12.24, 19.51, 13.89);
  path.cubicTo(20.28, 14.32, 20.32, 14.19, 20.32, 10.75);
  path.lineTo(20.32, 7.09);
  path.lineTo(18.96, 7.39);
  path.cubicTo(18.20, 7.51, 15.73, 8.20, 13.52, 8.83);
  path.lineTo(9.48, 9.98);
  path.lineTo(9.35, 15.30);
  path.cubicTo(9.22, 20.49, 9.22, 20.70, 8.12, 21.55);
  path.cubicTo(7.52, 22.02, 6.46, 22.40, 5.78, 22.40);
  path.cubicTo(4.25, 22.40, 2.46, 20.70, 2.46, 19.21);
  path.cubicTo(2.46, 16.91, 5.99, 15.04, 7.48, 16.53);
  path.cubicTo(7.86, 16.91, 7.99, 15.72, 7.99, 11.04);
  path.cubicTo(7.99, 6.71, 8.12, 4.92, 8.50, 4.67);
  path.cubicTo(9.22, 4.20, 18.58, 1.65, 19.81, 1.60);
  path.cubicTo(20.49, 1.56, 20.92, 1.90, 21.22, 2.71);
  path.close();
  path.moveTo(15.43, 3.77);
  path.cubicTo(13.82, 4.24, 11.73, 4.79, 10.88, 5.01);
  path.cubicTo(9.39, 5.39, 9.27, 5.56, 9.27, 6.88);
  path.cubicTo(9.27, 8.71, 9.52, 8.75, 15.64, 7.13);
  path.lineTo(20.11, 5.98);
  path.lineTo(20.11, 4.54);
  path.cubicTo(20.11, 2.71, 19.56, 2.58, 15.43, 3.77);
  path.close();
  path.moveTo(16.84, 15.21);
  path.cubicTo(15.77, 15.81, 15.81, 17.98, 16.88, 18.57);
  path.cubicTo(18.07, 19.17, 18.49, 19.13, 19.47, 18.15);
  path.cubicTo(20.37, 17.25, 20.54, 16.57, 19.98, 15.72);
  path.cubicTo(19.51, 15.00, 17.69, 14.70, 16.84, 15.21);
  path.close();
  path.moveTo(4.16, 17.93);
  path.cubicTo(3.27, 19.04, 4.12, 20.87, 5.57, 21.04);
  path.cubicTo(7.14, 21.25, 7.99, 20.44, 7.99, 18.83);
  path.cubicTo(7.99, 17.55, 7.90, 17.47, 6.33, 17.38);
  path.cubicTo(5.27, 17.30, 4.50, 17.51, 4.16, 17.93);
  path.close();
}

/// Filled phone glyph, converted 1:1 from the user-supplied
/// symbol source (93x100 viewBox, background-cell rect dropped; two
/// closed sub-paths with opposite winding). Same coordinates as
/// assets/icons/phone.svg.
void _phonePath(Path path) {
  path.moveTo(7.49, 3.17);
  path.cubicTo(8.28, 4.04, 9.15, 5.29, 9.48, 5.87);
  path.cubicTo(9.97, 6.82, 9.93, 7.03, 9.15, 8.14);
  path.cubicTo(8.65, 8.81, 8.23, 9.64, 8.23, 10.01);
  path.cubicTo(8.23, 10.84, 11.80, 14.65, 13.25, 15.44);
  path.cubicTo(14.24, 15.94, 14.49, 15.89, 15.44, 15.15);
  path.cubicTo(16.77, 14.11, 17.60, 14.28, 20.38, 16.02);
  path.cubicTo(21.87, 16.97, 22.32, 17.51, 22.32, 18.34);
  path.cubicTo(22.32, 20.91, 19.21, 23.02, 16.52, 22.23);
  path.cubicTo(10.02, 20.37, 2.56, 12.54, 1.77, 6.78);
  path.cubicTo(1.44, 4.58, 1.98, 3.42, 3.80, 2.34);
  path.cubicTo(5.62, 1.22, 5.91, 1.27, 7.49, 3.17);
  path.close();
  path.moveTo(3.80, 3.84);
  path.cubicTo(2.93, 4.71, 2.76, 5.16, 2.97, 6.53);
  path.cubicTo(3.51, 10.59, 7.36, 15.77, 12.05, 18.84);
  path.cubicTo(16.65, 21.78, 19.30, 21.99, 20.91, 19.50);
  path.cubicTo(21.66, 18.42, 21.66, 18.38, 20.46, 17.43);
  path.cubicTo(18.55, 15.89, 16.98, 15.36, 16.15, 15.94);
  path.cubicTo(14.16, 17.43, 12.92, 17.01, 9.85, 13.99);
  path.cubicTo(6.99, 11.09, 6.53, 9.80, 7.78, 8.14);
  path.cubicTo(8.23, 7.48, 8.65, 6.82, 8.65, 6.65);
  path.cubicTo(8.65, 6.16, 5.71, 2.76, 5.29, 2.76);
  path.cubicTo(5.04, 2.76, 4.38, 3.25, 3.80, 3.84);
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

/// Filled settings glyph, converted 1:1 from the user-supplied
/// symbol source (71x89 viewBox, background-cell rect dropped; four
/// closed sub-paths). Same coordinates as assets/icons/settings.svg.
void _settingsPath(Path path) {
  path.moveTo(14.29, 3.03);
  path.cubicTo(14.90, 4.58, 15.43, 4.75, 17.11, 3.97);
  path.cubicTo(18.05, 3.56, 18.29, 3.60, 19.44, 4.75);
  path.cubicTo(20.62, 5.93, 20.66, 6.14, 20.21, 7.28);
  path.cubicTo(19.60, 8.67, 19.84, 9.24, 21.23, 9.77);
  path.cubicTo(22.05, 10.10, 22.21, 10.43, 22.21, 11.98);
  path.cubicTo(22.21, 13.61, 22.09, 13.90, 20.99, 14.47);
  path.cubicTo(19.64, 15.16, 19.56, 15.41, 20.25, 16.92);
  path.cubicTo(20.66, 17.86, 20.62, 18.11, 19.44, 19.25);
  path.cubicTo(18.29, 20.43, 18.09, 20.52, 17.07, 20.07);
  path.cubicTo(15.72, 19.41, 14.45, 19.78, 14.45, 20.80);
  path.cubicTo(14.45, 22.64, 10.57, 23.01, 9.71, 21.29);
  path.cubicTo(8.89, 19.62, 8.49, 19.41, 7.10, 19.99);
  path.cubicTo(5.91, 20.48, 5.75, 20.43, 4.65, 19.37);
  path.cubicTo(3.42, 18.19, 3.05, 16.96, 3.83, 16.51);
  path.cubicTo(4.60, 16.02, 4.24, 15.08, 3.01, 14.47);
  path.cubicTo(1.91, 13.90, 1.79, 13.61, 1.79, 12.02);
  path.cubicTo(1.79, 10.47, 1.95, 10.10, 2.77, 9.69);
  path.cubicTo(4.07, 9.12, 4.32, 8.38, 3.75, 7.12);
  path.cubicTo(3.34, 6.22, 3.42, 5.93, 4.44, 4.87);
  path.cubicTo(5.71, 3.52, 6.28, 3.40, 7.46, 4.13);
  path.cubicTo(8.08, 4.50, 8.40, 4.50, 8.89, 4.09);
  path.cubicTo(9.26, 3.77, 9.55, 3.32, 9.55, 3.07);
  path.cubicTo(9.55, 2.17, 10.53, 1.60, 12.12, 1.60);
  path.cubicTo(13.51, 1.60, 13.76, 1.76, 14.29, 3.03);
  path.close();
  path.moveTo(10.61, 3.85);
  path.cubicTo(10.28, 5.11, 8.53, 5.93, 7.30, 5.36);
  path.cubicTo(5.79, 4.66, 4.93, 5.48, 5.26, 7.32);
  path.cubicTo(5.54, 9.04, 4.97, 10.59, 4.03, 10.59);
  path.cubicTo(3.13, 10.59, 2.44, 12.14, 3.05, 12.88);
  path.cubicTo(3.30, 13.20, 3.79, 13.45, 4.07, 13.45);
  path.cubicTo(5.10, 13.45, 5.67, 15.33, 5.10, 16.59);
  path.cubicTo(4.65, 17.57, 4.69, 17.78, 5.46, 18.43);
  path.cubicTo(6.16, 18.96, 6.48, 19.05, 7.06, 18.68);
  path.cubicTo(8.24, 17.94, 10.00, 18.64, 10.49, 19.99);
  path.cubicTo(11.10, 21.62, 12.57, 21.66, 13.31, 20.11);
  path.cubicTo(14.00, 18.68, 15.80, 17.98, 16.98, 18.72);
  path.cubicTo(17.72, 19.17, 17.92, 19.13, 18.62, 18.43);
  path.cubicTo(19.31, 17.78, 19.35, 17.49, 18.90, 16.84);
  path.cubicTo(18.21, 15.70, 18.74, 13.90, 19.97, 13.45);
  path.cubicTo(21.36, 12.92, 21.36, 11.28, 19.97, 10.67);
  path.cubicTo(18.74, 10.10, 18.21, 8.34, 18.90, 7.20);
  path.cubicTo(19.35, 6.54, 19.31, 6.26, 18.66, 5.60);
  path.cubicTo(17.97, 4.95, 17.72, 4.91, 16.78, 5.32);
  path.cubicTo(15.35, 5.97, 13.80, 5.32, 13.23, 3.85);
  path.cubicTo(12.69, 2.42, 10.98, 2.42, 10.61, 3.85);
  path.close();
  path.moveTo(13.39, 8.55);
  path.cubicTo(11.47, 7.81, 9.88, 8.38, 8.73, 10.26);
  path.cubicTo(6.48, 13.90, 11.63, 17.70, 14.70, 14.63);
  path.cubicTo(16.54, 12.79, 15.80, 9.44, 13.39, 8.55);
  path.close();
  path.moveTo(10.77, 9.89);
  path.cubicTo(9.96, 10.30, 9.75, 10.71, 9.75, 12.02);
  path.cubicTo(9.75, 13.33, 9.96, 13.73, 10.86, 14.27);
  path.cubicTo(11.88, 14.80, 12.12, 14.80, 13.14, 14.27);
  path.cubicTo(13.96, 13.78, 14.29, 13.29, 14.37, 12.18);
  path.cubicTo(14.53, 10.06, 12.74, 8.91, 10.77, 9.89);
  path.close();
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
