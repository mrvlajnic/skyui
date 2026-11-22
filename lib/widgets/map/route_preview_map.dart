import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'map_vehicle_puck.dart';

/// Decorative route-preview map used when tiles are unreachable.
///
/// This is a custom-painted fixture, not live navigation: no tiles are fetched
/// and no position source exists. It mirrors the Positron palette of the real
/// basemap so the Navigation panel keeps the same look offline.
class RoutePreviewMap extends StatelessWidget {
  /// Normalized (0-1) polyline drawn over the painted street grid.
  final List<Offset> route;

  /// Normalized (0-1) position of the vehicle puck.
  final Offset vehiclePosition;

  final bool showVehicleMarker;

  const RoutePreviewMap({
    super.key,
    this.route = routePreviewDefaultRoute,
    this.vehiclePosition = const Offset(0.5, 0.5),
    this.showVehicleMarker = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Simulated route preview. No GPS or live positioning.',
      image: true,
      excludeSemantics: true,
      child: RepaintBoundary(
        child: ColoredBox(
          color: const Color(0xFFEFEEEA),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _RoutePreviewPainter(route)),
              if (showVehicleMarker)
                Align(
                  alignment: Alignment(
                    vehiclePosition.dx * 2 - 1,
                    vehiclePosition.dy * 2 - 1,
                  ),
                  child: const MapVehiclePuck(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Route used by the painted fallback map in the navigation card.
const List<Offset> routePreviewDefaultRoute = [
  Offset(0.8, 0.2),
  Offset(0.8, 0.4),
  Offset(0.5, 0.4),
  Offset(0.5, 0.8),
  Offset(0.2, 0.8),
];

class _RoutePreviewPainter extends CustomPainter {
  final List<Offset> route;

  const _RoutePreviewPainter(this.route);

  @override
  void paint(Canvas canvas, Size size) {
    final step = math.max(64.0, size.shortestSide / 4);
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = math.max(8.0, step * 0.12)
      ..style = PaintingStyle.stroke;
    final blockPaint = Paint()
      ..color = const Color(0xFFE3E2DE)
      ..style = PaintingStyle.fill;

    // Stylized city blocks with the road grid running between them.
    final blockSize = step * 0.6;
    final blockInset = step * 0.2;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + blockInset, y + blockInset, blockSize, blockSize),
            const Radius.circular(8),
          ),
          blockPaint,
        );
      }
    }
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
    }

    if (route.isEmpty) return;

    final path = Path();
    for (int i = 0; i < route.length; i++) {
      final point = Offset(route[i].dx * size.width, route[i].dy * size.height);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    final routeGlowPaint = Paint()
      ..color = const Color(0xFF0A84FF).withValues(alpha: 0.25)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final routePaint = Paint()
      ..color = const Color(0xFF0A84FF)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, routeGlowPaint);
    canvas.drawPath(path, routePaint);

    // Destination marker at the end of the fixture route.
    final destination = Offset(
      route.last.dx * size.width,
      route.last.dy * size.height,
    );
    canvas.drawCircle(destination, 6, Paint()..color = const Color(0xFFFF9500));
  }

  @override
  bool shouldRepaint(_RoutePreviewPainter oldDelegate) =>
      oldDelegate.route != route;
}
