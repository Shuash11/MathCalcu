// ─────────────────────────────────────────────────────────────
// M2 SET THEORY — union / intersect / difference / symdiff,
// cardinality, subset check, power-set size. Offline, pure Dart.
// e.g. 'A={1,2,3} B={3,4} UNION'. Never throws.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

/// Set-theory solver over integer/string elements in `{…}` braces.
class M2SetsEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  M2SetsEquation(this.rawInput);

  static final RegExp _braces = RegExp(r'\{([^}]*)\}');

  List<String> _sets() =>
      _braces.allMatches(rawInput).map((m) => m.group(1)!.trim()).toList();

  /// Elements of one `{…}` body, de-duplicated, order-preserved.
  static List<String> elementsOf(String body) {
    if (body.trim().isEmpty) return [];
    final seen = <String>[];
    for (final part in body.split(',')) {
      final e = part.trim();
      if (e.isEmpty) continue;
      if (!seen.contains(e)) seen.add(e);
    }
    return seen;
  }

  String _op() {
    final t = rawInput.toUpperCase();
    if (t.contains('SYM') || t.contains('XOR') || t.contains('△')) {
      return 'symdiff';
    }
    if (t.contains('UNION') || t.contains('∪') || t.contains(' U ')) {
      return 'union';
    }
    if (t.contains('INTERSECT') || t.contains('∩')) return 'intersect';
    if (t.contains('SUBSET') || t.contains('⊆')) return 'subset';
    if (t.contains('CARD') || t.contains('|A|') || t.contains('SIZE')) {
      return 'card';
    }
    if (t.contains('POWER') || t.contains('P(A)') || t.contains('2^')) {
      return 'power';
    }
    if (t.contains('DIFF') ||
        t.contains('\\') ||
        t.contains('MINUS') ||
        t.contains(' − ') ||
        t.contains(' - ')) {
      return 'diff';
    }
    return 'union';
  }

  bool _isBinaryOp() {
    final op = _op();
    return op == 'union' ||
        op == 'intersect' ||
        op == 'diff' ||
        op == 'symdiff' ||
        op == 'subset';
  }

  @override
  bool validate() {
    final empty =
        FieldValidators.notEmpty(rawInput, example: 'A={1,2,3} B={3,4} UNION');
    if (empty != null) {
      _error = empty;
      return false;
    }
    final sets = _sets();
    if (sets.isEmpty) {
      _error = 'Write sets in braces — e.g. A={1,2,3} B={3,4} UNION.';
      return false;
    }
    if (_isBinaryOp() && sets.length < 2) {
      _error = 'Binary ops need two sets — e.g. {1,2} UNION {2,3}.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final sets = _sets();
    if (sets.isEmpty) {
      return SolveResult.error(
          _error ?? 'Write sets in braces — e.g. {1,2,3}.');
    }
    final op = _op();
    final a = elementsOf(sets[0]);
    final b = sets.length > 1 ? elementsOf(sets[1]) : <String>[];
    switch (op) {
      case 'union':
        if (sets.length < 2) {
          return SolveResult.error('UNION needs two sets.');
        }
        final out = [
          ...a,
          for (final e in b)
            if (!a.contains(e)) e
        ];
        return _setResult('A ∪ B = {${out.join(', ')}}', out, 'union');
      case 'intersect':
        if (sets.length < 2) {
          return SolveResult.error('INTERSECT needs two sets.');
        }
        final out = a.where(b.contains).toList();
        return _setResult('A ∩ B = {${out.join(', ')}}', out, 'intersect');
      case 'diff':
        if (sets.length < 2) {
          return SolveResult.error('DIFF needs two sets.');
        }
        final out = a.where((e) => !b.contains(e)).toList();
        return _setResult('A − B = {${out.join(', ')}}', out, 'diff');
      case 'symdiff':
        if (sets.length < 2) {
          return SolveResult.error('SYMDIFF needs two sets.');
        }
        final out = [
          ...a.where((e) => !b.contains(e)),
          ...b.where((e) => !a.contains(e)),
        ];
        return _setResult('A △ B = {${out.join(', ')}}', out, 'symdiff');
      case 'subset':
        if (sets.length < 2) {
          return SolveResult.error('SUBSET needs two sets.');
        }
        final isSub = a.every(b.contains);
        return SolveResult(
          answer: isSub ? 'A ⊆ B is True' : 'A ⊆ B is False',
          points: [isSub ? 1 : 0],
          customData: [
            {'kind': 'sets', 'mode': 'subset', 'value': isSub}
          ],
        );
      case 'card':
        return SolveResult(
          answer: '|A| = ${a.length}',
          points: [a.length.toDouble()],
          customData: [
            {'kind': 'sets', 'mode': 'card', 'value': a.length}
          ],
        );
      case 'power':
        if (a.length > 12) {
          return SolveResult.error('Power set too large — keep |A| ≤ 12.');
        }
        final size = 1 << a.length;
        return SolveResult(
          answer: '|P(A)| = 2^${a.length} = $size',
          points: [size.toDouble()],
          customData: [
            {'kind': 'sets', 'mode': 'power', 'n': a.length, 'value': size}
          ],
        );
    }
    return SolveResult.error('Unknown set operation.');
  }

  SolveResult _setResult(String answer, List<String> out, String mode) {
    return SolveResult(
      answer: out.isEmpty ? '$answer (empty set ∅)' : answer,
      points: [out.length.toDouble()],
      customData: [
        {'kind': 'sets', 'mode': mode, 'elements': out, 'size': out.length}
      ],
    );
  }

  @override
  List<StepModel> getSteps() {
    final sets = _sets();
    if (sets.isEmpty) {
      return [
        StepModel(
            stepNumber: 1,
            title: 'Invalid input',
            explanation: _error ?? 'Use {1,2,3}.')
      ];
    }
    final r = solve();
    final op = _op();
    final label = switch (op) {
      'union' => 'Union: every element in A or B (once each).',
      'intersect' => 'Intersect: only elements in both A and B.',
      'diff' => 'Difference: elements in A but not in B.',
      'symdiff' => 'Symmetric difference: in exactly one set.',
      'subset' => 'Subset: every element of A must sit inside B.',
      'card' => 'Cardinality: count distinct elements.',
      _ => 'Power set: 2^n subsets for n elements.',
    };
    return [
      StepModel(
          stepNumber: 1,
          title: 'List the elements',
          explanation: 'A = {${elementsOf(sets[0]).join(', ')}}'
              '${sets.length > 1 ? ', B = {${elementsOf(sets[1]).join(', ')}}' : ''}.'),
      StepModel(
          stepNumber: 2, title: 'Apply the operation', explanation: label),
      StepModel(
          stepNumber: 3,
          title: 'Read the result',
          explanation: r.hasError ? (r.errorMessage ?? '') : r.answer),
    ];
  }
}
