// ─────────────────────────────────────────────────────────────
// VARIATION — G9. Direct / inverse / joint variation.
// e.g. 'direct x=2 y=10 x=5' -> k=5, y=25. Never throws.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';
import 'package:calculus_system/topics/grade6/solvers/g6_support.dart';

class VariationEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  VariationEquation(this.rawInput);

  Map<String, double>? _nums() {
    final out = <String, double>{};
    for (final m
        in RegExp(r'([xyz])\s*=\s*(-?\d+(?:\.\d+)?)').allMatches(rawInput)) {
      out[m.group(1)!.toLowerCase()] = double.parse(m.group(2)!);
    }
    return out.isEmpty ? null : out;
  }

  String? _kind() {
    final t = rawInput.toLowerCase();
    if (t.contains('joint') || (t.contains('x') && t.contains('z') && t.contains('kxy'))) {
      return 'joint';
    }
    if (t.startsWith('inverse') || t.contains('inverse') || t.contains('k/x')) {
      return 'inverse';
    }
    if (t.startsWith('direct') || t.contains('direct') || t.contains('kx')) {
      return 'direct';
    }
    return null;
  }

  @override
  bool validate() {
    final empty = FieldValidators.notEmpty(
        rawInput, example: 'direct, x = 2, y = 10, x = 5');
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (_kind() == null) {
      _error = 'Start with direct, inverse, or joint — e.g. direct, x = 2, y = 10.';
      return false;
    }
    if (_nums() == null) {
      _error = 'Give values like x = 2, y = 10.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final kind = _kind();
    final nums = _nums();
    if (kind == null || nums == null) {
      return SolveResult.error(
          _error ?? 'Use direct/inverse/joint with x, y values.');
    }
    // Convention: first x,y pair defines k; a second x (or y) asks prediction.
    final xs = RegExp(r'x\s*=\s*(-?\d+(?:\.\d+)?)')
        .allMatches(rawInput)
        .map((m) => double.parse(m.group(1)!))
        .toList();
    final ys = RegExp(r'y\s*=\s*(-?\d+(?:\.\d+)?)')
        .allMatches(rawInput)
        .map((m) => double.parse(m.group(1)!))
        .toList();
    if (xs.isEmpty || ys.isEmpty) {
      return SolveResult.error('Need at least one x and one y value.');
    }
    final x1 = xs.first, y1 = ys.first;
    if (kind == 'direct') {
      if (x1 == 0) return SolveResult.error('x cannot be zero for direct variation.');
      final k = y1 / x1;
      if (xs.length > 1) {
        final y2 = k * xs[1];
        return SolveResult(
          answer: 'k = ${G6Format.num(k)}, y = ${G6Format.num(y2)} when x = ${G6Format.num(xs[1])}',
          points: [k, y2],
          customData: [
            {'kind': 'variation', 'mode': 'direct', 'k': k, 'x': xs[1], 'y': y2}
          ],
        );
      }
      return SolveResult(
        answer: 'k = ${G6Format.num(k)} (y = kx)',
        points: [k],
        customData: [
          {'kind': 'variation', 'mode': 'direct', 'k': k}
        ],
      );
    }
    if (kind == 'inverse') {
      final k = x1 * y1;
      if (xs.length > 1) {
        if (xs[1] == 0) {
          return SolveResult.error('x cannot be zero for inverse variation.');
        }
        final y2 = k / xs[1];
        return SolveResult(
          answer: 'k = ${G6Format.num(k)}, y = ${G6Format.num(y2)} when x = ${G6Format.num(xs[1])}',
          points: [k, y2],
          customData: [
            {'kind': 'variation', 'mode': 'inverse', 'k': k, 'x': xs[1], 'y': y2}
          ],
        );
      }
      return SolveResult(
        answer: 'k = ${G6Format.num(k)} (xy = k)',
        points: [k],
        customData: [
          {'kind': 'variation', 'mode': 'inverse', 'k': k}
        ],
      );
    }
    // Joint: z = kxy.
    final zs = RegExp(r'z\s*=\s*(-?\d+(?:\.\d+)?)')
        .allMatches(rawInput)
        .map((m) => double.parse(m.group(1)!))
        .toList();
    if (zs.isEmpty) return SolveResult.error('Joint variation needs z = kxy with a z value.');
    if (x1 == 0 || y1 == 0) {
      return SolveResult.error('x and y cannot be zero for joint variation.');
    }
    final k = zs.first / (x1 * y1);
    return SolveResult(
      answer: 'k = ${G6Format.num(k)} (z = kxy)',
      points: [k],
      customData: [
        {'kind': 'variation', 'mode': 'joint', 'k': k}
      ],
    );
  }

  @override
  List<StepModel> getSteps() {
    final kind = _kind();
    if (kind == null || _nums() == null) {
      return [
        StepModel(
            stepNumber: 1,
            title: 'Invalid input',
            explanation: _error ?? 'Use direct, x = 2, y = 10.')
      ];
    }
    final r = solve();
    final form = kind == 'direct'
        ? 'y = kx'
        : kind == 'inverse'
            ? 'xy = k'
            : 'z = kxy';
    return [
      StepModel(
          stepNumber: 1, title: 'Variation form', explanation: 'Use $form.'),
      StepModel(stepNumber: 2, title: 'Find k', explanation: r.answer),
      const StepModel(
          stepNumber: 3,
          title: 'Predict new values',
          explanation: 'Substitute the new x (or y) into the form with k.'),
    ];
  }
}
