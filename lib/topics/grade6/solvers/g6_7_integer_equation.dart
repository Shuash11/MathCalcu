// ─────────────────────────────────────────────────────────────
// G6-7 INTEGERS — signed add/sub/mul/div, comparisons + number-line
// data for the graph layer (points + jumps in customData).
// DepEd M6NS-IIIb-150. Offline, pure Dart.
// hintText: 'e.g. -5 + 8'.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

import 'g6_support.dart';

enum _IntKind { arithmetic, compare }

class _IntParsed {
  final _IntKind kind;
  final int a;
  final int b;
  final String op;

  const _IntParsed({
    required this.kind,
    required this.a,
    required this.b,
    required this.op,
  });
}

/// G6-7 solver: `-5 + 8`, `7 - 12`, `-3 × -4`, `Compare -3 < 2`.
class G6IntegerEquation extends BaseEquation {
  @override
  final String rawInput;

  String? _error;

  G6IntegerEquation(this.rawInput);

  static final RegExp _arith =
      RegExp(r'^\s*(-?\d+)\s*([+\-×÷*/])\s*(-?\d+)\s*$');
  static final RegExp _compare = RegExp(
    r'^\s*(?:compare\s+)?(-?\d+)\s*(<=|>=|≤|≥|<|>|=)\s*(-?\d+)\s*$',
  );

  String _normalized() {
    return rawInput
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll('≤', '<=')
        .replaceAll('≥', '>=');
  }

  _IntParsed? _parse() {
    final String t = _normalized().toLowerCase();
    final RegExpMatch? cmp = _compare.firstMatch(t);
    if (cmp != null &&
        (t.contains(RegExp(r'<=|>=|<|>|=')) || t.startsWith('compare'))) {
      // Distinguish `-5 + 8` (arithmetic) from comparisons: arithmetic
      // ops bind first when the operator is + - * / without compare word.
      final String op = cmp.group(2)!;
      if ((op == '<' || op == '>' || op.contains('=')) &&
          (t.startsWith('compare') || RegExp(r'[<>=]').hasMatch(t))) {
        return _IntParsed(
          kind: _IntKind.compare,
          a: int.parse(cmp.group(1)!),
          b: int.parse(cmp.group(3)!),
          op: op,
        );
      }
    }
    final RegExpMatch? arith = _arith.firstMatch(t);
    if (arith != null) {
      return _IntParsed(
        kind: _IntKind.arithmetic,
        a: int.parse(arith.group(1)!),
        b: int.parse(arith.group(3)!),
        op: arith.group(2)!,
      );
    }
    return null;
  }

  Map<String, dynamic> _numberLine(int a, int anchor) {
    final int lo = a < anchor ? a : anchor;
    final int hi = a > anchor ? a : anchor;
    return {
      'a': a,
      'result': anchor,
      'min': lo - 2,
      'max': hi + 2,
      'jumps': [
        {'from': a, 'to': anchor},
      ],
    };
  }

  @override
  bool validate() {
    final String? empty = FieldValidators.notEmpty(
      rawInput,
      example: '-5 + 8',
    );
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (rawInput.contains('.')) {
      _error = 'Integers only — no decimals. Try G6-2 decimals.';
      return false;
    }
    if (_parse() == null) {
      _error = 'Use integers with + - × ÷ or < > = — e.g. -5 + 8.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final _IntParsed? p = _parse();
    if (p == null) {
      return SolveResult.error(
        _error ?? 'Use integers — e.g. -5 + 8.',
      );
    }
    if (p.kind == _IntKind.compare) {
      late final bool holds;
      late final String symbol;
      if (p.op == '<') {
        holds = p.a < p.b;
        symbol = '<';
      } else if (p.op == '>') {
        holds = p.a > p.b;
        symbol = '>';
      } else if (p.op == '<=') {
        holds = p.a <= p.b;
        symbol = '≤';
      } else if (p.op == '>=') {
        holds = p.a >= p.b;
        symbol = '≥';
      } else {
        holds = p.a == p.b;
        symbol = '=';
      }
      final String verdict = holds ? 'True' : 'False';
      return SolveResult(
        answer: '${p.a} $symbol ${p.b} is $verdict',
        points: [p.a.toDouble(), p.b.toDouble()],
        customData: [_numberLine(p.a, p.b)],
      );
    }
    if ((p.op == '/' || p.op == '*') && p.op == '/' && p.b == 0) {
      return SolveResult.error('Cannot divide by zero.');
    }
    late final int value;
    late final String opWord;
    if (p.op == '+') {
      value = p.a + p.b;
      opWord = '+';
    } else if (p.op == '-') {
      value = p.a - p.b;
      opWord = '−';
    } else if (p.op == '*') {
      value = p.a * p.b;
      opWord = '×';
    } else {
      if (p.b == 0) {
        return SolveResult.error('Cannot divide by zero.');
      }
      if (p.a % p.b != 0) {
        final double q = p.a / p.b;
        return SolveResult(
          answer: G6Format.num(q),
          points: [p.a.toDouble(), q],
          customData: [_numberLine(p.a, q.round())],
        );
      }
      value = p.a ~/ p.b;
      opWord = '÷';
    }
    return SolveResult(
      answer: '${p.a} $opWord ${p.b} = $value',
      points: [p.a.toDouble(), value.toDouble()],
      customData: [_numberLine(p.a, value)],
    );
  }

  @override
  List<StepModel> getSteps() {
    final _IntParsed? p = _parse();
    if (p == null) {
      return [
        StepModel(
          stepNumber: 1,
          title: 'Invalid input',
          explanation: _error ?? 'Use integers — e.g. -5 + 8.',
        ),
      ];
    }
    if (p.kind == _IntKind.compare) {
      final SolveResult r = solve();
      return [
        StepModel(
          stepNumber: 1,
          title: 'Locate on the number line',
          explanation: 'Mark ${p.a} and ${p.b} on the line.',
        ),
        const StepModel(
          stepNumber: 2,
          title: 'Left means smaller',
          explanation: 'Numbers to the left are smaller; right are larger.',
        ),
        StepModel(
          stepNumber: 3,
          title: 'Count the steps',
          explanation: 'Distance between them is ${(p.a - p.b).abs()} steps.',
        ),
        StepModel(
          stepNumber: 4,
          title: 'Apply the sign rule',
          explanation: '${r.answer}.',
        ),
      ];
    }
    final SolveResult r = solve();
    final String direction = p.b >= 0 ? 'right (+)' : 'left (−)';
    return [
      StepModel(
        stepNumber: 1,
        title: 'Locate ${p.a} on the line',
        explanation: 'Start at ${p.a}.',
      ),
      StepModel(
        stepNumber: 2,
        title: 'Face $direction',
        explanation: 'Operation ${p.op} moves toward $direction.',
      ),
      StepModel(
        stepNumber: 3,
        title: 'Count ${p.b.abs()} step(s)',
        explanation: 'Land on the answer marker.',
      ),
      StepModel(
        stepNumber: 4,
        title: 'Apply the sign rule',
        explanation: '${r.answer}.',
      ),
    ];
  }
}
