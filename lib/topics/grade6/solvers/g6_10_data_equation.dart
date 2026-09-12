// ─────────────────────────────────────────────────────────────
// G6-10 DATA — pie chart (must) + simple probability (intro).
// DepEd M6SP-IVe-1 + M6SP-IVg-2. Pie slices carry % → degrees
// (% × 3.6°) in customData for the pie painter. Offline, pure Dart.
// hintText: 'e.g. Math 40, Science 30, English 30'.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

import 'g6_support.dart';

class G6PieSlice {
  final String label;
  final double value;
  final double percent;
  final double degrees;

  const G6PieSlice({
    required this.label,
    required this.value,
    required this.percent,
    required this.degrees,
  });
}

/// G6-10 pie solver: `Math 40, Science 30, English 30` or `40, 30, 30`.
class G6PieEquation extends BaseEquation {
  @override
  final String rawInput;

  String? _error;

  G6PieEquation(this.rawInput);

  List<G6PieSlice>? _slices() {
    final List<String> parts = rawInput
        .split(RegExp(r'[,;\n]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return null;
    }
    final List<Map<String, dynamic>> entries = [];
    for (var i = 0; i < parts.length; i++) {
      final String part = parts[i];
      final RegExpMatch? labeled =
          RegExp(r'^([a-zA-Z][a-zA-Z\s]*?)\s*[:=]?\s*(-?\d+(?:\.\d+)?)$')
              .firstMatch(part);
      if (labeled != null && RegExp(r'[a-zA-Z]').hasMatch(part)) {
        entries.add({
          'label': labeled.group(1)!.trim(),
          'value': double.parse(labeled.group(2)!),
        });
      } else if (RegExp(r'^-?\d+(?:\.\d+)?$').hasMatch(part)) {
        entries.add({
          'label': 'Slice ${String.fromCharCode(65 + i)}',
          'value': double.parse(part),
        });
      } else {
        return null;
      }
    }
    if (entries.any((e) => (e['value'] as double) < 0)) {
      return null;
    }
    final double total =
        entries.fold(0.0, (sum, e) => sum + (e['value'] as double));
    if (total <= 0) {
      return null;
    }
    return [
      for (final e in entries)
        G6PieSlice(
          label: e['label'] as String,
          value: e['value'] as double,
          percent: (e['value'] as double) / total * 100,
          degrees: (e['value'] as double) / total * 360,
        ),
    ];
  }

  @override
  bool validate() {
    final String? empty = FieldValidators.notEmpty(
      rawInput,
      example: 'Math 40, Science 30, English 30',
    );
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (_slices() == null) {
      _error = 'Values must be ≥ 0 with sum > 0 — e.g. Math 40, Science 30.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final List<G6PieSlice>? slices = _slices();
    if (slices == null) {
      return SolveResult.error(
        _error ?? 'Values must be ≥ 0 with sum > 0.',
      );
    }
    final double total = slices.fold(0.0, (s, e) => s + e.value);
    final String answer =
        'Total = ${G6Format.num(total)}; ${slices.map((s) => '${s.label}: ${G6Format.num(s.percent)}% (${G6Format.num(s.degrees)}°)').join(', ')}';
    return SolveResult(
      answer: answer,
      points: slices.map((s) => s.percent).toList(),
      customData: [
        {
          'total': total,
          'slices': [
            for (final s in slices)
              {
                'label': s.label,
                'value': s.value,
                'percent': s.percent,
                'degrees': s.degrees,
              },
          ],
        }
      ],
    );
  }

  @override
  List<StepModel> getSteps() {
    final List<G6PieSlice>? slices = _slices();
    if (slices == null) {
      return [
        StepModel(stepNumber: 1, title: 'Invalid input', explanation: _error ?? 'Values must be ≥ 0 with sum > 0.'),
      ];
    }
    final double total = slices.fold(0.0, (s, e) => s + e.value);
    return [
      StepModel(stepNumber: 1, title: 'Find the total', explanation: 'Total = ${G6Format.num(total)}.'),
      const StepModel(stepNumber: 2, title: 'Percent each slice', explanation: 'value ÷ total × 100%.'),
      const StepModel(stepNumber: 3, title: 'Percent to degrees', explanation: 'degrees = % × 3.6° (360° ÷ 100).'),
      StepModel(stepNumber: 4, title: 'Draw the slices', explanation: '${slices.length} slices in order of size.'),
      StepModel(stepNumber: 5, title: 'Label each slice', explanation: solve().answer),
    ];
  }
}

/// G6-10 probability intro: `3 out of 5`, `3/5`, `P(red) in 3R + 2B`,
/// `favorable=3 total=5`.
class G6ProbabilityEquation extends BaseEquation {
  @override
  final String rawInput;

  String? _error;

  G6ProbabilityEquation(this.rawInput);

  List<int>? _parse() {
    final String t = rawInput.toLowerCase().replaceAll('−', '-');
    final RegExpMatch? named = RegExp(
      r'favorable\s*=\s*(\d+)\s*total\s*=\s*(\d+)',
    ).firstMatch(t);
    if (named != null) {
      return [int.parse(named.group(1)!), int.parse(named.group(2)!)];
    }
    final RegExpMatch? outOf = RegExp(
      r'(\d+)\s*(?:out of|/|:)\s*(\d+)',
    ).firstMatch(t);
    if (outOf != null && !t.contains('=')) {
      // For `3/5` style, first = favorable, second = total.
      // For `P(red) in 3R + 2B`, the plus-form below wins instead.
      if (!t.contains('+')) {
        return [int.parse(outOf.group(1)!), int.parse(outOf.group(2)!)];
      }
    }
    final RegExpMatch? plus =
        RegExp(r'(\d+)\s*\w*\s*\+\s*(\d+)').firstMatch(t);
    if (plus != null && t.contains('p(')) {
      final int fav = int.parse(plus.group(1)!);
      final int rest = int.parse(plus.group(2)!);
      return [fav, fav + rest];
    }
    final RegExpMatch? inForm = RegExp(
      r'in\s*(\d+)\s*\w*\s*\+\s*(\d+)',
    ).firstMatch(t);
    if (inForm != null) {
      final int fav = int.parse(inForm.group(1)!);
      final int rest = int.parse(inForm.group(2)!);
      return [fav, fav + rest];
    }
    return null;
  }

  @override
  bool validate() {
    final String? empty = FieldValidators.notEmpty(
      rawInput,
      example: 'P(red) in 3R + 2B',
    );
    if (empty != null) {
      _error = empty;
      return false;
    }
    final List<int>? p = _parse();
    if (p == null) {
      _error = 'Use 3 out of 5, 3/5, or P(red) in 3R + 2B.';
      return false;
    }
    if (p[1] <= 0) {
      _error = 'Total outcomes must be above zero.';
      return false;
    }
    if (p[0] < 0 || p[0] > p[1]) {
      _error = 'Favorable cannot exceed total.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final List<int>? p = _parse();
    if (p == null) {
      return SolveResult.error(_error ?? 'Use 3 out of 5 or 3/5.');
    }
    if (p[1] <= 0) {
      return SolveResult.error('Total outcomes must be above zero.');
    }
    if (p[0] < 0 || p[0] > p[1]) {
      return SolveResult.error('Favorable cannot exceed total.');
    }
    final int g = G6Math.gcd(p[0], p[1]);
    final int sn = p[0] ~/ g, sd = p[1] ~/ g;
    final double dec = p[0] / p[1];
    return SolveResult(
      answer: 'P = $sn/$sd = ${G6Format.num(dec)} = ${G6Format.num(dec * 100)}%',
      points: [dec],
      customData: [
        {'favorable': p[0], 'total': p[1], 'decimal': dec}
      ],
    );
  }

  @override
  List<StepModel> getSteps() {
    final List<int>? p = _parse();
    if (p == null || p[1] <= 0) {
      return [
        StepModel(stepNumber: 1, title: 'Invalid input', explanation: _error ?? 'Use 3 out of 5.'),
      ];
    }
    final SolveResult r = solve();
    return [
      StepModel(stepNumber: 1, title: 'Count all outcomes', explanation: 'Total = ${p[1]}.'),
      StepModel(stepNumber: 2, title: 'Count favorable', explanation: 'Favorable = ${p[0]}.'),
      StepModel(stepNumber: 3, title: 'Write favorable/total and simplify', explanation: r.answer),
    ];
  }
}
