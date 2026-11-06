import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Veltron brand mark: two metallic ribbons forming a sharp V.
///
/// Vector source of truth is @assets/images/logo.svg; this painter mirrors
/// its polygon coordinates and gradients so the in-app logo stays crisp at
/// any size without an extra dependency.
class VeltronLogo extends StatelessWidget {
  /// Rendered box; the mark fills the box in a 96x96 coordinate space.
  final double size;

  const VeltronLogo({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _VeltronLogoPainter()),
    );
  }
}

class _VeltronLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size boxSize) {
    final double scale = boxSize.shortestSide / 96;
    canvas.scale(scale, scale);

    final Path leftArm = Path()
      ..moveTo(8, 20)
      ..lineTo(42, 10)
      ..lineTo(46, 91)
      ..close();

    final Path rightArm = Path()
      ..moveTo(47, 12)
      ..lineTo(90, 24)
      ..lineTo(46, 91)
      ..close();

    final Path junctionCrease = Path()
      ..moveTo(46, 91)
      ..lineTo(44.5, 66)
      ..lineTo(47.2, 66)
      ..close();

    final Paint leftPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(24, 12),
        const Offset(46, 91),
        const [
          Color(0xFFB9BEC8),
          Color(0xFFF8F9FB),
          Color(0xFF5C6169),
        ],
        const [0.0, 0.5, 1.0],
      );

    final Paint rightPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(70, 16),
        const Offset(46, 91),
        const [
          Color(0xFFFFFFFF),
          Color(0xFFD2D5DC),
          Color(0xFF454952),
        ],
        const [0.0, 0.55, 1.0],
      );

    final Paint creasePaint = Paint()
      ..color = const Color.fromRGBO(0, 0, 0, 0.30);

    canvas.drawPath(leftArm, leftPaint);
    canvas.drawPath(rightArm, rightPaint);
    canvas.drawPath(junctionCrease, creasePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
