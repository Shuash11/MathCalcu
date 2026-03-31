import '../../../../core/solve_result.dart';
import '../../../../core/step_model.dart';
import '../../core/inequality_core_solver.dart';

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
    final numStr = _ll(p.numA, p.numC);
    final denStr = _ll(p.denA, p.denC);
    final rhsFmt = InequalityCoreSolver.fmt(p.rhs);
    final combStr = _ll(p.combA, p.combC);

    // ── Step 1: Given ─────────────────────────────────────────────────────────
    steps.add(StepModel(
      stepNumber: n++,
      title: 'Given',
      explanation: '',
      latex: '($numStr) / ($denStr) ${p.op} $rhsFmt',
    ));

    // ── Step 2: Subtract RHS (only when rhs ≠ 0) ─────────────────────────────
    if (p.rhs != 0) {
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Subtract $rhsFmt',
        explanation: '',
        latex: '($numStr) / ($denStr) - $rhsFmt ${p.op} 0',
      ));

      // ── Step 3: Write RHS over common denominator ───────────────────────────
      final rhsExpanded = _ll(p.rhs * p.denA, p.rhs * p.denC);
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Common denominator',
        explanation: '',
        latex: '($numStr) / ($denStr) - ($rhsExpanded) / ($denStr) ${p.op} 0',
      ));

      // ── Step 4: Combine into one fraction ───────────────────────────────────
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Combine',
        explanation: '',
        latex: '($numStr - ($rhsExpanded)) / ($denStr) ${p.op} 0',
      ));
    }

    // ── Step 5: Simplified fraction ───────────────────────────────────────────
    steps.add(StepModel(
      stepNumber: n++,
      title: 'Simplify',
      explanation: '',
      latex: '($combStr) / ($denStr) ${p.op} 0',
    ));

    // ── Step 6: Numerator = 0 ─────────────────────────────────────────────────
    final numZero = p.combA != 0 ? -p.combC / p.combA : double.nan;
    if (!numZero.isNaN) {
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Numerator = 0',
        explanation: '',
        latex: '$combStr = 0  →  x = ${InequalityCoreSolver.fmt(numZero)}',
      ));
    }

    // ── Step 7: Denominator = 0 (always excluded) ─────────────────────────────
    final denZero = p.denA != 0 ? -p.denC / p.denA : double.nan;
    if (!denZero.isNaN) {
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Denominator = 0  (excluded)',
        explanation: '',
        latex: '$denStr = 0  →  x = ${InequalityCoreSolver.fmt(denZero)}',
      ));
    }

    // ── Step 8: Number line ───────────────────────────────────────────────────
    final pts = _criticalPoints(p)..sort();
    steps.add(StepModel(
      stepNumber: n++,
      title: 'Number line',
      explanation: '',
      latex: pts.map(InequalityCoreSolver.fmt).join('  <  '),
    ));

    // ── Step 9: Test each region ──────────────────────────────────────────────
    final testPts = <double>[
      pts.first - 1,
      for (int i = 0; i < pts.length - 1; i++) (pts[i] + pts[i + 1]) / 2,
      pts.last + 1,
    ];

    for (final tx in testPts) {
      final denVal = p.denA * tx + p.denC;
      if (denVal == 0) continue;
      final numVal = p.combA * tx + p.combC;
      final result = numVal / denVal;
      final satisfies = InequalityCoreSolver.evalOp(result, p.op, 0);
      final txFmt = InequalityCoreSolver.fmt(tx);
      final numValFmt = InequalityCoreSolver.fmt(numVal);
      final denValFmt = InequalityCoreSolver.fmt(denVal);
      final resFmt = InequalityCoreSolver.fmt(result);
      final mark = satisfies ? '✓' : '✗';

      steps.add(StepModel(
        stepNumber: n++,
        title: 'x = $txFmt',
        explanation: '',
        latex: '$numValFmt / $denValFmt = $resFmt ${p.op} 0  $mark',
      ));
    }

    // ── Step 10: Solution set ─────────────────────────────────────────────────
    final intervals = _buildIntervals(p);
    steps.add(StepModel(
      stepNumber: n++,
      title: 'Solution',
      explanation: '',
      latex: intervals.isEmpty ? '∅' : intervals.join(' ∪ '),
    ));

    return steps;
  }

  // ─── Internal helpers ─────────────────────────────────────────────────────

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
    return pts;
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
