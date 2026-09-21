// ─────────────────────────────────────────────────────────────
// VOLUMES OF REVOLUTION — finals period.
//
// Guided solver for the three common curriculum forms:
//   disk:   volume f about x-axis from a to b → V = π∫[a,b] f(x)² dx
//   washer: volume washer f g about x-axis from a to b
//                                        → V = π∫[a,b] (f² − g²) dx
//   shell:  volume shell f about y-axis from a to b
//                                        → V = 2π∫[a,b] y·f(y) dy
//
// Definite integrals are computed numerically with Simpson's rule
// (n = 400, even), reusing the proven CalculatorEngine evaluator
// the SHS definite-integral engine uses — no novel math beyond
// numeric integration. Validation: a < b, f ≥ 0 on [a, b] for
// disk (the radius cannot be negative), outer radius > inner
// radius for washer, and a ≥ 0 for shell (the radius y cannot be
// negative). Clean error messages, never throws.
// ─────────────────────────────────────────────────────────────

import 'dart:math' as math;

import 'package:calculus_system/calculator/calculator_engine.dart';
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';

/// The supported method of revolution.
enum _Method { disk, washer, shell }

/// Parsed volume problem (private to this module).
class _Volume {
  final _Method method;
  final String f;
  final String? g;
  final double a;
  final double b;
  const _Volume(this.method, this.f, this.g, this.a, this.b);

  /// Setup formula shown in step 1, e.g. 'V = π ∫[a, b] f(x)² dx'.
  String get formula {
    switch (method) {
      case _Method.disk:
        return 'V = π ∫[a, b] f(x)² dx';
      case _Method.washer:
        return 'V = π ∫[a, b] (f(x)² − g(x)²) dx';
      case _Method.shell:
        return 'V = 2π ∫[a, b] y·f(y) dy';
    }
  }
}

/// Finals-period volumes-of-revolution solver.
class VolumesOfRevolutionEquation extends BaseEquation {
  /// 'volume shell f about y-axis from a to b' — shell method.
  static final RegExp _shellRe = RegExp(
    r'^volume\s+shell\s+(.+?)\s+about\s+(?:the\s+)?y\s?-?axis\s+from\s+'
    r'(-?\d+(?:\.\d+)?)\s+to\s+(-?\d+(?:\.\d+)?)$',
  );

  /// 'volume washer f g about x-axis from a to b' — washer method,
  /// f = outer radius and g = inner radius (single-token functions).
  static final RegExp _washerRe = RegExp(
    r'^volume\s+washer\s+(\S+)\s+(\S+)\s+about\s+(?:the\s+)?x\s?-?axis\s+'
    r'from\s+(-?\d+(?:\.\d+)?)\s+to\s+(-?\d+(?:\.\d+)?)$',
  );

  /// 'volume f about x-axis from a to b' — disk method. The
  /// lookaheads stop this from swallowing washer/shell inputs.
  static final RegExp _diskRe = RegExp(
    r'^volume\s+(?!washer\b)(?!shell\b)(.+?)\s+about\s+(?:the\s+)?x\s?-?axis\s+'
    r'from\s+(-?\d+(?:\.\d+)?)\s+to\s+(-?\d+(?:\.\d+)?)$',
  );

  /// Numeric-tolerance floor for the radius checks: tiny negative
  /// sample values from floating-point noise are not real violations.
  static const double _tol = 1e-9;

  /// Simpson subintervals (kept even for the weighted sum).
  static const int _n = 400;

  /// Sample points used by the radius/defined checks in validate().
  static const int _samples = 40;

  VolumesOfRevolutionEquation(this.rawInput);

  /// The raw string the user typed.
  @override
  final String rawInput;

  String? _error;
  _Volume? _parsed;

  /// Normalized input: trimmed, minus folded, lowercased, single-spaced.
  String _norm() => rawInput
      .trim()
      .replaceAll('−', '-')
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ');

  RegExpMatch? get _match =>
      _shellRe.firstMatch(_norm()) ??
      _washerRe.firstMatch(_norm()) ??
      _diskRe.firstMatch(_norm());

