// ─────────────────────────────────────────────────────────────
// M10 ALGEBRAIC STRUCTURES — (Z_n, +/×) group / ring / field checks.
// e.g. 'Z5 + group', 'Z4 * group', 'Z7 field'.
// Offline, pure Dart. Never throws.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

/// Finite-structure classifier over Z_n.
class M10AlgebraicStructuresEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  M10AlgebraicStructuresEquation(this.rawInput);

  /// Returns [n, op, query].
  List<dynamic>? _parse() {
    final t = rawInput
        .replaceAll('−', '-')
        .replaceAll('×', '*')
        .replaceAll('·', '*')
        .toLowerCase()
        .trim();
    final m = RegExp(
      r'^(?:z|zn|mod)?\s*(\d+)\s*([+*x])?\s*(group|ring|field|units)?\s*$',
    ).firstMatch(t);
    if (m == null) return null;
    final n = int.tryParse(m.group(1)!);
    if (n == null || n < 1) return null;
    var op = m.group(2);
    final query = (m.group(3) ?? 'group').trim();
    if (op == 'x') op = '*';
    op ??= '+';
    return [n, op, query.isEmpty ? 'group' : query];
  }

  static bool _isPrime(int n) {
    if (n < 2) return false;
    for (var i = 2; i * i <= n; i++) {
      if (n % i == 0) return false;
    }
    return true;
  }

  static int _gcd(int a, int b) => b == 0 ? a.abs() : _gcd(b, a % b);

  @override
  bool validate() {
    final empty = FieldValidators.notEmpty(rawInput, example: 'Z5 + group');
    if (empty != null) {
      _error = empty;
      return false;
    }
    final p = _parse();
    if (p == null) {
      _error = 'Use Zn +/* group|ring|field — e.g. Z5 + group.';
      return false;
    }
    if ((p[0] as int) > 500) {
      _error = 'Keep n ≤ 500 — e.g. Z7 field.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final p = _parse();
    if (p == null) {
      return SolveResult.error(_error ?? 'Use Z5 + group.');
    }
    final n = p[0] as int;
    final op = p[1] as String;
    final query = p[2] as String;
    if (n > 500) return SolveResult.error('Keep n ≤ 500.');
    final prime = _isPrime(n);
    final units =
        List<int>.generate(n, (i) => i).where((a) => _gcd(a, n) == 1).length;

    String answer;
    bool holds;
    switch (query) {
      case 'ring':
        holds = true;
        answer =
            '(Z$n, +, ×) is a commutative ring${prime ? '; n prime so it is a field' : ''}.';
      case 'field':
        holds = prime;
        answer = holds
            ? '(Z$n, +, ×) is a field (n prime: every nonzero element has an inverse).'
            : '(Z$n, +, ×) is NOT a field (n composite: zero divisors exist).';
      case 'units':
        answer = 'Z$n has $units units (φ($n) = $units).';
        holds = true;
      default:
        if (op == '+') {
          holds = true;
          answer = '(Z$n, +) is an abelian group of order $n '
              '(identity 0, inverse of a is ${n == 1 ? '0' : 'n−a'}).';
        } else {
          if (n == 1) {
            holds = true;
            answer = '(Z1, ×) is the trivial group.';
          } else {
            holds = false;
            answer = '(Z$n, ×) is NOT a group (0 has no inverse); '
                'it is a monoid, and its $units units form an abelian group.';
          }
        }
    }
    return SolveResult(
      answer: answer,
      points: [holds ? 1.0 : 0.0],
      customData: [
        {
          'kind': 'algebraic-structure',
          'n': n,
          'op': op,
          'query': query,
          'holds': holds,
          'prime': prime,
          'units': units,
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
            explanation: _error ?? 'Use Z5 + group.')
      ];
    }
    final r = solve();
    return [
      StepModel(
          stepNumber: 1,
          title: 'Closure + identity',
          explanation: p[1] == '+'
              ? 'a+b mod ${p[0]} stays in range; 0 is the identity.'
              : 'a×b mod ${p[0]} stays in range; 1 is the identity.'),
      const StepModel(
          stepNumber: 2,
          title: 'Inverses + commutativity',
          explanation:
              'Every a needs b with a⋆b = e; check commutativity too.'),
      StepModel(
          stepNumber: 3,
          title: 'Decide',
          explanation: r.hasError ? (r.errorMessage ?? '') : r.answer),
    ];
  }
}
