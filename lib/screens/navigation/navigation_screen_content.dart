import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Full-screen navigation content shown after the expand animation completes.
/// This is separate from the card thumbnail to keep the card widget unchanged.
class NavigationScreenContent extends StatelessWidget {
  /// Called when the user taps the back/close button.
  final VoidCallback onClose;

  const NavigationScreenContent({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0F),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Map background ──────────────────────────────────────────────
          _FullMapBackground(),

          // ── Top bar with route info + close button ───────────────────────
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(child: _RouteInfoCard()),
                const SizedBox(width: 12),
                _CloseButton(onClose: onClose),
              ],
            ),
          ),

          // ── Turn-by-turn instruction banner ─────────────────────────────
          Positioned(
            top: 100,
            left: 16,
            right: 16,
            child: _TurnBanner(),
          ),

          // ── Bottom trip stats bar ────────────────────────────────────────
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _TripStatsBar(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Map background
// ─────────────────────────────────────────────────────────────────────────────

class _FullMapBackground extends StatelessWidget {
  const _FullMapBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _FullMapPainter(),
        ),
        // Current-position puck
        Center(
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                  blurRadius: 18,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FullMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    final blockPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    // Grid
    const gridSpacing = 48.0;
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // City blocks
    final blocks = [
      Rect.fromLTWH(size.width * 0.05, size.height * 0.1, size.width * 0.2, size.height * 0.15),
      Rect.fromLTWH(size.width * 0.30, size.height * 0.05, size.width * 0.15, size.height * 0.12),
      Rect.fromLTWH(size.width * 0.55, size.height * 0.08, size.width * 0.25, size.height * 0.18),
      Rect.fromLTWH(size.width * 0.10, size.height * 0.35, size.width * 0.18, size.height * 0.20),
      Rect.fromLTWH(size.width * 0.60, size.height * 0.35, size.width * 0.30, size.height * 0.14),
      Rect.fromLTWH(size.width * 0.05, size.height * 0.65, size.width * 0.22, size.height * 0.20),
      Rect.fromLTWH(size.width * 0.35, size.height * 0.68, size.width * 0.18, size.height * 0.18),
      Rect.fromLTWH(size.width * 0.65, size.height * 0.62, size.width * 0.28, size.height * 0.22),
    ];
    for (final block in blocks) {
      canvas.drawRRect(RRect.fromRectAndRadius(block, const Radius.circular(4)), blockPaint);
    }

    // Route path
    final routePaint = Paint()
      ..color = const Color(0xFFFF8A00)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final routeGlowPaint = Paint()
      ..color = const Color(0xFFFF8A00).withValues(alpha: 0.25)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width * 0.15, size.height * 0.75);
    path.cubicTo(
      size.width * 0.15, size.height * 0.5,
      size.width * 0.35, size.height * 0.5,
      size.width * 0.5, size.height * 0.5,
    );
    path.cubicTo(
      size.width * 0.65, size.height * 0.5,
      size.width * 0.65, size.height * 0.3,
      size.width * 0.82, size.height * 0.2,
    );

    canvas.drawPath(path, routeGlowPaint);
    canvas.drawPath(path, routePaint);

    // Destination pin
    final destPinFill = Paint()
      ..color = const Color(0xFFFF8A00)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.2),
      10,
      destPinFill,
    );
    final destPinStroke = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.2),
      10,
      destPinStroke,
    );
  }

  @override
  bool shouldRepaint(_FullMapPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Route info card (top-left)
// ─────────────────────────────────────────────────────────────────────────────

class _RouteInfoCard extends StatelessWidget {
  const _RouteInfoCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'City Center Mall',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    '8.5 km',
                    style: TextStyle(
                      color: Color(0xFFFF8A00),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '12 min',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'via Main St',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Close button
// ─────────────────────────────────────────────────────────────────────────────

class _CloseButton extends StatelessWidget {
  final VoidCallback onClose;

  const _CloseButton({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Turn-by-turn banner
// ─────────────────────────────────────────────────────────────────────────────

class _TurnBanner extends StatelessWidget {
  const _TurnBanner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFFF8A00).withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A00).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFF8A00).withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.turn_right_rounded,
                  color: Color(0xFFFF8A00),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Turn right onto Main Street',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'In 300 m',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trip stats bar (bottom)
// ─────────────────────────────────────────────────────────────────────────────

class _TripStatsBar extends StatelessWidget {
  const _TripStatsBar();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(icon: Icons.speed_rounded, label: 'Speed', value: '65 km/h'),
              _Divider(),
              _StatItem(icon: Icons.straighten_rounded, label: 'Distance', value: '2.3 km'),
              _Divider(),
              _StatItem(icon: Icons.timer_outlined, label: 'ETA', value: '5 min'),
              _Divider(),
              _StatItem(icon: Icons.alt_route_rounded, label: 'Route', value: 'Fastest'),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white.withValues(alpha: 0.08),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFFFF8A00), size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
