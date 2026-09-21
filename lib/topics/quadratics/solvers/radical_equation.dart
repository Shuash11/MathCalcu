// ─────────────────────────────────────────────────────────────
// RADICAL EQUATION — G9. Solves sqrt(linear)+b=c with domain and
// extraneous-root verification. e.g. 'sqrt(x+5)=3' -> x=4.
// Cycle 12 Item 2: right sides with x-terms (e.g. 'sqrt(x+5)=x').
// The x-terms fold to one side; squaring gives a quadratic in x and
// every candidate is verified against the original equation.
// ─────────────────────────────────────────────────────────────

import 'dart:math' as math;

import 'package:calculus_system/calculator/calculator_engine.dart';
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';
import 'package:calculus_system/topics/grade6/solvers/g6_support.dart';

class RadicalEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  RadicalEquation(this.rawInput);

  String _n() => rawInput.replaceAll(' ', '').replaceAll('−', '-');

  double? _eval(String e) {
    try {
      return CalculatorEngine.evaluate(e);
    } catch (_) {
      return null;
    }
  }

  /// Parses the left side into (m, k, b, inside): sqrt(m*x + k) + b.
  /// Null when the left side is unsupported.
  List<dynamic>? _parseLeft(String left) {
    final sm = RegExp(r'sqrt\(([^)]+)\)').firstMatch(left);
    if (sm == null) return null;
    if ('sqrt'.allMatches(left).length != 1) return null;
    final inside = sm.group(1)!;
    // Inside must be linear: m*x+k.
    final f0 = _eval(inside.replaceAll('x', '(0)'));
    final f1 = _eval(inside.replaceAll('x', '(1)'));
    if (f0 == null || f1 == null) return null;
    final m = f1 - f0, k = f0;
    if (m.abs() < 1e-12) return null;
    final rest = left.replaceFirst(sm.group(0)!, '');
    double b = 0;
    if (rest.isNotEmpty) {
      final v = double.tryParse(rest);
      if (v == null) return null;
      b = v;
    }
    return [m, k, b, inside];
  }

  /// Parses the right side. Plain numbers keep the fast path:
  /// [m, k, b, rhs, inside]. A linear x-term right side r*x + s folds
  /// to the left — the equation becomes sqrt(m*x + k) + b = r*x + s —
  /// and parses as [m, k, b, null, inside, r, s] (rhs null marks the
  /// x-form). Null when unsupported.
  List<dynamic>? _parse() {
    final t = _n().replaceAll('√', 'sqrt');
    if ('='.allMatches(t).length != 1) return null;
    final sides = t.split('=');
    final lhs = _parseLeft(sides[0]);
    if (lhs == null) return null;
    final m = lhs[0], k = lhs[1], b = lhs[2], inside = lhs[3];
    final rhsRaw = sides[1];
    final rhsNum = double.tryParse(rhsRaw);
    if (rhsNum != null) return [m, k, b, rhsNum, inside];
    // Right side has x: must be linear in x (probe 0, 1, 2).
    if (!rhsRaw.contains('x')) return null;
    final g0 = _eval(rhsRaw.replaceAll('x', '(0)'));
    final g1 = _eval(rhsRaw.replaceAll('x', '(1)'));
    final g2 = _eval(rhsRaw.replaceAll('x', '(2)'));
    if (g0 == null || g1 == null || g2 == null) return null;
    final r = g1 - g0, s = g0;
    if ((g2 - (2 * r + s)).abs() > 1e-9) return null; // not linear
    if (r.abs() < 1e-12) return null; // constant right side parses above
    return [m, k, b, null, inside, r, s];
  }

  @override
  bool validate() {
    final empty =
        FieldValidators.notEmpty(rawInput, example: 'sqrt(x + 5) = 3');
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (!rawInput.toLowerCase().contains('sqrt') && !rawInput.contains('√')) {
      _error = 'Include sqrt — e.g. sqrt(x + 5) = 3.';
      return false;
    }
    if (_parse() == null) {
      _error =
          'One square root of a linear expression — e.g. sqrt(2x + 1) - 1 = 2.';
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
          _error ?? 'Enter a radical equation — e.g. sqrt(x + 5) = 3.');
    }
    if (p[3] == null) return _solveXRhs(p);
    // Plain-number right side.
    final m = p[0] as double, k = p[1] as double;
    final b = p[2] as double, rhs = p[3] as double;
    final iso = rhs - b; // sqrt(...) = iso
    if (iso < -1e-12) {
      return SolveResult.error(
          'No real solution — square root cannot equal ${G6Format.num(iso)} < 0.');
    }
    final x = (iso * iso - k) / m;
    // Domain + verification (extraneous check).
    final inside = m * x + k;
    if (inside < -1e-9) {
      return SolveResult.error(
          'No solution — candidate x = ${G6Format.num(x)} is outside the domain.');
    }
    final check = _eval('sqrt(($inside))+($b)');
    if (check == null || (check - rhs).abs() > 1e-6) {
      return SolveResult.error(
          'No solution — candidate x = ${G6Format.num(x)} fails verification (extraneous).');
    }
    return SolveResult(
      answer: 'x = ${G6Format.num(x)}',
      points: [x],
      customData: [
        {
          'kind': 'radical',
          'root': x,
          'domain': 'x ${m > 0 ? '≥' : '≤'} ${G6Format.num(-k / m)}',
          'check': check,
        }
      ],
    );
  }

  /// Right side is r*x + s: sqrt(m*x + k) + b = r*x + s. Folding the
  /// x-terms to one side and squaring both sides gives a quadratic in
  /// x: r^2*x^2 + (2*r*t - m)*x + (t^2 - k) = 0 with t = s - b. Each
  /// candidate is verified against the original equation — squaring is
  /// not reversible, so false roots are rejected (extraneous check).
  SolveResult _solveXRhs(List<dynamic> p) {
    final m = p[0] as double, k = p[1] as double;
    final b = p[2] as double;
    final r = p[5] as double, s = p[6] as double;
    final t = s - b; // sqrt(...) = r*x + t
    final a = r * r;
    final b2 = 2 * r * t - m;
    final c2 = t * t - k;
    final disc = b2 * b2 - 4 * a * c2;
    if (disc < -1e-12) {
      return SolveResult.error(
          'No real solution — squaring gives a quadratic with a negative discriminant.');
    }
    final sq = math.sqrt(disc < 0 ? 0 : disc);
    final candidates = disc.abs() <= 1e-12
        ? [-b2 / (2 * a)]
        : [(-b2 + sq) / (2 * a), (-b2 - sq) / (2 * a)];
    // Domain + verification per candidate (extraneous check).
    final roots = <double>[];
    final checks = <double>[];
    for (final x in candidates) {
      final val = m * x + k;
      if (val < -1e-9) continue; // outside the domain
      final check = _eval('sqrt(($val))+($b)');
      if (check == null) continue;
      if ((check - (r * x + s)).abs() > 1e-6) continue; // extraneous
      if (roots.isNotEmpty && (x - roots.last).abs() <= 1e-9) continue;
      roots.add(x);
      checks.add(check);
    }
    if (roots.isEmpty) {
      final listed = candidates.map((x) => 'x = ${G6Format.num(x)}').join(', ');
      return SolveResult.error(
          'No solution — candidates $listed fail verification (extraneous).');
    }
    roots.sort(); // ascending for readability, e.g. 'x = 0 or x = 1'
    final answer = roots.map((x) => 'x = ${G6Format.num(x)}').join(' or ');
    return SolveResult(
      answer: answer,
      points: roots,
      customData: [
        for (var i = 0; i < roots.length; i++)
          {
            'kind': 'radical',
            'root': roots[i],
            'domain': 'x ${m > 0 ? '≥' : '≤'} ${G6Format.num(-k / m)}',
            'check': checks[i],
          }
      ],
    );
  }

  @override
  List<StepModel> getSteps() {
    final p = _parse();
    if (p == null) {
      return [
        StepModel(
            stepNumber: 1,
            title: 'Invalid input',
            explanation: _error ?? 'Use sqrt(x + 5) = 3.')
      ];
    }
    if (p[3] == null) return _stepsXRhs(p);
    final m = p[0] as double, k = p[1] as double;
    final b = p[2] as double, rhs = p[3] as double;
    final r = solve();
    return [
      StepModel(
          stepNumber: 1,
          title: 'Domain',
          explanation:
              'Need ${p[4]} ≥ 0, so x ${m > 0 ? '≥' : '≤'} ${G6Format.num(-k / m)}.'),
      StepModel(
          stepNumber: 2,
          title: 'Isolate the root',
          explanation:
              'sqrt(${p[4]}) = ${G6Format.num(rhs)} − ${G6Format.num(b)} = ${G6Format.num(rhs - b)}.'),
      const StepModel(
          stepNumber: 3,
          title: 'Square both sides',
          explanation: 'Squaring is not reversible — verify at the end.'),
      StepModel(
          stepNumber: 4,
          title: 'Verify (extraneous check)',
          explanation: r.answer),
    ];
  }

  /// Steps for a right side with x-terms: same four-step shape, with
  /// the isolate step showing the fold and the square step showing the
  /// resulting quadratic.
  List<StepModel> _stepsXRhs(List<dynamic> p) {
    final m = p[0] as double, k = p[1] as double;
    final b = p[2] as double, inside = p[4] as String;
    final r = p[5] as double, s = p[6] as double;
    final t = s - b;
    final a = r * r, b2 = 2 * r * t - m, c2 = t * t - k;
    final res = solve();
    return [
      StepModel(
          stepNumber: 1,
          title: 'Domain',
          explanation:
              'Need $inside ≥ 0, so x ${m > 0 ? '≥' : '≤'} ${G6Format.num(-k / m)}.'),
      StepModel(
          stepNumber: 2,
          title: 'Isolate the root',
          explanation: _isolateExpl(inside, r, s, b)),
      StepModel(
          stepNumber: 3,
          title: 'Square both sides',
          explanation:
              '${_quadStr(a, b2, c2)} Squaring is not reversible — verify at the end.'),
      StepModel(
          stepNumber: 4,
          title: 'Verify (extraneous check)',
          explanation: res.answer),
    ];
  }

  /// 'sqrt(x+5) = 2x - 1' style isolate explanation.
  String _isolateExpl(String inside, double r, double s, double b) {
    final t = s - b;
    String coef(double v) => v == 1
        ? 'x'
        : v == -1
            ? '-x'
            : '${G6Format.num(v)}x';
    String tail(double v) => v == 0
        ? ''
        : v > 0
            ? ' + ${G6Format.num(v)}'
            : ' - ${G6Format.num(-v)}';
    final isolated = '${coef(r)}${tail(t)}';
    if (b == 0) return 'sqrt($inside) = $isolated.';
    return 'sqrt($inside)${tail(b)} = ${coef(r)}${tail(s)} → '
            'sqrt($inside) = $isolated.'
        .replaceAll('  ', ' ');
  }

  /// 'x^2 - x - 5 = 0' style string for the squared equation.
  String _quadStr(double a, double bC, double c) {
    String term(double v, String sym) {
      if (v.abs() < 1e-12) return '';
      final mag = G6Format.num(v.abs());
      final coef = sym.isNotEmpty && mag == '1' ? '' : '$mag ';
      return '${v > 0 ? '+' : '-'} $coef$sym';
    }

    final parts = [
      term(a, 'x^2'),
      term(bC, 'x'),
      term(c, ''),
    ].where((t) => t.isNotEmpty).toList();
    if (parts.isEmpty) return '0 = 0.';
    var body = parts.join(' ');
    if (body.startsWith('+ ')) body = body.substring(2);
    return '$body = 0.';
  }
}
