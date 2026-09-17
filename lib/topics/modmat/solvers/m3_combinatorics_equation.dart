// ─────────────────────────────────────────────────────────────
// M3 COMBINATORICS — nPr / nCr / factorial. Kills the
// g10-combinatorics stub. Offline, pure Dart. Never throws.
// e.g. 'C(5,2)', 'P(5,2)', '5!', 'nPr 10 3'.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';
import 'package:calculus_system/topics/grade6/solvers/g6_support.dart';

/// Counting solver: permutations, combinations, factorials.
class M3CombinatoricsEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  M3CombinatoricsEquation(this.rawInput);

  String _norm() => rawInput
      .replaceAll('−', '-')
      .replaceAll('×', '*')
      .replaceAll(' ', '')
      .toLowerCase();

  /// Returns [mode, n, r-or-null].
  List<dynamic>? _parse() {
    final t = _norm();
    var m = RegExp(r'^(\d+)!$').firstMatch(t);
    if (m != null) return ['fact', int.parse(m.group(1)!), null];
    m = RegExp(r'^fact(?:orial)?\(?(\d+)\)?$').firstMatch(t);
    if (m != null) return ['fact', int.parse(m.group(1)!), null];
    m = RegExp(r'^[cn]\((\d+),(\d+)\)$').firstMatch(t);
    if (m != null) {
      return ['nCr', int.parse(m.group(1)!), int.parse(m.group(2)!)];
    }
    m = RegExp(r'^p\((\d+),(\d+)\)$').firstMatch(t);
    if (m != null) {
      return ['nPr', int.parse(m.group(1)!), int.parse(m.group(2)!)];
    }
    m = RegExp(r'^(npr|perm|permutation)\(?(\d+)[,;](\d+)\)?$').firstMatch(t);
    if (m != null) {
      return ['nPr', int.parse(m.group(2)!), int.parse(m.group(3)!)];
    }
    m = RegExp(r'^(ncr|comb|combination)\(?(\d+)[,;](\d+)\)?$').firstMatch(t);
    if (m != null) {
      return ['nCr', int.parse(m.group(2)!), int.parse(m.group(3)!)];
    }
    return null;
  }

  /// n! with overflow guard (20! fits in 64-bit).
  static int factorial(int n) {
    var r = 1;
    for (var i = 2; i <= n; i++) {
      r *= i;
    }
    return r;
  }

  /// nPr = n! / (n−r)! computed multiplicatively.
  static int perm(int n, int r) {
    var out = 1;
    for (var i = 0; i < r; i++) {
      out *= (n - i);
    }
    return out;
  }

  /// nCr via the multiplicative recurrence (exact division each step).
  static int comb(int n, int r) {
    if (r > n - r) r = n - r;
    var out = 1;
    for (var i = 1; i <= r; i++) {
      out = out * (n - r + i) ~/ i;
    }
    return out;
  }

  @override
  bool validate() {
    final empty = FieldValidators.notEmpty(rawInput, example: 'C(5,2)');
    if (empty != null) {
      _error = empty;
      return false;
    }
    final p = _parse();
    if (p == null) {
      _error = 'Use C(5,2), P(5,2), or 5! — e.g. nCr 10 3.';
      return false;
    }
    final n = p[1] as int;
    final r = p[2] as int?;
    if (n < 0 || n > 100) {
      _error = 'Keep n in 0…100 — e.g. C(10,3).';
      return false;
    }
    if (p[0] == 'fact' && n > 20) {
      _error = 'Factorials cap at 20! (64-bit) — try C/P instead.';
      return false;
    }
    if (r != null && (r < 0 || r > n)) {
      _error = 'Need 0 ≤ r ≤ n — e.g. C(5,2).';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final p = _parse();
    if (p == null) {
      return SolveResult.error(_error ?? 'Use C(5,2), P(5,2), or 5!.');
    }
    final mode = p[0] as String;
    final n = p[1] as int;
    final r = p[2] as int?;
    if (n < 0 || n > 100) {
      return SolveResult.error('Keep n in 0…100.');
    }
    if (mode == 'fact') {
      if (n > 20) return SolveResult.error('Factorials cap at 20!.');
      final v = factorial(n);
      return SolveResult(
        answer: '$n! = ${G6Format.num(v.toDouble())}',
        points: [v.toDouble()],
        customData: [
          {'kind': 'combinatorics', 'mode': 'fact', 'n': n, 'value': v}
        ],
      );
    }
    if (r == null || r < 0 || r > n) {
      return SolveResult.error('Need 0 ≤ r ≤ n.');
    }
    final v = mode == 'nPr' ? perm(n, r) : comb(n, r);
    final sym = mode == 'nPr' ? 'P($n,$r)' : 'C($n,$r)';
    return SolveResult(
      answer: '$sym = $v',
      points: [v.toDouble()],
      customData: [
        {'kind': 'combinatorics', 'mode': mode, 'n': n, 'r': r, 'value': v}
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
            explanation: _error ?? 'Use C(5,2).')
      ];
    }
    final r = solve();
    final mode = p[0] as String;
    final formula = switch (mode) {
      'fact' => 'n! = 1 × 2 × … × n.',
      'nPr' => 'nPr = n!/(n−r)! — order matters.',
      _ => 'nCr = n!/(r!(n−r)!) — order does not matter.',
    };
    return [
      StepModel(
          stepNumber: 1,
          title: mode == 'fact'
              ? 'Factorial form'
              : mode == 'nPr'
                  ? 'Permutation form'
                  : 'Combination form',
          explanation: formula),
      const StepModel(
          stepNumber: 2,
          title: 'Check 0 ≤ r ≤ n',
          explanation: 'r beyond n has no meaning — reject it.'),
      StepModel(
          stepNumber: 3,
          title: 'Compute',
          explanation: r.hasError ? (r.errorMessage ?? '') : r.answer),
    ];
  }
}
