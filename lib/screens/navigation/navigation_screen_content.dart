import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Comprehensive destination model with spatial and telemetry properties
class NavDestination {
  final String title;
  final String category;
  final IconData categoryIcon;
  final String street;
  final double distanceKm;
  final int durationMinutes;
  final int batteryArrivalPercent;
  final LatLng coordinates; // Real-world map coordinates
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
      coordinates: LatLng(44.8125, 20.4612),
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
      coordinates: LatLng(44.8000, 20.4300),
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
      coordinates: LatLng(44.7700, 20.4900),
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
      coordinates: LatLng(44.7500, 20.4100),
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
      coordinates: LatLng(44.8200, 20.4550),
      nextManeuver: 'Turn left onto Marina Drive',
      maneuverDistance: 'In 450 m',
      maneuverIcon: Icons.turn_left_rounded,
    ),
  ];

  int _selectedDestIndex = 0;

  // ── GPS Puck & Vehicle Movement State ──────────────────────────────────────
  // Real-world positions used by flutter_map; the simulated painter projects
  // them back to normalized 0-1 canvas coords via _project().
  static const LatLng _belgradeCenter = LatLng(44.7866, 20.4489);
  LatLng _currentPuckLatLng = _belgradeCenter;
  LatLng _startPuckLatLng = _belgradeCenter;
  LatLng _targetPuckLatLng = _belgradeCenter;
  double _puckHeading = -math.pi / 4; // Angle in radians

  /// Whether flutter_map + OSM tiles are reachable. Falls back to the
  /// hand-painted simulated map when the tile server can't be contacted.
  bool _useRealMap = true;

  /// Current zoom level for flutter_map (driven by the +/- buttons).
  double _zoom = 13;

  late final MapController _mapController;
  late final AnimationController _travelController;
  late final Animation<double> _travelAnimation;

  // Radar Pulse Animation
  late final AnimationController _pulseController;

  // ── Navigation Preferences ────────────────────────────────────────────────
  bool _isVoiceMuted = false;
  bool _isTrafficEnabled = true;

  @override
  void initState() {
    super.initState();

    _mapController = MapController();

    // Reachability probe: can we reach the OSM tile server? If not, fall back
    // to the hand-painted simulated map so the screen still renders offline.
    _probeTileServer();

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

    _targetPuckLatLng = _destinations[_selectedDestIndex].coordinates;
  }

  /// Lightly probes the OSM tile server. On success the real map is used; on
  /// failure (offline / blocked) we silently fall back to the simulated map.
  Future<void> _probeTileServer() async {
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 3);
      final request = await client.openUrl(
        'GET',
        Uri.parse('https://tile.openstreetmap.org/13/4193/2666.png'),
      );
      final response = await request.close();
      await response.drain();
      _useRealMap = response.statusCode == 200;
    } catch (_) {
      _useRealMap = false;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _travelController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTravelTick() {
    final t = _travelAnimation.value;

    // Generate smooth bezier curve trajectory between start and target
    final p0 = _startPuckLatLng;
    final p2 = _targetPuckLatLng;
    // Midpoint control offset for organic road curve
    final p1 = LatLng(
      (p0.latitude + p2.latitude) / 2 + (p2.longitude - p0.longitude) * 0.0004,
      (p0.longitude + p2.longitude) / 2 - (p2.latitude - p0.latitude) * 0.0004,
    );

    // Quadratic Bezier interpolation: B(t) = (1-t)^2*P0 + 2(1-t)t*P1 + t^2*P2
    final invT = 1.0 - t;
    final currentLat =
        invT * invT * p0.latitude + 2 * invT * t * p1.latitude + t * t * p2.latitude;
    final currentLng =
        invT * invT * p0.longitude + 2 * invT * t * p1.longitude + t * t * p2.longitude;

    // Tangent derivative for heading: B'(t) = 2(1-t)(P1 - P0) + 2t(P2 - P1)
    final dLat = 2 * invT * (p1.latitude - p0.latitude) + 2 * t * (p2.latitude - p1.latitude);
    final dLng = 2 * invT * (p1.longitude - p0.longitude) + 2 * t * (p2.longitude - p1.longitude);

    if (dLat != 0 || dLng != 0) {
      _currentPuckLatLng = LatLng(currentLat, currentLng);
      _puckHeading = math.atan2(dLat, dLng) + math.pi / 2;
    } else {
      _currentPuckLatLng = LatLng(currentLat, currentLng);
    }
    // flutter_map reads these fields on rebuild; keep the puck + route moving.
    setState(() {});
  }

  /// Triggered when the user selects a destination or taps a waypoint
  void _navigateToDestination(int index) {
    if (index < 0 || index >= _destinations.length) return;

    setState(() {
      _selectedDestIndex = index;
      _startPuckLatLng = _currentPuckLatLng;
      _targetPuckLatLng = _destinations[index].coordinates;
    });

    _travelController.stop();
    _travelController.forward(from: 0.0);
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
          // ── Map background: real OSM tiles, simulated fallback ─────────────
          _mapBody(),

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
                    onNavigate: () =>
                        _navigateToDestination(_selectedDestIndex),
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
              onToggleVoice: () =>
                  setState(() => _isVoiceMuted = !_isVoiceMuted),
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
              isTrafficEnabled: _isTrafficEnabled,
              onToggleTraffic: () =>
                  setState(() => _isTrafficEnabled = !_isTrafficEnabled),
              onRecenter: _recenter,
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
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
              routeType: 'Demo route',
            ),
          ),
        ],
      ),
    );
  }

  /// Real OSM tile map (flutter_map) with puck, destinations, route and
  /// attribution, or the hand-painted simulated map when the tile server is
  /// unreachable.
  Widget _mapBody() {
    if (!_useRealMap) {
      return _simulatedMap();
    }
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentPuckLatLng,
        initialZoom: _zoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          minZoom: 1,
          maxZoom: 19,
          maxNativeZoom: 19,
          userAgentPackageName: 'skyui',
        ),
        MarkerLayer(
          markers: [
            // Vehicle GPS puck with heading
            Marker(
              point: _currentPuckLatLng,
              width: 34,
              height: 34,
              child: Transform.rotate(
                angle: _puckHeading,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF00E676),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x8000E676),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            // Destination waypoints
            for (int i = 0; i < _destinations.length; i++) ...[
              Marker(
                point: _destinations[i].coordinates,
                width: 22,
                height: 22,
                child: Container(
                  decoration: BoxDecoration(
                    color: i == _selectedDestIndex
                        ? const Color(0xFFFF8A00)
                        : Colors.white10,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: i == _selectedDestIndex
                      ? const Icon(
                          Icons.navigation,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ),
            ],
          ],
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: _routePoints(),
              strokeWidth: 4,
              color: const Color(0xFFFF8A00),
            ),
          ],
        ),
        const SimpleAttributionWidget(
          source: Text('OpenStreetMap contributors'),
          alignment: Alignment.bottomLeft,
          backgroundColor: Color(0x7F000000),
        ),
      ],
    );
  }

  /// Intermediate points along the puck→target bezier so the route polyline
  /// reads as a curved road rather than a straight chord.
  List<LatLng> _routePoints() {
    final p0 = _startPuckLatLng;
    final p2 = _targetPuckLatLng;
    final p1 = LatLng(
      (p0.latitude + p2.latitude) / 2 + (p2.longitude - p0.longitude) * 0.0004,
      (p0.longitude + p2.longitude) / 2 - (p2.latitude - p0.latitude) * 0.0004,
    );
    return List.generate(11, (i) {
      final t = i / 10;
      final inv = 1 - t;
      return LatLng(
        inv * inv * p0.latitude + 2 * inv * t * p1.latitude + t * t * p2.latitude,
        inv * inv * p0.longitude + 2 * inv * t * p1.longitude + t * t * p2.longitude,
      );
    });
  }

  /// Camera controls wired to [MapController].
  void _recenter() {
    _mapController.move(_currentPuckLatLng, _zoom);
  }

  void _zoomIn() {
    _zoom = (_zoom + 1).clamp(1, 19);
    _mapController.move(_currentPuckLatLng, _zoom);
  }

  void _zoomOut() {
    _zoom = (_zoom - 1).clamp(1, 19);
    _mapController.move(_currentPuckLatLng, _zoom);
  }

  /// Hand-painted simulated map used when the OSM tile server is unreachable.
  /// Projects real-world [LatLng] positions onto the old normalized canvas.
  Widget _simulatedMap() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _travelAnimation]),
      builder: (context, child) {
        return RepaintBoundary(
          child: CustomPaint(
            painter: _VectorMapPainter(
              puckPosition: _project(_currentPuckLatLng),
              targetPosition: _project(_targetPuckLatLng),
              puckHeading: _puckHeading,
              radarPulseProgress: _pulseController.value,
              destinationPoints: _destinations
                  .map((d) => _project(d.coordinates))
                  .toList(),
              destinationTitles: _destinations.map((d) => d.title).toList(),
              selectedDestIndex: _selectedDestIndex,
              isTrafficEnabled: _isTrafficEnabled,
            ),
          ),
        );
      },
    );
  }

  /// Projects a real-world [LatLng] onto the 0-1 normalized canvas used by the
  /// simulated painter. Bounding box roughly covers central Belgrade.
  Offset _project(LatLng p) {
    const south = 44.7450;
    const north = 44.8300;
    const west = 20.3900;
    const east = 20.5100;
    final x = ((p.longitude - west) / (east - west)).clamp(0.0, 1.0);
    final y = ((north - p.latitude) / (north - south)).clamp(0.0, 1.0);
    return Offset(x, y);
  }

}

