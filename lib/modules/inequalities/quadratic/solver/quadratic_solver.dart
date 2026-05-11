import 'dart:math' as math;
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/modules/inequalities/core/inequality_core_solver.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Quadratic Inequality Solver
// ─────────────────────────────────────────────────────────────────────────────

class QuadraticSolver {
  static SolveResult solve(String input) {
    try {
      final prep = _preprocess(input);
      if (prep.isSqrtForm) return _solveSqrt(prep);
      return _solveStandard(prep);
    } catch (e) {
      return SolveResult.error('Error: $e');
    }
  }

  static List<StepModel> getSteps(String input) {
    try {
      final prep = _preprocess(input);
      if (prep.isSqrtForm) return _stepsSqrt(prep);
      return _stepsStandard(prep);
    } catch (_) {
      return [];
    }
  }

  // ── preprocessing ──────────────────────────────────────────────────────────

  static _Prep _preprocess(String input) {
    String s = input
        .trim()
        .replaceAll('\u2212', '-')
        .replaceAll('\u2013', '-')
        .replaceAll(' ', '')
        .replaceAll('>=', '≥')
        .replaceAll('<=', '≤')
        .replaceAll('=>', '≥')
        .replaceAll('=<', '≤')
        .replaceAll('x²', 'x^2')
        .replaceAll('²', '^2');

    // Detect square-root form
    final sqrtPattern = RegExp(
        r'^(√|sqrt)\(?([^)]+)\)?\s*(<=|>=|≤|≥|<|>)\s*(√|sqrt)\(?([^)]+)\)?$',
        caseSensitive: false);
    final sqrtMatch = sqrtPattern.firstMatch(s);
    if (sqrtMatch != null) {
      final lhsInner = sqrtMatch.group(2)!;
      final op = _normaliseOp(sqrtMatch.group(3)!);
      final rhsInner = sqrtMatch.group(5)!;
      return _Prep(
        original: input.trim(),
        op: op,
        isSqrtForm: true,
        sqrtLhs: lhsInner,
        sqrtRhs: rhsInner,
      );
    }

    // FIX 1: Extract operator using longest-match first to avoid '>' matching '≥'
    final op = _extractOp(s);
    if (op == null) {
      return _Prep(original: input.trim(), op: '', isSqrtForm: false);
    }

    // FIX 2: Use lastIndexOf for '>' and '<' to avoid matching inside coefficients,
    // and handle multi-char ops correctly by finding them reliably.
    final idx = _findOpIndex(s, op);
    if (idx == -1) {
      return _Prep(original: input.trim(), op: '', isSqrtForm: false);
    }

    final lhs = s.substring(0, idx);
    final rhs = s.substring(idx + op.length);

    final lp = _parseQuadFrac(lhs);
    final rp = _parseQuadFrac(rhs);

    final a = (lp['a'] ?? 0) - (rp['a'] ?? 0);
    final b = (lp['b'] ?? 0) - (rp['b'] ?? 0);
    final c = (lp['c'] ?? 0) - (rp['c'] ?? 0);

    return _Prep(
      original: input.trim(),
      op: op,
      isSqrtForm: false,
      a: a,
      b: b,
      c: c,
      lhsRaw: lhs,
      rhsRaw: rhs,
    );
  }

  // ── √ form solution ────────────────────────────────────────────────────────

  static SolveResult _solveSqrt(_Prep p) {
    final rhsVal = _evalConstExpr(p.sqrtRhs!);
    if (rhsVal == null || rhsVal < 0) {
      return SolveResult.error('Right-hand side under √ must be non-negative.');
    }
    final bound = math.sqrt(rhsVal);

    final lhsIsAbsX =
        RegExp(r'^x\^?2$').hasMatch(p.sqrtLhs!.replaceAll(' ', ''));
    if (!lhsIsAbsX) {
      return SolveResult.error('Only √(x²) form supported on the left side.');
    }

    final op = p.op;
    final bStr = InequalityCoreSolver.fmt(bound);

    if (op == '≤' || op == '<') {
      final interval = op == '≤' ? '[-$bStr, $bStr]' : '(-$bStr, $bStr)';
      return SolveResult(
        answer: '-$bStr $op x $op $bStr',
        points: [-bound, bound],
        intervalNotation: interval,
      );
    } else {
      final lb = op == '≥' ? '[' : '(';
      final rb = op == '≥' ? ']' : ')';
      return SolveResult(
        answer: 'x ${InequalityCoreSolver.flipOp(op)} -$bStr or x $op $bStr',
        points: [-bound, bound],
        intervalNotation: '(-∞, -$bStr$rb ∪ $lb$bStr, ∞)',
      );
    }
  }

