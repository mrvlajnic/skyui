import 'package:flutter/material.dart';

import 'veltron_logo.dart';

/// Full-screen startup gate shown before the main interface is revealed.
///
/// The home screen is still built and laid out underneath from the first
/// frame, so asset decoding and initial layout happen behind the overlay
/// instead of blocking it. The overlay then fades away after a short,
/// deterministic boot sequence.
///
/// Disabled by default so widget tests can mount [SkyUIApp] directly without
/// timers or overlays. The production entry point explicitly enables it.
class AppPreloader extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const AppPreloader({super.key, required this.child, this.enabled = true});

  @override
  State<AppPreloader> createState() => _AppPreloaderState();
}

class _AppPreloaderState extends State<AppPreloader>
    with SingleTickerProviderStateMixin {
  static const Duration _bootDuration = Duration(milliseconds: 1400);

  late final AnimationController _controller;
  late final Animation<double> _markOpacity;
  late final Animation<double> _wordmarkOpacity;
  late final Animation<double> _progress;
  late final Animation<double> _exitOpacity;
  bool _done = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _bootDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _done = true);
        }
      });

    _markOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.30, curve: Curves.easeOutCubic),
    );
    _wordmarkOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.08, 0.38, curve: Curves.easeOutCubic),
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.10, 0.70, curve: Curves.easeOutCubic),
    );
    _exitOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.82, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    if (widget.enabled) {
      // Start after the first frame so the minimum display time is measured
      // from when the preloader is actually visible.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Kept at index 0 for the whole boot so the home screen's state and
        // image cache survive the overlay being removed.
        widget.child,
        if (!_done)
          Positioned.fill(
            key: const ValueKey('app-preloader'),
            child: AbsorbPointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Opacity(
                    opacity: _exitOpacity.value,
                    child: ColoredBox(
                      color: const Color(0xFF0B0B10),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Opacity(
                              opacity: _markOpacity.value,
                              child: const VeltronLogo(size: 72),
                            ),
                            const SizedBox(height: 26),
                            Opacity(
                              opacity: _wordmarkOpacity.value,
                              child: const Text(
                                'V E L T R O N',
                                style: TextStyle(
                                  color: Color(0xD1FFFFFF),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 8,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 42),
                            _ProgressLine(progress: _progress.value),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final double progress;

  const _ProgressLine({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      height: 2,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0x14FFFFFF),
              borderRadius: BorderRadius.all(Radius.circular(1)),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: const BorderRadius.all(Radius.circular(1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.22),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
