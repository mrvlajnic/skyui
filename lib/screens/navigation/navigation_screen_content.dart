import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/place.dart';
import '../../models/route_plan.dart';
import '../../services/geocoding_service.dart';
import '../../services/routing_service.dart';
import '../../widgets/map/map_attribution.dart';
import '../../widgets/map/map_style.dart';
import '../../widgets/map/map_vehicle_puck.dart';
import '../../widgets/map/tile_probe.dart';
import 'place_search_panel.dart';

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

  /// Optional injected search service, used by tests. When null the screen
  /// builds a MapTiler service if a key is configured.
  final GeocodingService? geocodingService;

  /// Optional injected routing service, used by tests. When null the screen
  /// builds a MapTiler service if a key is configured.
  final RoutingService? routingService;

  const NavigationScreenContent({
    super.key,
    required this.onClose,
    this.geocodingService,
    this.routingService,
  });

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

  /// Whether the basemap host is reachable. Falls back to the hand-painted
  /// simulated map when the tile server can't be contacted or no API key is
  /// configured.
  bool _useRealMap = MapStyle.hasApiKey;

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

  // ── Search ────────────────────────────────────────────────────────────────
  late final GeocodingService? _geocoding;
  late final bool _ownsGeocoding;
  Place? _startPlace;
  Place? _destinationPlace;
  bool _searchOpen = false;

  // ── Routing ───────────────────────────────────────────────────────────────
  late final RoutingService? _routing;
  late final bool _ownsRouting;
  RoutePlan? _route;
  List<double> _routeCumulativeKm = const [];
  bool _routeLoading = false;
  String? _routeError;
  int _routeRequestId = 0;

  @override
  void initState() {
    super.initState();

    _mapController = MapController();

    // Search and routing are provider-backed and key-gated; without a key the
    // UI explains why they are unavailable instead of failing silently.
    final injectedGeocoding = widget.geocodingService;
    _ownsGeocoding = injectedGeocoding == null && MapStyle.hasApiKey;
    _geocoding =
        injectedGeocoding ??
        (MapStyle.hasApiKey
            ? MapTilerGeocodingService(apiKey: MapStyle.apiKey)
            : null);

    final injectedRouting = widget.routingService;
    _ownsRouting = injectedRouting == null && MapStyle.hasApiKey;
    _routing =
        injectedRouting ??
        (MapStyle.hasApiKey
            ? MapTilerRoutingService(apiKey: MapStyle.apiKey)
            : null);

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

  /// Lightly probes the basemap tile host. On success the real map is used; on
  /// failure (offline / blocked) we silently fall back to the simulated map.
  Future<void> _probeTileServer() async {
    final reachable = await basemapTilesReachable();
    if (!mounted) return;
    setState(() => _useRealMap = reachable);
  }

  @override
  void dispose() {
    if (_ownsGeocoding) _geocoding?.dispose();
    if (_ownsRouting) _routing?.dispose();
    _travelController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTravelTick() {
    final t = _travelAnimation.value;

    final route = _route;
    if (route != null &&
        _routeCumulativeKm.length == route.geometry.length &&
        _routeCumulativeKm.last > 0) {
      _travelAlongRoute(route, t);
      setState(() {});
      return;
    }

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
        invT * invT * p0.latitude +
        2 * invT * t * p1.latitude +
        t * t * p2.latitude;
    final currentLng =
        invT * invT * p0.longitude +
        2 * invT * t * p1.longitude +
        t * t * p2.longitude;

    // Tangent derivative for heading: B'(t) = 2(1-t)(P1 - P0) + 2t(P2 - P1)
    final dLat =
        2 * invT * (p1.latitude - p0.latitude) +
        2 * t * (p2.latitude - p1.latitude);
    final dLng =
        2 * invT * (p1.longitude - p0.longitude) +
        2 * t * (p2.longitude - p1.longitude);

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

  void _openSearch() => setState(() => _searchOpen = true);

  void _closeSearch() => setState(() => _searchOpen = false);

  /// Applies a search result and asks the provider for a route between the
  /// chosen points.
  void _selectPlace(SearchTarget target, Place place) {
    setState(() {
      switch (target) {
        case SearchTarget.start:
          _startPlace = place;
          _currentPuckLatLng = place.coordinates;
          _startPuckLatLng = place.coordinates;
          break;
        case SearchTarget.destination:
          _destinationPlace = place;
          _startPuckLatLng = _startPlace?.coordinates ?? _currentPuckLatLng;
          _targetPuckLatLng = place.coordinates;
          _searchOpen = false;
          break;
      }
    });

    if (target == SearchTarget.destination) {
      _requestRoute(place);
    } else if (_destinationPlace != null) {
      _requestRoute(_destinationPlace!);
    }
  }

  Future<void> _requestRoute(Place destination) async {
    final start = _startPlace?.coordinates ?? _currentPuckLatLng;
    final service = _routing;
    final requestId = ++_routeRequestId;

    setState(() {
      _route = null;
      _routeCumulativeKm = const [];
      _routeError = null;
      _routeLoading = service != null;
    });

    if (service == null) {
      setState(() {
        _routeError = 'Routing unavailable';
        _routeLoading = false;
      });
      _beginTravel(start, destination.coordinates);
      return;
    }

    try {
      final route = await service.route(start, destination.coordinates);
      if (!mounted || requestId != _routeRequestId) return;
      setState(() {
        _route = route;
        _routeCumulativeKm = _cumulativeDistances(route.geometry);
        _routeLoading = false;
      });
      _fitRoute(route);
      _beginTravel(start, destination.coordinates);
    } on RoutingException catch (error) {
      if (!mounted || requestId != _routeRequestId) return;
      setState(() {
        _routeError = error.message;
        _routeLoading = false;
      });
      _beginTravel(start, destination.coordinates);
    }
  }

  void _beginTravel(LatLng start, LatLng destination) {
    _startPuckLatLng = start;
    _targetPuckLatLng = destination;
    _travelController.stop();
    _travelController.forward(from: 0.0);
  }

  void _fitRoute(RoutePlan route) {
    if (!_useRealMap || route.geometry.length < 2) return;
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: route.geometry,
        padding: const EdgeInsets.all(70),
      ),
    );
  }

  /// Cumulative distance (km) at each geometry point, used to move the puck at
  /// a constant pace along the route rather than per segment.
  List<double> _cumulativeDistances(List<LatLng> geometry) {
    const distance = Distance();
    final result = <double>[0];
    for (var index = 1; index < geometry.length; index++) {
      result.add(
        result.last +
            distance.as(
                  LengthUnit.Meter,
                  geometry[index - 1],
                  geometry[index],
                ) /
                1000,
      );
    }
    return result;
  }

  void _travelAlongRoute(RoutePlan route, double t) {
    final total = _routeCumulativeKm.last;
    if (total <= 0) return;

    final target = t * total;
    var index = 1;
    while (index < _routeCumulativeKm.length - 1 &&
        _routeCumulativeKm[index] < target) {
      index++;
    }

    final segmentStart = _routeCumulativeKm[index - 1];
    final segmentEnd = _routeCumulativeKm[index];
    final segmentLength = segmentEnd - segmentStart;
    final localT = segmentLength == 0
        ? 0.0
        : ((target - segmentStart) / segmentLength).clamp(0.0, 1.0);

    final from = route.geometry[index - 1];
    final to = route.geometry[index];
    _currentPuckLatLng = LatLng(
      from.latitude + (to.latitude - from.latitude) * localT,
      from.longitude + (to.longitude - from.longitude) * localT,
    );

    final deltaLat = to.latitude - from.latitude;
    final deltaLng = to.longitude - from.longitude;
    if (deltaLat != 0 || deltaLng != 0) {
      _puckHeading = math.atan2(deltaLat, deltaLng) + math.pi / 2;
    }
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).round();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '$hours h' : '$hours h $rest min';
  }

  String get _routeSubtitle {
    if (_routeLoading) return 'Calculating route…';
    final route = _route;
    if (route != null) {
      return '${route.distanceKm.toStringAsFixed(1)} km · '
          '${_formatDuration(route.durationSeconds)} · simulated';
    }
    if (_routeError != null) return 'Routing unavailable · simulated route';
    return 'Search result · simulated route';
  }

  @override
  Widget build(BuildContext context) {
    final activeDest = _destinations[_selectedDestIndex];
    final hasSearchedDestination = _destinationPlace != null;

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

          // ── Minimal Top Bar: Destination name + Next maneuver only ─────────
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: _MinimalTopBar(
              title: _destinationPlace?.name ?? activeDest.title,
              subtitle: hasSearchedDestination
                  ? _routeSubtitle
                  : activeDest.nextManeuver,
              maneuverIcon: hasSearchedDestination
                  ? Icons.place_outlined
                  : activeDest.maneuverIcon,
              onOpenSearch: _openSearch,
              onClose: widget.onClose,
              onToggleVoice: () =>
                  setState(() => _isVoiceMuted = !_isVoiceMuted),
              isVoiceMuted: _isVoiceMuted,
            ),
          ),

          if (_searchOpen)
            Positioned(
              left: 10,
              top: 78,
              bottom: 10,
              width: 380,
              child: PlaceSearchPanel(
                service: _geocoding,
                unavailableReason:
                    'Map key not configured. Add MAPTILER_KEY or '
                    'maptiler_key.txt to enable place search.',
                initialStart: _startPlace,
                initialDestination: _destinationPlace,
                onPlaceSelected: _selectPlace,
                onClose: _closeSearch,
              ),
            ),

          // ── Floating Map Controls (Right Side) ──────────────────────────────
          Positioned(
            right: 10,
            top: 70,
            child: _CompactMapControls(
              isTrafficEnabled: _isTrafficEnabled,
              onToggleTraffic: () =>
                  setState(() => _isTrafficEnabled = !_isTrafficEnabled),
              onRecenter: _recenter,
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
            ),
          ),
        ],
      ),
    );
  }

  /// Real basemap (flutter_map) with puck, destinations, route and
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
        backgroundColor: const Color(0xFFEFEEEA),
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: MapStyle.rasterTileUrl,
          minZoom: 1,
          maxZoom: MapStyle.maxZoom,
          maxNativeZoom: MapStyle.maxNativeZoom,
          userAgentPackageName: 'skyui',
          retinaMode: RetinaMode.isHighDensity(context),
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
                child: const MapVehiclePuck(),
              ),
            ),
            // Destination waypoints
            for (int i = 0; i < _destinations.length; i++) ...[
              Marker(
                point: _destinations[i].coordinates,
                width: 22,
                height: 22,
                child: GestureDetector(
                  onTap: () => _navigateToDestination(i),
                  child: Container(
                    decoration: BoxDecoration(
                      color: i == _selectedDestIndex
                          ? const Color(0xFFFF8A00)
                          : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: i == _selectedDestIndex
                            ? Colors.white
                            : const Color(0xFF9AA0A6),
                        width: 2,
                      ),
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
              ),
            ],
            if (_startPlace != null)
              Marker(
                point: _startPlace!.coordinates,
                width: 22,
                height: 22,
                child: const _SearchedPlaceMarker(color: Color(0xFF00E676)),
              ),
            if (_destinationPlace != null)
              Marker(
                point: _destinationPlace!.coordinates,
                width: 26,
                height: 26,
                child: const _SearchedPlaceMarker(color: Color(0xFFFF8A00)),
              ),
          ],
        ),
        PolylineLayer(
          polylines: [
            if (_route != null)
              Polyline(
                points: _route!.geometry,
                strokeWidth: 9,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            Polyline(
              points: _route?.geometry ?? _routePoints(),
              strokeWidth: 5,
              color: const Color(0xFFFF8A00),
            ),
          ],
        ),
        const MapAttribution(text: MapStyle.attribution),
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
        inv * inv * p0.latitude +
            2 * inv * t * p1.latitude +
            t * t * p2.latitude,
        inv * inv * p0.longitude +
            2 * inv * t * p1.longitude +
            t * t * p2.longitude,
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
// Minimal Top Bar: Destination + Next Maneuver + Voice
// ─────────────────────────────────────────────────────────────────────────────

class _MinimalTopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData maneuverIcon;
  final VoidCallback onOpenSearch;
  final VoidCallback onClose;
  final VoidCallback onToggleVoice;
  final bool isVoiceMuted;

  const _MinimalTopBar({
    required this.title,
    required this.subtitle,
    required this.maneuverIcon,
    required this.onOpenSearch,
    required this.onClose,
    required this.onToggleVoice,
    required this.isVoiceMuted,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Destination title + distance
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // Next maneuver (compact)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8A00).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFFFF8A00).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(maneuverIcon, color: const Color(0xFFFF8A00), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFFFF8A00),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Search
            Tooltip(
              message: 'Search start and destination',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const ValueKey('navigation-search-button'),
                  onTap: onOpenSearch,
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.search_rounded,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Voice toggle
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onToggleVoice,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    isVoiceMuted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    color: isVoiceMuted ? Colors.white38 : Colors.white70,
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Close module
            Tooltip(
              message: 'Close navigation',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                      size: 18,
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
// Compact Map Controls (Right Side) - Recenter, Zoom, Traffic
// ─────────────────────────────────────────────────────────────────────────────

class _CompactMapControls extends StatelessWidget {
  final bool isTrafficEnabled;
  final VoidCallback onToggleTraffic;
  final VoidCallback onRecenter;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const _CompactMapControls({
    required this.isTrafficEnabled,
    required this.onToggleTraffic,
    required this.onRecenter,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MapControlButton(
          icon: Icons.my_location_rounded,
          onTap: onRecenter,
          tooltip: 'Recenter',
        ),
        const SizedBox(height: 6),
        _MapControlButton(
          icon: Icons.add_rounded,
          onTap: onZoomIn,
          tooltip: 'Zoom in',
        ),
        const SizedBox(height: 6),
        _MapControlButton(
          icon: Icons.remove_rounded,
          onTap: onZoomOut,
          tooltip: 'Zoom out',
        ),
        const SizedBox(height: 6),
        _MapControlButton(
          icon: Icons.traffic_rounded,
          onTap: onToggleTraffic,
          active: isTrafficEnabled,
          tooltip: 'Traffic',
        ),
      ],
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool active;
  final String tooltip;

  const _MapControlButton({
    required this.icon,
    this.onTap,
    this.active = false,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: active
                    ? const Color(0xFFFF8A00).withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: active
                  ? const Color(0xFFFF8A00)
                  : enabled
                  ? Colors.white70
                  : Colors.white24,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

/// Marker for a searched start or destination point.
class _SearchedPlaceMarker extends StatelessWidget {
  final Color color;

  const _SearchedPlaceMarker({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.circle, color: Colors.white, size: 5),
      ),
    );
  }
}
