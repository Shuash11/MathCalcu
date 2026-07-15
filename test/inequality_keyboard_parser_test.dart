import 'package:calculus_system/topics/calculus/midterm/solvers/inequalities_solver/inequality_solver_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('keyboard inequality parsing', () {
    test('accepts the keyboard less-than-or-equal glyph', () {
      final result = InequalitySolverRouter.solve('2x + 1 ≤ 5');

      expect(result.hasError, isFalse);
      expect(result.points, hasLength(1));
      expect(result.points.single, closeTo(2, 1e-9));
      expect(result.intervalNotation, '(-∞, 2]');
    });

    test('accepts the keyboard greater-than-or-equal glyph', () {
      final result = InequalitySolverRouter.solve('3x - 2 ≥ 4');

      expect(result.hasError, isFalse);
      expect(result.points, hasLength(1));
      expect(result.points.single, closeTo(2, 1e-9));
      expect(result.intervalNotation, '[2, ∞)');
    });

    test('parses a linear inequality with a trailing decimal right-hand side', () {
      final result = InequalitySolverRouter.solve('2x - 4 > 3.');

      expect(result.hasError, isFalse);
      expect(result.points, hasLength(1));
      expect(result.points.single, closeTo(3.5, 1e-9));
      expect(result.intervalNotation, '(7/2, ∞)');
    });

    test('parses a quadratic with a decimal boundary', () {
      final result = InequalitySolverRouter.solve('x^2 > 0.75');

      expect(result.hasError, isFalse);
      expect(result.points, hasLength(2));
      expect(result.points.first, closeTo(-0.8660254038, 1e-6));
      expect(result.points.last, closeTo(0.8660254038, 1e-6));
    });

    test('expands adjacent linear factors as a quadratic product', () {
      final result = InequalitySolverRouter.solve('(2x+1)(x-3) > 0');

      expect(result.hasError, isFalse);
      expect(result.points, hasLength(2));
      expect(result.points.first, closeTo(-0.5, 1e-9));
      expect(result.points.last, closeTo(3, 1e-9));
    });

    test('rejects powers above two instead of treating them as linear', () {
      final result = InequalitySolverRouter.solve('x^3 > 0');

      expect(result.hasError, isTrue);
      expect(result.errorMessage, contains('Unsupported power'));
    });
  });
}
