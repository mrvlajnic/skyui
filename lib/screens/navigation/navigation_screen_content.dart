import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Comprehensive destination model with spatial and telemetry properties
class NavDestination {
  final String title;
  final String category;
  final IconData categoryIcon;
  final String street;
  final double distanceKm;
  final int durationMinutes;
  final int batteryArrivalPercent;
  final Offset coordinates; // Normalized 0.0 to 1.0 on map canvas
  final String nextManeuver;
  final String maneuverDistance;
  final IconData maneuverIcon;

  const NavDestination({
    required this.title,
    required this.category,
    required this.categoryIcon,
    required this.street,
    required this.distanceKm,
    required this.durationMinutes,
    required this.batteryArrivalPercent,
    required this.coordinates,
    required this.nextManeuver,
    required this.maneuverDistance,
    required this.maneuverIcon,
  });
}

/// Full-Screen Interactive Automotive GPS Navigation System for Veltron OS
///
/// Features:
/// - Smooth animated travel of the GPS vehicle puck to any selected destination
/// - Dynamic heading orientation and real-time path morphing
/// - Interactive destination selector chips with instant glide camera
/// - Multi-layer vector map with roads, rivers, traffic indicators, and radar pulse
/// - Floating map control deck (Zoom In/Out, Recenter, Compass, Traffic, 3D)
/// - Automotive HUD (turn-by-turn banner, speed gauge with limit sign, ETA, battery arrival)
class NavigationScreenContent extends StatefulWidget {
  final VoidCallback onClose;

  const NavigationScreenContent({super.key, required this.onClose});

  @override
  State<NavigationScreenContent> createState() =>
      _NavigationScreenContentState();
}

