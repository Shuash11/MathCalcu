import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/modules/inequalities/core/inequality_core_solver.dart';

class LinearSolver {
  static SolveResult solve(String input) {
    final normalized = InequalityCoreSolver.normalize(input);
    final ops = _extractOps(normalized);
    if (ops.isEmpty) return SolveResult.error('No operator found.');

    if (ops.length == 2) {
      final parts = _splitDouble(normalized);
      if (parts == null) {
        return SolveResult.error('Could not split double inequality.');
      }
      return _solveDouble(normalized, ops, parts);
    }

    final op = ops[0];
    final sides = InequalityCoreSolver.splitOnOp(normalized, op);
    if (sides == null) return SolveResult.error('Could not split on operator.');

    final left = InequalityCoreSolver.parseLinear(sides[0]);
    final right = InequalityCoreSolver.parseLinear(sides[1]);
    if (left == null || right == null)
      // ignore: curly_braces_in_flow_control_structures
      return SolveResult.error('Could not parse linear expressions.');

    final la = left['x']!, lc = left['c']!;
    final ra = right['x']!, rc = right['c']!;
    final a = la - ra, b = lc - rc;

    if (a == 0) {
      final sat = InequalityCoreSolver.evalOp(b, op, 0);
      return SolveResult(
        answer: sat ? 'All real numbers' : 'No solution',
        points: [],
        intervalNotation: sat ? '(-∞, ∞)' : '∅',
      );
    }

    final boundary = -b / a;
    final finalOp = a < 0 ? InequalityCoreSolver.flipOp(op) : op;
    return SolveResult(
      answer: 'x $finalOp ${InequalityCoreSolver.fmt(boundary)}',
      points: [boundary],
      intervalNotation: InequalityCoreSolver.interval(finalOp, boundary),
    );
  }