  static List<StepModel> _stepsSqrt(_Prep p) {
    final steps = <StepModel>[];
    int n = 1;
    final rhsVal = _evalConstExpr(p.sqrtRhs!)!;
    final bound = math.sqrt(rhsVal);
    final bStr = InequalityCoreSolver.fmt(bound);
    final op = p.op;
    final flipOp = InequalityCoreSolver.flipOp(op);

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Write the inequality',
      explanation: 'Start with the original inequality.',
      latex: p.original,
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Simplify both sides',
      explanation: 'Since √(x²) = |x| for all real x, the inequality becomes an absolute value inequality.',
      latex: '|x| ${_tex(op)} \\sqrt{${p.sqrtRhs}} = $bStr',
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Rewrite without absolute value',
      explanation: op == '≤' || op == '<'
          ? 'An absolute value less than or equal to k means x is between -k and k.'
          : 'An absolute value greater than or equal to k means x is outside -k and k.',
      latex: op == '≤' || op == '<'
          ? '-$bStr ${_tex(op)} x ${_tex(op)} $bStr'
          : 'x ${_tex(flipOp)} -$bStr \\text{ or } x ${_tex(op)} $bStr',
    ));

    steps.addAll(_buildSqrtTestSteps(bound, n));
    n += 3;

    final sqrtResult = _solveSqrt(p);
    final answer = sqrtResult.answer;
    final interval = (sqrtResult.intervalNotation ?? '')
        .replaceAll('∞', r'\infty')
        .replaceAll('∪', r'\cup');

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Final Answer',
      explanation: 'The solution set is: $answer',
      latex: '\\text{S.S} = $interval',
    ));

    return steps;
  }

  static List<StepModel> _buildSqrtTestSteps(double bound, int startN) {
    final rhsInner = (bound * bound).toInt();
    const insidePoint = 0.0;
    final outsideLeft = -bound - 1;
    final outsideRight = bound + 1;

    final testValues = [outsideLeft, insidePoint, outsideRight];
    final steps = <StepModel>[];

    for (int i = 0; i < testValues.length; i++) {
      final x = testValues[i];
      final xSquared = (x * x).toInt();
      final sqrtVal = math.sqrt(xSquared).toInt();
      final result = sqrtVal <= bound;
      final check = result ? '\\checkmark' : '\\times';
      final status = result ? 'passes' : 'fails';

      steps.add(StepModel(
        stepNumber: startN + i,
        title: 'Test x = ${_fmt(x)}',
        explanation: 'x = ${_fmt(x)} $status the inequality',
        latex: 'x = ${_fmt(x)}: \\sqrt{$xSquared} \\leq \\sqrt{$rhsInner} \\rightarrow $sqrtVal \\leq ${_fmt(bound)} $check',
      ));
    }

    return steps;
  }

  static String _fmt(double x) {
    if (x == x.roundToDouble()) {
      return x.toInt().toString();
    }
    return x.toStringAsFixed(2);
  }

  // ── standard quadratic solution ────────────────────────────────────────────

  static SolveResult _solveStandard(_Prep p) {
    final a = p.a!, b = p.b!, c = p.c!;
    final op = p.op;

    if (a == 0 && b == 0 && c == 0 && op.isEmpty) {
      return SolveResult.error('Could not parse inequality.');
    }

    if (a == 0) {
      return _solveLinearFallback(b, c, op);
    }
    final disc = b * b - 4 * a * c;

    if (disc < 0) {
      final allSatisfy = _noRealRootsAnswer(a, op);
      final ans = allSatisfy ? 'All real numbers' : 'No solution';
      return SolveResult(
          answer: ans,
          points: [],
          intervalNotation: allSatisfy ? '(-∞, ∞)' : '∅');
    }

    final sqrtD = math.sqrt(disc);
    final r1 = (-b - sqrtD) / (2 * a);
    final r2 = (-b + sqrtD) / (2 * a);
    final lo = r1 < r2 ? r1 : r2;
    final hi = r1 < r2 ? r2 : r1;

    if (disc == 0) {
      final root = -b / (2 * a);
      if (op == '≤' || op == '≥') {
        return SolveResult(
          answer: op == '≤'
              ? 'x = ${InequalityCoreSolver.fmt(root)}'
              : 'All real numbers',
          points: [root],
          intervalNotation:
              op == '≤' ? '{${InequalityCoreSolver.fmt(root)}}' : '(-∞, ∞)',
        );
      } else {
        return SolveResult(
          answer: op == '<'
              ? 'No solution'
              : 'x ≠ ${InequalityCoreSolver.fmt(root)}',
          points: [root],
          intervalNotation: op == '<'
              ? '∅'
              : '(-∞, ${InequalityCoreSolver.fmt(root)}) ∪ (${InequalityCoreSolver.fmt(root)}, ∞)',
        );
      }
    }

    final strict = op == '<' || op == '>';
    final lb = strict ? '(' : '[';
    final rb = strict ? ')' : ']';
    final between = (op == '<' || op == '≤') ? a > 0 : a < 0;

    if (between) {
      return SolveResult(
        answer:
            '${InequalityCoreSolver.fmt(lo)} $op x $op ${InequalityCoreSolver.fmt(hi)}',
        points: [lo, hi],
        intervalNotation:
            '$lb${InequalityCoreSolver.fmt(lo)}, ${InequalityCoreSolver.fmt(hi)}$rb',
      );
    } else {
      return SolveResult(
        answer:
            'x ${InequalityCoreSolver.flipOp(op)} ${InequalityCoreSolver.fmt(lo)} or x $op ${InequalityCoreSolver.fmt(hi)}',
        points: [lo, hi],
        intervalNotation:
            '(-∞, ${InequalityCoreSolver.fmt(lo)}$rb ∪ $lb${InequalityCoreSolver.fmt(hi)}, ∞)',
      );
    }
  }

