// Cycle 10 Item 7: chain-rule sub-step generation in DerivativeSolver.getSteps.
// Written BEFORE the fix to prove the gap: nested/chained expressions
// (sin(x^2), (2x+1)^3) got only a single top-level rule label and no
// sub-steps showing the outer/inner decomposition. Rule labels mirror the
// sibling slope_using_derivatives per-rule decomposition and surface
// through the existing DerivativeStepTile UI unchanged.
import 'package:calculus_system/topics/calculus/finals/solvers/derivatives_solver/derivatives_solver.dart';
import 'package:flutter_test/flutter_test.dart';

List<DerivativeStep> ruleStepsOf(String expr, String v) {
  final steps = DerivativeSolver.getSteps(expr, v);
  return steps.steps.where((s) => s.type == StepType.identifyRule).toList();
}

String squash(String s) => s.replaceAll(' ', '');

void main() {
  group('DerivativeSolver chain sub-steps (Cycle 10 Item 7)', () {
    test('sin(x^2) shows chain sub-steps: outer/inner + inner rule label', () {
      final rules = ruleStepsOf('sin(x^2)', 'x');
      expect(rules.first.rule, contains('Chain Rule'));
      final chain = rules.where((s) => s.rule!.contains('outer')).toList();
      expect(chain, isNotEmpty, reason: 'no chain decomposition sub-step');
      expect(chain.first.rule, contains('inner'));
      expect(squash(chain.first.rule!), contains('x^2'));
      expect(
        rules.where((s) => squash(s.rule!).contains('PowerRule')),
        isNotEmpty,
        reason: 'no rule label for the inner x^2',
      );
    });

    test('(2x+1)^3 shows power + chain decomposition', () {
      final rules = ruleStepsOf('(2x+1)^3', 'x');
      expect(rules.first.rule, contains('Power Rule'));
      final chain = rules.where((s) => s.rule!.contains('outer')).toList();
      expect(chain, isNotEmpty, reason: 'no chain decomposition sub-step');
      expect(chain.first.rule, contains('inner'));
      expect(squash(chain.first.rule!), contains('(2*x+1)'));
      expect(
        rules.where((s) => squash(s.rule!).contains('Sum/DifferenceRule')),
        isNotEmpty,
        reason: 'no rule label for the inner 2x+1',
      );
    });

    test('simple expressions gain no sub-steps', () {
      expect(ruleStepsOf('x^2', 'x'), hasLength(1));
      expect(ruleStepsOf('sin(x)', 'x'), hasLength(1));
    });

    test('nested chains recurse under sub-step guards', () {
      final rules = ruleStepsOf('sin(cos(x^2))', 'x');
      expect(rules.where((s) => s.rule!.contains('outer')), hasLength(2));
      expect(rules.length, lessThanOrEqualTo(13));
    });
  });
}