class _VectorMapPainter extends CustomPainter {
  final Offset puckPosition;
  final Offset targetPosition;
  final double puckHeading;
  final double radarPulseProgress;
  /// Pre-projected waypoint positions (0-1 canvas space) — the painter itself
  /// does not geocode, so [NavigationScreenContent] projects via [_project].
  final List<Offset> destinationPoints;
  final List<String> destinationTitles;
  final int selectedDestIndex;
  final bool isTrafficEnabled;

  _VectorMapPainter({
    required this.puckPosition,
    required this.targetPosition,
    required this.puckHeading,
    required this.radarPulseProgress,
    required this.destinationPoints,
    required this.destinationTitles,
    required this.selectedDestIndex,
    required this.isTrafficEnabled,
  });

  // ── Cached paints ──────────────────────────────────────────────────────────
  // The radar pulse repaints this painter continuously, so constant styles are
  // allocated once instead of ~25 objects per frame (audit P-03).
  static final Paint _bgPaint = Paint()..color = const Color(0xFF090B12);

  static final Paint _gridPaint = Paint()
    ..color = const Color(0x0AFFFFFF)
    ..strokeWidth = 0.8;

  static final Paint _riverPaint = Paint();
  static Size? _riverShaderSize;
  static Shader? _riverShader;

