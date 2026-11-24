import 'package:flutter_test/flutter_test.dart';
import 'package:skyui/core/display/burn_in_policy.dart';

void main() {
  test('a fresh policy starts at the origin', () {
    expect(BurnInPolicy.standard.shiftFor(Duration.zero), Offset.zero);
    expect(BurnInPolicy.standard.shiftForStep(0), Offset.zero);
  });

  test('the drift path never leaves the configured amplitude', () {
    const policy = BurnInPolicy(shiftAmplitude: 2.0);
    for (var second = 0; second <= 240; second += 1) {
      final offset = policy.shiftFor(Duration(seconds: second));
      expect(offset.dx.abs(), lessThanOrEqualTo(2.0 + 1e-9));
      expect(offset.dy.abs(), lessThanOrEqualTo(2.0 + 1e-9));
    }
  });

  test('the path is closed: one full period returns to the start', () {
    const policy = BurnInPolicy();
    final start = policy.shiftFor(Duration.zero);
    final end = policy.shiftFor(policy.shiftPeriod);
    expect(end.dx, closeTo(start.dx, 1e-6));
    expect(end.dy, closeTo(start.dy, 1e-6));
  });

  test('steps advance through the cycle and wrap', () {
    const policy = BurnInPolicy(
      shiftPeriod: Duration(seconds: 8),
      shiftSteps: 8,
    );
    expect(policy.stepFor(Duration.zero), 0);
    expect(policy.stepFor(const Duration(seconds: 1)), 1);
    expect(policy.stepFor(const Duration(seconds: 7)), 7);
    expect(policy.stepFor(const Duration(seconds: 8)), 0);
    expect(policy.stepFor(const Duration(seconds: 9)), 1);
  });

  test('a zero amplitude or a zero period disables movement', () {
    expect(
      const BurnInPolicy(shiftAmplitude: 0).shiftFor(const Duration(minutes: 1)),
      Offset.zero,
    );
    expect(
      const BurnInPolicy(shiftPeriod: Duration.zero)
          .shiftFor(const Duration(minutes: 1)),
      Offset.zero,
    );
  });

  test('the standard policy dims but stays readable', () {
    expect(BurnInPolicy.standard.dimOpacity, greaterThanOrEqualTo(0.7));
    expect(BurnInPolicy.standard.dimOpacity, lessThan(1.0));
    expect(
      BurnInPolicy.standard.idleDimAfter,
      greaterThan(const Duration(minutes: 1)),
    );
  });
}