  @override
  bool validate() {
    _error = null;
    _parsed = null;
    final t = _norm();
    if (t.isEmpty) {
      _error = 'Enter a volume — e.g. volume x^2 about x-axis from 0 to 1.';
      return false;
    }
    final m = _match;
    if (m == null) {
      _error = 'Formats: volume f about x-axis from a to b, '
          'volume washer f g about x-axis from a to b, or '
          'volume shell f about y-axis from a to b.';
      return false;
    }
    final isShell = m.pattern.pattern == _shellRe.pattern;
    final isWasher = m.pattern.pattern == _washerRe.pattern;
    final f = m.group(1)!;
    final g = isWasher ? m.group(2)! : null;
    final a = double.parse(m.group(isWasher ? 3 : 2)!);
    final b = double.parse(m.group(isWasher ? 4 : 3)!);

    if (a >= b) {
      _error = 'Lower limit a must be less than b — e.g. from 0 to 1.';
      return false;
    }

    // Shell: the radius is y itself, so y = f's variable must be ≥ 0.
    if (isShell && a < 0) {
      _error = 'Shell method integrates y·f(y) — the radius y must be '
          'non-negative, so the lower limit a must be ≥ 0.';
      return false;
    }

    // Radius checks over [a, b] (sampled; null = undefined sample).
    final method = isShell
        ? _Method.shell
        : isWasher
            ? _Method.washer
            : _Method.disk;
    switch (method) {
      case _Method.disk:
        final fMin = _sampledMin(f, 'x', a, b);
        if (fMin == null) {
          _error = 'Could not evaluate f(x) on [a, b].';
          return false;
        }
        if (fMin < -_tol) {
          _error = 'Disk method needs f(x) ≥ 0 on [a, b] — the disk '
              'radius cannot be negative.';
          return false;
        }
      case _Method.washer:
        if (!_outerAboveInner(f, g!, a, b)) {
          _error = 'Could not evaluate f(x) or g(x) on [a, b], or the '
              'outer radius f(x) ≤ the inner radius g(x) somewhere on '
              '[a, b] — swap f and g or check the limits.';
          return false;
        }
      case _Method.shell:
        if (_sampledMin(f, 'y', a, b) == null) {
          _error = 'Could not evaluate f(y) on [a, b].';
          return false;
        }
    }

    _parsed = _Volume(method, f, g, a, b);
    return true;
  }

  @override
  SolveResult solve() {
    if (!validate()) {
      return SolveResult.error(_error ?? 'Could not parse input.');
    }
    try {
      final v = _parsed!;
      final volume = _volume(v);
      if (volume == null || volume.isNaN || volume.isInfinite) {
        return SolveResult.error(
            'Could not evaluate the solid of revolution on [a, b].');
      }
      return SolveResult(
        answer: _answerText(volume),
        points: const [],
        customData: [
          {
            'kind': 'volumes-of-revolution',
            'method': v.method.name,
            'f': v.f,
            if (v.g != null) 'g': v.g!,
            'a': v.a,
            'b': v.b,
            'volume': volume,
            'formula': v.formula,
          }
        ],
      );
    } catch (e) {
      return SolveResult.error('Could not solve: $e');
    }
  }

  @override
  List<StepModel> getSteps() {
    if (!validate()) {
      return [
        StepModel(
            stepNumber: 1, title: 'Cannot solve', explanation: _error ?? '')
      ];
    }
    final v = _parsed!;
    final volume = _volume(v);
    final limits = '[${_fmt(v.a)}, ${_fmt(v.b)}]';
    final piFactor = v.method == _Method.shell ? '2π' : 'π';

    final steps = <StepModel>[
      StepModel(
        stepNumber: 1,
        title: 'Identify the method',
        explanation: v.method == _Method.disk
            ? 'Revolving f(x) = ${v.f} about the x-axis: each '
                'cross-section is a disk of radius f(x), so '
                '${v.formula}.'
            : v.method == _Method.washer
                ? 'Revolving the region between f(x) = ${v.f} (outer) '
                    'and g(x) = ${v.g} (inner) about the x-axis: each '
                    'cross-section is a washer, so ${v.formula}.'
                : 'Revolving f(y) = ${v.f} about the y-axis: shells of '
                    'radius y and height f(y), so ${v.formula}.',
        hint: v.method == _Method.washer
            ? 'Outer ${v.f} − inner ${v.g}'
            : 'Limits $limits',
      ),
      StepModel(
        stepNumber: 2,
        title: 'Substitute',
        explanation: v.method == _Method.washer
            ? 'With f(x) = ${v.f} and g(x) = ${v.g} over $limits: '
                'V = π ∫$limits ((${v.f})² − (${v.g})²) dx.'
            : v.method == _Method.shell
                ? 'With f(y) = ${v.f} over $limits: '
                    'V = 2π ∫$limits y·(${v.f}) dy.'
                : 'With f(x) = ${v.f} over $limits: '
                    'V = π ∫$limits (${v.f})² dx.',
        hint: 'Integrand over $limits',
      ),
    ];

    if (volume == null || volume.isNaN || volume.isInfinite) {
      steps.add(const StepModel(
        stepNumber: 3,
        title: 'Numerical evaluation failed',
        explanation: 'The solid could not be evaluated on [a, b] — check '
            'that the function is defined there.',
      ));
      return steps;
    }

    final integral = volume / (v.method == _Method.shell ? 2 : 1) / math.pi;
    steps.add(StepModel(
      stepNumber: 3,
      title: 'Evaluate numerically (Simpson)',
      explanation: "Simpson's rule over $limits gives the integral "
          '≈ ${_fmt(integral)}; multiplying by $piFactor gives the '
          'volume.',
      hint: '∫ ≈ ${_fmt(integral)}',
    ));
    steps.add(StepModel(
      stepNumber: 4,
      title: 'Final answer',
      explanation: 'V = ${_answerText(volume)}',
    ));
    return steps;
  }