class _NavigationScreenContentState extends State<NavigationScreenContent>
    with TickerProviderStateMixin {
  // ── Destinations Catalog ──────────────────────────────────────────────────
  final List<NavDestination> _destinations = const [
    NavDestination(
      title: 'City Center Mall',
      category: 'Shopping',
      categoryIcon: Icons.shopping_bag_outlined,
      street: 'via Main St & 5th Avenue',
      distanceKm: 8.5,
      durationMinutes: 12,
      batteryArrivalPercent: 72,
      coordinates: Offset(0.82, 0.22),
      nextManeuver: 'Turn right onto Main Street',
      maneuverDistance: 'In 300 m',
      maneuverIcon: Icons.turn_right_rounded,
    ),
    NavDestination(
      title: 'Veltron Supercharger Hub',
      category: 'Charging',
      categoryIcon: Icons.bolt_rounded,
      street: 'via Express Highway E75',
      distanceKm: 4.2,
      durationMinutes: 7,
      batteryArrivalPercent: 74,
      coordinates: Offset(0.28, 0.18),
      nextManeuver: 'Keep left on Highway E75',
      maneuverDistance: 'In 1.2 km',
      maneuverIcon: Icons.fork_left_rounded,
    ),
    NavDestination(
      title: 'Skyline Boulevard',
      category: 'Scenic',
      categoryIcon: Icons.landscape_outlined,
      street: 'via River Parkway',
      distanceKm: 14.8,
      durationMinutes: 18,
      batteryArrivalPercent: 67,
      coordinates: Offset(0.78, 0.82),
      nextManeuver: 'Take exit 4B toward South River',
      maneuverDistance: 'In 800 m',
      maneuverIcon: Icons.turn_slight_right_rounded,
    ),
    NavDestination(
      title: 'Tech Park Station',
      category: 'Work',
      categoryIcon: Icons.business_outlined,
      street: 'via Tesla Avenue',
      distanceKm: 6.1,
      durationMinutes: 9,
      batteryArrivalPercent: 73,
      coordinates: Offset(0.18, 0.45),
      nextManeuver: 'Continue straight for 2.5 km',
      maneuverDistance: 'In 2.5 km',
      maneuverIcon: Icons.straight_rounded,
    ),
    NavDestination(
      title: 'Belgrade Waterfront',
      category: 'Marina',
      categoryIcon: Icons.sailing_outlined,
      street: 'via Boulevard of Peace',
      distanceKm: 11.3,
      durationMinutes: 15,
      batteryArrivalPercent: 70,
      coordinates: Offset(0.55, 0.85),
      nextManeuver: 'Turn left onto Marina Drive',
      maneuverDistance: 'In 450 m',
      maneuverIcon: Icons.turn_left_rounded,
    ),
  ];

  int _selectedDestIndex = 0;

  // ── GPS Puck & Vehicle Movement State ──────────────────────────────────────
  Offset _currentPuckPos = const Offset(0.48, 0.58);
  Offset _startPuckPos = const Offset(0.48, 0.58);
  Offset _targetPuckPos = const Offset(0.82, 0.22);
  double _puckHeading = -math.pi / 4; // Angle in radians

  late final AnimationController _travelController;
  late final Animation<double> _travelAnimation;

  // Radar Pulse Animation
  late final AnimationController _pulseController;

  // Flowing Route Dashes Animation
  late final AnimationController _flowController;

  // ── Navigation Preferences ────────────────────────────────────────────────
  double _zoomLevel = 1.0;
  bool _isVoiceMuted = false;
  bool _isTrafficEnabled = true;
  bool _is3DView = false;
  int _routeTypeIndex = 0; // 0: Fastest, 1: Eco, 2: Shortest

  @override
  void initState() {
    super.initState();

    // Setup travel glide animation
    _travelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _travelAnimation = CurvedAnimation(
      parent: _travelController,
      curve: Curves.fastOutSlowIn,
    )..addListener(_onTravelTick);

    // Setup Radar pulse around vehicle puck
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Setup flowing route trail
    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _targetPuckPos = _destinations[_selectedDestIndex].coordinates;
  }

  @override
  void dispose() {
    _travelController.dispose();
    _pulseController.dispose();
    _flowController.dispose();
    super.dispose();
  }

  void _onTravelTick() {
    final t = _travelAnimation.value;

    // Generate smooth bezier curve trajectory between start and target
    final p0 = _startPuckPos;
    final p2 = _targetPuckPos;
    // Midpoint control offset for organic road curve
    final p1 = Offset(
      (p0.dx + p2.dx) / 2 + (p2.dy - p0.dy) * 0.2,
      (p0.dy + p2.dy) / 2 - (p2.dx - p0.dx) * 0.2,
    );

    // Quadratic Bezier interpolation: B(t) = (1-t)^2*P0 + 2(1-t)t*P1 + t^2*P2
    final invT = 1.0 - t;
    final currentX = invT * invT * p0.dx + 2 * invT * t * p1.dx + t * t * p2.dx;
    final currentY = invT * invT * p0.dy + 2 * invT * t * p1.dy + t * t * p2.dy;

    // Tangent derivative for heading: B'(t) = 2(1-t)(P1 - P0) + 2t(P2 - P1)
    final dx = 2 * invT * (p1.dx - p0.dx) + 2 * t * (p2.dx - p1.dx);
    final dy = 2 * invT * (p1.dy - p0.dy) + 2 * t * (p2.dy - p1.dy);

    setState(() {
      _currentPuckPos = Offset(currentX, currentY);
      if (dx != 0 || dy != 0) {
        _puckHeading = math.atan2(dy, dx) + math.pi / 2;
      }
    });
  }

  /// Triggered when the user selects a destination or taps a waypoint
  void _navigateToDestination(int index) {
    if (index < 0 || index >= _destinations.length) return;

    setState(() {
      _selectedDestIndex = index;
      _startPuckPos = _currentPuckPos;
      _targetPuckPos = _destinations[index].coordinates;
    });

    _travelController.stop();
    _travelController.forward(from: 0.0);
  }

  /// Custom destination picked by tapping anywhere directly on the map
  void _onMapTap(Offset localNormalizedPos) {
    setState(() {
      _startPuckPos = _currentPuckPos;
      _targetPuckPos = localNormalizedPos;
    });

    _travelController.stop();
    _travelController.forward(from: 0.0);
  }

  void _recenterOnVehicle() {
    setState(() {
      _zoomLevel = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeDest = _destinations[_selectedDestIndex];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF07090F),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Interactive Map Canvas ─────────────────────────────────────────
          GestureDetector(
            onTapDown: (details) {
              final box = context.findRenderObject() as RenderBox?;
              if (box != null) {
                final local = box.globalToLocal(details.globalPosition);
                final norm = Offset(
                  (local.dx / box.size.width).clamp(0.05, 0.95),
                  (local.dy / box.size.height).clamp(0.05, 0.95),
                );
                _onMapTap(norm);
              }
            },
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _pulseController,
                _flowController,
                _travelAnimation,
              ]),
              builder: (context, child) {
                return CustomPaint(
                  painter: _VectorMapPainter(
                    puckPosition: _currentPuckPos,
                    targetPosition: _targetPuckPos,
                    puckHeading: _puckHeading,
                    radarPulseProgress: _pulseController.value,
                    routeFlowProgress: _flowController.value,
                    destinations: _destinations,
                    selectedDestIndex: _selectedDestIndex,
                    zoomLevel: _zoomLevel,
                    isTrafficEnabled: _isTrafficEnabled,
                    is3DView: _is3DView,
                  ),
                );
              },
            ),
          ),

          // ── Top Bar: Destination Card + Close Button ───────────────────────
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ActiveDestinationCard(
                    destination: activeDest,
                    onNavigate: () => _navigateToDestination(_selectedDestIndex),
                  ),
                ),
                const SizedBox(width: 12),
                _HeaderCloseButton(onClose: widget.onClose),
              ],
            ),
          ),

          // ── Turn-by-Turn Guidance Banner ───────────────────────────────────
          Positioned(
            top: 106,
            left: 16,
            child: _TurnGuidanceBanner(
              maneuverIcon: activeDest.maneuverIcon,
              instruction: activeDest.nextManeuver,
              distance: activeDest.maneuverDistance,
              isVoiceMuted: _isVoiceMuted,
              onToggleVoice: () => setState(() => _isVoiceMuted = !_isVoiceMuted),
            ),
          ),

          // ── Destination Quick-Select Chips (Horizontal Deck) ───────────────
          Positioned(
            bottom: 84,
            left: 16,
            right: 80,
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _destinations.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final dest = _destinations[index];
                  final isSelected = _selectedDestIndex == index;

                  return _DestinationChip(
                    destination: dest,
                    isSelected: isSelected,
                    onTap: () => _navigateToDestination(index),
                  );
                },
              ),
            ),
          ),

          // ── Floating Map Controls Toolbar (Right Side) ────────────────────
          Positioned(
            right: 16,
            top: 106,
            child: _MapControlDeck(
              zoomLevel: _zoomLevel,
              isTrafficEnabled: _isTrafficEnabled,
              is3DView: _is3DView,
              onZoomIn: () => setState(() => _zoomLevel = (_zoomLevel + 0.15).clamp(0.7, 1.6)),
              onZoomOut: () => setState(() => _zoomLevel = (_zoomLevel - 0.15).clamp(0.7, 1.6)),
              onRecenter: _recenterOnVehicle,
              onToggleTraffic: () => setState(() => _isTrafficEnabled = !_isTrafficEnabled),
              onToggle3D: () => setState(() => _is3DView = !_is3DView),
            ),
          ),

          // ── Bottom Trip Telemetry Bar ──────────────────────────────────────
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _TripTelemetryBar(
              speedKmh: 65,
              speedLimitKmh: 80,
              distanceRemaining: '${activeDest.distanceKm} km',
              durationRemaining: '${activeDest.durationMinutes} min',
              batteryOnArrival: '${activeDest.batteryArrivalPercent}%',
              routeType: _routeTypeIndex == 0
                  ? 'Fastest'
                  : _routeTypeIndex == 1
                      ? 'Eco'
                      : 'Shortest',
              onToggleRouteType: () {
                setState(() {
                  _routeTypeIndex = (_routeTypeIndex + 1) % 3;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vector Map Custom Painter
// ─────────────────────────────────────────────────────────────────────────────

class _VectorMapPainter extends CustomPainter {
  final Offset puckPosition;
  final Offset targetPosition;
  final double puckHeading;
  final double radarPulseProgress;
  final double routeFlowProgress;
  final List<NavDestination> destinations;
  final int selectedDestIndex;
  final double zoomLevel;
  final bool isTrafficEnabled;
  final bool is3DView;

  _VectorMapPainter({
    required this.puckPosition,
    required this.targetPosition,
    required this.puckHeading,
    required this.radarPulseProgress,
    required this.routeFlowProgress,
    required this.destinations,
    required this.selectedDestIndex,
    required this.zoomLevel,
    required this.isTrafficEnabled,
    required this.is3DView,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background deep dark obsidian base
    final bgPaint = Paint()..color = const Color(0xFF090B12);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Subtle grid mesh
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 0.8;
    const gridStep = 54.0;
    for (double x = 0; x < size.width; x += gridStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // ── Waterway / River Canal ──────────────────────────────────────────────
    final riverPath = Path();
    riverPath.moveTo(0, size.height * 0.45);
    riverPath.cubicTo(
      size.width * 0.35,
      size.height * 0.40,
      size.width * 0.65,
      size.height * 0.60,
      size.width,
      size.height * 0.55,
    );
    riverPath.lineTo(size.width, size.height * 0.68);
    riverPath.cubicTo(
      size.width * 0.65,
      size.height * 0.72,
      size.width * 0.35,
      size.height * 0.52,
      0,
      size.height * 0.58,
    );
    riverPath.close();

    final riverPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF0B192E),
          Color(0xFF0E233E),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(riverPath, riverPaint);

    // ── City Blocks Matrix ──────────────────────────────────────────────────
    final blockPaint = Paint()
      ..color = const Color(0xFF131622)
      ..style = PaintingStyle.fill;

    final blockBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final cityBlocks = [
      Rect.fromLTWH(size.width * 0.06, size.height * 0.12, size.width * 0.16, size.height * 0.14),
      Rect.fromLTWH(size.width * 0.26, size.height * 0.08, size.width * 0.18, size.height * 0.12),
      Rect.fromLTWH(size.width * 0.52, size.height * 0.10, size.width * 0.22, size.height * 0.16),
      Rect.fromLTWH(size.width * 0.08, size.height * 0.70, size.width * 0.20, size.height * 0.18),
      Rect.fromLTWH(size.width * 0.34, size.height * 0.74, size.width * 0.16, size.height * 0.15),
      Rect.fromLTWH(size.width * 0.64, size.height * 0.68, size.width * 0.26, size.height * 0.20),
      Rect.fromLTWH(size.width * 0.78, size.height * 0.32, size.width * 0.16, size.height * 0.18),
    ];

    for (final rect in cityBlocks) {
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
      canvas.drawRRect(rrect, blockPaint);
      canvas.drawRRect(rrect, blockBorderPaint);
    }

    // ── Road Network ────────────────────────────────────────────────────────
    final highwayUnderlay = Paint()
      ..color = const Color(0xFF1B1E2E)
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final streetPaint = Paint()
      ..color = const Color(0xFF161926)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

    // Secondary streets
    canvas.drawLine(Offset(0, size.height * 0.30), Offset(size.width, size.height * 0.30), streetPaint);
    canvas.drawLine(Offset(0, size.height * 0.72), Offset(size.width, size.height * 0.72), streetPaint);
    canvas.drawLine(Offset(size.width * 0.25, 0), Offset(size.width * 0.25, size.height), streetPaint);
    canvas.drawLine(Offset(size.width * 0.50, 0), Offset(size.width * 0.50, size.height), streetPaint);
    canvas.drawLine(Offset(size.width * 0.76, 0), Offset(size.width * 0.76, size.height), streetPaint);

    // Primary Expressway / Highway Curve
    final highwayPath = Path();
    highwayPath.moveTo(0, size.height * 0.85);
    highwayPath.cubicTo(
      size.width * 0.30,
      size.height * 0.80,
      size.width * 0.45,
      size.height * 0.30,
      size.width,
      size.height * 0.20,
    );
    canvas.drawPath(highwayPath, highwayUnderlay);

    // Live Traffic overlay (Green flow with slight amber slowdown)
    if (isTrafficEnabled) {
      final trafficGreen = Paint()
        ..color = const Color(0xFF00E676).withValues(alpha: 0.35)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;
      canvas.drawPath(highwayPath, trafficGreen);

      // Congestion segment
      final trafficSlow = Paint()
        ..color = const Color(0xFFFFB300).withValues(alpha: 0.55)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke;

      final slowPath = Path();
      slowPath.moveTo(size.width * 0.32, size.height * 0.65);
      slowPath.lineTo(size.width * 0.44, size.height * 0.45);
      canvas.drawPath(slowPath, trafficSlow);
    }

    // ── Active Navigation Route (Multi-Layer Neon Trail) ─────────────────────
    final startPt = Offset(puckPosition.dx * size.width, puckPosition.dy * size.height);
    final targetPt = Offset(targetPosition.dx * size.width, targetPosition.dy * size.height);

    final midControl = Offset(
      (startPt.dx + targetPt.dx) / 2 + (targetPt.dy - startPt.dy) * 0.2,
      (startPt.dy + targetPt.dy) / 2 - (targetPt.dx - startPt.dx) * 0.2,
    );

    final routePath = Path();
    routePath.moveTo(startPt.dx, startPt.dy);
    routePath.quadraticBezierTo(midControl.dx, midControl.dy, targetPt.dx, targetPt.dy);

    // Outer route halo glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFF8A00).withValues(alpha: 0.25)
      ..strokeWidth = 16.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(routePath, glowPaint);

    // Secondary bright orange boundary
    final routeOutline = Paint()
      ..color = const Color(0xFFFF8A00).withValues(alpha: 0.7)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(routePath, routeOutline);

    // Core bright neon route line
    final routeCore = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(routePath, routeCore);

    // ── Destination Waypoint Markers ─────────────────────────────────────────
    for (int i = 0; i < destinations.length; i++) {
      final dest = destinations[i];
      final pt = Offset(dest.coordinates.dx * size.width, dest.coordinates.dy * size.height);
      final isSelected = i == selectedDestIndex;

      _drawWaypointPin(canvas, pt, isSelected, dest.title);
    }

    // ── Vehicle GPS Puck with Heading & Radar Ripple ─────────────────────────
    _drawVehiclePuck(canvas, startPt, puckHeading, radarPulseProgress);
  }

  void _drawWaypointPin(Canvas canvas, Offset point, bool isSelected, String label) {
    if (isSelected) {
      // Glow ring around selected destination
      final glowPaint = Paint()
        ..color = const Color(0xFFFF8A00).withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 18, glowPaint);

      // Pin core
      final pinPaint = Paint()
        ..color = const Color(0xFFFF8A00)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 10, pinPaint);

      final innerWhite = Paint()..color = Colors.white;
      canvas.drawCircle(point, 4, innerWhite);

      // Destination Tag Card above pin
      final tagRect = Rect.fromCenter(
        center: Offset(point.dx, point.dy - 24),
        width: 100,
        height: 22,
      );
      final tagRRect = RRect.fromRectAndRadius(tagRect, const Radius.circular(6));

      final tagBg = Paint()..color = const Color(0xFF10121C);
      final tagBorder = Paint()
        ..color = const Color(0xFFFF8A00).withValues(alpha: 0.7)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      canvas.drawRRect(tagRRect, tagBg);
      canvas.drawRRect(tagRRect, tagBorder);
    } else {
      // Unselected subtle waypoint
      final bg = Paint()..color = const Color(0xFF1E2234);
      final border = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(point, 7, bg);
      canvas.drawCircle(point, 7, border);
    }
  }

  void _drawVehiclePuck(
    Canvas canvas,
    Offset position,
    double heading,
    double radarProgress,
  ) {
    // 1. Radar wave ripple expanding outward
    final radarRadius = 14.0 + (radarProgress * 28.0);
    final radarOpacity = (1.0 - radarProgress).clamp(0.0, 1.0) * 0.45;

    final radarPaint = Paint()
      ..color = const Color(0xFF00E676).withValues(alpha: radarOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(position, radarRadius, radarPaint);

    // 2. Outer glowing disc
    final glowPaint = Paint()
      ..color = const Color(0xFF00E676).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 18, glowPaint);

    // 3. Central Puck
    final puckBg = Paint()..color = const Color(0xFF00E676);
    canvas.drawCircle(position, 11, puckBg);

    final puckBorder = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(position, 11, puckBorder);

    // 4. Directional Heading Arrowhead
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(heading);

    final arrowPath = Path();
    arrowPath.moveTo(0, -6);
    arrowPath.lineTo(4, 4);
    arrowPath.lineTo(0, 2);
    arrowPath.lineTo(-4, 4);
    arrowPath.close();

    final arrowPaint = Paint()..color = Colors.white;
    canvas.drawPath(arrowPath, arrowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _VectorMapPainter oldDelegate) {
    return oldDelegate.puckPosition != puckPosition ||
        oldDelegate.targetPosition != targetPosition ||
        oldDelegate.puckHeading != puckHeading ||
        oldDelegate.radarPulseProgress != radarPulseProgress ||
        oldDelegate.routeFlowProgress != routeFlowProgress ||
        oldDelegate.selectedDestIndex != selectedDestIndex ||
        oldDelegate.zoomLevel != zoomLevel ||
        oldDelegate.isTrafficEnabled != isTrafficEnabled ||
        oldDelegate.is3DView != is3DView;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Active Destination Card (Top-Left Deck)
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveDestinationCard extends StatelessWidget {
  final NavDestination destination;
  final VoidCallback onNavigate;

  const _ActiveDestinationCard({
    required this.destination,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A00).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFFF8A00).withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Icon(
                  destination.categoryIcon,
                  color: const Color(0xFFFF8A00),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      destination.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          '${destination.distanceKm} km',
                          style: const TextStyle(
                            color: Color(0xFFFF8A00),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '·  ${destination.durationMinutes} min',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            destination.street,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onNavigate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8A00),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF8A00).withValues(alpha: 0.4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.near_me_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Recalculate',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
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
// Turn-by-Turn Guidance Banner
// ─────────────────────────────────────────────────────────────────────────────

class _TurnGuidanceBanner extends StatelessWidget {
  final IconData maneuverIcon;
  final String instruction;
  final String distance;
  final bool isVoiceMuted;
  final VoidCallback onToggleVoice;

  const _TurnGuidanceBanner({
    required this.maneuverIcon,
    required this.instruction,
    required this.distance,
    required this.isVoiceMuted,
    required this.onToggleVoice,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFF8A00).withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A00).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFF8A00).withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Icon(
                  maneuverIcon,
                  color: const Color(0xFFFF8A00),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    instruction,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    distance,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: onToggleVoice,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isVoiceMuted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    color: isVoiceMuted
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.8),
                    size: 16,
                  ),
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
// Destination Quick-Select Chips
// ─────────────────────────────────────────────────────────────────────────────

class _DestinationChip extends StatelessWidget {
  final NavDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  const _DestinationChip({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF241C10)
                  : Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFF8A00).withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  destination.categoryIcon,
                  color: isSelected
                      ? const Color(0xFFFF8A00)
                      : Colors.white.withValues(alpha: 0.6),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  destination.title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${destination.distanceKm} km',
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFFFF8A00)
                        : Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating Map Controls Toolbar
// ─────────────────────────────────────────────────────────────────────────────

class _MapControlDeck extends StatelessWidget {
  final double zoomLevel;
  final bool isTrafficEnabled;
  final bool is3DView;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onRecenter;
  final VoidCallback onToggleTraffic;
  final VoidCallback onToggle3D;

  const _MapControlDeck({
    required this.zoomLevel,
    required this.isTrafficEnabled,
    required this.is3DView,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onRecenter,
    required this.onToggleTraffic,
    required this.onToggle3D,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ControlIconButton(
                icon: Icons.my_location_rounded,
                tooltip: 'Recenter',
                onTap: onRecenter,
              ),
              _DividerLine(),
              _ControlIconButton(
                icon: Icons.add_rounded,
                tooltip: 'Zoom in',
                onTap: onZoomIn,
              ),
              _ControlIconButton(
                icon: Icons.remove_rounded,
                tooltip: 'Zoom out',
                onTap: onZoomOut,
              ),
              _DividerLine(),
              _ControlIconButton(
                icon: Icons.traffic_rounded,
                active: isTrafficEnabled,
                tooltip: 'Traffic',
                onTap: onToggleTraffic,
              ),
              _ControlIconButton(
                icon: Icons.view_in_ar_rounded,
                active: is3DView,
                tooltip: '3D View',
                onTap: onToggle3D,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool active;
  final VoidCallback onTap;

  const _ControlIconButton({
    required this.icon,
    required this.tooltip,
    this.active = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFFFF8A00).withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: active ? const Color(0xFFFF8A00) : Colors.white70,
          size: 18,
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.white.withValues(alpha: 0.1),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Trip Telemetry Bar
// ─────────────────────────────────────────────────────────────────────────────

class _TripTelemetryBar extends StatelessWidget {
  final int speedKmh;
  final int speedLimitKmh;
  final String distanceRemaining;
  final String durationRemaining;
  final String batteryOnArrival;
  final String routeType;
  final VoidCallback onToggleRouteType;

  const _TripTelemetryBar({
    required this.speedKmh,
    required this.speedLimitKmh,
    required this.distanceRemaining,
    required this.durationRemaining,
    required this.batteryOnArrival,
    required this.routeType,
    required this.onToggleRouteType,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Speed & Speed Limit Sign
              Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$speedKmh',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'km/h',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFF5252), width: 2),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Text(
                        '$speedLimitKmh',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              _TelemetryDivider(),

              // Distance remaining
              _TelemetryItem(
                icon: Icons.straighten_rounded,
                label: 'Distance',
                value: distanceRemaining,
              ),

              _TelemetryDivider(),

              // Duration remaining / ETA
              _TelemetryItem(
                icon: Icons.timer_outlined,
                label: 'Duration',
                value: durationRemaining,
              ),

              _TelemetryDivider(),

              // Battery on arrival
              _TelemetryItem(
                icon: Icons.battery_charging_full_rounded,
                iconColor: const Color(0xFF00E676),
                label: 'Battery Arrival',
                value: batteryOnArrival,
              ),

              _TelemetryDivider(),

              // Route mode toggle
              GestureDetector(
                onTap: onToggleRouteType,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.alt_route_rounded, color: Color(0xFFFF8A00), size: 16),
                    const SizedBox(height: 4),
                    Text(
                      routeType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to change',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10,
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

class _TelemetryDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white.withValues(alpha: 0.08),
    );
  }
}

class _TelemetryItem extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String value;

  const _TelemetryItem({
    required this.icon,
    this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor ?? const Color(0xFFFF8A00), size: 16),
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

// ─────────────────────────────────────────────────────────────────────────────
// Header Close Button
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderCloseButton extends StatelessWidget {
  final VoidCallback onClose;

  const _HeaderCloseButton({required this.onClose});

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
