// ─────────────────────────────────────────────────────────────
// M7 PREDICATE LOGIC — quantified statements over a finite domain.
// e.g. 'forall x in {1,2,3}: x > 0', 'exists x in {1,2}: x > 5'.
// Offline, pure Dart. Never throws.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

/// Evaluates ∀/∃ statements with a simple integer comparison predicate.
class M7PredicateEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  M7PredicateEquation(this.rawInput);

  String _norm() => rawInput
      .replaceAll('−', '-')
      .replaceAll('∀', 'forall')
      .replaceAll('∃', 'exists')
      .trim();

  /// Returns [isForall, varName, domain, op, rhs].
  List<dynamic>? _parse() {
    final t = _norm();
    final m = RegExp(
      r'^(forall|for\s*all|exists|exist|∃)\s+([a-z])\s+in\s*\{([^}]*)\}\s*:\s*\2\s*(>=|<=|==|!=|>|<)\s*(-?\d+)\s*$',
      caseSensitive: false,
    ).firstMatch(t);
    if (m == null) return null;
    final q = m.group(1)!.replaceAll(RegExp(r'\s+'), '');
    final isForall = q.toLowerCase().startsWith('for');
    final body = m.group(3)!.trim();
    final domain = <int>[];
    if (body.isNotEmpty) {
      for (final part in body.split(',')) {
        final v = int.tryParse(part.trim());
        if (v == null) return null;
        if (!domain.contains(v)) domain.add(v);
      }
    }
    if (domain.isEmpty) return null;
    return [
      isForall,
      m.group(2)!.toLowerCase(),
      domain,
      m.group(4)!,
      int.parse(m.group(5)!)
    ];
  }

  static bool _test(int x, String op, int rhs) => switch (op) {
        '>' => x > rhs,
        '<' => x < rhs,
        '>=' => x >= rhs,
        '<=' => x <= rhs,
        '==' => x == rhs,
        _ => x != rhs,
      };

  @override
  bool validate() {
    final empty = FieldValidators.notEmpty(rawInput,
        example: 'forall x in {1,2,3}: x > 0');
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (_parse() == null) {
      _error =
          'Use forall/exists x in {…}: x > k — e.g. forall x in {1,2,3}: x > 0.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final p = _parse();
    if (p == null) {
      return SolveResult.error(_error ?? 'Use forall x in {1,2,3}: x > 0.');
    }
    final isForall = p[0] as bool;
    final v = p[1] as String;
    final domain = p[2] as List<int>;
    final op = p[3] as String;
    final rhs = p[4] as int;
    final results = {for (final x in domain) x: _test(x, op, rhs)};
    final truth = isForall
        ? results.values.every((e) => e)
        : results.values.any((e) => e);
    final q = isForall ? '∀$v' : '∃$v';
    final witnesses =
        results.entries.where((e) => e.value).map((e) => e.key).toList();
    final counters =
        results.entries.where((e) => !e.value).map((e) => e.key).toList();
    final detail = isForall
        ? (truth
            ? 'holds for all ${domain.length} values'
            : 'fails at {${counters.join(', ')}}')
        : (truth
            ? 'witnessed by {${witnesses.join(', ')}}'
            : 'no witness in the domain');
    return SolveResult(
      answer:
          '$q ∈ {${domain.join(', ')}}: $v $op $rhs is ${truth ? 'True' : 'False'} ($detail)',
      points: [truth ? 1.0 : 0.0],
      customData: [
        {
          'kind': 'predicate',
          'quantifier': isForall ? 'forall' : 'exists',
          'variable': v,
          'domain': domain,
          'predicate': '$v $op $rhs',
          'value': truth,
          'witnesses': witnesses,
          'counterexamples': counters,
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
            explanation: _error ?? 'Use forall x in {1,2,3}: x > 0.')
      ];
    }
    final r = solve();
    final isForall = p[0] as bool;
    return [
      StepModel(
          stepNumber: 1,
          title: 'Read the quantifier',
          explanation: isForall
              ? '∀ needs every value to pass; one failure kills it.'
              : '∃ needs one passing value (a witness).'),
      const StepModel(
          stepNumber: 2,
          title: 'Test each domain value',
          explanation: 'Substitute every element into the predicate.'),
      StepModel(
          stepNumber: 3,
          title: 'Read the truth value',
          explanation: r.hasError ? (r.errorMessage ?? '') : r.answer),
    ];
  }
}
