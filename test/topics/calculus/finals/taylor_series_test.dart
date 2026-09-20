// Cycle 11 Item 4 Slice 4b: Taylor/Maclaurin series regression test —
// the thin DerivativesSolver wrap. Verifies the classic expansions
// (exp, sin, ln at 1), garbage error handling, and that the built
// polynomial numerically approximates the true function near the
// center.
import 'dart:math' as math;

import 'package:calculus_system/topics/calculus/finals/solvers/derivatives_solver/derivatives_solver.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/taylor_series/taylor_series_equation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Taylor series (finals, thin DerivativesSolver wrap)', () {
    test('taylor exp(x) at 0 gives 1 + x + x^2/2 + x^3/6 + x^4/24', () {
      final eq = TaylorSeriesEquation('taylor exp(x) at 0');
      expect(eq.validate(), isTrue);
      expect(eq.expression, 'exp(x)');
      expect(eq.center, 0.0);
      expect(eq.degree, 4);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, 'P4(x) = 1 + x + (1/2)x^2 + (1/6)x^3 + (1/24)x^4');
      expect(eq.getSteps(), isNotEmpty);
      expect(eq.getSteps().first.explanation, contains('Maclaurin'));
    });

    test('taylor sin(x) at 0 gives x - x^3/6 (zero terms omitted)', () {
      final eq = TaylorSeriesEquation('taylor sin(x) at 0');
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, 'P4(x) = x - (1/6)x^3');
    });

    test('taylor sin(x) at 0 n=5 includes the x^5/120 term', () {
      final eq = TaylorSeriesEquation('taylor sin(x) at 0 n=5');
      expect(eq.degree, 5);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(r.answer, contains('P5(x) = x - (1/6)x^3 + (1/120)x^5'));
    });

    test('taylor ln(x) at 1 gives (x-1) - (x-1)^2/2 + (x-1)^3/3 - ...', () {
      final eq = TaylorSeriesEquation('taylor ln(x) at 1');
      expect(eq.center, 1.0);
      final r = eq.solve();
      expect(r.hasError, isFalse);
      expect(
        r.answer,
        'P4(x) = (x - 1) - (1/2)(x - 1)^2 + (1/3)(x - 1)^3 - (1/4)(x - 1)^4',
      );
    });

    test('maclaurin ln(x) is the at-0 shorthand and errors (undefined)', () {
      final eq = TaylorSeriesEquation('maclaurin ln(x)');
      expect(eq.center, 0.0);
      expect(() => eq.solve(), returnsNormally);
      expect(eq.solve().hasError, isTrue);
      expect(eq.solve().errorMessage, contains('not analytic'));
    });

    test('garbage input errors without throwing', () {
      for (final garbage in ['taylor zzz', 'taylor zzz at 0', 'taylor']) {
        final eq = TaylorSeriesEquation(garbage);
        expect(() => eq.solve(), returnsNormally);
        expect(eq.solve().hasError, isTrue, reason: garbage);
      }
      expect(TaylorSeriesEquation('taylor zzz').getSteps(), isEmpty);
    });

    test('numeric check: taylor polynomial of exp at 0 approximates exp', () {
      final eq = TaylorSeriesEquation('taylor exp(x) at 0 n=6');
      final r = eq.solve();
      expect(r.hasError, isFalse);
      final poly = r.answer.substring(r.answer.indexOf('= ') + 2);
      final parsed = DerivativeSolver.parse(poly);
      final approx = TaylorSeriesEquation.evaluateAt(parsed, 'x', 0.1);
      expect(approx, isNotNull);
      expect((approx! - math.exp(0.1)).abs(), lessThan(1e-4));
    });

    test('numeric check: taylor polynomial of sin at 0 approximates sin', () {
      final eq = TaylorSeriesEquation('taylor sin(x) at 0 n=7');
      final r = eq.solve();
      expect(r.hasError, isFalse);
      final poly = r.answer.substring(r.answer.indexOf('= ') + 2);
      final parsed = DerivativeSolver.parse(poly);
      final approx = TaylorSeriesEquation.evaluateAt(parsed, 'x', 0.3);
      expect(approx, isNotNull);
      expect((approx! - math.sin(0.3)).abs(), lessThan(1e-4));
    });
  });
}
