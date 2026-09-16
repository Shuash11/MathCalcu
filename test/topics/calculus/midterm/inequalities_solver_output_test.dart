// Cycle 1 Batch B (Item 3): output-level regression tests for the
// midterm inequalities solvers. Written BEFORE the Item 1 fix so the
// LaTeX assertions fail on the corrupted `≠?` token and pass after.
//
// Pattern follows test/services/update_service_test.dart: pure group/test,
// no widget binding needed.
import 'package:calculus_system/topics/calculus/midterm/solvers/inequalities_solver/inequality_solver_router.dart';
import 'package:flutter_test/flutter_test.dart';

String _allLatex(String input) {
  final steps = InequalitySolverRouter.getSteps(input);
  return steps.map((s) => '${s.latex} ${(s.details ?? []).join(' ')}').join('\n');
}

void main() {
  group('Inequalities solver output (Batch B Item 3)', () {
    test('linear >= renders \\geq in steps latex', () {
      final latex = _allLatex('2x + 1 >= 5');
      expect(latex, contains(r'\geq'));
    });

    test('linear <= renders \\leq in steps latex', () {
      final latex = _allLatex('2x + 1 <= 5');
      expect(latex, contains(r'\leq'));
    });

    test('absolute <= (narrow) renders \\leq not \\geq', () {
      final latex = _allLatex('|x| <= 3');
      expect(latex, contains(r'\leq'));
      expect(latex, isNot(contains(r'\geq')));
    });

    test('absolute >= (wide) renders both branch ops', () {
      // Theorem 2: |X| >= k  =>  X <= -k or X >= k, so both symbols appear.
      final latex = _allLatex('|x| >= 5');
      expect(latex, contains(r'\geq'));
      expect(latex, contains(r'\leq'));
    });

    test('absolute narrow solves to bounded interval', () {
      final result = InequalitySolverRouter.solve('|x| <= 3');
      expect(result.hasError, isFalse);
      expect(result.intervalNotation, '[-3, 3]');
    });

    test('absolute wide solves to union of rays', () {
      final result = InequalitySolverRouter.solve('|x| >= 5');
      expect(result.hasError, isFalse);
      expect(result.intervalNotation, contains('∪'));
      expect(result.intervalNotation, contains('-∞'));
    });

    test('absolute k==0 with <= gives single point', () {
      final result = InequalitySolverRouter.solve('|x| <= 0');
      expect(result.hasError, isFalse);
      expect(result.answer, contains('x = 0'));
    });

    test('quadratic solves to two boundary points', () {
      final result = InequalitySolverRouter.solve('x^2 > 0.75');
      expect(result.hasError, isFalse);
      expect(result.points, hasLength(2));
    });

    test('rational solver returns steps with latex', () {
      final steps = InequalitySolverRouter.getSteps('(x+1)/(x-2) > 0');
      expect(steps, isNotEmpty);
      expect(steps.map((s) => s.latex).join(), isNotEmpty);
    });

    test('radical solver returns a solution or error without throwing', () {
      final result = InequalitySolverRouter.solve('sqrt(x) > 2');
      expect(result.hasError, isA<bool>());
    });
  });
}