  static List<StepModel> getSteps(String input) {
    final steps = <StepModel>[];
    final normalized = InequalityCoreSolver.normalize(input);
    final ops = _extractOps(normalized);
    if (ops.isEmpty) return steps;

    if (ops.length == 2) {
      final parts = _splitDouble(normalized);
      if (parts == null) return steps;
      return _stepsDouble(input, ops, parts);
    }

    final op = ops[0];
    final sides = InequalityCoreSolver.splitOnOp(normalized, op);
    if (sides == null) return steps;

    final left = InequalityCoreSolver.parseLinear(sides[0]);
    final right = InequalityCoreSolver.parseLinear(sides[1]);
    if (left == null || right == null) return steps;

    final la = left['x']!, lc = left['c']!;
    final ra = right['x']!, rc = right['c']!;
    final a = la - ra, b = lc - rc;

    int n = 1;
    const f = InequalityCoreSolver.fmt;

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Original Inequality',
      explanation: 'Start with the given inequality.',
      latex: input.trim(),
    ));

    if (ra != 0 || rc != 0) {
      final aMove = -ra, bMove = -rc;
      final sA = aMove >= 0 ? '+' : '-';
      final sB = bMove >= 0 ? '+' : '-';
      
      final lhs1 = '${_cl(la)}x ${lc != 0 ? (lc > 0 ? "+ ${f(lc)}" : "- ${f(lc.abs())}") : ""}';
      final rhs1 = '${ra != 0 ? "${_cl(ra)}x" : ""} ${rc != 0 ? (rc > 0 ? (ra != 0 ? "+ ${f(rc)}" : f(rc)) : "- ${f(rc.abs())}") : (ra == 0 ? "0" : "")}';
      
      final lhs2 = '$lhs1 ${ra != 0 ? "$sA ${_cl(aMove.abs())}x" : ""} ${rc != 0 ? "$sB ${f(bMove.abs())}" : ""}';

      steps.add(StepModel(
        stepNumber: n++,
        title: 'Group Variables and Constants',
        explanation: 'Move all terms containing x to the left side and all constants to the right (or left) to compare with zero.',
        latex:
            '\\begin{aligned} $lhs1 &${_tex(op)} $rhs1 \\\\ $lhs2 &${_tex(op)} 0 \\end{aligned}',
      ));
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Combine Like Terms',
        explanation: 'Simplify both sides by grouping the x-terms and the numerical constants.',
        latex: '${_cl(a)}x ${b != 0 ? (b > 0 ? "+ ${f(b)}" : "- ${f(b.abs())}") : ""} ${_tex(op)} 0',
      ));
    }

    if (b != 0) {
      final bMove = -b;
      final moveAction = bMove >= 0 ? 'Add' : 'Subtract';
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Isolate Variable Term',
        explanation: 'Move the constant term to the other side by $moveAction ${f(bMove.abs())} on both sides.',
        latex:
            '\\begin{aligned} ${_cl(a)}x ${b > 0 ? "+ ${f(b)}" : "- ${f(b.abs())}"} &${_tex(op)} 0 \\\\ ${_cl(a)}x &${_tex(op)} ${f(bMove)} \\end{aligned}',
      ));
    }

    if (a == 0) {
      final sat = InequalityCoreSolver.evalOp(b, op, 0);
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Evaluate Result',
        explanation: 'Check if the resulting inequality is a true mathematical statement.',
        latex:
            '${f(b)} ${_tex(op)} 0 \\quad \\rightarrow \\quad ${sat ? "\\text{True}" : "\\text{False}"}',
      ));
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Solution Summary',
        explanation: sat
            ? 'The statement is always true, so x can be any real number.'
            : 'The statement is false, so there is no solution for x.',
        latex: sat ? r'(-\infty, \infty)' : r'\emptyset',
      ));
      return steps;
    }

    final finalOp = a < 0 ? InequalityCoreSolver.flipOp(op) : op;
    final boundary = -b / a;
    if (a != 1) {
      final action = a < 0
          ? 'Divide by ${f(a)} and flip the inequality sign (since it is negative)'
          : 'Divide by ${f(a)} on both sides';

      steps.add(StepModel(
        stepNumber: n++,
        title: 'Divide by Coefficient',
        explanation: '$action to isolate x.',
        latex:
            '\\begin{aligned} \\frac{${_cl(a)}x}{${f(a)}} &${_tex(finalOp)} \\frac{${f(-b)}}{${f(a)}} \\\\ x &${_tex(finalOp)} ${f(boundary)} \\end{aligned}',
      ));
    }

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Interval Notation',
      explanation: 'Final solution set expressed in interval notation.',
      latex: InequalityCoreSolver.interval(finalOp, boundary),
    ));

    return steps;
  }

  static String _cl(double a) {
    if (a == 1) return '';
    if (a == -1) return '-';
    return InequalityCoreSolver.fmt(a);
  }

  static String _tex(String op) => switch (op) {
        '≥' => '\\geq',
        '≤' => '\\leq',
        '>' => '>',
        '<' => '<',
        _ => op,
      };

  static List<String> _extractOps(String s) {
    final ops = <String>[];
    for (int i = 0; i < s.length; i++) {
      final ch = s[i];
      if (ch == '<' || ch == '>' || ch == '≤' || ch == '≥') ops.add(ch);
    }
    return ops;
  }

  static List<String>? _splitDouble(String s) {
    final ops = _extractOps(s);
    if (ops.length != 2) return null;
    final idx1 = s.indexOf(ops[0]);
    final idx2 = s.indexOf(ops[1], idx1 + 1);
    return [
      s.substring(0, idx1),
      s.substring(idx1 + 1, idx2),
      s.substring(idx2 + 1),
    ];
  }

  static SolveResult _solveDouble(
      String normalized, List<String> ops, List<String> parts) {
    final left = InequalityCoreSolver.parseLinear(parts[0]);
    final mid = InequalityCoreSolver.parseLinear(parts[1]);
    final right = InequalityCoreSolver.parseLinear(parts[2]);
    if (left == null ||
        mid == null ||
        right == null ||
        left['x'] != 0 ||
        right['x'] != 0) {
      return SolveResult.error('Unsupported double inequality form.');
    }
    final mx = mid['x']!, mc = mid['c']!;
    final lc = left['c']!, rc = right['c']!;
    if (mx == 0) return SolveResult.error('No variable in middle.');

    double bL = (lc - mc) / mx, bR = (rc - mc) / mx;
    String op1 = ops[0], op2 = ops[1];

    if (mx < 0) {
      op1 = InequalityCoreSolver.flipOp(op1);
      op2 = InequalityCoreSolver.flipOp(op2);
      if (bL > bR) {
        final tB = bL;
        bL = bR;
        bR = tB;
        final tO = op1;
        op1 = InequalityCoreSolver.flipOp(op2);
        op2 = InequalityCoreSolver.flipOp(tO);
      }
    }
    if (bL > bR || (bL == bR && (op1 == '<' || op2 == '<'))) {
      return const SolveResult(
          answer: 'No solution', points: [], intervalNotation: '∅');
    }
    final lb = (op1 == '≤' || op1 == '≥') ? '[' : '(';
    final rb = (op2 == '≤' || op2 == '≥') ? ']' : ')';
    final interval =
        '$lb${InequalityCoreSolver.fmt(bL)}, ${InequalityCoreSolver.fmt(bR)}$rb';
    final answer =
        '${InequalityCoreSolver.fmt(bL)} $op1 x $op2 ${InequalityCoreSolver.fmt(bR)}';
    return SolveResult(
        answer: answer, points: [bL, bR], intervalNotation: interval);
  }

  static List<StepModel> _stepsDouble(
      String input, List<String> ops, List<String> parts) {
    final steps = <StepModel>[];
    int n = 1;
    const f = InequalityCoreSolver.fmt;

    steps.add(StepModel(
        stepNumber: n++,
        title: 'Original Inequality',
        explanation: 'Start with the compound inequality.',
        latex: input.trim()));
    final left = InequalityCoreSolver.parseLinear(parts[0]);
    final mid = InequalityCoreSolver.parseLinear(parts[1]);
    final right = InequalityCoreSolver.parseLinear(parts[2]);
    if (left == null ||
        mid == null ||
        right == null ||
        left['x'] != 0 ||
        right['x'] != 0) {
      return steps;
    }

    final mx = mid['x']!, mc = mid['c']!, lc = left['c']!, rc = right['c']!;
    if (mx == 0) return steps;
    String op1 = ops[0], op2 = ops[1];

    if (mc != 0) {
      final nL = lc - mc, nR = rc - mc;
      final xPart = '${_cl(mx)}x';
      final action = mc > 0 ? 'Subtract' : 'Add';
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Isolate Variable Term',
        explanation: 'Move the constant term away from the middle by performing $action ${f(mc.abs())} on all parts of the inequality.',
        latex:
            '\\begin{aligned} ${f(lc)} - ${f(mc)} &${_tex(op1)} $xPart + ${f(mc)} - ${f(mc)} &&${_tex(op2)} ${f(rc)} - ${f(mc)} \\\\ ${f(nL)} &${_tex(op1)} $xPart &&${_tex(op2)} ${f(nR)} \\end{aligned}',
      ));
    }

    double bL = (lc - mc) / mx, bR = (rc - mc) / mx;
    if (mx == 1) {
      // Done
    } else if (mx < 0) {
      op1 = InequalityCoreSolver.flipOp(op1);
      op2 = InequalityCoreSolver.flipOp(op2);
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Divide by Negative',
        explanation:
            'Divide all parts by ${f(mx)} and flip the inequality symbols because we are dividing by a negative number.',
        latex:
            '\\begin{aligned} \\frac{${f(lc - mc)}}{${f(mx)}} &${_tex(op1)} x &&${_tex(op2)} \\frac{${f(rc - mc)}}{${f(mx)}} \\\\ ${f(bL)} &${_tex(op1)} x &&${_tex(op2)} ${f(bR)} \\end{aligned}',
      ));
      if (bL > bR) {
        final tB = bL;
        bL = bR;
        bR = tB;
        final tO = op1;
        op1 = InequalityCoreSolver.flipOp(op2);
        op2 = InequalityCoreSolver.flipOp(tO);
        steps.add(StepModel(
          stepNumber: n++,
          title: 'Rewrite in Ascending Order',
          explanation: 'Reorganize the solution to show the range from smallest to largest.',
          latex: '${f(bL)} ${_tex(op1)} x ${_tex(op2)} ${f(bR)}',
        ));
      }
    } else {
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Divide All Parts',
        explanation: 'Divide every part of the inequality by ${f(mx)} to isolate x in the middle.',
        latex:
            '\\begin{aligned} \\frac{${f(lc - mc)}}{${f(mx)}} &${_tex(op1)} x &&${_tex(op2)} \\frac{${f(rc - mc)}}{${f(mx)}} \\\\ ${f(bL)} &${_tex(op1)} x &&${_tex(op2)} ${f(bR)} \\end{aligned}',
      ));
    }

    final bool noSol = bL > bR || (bL == bR && (op1 == '<' || op2 == '<'));
    steps.add(StepModel(
      stepNumber: n++,
      title: 'Interval Notation',
      explanation: 'Final solution set expressed in interval notation.',
      latex: noSol ? r'\emptyset' : solve(input).intervalNotation,
    ));
    return steps;
  }
}
