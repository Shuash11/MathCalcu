// ─────────────────────────────────────────────────────────────
// M1 PROPOSITIONAL LOGIC — truth tables for p, q (, r).
// e.g. 'p AND q', 'p -> q', '~(p OR q) <=> ~p AND ~q'.
// Offline, pure Dart. Never throws.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

/// Propositional-logic solver: builds the truth table, then classifies
/// the formula as tautology / contradiction / contingency.
class M1PropositionalEquation extends BaseEquation {
  @override
  final String rawInput;
  String? _error;

  M1PropositionalEquation(this.rawInput);

  String _norm() {
    var t = rawInput
        .replaceAll('−', '-')
        .replaceAll('∧', '&')
        .replaceAll('∨', '|')
        .replaceAll('¬', '~')
        .replaceAll('→', '->')
        .replaceAll('↔', '<->')
        .trim();
    // Word operators to symbols (case-insensitive).
    t = t.replaceAll(RegExp(r'\bAND\b', caseSensitive: false), '&');
    t = t.replaceAll(RegExp(r'\bOR\b', caseSensitive: false), '|');
    t = t.replaceAll(RegExp(r'\bNOT\b', caseSensitive: false), '~');
    t = t.replaceAll(RegExp(r'\bXOR\b', caseSensitive: false), '^');
    t = t.replaceAll('=>', '->');
    t = t.replaceAll('==>', '->');
    t = t.replaceAll('<=>', '<->');
    t = t.replaceAll('<-->', '<->');
    return t.replaceAll(' ', '');
  }

  /// Variables used (p, q, r only), in fixed order.
  List<String> _vars(String t) {
    final found = <String>[];
    for (final v in ['p', 'q', 'r']) {
      if (RegExp(v, caseSensitive: false).hasMatch(t)) found.add(v);
    }
    return found;
  }

  bool _validChars(String t) => RegExp(r'^[pqrx01~&|^()<>-]+$').hasMatch(t);

  _Parser _parser(String t, Map<String, bool> env) => _Parser(t, env);

  List<Map<String, dynamic>>? _table() {
    final t = _norm();
    if (t.isEmpty || !_validChars(t)) return null;
    final vars = _vars(t);
    if (vars.isEmpty) return null;
    if (vars.length > 3) return null;
    final rows = <Map<String, dynamic>>[];
    final n = 1 << vars.length;
    for (var i = 0; i < n; i++) {
      final env = <String, bool>{};
      for (var k = 0; k < vars.length; k++) {
        env[vars[k]] = ((n - 1 - i) >> (vars.length - 1 - k) & 1) == 1;
      }
      bool value;
      try {
        value = _parser(t, env).parse();
      } catch (_) {
        return null;
      }
      rows.add({'env': Map<String, bool>.from(env), 'value': value});
    }
    return rows;
  }

  @override
  bool validate() {
    final empty = FieldValidators.notEmpty(rawInput, example: 'p -> q');
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (_table() == null) {
      _error = 'Use p, q (, r) with AND OR NOT -> <-> — e.g. p -> q.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final rows = _table();
    if (rows == null) {
      return SolveResult.error(_error ?? 'Use p, q with AND OR NOT -> <->.');
    }
    final vals = rows.map((r) => r['value'] as bool).toList();
    final allTrue = vals.every((v) => v);
    final allFalse = vals.every((v) => !v);
    final kind = allTrue
        ? 'tautology'
        : allFalse
            ? 'contradiction'
            : 'contingency';
    final trueCount = vals.where((v) => v).length;
    return SolveResult(
      answer: '$kind (true in $trueCount of ${vals.length} rows)',
      points: vals.map((v) => v ? 1.0 : 0.0).toList(),
      customData: [
        {
          'kind': 'truth-table',
          'classification': kind,
          'rows': rows
              .map((r) => {
                    'env': (r['env'] as Map<String, bool>)
                        .map((k, v) => MapEntry(k, v ? 'T' : 'F')),
                    'value': (r['value'] as bool) ? 'T' : 'F',
                  })
              .toList(),
        }
      ],
    );
  }

  @override
  List<StepModel> getSteps() {
    final rows = _table();
    if (rows == null) {
      return [
        StepModel(
            stepNumber: 1,
            title: 'Invalid input',
            explanation: _error ?? 'Use p -> q.')
      ];
    }
    final r = solve();
    final vars = _vars(_norm());
    return [
      StepModel(
          stepNumber: 1,
          title: 'List the variables',
          explanation: 'Variables: ${vars.join(', ')} '
              '(${rows.length} rows).'),
      const StepModel(
          stepNumber: 2,
          title: 'Evaluate each row',
          explanation: '~ binds tightest, then AND, OR, ->, <->.'),
      StepModel(stepNumber: 3, title: 'Read the column', explanation: r.answer),
      const StepModel(
          stepNumber: 4,
          title: 'Classify',
          explanation: 'All T = tautology, all F = contradiction, '
              'mixed = contingency.'),
    ];
  }
}

/// Recursive-descent parser over: <-> -> | ^ & ~ atoms (p/q/r/0/1/parens).
class _Parser {
  final String t;
  final Map<String, bool> env;
  int pos = 0;

  _Parser(this.t, this.env);

  bool parse() {
    final v = _parseIff();
    if (pos != t.length) throw const FormatException('trailing input');
    return v;
  }

  bool _parseIff() {
    var left = _parseImp();
    while (_eat('<->')) {
      final right = _parseImp();
      left = left == right;
    }
    return left;
  }

  bool _parseImp() {
    var left = _parseOr();
    while (_eat('->')) {
      final right = _parseOr();
      left = !left || right;
    }
    return left;
  }

  bool _parseOr() {
    var left = _parseXor();
    while (_eat('|')) {
      final right = _parseXor();
      left = left || right;
    }
    return left;
  }

  bool _parseXor() {
    var left = _parseAnd();
    while (_eat('^')) {
      final right = _parseAnd();
      left = left != right;
    }
    return left;
  }

  bool _parseAnd() {
    var left = _parseNot();
    while (_eat('&')) {
      final right = _parseNot();
      left = left && right;
    }
    return left;
  }

  bool _parseNot() {
    if (_eat('~') || _eat('!')) return !_parseNot();
    return _parseAtom();
  }

  bool _parseAtom() {
    if (_eat('(')) {
      final v = _parseIff();
      if (!_eat(')')) throw const FormatException('missing )');
      return v;
    }
    if (pos >= t.length) throw const FormatException('empty');
    final c = t[pos].toLowerCase();
    if (c == 'p' || c == 'q' || c == 'r' || c == 'x') {
      pos++;
      return env[c == 'x' ? 'p' : c] ?? false;
    }
    if (c == '1') {
      pos++;
      return true;
    }
    if (c == '0') {
      pos++;
      return false;
    }
    if (c == 't') {
      pos++;
      return true;
    }
    if (c == 'f') {
      pos++;
      return false;
    }
    throw const FormatException('bad atom');
  }

  bool _eat(String s) {
    if (t.startsWith(s, pos)) {
      pos += s.length;
      return true;
    }
    return false;
  }
}
