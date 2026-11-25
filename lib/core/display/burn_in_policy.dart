import 'dart:math' as math;
import 'dart:ui' show Offset;

/// Burn-in mitigation policy for the 21:9 OLED cockpit panel.
///
/// OLED pixels age in proportion to the light they emit, so a cockpit UI is
/// unusually exposed: the sidebar, header icons, clock, climate bar and card
/// borders occupy the same pixels for hours at a time. This policy keeps the
/// whole surface drifting slowly and dims it when the car is parked and
/// untouched. It is a display-lifetime decision, not a styling choice — see
/// `DEC-009 - OLED burn-in and always-on content policy`.
///
/// The defaults are deliberately conservative: a shift small enough to be
/// invisible at arm's length, and a dim shallow enough to stay readable.
class BurnInPolicy {
  const BurnInPolicy({
    this.shiftAmplitude = 2.0,
    this.shiftPeriod = const Duration(minutes: 4),
    this.shiftSteps = 8,
    this.idleDimAfter = const Duration(minutes: 5),
    this.dimOpacity = 0.78,
    this.dimTransition = const Duration(milliseconds: 600),
  })  : assert(shiftAmplitude >= 0),
        assert(shiftSteps > 0),
        assert(dimOpacity > 0 && dimOpacity <= 1);

  /// The production policy.
  static const BurnInPolicy standard = BurnInPolicy();

  /// Maximum displacement, in logical pixels, on either axis.
  final double shiftAmplitude;

  /// Time for one full drift cycle.
  final Duration shiftPeriod;

  /// Discrete positions per cycle. The surface only moves when the step
  /// changes, so a static screen does not repaint every frame.
  final int shiftSteps;

  /// How long the panel may stay parked and untouched before it dims.
  final Duration idleDimAfter;

  /// Opacity applied while dimmed. Kept mild so the clock stays readable.
  final double dimOpacity;

  /// Cross-fade into and out of the dimmed state.
  final Duration dimTransition;

  /// Position of the surface after [elapsed], on a closed Lissajous path.
  ///
  /// Both axes are bounded by [shiftAmplitude], and the path returns to the
  /// origin at the end of every cycle.
  Offset shiftFor(Duration elapsed) {
    if (shiftPeriod <= Duration.zero) return Offset.zero;
    final cycle =
        elapsed.inMicroseconds / shiftPeriod.inMicroseconds;
    // A full revolution on X and two on Y: no axis ever rests.
    final angle = cycle * 2 * math.pi;
    return Offset(
      math.sin(angle) * shiftAmplitude,
      math.sin(angle * 2) * shiftAmplitude * 0.5,
    );
  }

  /// Quantised step for [elapsed], wrapping at the end of each cycle.
  int stepFor(Duration elapsed) {
    if (shiftPeriod <= Duration.zero || shiftSteps <= 1) return 0;
    final stepMicros = shiftPeriod.inMicroseconds / shiftSteps;
    final raw = elapsed.inMicroseconds ~/ stepMicros;
    return raw % shiftSteps;
  }

  /// Position for a quantised [step].
  Offset shiftForStep(int step) {
    if (shiftPeriod <= Duration.zero || shiftSteps <= 1) return Offset.zero;
    final micros = (shiftPeriod.inMicroseconds * step / shiftSteps).round();
    final point = shiftFor(Duration(microseconds: micros));
    // Whole logical pixels: a fractional translation makes the whole app
    // composite at subpixel offsets, which can shimmer over moving map tiles.
    return Offset(point.dx.roundToDouble(), point.dy.roundToDouble());
  }
}
