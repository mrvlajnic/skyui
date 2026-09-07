import 'package:flutter/material.dart';

import '../../widgets/sidebar/sidebar.dart';
import '../../widgets/cards/vehicle_card.dart';
import '../../widgets/cards/media_card.dart';
import '../../widgets/cards/navigation_card.dart';
import '../../widgets/cards/phone_card.dart';
import '../../widgets/climate/climate_bar.dart';
import '../navigation/navigation_screen_content.dart';

// ── Shared layout constants ───────────────────────────────────────────────────
const double _kPadding = 24.0;
const double _kSpacing = 24.0;
const double _kClimateBarHeight = 80.0;

/// Home dashboard screen.
///
/// When the Navigation card is tapped, an animated overlay expands from the
/// card's position to fill the entire content area above the climate bar.
/// The Vehicle, Media and Phone cards fade out during the transition.
/// The bottom ClimateBar and the outer sidebar remain visible at all times.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // ── Animation ─────────────────────────────────────────────────────────────
  late final AnimationController _controller;

  /// [0] = dashboard, [1] = navigation full-screen
  late final Animation<double> _expandProgress;

  /// Opacity of the three non-navigation cards (vehicle, media, phone)
  late final Animation<double> _otherCardsOpacity;

  /// Opacity of the full-screen navigation content
  late final Animation<double> _navContentOpacity;

  bool _navigationExpanded = false;



  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // Card expansion curve – ease in/out for a polished feel
    _expandProgress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    // Other cards fade out quickly in the first 40 % of the animation
    _otherCardsOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.40, curve: Curves.easeIn),
      ),
    );

    // Navigation full-screen content fades in during the last 35 %
    _navContentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _openNavigation() {
    if (_navigationExpanded) return;
    setState(() => _navigationExpanded = true);
    _controller.forward();
  }

  void _closeNavigation() {
    _controller.reverse().then((_) {
      if (mounted) setState(() => _navigationExpanded = false);
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight =
                    constraints.maxHeight - _kClimateBarHeight - _kPadding * 2;
                final availableWidth = constraints.maxWidth - _kPadding * 2;

                final centerCardHeight = (availableHeight - _kSpacing) / 2;
                final totalHorizontalSpacing = _kSpacing * 2;
                final contentWidth = availableWidth - totalHorizontalSpacing;
                final vehicleWidth = (contentWidth / 5) * 2;
                final centerWidth = contentWidth / 5;
                final navWidth = (contentWidth / 5) * 2;

                // ── Nav card geometry in the content coordinate space ──────
                // The nav card starts at x = vehicleWidth + spacing + centerWidth + spacing,
                // y = 0 (relative to the padded content area).
                // In the expanded state it fills the full padded content area.
                final navCardLeft = vehicleWidth + _kSpacing + centerWidth + _kSpacing;
                const navCardTop = 0.0;

                // Full content area rect (relative to padded area)
                const fullLeft = 0.0;
                const fullTop = 0.0;
                final fullWidth = availableWidth;
                final fullHeight = availableHeight;

                return Column(
                  children: [
                    // ── Content area ────────────────────────────────────────
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(_kPadding),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // ── Base card row (always in tree, fades/stays) ─
                            _AnimatedRow(
                              vehicleWidth: vehicleWidth,
                              centerWidth: centerWidth,
                              navWidth: navWidth,
                              centerCardHeight: centerCardHeight,
                              otherCardsOpacity: _otherCardsOpacity,
                            ),

                            // ── Animated nav card overlay ───────────────────
                            AnimatedBuilder(
                              animation: _expandProgress,
                              builder: (context, child) {
                                final t = _expandProgress.value;

                                // Interpolate position & size
                                final left = _lerpDouble(navCardLeft, fullLeft, t);
                                final top = _lerpDouble(navCardTop, fullTop, t);
                                final width = _lerpDouble(navWidth, fullWidth, t);
                                final height = _lerpDouble(availableHeight, fullHeight, t);

                                return Positioned(
                                  left: left,
                                  top: top,
                                  width: width,
                                  height: height,
                                  child: child!,
                                );
                              },
                              child: _NavCardOverlay(
                                expandProgress: _expandProgress,
                                navContentOpacity: _navContentOpacity,
                                navigationExpanded: _navigationExpanded,
                                onTap: _openNavigation,
                                onClose: _closeNavigation,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Climate bar – always visible ─────────────────────────
                    const ClimateBar(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

// ─────────────────────────────────────────────────────────────────────────────
// The three non-navigation cards with animated opacity
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedRow extends StatelessWidget {
  final double vehicleWidth;
  final double centerWidth;
  final double navWidth;
  final double centerCardHeight;
  final Animation<double> otherCardsOpacity;

  const _AnimatedRow({
    required this.vehicleWidth,
    required this.centerWidth,
    required this.navWidth,
    required this.centerCardHeight,
    required this.otherCardsOpacity,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Vehicle card
        FadeTransition(
          opacity: otherCardsOpacity,
          child: SizedBox(
            width: vehicleWidth,
            child: const VehicleCard(),
          ),
        ),

        const SizedBox(width: _kSpacing),

        // Media + Phone stack
        FadeTransition(
          opacity: otherCardsOpacity,
          child: SizedBox(
            width: centerWidth,
            child: Column(
              children: [
                SizedBox(
                  height: centerCardHeight,
                  child: const MediaCard(),
                ),
                const SizedBox(height: _kSpacing),
                SizedBox(
                  height: centerCardHeight,
                  child: const PhoneCard(),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: _kSpacing),

        // Navigation placeholder (same width so layout is stable)
        SizedBox(width: navWidth),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// The nav card overlay that starts as the compact card and expands full-screen
// ─────────────────────────────────────────────────────────────────────────────

class _NavCardOverlay extends StatelessWidget {
  final Animation<double> expandProgress;
  final Animation<double> navContentOpacity;
  final bool navigationExpanded;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _NavCardOverlay({
    required this.expandProgress,
    required this.navContentOpacity,
    required this.navigationExpanded,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Only tappable when in the compact state
      onTap: navigationExpanded ? null : onTap,
      child: AnimatedBuilder(
        animation: expandProgress,
        builder: (context, child) {
          final t = expandProgress.value;

          return Stack(
            fit: StackFit.expand,
            children: [
              // ── Compact NavigationCard (fades out as nav content fades in) ──
              Opacity(
                opacity: (1.0 - navContentOpacity.value).clamp(0.0, 1.0),
                child: const NavigationCard(),
              ),

              // ── Full-screen navigation content (fades in) ─────────────────
              if (t > 0)
                FadeTransition(
                  opacity: navContentOpacity,
                  child: NavigationScreenContent(onClose: onClose),
                ),
            ],
          );
        },
      ),
    );
  }
}
