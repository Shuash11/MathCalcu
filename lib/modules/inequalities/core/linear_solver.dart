import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';

import 'inequality_core_solver.dart';

class LinearSolver {
  static SolveResult solve(String input) {
    try {
      final normalized = InequalityCoreSolver.normalize(input);
      final ops = RegExp(r'[≥≤><]')
          .allMatches(normalized)
          .map((m) => m.group(0)!)
          .toList();
      if (ops.isEmpty) {
        return SolveResult.error('No inequality operator found.');
      }

      if (ops.length == 2) {
        final parts = normalized.split(RegExp(r'[≥≤><]'));
        return _solveDouble(normalized, ops, parts);
      }

      final op = ops[0];
      final sides = InequalityCoreSolver.splitOnOp(normalized, op);
      if (sides == null) {
        return SolveResult.error('Could not split expression.');
      }

      final left = InequalityCoreSolver.parseLinear(sides[0]);
      final right = InequalityCoreSolver.parseLinear(sides[1]);
      if (left == null || right == null) {
        return SolveResult.error(
            'Could not parse expression. Check your input.');
      }

      final a = left['x']! - right['x']!;
      final b = left['c']! - right['c']!;

      if (a == 0) {
        final satisfies = InequalityCoreSolver.evalOp(-b, op, 0);
        if (satisfies) {
          return const SolveResult(
              answer: 'All real numbers',
              points: [],
              intervalNotation: '(-∞, ∞)');
        } else {
          return const SolveResult(
              answer: 'No solution', points: [], intervalNotation: '∅');
        }
      }

      final boundary = -b / a;
      final finalOp = a < 0 ? InequalityCoreSolver.flipOp(op) : op;
      final answer = 'x $finalOp ${InequalityCoreSolver.fmt(boundary)}';
      final interval = InequalityCoreSolver.interval(finalOp, boundary);

      return SolveResult(
          answer: answer, points: [boundary], intervalNotation: interval);
    } catch (e) {
      return SolveResult.error('Error solving: $e');
    }
  }

