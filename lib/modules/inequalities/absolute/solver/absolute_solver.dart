import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/modules/inequalities/core/inequality_core_solver.dart';

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
        if (k < 0) return const SolveResult(answer: 'No solution', points: [], intervalNotation: '∅');
        if (k == 0 && effectiveOp == '<') return const SolveResult(answer: 'No solution', points: [], intervalNotation: '∅');
        if (k == 0 && effectiveOp == '≤') {
          if (a == 0) return const SolveResult(answer: 'No solution', points: [], intervalNotation: '∅');
          final root = -b / a;
          return SolveResult(answer: 'x = ${InequalityCoreSolver.fmt(root)}', points: [root], intervalNotation: '{${InequalityCoreSolver.fmt(root)}}');
        }
        if (a == 0) return const SolveResult(answer: 'No solution', points: [], intervalNotation: '∅');

        final v1 = (-k - b) / a, v2 = (k - b) / a;
        final l = v1 < v2 ? v1 : v2, h = v1 < v2 ? v2 : v1;
        final lb = effectiveOp == '<' ? '(' : '[', rb = effectiveOp == '<' ? ')' : ']';
        return SolveResult(
          answer: '${InequalityCoreSolver.fmt(l)} $effectiveOp x $effectiveOp ${InequalityCoreSolver.fmt(h)}',
          points: [l, h],
          intervalNotation: '$lb${InequalityCoreSolver.fmt(l)}, ${InequalityCoreSolver.fmt(h)}$rb',
        );
      } else {
        if (k < 0) return const SolveResult(answer: 'All real numbers', points: [], intervalNotation: '(-∞, ∞)');
        if (k == 0 && effectiveOp == '≥') return const SolveResult(answer: 'All real numbers', points: [], intervalNotation: '(-∞, ∞)');
        if (a == 0) return const SolveResult(answer: 'No solution', points: [], intervalNotation: '∅');
        if (k == 0 && effectiveOp == '>') {
          final root = -b / a;
          final fR = InequalityCoreSolver.fmt(root);
          return SolveResult(answer: 'x ≠ $fR', points: [root], intervalNotation: '(-∞, $fR) ∪ ($fR, ∞)');
        }
        final v1 = (-k - b) / a, v2 = (k - b) / a;
        final l = v1 < v2 ? v1 : v2, h = v1 < v2 ? v2 : v1;
        final b1 = effectiveOp == '>' ? ')' : ']', b2 = effectiveOp == '>' ? '(' : '[';
        final fL = InequalityCoreSolver.fmt(l), fH = InequalityCoreSolver.fmt(h);
        return SolveResult(
          answer: 'x ${InequalityCoreSolver.flipOp(effectiveOp)} $fL or x $effectiveOp $fH',
          points: [l, h],
          intervalNotation: '(-∞, $fL$b1 ∪ $b2$fH, ∞)',
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

    final a = parsed['x']!, b = parsed['c']!;
    int n = 1;
    const f = InequalityCoreSolver.fmt;
    final kF = f(k), nkF = f(-k);

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Original Inequality',
      explanation: 'Identified the given absolute value inequality.',
      latex: input.trim(),
    ));

    final isNarrow = op == '<' || op == '≤';

    if (isNarrow) {
      // Theorem 1: |X| < k <=> -k < X < k
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Apply Absolute Property',
        explanation:
            'Rewrite based on the property |X| ${_tex(op)} k ⇔ -k ${_tex(op)} X ${_tex(op)} k.',
        latex: '$nkF ${_tex(op)} $inner ${_tex(op)} $kF',
      ));

      // Step: Isolate the variable term (Add/Subtract constant to all parts)
      final bMove = -b;
      final k1 = -k + bMove, k2 = k + bMove;
      final moveAction =
          bMove >= 0 ? 'Add ${f(bMove.abs())}' : 'Subtract ${f(bMove.abs())}';

      steps.add(StepModel(
        stepNumber: n++,
        title: 'Isolate Variable Term',
        explanation: '$moveAction all parts to isolate the variable term.',
        latex:
            '\\begin{aligned} $nkF ${bMove >= 0 ? "+" : "-"} ${f(bMove.abs())} &${_tex(op)} ${_coef(a)}x ${_tex(op)} $kF ${bMove >= 0 ? "+" : "-"} ${f(bMove.abs())} \\\\ \\implies ${f(k1)} &${_tex(op)} ${_coef(a)}x ${_tex(op)} ${f(k2)} \\end{aligned}',
      ));

      // Step: Divide by coefficient a
      if (a != 1) {
        final v1 = k1 / a, v2 = k2 / a;
        final range = [v1, v2]..sort();
        final l = range[0], h = range[1];
        final bOp = a < 0 ? InequalityCoreSolver.flipOp(op) : op;
        final action = a < 0
            ? 'Divide by ${f(a)} and flip the inequality signs'
            : 'Divide by ${f(a)}';

        steps.add(StepModel(
          stepNumber: n++,
          title: 'Isolate Variable x',
          explanation: '$action to solve for x.',
          latex:
              '\\begin{aligned} \\frac{${f(k1)}}{${f(a)}} &${_tex(bOp)} x ${_tex(bOp)} \\frac{${f(k2)}}{${f(a)}} \\\\ \\implies ${f(l)} &${_tex(bOp)} x ${_tex(bOp)} ${f(h)} \\end{aligned}',
        ));
      }
    } else {
      // Theorem 2: |X| > k <=> X < -k OR X > k
      final flipOp = InequalityCoreSolver.flipOp(op);

      steps.add(StepModel(
        stepNumber: n++,
        title: 'Apply Absolute Property',
        explanation: 'Split into two cases based on |X| ≥ k ⇔ X ≤ -k or X ≥ k.',
        latex: '$inner ${_tex(flipOp)} $nkF \\text{ or } $inner ${_tex(op)} $kF',
      ));
      final bMove = -b;
      final moveAction = bMove >= 0 ? "+" : "-";
      final bAbs = f(bMove.abs());

      // Branch 1 logic
      final v1_1 = (-k - b) / a;
      final op1 = a < 0 ? op : flipOp;
      final k1 = -k + bMove;

      // Branch 2 logic
      final v2_2 = (k - b) / a;
      final op2 = a < 0 ? flipOp : op;
      final k2 = k + bMove;

      steps.add(StepModel(
        stepNumber: n++,
        title: 'Solve Both Cases',
        explanation:
            'Solve the negative and positive branches side-by-side to find the full solution set.',
        subLatex: [
          '\\begin{aligned} \\text{Case 1: } & $inner ${_tex(flipOp)} $nkF \\\\ ${_coef(a)}x &${_tex(flipOp)} $nkF $moveAction $bAbs \\\\ ${_coef(a)}x &${_tex(flipOp)} ${f(k1)} \\\\ x &${_tex(op1)} ${f(v1_1)} \\end{aligned}',
          '\\begin{aligned} \\text{Case 2: } & $inner ${_tex(op)} $kF \\\\ ${_coef(a)}x &${_tex(op)} $kF $moveAction $bAbs \\\\ ${_coef(a)}x &${_tex(op)} ${f(k2)} \\\\ x &${_tex(op2)} ${f(v2_2)} \\end{aligned}',
        ],
      ));
    }

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Final Solution',
      explanation: 'Represent the combined solution set using interval notation.',
      latex: solve(input).intervalNotation,
    ));

    return steps;
  }

  static String _coef(double a) {
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
}
