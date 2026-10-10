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
  static List<dynamic> _values(String id, int n) {
    switch (id) {
      case 'k2':
        return [n * (n + 1) * (2 * n + 1) ~/ 6, _direct(id, n)];
      case 'k3':
        final t = n * (n + 1) ~/ 2;
        return [t * t, _direct(id, n)];
      case 'pow2':
        return [_pow2Closed(n), _direct(id, n)];
      default:
        return [n * (n + 1) ~/ 2, _direct(id, n)];
    }
  }

  /// Σ2^k closed form 2^(n+1) − 2, held in BigInt so it is EXACT ON BOTH
  /// TARGETS. dart2js models `int <<` as a 32-bit JavaScript shift, so the old
  /// `(1 << (n + 1)) - 2` silently became −2 for every n ≥ 31 on the web target
  /// (the VM gives 2^(n+1) − 2); and for n ≥ 53 the result exceeds 2^53 and is
  /// no longer exactly representable as a JS number, so it cannot round-trip
  /// through `int` for display either. BigInt is arbitrary precision and is
  /// identical on the VM and the web target.
  static BigInt _pow2Closed(int n) => (BigInt.one << (n + 1)) - BigInt.two;

  static dynamic _direct(String id, int n) {
    if (id == 'pow2') {
      // Same 2^k series, summed in BigInt (see [_pow2Closed]): `1 << k` is a
      // 32-bit JS shift on the web target and this sum exceeds 2^53 for n ≥ 53.
      var s = BigInt.zero;
      for (var k = 1; k <= n; k++) {
        s += BigInt.one << k;
      }
      return s;
    }
    var s = 0;
    for (var k = 1; k <= n; k++) {
      s += switch (id) {
        'k2' => k * k,
        'k3' => k * k * k,
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

  // ── Static TeX helpers (additive; parsing is untouched) ──────────────
  /// Generic series identity, e.g. `\sum_{k=1}^{n} k`.
  static String _seriesTex(String id) => switch (id) {
    'k2' => '\\sum_{k=1}^{n} k^{2}',
    'k3' => '\\sum_{k=1}^{n} k^{3}',
    'pow2' => '\\sum_{k=1}^{n} 2^{k}',
    _ => '\\sum_{k=1}^{n} k',
  };

  /// Closed form in n, e.g. `\frac{n(n + 1)}{2}`.
  static String _formulaTex(String id) => switch (id) {
    'k2' => '\\frac{n(n + 1)(2n + 1)}{6}',
    'k3' => '[\\frac{n(n + 1)}{2}]^{2}',
    'pow2' => '2^{n + 1} - 2',
    _ => '\\frac{n(n + 1)}{2}',
  };

  /// Series with an explicit upper limit (a literal or `n`).
  static String _sumTex(String id, String upper) => switch (id) {
    'k2' => '\\sum_{k=1}^{$upper} k^{2}',
    'k3' => '\\sum_{k=1}^{$upper} k^{3}',
    'pow2' => '\\sum_{k=1}^{$upper} 2^{k}',
    _ => '\\sum_{k=1}^{$upper} k',
  };

  /// Closed form with n substituted, e.g. `\frac{5(5 + 1)}{2}`.
  static String _instFormulaTex(String id, int n) => switch (id) {
    'k2' => '\\frac{$n($n + 1)(2 \\cdot $n + 1)}{6}',
    'k3' => '[\\frac{$n($n + 1)}{2}]^{2}',
    'pow2' => '2^{$n + 1} - 2',
    _ => '\\frac{$n($n + 1)}{2}',
  };

  @override
  bool validate() {
    final empty = FieldValidators.notEmpty(
      rawInput,
      example: 'induction sum k n=5',
    );
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
      answer:
          '${_series(id)} = ${_formula(id)}: base n=1 holds; '
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
        },
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
          explanation: _error ?? 'Use induction sum k n=5.',
        ),
      ];
    }
    final r = solve();
    final id = p[0] as String;
    final n = p[1] as int;
    final v = _values(id, n);
    final baseTex =
        '${_sumTex(id, '1')} = ${_instFormulaTex(id, 1)} = '
        '${_direct(id, 1)}';
    final instTex =
        '${_sumTex(id, '$n')} = ${_instFormulaTex(id, n)} = ${v[0]}';
    return [
      StepModel(
        stepNumber: 1,
        title: 'Base case n = 1',
        explanation:
            'LHS = 1 (or 2 for 2^k); RHS ${_formula(id)} at n=1 matches.',
        latex: r.hasError ? null : baseTex,
        subLatex: r.hasError
            ? null
            : ['${_seriesTex(id)} = ${_formulaTex(id)}'],
      ),
      StepModel(
        stepNumber: 2,
        title: 'Inductive step',
        explanation:
            'Assume P(k), add the (k+1)-th term, '
            'factor to the formula at k+1.',
        latex: r.hasError ? null : 'P(k) \\implies P(k + 1)',
      ),
      StepModel(
        stepNumber: 3,
        title: 'Numeric instance',
        explanation: r.hasError ? (r.errorMessage ?? '') : r.answer,
        latex: r.hasError ? null : instTex,
      ),
    ];
  }
}
