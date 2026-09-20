import 'dart:math' as math;

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/derivatives_solver/derivatives_solver.dart';

// ─────────────────────────────────────────────────────────────
// TAYLOR / MACLAURIN SERIES EQUATION — finals period.
//
// Thin wrapper around the proven DerivativesSolver CAS engine
// (derivatives_solver.dart): Taylor coefficients are the
// successive derivatives of f evaluated at the center a, divided
// by k!. So the polynomial
//   f(a) + f'(a)(x-a) + f''(a)/2!(x-a)^2 + ...
// falls out for free from repeated differentiation + point
// evaluation. Maclaurin is simply the a = 0 case.
// ─────────────────────────────────────────────────────────────

/// One Taylor term: coefficient c_k = f^(k)(a)/k!.
class _Term {
  final int k;
  final Expr derivative;
  final double value;
  final double coefficient;
  const _Term(this.k, this.derivative, this.value, this.coefficient);
}

/// Built series data (private to this module).
class _Series {
  final String f;
  final String varName;
  final double a;
  final int n;
  final List<_Term> terms;
  const _Series(this.f, this.varName, this.a, this.n, this.terms);

  /// Display string of one term, e.g. '(1/2)x^2' or '-(x - 1)'.
  String termText(_Term t) {
    if (t.k == 0) return TaylorSeriesFormat.frac(t.coefficient);
    final base = a == 0 ? 'x' : '(x - ${TaylorSeriesFormat.frac(a)})';
    final power = t.k >= 2 ? '^${t.k}' : '';
    final rational = TaylorSeriesFormat.rational(t.coefficient);
    if (rational == null) {
      return '${t.coefficient.toStringAsFixed(4)}$base$power';
    }
    final (p, q) = rational;
    final sign = p < 0 ? '-' : '';
    final coef = (p.abs() == 1 && q == 1) ? '' : '${p.abs()}/$q';
    final body = q == 1 ? '$coef$base$power' : '($coef)$base$power';
    return '$sign$body';
  }

  /// Nonzero terms only — e.g. sin at 0 shows x - (1/6)x^3 + ...
  List<String> get termStrings =>
      terms.where((t) => t.coefficient != 0).map(termText).toList();

  /// The full polynomial joined with proper +/- handling.
  String get polynomial {
    final parts = termStrings;
    if (parts.isEmpty) return '0';
    final buf = StringBuffer(parts.first);
    for (final p in parts.skip(1)) {
      if (p.startsWith('-')) {
        buf.write(' - ${p.substring(1)}');
      } else {
        buf.write(' + $p');
      }
    }
    return buf.toString();
  }
}

/// Number formatting helpers for the Taylor module (fractions,
/// factorials, derivative ordinals). Private to the series solvers.
abstract class TaylorSeriesFormat {
  /// Exact rational p/q for v (denominator ≤ 120), else null.
  static (int, int)? rational(double v) {
    for (int q = 2; q <= 120; q++) {
      final p = v * q;
      if ((p - p.round()).abs() < 1e-9) {
        final pi = p.round();
        final g = _gcd(pi.abs(), q);
        return (pi ~/ g, q ~/ g);
      }
    }
    return null;
  }

  /// Human-readable number: integer, exact fraction, or decimal.
  static String frac(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    final r = rational(v);
    if (r != null) {
      final (p, q) = r;
      return q == 1 ? '$p' : '$p/$q';
    }
    var s = v.toStringAsFixed(6);
    s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  static int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  /// ASCII derivative ordinal, e.g. '^(2)' for f^(2)(x) labels.
  static String ordSup(int k) => '^($k)';
}

/// Finals-period Taylor / Maclaurin series solver.
class TaylorSeriesEquation extends BaseEquation {
  /// 'taylor <f> at <a> [n=<k>]' — the general form.
  static final RegExp _taylorRe = RegExp(
    r'^taylor\s+(.+?)\s+at\s+(-?\d+(?:\.\d+)?)\s*(?:n\s*=\s*(\d+))?$',
  );

