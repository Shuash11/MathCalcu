// ─────────────────────────────────────────────────────────────
// M6 MODULAR ARITHMETIC — extends the G6 GCF/LCM number-theory line
// into congruences. e.g. '17 mod 5', '3^4 mod 5', 'inv 3 mod 7',
// '(12 + 30) mod 7'. Offline, pure Dart. Never throws.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';
import 'package:calculus_system/topics/grade6/solvers/g6_support.dart';

/// Modular-arithmetic solver: normalize, add/sub/mul/pow, inverse.
class M6ModularEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  M6ModularEquation(this.rawInput);

  String _norm() => rawInput
      .replaceAll('−', '-')
      .replaceAll('×', '*')
      .replaceAll('modulo', 'mod')
      .trim();

  /// Returns [mode, a, b-or-exp, m].
  List<dynamic>? _parse() {
    final t = _norm();
    var m = RegExp(r'^inv(?:erse)?\s+(-?\d+)\s+mod\s+(-?\d+)\s*$',
            caseSensitive: false)
        .firstMatch(t);
    if (m != null) {
      return ['inv', int.parse(m.group(1)!), 0, int.parse(m.group(2)!)];
    }
    m = RegExp(r'^(-?\d+)\s*\^\s*(-?\d+)\s+mod\s+(-?\d+)\s*$',
            caseSensitive: false)
        .firstMatch(t);
    if (m != null) {
      return [
        'pow',
        int.parse(m.group(1)!),
        int.parse(m.group(2)!),
        int.parse(m.group(3)!),
      ];
    }
    m = RegExp(r'^\(\s*(-?\d+)\s*([+\-*])\s*(-?\d+)\s*\)\s*mod\s+(-?\d+)\s*$',
            caseSensitive: false)
        .firstMatch(t);
    if (m != null) {
      return [
        m.group(2) == '+'
            ? 'add'
            : m.group(2) == '-'
                ? 'sub'
                : 'mul',
        int.parse(m.group(1)!),
        int.parse(m.group(3)!),
        int.parse(m.group(4)!),
      ];
    }
    m = RegExp(r'^(-?\d+)\s+mod\s+(-?\d+)\s*$', caseSensitive: false)
        .firstMatch(t);
    if (m != null) {
      return ['norm', int.parse(m.group(1)!), 0, int.parse(m.group(2)!)];
    }
    return null;
  }

  /// Fast modular power (non-negative exponent).
  static int modPow(int base, int exp, int mod) {
    var b = ((base % mod) + mod) % mod;
    var result = 1 % mod;
    var e = exp;
    while (e > 0) {
      if (e.isOdd) result = (result * b) % mod;
      b = (b * b) % mod;
      e ~/= 2;
    }
    return result;
  }

  /// Extended Euclid: returns [g, x, y] with ax + by = g.
  static List<int> _egcd(int a, int b) {
    if (b == 0) return [a, 1, 0];
    final r = _egcd(b, a % b);
    return [r[0], r[2], r[1] - (a ~/ b) * r[2]];
  }

  /// Multiplicative inverse of [a] mod [m]. Null when gcd ≠ 1.
  static int? modInverse(int a, int m) {
    final mm = m.abs();
    if (mm <= 1) return null;
    final r = _egcd(((a % mm) + mm) % mm, mm);
    if (r[0].abs() != 1) return null;
    return ((r[1] % mm) + mm) % mm;
  }

  @override
  bool validate() {
    final empty = FieldValidators.notEmpty(rawInput, example: '17 mod 5');
    if (empty != null) {
      _error = empty;
      return false;
    }
    final p = _parse();
    if (p == null) {
      _error = 'Use 17 mod 5, 3^4 mod 5, inv 3 mod 7, or (12 + 30) mod 7.';
      return false;
    }
    if ((p[3] as int) <= 1) {
      _error = 'Modulus must be ≥ 2 — e.g. 17 mod 5.';
      return false;
    }
    if (p[0] == 'pow' && (p[2] as int) < 0) {
      _error = 'Exponents must be ≥ 0 — use inv for negative powers.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final p = _parse();
    if (p == null) {
      return SolveResult.error(_error ?? 'Use 17 mod 5.');
    }
    final mode = p[0] as String;
    final a = p[1] as int;
    final b = p[2] as int;
    final m = p[3] as int;
    if (m <= 1) return SolveResult.error('Modulus must be ≥ 2.');
    switch (mode) {
      case 'norm':
        final v = ((a % m) + m) % m;
        return SolveResult(
          answer: '$a ≡ $v (mod $m)',
          points: [v.toDouble()],
          customData: [
            {'kind': 'modular', 'mode': 'norm', 'a': a, 'm': m, 'value': v}
          ],
        );
      case 'add':
      case 'sub':
      case 'mul':
        final raw = mode == 'add'
            ? a + b
            : mode == 'sub'
                ? a - b
                : a * b;
        final v = ((raw % m) + m) % m;
        final sym = mode == 'add'
            ? '+'
            : mode == 'sub'
                ? '−'
                : '×';
        return SolveResult(
          answer: '($a $sym $b) mod $m = $v',
          points: [v.toDouble()],
          customData: [
            {
              'kind': 'modular',
              'mode': mode,
              'a': a,
              'b': b,
              'm': m,
              'value': v
            }
          ],
        );
      case 'pow':
        if (b < 0) {
          return SolveResult.error('Exponents must be ≥ 0.');
        }
        final v = modPow(a, b, m);
        return SolveResult(
          answer: '$a^$b mod $m = $v',
          points: [v.toDouble()],
          customData: [
            {
              'kind': 'modular',
              'mode': 'pow',
              'a': a,
              'exp': b,
              'm': m,
              'value': v
            }
          ],
        );
      case 'inv':
        final v = modInverse(a, m);
        if (v == null) {
          final g = G6Math.gcd(a, m);
          return SolveResult.error('No inverse — gcd($a, $m) = $g ≠ 1.');
        }
        return SolveResult(
          answer: '$a⁻¹ ≡ $v (mod $m)',
          points: [v.toDouble()],
          customData: [
            {'kind': 'modular', 'mode': 'inv', 'a': a, 'm': m, 'value': v}
          ],
        );
    }
    return SolveResult.error('Unknown modular form.');
  }

  @override
  List<StepModel> getSteps() {
    final p = _parse();
    if (p == null) {
      return [
        StepModel(
            stepNumber: 1,
            title: 'Invalid input',
            explanation: _error ?? 'Use 17 mod 5.')
      ];
    }
    final r = solve();
    final mode = p[0] as String;
    final hint = switch (mode) {
      'inv' => 'Inverse exists only when gcd(a, m) = 1 (extended Euclid).',
      'pow' => 'Square-and-multiply: reduce mod m at every step.',
      _ => 'Reduce each operand mod m first, then operate.',
    };
    return [
      StepModel(
          stepNumber: 1,
          title: 'Reduce mod ${p[3]}',
          explanation: 'Bring every number into 0…${(p[3] as int) - 1}.'),
      StepModel(stepNumber: 2, title: 'Operate in the ring', explanation: hint),
      StepModel(
          stepNumber: 3,
          title: 'Read the residue',
          explanation: r.hasError ? (r.errorMessage ?? '') : r.answer),
    ];
  }
}
