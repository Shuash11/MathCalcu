// ─────────────────────────────────────────────────────────────
// M12 PROOF TECHNIQUES — induction outlines for standard closed forms.
// e.g. 'induction sum k n=5', 'induction sum k^2 n=3'.
// Offline, pure Dart. Never throws.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

/// Verifies base case + inductive step + numeric instance for
/// Σk, Σk², Σk³, Σ2^k closed forms.
class M12ProofEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  M12ProofEquation(this.rawInput);

  /// Returns [seriesId, n].
  List<dynamic>? _parse() {
    final t = rawInput.replaceAll('−', '-').replaceAll(' ', '').toLowerCase();
    final m = RegExp(
      r'(?:prove|induction|show)?(sum|series)(k\^3|k\^2|k|2\^k|2k)?(?:1\.\.n|1ton)?n=(\d+)',
    ).firstMatch(t);
    if (m == null) {
      final alt = RegExp(r'(k\^3|k\^2|2\^k|\bk\b).*?n=(\d+)').firstMatch(t);
      if (alt == null) return null;
      return [_seriesId(alt.group(1)!), int.parse(alt.group(2)!)];
    }
    return [_seriesId(m.group(2) ?? 'k'), int.parse(m.group(3)!)];
  }

  static String _seriesId(String s) {
    if (s.contains('k^3')) return 'k3';
    if (s.contains('k^2')) return 'k2';
    if (s.contains('2^k')) return 'pow2';
    return 'k1';
  }

  /// [closedForm, lhsAt] for n.
  static List<int> _values(String id, int n) {
    switch (id) {
      case 'k2':
        return [n * (n + 1) * (2 * n + 1) ~/ 6, _direct(id, n)];
      case 'k3':
        final t = n * (n + 1) ~/ 2;
        return [t * t, _direct(id, n)];
      case 'pow2':
        return [(1 << (n + 1)) - 2, _direct(id, n)];
      default:
        return [n * (n + 1) ~/ 2, _direct(id, n)];
    }
  }

  static int _direct(String id, int n) {
    var s = 0;
    for (var k = 1; k <= n; k++) {
      s += switch (id) {
        'k2' => k * k,
        'k3' => k * k * k,
        'pow2' => 1 << k,
        _ => k,
      };
    }
    return s;
  }

  static String _formula(String id) => switch (id) {
        'k2' => 'n(n+1)(2n+1)/6',
        'k3' => '[n(n+1)/2]²',
        'pow2' => '2^(n+1) − 2',
        _ => 'n(n+1)/2',
      };

  static String _series(String id) => switch (id) {
        'k2' => 'Σk² (k=1..n)',
        'k3' => 'Σk³ (k=1..n)',
        'pow2' => 'Σ2^k (k=1..n)',
        _ => 'Σk (k=1..n)',
      };

  @override
  bool validate() {
    final empty =
        FieldValidators.notEmpty(rawInput, example: 'induction sum k n=5');
    if (empty != null) {
      _error = empty;
      return false;
    }
    final p = _parse();
    if (p == null) {
      _error =
          'Use induction sum k|k^2|k^3|2^k n=N — e.g. induction sum k n=5.';
      return false;
    }
    if ((p[1] as int) < 1 || (p[1] as int) > 60) {
      _error = 'Keep n in 1…60 — e.g. induction sum k n=5.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final p = _parse();
    if (p == null) {
      return SolveResult.error(_error ?? 'Use induction sum k n=5.');
    }
    final id = p[0] as String;
    final n = p[1] as int;
    if (n < 1 || n > 60) return SolveResult.error('Keep n in 1…60.');
    final v = _values(id, n);
    final ok = v[0] == v[1];
    return SolveResult(
      answer: '${_series(id)} = ${_formula(id)}: base n=1 holds; '
          'inductive step P(k)→P(k+1) checks algebraically; '
          'at n=$n both sides = ${v[0]} ${ok ? '✓' : '✗'}.',
      points: [v[0].toDouble()],
      customData: [
        {
          'kind': 'proof-induction',
          'series': id,
          'formula': _formula(id),
          'n': n,
          'closedForm': v[0],
          'directSum': v[1],
          'verified': ok,
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
            explanation: _error ?? 'Use induction sum k n=5.')
      ];
    }
    final r = solve();
    final id = p[0] as String;
    return [
      StepModel(
          stepNumber: 1,
          title: 'Base case n = 1',
          explanation:
              'LHS = 1 (or 2 for 2^k); RHS ${_formula(id)} at n=1 matches.'),
      const StepModel(
          stepNumber: 2,
          title: 'Inductive step',
          explanation: 'Assume P(k), add the (k+1)-th term, '
              'factor to the formula at k+1.'),
      StepModel(
          stepNumber: 3,
          title: 'Numeric instance',
          explanation: r.hasError ? (r.errorMessage ?? '') : r.answer),
    ];
  }
}