  /// 'maclaurin <f> [n=<k>]' — shorthand for the a = 0 case.
  static final RegExp _maclaurinRe = RegExp(
    r'^maclaurin\s+(.+?)\s*(?:n\s*=\s*(\d+))?$',
  );

  /// Cap on requested terms so runaway derivatives cannot stall the UI.
  static const int _maxTerms = 12;

  TaylorSeriesEquation(this.rawInput);

  /// The raw string the user typed.
  @override
  final String rawInput;

  /// Normalized input: trimmed, minus folded, lowercased (the
  /// derivatives engine itself lowercases idents too).
  String _norm() => rawInput.trim().toLowerCase().replaceAll('−', '-');

  RegExpMatch? get _taylorMatch => _taylorRe.firstMatch(_norm());
  RegExpMatch? get _maclaurinMatch => _maclaurinRe.firstMatch(_norm());
  RegExpMatch? get _match => _taylorMatch ?? _maclaurinMatch;

  /// The function f, e.g. 'exp(x)'.
  String? get expression => _match?.group(1);

  /// The series center a (Maclaurin ⇒ 0).
  double? get center {
    final t = _taylorMatch;
    if (t == null) return _match == null ? null : 0.0;
    return double.parse(t.group(2)!);
  }

  /// Requested polynomial degree n (default 4) — P_n(x) uses the
  /// k = 0..n coefficients, i.e. n + 1 terms.
  int get degree {
    final m = _match;
    if (m == null) return 4;
    final isTaylor = m.pattern.pattern == _taylorRe.pattern;
    final g = isTaylor ? m.group(3) : m.group(2);
    final n = g == null ? 4 : int.parse(g);
    return n.clamp(1, _maxTerms);
  }

  /// The differentiation variable: first of x/y/z/t present in f.
  String get variable {
    final f = expression ?? '';
    for (final v in const ['x', 'y', 'z', 't']) {
      if (f.contains(v)) return v;
    }
    return 'x';
  }

  @override
  bool validate() {
    final expr = expression;
    return expr != null && expr.isNotEmpty;
  }

  @override
  SolveResult solve() {
    if (!validate()) {
      return SolveResult.error(
        'Enter a Taylor series — e.g. taylor exp(x) at 0, '
        'taylor sin(x) at 0 n=5 or maclaurin ln(x)',
      );
    }
    try {
      final series = _build();
      if (series == null) {
        return SolveResult.error(
          'f($expression) is not analytic at x = '
          '${TaylorSeriesFormat.frac(seriesCenter)} — a derivative is '
          'undefined there, so the series cannot be built.',
        );
      }
      return SolveResult(
        answer: 'P${series.n}(${series.varName}) = ${series.polynomial}',
        points: const [],
        customData: [
          {
            'kind': 'taylor',
            'f': series.f,
            'center': TaylorSeriesFormat.frac(series.a),
            'n': series.n,
            'polynomial': series.polynomial,
            'terms': series.termStrings,
          }
        ],
      );
    } on ParseException catch (e) {
      return SolveResult.error(
          e.toString().replaceFirst('ParseException: ', ''));
    } catch (e) {
      return SolveResult.error('Could not solve: $e');
    }
  }

  @override
  List<StepModel> getSteps() {
    if (!validate()) return const [];
    final series = _build();
    if (series == null) return const [];
    final v = series.varName;
    final a = TaylorSeriesFormat.frac(series.a);
    const sup = TaylorSeriesFormat.ordSup;

    final steps = <StepModel>[
      StepModel(
        stepNumber: 1,
        title: 'Identify the series',
        explanation: "Taylor series of f = ${series.f} about x = $a: "
            "f(a) + f'(a)(x-a) + f''(a)/2!(x-a)^2 + ... — each "
            'coefficient is the k-th derivative at a, divided by k!.'
            '${series.a == 0 ? ' Here a = 0, so this is a Maclaurin series.' : ''}',
      ),
    ];

    var n = 2;
    for (final t in series.terms) {
      steps.add(StepModel(
        stepNumber: n++,
        title: t.k == 0
            ? 'Term 1: constant term'
            : 'Term ${t.k + 1}: coefficient ${TaylorSeriesFormat.frac(t.coefficient)}',
        explanation: t.k == 0
            ? 'f($a) = ${TaylorSeriesFormat.frac(t.coefficient)} — the constant term.'
            : 'f${sup(t.k)}($v) = ${t.derivative} → '
                'f${sup(t.k)}($a) = ${TaylorSeriesFormat.frac(t.value)} → '
                'coefficient = ${TaylorSeriesFormat.frac(t.value)}/${t.k}! = '
                '${TaylorSeriesFormat.frac(t.coefficient)}',
        hint: 'Term: ${series.termText(t)}',
      ));
    }

    steps.add(StepModel(
      stepNumber: n++,
      title: 'Final answer',
      explanation: 'P${series.n}($v) = ${series.polynomial}',
    ));
    return steps;
  }

