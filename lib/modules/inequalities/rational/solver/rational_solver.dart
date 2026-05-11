// ignore_for_file: prefer_const_declarations, prefer_interpolation_to_compose_strings

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
      final inequalityAnswer = _intervalsToInequalityAnswer(intervals);
      return SolveResult(
        answer: inequalityAnswer,
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

    final numZero = p.combA != 0 ? -p.combC / p.combA : double.nan;
    final denZero = p.denA != 0 ? -p.denC / p.denA : double.nan;
    final pts = _criticalPoints(p)..sort();

    int criticalCount = 0;
    if (!numZero.isNaN) criticalCount++;
    if (!denZero.isNaN) criticalCount++;

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Given Inequality',
      explanation: 'Original inequality to solve.',
      latex: r'\frac{' + numStr + r'}{' + denStr + r'} ' + _tex(p.op) + ' ' + rhsFmt,
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Step 1 — Find $criticalCount Critical Points',
      explanation: 'Find where numerator and denominator equal zero.',
      subLatex: _buildCriticalPointsStep(p, numZero, denZero),
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
            _tex(p.op) +
            ' 0',
      ));
    }

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Set Inequality to Zero',
      explanation: 'Rearrange so the right side equals zero.',
      latex: r'\frac{' + combStr + r'}{' + denStr + r'} ' + _tex(p.op) + ' 0',
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Step 3 — ${pts.length + 1} Regions on the Number Line',
      explanation: 'Divide the number line at each critical point.',
      subLatex: _buildRegionsStep(pts),
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Step 4 — Test Each Region',
      explanation: 'Pick a test point from each region and evaluate.',
      subLatex: _buildTestRegionsStep(p, pts),
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Step 5 — Check $criticalCount Critical Points',
      explanation: 'Check if critical points satisfy the inequality.',
      subLatex: _buildCriticalPointsCheckStep(p, numZero, denZero),
    ));

    final intervals = _buildIntervals(p);
    final inequalityAnswer = _intervalsToInequalityAnswer(intervals);
    final intervalNotation = intervals.isEmpty ? '∅' : intervals.join(' ∪ ');

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Final Answer',
      explanation: 'Combine the valid regions.',
      latex: inequalityAnswer,
      subLatex: [intervalNotation],
    ));

    return steps;
  }

  static List<String> _buildCriticalPointsStep(_Parsed p, double numZero, double denZero) {
    final results = <String>[];
    final f = InequalityCoreSolver.fmt;

    if (!numZero.isNaN) {
      results.add(_ll(p.numA, p.numC) + ' = 0  →  x = ' + f(numZero));
    }
    if (!denZero.isNaN) {
      results.add(_ll(p.denA, p.denC) + ' = 0  →  x = ' + f(denZero));
    }

    if (results.isEmpty) {
      return [r'\text{No critical points}'];
    }
    return results;
  }

  static List<String> _buildRegionsStep(List<double> pts) {
    if (pts.isEmpty) {
      return [r'\text{No regions}'];
    }

    final f = InequalityCoreSolver.fmt;
    final regions = <String>[];

    final regionCount = pts.length + 1;
    if (regionCount == 2) {
      regions.add('x < ' + f(pts[0]));
      regions.add('x > ' + f(pts[0]));
    } else {
      regions.add('x < ' + f(pts[0]));
      for (int i = 0; i < pts.length - 1; i++) {
        regions.add(f(pts[i]) + ' < x < ' + f(pts[i + 1]));
      }
      regions.add('x > ' + f(pts.last));
    }

    return regions;
  }

  static List<String> _buildTestRegionsStep(_Parsed p, List<double> pts) {
    if (pts.isEmpty) return [r'\text{No regions to test}'];

    final f = InequalityCoreSolver.fmt;
    final testPts = <double>[
      pts.first - 1,
      for (int i = 0; i < pts.length - 1; i++) (pts[i] + pts[i + 1]) / 2,
      pts.last + 1,
    ];

    final results = <String>[];

    for (int i = 0; i < testPts.length; i++) {
      final tx = testPts[i];
      final denVal = p.denA * tx + p.denC;
      if (denVal == 0) continue;
      final numVal = p.combA * tx + p.combC;
      final satisfies = InequalityCoreSolver.evalOp(numVal / denVal, p.op, 0);
      final mark = satisfies ? '✓' : '✗';

      results.add('x = ' + f(tx) + r': \frac{' + f(numVal) + '}{' + f(denVal) + '} = ' + f(numVal / denVal) + ' ' + mark);
    }

    return results;
  }

  static List<String> _buildCriticalPointsCheckStep(_Parsed p, double numZero, double denZero) {
    final results = <String>[];
    final f = InequalityCoreSolver.fmt;
    final op = p.op;

    if (!numZero.isNaN) {
      final numVal = p.combA * numZero + p.combC;
      final satisfies = numVal == 0 && (op == '≥' || op == '≤');
      final result = satisfies ? '✓' : '✗';
      results.add('x = ' + f(numZero) + ': = 0, ' + _tex(op) + ' 0 ' + result);
    }

    if (!denZero.isNaN) {
      results.add('x = ' + f(denZero) + ': undefined ✗');
    }

    if (results.isEmpty) {
      return [r'\text{No critical points to check}'];
    }

    return results;
  }

  // ─── Internal helpers ─────────────────────────────────────────────────────

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

  static String _intervalToInequality(String interval) {
    final isOpenLeft = !interval.startsWith('[');
    final isOpenRight = !interval.endsWith(']');

    final inner = interval.substring(1, interval.length - 1).trim();
    final innerParts = inner.split(',');

    if (innerParts.length == 2) {
      final lo = innerParts[0].trim();
      final hi = innerParts[1].trim();

      if (lo == '-∞') {
        return isOpenRight ? ' x < $hi' : ' x ≤ $hi';
      } else if (hi == '+∞') {
        return isOpenLeft ? ' x > $lo' : ' x ≥ $lo';
      } else {
        final loOp = isOpenLeft ? ' < ' : ' ≤ ';
        final hiOp = isOpenRight ? ' < ' : ' ≤ ';
        return '$lo$loOp x $hiOp$hi';
      }
    }
    return interval;
  }

  static String _intervalsToInequalityAnswer(List<String> intervals) {
    return intervals.map(_intervalToInequality).join(' or ');
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
