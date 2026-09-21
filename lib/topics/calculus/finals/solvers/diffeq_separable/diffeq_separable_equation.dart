// ─────────────────────────────────────────────────────────────
// DIFFEQ SEPARABLE — finals period.
//
// Guided, separable-only ODE solver:
//   dy/dx = f(x) * g(y)  →  dy/g(y) = f(x) dx
//   →  integrate both sides  →  G(y) = F(x) + C
//
// Parser is intentionally minimal (novel parsers are a known
// design risk): the input must match the guided format with the
// RHS split at '*' into exactly two elementary monomial factors.
// Only elementary g(y) is handled — y^n or 1/y (linear y).
// Anything else returns an explicit unsupported error. The
// antiderivatives reuse the proven SHS integral-engine power
// rules (power rule, 1/x → ln|x|) inline — no novel math beyond
// elementary cases. Never throws.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/topics/grade6/solvers/g6_support.dart';

/// One elementary monomial factor: coefficient k times var^n
/// (e.g. 'x^2' → (1, 2), '2y' → (2, 1), constant → n = 0).
class _Mono {
  final double k;
  final double n;
  const _Mono(this.k, this.n);
}

/// Parsed separable ODE (private to this module): f(x) = k·x^n
/// and g(y) = k·y^m, with the raw factor strings for the steps.
class _Separable {
  final _Mono f;
  final _Mono g;
  final String fRaw;
  final String gRaw;
  const _Separable(this.f, this.g, this.fRaw, this.gRaw);
}

/// Finals-period separable differential equation solver.
class DiffeqSeparableEquation extends BaseEquation {
  /// Elementary monomial: optional coefficient, one variable
  /// letter, optional integer exponent.
  static final RegExp _monoRe =
      RegExp(r'^([+-]?\d+(?:\.\d+)?)?\*?([xy])(?:\^([+-]?\d+))?$');

  DiffeqSeparableEquation(this.rawInput);

  /// The raw string the user typed.
  @override
  final String rawInput;

  String? _error;
  _Separable? _parsed;

  /// Normalized input: trimmed, minus folded, spaces removed.
  String _norm() => rawInput.trim().replaceAll('−', '-').replaceAll(' ', '');

  /// Parses one monomial factor for the expected variable.
  /// Returns null when the factor is not an elementary monomial.
  _Mono? _parseMono(String s, String expectedVar) {
    final m = _monoRe.firstMatch(s);
    if (m == null || m.group(2) != expectedVar) return null;
    final k = (m.group(1) == null || m.group(1)!.isEmpty)
        ? 1.0
        : double.parse(m.group(1)!);
    final n = m.group(3) == null ? 1.0 : double.parse(m.group(3)!);
    return _Mono(k, n);
  }

  /// Parses a bare constant as an f(x) monomial (n = 0).
  _Mono? _parseConstant(String s) {
    final v = double.tryParse(s);
    return v == null ? null : _Mono(v, 0);
  }

  @override
  bool validate() {
    _error = null;
    _parsed = null;
    final t = _norm();
    if (t.isEmpty) {
      _error = 'Enter a separable equation — e.g. dy/dx = x * y.';
      return false;
    }
    final parts = t.split('=');
    if (parts.length != 2) {
      _error = 'Guided format: dy/dx = f(x) * g(y) — e.g. dy/dx = x * y.';
      return false;
    }
    final lhs = parts[0].toLowerCase();
    if (lhs != 'dy/dx') {
      _error = 'Left side must be dy/dx — e.g. dy/dx = x * y.';
      return false;
    }
    final rhs = parts[1];
    final factors = rhs.split('*');
    if (factors.length != 2) {
      _error = 'Split the right side as f(x) * g(y) — e.g. x * y.';
      return false;
    }
    // 1/x and 1/y shorthand: fold into the negative-exponent form.
    final fStr = factors[0] == '1/x' ? 'x^-1' : factors[0];
    final gStr = factors[1] == '1/y' ? 'y^-1' : factors[1];
    final f = _parseMono(fStr, 'x') ?? _parseConstant(fStr);
    final g = _parseMono(gStr, 'y');
    if (f == null) {
      _error =
          'f(x) must be elementary: k·x^n or a constant — e.g. x, 2x, x^2.';
      return false;
    }
    if (g == null) {
      _error =
          'Only elementary g(y) supported: y^n or 1/y — e.g. dy/dx = x * y.';
      return false;
    }
    _parsed = _Separable(f, g, fStr, gStr);
    return true;
  }