  static final Paint _blockPaint = Paint()
    ..color = const Color(0xFF131622)
    ..style = PaintingStyle.fill;

  static final Paint _blockBorderPaint = Paint()
    ..color = const Color(0x08FFFFFF)
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  static final Paint _highwayUnderlay = Paint()
    ..color = const Color(0xFF1B1E2E)
    ..strokeWidth = 18.0
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  static final Paint _streetPaint = Paint()
    ..color = const Color(0xFF161926)
    ..strokeWidth = 8.0
    ..style = PaintingStyle.stroke;

  static final Paint _trafficGreen = Paint()
    ..color = const Color(0x5900E676)
    ..strokeWidth = 3.0
    ..style = PaintingStyle.stroke;

  static final Paint _trafficSlow = Paint()
    ..color = const Color(0x8CFFB300)
    ..strokeWidth = 3.5
    ..style = PaintingStyle.stroke;

  static final Paint _routeGlow = Paint()
    ..color = const Color(0x40FF8A00)
    ..strokeWidth = 16.0
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  static final Paint _routeOutline = Paint()
    ..color = const Color(0xB3FF8A00)
    ..strokeWidth = 6.0
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  static final Paint _routeCore = Paint()
    ..color = Colors.white
    ..strokeWidth = 2.5
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  static final Paint _waypointGlow = Paint()
    ..color = const Color(0x66FF8A00)
    ..style = PaintingStyle.fill;

