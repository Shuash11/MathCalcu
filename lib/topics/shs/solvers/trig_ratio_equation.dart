// ─────────────────────────────────────────────────────────────
// TRIG RATIO (SOHCAHTOA) — G9/PreCalc. Right-triangle side, angle,
// or ratio. Degrees. Never throws. e.g. 'sin 30', 'opp=3 hyp=6'.
// ─────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';
import 'package:calculus_system/topics/grade6/solvers/g6_support.dart';

class TrigRatioEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  TrigRatioEquation(this.rawInput);

  double? _num(String name) {
    final m = RegExp('$name\\s*=\\s*(-?\\d+(?:\\.\\d+)?)', caseSensitive: false)
        .firstMatch(rawInput);
    return m == null ? null : double.parse(m.group(1)!);
  }

  @override
  bool validate() {
    final empty = FieldValidators.notEmpty(rawInput,
        example: 'sin 30° or opp = 3, hyp = 6');
    if (empty != null) {
      _error = empty;
      return false;
    }
    final t = rawInput.toLowerCase();
    final hasFn = t.contains('sin') || t.contains('cos') || t.contains('tan');
    final hasSide = t.contains('opp') || t.contains('adj') || t.contains('hyp');
    if (!hasFn && !hasSide) {
      _error =
          'Use sin/cos/tan or opp/adj/hyp — e.g. sin 30° or opp = 3, hyp = 6.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final t =
        rawInput.toLowerCase().replaceAll('°', '').replaceAll('deg', '').trim();
    // Case 1: ratio of an angle: 'sin 30'.
    final rm = RegExp(r'(sin|cos|tan)\s*(-?\d+(?:\.\d+)?)').firstMatch(t);
    if (rm != null && !_hasSides()) {
      final fn = rm.group(1)!;
      final deg = double.parse(rm.group(2)!);
      final rad = deg * math.pi / 180;
      double v;
      if (fn == 'sin') {
        v = math.sin(rad);
      } else if (fn == 'cos') {
        v = math.cos(rad);
      } else {
        if ((deg - 90).abs() % 180 < 1e-9) {
          return SolveResult.error('tan 90° is undefined.');
        }
        v = math.tan(rad);
      }
      final rounded = v.abs() < 1e-12 ? 0.0 : v;
      return SolveResult(
        answer: '$fn(${G6Format.num(deg)}°) = ${G6Format.num(rounded)}',
        points: [rounded],
        customData: [
          {
            'kind': 'trig-ratio',
            'mode': 'ratio',
            'fn': fn,
            'deg': deg,
            'value': rounded
          }
        ],
      );
    }
    // Case 2: sides -> missing side / angle / ratio.
    final opp = _num('opp'), adj = _num('adj'), hyp = _num('hyp');
    final known = [opp, adj, hyp].where((v) => v != null).length;
    if (known < 2) {
      // Angle from ratio? e.g. 'sin x = 0.5' handled by trig-equation solver; here:
      // 'sin=0.5 find angle'.
      final vm = RegExp(r'(sin|cos|tan)\s*=\s*(-?\d+(?:\.\d+)?)').firstMatch(t);
      if (vm != null) {
        final fn = vm.group(1)!;
        final v = double.parse(vm.group(2)!);
        if (v.abs() > 1 && fn != 'tan') {
          return SolveResult.error('$fn = $v has no real angle (|value| ≤ 1).');
        }
        double deg;
        if (fn == 'sin') {
          deg = math.asin(v.clamp(-1, 1)) * 180 / math.pi;
        } else if (fn == 'cos') {
          deg = math.acos(v.clamp(-1, 1)) * 180 / math.pi;
        } else {
          deg = math.atan(v) * 180 / math.pi;
        }
        return SolveResult(
          answer: 'θ = ${G6Format.num(deg)}° ($fn θ = ${G6Format.num(v)})',
          points: [deg],
          customData: [
            {'kind': 'trig-ratio', 'mode': 'angle', 'fn': fn, 'deg': deg}
          ],
        );
      }
      return SolveResult.error(
          _error ?? 'Give two sides — e.g. opp = 3, hyp = 6.');
    }
    for (final s in [opp, adj, hyp]) {
      if (s != null && s <= 0) {
        return SolveResult.error('Sides must be positive.');
      }
    }
    if (opp != null && hyp != null && opp >= hyp) {
      return SolveResult.error('Opposite cannot exceed the hypotenuse.');
    }
    if (adj != null && hyp != null && adj >= hyp) {
      return SolveResult.error('Adjacent cannot exceed the hypotenuse.');
    }
    if (opp != null && hyp != null) {
      final a = math.asin((opp / hyp).clamp(-1, 1)) * 180 / math.pi;
      final ad = math.sqrt(hyp * hyp - opp * opp);
      return SolveResult(
        answer:
            'θ = ${G6Format.num(a)}°, adj = ${G6Format.num(ad)} (sin θ = opp/hyp)',
        points: [a, ad],
        customData: [
          {
            'kind': 'trig-ratio',
            'mode': 'triangle',
            'theta': a,
            'opp': opp,
            'adj': ad,
            'hyp': hyp
          }
        ],
      );
    }
    if (adj != null && hyp != null) {
      final a = math.acos((adj / hyp).clamp(-1, 1)) * 180 / math.pi;
      final op = math.sqrt(hyp * hyp - adj * adj);
      return SolveResult(
        answer:
            'θ = ${G6Format.num(a)}°, opp = ${G6Format.num(op)} (cos θ = adj/hyp)',
        points: [a, op],
        customData: [
          {
            'kind': 'trig-ratio',
            'mode': 'triangle',
            'theta': a,
            'opp': op,
            'adj': adj,
            'hyp': hyp
          }
        ],
      );
    }
    // opp + adj -> hyp + angle.
    final o = opp!, j = adj!;
    final h = math.sqrt(o * o + j * j);
    final a = math.atan2(o, j) * 180 / math.pi;
    return SolveResult(
      answer:
          'hyp = ${G6Format.num(h)}, θ = ${G6Format.num(a)}° (tan θ = opp/adj)',
      points: [h, a],
      customData: [
        {
          'kind': 'trig-ratio',
          'mode': 'triangle',
          'theta': a,
          'opp': o,
          'adj': j,
          'hyp': h
        }
      ],
    );
  }

  bool _hasSides() {
    final t = rawInput.toLowerCase();
    return t.contains('opp') || t.contains('adj') || t.contains('hyp');
  }

  @override
  List<StepModel> getSteps() {
    final r = solve();
    if (r.hasError) {
      return [
        StepModel(
            stepNumber: 1,
            title: 'Invalid input',
            explanation: r.errorMessage ?? (_error ?? 'Use sin 30°.'))
      ];
    }
    return [
      const StepModel(
          stepNumber: 1,
          title: 'Label SOH-CAH-TOA',
          explanation: 'Sin = Opp/Hyp, Cos = Adj/Hyp, Tan = Opp/Adj.'),
      const StepModel(
          stepNumber: 2,
          title: 'Pick the ratio with two knowns',
          explanation: 'The hypotenuse is always the longest side.'),
      StepModel(stepNumber: 3, title: 'Solve', explanation: r.answer),
    ];
  }
}
