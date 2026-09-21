// Cycle 12 Item 1: L'Hopital's rule as the 5th Evaluating Limits method.
// Solver-level output tests mirroring the sibling evaluating-limits
// patterns: sin(x)/x -> 1, (x^2-4)/(x-2) -> 4, and the non-indeterminate
// error path.
import 'package:calculus_system/topics/calculus/finals/solvers/evaluating_limits_solver/by_lhopital/lhopital_engine.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/evaluating_limits_solver/by_lhopital/solution_steps.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final engine = LhopitalSolverEngine();

  group("LhopitalSolverEngine 0/0 limits (Cycle 12 Item 1)", () {
    test('lim x->0 sin(x)/x = 1', () {
      final result = engine.solve(
          const LhopitalProblem(expression: 'sin(x)/x', approachValue: 0));
      expect(result.solved, isTrue);
      expect(result.isIndeterminate, isTrue);
      expect(result.resultString, '1');
      expect(result.roundsApplied, 1);
    });

    test('lim x->2 (x^2-4)/(x-2) = 4', () {
      final result = engine.solve(const LhopitalProblem(
        expression: '(x^2-4)/(x-2)',
        approachValue: 2,
      ));
      expect(result.solved, isTrue);
      expect(result.resultString, '4');
    });

    test('lim x->0 (e^x-1)/x = 1', () {
      final result = engine.solve(
          const LhopitalProblem(expression: '(e^x-1)/x', approachValue: 0));
      expect(result.solved, isTrue);
      expect(result.resultString, '1');
    });

    test('lim x->0 (1-cos(x))/x^2 = 1/2 (two rounds)', () {
      final result = engine.solve(const LhopitalProblem(
          expression: '(1-cos(x))/x^2', approachValue: 0));
      expect(result.solved, isTrue);
      expect(result.resultString, '1/2');
      expect(result.roundsApplied, 2);
    });

    test('respects the chosen variable', () {
      final result = engine.solve(const LhopitalProblem(
        expression: 'sin t / t',
        approachValue: 0,
        variable: 't',
      ));
      expect(result.solved, isTrue);
      expect(result.resultString, '1');
    });
  });

  group("LhopitalSolverEngine infinity/infinity (Cycle 12 Item 1)", () {
    test('lim x->infinity (2x+1)/(x+3) = 2', () {
      final result = engine.solve(const LhopitalProblem(
        expression: '(2x+1)/(x+3)',
        approachValue: double.infinity,
      ));
      expect(result.solved, isTrue);
      expect(result.isInfinityOverInfinity, isTrue);
      expect(result.resultString, '2');
    });
  });

  group("LhopitalSolverEngine error paths (Cycle 12 Item 1)", () {
    test('non-indeterminate form falls to error path', () {
      final result = engine.solve(
          const LhopitalProblem(expression: '(x+1)/(x-1)', approachValue: 0));
      expect(result.solved, isFalse);
      expect(result.isIndeterminate, isFalse);
      expect(result.errorMessage, contains('Not an indeterminate form'));
    });

    test('garbage input never throws, returns error', () {
      final result = engine.solve(const LhopitalProblem(
        expression: 'garbage((/',
        approachValue: 0,
      ));
      expect(result.solved, isFalse);
      expect(result.errorMessage, isNotNull);
    });
  });

  group("LhopitalStepsGenerator (Cycle 12 Item 1)", () {
    test('generates narration for a solved limit', () {
      final result = engine.solve(
          const LhopitalProblem(expression: 'sin(x)/x', approachValue: 0));
      final steps = LhopitalStepsGenerator().generate(result);
      expect(steps.length, greaterThanOrEqualTo(5));
      expect(steps.first.title, 'Write the Equation');
      expect(
        steps.any((s) => s.title.contains("L'Hopital's Rule")),
        isTrue,
      );
      expect(steps.last.title, 'Final Answer');
    });

    test('generates a single error step for the error path', () {
      final result = engine.solve(
          const LhopitalProblem(expression: '(x+1)/(x-1)', approachValue: 0));
      final steps = LhopitalStepsGenerator().generate(result);
      expect(steps.length, 1);
      expect(steps.first.title, 'Error');
    });
  });
}
