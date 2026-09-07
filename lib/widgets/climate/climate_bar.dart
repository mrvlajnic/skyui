import 'package:flutter/material.dart';

class ClimateBar extends StatefulWidget {
  const ClimateBar({super.key});

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
      height: 80,
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      color: Colors.transparent,
      child: CustomPaint(
        painter: ClimatePanelPainter(
          slantWidth: 20.0,
          borderRadius: 12.0,
          borderColor: const Color(0x22FFFFFF),
          backgroundColor: const Color(0xFF111118),
        ),
        child: ClipPath(
          clipper: ClimatePanelClipper(
            slantWidth: 20.0,
            borderRadius: 12.0,
          ),
          child: Container(
            height: 56,
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
                Expanded(
                  child: const _CenterClimateSection(),
                ),
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

class ClimatePanelClipper extends CustomClipper<Path> {
  final double slantWidth;
  final double borderRadius;

  ClimatePanelClipper({
    required this.slantWidth,
    required this.borderRadius,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(borderRadius, 0);
    path.lineTo(size.width - slantWidth, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(borderRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - borderRadius);
    path.lineTo(0, borderRadius);
    path.quadraticBezierTo(0, 0, borderRadius, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant ClimatePanelClipper oldClipper) =>
      oldClipper.slantWidth != slantWidth || oldClipper.borderRadius != borderRadius;
}

class ClimatePanelPainter extends CustomPainter {
  final double slantWidth;
  final double borderRadius;
  final Color borderColor;
  final Color backgroundColor;

  ClimatePanelPainter({
    required this.slantWidth,
    required this.borderRadius,
    required this.borderColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(borderRadius, 0);
    path.lineTo(size.width - slantWidth, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(borderRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - borderRadius);
    path.lineTo(0, borderRadius);
    path.quadraticBezierTo(0, 0, borderRadius, 0);
    path.close();

    // Fill background
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, bgPaint);

    // Draw main border
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint);

    // Draw red/orange accent line on the slanted right edge
    final accentPaint = Paint()
      ..color = const Color(0xFFE53935)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final accentPath = Path()
      ..moveTo(size.width - slantWidth, 0)
      ..lineTo(size.width, size.height);
    
    canvas.drawPath(accentPath, accentPaint);
  }

  @override
  bool shouldRepaint(covariant ClimatePanelPainter oldDelegate) {
    return oldDelegate.slantWidth != slantWidth ||
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
      padding: const EdgeInsets.only(left: 20, right: 16, top: 6, bottom: 6),
      child: Row(
        children: [
          const _HeatedSeatButton(),
          const SizedBox(width: 24),
          _ControlButton(
            label: '−',
            onPressed: () => onTemperatureChange(temperature - 0.5),
          ),
          const SizedBox(width: 12),
          Text(
            '${temperature.toStringAsFixed(1)}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          _ControlButton(
            label: '+',
            onPressed: () => onTemperatureChange(temperature + 0.5),
          ),
          const SizedBox(width: 24),
          _FanSpeedIndicator(
            speed: fanSpeed,
            onSpeedChange: onFanSpeedChange,
          ),
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
            height: 24,
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
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
      padding: const EdgeInsets.only(left: 16, right: 32, top: 6, bottom: 6),
      child: Row(
        children: [
          _FanSpeedIndicator(
            speed: fanSpeed,
            onSpeedChange: onFanSpeedChange,
          ),
          const SizedBox(width: 24),
          _ControlButton(
            label: '−',
            onPressed: () => onTemperatureChange(temperature - 0.5),
          ),
          const SizedBox(width: 12),
          Text(
            '${temperature.toStringAsFixed(1)}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          _ControlButton(
            label: '+',
            onPressed: () => onTemperatureChange(temperature + 0.5),
          ),
          const SizedBox(width: 24),
          const _HeatedSeatButton(),
        ],
      ),
    );
  }
}

class _HeatedSeatButton extends StatefulWidget {
  const _HeatedSeatButton();

  @override
  State<_HeatedSeatButton> createState() => _HeatedSeatButtonState();
}

class _HeatedSeatButtonState extends State<_HeatedSeatButton> {
  int level = 3; // Default to 3 to match preview

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          level = (level + 1) % 4;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chair_outlined,
            color: level > 0 ? const Color(0xFFE53935) : Colors.white54,
            size: 20,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  color: index < level ? const Color(0xFFE53935) : Colors.white24,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.label,
    required this.onPressed,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              color: _isPressed ? const Color(0xFFE53935) : Colors.white54,
              fontSize: 20,
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

  const _FanSpeedIndicator({
    required this.speed,
    required this.onSpeedChange,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final nextSpeed = speed >= 4 ? 1 : speed + 1;
        onSpeedChange(nextSpeed);
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.toys_outlined, color: Colors.white54, size: 16),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'AUTO',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    4,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.0),
                      child: Container(
                        width: 2,
                        height: 2,
                        decoration: BoxDecoration(
                          color: index < speed
                              ? Colors.white
                              : Colors.white24,
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
