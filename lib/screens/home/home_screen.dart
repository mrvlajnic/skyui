import 'package:flutter/material.dart';

import '../../widgets/sidebar/sidebar.dart';
import '../../widgets/cards/vehicle_card.dart';
import '../../widgets/cards/media_card.dart';
import '../../widgets/cards/navigation_card.dart';
import '../../widgets/cards/phone_card.dart';
import '../../widgets/climate/climate_bar.dart';
import '../navigation/navigation_screen_content.dart';
import '../phone/phone_screen.dart';
import '../media/media_screen_content.dart';

// ── Shared layout constants ───────────────────────────────────────────────────
const double _kPadding = 24.0;
const double _kSpacing = 24.0;
const double _kClimateBarHeight = 80.0;

/// Home dashboard screen.
///
/// Features fluid automotive expansion overlays:
/// - Navigation card expands full-screen when tapped.
/// - Phone card expands full-screen with the communication hub when tapped.
/// - Media card expands into Sections 1 & 2 (covering Vehicle and Media/Phone),
///   while the Navigation Card remains anchored in Section 3 on the far right.
/// The bottom ClimateBar and the outer sidebar remain visible at all times.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ── Navigation Card Expansion Animation ─────────────────────────────────────
  late final AnimationController _navController;
  late final Animation<double> _navExpandProgress;
  late final Animation<double> _navOtherCardsOpacity;
  late final Animation<double> _navContentOpacity;
  bool _navigationExpanded = false;

  // ── Phone Card Expansion Animation ──────────────────────────────────────────
  late final AnimationController _phoneController;
  late final Animation<double> _phoneExpandProgress;
  late final Animation<double> _phoneOtherCardsOpacity;
  late final Animation<double> _phoneContentOpacity;
  bool _phoneExpanded = false;

  // ── Media / Music Expansion Animation (Sections 1 & 2) ──────────────────────
  late final AnimationController _mediaController;
  late final Animation<double> _mediaExpandProgress;
  late final Animation<double> _mediaOtherCardsOpacity;
  late final Animation<double> _mediaContentOpacity;
  bool _mediaExpanded = false;

  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();

    // ── Setup Navigation Animation ───────────────────────────────────────────
    _navController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _navExpandProgress = CurvedAnimation(
      parent: _navController,
      curve: Curves.easeInOutCubic,
    );
    _navOtherCardsOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _navController,
        curve: const Interval(0.0, 0.40, curve: Curves.easeIn),
      ),
    );
    _navContentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _navController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
      ),
    );

    // ── Setup Phone Animation ────────────────────────────────────────────────
    _phoneController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _phoneExpandProgress = CurvedAnimation(
      parent: _phoneController,
      curve: Curves.easeInOutCubic,
    );
    _phoneOtherCardsOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _phoneController,
        curve: const Interval(0.0, 0.40, curve: Curves.easeIn),
      ),
    );
    _phoneContentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _phoneController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
      ),
    );

    // ── Setup Media / Music Animation ────────────────────────────────────────
    _mediaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _mediaExpandProgress = CurvedAnimation(
      parent: _mediaController,
      curve: Curves.easeInOutCubic,
    );
    _mediaOtherCardsOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mediaController,
        curve: const Interval(0.0, 0.40, curve: Curves.easeIn),
      ),
    );
    _mediaContentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mediaController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _navController.dispose();
    _phoneController.dispose();
    _mediaController.dispose();
    super.dispose();
  }

  // ── Navigation Expansion Controls ───────────────────────────────────────────

  void _openNavigation() {
    if (_navigationExpanded) return;
    if (_phoneExpanded) {
      _closePhone(onClosed: _openNavigation);
      return;
    }
    setState(() {
      _navigationExpanded = true;
      _currentNavIndex = 1;
    });
    _navController.forward();
  }

  void _closeNavigation({VoidCallback? onClosed}) {
    _navController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _navigationExpanded = false;
          if (_currentNavIndex == 1) {
            _currentNavIndex = _mediaExpanded ? 2 : 0;
          }
        });
        onClosed?.call();
      }
    });
  }

  // ── Phone Expansion Controls ────────────────────────────────────────────────

  void _openPhone() {
    if (_phoneExpanded) return;
    if (_navigationExpanded) {
      _closeNavigation(onClosed: _openPhone);
      return;
    }
    if (_mediaExpanded) {
      _closeMedia(onClosed: _openPhone);
      return;
    }
    setState(() {
      _phoneExpanded = true;
      _currentNavIndex = 3;
    });
    _phoneController.forward();
  }

  void _closePhone({VoidCallback? onClosed}) {
    _phoneController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _phoneExpanded = false;
          if (_currentNavIndex == 3) _currentNavIndex = 0;
        });
        onClosed?.call();
      }
    });
  }

  // ── Media / Music Expansion Controls ────────────────────────────────────────

  void _openMedia() {
    if (_mediaExpanded) return;
    if (_navigationExpanded) {
      _closeNavigation(onClosed: _openMedia);
      return;
    }
    if (_phoneExpanded) {
      _closePhone(onClosed: _openMedia);
      return;
    }
    setState(() {
      _mediaExpanded = true;
      _currentNavIndex = 2;
    });
    _mediaController.forward();
  }

  void _closeMedia({VoidCallback? onClosed}) {
    _mediaController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _mediaExpanded = false;
          if (_currentNavIndex == 2) _currentNavIndex = 0;
        });
        onClosed?.call();
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Opacity for the base card (Vehicle Card)
    final otherCardsOpacity = _phoneExpanded
        ? _phoneOtherCardsOpacity
        : (_mediaExpanded
            ? _mediaOtherCardsOpacity
            : _navOtherCardsOpacity);

    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: _currentNavIndex,
            onItemSelected: (index) {
              if (index == 2) {
                _openMedia();
              } else if (index == 3) {
                _openPhone();
              } else if (index == 1) {
                _openNavigation();
              } else {
                setState(() => _currentNavIndex = index);
                if (_mediaExpanded) _closeMedia();
                if (_phoneExpanded) _closePhone();
                if (_navigationExpanded) _closeNavigation();
              }
            },
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight =
                    constraints.maxHeight - _kClimateBarHeight - _kPadding * 2;
                final availableWidth = constraints.maxWidth - _kPadding * 2;

                final centerCardHeight = (availableHeight - _kSpacing) / 2;
                final totalHorizontalSpacing = _kSpacing * 2;
                final contentWidth = availableWidth - totalHorizontalSpacing;
                // 21:9 ultrawide optimized proportions: 7 : 4 : 5
                final vehicleWidth = (contentWidth / 16) * 7;
                final centerWidth = (contentWidth / 16) * 4;
                final navWidth = (contentWidth / 16) * 5;

                // ── Nav card geometry in content coordinates (Section 3) ────
                final navCardLeft =
                    vehicleWidth + _kSpacing + centerWidth + _kSpacing;
                const navCardTop = 0.0;
                final navCardWidth = navWidth;
                final navCardHeight = availableHeight;

                // ── Phone card geometry in content coordinates ──────────────
                final phoneCardLeft = vehicleWidth + _kSpacing;
                final phoneCardTop = centerCardHeight + _kSpacing;
                final phoneCardWidth = centerWidth;
                final phoneCardHeight = centerCardHeight;

                // ── Media card compact starting geometry ────────────────────
                final mediaCardLeft = vehicleWidth + _kSpacing;
                const mediaCardTop = 0.0;
                final mediaCardWidth = centerWidth;
                final mediaCardHeight = centerCardHeight;

                // ── Music Expanded Target geometry (Sections 1 & 2) ─────────
                // Exactly spans Section 1 (vehicle) + spacing + Section 2 (center)
                const musicExpandedLeft = 0.0;
                const musicExpandedTop = 0.0;
                final musicExpandedWidth = vehicleWidth + _kSpacing + centerWidth;
                final musicExpandedHeight = availableHeight;

                // Full content area geometry (for full-screen Nav/Phone)
                const fullLeft = 0.0;
                const fullTop = 0.0;
                final fullWidth = availableWidth;
                final fullHeight = availableHeight;

                // ── Animated Nav Overlay (Section 3 or Fullscreen) ────────────
                Widget buildNavOverlay() {
                  return AnimatedBuilder(
                    animation: _navExpandProgress,
                    builder: (context, child) {
                      final t = _navExpandProgress.value;
                      final left = _lerpDouble(navCardLeft, fullLeft, t);
                      final top = _lerpDouble(navCardTop, fullTop, t);
                      final width = _lerpDouble(navCardWidth, fullWidth, t);
                      final height = _lerpDouble(navCardHeight, fullHeight, t);

                      return Positioned(
                        left: left,
                        top: top,
                        width: width,
                        height: height,
                        child: IgnorePointer(
                          ignoring: _phoneExpanded,
                          child: FadeTransition(
                            // When Phone expands, Nav fades out. When Media expands, Nav STAYS VISIBLE!
                            opacity: _phoneOtherCardsOpacity,
                            child: child!,
                          ),
                        ),
                      );
                    },
                    child: _NavCardOverlay(
                      expandProgress: _navExpandProgress,
                      navContentOpacity: _navContentOpacity,
                      navigationExpanded: _navigationExpanded,
                      onTap: _openNavigation,
                      onClose: _closeNavigation,
                    ),
                  );
                }

                // ── Animated Phone Overlay ───────────────────────────────────
                Widget buildPhoneOverlay() {
                  return AnimatedBuilder(
                    animation: _phoneExpandProgress,
                    builder: (context, child) {
                      final t = _phoneExpandProgress.value;
                      final left = _lerpDouble(phoneCardLeft, fullLeft, t);
                      final top = _lerpDouble(phoneCardTop, fullTop, t);
                      final width = _lerpDouble(phoneCardWidth, fullWidth, t);
                      final height = _lerpDouble(phoneCardHeight, fullHeight, t);

                      final parentOpacity = _navigationExpanded
                          ? _navOtherCardsOpacity
                          : (_mediaExpanded ? _mediaOtherCardsOpacity : null);

                      Widget content = child!;
                      if (parentOpacity != null) {
                        content = FadeTransition(
                          opacity: parentOpacity,
                          child: content,
                        );
                      }

                      return Positioned(
                        left: left,
                        top: top,
                        width: width,
                        height: height,
                        child: IgnorePointer(
                          ignoring: _navigationExpanded || _mediaExpanded,
                          child: content,
                        ),
                      );
                    },
                    child: _PhoneCardOverlay(
                      expandProgress: _phoneExpandProgress,
                      phoneContentOpacity: _phoneContentOpacity,
                      phoneExpanded: _phoneExpanded,
                      onTap: _openPhone,
                      onClose: _closePhone,
                    ),
                  );
                }

                // ── Animated Media / Music Overlay (Sections 1 & 2) ─────────
                Widget buildMediaOverlay() {
                  return AnimatedBuilder(
                    animation: _mediaExpandProgress,
                    builder: (context, child) {
                      final t = _mediaExpandProgress.value;
                      final left =
                          _lerpDouble(mediaCardLeft, musicExpandedLeft, t);
                      final top = _lerpDouble(mediaCardTop, musicExpandedTop, t);
                      final width =
                          _lerpDouble(mediaCardWidth, musicExpandedWidth, t);
                      final height =
                          _lerpDouble(mediaCardHeight, musicExpandedHeight, t);

                      final parentOpacity = _navigationExpanded
                          ? _navOtherCardsOpacity
                          : (_phoneExpanded ? _phoneOtherCardsOpacity : null);

                      Widget content = child!;
                      if (parentOpacity != null) {
                        content = FadeTransition(
                          opacity: parentOpacity,
                          child: content,
                        );
                      }

                      return Positioned(
                        left: left,
                        top: top,
                        width: width,
                        height: height,
                        child: IgnorePointer(
                          ignoring: _navigationExpanded || _phoneExpanded,
                          child: content,
                        ),
                      );
                    },
                    child: _MediaCardOverlay(
                      expandProgress: _mediaExpandProgress,
                      mediaContentOpacity: _mediaContentOpacity,
                      mediaExpanded: _mediaExpanded,
                      onTap: _openMedia,
                      onClose: _closeMedia,
                    ),
                  );
                }

                return Column(
                  children: [
                    // ── Content area ────────────────────────────────────────
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(_kPadding),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // ── Base card row (Vehicle card in tree) ────────
                            _AnimatedRow(
                              vehicleWidth: vehicleWidth,
                              centerWidth: centerWidth,
                              navWidth: navWidth,
                              centerCardHeight: centerCardHeight,
                              otherCardsOpacity: otherCardsOpacity,
                            ),

                            // ── Overlays: active expanding overlay on top ───
                            if (_phoneExpanded) ...[
                              buildNavOverlay(),
                              buildMediaOverlay(),
                              buildPhoneOverlay(),
                            ] else if (_navigationExpanded) ...[
                              buildPhoneOverlay(),
                              buildMediaOverlay(),
                              buildNavOverlay(),
                            ] else if (_mediaExpanded) ...[
                              buildPhoneOverlay(),
                              buildNavOverlay(),
                              buildMediaOverlay(),
                            ] else ...[
                              buildPhoneOverlay(),
                              buildMediaOverlay(),
                              buildNavOverlay(),
                            ],
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
// Base card row (Vehicle card and layout placeholders)
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
        // Vehicle card (Section 1)
        FadeTransition(
          opacity: otherCardsOpacity,
          child: SizedBox(
            width: vehicleWidth,
            child: const VehicleCard(),
          ),
        ),

        const SizedBox(width: _kSpacing),

        // Section 2 placeholders (Media & Phone)
        SizedBox(
          width: centerWidth,
          child: Column(
            children: [
              // Media placeholder (same size so layout remains stable)
              SizedBox(height: centerCardHeight),
              const SizedBox(height: _kSpacing),
              // Phone placeholder (same size so layout remains stable)
              SizedBox(height: centerCardHeight),
            ],
          ),
        ),

        const SizedBox(width: _kSpacing),

        // Section 3 placeholder (Navigation)
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

// ─────────────────────────────────────────────────────────────────────────────
// The phone card overlay that starts as the compact card and expands full-screen
// ─────────────────────────────────────────────────────────────────────────────

class _PhoneCardOverlay extends StatelessWidget {
  final Animation<double> expandProgress;
  final Animation<double> phoneContentOpacity;
  final bool phoneExpanded;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _PhoneCardOverlay({
    required this.expandProgress,
    required this.phoneContentOpacity,
    required this.phoneExpanded,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Only tappable when in the compact state
      onTap: phoneExpanded ? null : onTap,
      child: AnimatedBuilder(
        animation: expandProgress,
        builder: (context, child) {
          final t = expandProgress.value;

          return Stack(
            fit: StackFit.expand,
            children: [
              // ── Compact PhoneCard (fades out as phone content fades in) ──
              Opacity(
                opacity: (1.0 - phoneContentOpacity.value).clamp(0.0, 1.0),
                child: const PhoneCard(),
              ),

              // ── Full-screen PhoneScreen content (fades in) ─────────────────
              if (t > 0)
                FadeTransition(
                  opacity: phoneContentOpacity,
                  child: PhoneScreen(onClose: onClose),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// The media card overlay that starts as compact and expands to Sections 1 & 2
// ─────────────────────────────────────────────────────────────────────────────

class _MediaCardOverlay extends StatelessWidget {
  final Animation<double> expandProgress;
  final Animation<double> mediaContentOpacity;
  final bool mediaExpanded;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _MediaCardOverlay({
    required this.expandProgress,
    required this.mediaContentOpacity,
    required this.mediaExpanded,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Only tappable when in the compact state
      onTap: mediaExpanded ? null : onTap,
      child: AnimatedBuilder(
        animation: expandProgress,
        builder: (context, child) {
          final t = expandProgress.value;

          return Stack(
            fit: StackFit.expand,
            children: [
              // ── Compact MediaCard (fades out as music content fades in) ──
              Opacity(
                opacity: (1.0 - mediaContentOpacity.value).clamp(0.0, 1.0),
                child: const MediaCard(),
              ),

              // ── Full Sections 1 & 2 MediaScreenContent (fades in) ─────────
              if (t > 0)
                FadeTransition(
                  opacity: mediaContentOpacity,
                  child: MediaScreenContent(onClose: onClose),
                ),
            ],
          );
        },
      ),
    );
  }
}
