// Cycle 10 Item 3: regression tests for the slope-derivative solver.
// Written BEFORE any solver fix to prove the bugs:
//  - Parser._atom: an unknown ident followed by '(' skipped the
//    parenthesized content and returned Var('y'), so y = f(x^2) silently
//    solved as y = y (derivative 0) instead of erroring,
//  - the screen var regex was single-letter only ([a-zA-Z_]) with no
//    scientific notation, so x1=2 / theta=0.5 were silently ignored and
//    1e-3 was unparseable.
import 'package:calculus_system/topics/calculus/finals/solvers/slope_using_derivatives_solver/point_values.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/slope_using_derivatives_solver/slope_using_derivatives_solver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SlopeSolver call notation (Cycle 10 Item 3)', () {
    test('y = f(x^2) errors explicitly instead of silent slope 0', () {
      expect(
        () => SlopeSolver.solve('y = f(x^2)'),
        throwsA(isA<FormatException>()),
      );
    });

    test('any unknown ident before ( errors explicitly', () {
      expect(
        () => SlopeSolver.solve('y = f(x)'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => SlopeSolver.solve('y = g(t)'),
        throwsA(isA<FormatException>()),
      );
    });

    test('call notation on the left side errors explicitly', () {
      expect(
        () => SlopeSolver.solve('x(t) = cos(t)'),
        throwsA(isA<FormatException>()),
      );
    });

    test('known functions still parse after the hardening', () {
      final r = SlopeSolver.solve('y = sin(x^2)', pointValues: {'x': 1.0});
      // d/dx sin(x^2) = 2x cos(x^2) -> 2 cos(1) at x=1.
      expect(r.slopeValue, closeTo(1.0806, 1e-3));
    });
  });

  group('PointValues parsing (Cycle 10 Item 3)', () {
    test('single-letter var still accepted', () {
      expect(PointValues.parse('x=2'), {'x': 2.0});
    });

    test('multi-char var x1 accepted and consumed by the solver', () {
      final vars = PointValues.parse('x1=2 x=1');
      expect(vars, {'x1': 2.0, 'x': 1.0});
      final r = SlopeSolver.solve('x1 * x', pointValues: vars);
      expect(r.slopeValue, closeTo(2.0, 1e-9));
      expect(r.point, {'x1': 2.0, 'x': 1.0});
    });

    test('multi-char var theta accepted and consumed by the solver', () {
      final vars = PointValues.parse('theta=0.5 x=1');
      expect(vars, {'theta': 0.5, 'x': 1.0});
      final r = SlopeSolver.solve('theta * x', pointValues: vars);
      expect(r.slopeValue, closeTo(0.5, 1e-9));
    });

    test('scientific notation accepted', () {
      expect(PointValues.parse('x=1e-3'), {'x': 0.001});
      expect(PointValues.parse('x=2E5'), {'x': 200000.0});
      expect(PointValues.parse('y=-1.5e2'), {'y': -150.0});
      expect(
        SlopeSolver.solve('x^2', pointValues: PointValues.parse('x=1e-3'))
            .slopeValue,
        closeTo(0.002, 1e-9),
      );
    });

    test('space-separated multiple vars accepted', () {
      expect(PointValues.parse('x=3  y=4'), {'x': 3.0, 'y': 4.0});
    });

    test('malformed parts are skipped, empty input yields empty map', () {
      expect(PointValues.parse('x=abc y=2'), {'y': 2.0});
      expect(PointValues.parse(''), isEmpty);
    });
  });
}
