// ─────────────────────────────────────────────────────────────
// QUADRATIC SOLVE — G9. Discriminant + quadratic formula.
// e.g. 'x^2-5x+6=0' -> x=2, 3. Parabola graph via customData.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';
import 'package:calculus_system/topics/grade6/solvers/g6_support.dart';

class QuadraticEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  QuadraticEquation(this.rawInput);

  String _norm() => rawInput
      .replaceAll('×', '*')
      .replaceAll('−', '-')
      .replaceAll(' ', '')
      .replaceAll('X', 'x');

  List<double>? _coeffs() {
    var e = _norm().replaceAll('*', '');
    if (e.contains('=')) {
      final sides = e.split('=');
      if (sides.length != 2) return null;
      if (sides[1] != '0' && sides[1].isNotEmpty) {
        // Move simple constant RHS over.
        final rhs = double.tryParse(sides[1]);
        if (rhs == null) return null;
        e = '${sides[0]}${rhs > 0 ? '-' : '+'}${rhs.abs()}';
      } else {
        e = sides[0];
      }
    }
    if (!e.contains('x')) return null;
    if (RegExp(r'x\^?[3-9]').hasMatch(e)) return null;
    double a = 0, b = 0, c = 0;
    var s = e.startsWith('-') || e.startsWith('+') ? e : '+$e';
    final terms = RegExp(r'[+-][^+-]+').allMatches(s).map((m) => m.group(0)!);
    for (final t in terms) {
      final sign = t.startsWith('-') ? -1.0 : 1.0;
      final body = t.substring(1);
      if (body.contains('x^2') || body.contains('x²')) {
        final coef = body.replaceAll('x^2', '').replaceAll('x²', '');
        final v = coef.isEmpty ? 1.0 : double.tryParse(coef);
        if (v == null) return null;
        a += sign * v;
      } else if (body.contains('x')) {
        final coef = body.replaceAll('x', '');
        final v = coef.isEmpty ? 1.0 : double.tryParse(coef);
        if (v == null) return null;
        b += sign * v;
      } else {
        final v = double.tryParse(body);
        if (v == null) return null;
        c += sign * v;
      }
    }
    if (a.abs() < 1e-12) return null;
    return [a, b, c];
  }

  @override
  bool validate() {
    final empty =
        FieldValidators.notEmpty(rawInput, example: 'x^2 - 5x + 6 = 0');
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (_coeffs() == null) {
      _error = 'Quadratic = 0 form — e.g. x^2 - 5x + 6 = 0.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final cf = _coeffs();
    if (cf == null) {
      return SolveResult.error(
          _error ?? 'Enter a quadratic — e.g. x^2 - 5x + 6 = 0.');
    }
    final a = cf[0], b = cf[1], c = cf[2];
    final disc = b * b - 4 * a * c;
    if (disc < -1e-12) {
      return SolveResult(
        answer: 'No real roots (D = ${G6Format.num(disc)} < 0)',
        points: const [],
        customData: [
          {'kind': 'parabola', 'a': a, 'b': b, 'c': c, 'discriminant': disc, 'roots': []}
        ],
      );
    }
    if (disc.abs() < 1e-12) {
      final x = -b / (2 * a);
      return SolveResult(
        answer: 'x = ${G6Format.num(x)} (double root, D = 0)',
        points: [x],
        customData: [
          {'kind': 'parabola', 'a': a, 'b': b, 'c': c, 'discriminant': 0, 'roots': [x]}
        ],
      );
    }
    final s = _sqrt(disc);
    final x1 = (-b - s) / (2 * a);
    final x2 = (-b + s) / (2 * a);
    final lo = x1 < x2 ? x1 : x2;
    final hi = x1 < x2 ? x2 : x1;
    return SolveResult(
      answer: 'x = ${G6Format.num(lo)}, ${G6Format.num(hi)} (D = ${G6Format.num(disc)})',
      points: [lo, hi],
      customData: [
        {
          'kind': 'parabola',
          'a': a,
          'b': b,
          'c': c,
          'discriminant': disc,
          'roots': [lo, hi],
          'vertex': {'x': -b / (2 * a), 'y': c - b * b / (4 * a)},
        }
      ],
    );
  }

  double _sqrt(double d) {
    var x = d / 2;
    if (x <= 0) x = 1;
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
            explanation: _error ?? 'Use x^2 - 5x + 6 = 0.')
      ];
    }
    final disc = cf[1] * cf[1] - 4 * cf[0] * cf[2];
    final r = solve();
    return [
      StepModel(
          stepNumber: 1,
          title: 'Identify a, b, c',
          explanation:
              'a=${G6Format.num(cf[0])}, b=${G6Format.num(cf[1])}, c=${G6Format.num(cf[2])}.'),
      StepModel(
          stepNumber: 2,
          title: 'Discriminant',
          explanation: 'D = b² − 4ac = ${G6Format.num(disc)}.'),
      const StepModel(
          stepNumber: 3,
          title: 'Quadratic formula',
          explanation: 'x = (−b ± √D) / 2a.'),
      StepModel(stepNumber: 4, title: 'Roots + parabola', explanation: r.answer),
    ];
  }
}