  static List<StepModel> getSteps(String input) {
    final steps = <StepModel>[];
    final normalized = InequalityCoreSolver.normalize(input);
    final ops = RegExp(r'[≥≤><]')
        .allMatches(normalized)
        .map((m) => m.group(0)!)
        .toList();
    if (ops.isEmpty) return steps;

    if (ops.length == 2) {
      final parts = normalized.split(RegExp(r'[≥≤><]'));
      return _stepsDouble(input, ops, parts);
    }

    final op = ops[0];
    final sides = InequalityCoreSolver.splitOnOp(normalized, op);
    if (sides == null) return steps;

    final left = InequalityCoreSolver.parseLinear(sides[0]);
    final right = InequalityCoreSolver.parseLinear(sides[1]);
    if (left == null || right == null) return steps;

    final la = left['x']!;
    final lc = left['c']!;
    final ra = right['x']!;
    final rc = right['c']!;
    final a = la - ra;
    final b = lc - rc;

    int n = 1;

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Original inequality',
      explanation: '',
      latex: input.trim(),
    ));

    if (ra != 0) {
      final xPart =
          a == 1 ? 'x' : (a == -1 ? '-x' : '${InequalityCoreSolver.fmt(a)}x');
      final cPart = lc >= 0
          ? (lc != 0 ? '+ ${InequalityCoreSolver.fmt(lc)}' : '')
          : InequalityCoreSolver.fmt(lc);
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Group x terms',
        explanation: '',
        latex:
            '$xPart ${cPart.isNotEmpty ? cPart : ""} $op ${InequalityCoreSolver.fmt(rc)}',
      ));
    }

    if (lc != 0) {
      final rhs = rc - lc;
      final xPart =
          a == 1 ? 'x' : (a == -1 ? '-x' : '${InequalityCoreSolver.fmt(a)}x');
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Move constants',
        explanation: '',
        latex: '$xPart $op ${InequalityCoreSolver.fmt(rhs)}',
      ));
    }

    if (a == 0) {
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Evaluate constant check',
        explanation: '',
        latex:
            '${InequalityCoreSolver.fmt(b)} $op 0 → ${InequalityCoreSolver.evalOp(b, op, 0) ? "True: All real numbers" : "False: No solution"}',
      ));
      return steps;
    }

    final boundary = -b / a;

    if (a == -1) {
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Divide by -1 (flip inequality)',
        explanation: '',
        latex:
            'x ${InequalityCoreSolver.flipOp(op)} ${InequalityCoreSolver.fmt(boundary)}',
      ));
    } else if (a < 0) {
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Divide by ${InequalityCoreSolver.fmt(a)} (flip inequality)',
        explanation: '',
        latex:
            'x ${InequalityCoreSolver.flipOp(op)} ${InequalityCoreSolver.fmt(boundary)}',
      ));
    } else if (a != 1) {
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Divide by ${InequalityCoreSolver.fmt(a)}',
        explanation: '',
        latex: 'x $op ${InequalityCoreSolver.fmt(boundary)}',
      ));
    }

    final finalOp = a < 0 ? InequalityCoreSolver.flipOp(op) : op;
    steps.add(StepModel(
      stepNumber: n++,
      title: 'Solution set',
      explanation: '',
      latex: InequalityCoreSolver.interval(finalOp, boundary),
    ));

    return steps;
  }

  static SolveResult _solveDouble(
      String normalized, List<String> ops, List<String> parts) {
    if (parts.length != 3) {
      return SolveResult.error('Invalid double inequality format.');
    }
    final left = InequalityCoreSolver.parseLinear(parts[0]);
    final mid = InequalityCoreSolver.parseLinear(parts[1]);
    final right = InequalityCoreSolver.parseLinear(parts[2]);

    if (left == null || mid == null || right == null) {
      return SolveResult.error('Could not parse double inequality parts.');
    }

    if (left['x'] != 0 || right['x'] != 0) {
      return SolveResult.error(
          'Variables on the outside are not supported yet.');
    }

    final mx = mid['x']!;
    final c = mid['c']!;
    final l = left['c']!;
    final r = right['c']!;

    if (mx == 0) return SolveResult.error('No variable in the expression.');

    final newL = l - c;
    final newR = r - c;

    double boundL = newL / mx;
    double boundR = newR / mx;
    String op1 = ops[0];
    String op2 = ops[1];

    if (mx < 0) {
      op1 = InequalityCoreSolver.flipOp(op1);
      op2 = InequalityCoreSolver.flipOp(op2);
      final tempOp = op1;
      op1 = op2;
      op2 = tempOp;

      final tempB = boundL;
      boundL = boundR;
      boundR = tempB;
    }

    final lb = (op1 == '≤' || op1 == '≥') ? '[' : '(';
    final rb = (op2 == '≤' || op2 == '≥') ? ']' : ')';
    final interval =
        '$lb${InequalityCoreSolver.fmt(boundL)}, ${InequalityCoreSolver.fmt(boundR)}$rb';

    if (boundL > boundR || (boundL == boundR && (op1 == '<' || op2 == '<'))) {
      return const SolveResult(
          answer: 'No solution', points: [], intervalNotation: '∅');
    }

    final answer =
        '${InequalityCoreSolver.fmt(boundL)} $op1 x $op2 ${InequalityCoreSolver.fmt(boundR)}';
    return SolveResult(
        answer: answer, points: [boundL, boundR], intervalNotation: interval);
  }

  static List<StepModel> _stepsDouble(
      String input, List<String> ops, List<String> parts) {
    final steps = <StepModel>[];
    int n = 1;

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Original double inequality',
      explanation: '',
      latex: input.trim(),
    ));

    final left = InequalityCoreSolver.parseLinear(parts[0]);
    final mid = InequalityCoreSolver.parseLinear(parts[1]);
    final right = InequalityCoreSolver.parseLinear(parts[2]);
    if (left == null || mid == null || right == null) return steps;
    if (left['x'] != 0 || right['x'] != 0) return steps;

    final mx = mid['x']!;
    final c = mid['c']!;
    final l = left['c']!;
    final r = right['c']!;
    if (mx == 0) return steps;

    if (c != 0) {
      final newL = l - c;
      final newR = r - c;
      final xPart = mx == 1
          ? 'x'
          : (mx == -1 ? '-x' : '${InequalityCoreSolver.fmt(mx)}x');
      steps.add(StepModel(
        stepNumber: n++,
        title: c > 0
            ? 'Subtract ${InequalityCoreSolver.fmt(c)} from all parts'
            : 'Add ${InequalityCoreSolver.fmt(-c)} to all parts',
        explanation: '',
        latex:
            '${InequalityCoreSolver.fmt(newL)} ${ops[0]} $xPart ${ops[1]} ${InequalityCoreSolver.fmt(newR)}',
      ));
    }

    double boundL = (l - c) / mx;
    double boundR = (r - c) / mx;
    String op1 = ops[0];
    String op2 = ops[1];

    if (mx != 1) {
      if (mx < 0) {
        op1 = InequalityCoreSolver.flipOp(op1);
        op2 = InequalityCoreSolver.flipOp(op2);
        final tempOp = op1;
        op1 = op2;
        op2 = tempOp;
        final tempB = boundL;
        boundL = boundR;
        boundR = tempB;

        steps.add(StepModel(
          stepNumber: n++,
          title:
              'Divide by ${InequalityCoreSolver.fmt(mx)} (flip inequalities)',
          explanation: '',
          latex:
              '${InequalityCoreSolver.fmt(boundL)} $op1 x $op2 ${InequalityCoreSolver.fmt(boundR)}',
        ));
      } else {
        steps.add(StepModel(
          stepNumber: n++,
          title: 'Divide by ${InequalityCoreSolver.fmt(mx)}',
          explanation: '',
          latex:
              '${InequalityCoreSolver.fmt(boundL)} $op1 x $op2 ${InequalityCoreSolver.fmt(boundR)}',
        ));
      }
    }

    final lb = (op1 == '≤' || op1 == '≥') ? '[' : '(';
    final rb = (op2 == '≤' || op2 == '≥') ? ']' : ')';
    final interval =
        '$lb${InequalityCoreSolver.fmt(boundL)}, ${InequalityCoreSolver.fmt(boundR)}$rb';

    if (boundL > boundR || (boundL == boundR && (op1 == '<' || op2 == '<'))) {
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Solution set',
        explanation: '',
        latex: 'No solution (∅)',
      ));
    } else {
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Solution set',
        explanation: '',
        latex: interval,
      ));
    }

    return steps;
  }
}
