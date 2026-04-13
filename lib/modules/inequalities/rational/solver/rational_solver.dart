import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/modules/inequalities/core/inequality_core_solver.dart';

class RationalSolver {
  // ─── Public API ───────────────────────────────────────────────────────────

  static SolveResult solve(String input) {
    try {
      final p = _parse(input);
      if (p == null) {
        return SolveResult.error('Could not parse rational expression.');
      }

      final intervals = _buildIntervals(p);
      if (intervals.isEmpty) {
        return const SolveResult(
            answer: 'No solution', points: [], intervalNotation: '∅');
      }

      final intervalNotation = intervals.join(' ∪ ');
      return SolveResult(
        answer: intervalNotation,
        points: _criticalPoints(p),
        intervalNotation: intervalNotation,
      );
    } catch (e) {
      return SolveResult.error('Error: $e');
    }
  }

  static List<StepModel> getSteps(String input) {
    final steps = <StepModel>[];
    final p = _parse(input);
    if (p == null) return steps;

    int n = 1;
    const f = InequalityCoreSolver.fmt;
    final numStr = _ll(p.numA, p.numC);
    final denStr = _ll(p.denA, p.denC);
    final rhsFmt = f(p.rhs);
    final combStr = _ll(p.combA, p.combC);

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Original Inequality',
      explanation: 'Start with the given rational inequality.',
      latex: r'\frac{' + numStr + r'}{' + denStr + r'} ${_tex(p.op)} ' + rhsFmt,
    ));

    if (p.rhs != 0) {
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Subtract Constant',
        explanation:
            'Move all terms to one side to compare the expression with zero.',
        latex: r'\frac{' +
            numStr +
            r'}{' +
            denStr +
            r'} - ' +
            // ignore: prefer_interpolation_to_compose_strings
            rhsFmt +
            ' ' +
            _tex(p.op) +
            ' 0',
      ));

      final rhsExp = _ll(p.rhs * p.denA, p.rhs * p.denC);
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Common Denominator',
        explanation:
            'Rewrite the constant as a fraction over the common denominator.',
        latex: r'\frac{' +
            numStr +
            r'}{' +
            denStr +
            r'} - \frac{' +
            rhsExp +
            r'}{' +
            denStr +
            r'} ' +
            // ignore: prefer_interpolation_to_compose_strings
            _tex(p.op) +
            ' 0',
      ));

      steps.add(StepModel(
        stepNumber: n++,
        title: 'Combine Fractions',
        explanation:
            'Subtract the numerators while keeping the common denominator.',
        latex: r'\frac{' +
            numStr +
            r' - (' +
            rhsExp +
            r')}{' +
            denStr +
            r'} ' +
            // ignore: prefer_interpolation_to_compose_strings
            _tex(p.op) +
            ' 0',
      ));
    }

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Standard Form',
      explanation: 'Simplify the numerator to reach standard form.',
      // ignore: prefer_interpolation_to_compose_strings
      latex: r'\frac{' + combStr + r'}{' + denStr + r'} ' + _tex(p.op) + ' 0',
    ));

    final numZero = p.combA != 0 ? -p.combC / p.combA : double.nan;
    if (!numZero.isNaN) {
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Numerator Zero',
        explanation:
            'Find the points where the expression equals zero (the roots).',
        latex: '$combStr = 0 \\implies x = ${f(numZero)}',
      ));
    }

    final denZero = p.denA != 0 ? -p.denC / p.denA : double.nan;
    if (!denZero.isNaN) {
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Denominator Zero',
        explanation:
            'Find where the expression is undefined (vertical asymptotes).',
        latex: '$denStr = 0 \\implies x = ${f(denZero)}',
      ));
    }

    final pts = _criticalPoints(p)..sort();
    steps.add(StepModel(
      stepNumber: n++,
      title: 'Sign Analysis',
      explanation:
          'Test each interval on the number line to find where the inequality holds true.',
      latex: _buildSignChart(p, pts),
    ));

    final intervals = _buildIntervals(p);
    steps.add(StepModel(
      stepNumber: n++,
      title: 'Interval Notation',
      explanation:
          'Combine the successful intervals into the final solution set.',
      latex: intervals.isEmpty ? r'\emptyset' : intervals.join(' \\cup '),
    ));

    return steps;
  }

  // ─── Internal helpers ─────────────────────────────────────────────────────

  static String _buildSignChart(_Parsed p, List<double> pts) {
    const f = InequalityCoreSolver.fmt;
    final testPts = <double>[
      pts.first - 1,
      for (int i = 0; i < pts.length - 1; i++) (pts[i] + pts[i + 1]) / 2,
      pts.last + 1,
    ];

    final buffer = StringBuffer();
    buffer.write(r'\begin{aligned} ');
    for (int i = 0; i < testPts.length; i++) {
      final tx = testPts[i];
      final denVal = p.denA * tx + p.denC;
      if (denVal == 0) continue;
      final numVal = p.combA * tx + p.combC;
      final satisfies = InequalityCoreSolver.evalOp(numVal / denVal, p.op, 0);
      final mark = satisfies ? r'\text{ \checkmark}' : r'\text{ \times}';

      buffer.write(
          'x = ${f(tx)}: \\quad \\frac{${f(numVal)}}{${f(denVal)}} ${_tex(p.op)} 0 \\implies $mark');
      if (i < testPts.length - 1) buffer.write(r' \\ ');
    }
    buffer.write(r' \end{aligned}');
    return buffer.toString();
  }

  static String _tex(String op) => switch (op) {
        '≥' => '\\geq',
        '≤' => '\\leq',
        '>' => '>',
        '<' => '<',
        _ => op,
      };

  static _Parsed? _parse(String input) {
    final normalized = InequalityCoreSolver.normalize(input);
    final op = InequalityCoreSolver.extractOperator(normalized);
    if (op == null) return null;

    final sides = InequalityCoreSolver.splitOnOp(normalized, op);
    if (sides == null) return null;

    final slashIdx = sides[0].indexOf('/');
    if (slashIdx == -1) return null;

    final numStr =
        sides[0].substring(0, slashIdx).replaceAll('(', '').replaceAll(')', '');
    final denStr = sides[0]
        .substring(slashIdx + 1)
        .replaceAll('(', '')
        .replaceAll(')', '');
    final rhs = double.tryParse(sides[1].trim()) ?? 0.0;

    final numP = InequalityCoreSolver.parseLinear(numStr);
    final denP = InequalityCoreSolver.parseLinear(denStr);
    if (numP == null || denP == null) return null;

    final numA = numP['x']!, numC = numP['c']!;
    final denA = denP['x']!, denC = denP['c']!;

    // Combined numerator:  (numA - rhs·denA)x + (numC - rhs·denC)
    final combA = numA - rhs * denA;
    final combC = numC - rhs * denC;

    return _Parsed(
      op: op,
      numA: numA,
      numC: numC,
      denA: denA,
      denC: denC,
      rhs: rhs,
      combA: combA,
      combC: combC,
    );
  }

  static List<double> _criticalPoints(_Parsed p) {
    final pts = <double>[];
    if (p.combA != 0) pts.add(-p.combC / p.combA);
    if (p.denA != 0) pts.add(-p.denC / p.denA);
    // Remove duplicates
    return pts.toSet().toList();
  }

  static bool _satisfies(double x, _Parsed p) {
    final den = p.denA * x + p.denC;
    if (den == 0) return false;
    final val = (p.combA * x + p.combC) / den;
    return InequalityCoreSolver.evalOp(val, p.op, 0);
  }

  static List<String> _buildIntervals(_Parsed p) {
    final strict = p.op == '<' || p.op == '>';
    final denZero = p.denA != 0 ? -p.denC / p.denA : double.nan;
    final undefinedPts = {if (!denZero.isNaN) denZero};

    final pts = _criticalPoints(p)..sort();
    if (pts.isEmpty) return [];

    final testPts = <double>[
      pts.first - 1,
      for (int i = 0; i < pts.length - 1; i++) (pts[i] + pts[i + 1]) / 2,
      pts.last + 1,
    ];

    final solution = <String>[];
    for (int i = 0; i < testPts.length; i++) {
      if (!_satisfies(testPts[i], p)) continue;

      if (i == 0) {
        final hi = pts[0];
        final hiOpen = strict || undefinedPts.contains(hi);
        solution
            .add('(-∞, ${InequalityCoreSolver.fmt(hi)}${hiOpen ? ')' : ']'}');
      } else if (i == testPts.length - 1) {
        final lo = pts.last;
        final loOpen = strict || undefinedPts.contains(lo);
        solution
            .add('${loOpen ? '(' : '['}${InequalityCoreSolver.fmt(lo)}, +∞)');
      } else {
        final lo = pts[i - 1];
        final hi = pts[i];
        final loOpen = strict || undefinedPts.contains(lo);
        final hiOpen = strict || undefinedPts.contains(hi);
        solution.add(
          '${loOpen ? '(' : '['}${InequalityCoreSolver.fmt(lo)}, '
          '${InequalityCoreSolver.fmt(hi)}${hiOpen ? ')' : ']'}',
        );
      }
    }
    return solution;
  }

  /// Linear expression string: "2x + 3", "x - 5", "-4", etc.
  static String _ll(double a, double c) {
    if (a == 0) return InequalityCoreSolver.fmt(c);
    final aStr = a == 1
        ? 'x'
        : a == -1
            ? '-x'
            : '${InequalityCoreSolver.fmt(a)}x';
    if (c == 0) return aStr;
    final sign = c > 0 ? '+' : '-';
    return '$aStr $sign ${InequalityCoreSolver.fmt(c.abs())}';
  }
}

// ─── Data holder ──────────────────────────────────────────────────────────────
class _Parsed {
  final String op;
  final double numA, numC;
  final double denA, denC;
  final double rhs;
  final double combA, combC;

  const _Parsed({
    required this.op,
    required this.numA,
    required this.numC,
    required this.denA,
    required this.denC,
    required this.rhs,
    required this.combA,
    required this.combC,
  });
}
