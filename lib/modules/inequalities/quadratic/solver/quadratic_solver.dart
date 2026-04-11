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

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Original Inequality',
      explanation: 'Identify the square root on both sides.',
      latex: p.original,
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Simplify √(x²) = |x|',
      explanation:
          'Since √(x²) = |x| for all real x, the inequality becomes an absolute value inequality.',
      latex: '|x| ${_tex(op)} \\sqrt{${p.sqrtRhs}} = $bStr',
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Apply Absolute Property',
      explanation: op == '≤' || op == '<'
          ? 'An absolute value less than k means x is between -k and k.'
          : 'An absolute value greater than k means x is outside -k and k.',
      latex: op == '≤' || op == '<'
          ? '-$bStr ${_tex(op)} x ${_tex(op)} $bStr'
          : 'x ${_tex(InequalityCoreSolver.flipOp(op))} -$bStr \\text{ or } x ${_tex(op)} $bStr',
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Solution Set',
      explanation: 'Represent the valid input range in interval notation.',
      latex: _solveSqrt(p).intervalNotation,
    ));

    return steps;
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
      title: 'Original Inequality',
      explanation: 'Begin with the given quadratic inequality.',
      latex: p.original,
    ));

    final bStr = b >= 0 ? '+ ${f(b)}' : '- ${f(b.abs())}';
    final cStr = c >= 0 ? '+ ${f(c)}' : '- ${f(c.abs())}';
    steps.add(StepModel(
      stepNumber: n++,
      title: 'Standard Form',
      explanation: 'Rearrange into the form ax² + bx + c ${_tex(op)} 0.',
      latex:
          '\\begin{aligned} ${_coefStr(a)}x^2 ${b != 0 ? "$bStr x" : ""} ${c != 0 ? cStr : ""} &${_tex(op)} 0 \\end{aligned}',
    ));

    final disc = b * b - 4 * a * c;
    steps.add(StepModel(
      stepNumber: n++,
      title: 'Calculate Discriminant',
      explanation: 'Calculate Δ = b² - 4ac to determine the roots.',
      latex:
          '\\begin{aligned} \\Delta &= (${f(b)})^2 - 4(${f(a)})(${f(c)}) \\\\ &= ${f(disc)} \\end{aligned}',
    ));

    if (disc < 0) {
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Analyze Roots',
        explanation: 'The discriminant is negative, so there are no real roots.',
        latex: '\\Delta < 0 \\implies \\text{No real zeros}',
      ));
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Interval Notation',
        explanation: 'Represent the solution based on the parabola direction.',
        latex: _solveStandard(p).intervalNotation,
      ));
      return steps;
    }

    final sqrtD = math.sqrt(disc);
    final r1 = (-b - sqrtD) / (2 * a);
    final r2 = (-b + sqrtD) / (2 * a);
    final lo = r1 < r2 ? r1 : r2;
    final hi = r1 < r2 ? r2 : r1;

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Quadratic Formula',
      explanation: 'Apply the formula to find the critical values.',
      latex:
          'x = \\frac{-(${f(b)}) \\pm \\sqrt{${f(disc)}}}{2(${f(a)})} \\\\ \\implies x = \\frac{-${f(b)} \\pm ${f(sqrtD)}}{${f(2 * a)}}',
    ));

    if (disc == 0) {
      final root = -b / (2 * a);
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Find Root',
        explanation: 'One double root at the vertex.',
        latex: 'x = ${f(root)}',
      ));
    } else {
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Find Zeros',
        explanation: 'Critical points where the expression equals zero.',
        latex: 'x_1 = ${f(lo)}, \\quad x_2 = ${f(hi)}',
      ));

      final factored = _tryFactor(a, b, c);
      if (factored != null) {
        steps.add(StepModel(
          stepNumber: n++,
          title: 'Factored Form',
          explanation: 'Express as a product of linear factors.',
          latex: '($factored) ${_tex(op)} 0',
        ));
      }
    }

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Sign Chart Analysis',
      explanation: 'Test values in each interval to find solutions.',
      latex: _buildSignChart(a, lo, hi, op),
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Interval Notation',
      explanation: 'Identify the intervals that satisfy the condition.',
      latex: _solveStandard(p).intervalNotation,
    ));

    return steps;
  }

  static String _buildSignChart(double a, double lo, double hi, String op) {
    const f = InequalityCoreSolver.fmt;
    final t1 = lo - 1;
    final t2 = (lo + hi) / 2;
    final t3 = hi + 1;

    String testLine(double t) {
      final expr = a * (t - lo) * (t - hi);
      final passes = InequalityCoreSolver.evalOp(expr, op, 0);
      return 'x = ${f(t)}: \\quad (${a > 0 ? "+" : "-"})(${t - lo > 0 ? "+" : "-"})(${t - hi > 0 ? "+" : "-"}) = ${expr > 0 ? "+" : "-"} \\implies ${passes ? r"\text{\checkmark}" : r"\text{\times}"}';
    }

    return '\\begin{aligned} ${testLine(t1)} \\\\ ${testLine(t2)} \\\\ ${testLine(t3)} \\end{aligned}';
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

  static String _coefStr(double a) {
    if (a == 1) return '';
    if (a == -1) return '-';
    return InequalityCoreSolver.fmt(a);
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