  static final Paint _waypointPin = Paint()
    ..color = const Color(0xFFFF8A00)
    ..style = PaintingStyle.fill;

  static final Paint _waypointCore = Paint()..color = Colors.white;

  static final Paint _tagBg = Paint()..color = const Color(0xFF10121C);

  static final Paint _tagBorder = Paint()
    ..color = const Color(0xB3FF8A00)
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  static final Paint _waypointIdleBg = Paint()..color = const Color(0xFF1E2234);

  static final Paint _waypointIdleBorder = Paint()
    ..color = const Color(0x4DFFFFFF)
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;

  static final Paint _puckGlow = Paint()
    ..color = const Color(0x4000E676)
    ..style = PaintingStyle.fill;

  static final Paint _puckBg = Paint()..color = const Color(0xFF00E676);

  static final Paint _puckBorder = Paint()
    ..color = Colors.white
    ..strokeWidth = 2.5
    ..style = PaintingStyle.stroke;

  static final Paint _radarPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  static final Paint _arrowPaint = Paint()..color = Colors.white;

  static final ui.Path _arrowPath = ui.Path()
    ..moveTo(0, -6)
    ..lineTo(4, 4)
    ..lineTo(0, 2)
    ..lineTo(-4, 4)
    ..close();

  /// River gradient shader is size-dependent; cache it per size instead of
  /// creating a new shader every paint.
  static Shader _riverShaderFor(Size size) {
    if (_riverShaderSize != size || _riverShader == null) {
      _riverShaderSize = size;
      _riverShader = const LinearGradient(
        colors: [Color(0xFF0B192E), Color(0xFF0E233E)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    }
    return _riverShader!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Background deep dark obsidian base
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _bgPaint);

    // Subtle grid mesh
    const gridStep = 54.0;
    for (double x = 0; x < size.width; x += gridStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), _gridPaint);
    }
    for (double y = 0; y < size.height; y += gridStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _gridPaint);
    }

    // ── Waterway / River Canal ──────────────────────────────────────────────
    final ui.Path riverPath = ui.Path();
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

    _riverPaint.shader = _riverShaderFor(size);
    canvas.drawPath(riverPath, _riverPaint);

    // ── City Blocks Matrix ──────────────────────────────────────────────────
    final cityBlocks = [
      Rect.fromLTWH(
        size.width * 0.06,
        size.height * 0.12,
        size.width * 0.16,
        size.height * 0.14,
      ),
      Rect.fromLTWH(
        size.width * 0.26,
        size.height * 0.08,
        size.width * 0.18,
        size.height * 0.12,
      ),
      Rect.fromLTWH(
        size.width * 0.52,
        size.height * 0.10,
        size.width * 0.22,
        size.height * 0.16,
      ),
      Rect.fromLTWH(
        size.width * 0.08,
        size.height * 0.70,
        size.width * 0.20,
        size.height * 0.18,
      ),
      Rect.fromLTWH(
        size.width * 0.34,
        size.height * 0.74,
        size.width * 0.16,
        size.height * 0.15,
      ),
      Rect.fromLTWH(
        size.width * 0.64,
        size.height * 0.68,
        size.width * 0.26,
        size.height * 0.20,
      ),
      Rect.fromLTWH(
        size.width * 0.78,
        size.height * 0.32,
        size.width * 0.16,
        size.height * 0.18,
      ),
    ];

    for (final rect in cityBlocks) {
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
      canvas.drawRRect(rrect, _blockPaint);
      canvas.drawRRect(rrect, _blockBorderPaint);
    }

    // ── Road Network ────────────────────────────────────────────────────────
    // Secondary streets
    canvas.drawLine(
      Offset(0, size.height * 0.30),
      Offset(size.width, size.height * 0.30),
      _streetPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.72),
      Offset(size.width, size.height * 0.72),
      _streetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.25, 0),
      Offset(size.width * 0.25, size.height),
      _streetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.50, 0),
      Offset(size.width * 0.50, size.height),
      _streetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.76, 0),
      Offset(size.width * 0.76, size.height),
      _streetPaint,
    );

    // Primary Expressway / Highway Curve
    final ui.Path highwayPath = ui.Path();
    highwayPath.moveTo(0, size.height * 0.85);
    highwayPath.cubicTo(
      size.width * 0.30,
      size.height * 0.80,
      size.width * 0.45,
      size.height * 0.30,
      size.width,
      size.height * 0.20,
    );
    canvas.drawPath(highwayPath, _highwayUnderlay);

    // Live Traffic overlay (Green flow with slight amber slowdown)
    if (isTrafficEnabled) {
      canvas.drawPath(highwayPath, _trafficGreen);

      // Congestion segment
      final ui.Path slowPath = ui.Path();
      slowPath.moveTo(size.width * 0.32, size.height * 0.65);
      slowPath.lineTo(size.width * 0.44, size.height * 0.45);
      canvas.drawPath(slowPath, _trafficSlow);
    }

    // ── Active Navigation Route (Multi-Layer Neon Trail) ─────────────────────
    final startPt = Offset(
      puckPosition.dx * size.width,
      puckPosition.dy * size.height,
    );
    final targetPt = Offset(
      targetPosition.dx * size.width,
      targetPosition.dy * size.height,
    );

    final midControl = Offset(
      (startPt.dx + targetPt.dx) / 2 + (targetPt.dy - startPt.dy) * 0.2,
      (startPt.dy + targetPt.dy) / 2 - (targetPt.dx - startPt.dx) * 0.2,
    );

    final ui.Path routePath = ui.Path();
    routePath.moveTo(startPt.dx, startPt.dy);
    routePath.quadraticBezierTo(
      midControl.dx,
      midControl.dy,
      targetPt.dx,
      targetPt.dy,
    );

    // Outer route halo glow
    canvas.drawPath(routePath, _routeGlow);

    // Secondary bright orange boundary
    canvas.drawPath(routePath, _routeOutline);

    // Core bright neon route line
    canvas.drawPath(routePath, _routeCore);

    // ── Destination Waypoint Markers ─────────────────────────────────────────
    for (int i = 0; i < destinationPoints.length; i++) {
      final pt = destinationPoints[i];
      final title = destinationTitles[i];
      final isSelected = i == selectedDestIndex;

      _drawWaypointPin(canvas, pt, isSelected, title);
    }

    // ── Vehicle GPS Puck with Heading & Radar Ripple ─────────────────────────
    _drawVehiclePuck(canvas, startPt, puckHeading, radarPulseProgress);
  }

  void _drawWaypointPin(
    Canvas canvas,
    Offset point,
    bool isSelected,
    String label,
  ) {
    if (isSelected) {
      // Glow ring around selected destination
      canvas.drawCircle(point, 18, _waypointGlow);

      // Pin core
      canvas.drawCircle(point, 10, _waypointPin);
      canvas.drawCircle(point, 4, _waypointCore);

      // Destination Tag Card above pin
      final tagRect = Rect.fromCenter(
        center: Offset(point.dx, point.dy - 24),
        width: 100,
        height: 22,
      );
      final tagRRect = RRect.fromRectAndRadius(
        tagRect,
        const Radius.circular(6),
      );

      canvas.drawRRect(tagRRect, _tagBg);
      canvas.drawRRect(tagRRect, _tagBorder);
    } else {
      // Unselected subtle waypoint
      canvas.drawCircle(point, 7, _waypointIdleBg);
      canvas.drawCircle(point, 7, _waypointIdleBorder);
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

    _radarPaint.color = const Color(0xFF00E676).withValues(alpha: radarOpacity);
    canvas.drawCircle(position, radarRadius, _radarPaint);

    // 2. Outer glowing disc
    canvas.drawCircle(position, 18, _puckGlow);

    // 3. Central Puck
    canvas.drawCircle(position, 11, _puckBg);
    canvas.drawCircle(position, 11, _puckBorder);

    // 4. Directional Heading Arrowhead
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(heading);
    canvas.drawPath(_arrowPath, _arrowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _VectorMapPainter oldDelegate) {
    return oldDelegate.puckPosition != puckPosition ||
        oldDelegate.targetPosition != targetPosition ||
        oldDelegate.puckHeading != puckHeading ||
        oldDelegate.radarPulseProgress != radarPulseProgress ||
        oldDelegate.selectedDestIndex != selectedDestIndex ||
        oldDelegate.isTrafficEnabled != isTrafficEnabled;
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.85),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.84),
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
            Semantics(
              button: true,
              toggled: isVoiceMuted,
              label: isVoiceMuted
                  ? 'Voice guidance muted'
                  : 'Voice guidance on',
              onTap: onToggleVoice,
              excludeSemantics: true,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.06),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onToggleVoice,
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: 32,
                        height: 32,
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
                  ),
                ),
              ),
            ),
          ],
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF241C10)
                : Colors.black.withValues(alpha: 0.78),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating Map Controls Toolbar
