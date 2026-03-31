// radical_solver.dart
//
// Public API for the radical inequality solver.
// This file is intentionally thin: parse, dispatch, build steps.
// All math lives in radical_forms.dart and radical_helpers.dart.
//
// Supported forms  (op ∈ { <, ≤, >, ≥ }):
//
//   Form A  √(ax+b)  op  k              — radical vs constant
//   Form B  k        op  √(ax+b)        — constant vs radical  (normalised → A)
//   Form C  √(ax+b)  op  cx+d           — radical vs linear
//   Form D  cx+d     op  √(ax+b)        — linear vs radical    (normalised → C)
//   Form E  √(ax+b)  op  √(cx+d)        — radical vs radical
//   Form F  √(ax+b)  op  ex²+cx+d       — radical vs quadratic
//   Form G  ex²+cx+d op  √(ax+b)        — quadratic vs radical (normalised → F)

import 'package:calculus_system/modules/inequalities/core/inequality_core_solver.dart';
import 'package:calculus_system/modules/inequalities/radical/solver/radical_form.dart';
import 'package:calculus_system/modules/inequalities/radical/solver/radical_parsers.dart';
import '../../../../core/solve_result.dart';
import '../../../../core/step_model.dart';
import 'radical_models.dart';

class RadicalSolver {
  // ── Public entry points ───────────────────────────────────────────────────

  static SolveResult solve(String input) {
    try {
      final p = RadicalParser.parse(input);
      if (p == null) {
        return SolveResult.error('Could not parse radical inequality.');
      }
      return RadicalForms.solve(p);
    } catch (e) {
      return SolveResult.error('Error: $e');
    }
  }

  static List<StepModel> getSteps(String input) {
    try {
      final p = RadicalParser.parse(input);
      if (p == null) return [];
      return _buildSteps(p);
    } catch (_) {
      return [];
    }
  }

  // ── Step builder ──────────────────────────────────────────────────────────

  static List<StepModel> _buildSteps(RadicalPrep p) {
    final steps = <StepModel>[];
    int n = 1;
    const f = InequalityCoreSolver.fmt;
    final domBound = p.ia != 0 ? -p.ib / p.ia : double.nan;
    final domOp = p.ia > 0 ? '≥' : '≤';

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Write the original inequality',
      explanation: 'Start with the given radical inequality.',
      latex: p.original,
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Establish the domain',
      explanation: 'The radicand must be non-negative.',
      latex: p.ia == 0
          ? '${f(p.ib)} ≥ 0  →  domain: all reals'
          : '${p.inner} ≥ 0  →  x $domOp ${f(domBound)}',
    ));

    switch (p.rhsType) {
      case RhsType.constant:
        final k = p.k!;
        if ((p.op == '<' || p.op == '≤') && k < 0) {
          steps.add(StepModel(
            stepNumber: n++,
            title: 'Check RHS sign',
            explanation: '√ ≥ 0 always — cannot be less than a negative.',
            latex: 'No solution',
          ));
          break;
        }
        if ((p.op == '>' || p.op == '≥') && k < 0) {
          steps.add(StepModel(
            stepNumber: n++,
            title: 'Check RHS sign',
            explanation: '√ ≥ 0 > ${f(k)} always — entire domain satisfies.',
            latex: RadicalForms.solve(p).intervalNotation,
          ));
          break;
        }
        steps.add(StepModel(
          stepNumber: n++,
          title: 'Square both sides',
          explanation: 'Both sides ≥ 0, squaring preserves the inequality.',
          latex: '${p.inner} ${p.op} ${f(k * k)}',
        ));
        final rawBound = p.ia != 0 ? (k * k - p.ib) / p.ia : 0.0;
        final sqOp = p.ia > 0 ? p.op : InequalityCoreSolver.flipOp(p.op);
        steps.add(StepModel(
          stepNumber: n++,
          title: 'Solve the linear inequality',
          explanation: p.ia < 0
              ? 'Dividing by negative flips the inequality.'
              : 'Isolate x.',
          latex: 'x $sqOp ${f(rawBound)}',
        ));
        steps.add(StepModel(
          stepNumber: n++,
          title: 'Intersect with domain — S.S.',
          explanation: 'x $domOp ${f(domBound)}  AND  x $sqOp ${f(rawBound)}',
          latex: RadicalForms.solve(p).intervalNotation,
        ));

      case RhsType.radical:
        steps.add(StepModel(
          stepNumber: n++,
          title: 'Second domain',
          explanation: 'Right radicand must also be ≥ 0.',
          latex: '${p.rhsExpr} ≥ 0',
        ));
        steps.add(StepModel(
          stepNumber: n++,
          title: 'Square both sides',
          explanation: 'Both sides ≥ 0 on combined domain.',
          latex: '${p.inner} ${p.op} ${p.rhsExpr}',
        ));
        steps.add(StepModel(
          stepNumber: n++,
          title: 'Solve linear inequality — S.S.',
          explanation: 'Intersect with both domain constraints.',
          latex: RadicalForms.solve(p).intervalNotation,
        ));

      case RhsType.linear:
        steps.add(StepModel(
          stepNumber: n++,
          title: 'Sign analysis of RHS',
          explanation: p.op == '>' || p.op == '≥'
              ? 'Case I: RHS < 0 → auto-satisfied on domain ∩ {RHS<0}.\n'
                  'Case II: RHS ≥ 0 → square both sides.'
              : 'LHS ≥ 0, so RHS must be ≥ 0. Restrict then square.',
          latex: '${p.rhsExpr} = 0  →  x = '
              '${f(p.rc != 0 ? -p.rd! / p.rc! : 0)}',
        ));
        steps.add(StepModel(
          stepNumber: n++,
          title: 'Square both sides (Case II)',
          explanation: 'On region where both sides ≥ 0.',
          latex: '${p.inner} ${p.op} (${p.rhsExpr})²',
        ));
        steps.add(StepModel(
          stepNumber: n++,
          title: 'Solve quadratic and intersect — S.S.',
          explanation:
              'Solve the resulting quadratic inequality, then intersect with domain.',
          latex: RadicalForms.solve(p).intervalNotation,
        ));

      case RhsType.quadratic:
        steps.add(StepModel(
          stepNumber: n++,
          title: 'Sign analysis of RHS',
          explanation:
              'Determine where the quadratic RHS is negative vs non-negative.',
          latex: '${p.rhsExpr} = 0',
        ));
        steps.add(StepModel(
          stepNumber: n++,
          title: 'Square both sides (where RHS ≥ 0)',
          explanation:
              'Squaring gives a degree-4 expression. Critical points found numerically.',
          latex: '${p.inner} ${p.op} (${p.rhsExpr})²',
        ));
        steps.add(StepModel(
          stepNumber: n++,
          title: 'Write the solution set — S.S.',
          explanation: 'Intersect all conditions with the domain.',
          latex: RadicalForms.solve(p).intervalNotation,
        ));
    }

    return steps;
  }
}
