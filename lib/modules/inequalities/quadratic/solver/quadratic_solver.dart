import 'dart:math' as math;
import '../../../../core/solve_result.dart';
import '../../../../core/step_model.dart';
import '../../core/inequality_core_solver.dart';

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
      title: 'Write the original inequality',
      explanation: 'Identify the square root on both sides.',
      latex: p.original,
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Simplify √(x²) = |x|',
      explanation:
          'Since √(x²) = |x| for all real x, the inequality becomes an absolute value inequality.',
      latex: '|x| $op √(${p.sqrtRhs}) = $bStr',
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Set up the absolute value inequality',
      explanation: op == '≤' || op == '<'
          ? '|x| $op k  ⟹  −k $op x $op k'
          : '|x| $op k  ⟹  x ${InequalityCoreSolver.flipOp(op)} −k  or  x $op k',
      latex: '|x| $op $bStr',
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Test boundary values on the number line',
      explanation:
          'Check a value outside and inside the proposed solution set.',
      latex: _buildSqrtTestLatex(op, bound),
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Write the solution set',
      explanation: 'S.S.',
      latex: _solveSqrt(p).intervalNotation,
    ));

    return steps;
  }

  static String _buildSqrtTestLatex(String op, double b) {
    final t1 = -(b + 1);
    const t2 = 0.0;
    final t3 = b + 1;
    String check(double t) {
      final absT = t.abs();
      final pass = InequalityCoreSolver.evalOp(absT, op, b);
      return '|${InequalityCoreSolver.fmt(t)}| = ${InequalityCoreSolver.fmt(absT)} ${pass ? "✓" : "✗"}';
    }

    return '${check(t1)}\n${check(t2)}\n${check(t3)}';
  }

  // ── standard quadratic solution ────────────────────────────────────────────

  static SolveResult _solveStandard(_Prep p) {
    final a = p.a!, b = p.b!, c = p.c!;
    final op = p.op;

    // FIX 3: Guard against unparseable input (all zeros likely means parse failed)
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

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Write the original inequality',
      explanation: 'Start with the given quadratic inequality.',
      latex: p.original,
    ));

    final needsMove =
        (p.rhsRaw != null && p.rhsRaw!.isNotEmpty && p.rhsRaw != '0');
    if (needsMove) {
      final bStr = b >= 0
          ? '+ ${InequalityCoreSolver.fmt(b)}'
          : InequalityCoreSolver.fmt(b);
      final cStr = c >= 0
          ? '+ ${InequalityCoreSolver.fmt(c)}'
          : InequalityCoreSolver.fmt(c);
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Move all terms to the left side',
        explanation: 'Make the right-hand side zero.',
        latex: '${_coefStr(a)}x² $bStr x $cStr $op 0',
      ));
    }

    final disc = b * b - 4 * a * c;

    if (disc < 0) {
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Compute the discriminant',
        explanation:
            'Δ = b² − 4ac = (${InequalityCoreSolver.fmt(b)})² − 4(${InequalityCoreSolver.fmt(a)})(${InequalityCoreSolver.fmt(c)})',
        latex: 'Δ = ${InequalityCoreSolver.fmt(disc)} < 0  →  no real roots',
      ));
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Write the solution set',
        explanation: 'Since Δ < 0 the parabola does not cross the x-axis.',
        latex: _solveStandard(p).intervalNotation,
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
        title: 'Factor the quadratic',
        explanation: 'Express the left side as a product of two binomials.',
        latex: '($factored) $op 0',
      ));
    } else {
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Compute the discriminant',
        explanation:
            'Δ = b² − 4ac = (${InequalityCoreSolver.fmt(b)})² − 4(${InequalityCoreSolver.fmt(a)})(${InequalityCoreSolver.fmt(c)})',
        latex: 'Δ = ${InequalityCoreSolver.fmt(disc)}',
      ));
    }

    if (disc == 0) {
      final root = -b / (2 * a);
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Find the root (double root)',
        explanation: 'Δ = 0 → one repeated root.',
        latex: 'x = ${InequalityCoreSolver.fmt(root)}',
      ));
    } else {
      steps.add(StepModel(
        stepNumber: n++,
        title: 'Find the roots',
        explanation: 'Set each factor equal to zero.',
        latex:
            'x − ${InequalityCoreSolver.fmt(lo)} = 0    |    x − ${InequalityCoreSolver.fmt(hi)} = 0\n'
            'x = ${InequalityCoreSolver.fmt(lo)}          x = ${InequalityCoreSolver.fmt(hi)}',
      ));
    }

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Build a sign chart (test values)',
      explanation:
          'Pick a test point in each interval and check if it satisfies the inequality.',
      latex: _buildSignChart(a, lo, hi, op),
    ));

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Write the solution set',
      explanation: 'S.S.',
      latex: _solveStandard(p).intervalNotation,
    ));

    return steps;
  }

  // ── sign chart builder ─────────────────────────────────────────────────────

  static String _buildSignChart(double a, double lo, double hi, String op) {
    final t1 = lo - 1;
    final t2 = (lo + hi) / 2;
    final t3 = hi + 1;

    String testLine(double t) {
      final expr = a * (t - lo) * (t - hi);
      final passes = InequalityCoreSolver.evalOp(expr, op, 0);
      final loStr = InequalityCoreSolver.fmt(lo);
      final hiStr = InequalityCoreSolver.fmt(hi);
      final tStr = InequalityCoreSolver.fmt(t);
      final f1 = t - lo;
      final f2 = t - hi;
      final s1 = f1 > 0 ? '+' : '−';
      final s2 = f2 > 0 ? '+' : '−';
      return '($tStr−$loStr)($tStr−$hiStr) = ($s1)($s2) = ${passes ? "✓" : "✗"}';
    }

    return '${testLine(t1)}\n${testLine(t2)}\n${testLine(t3)}';
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  static String? _tryFactor(double a, double b, double c) {
    final disc = b * b - 4 * a * c;
    if (disc < 0) return null;
    final sqrtD = math.sqrt(disc);
    // FIX 4: Check disc is a perfect square (integer), not sqrtD against its round
    final discRounded = disc.roundToDouble();
    if ((disc - discRounded).abs() > 1e-6) return null; // non-integer disc
    final sqrtDRounded = sqrtD.roundToDouble();
    if ((sqrtD - sqrtDRounded).abs() > 1e-6) return null; // irrational sqrt

    final r1 = (-b - sqrtD) / (2 * a);
    final r2 = (-b + sqrtD) / (2 * a);

    String binomial(double r) {
      if (r == 0) return 'x';
      final rStr = InequalityCoreSolver.fmt(r.abs());
      return r < 0 ? 'x + $rStr' : 'x − $rStr';
    }

    final aStr = a == 1 ? '' : (a == -1 ? '−' : InequalityCoreSolver.fmt(a));
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

    // FIX 5: Robust tokeniser — collect sign + term together by scanning
    // forward and splitting only when we hit a +/- that is NOT at position 0
    // and NOT inside parentheses (for fraction coefficients like (1/2)).
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
      // Remove explicit multiplication sign
      final t = tok.replaceAll('*', '');

      if (t.contains('x^2') || t.contains('x²')) {
        // Quadratic term — coefficient is everything before 'x'
        a += _extractCoef(t.substring(0, t.indexOf('x')));
      } else if (t.contains('x')) {
        // Linear term
        final xIdx = t.indexOf('x');
        b += _extractCoef(t.substring(0, xIdx));
      } else {
        // Constant term
        // FIX 6: Strip leading '+' before parsing since double.tryParse
        // handles '-' but is inconsistent with leading '+' on some platforms
        final clean = t.startsWith('+') ? t.substring(1) : t;
        c += _parseFrac(clean);
      }
    }
    return {'a': a, 'b': b, 'c': c};
  }

  static double _extractCoef(String s) {
    s = s.trim();
    // FIX 7: Strip outer parentheses that wrap fraction coefficients e.g. (1/2)
    if (s.startsWith('(') && s.endsWith(')')) {
      s = s.substring(1, s.length - 1);
    }
    if (s.isEmpty || s == '+') return 1;
    if (s == '-') return -1;
    return _parseFrac(s);
  }

  static double _parseFrac(String s) {
    s = s.trim();
    // FIX 8: Strip outer parens here too for safety
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

  // FIX 9: Separate op extraction from op index finding.
  // Check longest ops first so '>=' isn't consumed as '>'.
  // After _preprocess normalises '>=' → '≥', we only ever see the unicode chars,
  // but we keep the priority order for safety.
  static String? _extractOp(String s) {
    if (s.contains('≥')) return '≥';
    if (s.contains('≤')) return '≤';
    if (s.contains('>')) return '>';
    if (s.contains('<')) return '<';
    return null;
  }

  // FIX 10: Find the operator index properly.
  // For '>' and '<' we want the last occurrence to avoid matching a negative
  // exponent or unary minus that could appear on the left side.
  // For '≥' and '≤' (single unicode code units) indexOf is reliable.
  static int _findOpIndex(String s, String op) {
    if (op == '>' || op == '<') {
      // Walk right-to-left and return the first standalone operator
      // (not preceded by another operator char like '!' or '=')
      for (int i = s.length - 1; i >= 0; i--) {
        if (s[i] == op) {
          // Make sure it's not part of '>=' or '<=' that wasn't normalised
          if (i + 1 < s.length && s[i + 1] == '=') continue;
          return i;
        }
      }
      return -1;
    }
    return s.indexOf(op);
  }
}

// ── Internal prep container ───────────────────────────────────────────────────

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
