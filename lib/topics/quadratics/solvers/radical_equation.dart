// ─────────────────────────────────────────────────────────────
// RADICAL EQUATION — G9. Solves sqrt(linear)+b=c with domain and
// extraneous-root verification. e.g. 'sqrt(x+5)=3' -> x=4.
// ─────────────────────────────────────────────────────────────

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

  /// Returns (m, k, b): sqrt(m*x+k) + b = rhs. Null when unsupported.
  List<dynamic>? _parse() {
    final t = _n().replaceAll('√', 'sqrt');
    if ('='.allMatches(t).length != 1) return null;
    final sides = t.split('=');
    final rhs = double.tryParse(sides[1]);
    if (rhs == null) return null;
    final left = sides[0];
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
    return [m, k, b, rhs, inside];
  }

  @override
  bool validate() {
    final empty =
        FieldValidators.notEmpty(rawInput, example: 'sqrt(x + 5) = 3');
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (!rawInput.toLowerCase().contains('sqrt') &&
        !rawInput.contains('√')) {
      _error = 'Include sqrt — e.g. sqrt(x + 5) = 3.';
      return false;
    }
    if (_parse() == null) {
      _error = 'One square root of a linear expression — e.g. sqrt(2x + 1) - 1 = 2.';
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
          stepNumber: 4, title: 'Verify (extraneous check)', explanation: r.answer),
    ];
  }
}
