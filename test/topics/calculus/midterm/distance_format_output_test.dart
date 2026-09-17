// Cycle 3 F3: output-level regression tests for distance exact-display
// notation. The 2D formatter must always use the real radical `√`
// (U+221A) — never the ASCII `v` fallback — matching radius_solver and
// distancesolver. Written against DistanceFormat (extracted from
// _DistancescreenState._formatDistance so it is unit-testable).
//
// Pattern follows test/topics/calculus/midterm/
// inequalities_solver_output_test.dart: pure group/test, no widget binding.
import 'dart:math';

import 'package:calculus_system/topics/calculus/midterm/screens/distance_screen/distance_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DistanceFormat output (Cycle 3 F3)', () {
    test('perfect square returns integer only', () {
      expect(DistanceFormat.formatDistance(5.0, true), '5');
    });

    test('prime radicand uses √ form, never ASCII v', () {
      final result = DistanceFormat.formatDistance(sqrt(5), true);
      expect(result, '√5 ≈ 2.2361');
      expect(result, isNot(contains('v5')));
    });

    test('composite radicand uses coefficient √ form', () {
      final result = DistanceFormat.formatDistance(sqrt(20), true);
      expect(result, '2√5 ≈ 4.4721');
      expect(result, isNot(contains('v')));
    });

    test('approximation trailing zeros are trimmed', () {
      // 4.5² = 20.25 rounds to 20 → exact part is 2√5, approx trims
      // "4.5000" down to "4.5".
      expect(DistanceFormat.formatDistance(4.5, true), '2√5 ≈ 4.5');
    });

    test('1D returns absolute value', () {
      expect(DistanceFormat.formatDistance(-3.0, false), '3');
      expect(DistanceFormat.formatDistance(2.5, false), '2.5');
    });
  });
}
