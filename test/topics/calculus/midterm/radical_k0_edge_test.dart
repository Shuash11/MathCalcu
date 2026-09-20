// Cycle 10 Item 9: k=0 edge-case tests for GeneratedRadicalSolver.
// Written BEFORE the fix to prove the bug: with k=0, sqrt(bx + c) < k
// fell through to the general path where squaredBoundary == domainBoundary,
// rendering a degenerate interval like [0, 0] instead of "No solution".
import 'package:calculus_system/topics/calculus/midterm/solvers/inequalities_solver/generated_radical_solver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Radical solver k=0 strict < (Cycle 10 Item 9)', () {
    test('sqrt(x) < 0 is No solution, not [0, 0]', () {
      final r = GeneratedRadicalSolver.solve('sqrt(x) < 0');
      expect(r.hasError, isFalse);
      expect(r.answer, 'No solution');
      expect(r.intervalNotation, '∅');
      expect(r.points, isEmpty);
    });

    test('sqrt(2x - 4) < 0 is No solution, not [2, 2]', () {
      final r = GeneratedRadicalSolver.solve('sqrt(2x - 4) < 0');
      expect(r.hasError, isFalse);
      expect(r.answer, 'No solution');
      expect(r.intervalNotation, '∅');
    });
  });

  group('Radical solver k=0 non-strict <= (Cycle 10 Item 9)', () {
    test('sqrt(x) <= 0 is the single point x = 0', () {
      final r = GeneratedRadicalSolver.solve('sqrt(x) <= 0');
      expect(r.hasError, isFalse);
      expect(r.answer, contains('x = 0'));
      expect(r.points, [0]);
      expect(r.intervalNotation, '[0, 0]');
    });

    test('sqrt(2x - 4) <= 0 is the single point x = 2', () {
      final r = GeneratedRadicalSolver.solve('sqrt(2x - 4) <= 0');
      expect(r.hasError, isFalse);
      expect(r.answer, contains('x = 2'));
      expect(r.points, [2]);
    });
  });

  group('Radical solver k>0 unchanged (Cycle 10 Item 9)', () {
    test('sqrt(x) > 2 still solves to the x >= 4 ray', () {
      final r = GeneratedRadicalSolver.solve('sqrt(x) > 2');
      expect(r.hasError, isFalse);
      expect(r.answer, contains('4'));
      expect(r.intervalNotation, '[4, ∞)');
    });

    test('sqrt(x) >= 2 still solves to the x >= 4 ray', () {
      final r = GeneratedRadicalSolver.solve('sqrt(x) >= 2');
      expect(r.hasError, isFalse);
      expect(r.answer, contains('x ≥ 4'));
      expect(r.intervalNotation, '[4, ∞)');
    });
  });
}
