// ─────────────────────────────────────────────────────────────
// TRIG EQUATION — PreCalc. sin/cos/tan x = k on [0, 2π).
// e.g. 'sin x = 1/2' -> x = π/6, 5π/6. Never throws.
// ─────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:calculus_system/calculator/calculator_engine.dart';
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';
import 'package:calculus_system/topics/grade6/solvers/g6_support.dart';

class TrigEquationSolver extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  TrigEquationSolver(this.rawInput);

  List<dynamic>? _parse() {
    final t = rawInput
        .replaceAll(' ', '')
        .replaceAll('−', '-')
        .replaceAll('θ', 'x')
        .toLowerCase();
    final m = RegExp(r'^(sin|cos|tan)\(?x\)?=(.+)$').firstMatch(t);
    if (m == null) return null;
    double k;
    try {
      k = CalculatorEngine.evaluate(m.group(2)!);
    } catch (_) {
      return null;
    }
    if (!k.isFinite) return null;
    return [m.group(1)!, k];
  }

  String _fmtPi(double rad) {
    // Pretty multiples of π/6, π/4, π/3, π/2.
    const denoms = [6, 4, 3, 2, 1];
    for (final d in denoms) {
      final n = (rad * d / math.pi).round();
      if ((rad - n * math.pi / d).abs() < 1e-9 && n.abs() <= 4 * d) {
        if (n == 0) return '0';
        if (d == 1) {
          return n == 1
              ? 'π'
              : n == -1
                  ? '-π'
                  : '$nπ';
        }
        final g = _gcd(n.abs(), d);
        final nn = n ~/ g, dd = d ~/ g;
        if (nn == 1 && dd == 1) return 'π';
        if (dd == 1) return '$nnπ';
        return nn == 1 ? 'π/$dd' : '$nnπ/$dd';
      }
    }
    return '${G6Format.num(rad)} rad';
  }

  int _gcd(int a, int b) {
    while (b != 0) {
      final t = a % b;
      a = b;
      b = t;
    }
    return a == 0 ? 1 : a;
  }

  @override
  bool validate() {
    final empty = FieldValidators.notEmpty(rawInput, example: 'sin x = 1/2');
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (_parse() == null) {
      _error = 'Use sin/cos/tan x = k — e.g. sin x = 1/2.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final p = _parse();
    if (p == null) {
      return SolveResult.error(_error ?? 'Use sin x = 1/2 on [0, 2π).');
    }
    final fn = p[0] as String, k = p[1] as double;
    const twoPi = 2 * math.pi;
    List<double> sols;
    if (fn == 'sin') {
      if (k.abs() > 1 + 1e-12) {
        return SolveResult.error('No solution — |sin x| ≤ 1.');
      }
      final a = math.asin(k.clamp(-1, 1));
      sols = k.abs() > 1 - 1e-12 ? [a < 0 ? a + twoPi : a] : [a, math.pi - a];
    } else if (fn == 'cos') {
      if (k.abs() > 1 + 1e-12) {
        return SolveResult.error('No solution — |cos x| ≤ 1.');
      }
      final a = math.acos(k.clamp(-1, 1));
      sols =
          (k - 1).abs() < 1e-12 || (k + 1).abs() < 1e-12 ? [a] : [a, twoPi - a];
    } else {
      final a = math.atan(k);
      sols = [a < 0 ? a + math.pi : a, (a < 0 ? a + math.pi : a) + math.pi];
    }
    sols = sols
        .map((e) => e < 0
            ? e + twoPi
            : (e >= twoPi && (e - twoPi).abs() < 1e-9 ? 0.0 : e))
        .toSet()
        .toList()
      ..sort();
    final degs = sols.map((e) => G6Format.num(e * 180 / math.pi)).join('°, ');
    final ans = 'x = ${sols.map(_fmtPi).join(', ')}  ($degs° on [0, 2π))';
    return SolveResult(
      answer: ans,
      points: sols,
      customData: [
        {
          'kind': 'trig-eq',
          'fn': fn,
          'k': k,
          'radians': sols,
          'degrees': sols.map((e) => e * 180 / math.pi).toList(),
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
            explanation: _error ?? 'Use sin x = 1/2.')
      ];
    }
    final r = solve();
    return [
      const StepModel(
          stepNumber: 1,
          title: 'Reference angle',
          explanation: 'Solve for the acute reference angle first.'),
      const StepModel(
          stepNumber: 2,
          title: 'Quadrants by sign',
          explanation: 'sin + in I/II, cos + in I/IV, tan + in I/III.'),
      StepModel(
          stepNumber: 3, title: 'Solutions on [0, 2π)', explanation: r.answer),
    ];
  }
}
