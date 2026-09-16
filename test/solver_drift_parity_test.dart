// Cycle 1 Batch B (Item 12): drift guard between the SymPy-verified
// Python generators and the shipped Dart solvers.
//
// Source vectors: python_solvers/math_generator.py `main()` (Linear /
// Quadratic / Absolute / Rational `sympy_run_tests` lists) and
// python_solvers/slope_generator.py `verify()` (power-rule cases).
// SymPy syntax is translated to app syntax in comments (e.g. Abs(x) < 3
// becomes '|x| < 3'). If a generator vector changes, update the matching
// expectation here — a failure means Dart drifted from SymPy truth.
import 'package:calculus_system/topics/calculus/finals/solvers/slope_using_derivatives_solver/slope_using_derivatives_solver.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/inequalities_solver/inequality_solver_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Solver drift parity with python_solvers (Batch B Item 12)', () {
    test('Linear vectors: 2x+1>5, 3x-7<=8, -4x+3<11', () {
      final r1 = InequalitySolverRouter.solve('2x+1>5');
      expect(r1.hasError, isFalse);
      expect(r1.points.single, closeTo(2, 1e-9));

      final r2 = InequalitySolverRouter.solve('3x-7<=8');
      expect(r2.hasError, isFalse);
      expect(r2.points.single, closeTo(5, 1e-9));

      // Negative leading coefficient flips the operator: x > -2.
      final r3 = InequalitySolverRouter.solve('-4x+3<11');
      expect(r3.hasError, isFalse);
      expect(r3.points.single, closeTo(-2, 1e-9));
      expect(r3.answer, contains('>'));
    });

    test('Quadratic vectors: x^2-4>0, x^2-5x+6<=0', () {
      final r1 = InequalitySolverRouter.solve('x^2-4>0');
      expect(r1.hasError, isFalse);
      expect(r1.points[0], closeTo(-2, 1e-9));
      expect(r1.points[1], closeTo(2, 1e-9));

      final r2 = InequalitySolverRouter.solve('x^2-5x+6<=0');
      expect(r2.hasError, isFalse);
      expect(r2.points[0], closeTo(2, 1e-9));
      expect(r2.points[1], closeTo(3, 1e-9));
    });

    test('Absolute vectors from math_generator.py', () {
      // Abs(x) < 3  ->  -3 < x < 3
      final narrow = InequalitySolverRouter.solve('|x|<3');
      expect(narrow.hasError, isFalse);
      expect(narrow.intervalNotation, '(-3, 3)');

      // Abs(2*x - 1) >= 3  ->  x <= -1 or x >= 2
      final wide = InequalitySolverRouter.solve('|2x-1|>=3');
      expect(wide.hasError, isFalse);
      expect(wide.answer, contains('-1'));
      expect(wide.answer, contains('2'));

      // Abs(x) > 0  ->  x < 0 or x > 0
      final strict = InequalitySolverRouter.solve('|x|>0');
      expect(strict.hasError, isFalse);
      expect(strict.answer, contains('or'));

      // Abs(x) >= 0  ->  All real numbers
      expect(
        InequalitySolverRouter.solve('|x|>=0').answer,
        'All real numbers',
      );

      // Abs(x) < 0  ->  No solution
      expect(
        InequalitySolverRouter.solve('|x|<0').answer,
        'No solution',
      );

      // Abs(x) <= 0  ->  x = 0
      expect(
        InequalitySolverRouter.solve('|x|<=0').answer,
        contains('x = 0'),
      );

      // Abs(2*x - 3) <= 5  ->  -1 <= x <= 4
      final compound = InequalitySolverRouter.solve('|2x-3|<=5');
      expect(compound.hasError, isFalse);
      expect(compound.points[0], closeTo(-1, 1e-9));
      expect(compound.points[1], closeTo(4, 1e-9));

      // Abs(4 - 3*x) > 7  ->  x < -1 or x > 11/3
      final negLead = InequalitySolverRouter.solve('|4-3x|>7');
      expect(negLead.hasError, isFalse);
      expect(negLead.points[0], closeTo(-1, 1e-9));
      expect(negLead.points[1], closeTo(11 / 3, 1e-9));
    });

    test('Rational vector: (x+1)/(x-2)>0', () {
      final r = InequalitySolverRouter.solve('(x+1)/(x-2)>0');
      expect(r.hasError, isFalse);
      expect(r.points[0], closeTo(-1, 1e-9));
      expect(r.points[1], closeTo(2, 1e-9));
    });

    test('Slope generator power-rule vectors (slope_generator.py verify)',
        () {
      // d/dx x^2 = 2x  ->  slope 6 at x=3.
      expect(
        SlopeSolver.solve('y = x^2', pointValues: {'x': 3.0}).slopeValue,
        closeTo(6.0, 1e-6),
      );
      // d/dx x^3 = 3x^2  ->  slope 12 at x=2.
      expect(
        SlopeSolver.solve('y = x^3', pointValues: {'x': 2.0}).slopeValue,
        closeTo(12.0, 1e-6),
      );
      // d/dx sin(x) = cos(x)  ->  slope 1 at x=0.
      expect(
        SlopeSolver.solve('y = sin(x)', pointValues: {'x': 0.0}).slopeValue,
        closeTo(1.0, 1e-6),
      );
    });
  });
}
