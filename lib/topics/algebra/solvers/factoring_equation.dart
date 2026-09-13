// ─────────────────────────────────────────────────────────────
// FACTORING — G8. GCF + difference-of-squares + monic trinomial.
// e.g. 'x^2+5x+6' -> (x+2)(x+3). Offline, pure Dart. Never throws.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';
import 'package:calculus_system/topics/grade6/solvers/g6_support.dart';

class FactoringEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  FactoringEquation(this.rawInput);

  String _norm() => rawInput
      .replaceAll('×', '*')
      .replaceAll('−', '-')
      .replaceAll(' ', '')
      .replaceAll('X', 'x');

  /// Parses ax^2+bx+c (a,b,c doubles, integers preferred). Null on failure.
  List<double>? _coeffs() {
    var e = _norm().replaceAll('*', '');
    if (e.contains('=')) e = e.split('=').first;
    if (!e.contains('x')) return null;
    // Reject higher powers.
    if (RegExp(r'x\^?[3-9]').hasMatch(e)) return null;
    double a = 0, b = 0, c = 0;
    // Tokenize signed terms.
    var s = e.startsWith('-') || e.startsWith('+') ? e : '+$e';
    final terms = RegExp(r'[+-][^+-]+').allMatches(s).map((m) => m.group(0)!);
    var sawX2 = false, sawX = false, sawC = false;
    for (final t in terms) {
      final sign = t.startsWith('-') ? -1.0 : 1.0;
      final body = t.substring(1);
      if (body.contains('x^2') || body.contains('x²')) {
        if (sawX2) return null;
        sawX2 = true;
        var coef = body.replaceAll('x^2', '').replaceAll('x²', '');
        a += sign * (coef.isEmpty ? 1 : double.tryParse(coef) ?? double.nan);
      } else if (body.contains('x')) {
        if (sawX) return null;
        sawX = true;
        var coef = body.replaceAll('x', '');
        b += sign * (coef.isEmpty ? 1 : double.tryParse(coef) ?? double.nan);
      } else {
        if (sawC) return null;
        sawC = true;
        final v = double.tryParse(body);
        if (v == null) return null;
        c += sign * v;
      }
    }
    if (a.isNaN || b.isNaN) return null;
    if (!sawX2) return null;
    return [a, b, c];
  }

  int? _asInt(double v) {
    if ((v - v.round()).abs() < 1e-9 && v.abs() < 1e9) return v.round();
    return null;
  }

  @override
  bool validate() {
    final empty = FieldValidators.notEmpty(rawInput, example: 'x^2 + 5x + 6');
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (_coeffs() == null) {
      _error = 'Quadratic in x only — e.g. x^2 + 5x + 6 or x^2 - 9.';
      return false;
    }
    _error = null;
    return true;
  }

  String _fmtFactor(int a, int r) {
    // a==1: (x+2)/(x-3); general: (2x+1).
    if (a == 1) {
      return r >= 0 ? '(x+${r.abs()})'.replaceAll('+-', '-') : '(x-${r.abs()})';
    }
    if (a == -1) {
      return r >= 0 ? '(-x+${r.abs()})' : '(-x-${r.abs()})';
    }
    return r >= 0 ? '(${a}x+$r)' : '(${a}x-${r.abs()})';
  }

  @override
  SolveResult solve() {
    final cf = _coeffs();
    if (cf == null) {
      return SolveResult.error(
          _error ?? 'Enter a quadratic — e.g. x^2 + 5x + 6.');
    }
    final ai = _asInt(cf[0]), bi = _asInt(cf[1]), ci = _asInt(cf[2]);
    if (ai == null || bi == null || ci == null || ai == 0) {
      return SolveResult.error(
          'Integer coefficients only — e.g. x^2 + 5x + 6.');
    }
    // GCF across non-zero terms.
    final nz = [ai, bi, ci].where((v) => v != 0).toList();
    final g = nz.map((v) => v.abs()).reduce((p, e) => G6Math.gcd(p, e));
    final a = ai ~/ (ai < 0 && g > 1 ? -g : g);
    final b = bi ~/ g;
    final c = ci ~/ g;

    String? factored;
    String kind = 'trinomial';
    if (b == 0 && c != 0) {
      // a x^2 + c: DOTS when signs differ.
      if (a * c < 0) {
        final p =
            _intSqrt((c ~/ -a * (a < 0 ? -1 : 1)).abs() == 0 ? 0 : (-c ~/ a));
        if (p != null) {
          factored = '(x+$p)(x-$p)';
          kind = 'dots';
        }
      } else if (a * c < 0) {
        kind = 'dots';
      }
    }
    factored ??= _trinomial(a, b, c);
    if (factored == null) {
      return SolveResult.error(
          'Not factorable over integers — try the quadratic formula.');
    }
    final disc = b * b - 4 * a * c;
    final answer = g > 1 ? '$g$factored' : factored;
    return SolveResult(
      answer: answer,
      points: _roots(a, b, c),
      customData: [
        {
          'kind': 'parabola',
          'a': a,
          'b': b,
          'c': c,
          'gcf': g,
          'factorKind': kind,
          'discriminant': disc,
          'factored': answer,
        }
      ],
    );
  }

  int? _intSqrt(int n) {
    if (n < 0) return null;
    final r = n == 0 ? 0 : _isqrt(n);
    return r * r == n ? r : null;
  }

  int _isqrt(int n) {
    var x = n;
    while ((x - n ~/ x).abs() > 0) {
      x = (x + n ~/ x) ~/ 2;
    }
    return x;
  }

  String? _trinomial(int a, int b, int c) {
    if (a == 1) {
      for (var m = -200; m <= 200; m++) {
        if (m == 0 || c % (m == 0 ? 1 : m) != 0) {
          if (m != 0 && c != 0) continue;
        }
        if (m == 0 && c != 0) continue;
        final n = b - m;
        if (m * n == c) return _fmtFactor(1, m) + _fmtFactor(1, n);
        if (m.abs() > 100 && c.abs() > 10000) break;
      }
      // Divisor-based search for big c.
      for (var m = 1; m * m <= c.abs() + 1; m++) {
        if (c != 0 && c % m != 0) continue;
        for (final s in [
          m,
          -m,
          c ~/ (m == 0 ? 1 : m),
          -(c ~/ (m == 0 ? 1 : m))
        ]) {
          final n = b - s;
          if (s * n == c) return _fmtFactor(1, s) + _fmtFactor(1, n);
        }
      }
      return null;
    }
    // Non-monic ac-method, small search.
    for (var p = -50; p <= 50; p++) {
      for (var q = -50; q <= 50; q++) {
        if (p == 0 || q == 0) continue;
        // (px+r)(qx+s): pq=a, rs=c, ps+qr=b.
        if (a % p != 0) continue;
        final qq = a ~/ p;
        if (qq != q) continue;
        for (var r = -50; r <= 50; r++) {
          if (c != 0 && r != 0 && c % r != 0) continue;
          if (r == 0 && c != 0) continue;
          final s = c == 0 ? 0 : (r == 0 ? 0 : c ~/ r);
          if (r * s != c) continue;
          if (p * s + q * r == b) {
            return _fmtFactor(p, r) + _fmtFactor(q, s);
          }
        }
      }
    }
    return null;
  }

  List<double> _roots(int a, int b, int c) {
    final d = (b * b - 4 * a * c).toDouble();
    if (d < 0) return [];
    if (d == 0) return [-b / (2 * a)];
    final s = d > 0 ? _sqrtD(d) : 0;
    return [(-b - s) / (2 * a), (-b + s) / (2 * a)];
  }

  double _sqrtD(double d) {
    var x = d / 2;
    for (var i = 0; i < 40; i++) {
      x = 0.5 * (x + d / x);
    }
    return x;
  }

  @override
  List<StepModel> getSteps() {
    final cf = _coeffs();
    if (cf == null) {
      return [
        StepModel(
            stepNumber: 1,
            title: 'Invalid input',
            explanation: _error ?? 'Use x^2 + 5x + 6.')
      ];
    }
    final r = solve();
    if (r.hasError) {
      return [
        StepModel(
            stepNumber: 1,
            title: 'No integer factors',
            explanation: r.errorMessage ?? '')
      ];
    }
    final m = (r.customData!.first as Map)['factorKind'] as String;
    final g = (r.customData!.first as Map)['gcf'] as int;
    return [
      StepModel(
          stepNumber: 1,
          title: 'Factor out the GCF',
          explanation: g > 1
              ? 'GCF is $g — divide every term by $g first.'
              : 'GCF is 1 — nothing to pull out.'),
      StepModel(
          stepNumber: 2,
          title: m == 'dots' ? 'Difference of squares' : 'Find two numbers',
          explanation: m == 'dots'
              ? 'a² − b² = (a+b)(a−b).'
              : 'Two numbers that multiply to c and add to b.'),
      StepModel(
          stepNumber: 3, title: 'Write the factors', explanation: r.answer),
      const StepModel(
          stepNumber: 4,
          title: 'Check (FOIL)',
          explanation: 'Multiply back — outer + inner must give bx.'),
    ];
  }
}
