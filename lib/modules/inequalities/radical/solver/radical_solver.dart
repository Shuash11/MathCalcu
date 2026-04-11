// radical_solver.dart
//
// Public API for the radical inequality solver.
// This file is intentionally thin: parse, dispatch, build steps.
// All math lives in radical_forms.dart and radical_helpers.dart.

import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/modules/inequalities/core/inequality_core_solver.dart';
import 'package:calculus_system/modules/inequalities/radical/solver/radical_form.dart';
import 'package:calculus_system/modules/inequalities/radical/solver/radical_parsers.dart';
import 'package:calculus_system/modules/inequalities/radical/solver/radical_helpers.dart';

import 'radical_models.dart';

class RadicalSolver {
  // Public entry points

  static SolveResult solve(String input) {
    try {
      final p = RadicalParser.parse(input);
      if (p == null) {
        return SolveResult.error('Could not parse radical inequality. '
            'Ensure you have an inequality operator (<, ≤, >, ≥) '
            'and at least one square root expression.');
      }
      return RadicalForms.solve(p);
    } catch (e, stackTrace) {
      return SolveResult.error(
          'Error solving radical inequality: $e\n$stackTrace');
    }
  }

  static List<StepModel> getSteps(String input) {
    try {
      final p = RadicalParser.parse(input);
      if (p == null) return [];
      return _buildSteps(p);
    } catch (e) {
      return [
        StepModel(
          stepNumber: 1,
          title: 'Error',
          explanation: 'Failed to generate steps: $e',
          latex: '',
        )
      ];
    }
  }

  // Step builder

  static List<StepModel> _buildSteps(RadicalPrep p) {
    final steps = <StepModel>[];
    int n = 1;
    const f = InequalityCoreSolver.fmt;

    final domBound = p.ia != 0 ? -p.ib / p.ia : double.nan;
    final domOp = p.ia > 0 ? '≥' : '≤';

    // Step 1: Original inequality
    steps.add(StepModel(
      stepNumber: n++,
      title: 'Problem',
      explanation: 'Start with the original expression.',
      latex: _formatOriginalInequality(p),
    ));

    // Step 2+: Domain steps
    _addDomainSteps(steps, n, p, domBound, domOp, f);
    n = steps.length + 1;

    // Type-specific solving
    switch (p.rhsType) {
      case RhsType.constant:
        _addConstantSteps(steps, n, p, domBound, domOp, f);
        break;
      case RhsType.radical:
        _addRadicalSteps(steps, n, p, domBound, domOp, f);
        break;
      case RhsType.linear:
        _addLinearSteps(steps, n, p, domBound, domOp, f);
        break;
      case RhsType.quadratic:
        _addQuadraticSteps(steps, n, p, domBound, domOp, f);
        break;
    }

    return steps;
  }

  // Helper: Format original inequality

  static String _formatOriginalInequality(RadicalPrep p) {
    final lhs = '\\sqrt{${p.inner}}';
    final rhs = switch (p.rhsType) {
      RhsType.constant => InequalityCoreSolver.fmt(p.k!),
      RhsType.radical => '\\sqrt{${p.rhsExpr}}',
      RhsType.linear || RhsType.quadratic => p.rhsExpr!,
    };
    return '$lhs ${_latexOp(p.op)} $rhs';
  }

  static String _latexOp(String op) => switch (op) {
        '≥' => '\\geq',
        '≤' => '\\leq',
        '>' => '>',
        '<' => '<',
        _ => op,
      };

  // Helper: Domain steps

