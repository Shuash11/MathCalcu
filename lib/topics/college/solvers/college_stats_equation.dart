// ─────────────────────────────────────────────────────────────
// COLLEGE STATS — descriptive stats + linear regression + z-test.
// e.g. '4,7,9 stats', 'x:1,2,3 y:2,4,6 regress',
// 'ztest mean=72 mu=70 sd=10 n=25'.
// Offline, pure Dart. Never throws.
// ─────────────────────────────────────────────────────────────

import 'dart:math' as math;

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

/// PH-college stats engine: mean / median / mode / SD + regression + z-test.
class CollegeStatsEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  CollegeStatsEquation(this.rawInput);

  String _norm() => rawInput.replaceAll('−', '-').trim();

  /// Returns [mode, payload].
  List<dynamic>? _parse() {
    final t = _norm();
    final tl = t.toLowerCase();
    if (tl.startsWith('ztest') ||
        tl.startsWith('z-test') ||
        tl.startsWith('z ')) {
      RegExpMatch? numOf(String k) =>
          RegExp('$k\\s*=\\s*(-?\\d+(?:\\.\\d+)?)').firstMatch(tl);
      final mean = numOf('mean') ?? numOf('xbar') ?? numOf('x');
      final mu = numOf('mu') ?? numOf('μ') ?? numOf('null');
      final sd = numOf('sd') ?? numOf('sigma') ?? numOf('s');
      final nM = RegExp(r'n\s*=\s*(\d+)').firstMatch(tl);
      if (mean == null || mu == null || sd == null || nM == null) return null;
      final sdV = double.parse(sd.group(1)!);
      final n = int.parse(nM.group(1)!);
      if (!(sdV > 0) || n < 2 || n > 1000000) return null;
      return [
        'ztest',
        [
          double.parse(mean.group(1)!),
          double.parse(mu.group(1)!),
          sdV,
          n.toDouble()
        ]
      ];
    }
    if (tl.contains('regress') || (tl.contains('x:') && tl.contains('y:'))) {
      final clean =
          tl.replaceAll('regression', ' ').replaceAll('regress', ' ').trim();
      final xm = RegExp(r'x\s*:\s*([-\d.,\s]+?)(?:y\s*:|$)').firstMatch(clean);
      final ym = RegExp(r'y\s*:\s*([-\d.,\s]+?)$').firstMatch(clean);
      if (xm == null || ym == null) return null;
      final xs = _nums(xm.group(1)!);
      final ys = _nums(ym.group(1)!);
      if (xs == null || ys == null || xs.length != ys.length || xs.length < 2) {
        return null;
      }
      if (xs.length > 500) return null;
      return [
        'regress',
        [xs, ys]
      ];
    }
    final nums = _nums(tl
        .replaceAll(RegExp(r'\bstats?\b'), '')
        .replaceAll(RegExp(r'\bdata\b'), ''));
    if (nums == null || nums.length < 2 || nums.length > 500) return null;
    return ['stats', nums];
  }

  static List<double>? _nums(String s) {
    final parts =
        s.split(RegExp(r'[,;\s\n]+')).where((e) => e.isNotEmpty).toList();
    if (parts.length < 2) return null;
    final out = <double>[];
    for (final p in parts) {
      final v = double.tryParse(p.trim());
      if (v == null || !v.isFinite) return null;
      out.add(v);
    }
    return out.length < 2 ? null : out;
  }

  /// Normal CDF via Abramowitz–Stegun erf approximation.
  static double _phi(double z) {
    final t = 1 / (1 + 0.2316419 * z.abs());
    final poly = t *
        (0.319381530 +
            t *
                (-0.356563782 +
                    t * (1.781477937 + t * (-1.821255978 + t * 1.330274429))));
    final pdf = math.exp(-z * z / 2) / math.sqrt(2 * math.pi);
    final tail = pdf * poly;
    return z >= 0 ? 1 - tail : tail;
  }

  static String _fmt(double v, [int digits = 4]) {
    if (!v.isFinite) return v.toString();
    if (v == v.roundToDouble() && v.abs() < 1e12) return v.toInt().toString();
    var s = v.toStringAsFixed(digits);
    s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  @override
  bool validate() {
    final empty = FieldValidators.notEmpty(rawInput, example: '4,7,9 stats');
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (_parse() == null) {
      _error =
          'Use 4,7,9 stats · x:1,2,3 y:2,4,6 regress · ztest mean=72 mu=70 sd=10 n=25.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final p = _parse();
    if (p == null) {
      return SolveResult.error(_error ?? 'Use 4,7,9 stats.');
    }
    switch (p[0] as String) {
      case 'ztest':
        final v = (p[1] as List).cast<double>();
        final z = (v[0] - v[1]) / (v[2] / math.sqrt(v[3]));
        final pVal = 2 * (1 - _phi(z.abs()));
        final reject = pVal < 0.05;
        return SolveResult(
          answer: 'z = ${_fmt(z)} (SE = ${_fmt(v[2] / math.sqrt(v[3]))}), '
              'two-sided p = ${_fmt(pVal)} → ${reject ? 'reject H₀ at α=0.05' : 'fail to reject H₀ at α=0.05'}.',
          points: [z],
          customData: [
            {
              'kind': 'stats-ztest',
              'mean': v[0],
              'mu': v[1],
              'sd': v[2],
              'n': v[3],
              'z': z,
              'p': pVal,
              'reject': reject
            }
          ],
        );
      case 'regress':
        final pair = (p[1] as List).cast<List<double>>();
        final xs = pair[0];
        final ys = pair[1];
        final n = xs.length;
        final mx = xs.fold(0.0, (a, b) => a + b) / n;
        final my = ys.fold(0.0, (a, b) => a + b) / n;
        var sxx = 0.0, sxy = 0.0, syy = 0.0;
        for (var i = 0; i < n; i++) {
          sxx += (xs[i] - mx) * (xs[i] - mx);
          sxy += (xs[i] - mx) * (ys[i] - my);
          syy += (ys[i] - my) * (ys[i] - my);
        }
        if (sxx == 0) {
          return SolveResult.error('x values are constant — slope undefined.');
        }
        final b = sxy / sxx;
        final a = my - b * mx;
        final r = (sxx > 0 && syy > 0) ? sxy / math.sqrt(sxx * syy) : 0.0;
        return SolveResult(
          answer:
              'ŷ = ${_fmt(a)} + ${_fmt(b)}x (r = ${_fmt(r)}, R² = ${_fmt(r * r)}; n=$n).',
          points: List<double>.from(ys),
          customData: [
            {
              'kind': 'stats-regression',
              'slope': b,
              'intercept': a,
              'r': r,
              'r2': r * r,
              'n': n.toDouble(),
              'xs': xs,
              'ys': ys
            }
          ],
        );
      default:
        final xs = (p[1] as List).cast<double>();
        final n = xs.length;
        final sorted = List<double>.from(xs)..sort();
        final sum = xs.fold(0.0, (a, b) => a + b);
        final mean = sum / n;
        final median = n.isOdd
            ? sorted[n ~/ 2]
            : (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2;
        final freq = <double, int>{};
        for (final v in xs) {
          freq[v] = (freq[v] ?? 0) + 1;
        }
        final top = freq.values.fold(0, (a, b) => a > b ? a : b);
        final modes = top > 1
            ? freq.entries
                .where((e) => e.value == top)
                .map((e) => e.key)
                .toList()
            : <double>[];
        var ss = 0.0;
        for (final v in xs) {
          ss += (v - mean) * (v - mean);
        }
        final popSd = math.sqrt(ss / n);
        final sampSd = n > 1 ? math.sqrt(ss / (n - 1)) : 0.0;
        final range = sorted.last - sorted.first;
        final modeStr =
            modes.isEmpty ? 'none (all unique)' : modes.map(_fmt).join(', ');
        return SolveResult(
          answer:
              'n=$n, mean=${_fmt(mean)}, median=${_fmt(median)}, mode=$modeStr, '
              'SD(pop)=${_fmt(popSd)}, SD(sample)=${_fmt(sampSd)}, range=${_fmt(range)} [${_fmt(sorted.first)}…${_fmt(sorted.last)}].',
          points: List<double>.from(xs),
          customData: [
            {
              'kind': 'stats-descriptive',
              'n': n,
              'mean': mean,
              'median': median,
              'modes': modes,
              'popSd': popSd,
              'sampleSd': sampSd,
              'min': sorted.first,
              'max': sorted.last,
              'range': range,
              'sum': sum,
            }
          ],
        );
    }
  }

  @override
  List<StepModel> getSteps() {
    final p = _parse();
    if (p == null) {
      return [
        StepModel(
            stepNumber: 1,
            title: 'Invalid input',
            explanation: _error ?? 'Use 4,7,9 stats.')
      ];
    }
    final r = solve();
    final mode = p[0] as String;
    final mid = switch (mode) {
      'ztest' => 'Standardize: z = (x̄ − μ₀)/(s/√n), then two-sided p.',
      'regress' =>
        'Slope b = Sxy/Sxx, intercept a = ȳ − b·x̄, r from covariance.',
      _ => 'Mean = Σx/n; median = middle of sorted data; SD from deviations.',
    };
    return [
      const StepModel(
          stepNumber: 1,
          title: 'Summarize the data',
          explanation: 'Count n, sum, sort for center + spread.'),
      StepModel(stepNumber: 2, title: 'Apply the formula', explanation: mid),
      StepModel(
          stepNumber: 3,
          title: 'Read the result',
          explanation: r.hasError ? (r.errorMessage ?? '') : r.answer),
    ];
  }
}
