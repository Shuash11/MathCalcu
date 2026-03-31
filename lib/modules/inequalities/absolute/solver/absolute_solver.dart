import '../../../../core/solve_result.dart';
import '../../../../core/step_model.dart';
import '../../core/inequality_core_solver.dart';

class AbsoluteSolver {
  static SolveResult solve(String input) {
    try {
      final normalized = InequalityCoreSolver.normalize(input);
      final op = InequalityCoreSolver.extractOperator(normalized);
      if (op == null) return SolveResult.error('No operator found.');

      final sides = InequalityCoreSolver.splitOnOp(normalized, op);
      if (sides == null) return SolveResult.error('Could not split.');

      String absSide, constSide;
      bool absOnLeft;
      if (sides[0].contains('|')) {
        absSide = sides[0];
        constSide = sides[1];
        absOnLeft = true;
      } else if (sides[1].contains('|')) {
        absSide = sides[1];
        constSide = sides[0];
        absOnLeft = false;
      } else {
        return SolveResult.error('No absolute value bars found.');
      }

      final inner = absSide.replaceAll('|', '');
      final parsed = InequalityCoreSolver.parseLinear(inner);
      final k = double.tryParse(constSide);

      if (parsed == null || k == null) {
        return SolveResult.error('Could not parse absolute value expression.');
      }

      final a = parsed['x']!;
      final b = parsed['c']!;
      final effectiveOp = absOnLeft ? op : InequalityCoreSolver.flipOp(op);

      if (effectiveOp == '<' || effectiveOp == '≤') {
        if (k < 0)
          return const SolveResult(
              answer: 'No solution', points: [], intervalNotation: '∅');
        if (k == 0 && effectiveOp == '<')
          return const SolveResult(
              answer: 'No solution', points: [], intervalNotation: '∅');
        if (k == 0 && effectiveOp == '≤') {
          if (a == 0)
            return const SolveResult(
                answer: 'No solution', points: [], intervalNotation: '∅');
          final root = -b / a;
          return SolveResult(
              answer: 'x = ${InequalityCoreSolver.fmt(root)}',
              points: [root],
              intervalNotation: '{${InequalityCoreSolver.fmt(root)}}');
        }
        if (a == 0)
          return const SolveResult(
              answer: 'No solution', points: [], intervalNotation: '∅');
        final v1 = (-k - b) / a;
        final v2 = (k - b) / a;
        final l = v1 < v2 ? v1 : v2;
        final h = v1 < v2 ? v2 : v1;
        final lb = effectiveOp == '<' ? '(' : '[';
        final rb = effectiveOp == '<' ? ')' : ']';
        return SolveResult(
          answer:
              '${InequalityCoreSolver.fmt(l)} $effectiveOp x $effectiveOp ${InequalityCoreSolver.fmt(h)}',
          points: [l, h],
          intervalNotation:
              '$lb${InequalityCoreSolver.fmt(l)}, ${InequalityCoreSolver.fmt(h)}$rb',
        );
      } else {
        if (k < 0)
          return const SolveResult(
              answer: 'All real numbers',
              points: [],
              intervalNotation: '(-∞, +∞)');
        if (k == 0 && effectiveOp == '≥') {
          return const SolveResult(
              answer: 'All real numbers',
              points: [],
              intervalNotation: '(-∞, +∞)');
        }
        if (a == 0)
          return const SolveResult(
              answer: 'No solution', points: [], intervalNotation: '∅');
        if (k == 0 && effectiveOp == '>') {
          final root = -b / a;
          return SolveResult(
            answer: 'x ≠ ${InequalityCoreSolver.fmt(root)}',
            points: [root],
            intervalNotation:
                '(-∞, ${InequalityCoreSolver.fmt(root)}) ∪ (${InequalityCoreSolver.fmt(root)}, +∞)',
          );
        }
        final v1 = (-k - b) / a;
        final v2 = (k - b) / a;
        final l = v1 < v2 ? v1 : v2;
        final h = v1 < v2 ? v2 : v1;
        final b1 = effectiveOp == '>' ? ')' : ']';
        final b2 = effectiveOp == '>' ? '(' : '[';
        return SolveResult(
          answer:
              'x < ${InequalityCoreSolver.fmt(l)} or x > ${InequalityCoreSolver.fmt(h)}',
          points: [l, h],
          intervalNotation:
              '(-∞, ${InequalityCoreSolver.fmt(l)}$b1 ∪ $b2${InequalityCoreSolver.fmt(h)}, +∞)',
        );
      }
    } catch (e) {
      return SolveResult.error('Error: $e');
    }
  }

