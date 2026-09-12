// ─────────────────────────────────────────────────────────────
// POLYNOMIAL DIVISION — G10. Synthetic division by (x − a):
// quotient + remainder (Remainder theorem). Never throws.
// e.g. '(x^3+2x^2-5x+1)/(x-1)' -> quotient + R=... 
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';
import 'package:calculus_system/topics/grade6/solvers/g6_support.dart';

class PolyDivisionEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  PolyDivisionEquation(this.rawInput);

  String _n() => rawInput.replaceAll(' ', '').replaceAll('−', '-').replaceAll('X', 'x');

  /// Parses polynomial coeffs highest→constant. Null on failure.
  List<double>? _polyCoeffs(String e) {
    var s = e.replaceAll('*', '');
    if (s.isEmpty || !s.contains('x')) {
      final v = double.tryParse(s);
      return v == null ? null : [v];
    }
    if (RegExp(r'x\^?([3-9]\d*)').hasMatch(s.replaceAll('x^2', 'Q').replaceAll('x²', 'Q'))) {
      // Allow degree 1..6 only.
      final degs = RegExp(r'x\^(\d+)').allMatches(s).map((m) => int.parse(m.group(1)!));
      if (degs.any((d) => d > 6)) return null;
    }
    final terms = <String, double>{};
    var t = s.startsWith('-') || s.startsWith('+') ? s : '+$s';
    for (final m in RegExp(r'[+-][^+-]+').allMatches(t)) {
      final term = m.group(0)!;
      final sign = term.startsWith('-') ? -1.0 : 1.0;
      final body = term.substring(1);
      if (body.contains('x^')) {
        final parts = body.split('x^');
        if (parts.length != 2) return null;
        final deg = int.tryParse(parts[1]);
        final coef = parts[0].isEmpty ? 1.0 : double.tryParse(parts[0]);
        if (deg == null || coef == null) return null;
        terms['$deg'] = (terms['$deg'] ?? 0) + sign * coef;
      } else if (body.contains('x²')) {
        final coef = body.replaceAll('x²', '');
        final v = coef.isEmpty ? 1.0 : double.tryParse(coef);
        if (v == null) return null;
        terms['2'] = (terms['2'] ?? 0) + sign * v;
      } else if (body.contains('x')) {
        final coef = body.replaceAll('x', '');
        final v = coef.isEmpty ? 1.0 : double.tryParse(coef);
        if (v == null) return null;
        terms['1'] = (terms['1'] ?? 0) + sign * v;
      } else {
        final v = double.tryParse(body);
        if (v == null) return null;
        terms['0'] = (terms['0'] ?? 0) + sign * v;
      }
    }
    if (terms.isEmpty) return null;
    final maxDeg = terms.keys.map(int.parse).reduce((a, b) => a > b ? a : b);
    return [for (var d = maxDeg; d >= 0; d--) terms['$d'] ?? 0];
  }

  List<dynamic>? _parse() {
    final t = _n();
    final parts = t.split('/');
    if (parts.length != 2) return null;
    var num = parts[0];
    var den = parts[1];
    if (num.startsWith('(') && num.endsWith(')')) {
      num = num.substring(1, num.length - 1);
    }
    if (den.startsWith('(') && den.endsWith(')')) {
      den = den.substring(1, den.length - 1);
    }
    final nc = _polyCoeffs(num);
    if (nc == null || nc.length < 2) return null;
    // Divisor must be (x − a): x+b form.
    final dm = RegExp(r'^x([+-]\d+(?:\.\d+)?)$').firstMatch(den);
    if (dm == null) return null;
    final b = double.parse(dm.group(1)!); // divisor x+b -> a=-b
    return [nc, -b];
  }

  @override
  bool validate() {
    final empty = FieldValidators.notEmpty(
        rawInput, example: '(x^3 + 2x^2 - 5x + 1)/(x - 1)');
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (_parse() == null) {
      _error = 'Use P(x)/(x - a) — e.g. (x^3 + 2x^2 - 5x + 1)/(x - 1).';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final p = _parse();
    if (p == null) {
      return SolveResult.error(
          _error ?? 'Use P(x)/(x - a).');
    }
    final coeffs = (p[0] as List).cast<double>();
    final a = p[1] as double;
    // Synthetic division.
    final q = <double>[coeffs.first];
    for (var i = 1; i < coeffs.length - 1; i++) {
      q.add(coeffs[i] + q.last * a);
    }
    final rem = coeffs.last + q.last * a;
    final deg = coeffs.length - 1;
    final terms = <String>[];
    for (var i = 0; i < q.length; i++) {
      final power = deg - 1 - i;
      final c = q[i];
      if (c.abs() < 1e-12) continue;
      final cs = G6Format.num(c.abs());
      final body = power == 0
          ? cs
          : power == 1
              ? '${cs == '1' ? '' : cs}x'
              : '${cs == '1' ? '' : cs}x^$power';
      if (terms.isEmpty) {
        terms.add('${c < 0 ? '-' : ''}$body');
      } else {
        terms.add('${c < 0 ? ' - ' : ' + '}$body');
      }
    }
    final qs = terms.isEmpty ? '0' : terms.join();
    final answer = rem.abs() < 1e-9
        ? 'Quotient: $qs, Remainder: 0  →  (x ${a >= 0 ? '-' : '+'} ${G6Format.num(a.abs())}) is a factor'
        : 'Quotient: $qs, Remainder: ${G6Format.num(rem)}';
    return SolveResult(
      answer: answer,
      points: q,
      customData: [
        {
          'kind': 'polydiv',
          'quotient': q,
          'remainder': rem,
          'a': a,
          'degree': deg,
        }
      ],
    );
  }

  @override
  List<StepModel> getSteps() {
    if (_parse() == null) {
      return [
        StepModel(
            stepNumber: 1,
            title: 'Invalid input',
            explanation: _error ?? 'Use P(x)/(x - a).')
      ];
    }
    final r = solve();
    return [
      const StepModel(
          stepNumber: 1,
          title: 'Set up synthetic division',
          explanation: 'Coefficients on top, zero a of (x − a) on the side.'),
      const StepModel(
          stepNumber: 2,
          title: 'Bring down, multiply, add',
          explanation: 'Repeat across the row — multiply by a, add to next.'),
      StepModel(stepNumber: 3, title: 'Quotient + remainder', explanation: r.answer),
      const StepModel(
          stepNumber: 4,
          title: 'Remainder theorem',
          explanation: 'Remainder equals P(a) — zero means (x − a) is a factor.'),
    ];
  }
}