  @override
  SolveResult solve() {
    if (!validate()) {
      return SolveResult.error(_error ?? 'Could not parse input.');
    }
    try {
      final s = _parsed!;
      final fx = _fxAntiderivative(s.f.k, s.f.n);
      final gy = _gyAntiderivative(s.g.k, s.g.n);
      return SolveResult(
        answer: '$gy = $fx + C',
        points: const [],
        customData: [
          {
            'kind': 'separable',
            'f': s.fRaw,
            'g': s.gRaw,
            'F': fx,
            'G': gy,
            'form': 'dy/dx = f(x) · g(y)',
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
    final s = _parsed!;
    final fx = _fxAntiderivative(s.f.k, s.f.n);
    final gy = _gyAntiderivative(s.g.k, s.g.n);
    return [
      StepModel(
        stepNumber: 1,
        title: 'Separate variables',
        explanation: 'dy/dx = f(x)·g(y) → divide both sides by g(y) so every '
            'y sits with dy and every x with dx.',
        hint: 'dy/${s.gRaw} = ${s.fRaw} dx',
      ),
      StepModel(
        stepNumber: 2,
        title: 'Integrate both sides',
        explanation: 'Left: ∫ dy/g(y) = $gy. Right: ∫ f(x) dx = $fx. '
            'Power rule: ∫ y^n dy = y^(n+1)/(n+1); ∫ dy/y = ln|y|.',
        hint: '$gy and $fx',
      ),
      StepModel(
        stepNumber: 3,
        title: 'General solution',
        explanation: '$gy = $fx + C — one constant C covers both '
            'antiderivatives.',
      ),
    ];
  }

  // ── internals ──────────────────────────────────────────────

  /// Antiderivative of f(x) = k·x^n (power rule; n = -1 → k·ln|x|).
  String _fxAntiderivative(double k, double n) {
    if (n == -1) {
      if (k == 1) return 'ln|x|';
      if (k == -1) return '-ln|x|';
      return '${G6Format.num(k)}ln|x|';
    }
    final e = n + 1;
    if (k == 1) return e == 1 ? 'x' : 'x^${G6Format.num(e)}/${G6Format.num(e)}';
    final c = k / e;
    if (c == c.roundToDouble()) {
      final ci = c.round();
      final coef = ci == 1
          ? ''
          : ci == -1
              ? '-'
              : '$ci';
      return e == 1 ? '${coef}x' : '${coef}x^${G6Format.num(e)}';
    }
    final kf = G6Format.num(k);
    return e == 1 ? '${kf}x' : '${kf}x^${G6Format.num(e)}/${G6Format.num(e)}';
  }

  /// Antiderivative of 1/g(y) dy for g(y) = k·y^m:
  /// m = 1 → ln|y|; otherwise (1/k)·y^(1-m)/(1-m).
  String _gyAntiderivative(double k, double m) {
    if (m == 1) {
      return k == 1 ? 'ln|y|' : 'ln|y|/${G6Format.num(k)}';
    }
    final p = 1 - m; // new exponent on y
    if (p < 0) {
      // y^p/(k·p) with both negative → -1/(|k·p|·y^|p|)
      final d = (k * p).abs();
      final pw = p.abs() == 1 ? 'y' : 'y^${G6Format.num(p.abs())}';
      final coef = d == 1 ? '' : G6Format.num(d);
      return coef.isEmpty ? '-1/$pw' : '-1/($coef$pw)';
    }
    // y^p/(k·p), positive exponent.
    final d = k * p;
    if (p == 1) return d == 1 ? 'y' : 'y/${G6Format.num(d)}';
    if (d < 0) return '-y^${G6Format.num(p)}/${G6Format.num(-d)}';
    return 'y^${G6Format.num(p)}/${G6Format.num(d)}';
  }
}
