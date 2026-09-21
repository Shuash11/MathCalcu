// Cycle 12 Item 3 Slice 3b: separable DiffEq regression test —
// the guided-parser BaseEquation subclass. Verifies the classic
// separable cases (x*y, x^2*y^2, 1/y), unsupported g(y) errors,
// garbage never throwing, and a numeric sanity check that the
// implicit solution for dy/dx = x*y (y = exp(x^2/2)) really
// satisfies ln|y| = x^2/2.
import 'dart:math' as math;

import 'package:calculus_system/topics/calculus/finals/solvers/diffeq_separable/diffeq_separable_equation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Separable DiffEq (finals, guided parser)', () {
    test('dy/dx = x * y gives ln|y| = x^2/2 + C', () {
      final eq = DiffeqSeparableEquation('dy/dx = x * y');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, 'ln|y| = x^2/2 + C');
      expect(r.customData!.first['kind'], 'separable');
    });

    test('dy/dx = x^2 * y^2 gives -1/y = x^3/3 + C', () {
      final eq = DiffeqSeparableEquation('dy/dx = x^2 * y^2');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, '-1/y = x^3/3 + C');
    });

    test('coefficients carry through: dy/dx = 2x * y (f side)', () {
      final eq = DiffeqSeparableEquation('dy/dx = 2x * y');
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, 'ln|y| = x^2 + C');
    });

    test('coefficients carry through: dy/dx = x * 2y (g side)', () {
      final eq = DiffeqSeparableEquation('dy/dx = x * 2y');
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, 'ln|y|/2 = x^2/2 + C');
    });

    test('1/x fold still gives ln|x| (k = 1 f side)', () {
      final eq = DiffeqSeparableEquation('dy/dx = 1/x * y');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, 'ln|y| = ln|x| + C');
    });

    test('k=2 negative exponent: dy/dx = 2x^-1 * y gives 2ln|x| + C', () {
      final eq = DiffeqSeparableEquation('dy/dx = 2x^-1 * y');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, 'ln|y| = 2ln|x| + C');
      // Differentiating 2ln|x| gives 2/x = f(x), not f(x)/2.
      for (final x in const [0.5, 1.0, 2.0]) {
        final y = x * x; // solution curve: ln|y| = 2ln|x|
        expect(math.log(y), closeTo(2 * math.log(x.abs()), 1e-9));
      }
    });

    test('k=-2 negative exponent: dy/dx = -2x^-1 * y gives -2ln|x| + C', () {
      final eq = DiffeqSeparableEquation('dy/dx = -2x^-1 * y');
      expect(eq.validate(), isTrue);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, 'ln|y| = -2ln|x| + C');
    });

    test('1/y on the right: dy/dx = x * (1/y) gives y^2/2 = x^2/2 + C', () {
      final eq = DiffeqSeparableEquation('dy/dx = x * 1/y');
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, 'y^2/2 = x^2/2 + C');
    });

    test('steps follow Separate → Integrate → General solution', () {
      final eq = DiffeqSeparableEquation('dy/dx = x * y');
      final steps = eq.getSteps();
      expect(steps.length, 3);
      expect(steps[0].title, 'Separate variables');
      expect(steps[0].hint, 'dy/y = x dx');
      expect(steps[1].title, 'Integrate both sides');
      expect(steps[2].title, 'General solution');
      expect(steps[2].explanation, contains('ln|y| = x^2/2 + C'));
    });

    test('unsupported g(y) (sin) errors explicitly, never throws', () {
      final eq = DiffeqSeparableEquation('dy/dx = x * sin(y)');
      expect(eq.validate(), isFalse);
      expect(() => eq.solve(), returnsNormally);
      expect(eq.solve().hasError, isTrue);
      expect(eq.solve().errorMessage, contains('Only elementary g(y)'));
    });

    test('wrong lhs and malformed rhs error, never throw', () {
      for (final bad in [
        'dx/dy = x * y',
        'y = x',
        'dy/dx = x',
        'dy/dx = x * y * x',
        'dy/dx = x + y',
      ]) {
        final eq = DiffeqSeparableEquation(bad);
        expect(eq.validate(), isFalse, reason: bad);
        expect(() => eq.solve(), returnsNormally, reason: bad);
        expect(eq.solve().hasError, isTrue, reason: bad);
        expect(eq.getSteps(), isNotEmpty, reason: bad);
      }
    });

    test('empty and garbage inputs never throw', () {
      for (final bad in ['', '   ', 'hello world', 'dy/dx === x * y']) {
        final eq = DiffeqSeparableEquation(bad);
        expect(() => eq.solve(), returnsNormally, reason: bad);
        expect(eq.solve().hasError, isTrue, reason: bad);
      }
    });

    test('numeric sanity: ln|y| = x^2/2 holds for y = exp(x^2/2)', () {
      // dy/dx = x*y separates to ln|y| = x^2/2 + C; along the
      // solution curve y(x) = exp(x^2/2), the implicit identity
      // ln|y(x)| = x^2/2 must hold at any sample point.
      final eq = DiffeqSeparableEquation('dy/dx = x * y');
      expect(eq.solve().answer, 'ln|y| = x^2/2 + C');
      for (final x in const [0.5, 1.0, 1.7]) {
        final y = math.exp(x * x / 2);
        expect(math.log(y), closeTo(x * x / 2, 1e-9));
      }
    });
  });
}