  static void _addDomainSteps(
    List<StepModel> steps,
    int startN,
    RadicalPrep p,
    double domBound,
    String domOp,
    String Function(double) f,
  ) {
    int n = startN;
    if (p.ia == 0) {
      final isValid = p.ib >= 0;
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Domain Restriction',
        explanation: 'The expression inside the square root must be non-negative.',
        latex:
            '${f(p.ib)} \\geq 0 \\quad \\rightarrow \\quad \\text{(${isValid ? 'True' : 'False'})}',
      ));
      return;
    }

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Domain Restriction',
      explanation: 'The expression inside the square root must be non-negative (x ≥ 0).',
      latex: '${p.inner} \\geq 0',
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Isolate Variable x',
      explanation: 'Solve the domain inequality to find the allowed input range.',
      latex:
          '\\begin{aligned} ${p.inner} &\\geq 0 \\\\ x &${_latexOp(domOp)} ${f(domBound)} \\end{aligned}',
    ));
  }

  // Type-specific step builders

  static void _addConstantSteps(
    List<StepModel> steps,
    int n,
    RadicalPrep p,
    double domBound,
    String domOp,
    String Function(double) f,
  ) {
    final k = p.k!;

    if ((p.op == '<' || p.op == '≤') && k < 0) {
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Analyze Signs',
        explanation:
            'A square root result is always non-negative. It cannot be less than a negative number.',
        latex:
            '\\sqrt{${p.inner}} \\geq 0 \\quad \\text{but} \\quad ${f(k)} < 0',
      ));
      return;
    }

    if ((p.op == '>' || p.op == '≥') && k < 0) {
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Analyze Signs',
        explanation:
            'A square root is always zero or more, which is always greater than any negative number.',
        latex: '\\sqrt{${p.inner}} \\geq 0 > ${f(k)}',
      ));
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Final Solution',
        explanation:
            'Since it is always true, the solution is restricted only by the domain.',
        latex: RadicalForms.solve(p).intervalNotation,
      ));
      return;
    }

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Remove Root',
      explanation: 'Square both sides to eliminate the radical.',
      latex:
          '\\begin{aligned} (\\sqrt{${p.inner}})^2 &${_latexOp(p.op)} (${f(k)})^2 \\\\ ${p.inner} &${_latexOp(p.op)} ${f(k * k)} \\end{aligned}',
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Solve for x',
      explanation: p.ia < 0
          ? 'Isolate x and flip the inequality symbol because we divide by a negative.'
          : 'Isolate x to find the range of values that satisfy the inequality.',
      latex:
          'x ${_latexOp(p.ia > 0 ? p.op : InequalityCoreSolver.flipOp(p.op))} ${f((k * k - p.ib) / p.ia)}',
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Final Solution',
      explanation: 'Combine the algebraic result with the domain restriction.',
      latex: solve(p.original).intervalNotation,
    ));
  }

  static void _addRadicalSteps(
    List<StepModel> steps,
    int n,
    RadicalPrep p,
    double domBound,
    String domOp,
    String Function(double) f,
  ) {
    final rc = p.rc!, rd = p.rd!;
    final rhsDomBound = rc != 0 ? -rd / rc : double.nan;
    final rhsDomOp = rc > 0 ? '≥' : '≤';

    steps.add(StepModel(
      stepNumber: n++,
      title: 'RHS Domain',
      explanation: 'The second root must also have a non-negative inside.',
      latex:
          '${p.rhsExpr} \\geq 0 \\quad \\Rightarrow \\quad x ${_latexOp(rhsDomOp)} ${f(rhsDomBound)}',
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Remove Roots',
      explanation: 'Square both sides to eliminate both radicals.',
      latex:
          '(\\sqrt{${p.inner}})^2 ${_latexOp(p.op)} (\\sqrt{${p.rhsExpr}})^2',
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Simplify',
      explanation: 'After squaring, we get a linear inequality.',
      latex: '${p.inner} ${_latexOp(p.op)} ${p.rhsExpr}',
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Final Answer',
      explanation: 'Combine all valid rules for the result.',
      latex: RadicalForms.solve(p).answer,
    ));
  }

  static void _addLinearSteps(
    List<StepModel> steps,
    int n,
    RadicalPrep p,
    double domBound,
    String domOp,
    String Function(double) f,
  ) {
    final rc = p.rc!, rd = p.rd!;
    final rhsZero = rc != 0 ? -rd / rc : 0.0;

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Check RHS',
      explanation: 'Find where the right side is zero to analyze signs.',
      latex: '${p.rhsExpr} = 0 \\quad \\Rightarrow \\quad x = ${f(rhsZero)}',
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Squaring',
      explanation: 'Square both sides to remove the root.',
      latex: '(\\sqrt{${p.inner}})^2 ${_latexOp(p.op)} (${p.rhsExpr})^2',
    ));

    if (p.rc != null && p.rd != null) {
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Expansion',
        explanation: 'Expand the squared linear expression.',
        latex: RadicalHelpers.expandLinearSquaredLatex(rc, rd),
      ));

      // Move units to one side
      final qae = -rc * rc;
      final qbe = p.ia - 2 * rc * rd;
      final qce = p.ib - rd * rd;
      final s1 = qbe >= 0 ? '+' : '';
      final s2 = qce >= 0 ? '+' : '';

      steps.add(StepModel(
        stepNumber: n++,
        title: 'Rearrange',
        explanation: 'Move all terms to one side to form a quadratic.',
        latex: '0 ${_latexOp(p.op)} ${f(qae)}x^2 $s1 ${f(qbe)}x $s2 ${f(qce)}',
      ));

      steps.add(StepModel(
        stepNumber: n++,
        title: 'Formula',
        explanation: 'Plug the values into the quadratic formula.',
        latex: RadicalHelpers.quadFormulaLatex(qae, qbe, qce),
      ));
    }

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Final Answer',
      explanation: 'Combine all cases and rules.',
      latex: RadicalForms.solve(p).answer,
    ));
  }

  static void _addQuadraticSteps(
    List<StepModel> steps,
    int n,
    RadicalPrep p,
    double domBound,
    String domOp,
    String Function(double) f,
  ) {
    steps.add(StepModel(
      stepNumber: n++,
      title: 'Check RHS',
      explanation: 'Find where the quadratic part is zero.',
      latex: '${p.rhsExpr} = 0',
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Squaring',
      explanation: 'Square both sides to simplify.',
      latex: '(\\sqrt{${p.inner}})^2 = (${p.rhsExpr})^2',
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Final Answer',
      explanation: 'The result is the combination of all valid pieces.',
      latex: RadicalForms.solve(p).answer,
    ));
  }
}