  // ── internals ──────────────────────────────────────────────

  double get seriesCenter => center ?? 0.0;

  _Series? _build() {
    final f = expression!;
    final v = variable;
    final a = seriesCenter;
    final n = degree;

    var d = DerivativeSolver.parse(f);
    final built = <_Term>[];

    // k = 0: the constant term f(a).
    final f0 = evaluateAt(d, v, a);
    if (f0 == null || f0.isNaN) return null;
    built.add(_Term(0, d, f0, f0));

    // k = 1..n: differentiate again, evaluate at a, divide by k!.
    for (int k = 1; k <= n; k++) {
      d = DerivativeSolver.differentiate(d, v);
      final simp = DerivativeSolver.simplify(d);
      final vk = evaluateAt(simp, v, a);
      if (vk == null || vk.isNaN) return null;
      built.add(_Term(k, simp, vk, vk / _factorial(k)));
    }
    return _Series(f, v, a, n, built);
  }

  /// Evaluates a derivatives-engine [Expr] at the point [x] for
  /// variable [v]. Returns null when undefined (e.g. ln of ≤ 0).
  /// Public so tests can numerically verify the built polynomial.
  static double? evaluateAt(Expr e, String v, double x) {
    if (e is Num) return e.value;
    if (e is Var) {
      if (e.name == v) return x;
      if (e.name == 'e') return math.e;
      return null;
    }
    if (e is Neg) {
      final inner = evaluateAt(e.expr, v, x);
      return inner == null ? null : -inner;
    }
    if (e is Sqrt) {
      final inner = evaluateAt(e.arg, v, x);
      return inner == null || inner < 0 ? null : math.sqrt(inner);
    }
    if (e is Abs) {
      final inner = evaluateAt(e.arg, v, x);
      return inner?.abs();
    }
    if (e is BinOp) {
      final l = evaluateAt(e.left, v, x), r = evaluateAt(e.right, v, x);
      if (l == null || r == null) return null;
      switch (e.op) {
        case '+':
          return l + r;
        case '-':
          return l - r;
        case '*':
          return l * r;
        case '/':
          return r == 0 ? null : l / r;
        case '^':
          return math.pow(l, r).toDouble();
        default:
          return null;
      }
    }
    if (e is Func) {
      final inner = evaluateAt(e.arg, v, x);
      if (inner == null) return null;
      switch (e.name) {
        case 'exp':
          return math.exp(inner);
        case 'ln':
          return inner > 0 ? math.log(inner) : null;
        case 'log':
          return inner > 0 ? math.log(inner) / math.ln10 : null;
        case 'sin':
          return math.sin(inner);
        case 'cos':
          return math.cos(inner);
        case 'tan':
          return math.tan(inner);
        case 'asin':
        case 'arcsin':
          return inner.abs() <= 1 ? math.asin(inner) : null;
        case 'acos':
        case 'arccos':
          return inner.abs() <= 1 ? math.acos(inner) : null;
        case 'atan':
        case 'arctan':
          return math.atan(inner);
        default:
          return null;
      }
    }
    return null;
  }

  static double _factorial(int k) {
    var f = 1.0;
    for (int i = 2; i <= k; i++) {
      f *= i;
    }
    return f;
  }
}
