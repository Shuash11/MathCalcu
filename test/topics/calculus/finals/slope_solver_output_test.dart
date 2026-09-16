// Cycle 1 Batch B (Item 3): output-level tests for the finals slope
// solver plus the calculator engine. Written BEFORE any solver fix.
import 'package:calculus_system/calculator/calculator_engine.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/slope_using_derivatives_solver/slope_using_derivatives_solver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SlopeSolver output (Batch B Item 3)', () {
    test('explicit polynomial slope: y = x^2 at x=3 is 6', () {
      final r = SlopeSolver.solve('y = x^2', pointValues: {'x': 3.0});
      expect(r.slopeValue, closeTo(6.0, 1e-6));
    });

    test('explicit cubic slope: y = x^3 at x=2 is 12', () {
      final r = SlopeSolver.solve('y = x^3', pointValues: {'x': 2.0});
      expect(r.slopeValue, closeTo(12.0, 1e-6));
    });

    test('trig slope: y = sin(x) at x=0 is 1', () {
      final r = SlopeSolver.solve('y = sin(x)', pointValues: {'x': 0.0});
      expect(r.slopeValue, closeTo(1.0, 1e-6));
    });

    test('implicit circle slope: x^2 + y^2 = 25 at (3,4) is -0.75', () {
      final r = SlopeSolver.solve(
        'x^2 + y^2 = 25',
        pointValues: {'x': 3.0, 'y': 4.0},
      );
      expect(r.slopeValue, closeTo(-0.75, 1e-6));
    });

    test('parametric unit circle at t=pi/4 has slope -1', () {
      final r = SlopeSolver.solve(
        'x=cos(t), y=sin(t)',
        pointValues: {'t': 0.78539816339},
      );
      expect(r.slopeValue, closeTo(-1.0, 1e-3));
    });

    test('derivative latex is non-empty', () {
      final r = SlopeSolver.solve('y = x^2', pointValues: {'x': 3.0});
      expect(r.derivative.toLatexString(), isNotEmpty);
    });
  });

  group('CalculatorEngine output (Batch B Item 3)', () {
    test('operator precedence', () {
      expect(CalculatorEngine.evaluate('2+3*4'), closeTo(14, 1e-9));
    });

    test('parentheses', () {
      expect(CalculatorEngine.evaluate('(2+3)*4'), closeTo(20, 1e-9));
    });

    test('sqrt function', () {
      expect(CalculatorEngine.evaluate('sqrt(16)'), closeTo(4, 1e-9));
    });

    test('exponent', () {
      expect(CalculatorEngine.evaluate('2^3'), closeTo(8, 1e-9));
    });

    test('invalid expression throws FormatException', () {
      expect(() => CalculatorEngine.evaluate('2+'), throwsFormatException);
    });
  });
}
