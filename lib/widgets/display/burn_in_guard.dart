import 'package:flutter/material.dart';

import '../../core/display/burn_in_policy.dart';
import '../../core/theme/colors.dart';
import '../../services/drive_mode_service.dart';

/// Protects the OLED panel from differential ageing.
///
/// Two mitigations run together:
///
/// 1. **Pixel shift** — the whole surface moves by a couple of logical pixels
///    on a slow closed path, so static chrome (sidebar, clock, climate bar,
///    card borders) never holds one pixel for hours.
/// 2. **Idle dim** — while the car is parked and nobody has touched the screen,
///    the surface fades to [BurnInPolicy.dimOpacity]. The first tap only wakes
///    the display; it does not press whatever is underneath.
///
/// Dimming is disabled while driving: a moving vehicle needs full-brightness
/// information, and the screen is changing anyway. The mitigation is disabled
/// by default so widget tests can mount the app without running animations;
/// `main()` enables it for the real application, the same way it enables the
/// preloader.
class BurnInGuard extends StatefulWidget {
  const BurnInGuard({
    super.key,
    required this.child,
    this.policy = BurnInPolicy.standard,
    this.enabled = true,
  });

  final Widget child;
  final BurnInPolicy policy;
  final bool enabled;

  @override
  State<BurnInGuard> createState() => _BurnInGuardState();
}

class _BurnInGuardState extends State<BurnInGuard>
    with TickerProviderStateMixin {
  late final AnimationController _shift;
  late final AnimationController _idle;
  int _step = 0;
  bool _dimmed = false;
  bool _driving = false;

  @override
  void initState() {
    super.initState();
    _shift = AnimationController(
      vsync: this,
      duration: widget.policy.shiftPeriod,
    )..addListener(_onShiftTick);
    _idle = AnimationController(
      vsync: this,
      duration: widget.policy.idleDimAfter,
    )..addStatusListener(_onIdleStatus);
    _driving = DriveModeService.instance.isDriving;
    DriveModeService.instance.state.addListener(_onDriveModeChanged);
    if (widget.enabled) _start();
  }

  @override
  void didUpdateWidget(BurnInGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled == widget.enabled) return;
    if (widget.enabled) {
      _start();
    } else {
      _stop();
    }
  }

  @override
  void dispose() {
    DriveModeService.instance.state.removeListener(_onDriveModeChanged);
    _shift.dispose();
    _idle.dispose();
    super.dispose();
  }

  void _start() {
    _shift.repeat();
    _restartIdle();
  }

  void _stop() {
    _shift.stop();
    _idle.stop();
    if (_dimmed && mounted) {
      setState(() => _dimmed = false);
    }
  }

  void _restartIdle() {
    if (!widget.enabled || _driving) return;
    _idle.forward(from: 0);
  }

  void _onShiftTick() {
    final elapsed = Duration(
      microseconds:
          (widget.policy.shiftPeriod.inMicroseconds * _shift.value).round(),
    );
    final next = widget.policy.stepFor(elapsed);
    if (next != _step && mounted) {
      setState(() => _step = next);
    }
  }

  void _onIdleStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    if (!widget.enabled || _driving || _dimmed) return;
    setState(() => _dimmed = true);
  }

  void _onDriveModeChanged() {
    final driving = DriveModeService.instance.isDriving;
    if (driving == _driving) return;
    _driving = driving;
    if (driving) {
      _idle.stop();
      _idle.value = 0;
      if (_dimmed && mounted) setState(() => _dimmed = false);
    } else {
      _restartIdle();
    }
  }

  /// Restores full brightness without passing the tap to the content.
  void _wake() {
    if (_dimmed && mounted) {
      setState(() => _dimmed = false);
    }
    if (_idle.isCompleted || _idle.isDismissed) {
      _restartIdle();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final offset = widget.policy.shiftForStep(_step);
    return Listener(
      onPointerDown: (_) => _wake(),
      child: ClipRect(
        child: ColoredBox(
          color: AppColors.background,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Transform.translate(
                key: const ValueKey('burn-in-shift'),
                offset: offset,
                child: AnimatedOpacity(
                  opacity: _dimmed ? widget.policy.dimOpacity : 1.0,
                  duration: widget.policy.dimTransition,
                  curve: Curves.easeOut,
                  child: widget.child,
                ),
              ),
              if (_dimmed)
                Semantics(
                  label: 'Display dimmed to protect the screen. Tap to wake.',
                  button: true,
                  child: GestureDetector(
                    key: const ValueKey('burn-in-wake'),
                    behavior: HitTestBehavior.opaque,
                    onTap: _wake,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
