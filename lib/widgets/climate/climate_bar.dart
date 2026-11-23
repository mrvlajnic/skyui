import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/icons/sky_icon.dart';
import '../../core/icons/sky_icons.dart';

/// Scales a design metric from the original 56 dp panel so the contents grow
/// with the bar instead of leaving extra padding around them.
double _s(double value) => value * ClimateBar.scale;

class ClimateBar extends StatefulWidget {
  const ClimateBar({super.key});

  /// Total height the dashboard layout reserves for the bar, including the
  /// gap below the panel.
  static const double height = 104;

  /// Visible panel height once the layout gap is removed.
  static const double panelHeight = height - 24;

  /// Horizontal inset of the bottom-right corner relative to the top-right
  /// corner. The reference design cuts the right end at roughly 36° from
  /// vertical, so the top edge is the widest point.
  static const double slantWidth = panelHeight * 0.72;

  /// Radius used where the diagonal meets the top and bottom edges.
  static const double slantJoinRadius = 10;

  /// The internal metrics below were designed at this panel height.
  static const double _basePanelHeight = 56;

  /// Uniform scale applied to every metric inside the bar.
  static const double scale = panelHeight / _basePanelHeight;

  @override
  State<ClimateBar> createState() => _ClimateBarState();
}

class _ClimateBarState extends State<ClimateBar> {
  double leftTemp = 22.0;
  double rightTemp = 22.0;
  int leftFanSpeed = 3;
  int rightFanSpeed = 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ClimateBar.height,
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      color: Colors.transparent,
      child: CustomPaint(
        painter: ClimatePanelPainter(
          slantWidth: ClimateBar.slantWidth,
          joinRadius: ClimateBar.slantJoinRadius,
          borderRadius: 12.0,
          borderColor: const Color(0x3AFFFFFF),
          backgroundColor: const Color(0xFF111118),
        ),
        child: ClipPath(
          clipper: ClimatePanelClipper(
            slantWidth: ClimateBar.slantWidth,
            joinRadius: ClimateBar.slantJoinRadius,
            borderRadius: 12.0,
          ),
          child: Container(
            height: ClimateBar.panelHeight,
            color: Colors.transparent,
            child: Row(
              children: [
                _LeftClimateSection(
                  temperature: leftTemp,
                  fanSpeed: leftFanSpeed,
                  onTemperatureChange: (temp) {
                    setState(() => leftTemp = temp);
                  },
                  onFanSpeedChange: (speed) {
                    setState(() => leftFanSpeed = speed);
                  },
                ),
                Expanded(child: const _CenterClimateSection()),
                _RightClimateSection(
                  temperature: rightTemp,
                  fanSpeed: rightFanSpeed,
                  onTemperatureChange: (temp) {
                    setState(() => rightTemp = temp);
                  },
                  onFanSpeedChange: (speed) {
                    setState(() => rightFanSpeed = speed);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared geometry for the climate panel.
///
/// The right end is a diagonal cut: the top edge is the widest point and the
/// bottom-right corner is inset by [slantWidth], matching the reference
/// design. Both joins are rounded so the cut reads as a shape rather than a
/// clipped corner.
class _PanelGeometry {
  final Path path;
  final Offset accentStart;
  final Offset accentEnd;

  const _PanelGeometry({
    required this.path,
    required this.accentStart,
    required this.accentEnd,
  });

  factory _PanelGeometry.from(
    Size size,
    double slantWidth,
    double borderRadius,
    double joinRadius,
  ) {
    final width = size.width;
    final height = size.height;

    // Diagonal direction from the top-right corner to the inset bottom-right.
    final dx = -slantWidth;
    final dy = height;
    final length = math.sqrt(dx * dx + dy * dy);
    final ux = dx / length;
    final uy = dy / length;

    final path = Path()
      ..moveTo(borderRadius, 0)
      ..lineTo(width - joinRadius, 0)
      ..quadraticBezierTo(width, 0, width + ux * joinRadius, uy * joinRadius)
      ..lineTo(width - slantWidth - ux * joinRadius, height - uy * joinRadius)
      ..quadraticBezierTo(
        width - slantWidth,
        height,
        width - slantWidth - joinRadius,
        height,
      )
      ..lineTo(borderRadius, height)
      ..quadraticBezierTo(0, height, 0, height - borderRadius)
      ..lineTo(0, borderRadius)
      ..quadraticBezierTo(0, 0, borderRadius, 0)
      ..close();

    return _PanelGeometry(
      path: path,
      accentStart: Offset(width + ux * joinRadius, uy * joinRadius),
      accentEnd: Offset(
        width - slantWidth - ux * joinRadius,
        height - uy * joinRadius,
      ),
    );
  }
}

class ClimatePanelClipper extends CustomClipper<Path> {
  final double slantWidth;
  final double joinRadius;
  final double borderRadius;

  ClimatePanelClipper({
    required this.slantWidth,
    required this.borderRadius,
    this.joinRadius = 10,
  });

  @override
  Path getClip(Size size) =>
      _PanelGeometry.from(size, slantWidth, borderRadius, joinRadius).path;

  @override
  bool shouldReclip(covariant ClimatePanelClipper oldClipper) =>
      oldClipper.slantWidth != slantWidth ||
      oldClipper.joinRadius != joinRadius ||
      oldClipper.borderRadius != borderRadius;
}

class ClimatePanelPainter extends CustomPainter {
  final double slantWidth;
  final double joinRadius;
  final double borderRadius;
  final Color borderColor;
  final Color backgroundColor;

  ClimatePanelPainter({
    required this.slantWidth,
    required this.borderRadius,
    required this.borderColor,
    required this.backgroundColor,
    this.joinRadius = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final geometry = _PanelGeometry.from(
      size,
      slantWidth,
      borderRadius,
      joinRadius,
    );

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(geometry.path, bgPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(geometry.path, borderPaint);

    // Red accent along the diagonal cut.
    final accentPaint = Paint()
      ..color = const Color(0xFFE53935)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final accentPath = Path()
      ..moveTo(geometry.accentStart.dx, geometry.accentStart.dy)
      ..lineTo(geometry.accentEnd.dx, geometry.accentEnd.dy);

    canvas.drawPath(accentPath, accentPaint);
  }

  @override
  bool shouldRepaint(covariant ClimatePanelPainter oldDelegate) {
    return oldDelegate.slantWidth != slantWidth ||
        oldDelegate.joinRadius != joinRadius ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

class _LeftClimateSection extends StatelessWidget {
  final double temperature;
  final int fanSpeed;
  final Function(double) onTemperatureChange;
  final Function(int) onFanSpeedChange;

  const _LeftClimateSection({
    required this.temperature,
    required this.fanSpeed,
    required this.onTemperatureChange,
    required this.onFanSpeedChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 16, top: _s(6), bottom: _s(6)),
      child: Row(
        children: [
          const _HeatedSeatButton(mirrored: true),
          const SizedBox(width: 20),
          _TemperatureControl(
            temperature: temperature,
            onTemperatureChange: onTemperatureChange,
          ),
          const SizedBox(width: 20),
          _FanSpeedIndicator(speed: fanSpeed, onSpeedChange: onFanSpeedChange),
        ],
      ),
    );
  }
}

class _CenterClimateSection extends StatelessWidget {
  const _CenterClimateSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _StatBlock(value: '14.0%', label: 'Trip: Efficiency'),
          Container(
            width: 1,
            height: _s(24),
            color: Colors.white12,
            margin: const EdgeInsets.symmetric(horizontal: 24),
          ),
          const _StatBlock(value: '48', label: 'Low'),
          const SizedBox(width: 24),
          const _StatBlock(value: '10.0', label: 'Tire as'),
          const SizedBox(width: 24),
          const _StatBlock(value: '46', label: 'Trip'),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String value;
  final String label;

  const _StatBlock({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: _s(14),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: _s(2)),
        Text(
          label,
          style: TextStyle(
            color: Colors.white54,
            fontSize: _s(10),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _RightClimateSection extends StatelessWidget {
  final double temperature;
  final int fanSpeed;
  final Function(double) onTemperatureChange;
  final Function(int) onFanSpeedChange;

  const _RightClimateSection({
    required this.temperature,
    required this.fanSpeed,
    required this.onTemperatureChange,
    required this.onFanSpeedChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 52, top: _s(6), bottom: _s(6)),
      child: Row(
        children: [
          _FanSpeedIndicator(speed: fanSpeed, onSpeedChange: onFanSpeedChange),
          const SizedBox(width: 20),
          _TemperatureControl(
            temperature: temperature,
            onTemperatureChange: onTemperatureChange,
          ),
          const SizedBox(width: 20),
          const _HeatedSeatButton(),
        ],
      ),
    );
  }
}

class _HeatedSeatButton extends StatefulWidget {
  /// Mirrors the seat glyph so the left and right seats face each other.
  final bool mirrored;

  const _HeatedSeatButton({this.mirrored = false});

  @override
  State<_HeatedSeatButton> createState() => _HeatedSeatButtonState();
}

class _HeatedSeatButtonState extends State<_HeatedSeatButton> {
  // Levels 0 (off) through 4 (max); four indicator dots as in the
  // reference image. Default 4 so the bar matches the all-dots-lit look.
  int level = 4;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          level = (level + 1) % 5;
        });
      },
      child: Semantics(
        button: true,
        label: 'Heated seat, level $level of 4',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.flip(
              flipX: widget.mirrored,
              child: SkyIcon(
                SkyIcons.heatedSeat,
                color: level > 0 ? const Color(0xFFE53935) : Colors.white54,
                size: _s(20),
              ),
            ),
            SizedBox(height: _s(4)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(4, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: _s(1.5)),
                  width: _s(3),
                  height: _s(3),
                  decoration: BoxDecoration(
                    color: index < level
                        ? const Color(0xFFE53935)
                        : Colors.white24,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemperatureControl extends StatelessWidget {
  final double temperature;
  final Function(double) onTemperatureChange;

  const _TemperatureControl({
    required this.temperature,
    required this.onTemperatureChange,
  });

  @override
  Widget build(BuildContext context) {
    // Rounded pill matching the reference: minus on the left, temperature
    // centered, plus on the right.
    return Container(
      height: _s(40),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF17171F),
        borderRadius: BorderRadius.circular(_s(10)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ControlButton(
            label: '−',
            compact: true,
            onPressed: () => onTemperatureChange(temperature - 0.5),
          ),
          const SizedBox(width: 8),
          Text(
            '${temperature.toStringAsFixed(1)}°',
            style: TextStyle(
              color: Colors.white,
              fontSize: _s(18),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          _ControlButton(
            label: '+',
            compact: true,
            onPressed: () => onTemperatureChange(temperature + 0.5),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  /// Smaller hit area used inside the [_TemperatureControl] pill.
  final bool compact;

  const _ControlButton({
    required this.label,
    required this.onPressed,
    this.compact = false,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: _s(compact ? 24 : 32),
        height: _s(compact ? 28 : 32),
        decoration: BoxDecoration(color: Colors.transparent),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              color: _isPressed
                  ? const Color(0xFFE53935)
                  : Colors.white.withValues(alpha: 0.62),
              fontSize: _s(compact ? 18 : 20),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _FanSpeedIndicator extends StatelessWidget {
  final int speed;
  final Function(int) onSpeedChange;

  const _FanSpeedIndicator({required this.speed, required this.onSpeedChange});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final nextSpeed = speed >= 4 ? 1 : speed + 1;
        onSpeedChange(nextSpeed);
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: _s(4)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.toys_outlined, color: Colors.white54, size: _s(16)),
            SizedBox(height: _s(4)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AUTO',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: _s(9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    4,
                    (index) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: _s(1)),
                      child: Container(
                        width: _s(2),
                        height: _s(2),
                        decoration: BoxDecoration(
                          color: index < speed ? Colors.white : Colors.white24,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