  // ── internals ──────────────────────────────────────────────

  /// Evaluates [expr] at the point [at] for variable [varName],
  /// mirroring the SHS integral engine: implicit multiplication
  /// after a digit/closing paren, then the variable is substituted.
  /// Returns null when the expression is undefined there.
  static double? _ev(String expr, String varName, double at) {
    try {
      var s = expr.replaceAllMapped(
          RegExp('([0-9\\)])$varName'), (m) => '${m.group(1)}*$varName');
      s = s.replaceAll(varName, '($at)');
      final v = CalculatorEngine.evaluate(s);
      return v.isFinite ? v : null;
    } catch (_) {
      return null;
    }
  }

  /// Definite integral of [integrand] over [a, b] via Simpson's rule
  /// with [_n] subintervals. Returns null when any sample is
  /// undefined — the caller decides how to surface that.
  static double? _simpson(
      double? Function(double) integrand, double a, double b) {
    final h = (b - a) / _n;
    final f0 = integrand(a);
    final f1 = integrand(b);
    if (f0 == null || f1 == null) return null;
    var sum = f0 + f1;
    for (var i = 1; i < _n; i++) {
      final v = integrand(a + i * h);
      if (v == null) return null;
      sum += i.isOdd ? 4 * v : 2 * v;
    }
    return sum * h / 3;
  }

  /// Minimum of [expr] over [_samples + 1] points on [a, b]; null
  /// when any sample is undefined.
  static double? _sampledMin(String expr, String varName, double a, double b) {
    double? min;
    for (var i = 0; i <= _samples; i++) {
      final v = _ev(expr, varName, a + (b - a) * i / _samples);
      if (v == null) return null;
      if (min == null || v < min) min = v;
    }
    return min;
  }

  /// True when both radii are defined on [a, b] and the outer
  /// radius f(x) > the inner radius g(x) at every sampled point
  /// (touching endpoints — g(x) == f(x) within [_tol] — are fine:
  /// they just give a zero-width washer there).
  static bool _outerAboveInner(String f, String g, double a, double b) {
    for (var i = 0; i <= _samples; i++) {
      final x = a + (b - a) * i / _samples;
      final outer = _ev(f, 'x', x);
      final inner = _ev(g, 'x', x);
      if (outer == null || inner == null) return false;
      if (inner > outer + _tol) return false;
    }
    return true;
  }

  /// The volume for a validated problem; null when the numeric
  /// integration cannot be completed. Disk/washer multiply the
  /// integral by π; shell multiplies by 2π.
  double? _volume(_Volume v) {
    final integral = switch (v.method) {
      _Method.disk => _simpson(
          (x) {
            final f = _ev(v.f, 'x', x);
            return f == null ? null : f * f;
          },
          v.a,
          v.b,
        ),
      _Method.washer => _simpson(
          (x) {
            final outer = _ev(v.f, 'x', x);
            final inner = _ev(v.g!, 'x', x);
            if (outer == null || inner == null) return null;
            return outer * outer - inner * inner;
          },
          v.a,
          v.b,
        ),
      _Method.shell => _simpson(
          (y) {
            final f = _ev(v.f, 'y', y);
            return f == null ? null : y * f;
          },
          v.a,
          v.b,
        ),
    };
    if (integral == null || integral.isNaN || integral.isInfinite) return null;
    return v.method == _Method.shell
        ? 2 * math.pi * integral
        : math.pi * integral;
  }

  /// Answer with π in it, e.g. 'V = π/3  (≈ 1.0472)'. Exact
  /// π-multiples are detected by rational approximation of V/π;
  /// otherwise a decimal π-multiple is shown.
  String _answerText(double volume) {
    final q = volume / math.pi;
    final r = _rational(q);
    final approx = '≈ ${_fmt(volume)}';
    if (r == null) return 'V ≈ ${_fmt(q)}π  ($approx)';
    final (p, den) = r;
    if (den == 1) {
      return p == 1 ? 'V = π  ($approx)' : 'V = $pπ  ($approx)';
    }
    return p == 1 ? 'V = π/$den  ($approx)' : 'V = $pπ/$den  ($approx)';
  }

  /// Exact rational p/q for v (denominator ≤ 200), else null —
  /// used to render π-multiples like π/3 in the answer.
  static (int, int)? _rational(double v) {
    for (int q = 1; q <= 200; q++) {
      final p = v * q;
      if ((p - p.round()).abs() < 1e-9) {
        final pi = p.round();
        final g = _gcd(pi.abs(), q);
        return (pi ~/ g, q ~/ g);
      }
    }
    return null;
  }

  static int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  /// Formats a number to 4 decimals, trimming trailing zeros.
  static String _fmt(double v) {
    var s = v.toStringAsFixed(4);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }
}