static List<StepModel> _stepsStandard(_Prep p) {
    final steps = <StepModel>[];
    final a = p.a!, b = p.b!, c = p.c!;
    final op = p.op;
    int n = 1;
    const f = InequalityCoreSolver.fmt;

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Write the inequality',
      explanation: 'Start with the given quadratic inequality.',
      latex: p.original,
    ));

    final disc = b * b - 4 * a * c;

    if (disc < 0) {
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Analyze discriminant',
        explanation: 'Δ < 0 means no real roots exist.',
        latex: '\\Delta = ${f(disc)} < 0 \\implies \\text{No real roots}',
      ));
      final discResult = _solveStandard(p);
      final discInterval = discResult.intervalNotation ?? '';
      final discLatexInterval = discInterval
          .replaceAll('∞', r'\infty')
          .replaceAll('∪', r'\cup');
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Final Answer',
        explanation: 'Solution: ${discResult.answer}',
        latex: '\\text{S.S} = $discLatexInterval',
      ));
      return steps;
    }

    final sqrtD = math.sqrt(disc);
    final r1 = (-b - sqrtD) / (2 * a);
    final r2 = (-b + sqrtD) / (2 * a);
    final lo = r1 < r2 ? r1 : r2;
    final hi = r1 < r2 ? r2 : r1;

    final factored = _tryFactor(a, b, c);
    if (factored != null) {
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Factor',
        explanation: 'Write as a product of linear factors.',
        latex: '($factored) ${_tex(op)} 0',
      ));
    }

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Critical points',
      explanation: 'From factored form, critical points are where each factor equals zero.',
      latex: 'x_1 = ${f(lo)}, \\quad x_2 = ${f(hi)}',
    ));

    steps.addAll(_buildQuadraticTestSteps(a, lo, hi, op, n));
    n += 4;

    final solveResult = _solveStandard(p);
    final answer = solveResult.answer;
    final interval = (solveResult.intervalNotation ?? '')
        .replaceAll('∞', r'\infty')
        .replaceAll('∪', r'\cup');

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Final Answer',
      explanation: 'Solution: $answer',
      latex: '\\text{S.S} = $interval',
    ));

    return steps;
  }

  static List<StepModel> _buildQuadraticTestSteps(double a, double lo, double hi, String op, int startN) {
    final steps = <StepModel>[];
    final regionA = lo - 1;
    final regionB = (lo + hi) / 2;
    final regionC = hi + 1;

    final factorA1 = regionA - lo;
    final factorA2 = regionA - hi;
    final factorB1 = regionB - lo;
    final factorB2 = regionB - hi;
    final factorC1 = regionC - lo;
    final factorC2 = regionC - hi;

    String fmt(double x) => InequalityCoreSolver.fmt(x);
    String fmtSigned(double x) {
      if (x >= 0) return '+${x.toInt()}';
      return x.toInt().toString();
    }

    steps.add(StepModel(
      stepNumber: startN,
      title: 'Regions',
      explanation: 'Critical points divide the number line into three regions.',
      latex: '\\text{A: } x < ${fmt(lo)}, \\quad \\text{B: } ${fmt(lo)} < x < ${fmt(hi)}, \\quad \\text{C: } x > ${fmt(hi)}',
    ));

    final resA = factorA1 * factorA2;
    steps.add(StepModel(
      stepNumber: startN + 1,
      title: 'Test Region A',
      explanation: 'A: x < ${fmt(lo)} → (${fmtSigned(factorA1)})(${fmtSigned(factorA2)}) = ${resA.toInt()} ${resA > 0 ? "\\checkmark" : "\\times"}',
      latex: 'A: x < ${fmt(lo)} \\rightarrow (${fmtSigned(factorA1)})(${fmtSigned(factorA2)}) = ${resA.toInt()} ${resA > 0 ? "\\checkmark" : "\\times"}',
    ));

    final resB = factorB1 * factorB2;
    steps.add(StepModel(
      stepNumber: startN + 2,
      title: 'Test Region B',
      explanation: 'B: ${fmt(lo)} < x < ${fmt(hi)} → (${fmtSigned(factorB1)})(${fmtSigned(factorB2)}) = ${resB.toInt()} ${resB > 0 ? "\\checkmark" : "\\times"}',
      latex: 'B: ${fmt(lo)} < x < ${fmt(hi)} \\rightarrow (${fmtSigned(factorB1)})(${fmtSigned(factorB2)}) = ${resB.toInt()} ${resB > 0 ? "\\checkmark" : "\\times"}',
    ));

    final resC = factorC1 * factorC2;
    steps.add(StepModel(
      stepNumber: startN + 3,
      title: 'Test Region C',
      explanation: 'C: x > ${fmt(hi)} → (${fmtSigned(factorC1)})(${fmtSigned(factorC2)}) = ${resC.toInt()} ${resC > 0 ? "\\checkmark" : "\\times"}',
      latex: 'C: x > ${fmt(hi)} \\rightarrow (${fmtSigned(factorC1)})(${fmtSigned(factorC2)}) = ${resC.toInt()} ${resC > 0 ? "\\checkmark" : "\\times"}',
    ));

    return steps;
  }

  static String _tex(String op) => switch (op) {
        '≥' => '\\geq',
        '≤' => '\\leq',
        '>' => '>',
        '<' => '<',
        _ => op,
      };

  // ── helpers ────────────────────────────────────────────────────────────────

  static String? _tryFactor(double a, double b, double c) {
    final disc = b * b - 4 * a * c;
    if (disc < 0) return null;
    final sqrtD = math.sqrt(disc);
    final discRounded = disc.roundToDouble();
    if ((disc - discRounded).abs() > 1e-6) return null;
    final sqrtDRounded = sqrtD.roundToDouble();
    if ((sqrtD - sqrtDRounded).abs() > 1e-6) return null;

    final r1 = (-b - sqrtD) / (2 * a);
    final r2 = (-b + sqrtD) / (2 * a);

    String binomial(double r) {
      if (r == 0) return 'x';
      final rStr = InequalityCoreSolver.fmt(r.abs());
      return r < 0 ? 'x + $rStr' : 'x - $rStr';
    }

    final aStr = a == 1 ? '' : (a == -1 ? '-' : InequalityCoreSolver.fmt(a));
    return '$aStr(${binomial(r1)})(${binomial(r2)})';
  }

  static bool _noRealRootsAnswer(double a, String op) {
    if (a > 0) return op == '>' || op == '≥';
    return op == '<' || op == '≤';
  }

  static SolveResult _solveLinearFallback(double b, double c, String op) {
    if (b == 0) {
      final sat = InequalityCoreSolver.evalOp(c, op, 0);
      return SolveResult(
          answer: sat ? 'All real numbers' : 'No solution',
          points: [],
          intervalNotation: sat ? '(-∞, ∞)' : '∅');
    }
    final x = -c / b;
    final flip = b < 0;
    final effectiveOp = flip ? InequalityCoreSolver.flipOp(op) : op;
    return SolveResult(
      answer: 'x $effectiveOp ${InequalityCoreSolver.fmt(x)}',
      points: [x],
      intervalNotation: InequalityCoreSolver.interval(effectiveOp, x),
    );
  }

  // ── fraction-aware quadratic parser ───────────────────────────────────────

  static Map<String, double> _parseQuadFrac(String expr) {
    expr = expr.trim().replaceAll(' ', '');
    if (expr.isEmpty) return {'a': 0, 'b': 0, 'c': 0};

    double a = 0, b = 0, c = 0;
    final tokens = <String>[];
    int depth = 0;
    String cur = '';
    for (int i = 0; i < expr.length; i++) {
      final ch = expr[i];
      if (ch == '(') {
        depth++;
        cur += ch;
      } else if (ch == ')') {
        depth--;
        cur += ch;
      } else if ((ch == '+' || ch == '-') &&
          i > 0 &&
          depth == 0 &&
          cur.isNotEmpty) {
        tokens.add(cur);
        cur = ch;
      } else {
        cur += ch;
      }
    }
    if (cur.isNotEmpty) tokens.add(cur);

    for (final tok in tokens) {
      final t = tok.replaceAll('*', '');
      if (t.contains('x^2') || t.contains('x²')) {
        a += _extractCoef(t.substring(0, t.indexOf('x')));
      } else if (t.contains('x')) {
        final xIdx = t.indexOf('x');
        b += _extractCoef(t.substring(0, xIdx));
      } else {
        final clean = t.startsWith('+') ? t.substring(1) : t;
        c += _parseFrac(clean);
      }
    }
    return {'a': a, 'b': b, 'c': c};
  }

  static double _extractCoef(String s) {
    s = s.trim();
    if (s.startsWith('(') && s.endsWith(')')) {
      s = s.substring(1, s.length - 1);
    }
    if (s.isEmpty || s == '+') return 1;
    if (s == '-') return -1;
    return _parseFrac(s);
  }

  static double _parseFrac(String s) {
    s = s.trim();
    if (s.startsWith('(') && s.endsWith(')')) {
      s = s.substring(1, s.length - 1);
    }
    if (s.contains('/')) {
      final parts = s.split('/');
      if (parts.length != 2) return 0;
      final n = double.tryParse(parts[0].trim());
      final d = double.tryParse(parts[1].trim());
      if (n == null || d == null || d == 0) return 0;
      return n / d;
    }
    return double.tryParse(s) ?? 0;
  }

  static double? _evalConstExpr(String s) {
    s = s.trim().replaceAll(' ', '');
    if (s.startsWith('(') && s.endsWith(')')) {
      s = s.substring(1, s.length - 1);
    }
    if (s.contains('/')) {
      final parts = s.split('/');
      if (parts.length != 2) return null;
      final n = double.tryParse(parts[0].trim());
      final d = double.tryParse(parts[1].trim());
      if (n == null || d == null || d == 0) return null;
      return n / d;
    }
    return double.tryParse(s);
  }

  static String _normaliseOp(String op) {
    switch (op) {
      case '>=':
      case '=>':
        return '≥';
      case '<=':
      case '=<':
        return '≤';
      default:
        return op;
    }
  }

  static String? _extractOp(String s) {
    if (s.contains('≥')) return '≥';
    if (s.contains('≤')) return '≤';
    if (s.contains('>')) return '>';
    if (s.contains('<')) return '<';
    return null;
  }

  static int _findOpIndex(String s, String op) {
    if (op == '>' || op == '<') {
      for (int i = s.length - 1; i >= 0; i--) {
        if (s[i] == op) {
          if (i + 1 < s.length && s[i + 1] == '=') continue;
          return i;
        }
      }
      return -1;
    }
    return s.indexOf(op);
  }
}

class _Prep {
  final String original;
  final String op;
  final bool isSqrtForm;
  final double? a, b, c;
  final String? lhsRaw, rhsRaw;
  final String? sqrtLhs, sqrtRhs;

  const _Prep({
    required this.original,
    required this.op,
    required this.isSqrtForm,
    this.a,
    this.b,
    this.c,
    this.lhsRaw,
    this.rhsRaw,
    this.sqrtLhs,
    this.sqrtRhs,
  });
}
