import 'package:flutter/material.dart';

/// Draws a single icon's geometry into [path], using the exact coordinates
/// of the icon's source SVG (24x24 viewBox).
typedef SkySvgPath = void Function(Path path);

class SkyIconData {
  final IconData? iconData;

  /// SVG-accurate geometry for stroke-based custom icons. Painted with round
  /// caps and joins at a 2-unit stroke width inside a 24x24 viewBox, so the
  /// [SkyIcon] output matches the bundled SVG asset it was recreated from.
  final SkySvgPath? svgPath;

  const SkyIconData(this.iconData) : svgPath = null;

  const SkyIconData.svg(this.svgPath) : iconData = null;
}

class SkyIcon extends StatelessWidget {
  final SkyIconData icon;
  final double size;
  final Color? color;
  final String? semanticLabel;

  const SkyIcon(
    this.icon, {
    super.key,
    this.size = 24,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final svgPath = icon.svgPath;
    if (svgPath != null) {
      return SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _SkySvgIconPainter(
            svgPath,
            color ?? IconTheme.of(context).color ?? const Color(0xFFADADAD),
          ),
        ),
      );
    }
    return Icon(
      icon.iconData,
      size: size,
      color: color,
      semanticLabel: semanticLabel,
    );
  }
}

class _SkySvgIconPainter extends CustomPainter {
  const _SkySvgIconPainter(this.svgPath, this.color);

  final SkySvgPath svgPath;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..fillType = PathFillType.nonZero;
    svgPath(path);

    // The source SVG is authored in a 24x24 viewBox; scale it to the widget
    // square so geometry and stroke weight shrink/grow together.
    final scale = size.shortestSide / 24;
    canvas.save();
    canvas.translate(
      (size.width - 24 * scale) / 2,
      (size.height - 24 * scale) / 2,
    );
    canvas.scale(scale);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SkySvgIconPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.svgPath != svgPath;
}