// ─────────────────────────────────────────────────────────────────────────────

class _MapControlDeck extends StatelessWidget {
  final bool isTrafficEnabled;
  final VoidCallback onToggleTraffic;
  final VoidCallback onRecenter;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const _MapControlDeck({
    required this.isTrafficEnabled,
    required this.onToggleTraffic,
    required this.onRecenter,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.84),
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
              tooltip: 'Recenter on vehicle',
              onTap: onRecenter,
            ),
            const _DividerLine(),
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
            const _DividerLine(),
            _ControlIconButton(
              icon: Icons.traffic_rounded,
              active: isTrafficEnabled,
              isToggle: true,
              tooltip: 'Traffic',
              onTap: onToggleTraffic,
            ),
            const _ControlIconButton(
              icon: Icons.view_in_ar_rounded,
              tooltip: '3D view — unavailable in prototype',
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool active;
  final bool isToggle;
  final VoidCallback? onTap;

  const _ControlIconButton({
    required this.icon,
    required this.tooltip,
    this.active = false,
    this.isToggle = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      toggled: isToggle ? active : null,
      label: tooltip,
      onTap: onTap,
      excludeSemantics: true,
      child: Tooltip(
        message: tooltip,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Material(
              color: active
                  ? const Color(0xFFFF8A00).withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(
                    icon,
                    color: active
                        ? const Color(0xFFFF8A00)
                        : enabled
                        ? Colors.white70
                        : Colors.white24,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

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

  const _TripTelemetryBar({
    required this.speedKmh,
    required this.speedLimitKmh,
    required this.distanceRemaining,
    required this.durationRemaining,
    required this.batteryOnArrival,
    required this.routeType,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.85),
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
                    border: Border.all(
                      color: const Color(0xFFFF5252),
                      width: 2,
                    ),
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
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.alt_route_rounded,
                  color: Color(0xFFFF8A00),
                  size: 16,
                ),
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
                  'Simulated',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
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
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.84),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