  static List<StepModel> getSteps(String input) {
    final steps = <StepModel>[];
    final normalized = InequalityCoreSolver.normalize(input);
    final op = InequalityCoreSolver.extractOperator(normalized);
    if (op == null) return steps;

    final sides = InequalityCoreSolver.splitOnOp(normalized, op);
    if (sides == null) return steps;

    String absSide, constSide;
    if (sides[0].contains('|')) {
      absSide = sides[0];
      constSide = sides[1];
    } else {
      absSide = sides[1];
      constSide = sides[0];
    }

    final inner = absSide.replaceAll('|', '');
    final k = double.tryParse(constSide) ?? 0;
    final parsed = InequalityCoreSolver.parseLinear(inner);
    if (parsed == null) return steps;

    final a = parsed['x']!;
    final b = parsed['c']!;
    int n = 1;

    final kFmt = InequalityCoreSolver.fmt(k);
    final nkFmt = InequalityCoreSolver.fmt(-k);

    // ── Step 1: Given ─────────────────────────────────────────────────────────
    steps.add(StepModel(
      stepNumber: n++,
      title: 'Given',
      explanation: '',
      latex: input.trim(),
    ));

    if (op == '<' || op == '≤') {
      // ── Step 2: Split ───────────────────────────────────────────────────────
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Split',
        explanation: '',
        latex: '$nkFmt $op $inner $op $kFmt',
      ));

      final v1 = (-k - b) / a;
      final v2 = (k - b) / a;
      final l = v1 < v2 ? v1 : v2;
      final h = v1 < v2 ? v2 : v1;
      final boundOp = a < 0 ? InequalityCoreSolver.flipOp(op) : op;

      // ── Step 3: Left ────────────────────────────────────────────────────────
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Left',
        explanation: '',
        latex:
            '$nkFmt $op $inner  →  x $boundOp ${InequalityCoreSolver.fmt(l)}',
      ));

      // ── Step 4: Right ───────────────────────────────────────────────────────
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Right',
        explanation: '',
        latex: '$inner $op $kFmt  →  x $boundOp ${InequalityCoreSolver.fmt(h)}',
      ));
    } else {
      // ── Step 2: Split ───────────────────────────────────────────────────────
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Split',
        explanation: '',
        latex:
            '$inner $op $nkFmt  OR  $inner ${InequalityCoreSolver.flipOp(op)} $kFmt',
      ));

      final v1 = (-k - b) / a;
      final v2 = (k - b) / a;
      final l = v1 < v2 ? v1 : v2;
      final h = v1 < v2 ? v2 : v1;
      final boundOp = a < 0 ? InequalityCoreSolver.flipOp(op) : op;

      // ── Step 3: Case 1 ──────────────────────────────────────────────────────
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Case 1',
        explanation: '',
        latex:
            '$inner $op $nkFmt  →  x ${InequalityCoreSolver.flipOp(boundOp)} ${InequalityCoreSolver.fmt(l)}',
      ));

      // ── Step 4: Case 2 ──────────────────────────────────────────────────────
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Case 2',
        explanation: '',
        latex:
            '$inner ${InequalityCoreSolver.flipOp(op)} $kFmt  →  x $boundOp ${InequalityCoreSolver.fmt(h)}',
      ));
    }

    // ── Step 5: Solution ──────────────────────────────────────────────────────
    steps.add(StepModel(
      stepNumber: n++,
      title: 'Solution',
      explanation: '',
      latex: solve(input).intervalNotation,
    ));

    return steps;
  }
}
