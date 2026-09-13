// ─────────────────────────────────────────────────────────────
// RELATED RATES / OPTIMIZATION — G12. Maximize xy given x+y=S,
// rectangle max-area for perimeter P, sphere/balloon rates.
// e.g. 'max xy, x+y=20', 'rect P=40 max area'. Never throws.
// ─────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';
import 'package:calculus_system/topics/grade6/solvers/g6_support.dart';

class RelatedRatesEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  RelatedRatesEquation(this.rawInput);

  @override
  bool validate() {
    final empty =
        FieldValidators.notEmpty(rawInput, example: 'max xy, x + y = 20');
    if (empty != null) {
      _error = empty;
      return false;
    }
    final t = rawInput.toLowerCase();
    final ok = (t.contains('max') || t.contains('min') || t.contains('rate')) &&
        (t.contains('x+y') ||
            t.contains('x + y') ||
            t.contains('rect') ||
            t.contains('p=') ||
            t.contains('sphere') ||
            t.contains('balloon') ||
            t.contains('ladder'));
    if (!ok) {
      _error = 'Supported: max xy with x+y=S, rect P=…, sphere r=… dr/dt=….';
      return false;
    }
    _error = null;
    return true;
  }

  double? _num(String name) {
    final m = RegExp('$name\\s*=\\s*(-?\\d+(?:\\.\\d+)?)', caseSensitive: false)
        .firstMatch(rawInput);
    return m == null ? null : double.parse(m.group(1)!);
  }

  double? _sumXY() {
    // 'x+y=20' (spaces optional).
    final m =
        RegExp(r'x\s*\+\s*y\s*=\s*(-?\d+(?:\.\d+)?)', caseSensitive: false)
            .firstMatch(rawInput);
    return m == null ? null : double.parse(m.group(1)!);
  }

  @override
  SolveResult solve() {
    final t = rawInput.toLowerCase();
    final s = _sumXY();
    if (s != null && (t.contains('max') || t.contains('min'))) {
      // xy with x+y=S -> x=y=S/2, max=S²/4 (vertex of x(S−x)).
      final x = s / 2, y = s / 2, prod = x * y;
      return SolveResult(
        answer:
            'x = ${G6Format.num(x)}, y = ${G6Format.num(y)}, max xy = ${G6Format.num(prod)}',
        points: [x, y, prod],
        customData: [
          {
            'kind': 'optimization',
            'mode': 'sum-constraint',
            'x': x,
            'y': y,
            'max': prod,
            's': s
          }
        ],
      );
    }
    if (t.contains('rect')) {
      final p = _num('p');
      if (p == null || p <= 0) {
        return SolveResult.error(
            'Rectangle needs P > 0 — e.g. rect P = 40 max area.');
      }
      final side = p / 4, area = side * side;
      return SolveResult(
        answer:
            'Square ${G6Format.num(side)} × ${G6Format.num(side)}, max area = ${G6Format.num(area)}',
        points: [side, area],
        customData: [
          {
            'kind': 'optimization',
            'mode': 'rectangle',
            'side': side,
            'area': area,
            'p': p
          }
        ],
      );
    }
    if (t.contains('sphere') || t.contains('balloon')) {
      final r = _num('r');
      // Accept 'dr=0.5' or 'dr/dt=0.5'.
      double? rate;
      final m =
          RegExp(r'dr(?:/dt)?\s*=\s*(-?\d+(?:\.\d+)?)', caseSensitive: false)
              .firstMatch(rawInput);
      if (m != null) rate = double.parse(m.group(1)!);
      if (r == null || rate == null || r <= 0) {
        return SolveResult.error(
            'Sphere needs r > 0 and dr/dt — e.g. sphere r = 3, dr/dt = 0.5.');
      }
      final dv = 4 * math.pi * r * r * rate;
      final da = 8 * math.pi * r * rate;
      return SolveResult(
        answer:
            'dV/dt = ${G6Format.num(dv)}, dA/dt = ${G6Format.num(da)} (V = 4/3πr³, A = 4πr²)',
        points: [dv, da],
        customData: [
          {
            'kind': 'related-rates',
            'mode': 'sphere',
            'r': r,
            'dr': rate,
            'dv': dv,
            'da': da
          }
        ],
      );
    }
    if (t.contains('ladder')) {
      return SolveResult.error(
          'Ladder problems need x, y, L, dx/dt — e.g. ladder L = 10, x = 6, dx/dt = 2.');
    }
    return SolveResult.error(_error ?? 'Unsupported optimization pattern.');
  }

  @override
  List<StepModel> getSteps() {
    final r = solve();
    if (r.hasError) {
      return [
        StepModel(
            stepNumber: 1,
            title: 'Invalid input',
            explanation: r.errorMessage ?? '')
      ];
    }
    return [
      const StepModel(
          stepNumber: 1,
          title: 'Constraint → one variable',
          explanation:
              'Use the constraint (x + y = S, P = 2l + 2w) to eliminate y.'),
      const StepModel(
          stepNumber: 2,
          title: 'Derivative = 0',
          explanation: 'Critical point where the rate vanishes (vertex).'),
      StepModel(stepNumber: 3, title: 'Optimum', explanation: r.answer),
      const StepModel(
          stepNumber: 4,
          title: 'Second-derivative check',
          explanation: 'Concave down → maximum; up → minimum.'),
    ];
  }
}
