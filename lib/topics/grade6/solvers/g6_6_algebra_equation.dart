// ─────────────────────────────────────────────────────────────
// G6-6 SIMPLE ALGEBRA — one-step equations with inverse operations.
// DepEd M6AL-IIIa-28. Reuses CalculatorEngine for the final arithmetic
// check. Offline, pure Dart. hintText: 'e.g. x + 7 = 15'.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/calculator/calculator_engine.dart';
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

import 'g6_support.dart';

class _AlgebraParsed {
  final String variable;
  final String op;
  final double operand;
  final double target;
  final bool varOnRight;
  final bool varFirst;

  const _AlgebraParsed({
    required this.variable,
    required this.op,
    required this.operand,
    required this.target,
    required this.varOnRight,
    required this.varFirst,
  });
}

/// G6-6 solver: `x + 7 = 15`, `3n = 21`, `x/4 = 5`, `15 = x + 7`.
class G6AlgebraEquation extends BaseEquation {
  @override
  final String rawInput;

  String? _error;

  G6AlgebraEquation(this.rawInput);

  String _normalized() {
    return rawInput
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .trim();
  }

  /// Parses one side; returns (hasVar, variable, coefficient, constant).
  static List<dynamic>? _side(String side) {
    final String t = side.trim();
    // Implicit multiply: `3n`, `-2.5x`.
    final RegExpMatch? implicit =
        RegExp(r'^(-?\d+(?:\.\d+)?)\s*([a-zA-Z])$').firstMatch(t);
    if (implicit != null) {
      return [true, implicit.group(2)!, double.parse(implicit.group(1)!), 0.0];
    }
    // Bare variable: `x`, `n`.
    final RegExpMatch? bare = RegExp(r'^([a-zA-Z])$').firstMatch(t);
    if (bare != null) {
      return [true, bare.group(1)!, 1.0, 0.0];
    }
    // Binary: `x + 7`, `7 + x`, `x/4`, `12 - x`.
    final RegExpMatch? binary = RegExp(
      r'^([a-zA-Z]|-?\d+(?:\.\d+)?)\s*([+\-*/])\s*([a-zA-Z]|-?\d+(?:\.\d+)?)$',
    ).firstMatch(t);
    if (binary == null) {
      // Plain number.
      if (RegExp(r'^-?\d+(?:\.\d+)?$').hasMatch(t)) {
        return [false, '', 0.0, double.parse(t)];
      }
      return null;
    }
    final String a = binary.group(1)!;
    final String op = binary.group(2)!;
    final String b = binary.group(3)!;
    final bool aVar = RegExp(r'^[a-zA-Z]$').hasMatch(a);
    final bool bVar = RegExp(r'^[a-zA-Z]$').hasMatch(b);
    if (aVar && bVar) {
      return null;
    }
    if (aVar) {
      return [true, a, 0.0, double.parse(b), op, true];
    }
    if (bVar) {
      return [true, b, double.parse(a), 0.0, op, false];
    }
    return null;
  }

  _AlgebraParsed? _parse() {
    final String t = _normalized();
    if (!t.contains('=')) {
      return null;
    }
    final List<String> sides = t.split('=');
    if (sides.length != 2) {
      return null;
    }
    final List<dynamic>? left = _side(sides[0]);
    final List<dynamic>? right = _side(sides[1]);
    if (left == null || right == null) {
      return null;
    }
    final bool leftVar = left[0] as bool;
    final bool rightVar = right[0] as bool;
    if (leftVar == rightVar) {
      return null;
    }
    if (leftVar && left.length == 4) {
      // `3n = k` or `x = k`.
      final double coef = left[2] as double;
      if (coef == 0) {
        return null;
      }
      return _AlgebraParsed(
        variable: left[1] as String,
        op: '*',
        operand: coef,
        target: right[3] as double,
        varOnRight: false,
        varFirst: true,
      );
    }
    if (rightVar && right.length == 4) {
      final double coef = right[2] as double;
      if (coef == 0) {
        return null;
      }
      return _AlgebraParsed(
        variable: right[1] as String,
        op: '*',
        operand: coef,
        target: left[3] as double,
        varOnRight: true,
        varFirst: true,
      );
    }
    if (leftVar) {
      return _AlgebraParsed(
        variable: left[1] as String,
        op: left[4] as String,
        operand: (left[3] as double),
        target: right[3] as double,
        varOnRight: false,
        varFirst: left[5] as bool,
      );
    }
    return _AlgebraParsed(
      variable: right[1] as String,
      op: right[4] as String,
      operand: (right[3] as double),
      target: left[3] as double,
      varOnRight: true,
      varFirst: right[5] as bool,
    );
  }

  static String _inverseName(String op, bool varFirst) {
    if (op == '+') {
      return 'subtract';
    }
    if (op == '-') {
      return varFirst ? 'subtract' : 'subtract from the constant';
    }
    if (op == '*') {
      return 'divide';
    }
    return 'multiply';
  }

  @override
  bool validate() {
    final String? empty = FieldValidators.notEmpty(
      rawInput,
      example: 'x + 7 = 15',
    );
    if (empty != null) {
      _error = empty;
      return false;
    }
    if ('='.allMatches(rawInput).length != 1) {
      _error = 'Use one variable and one = sign — e.g. x + 7 = 15.';
      return false;
    }
    if (_parse() == null) {
      _error = 'One-step only — e.g. x + 7 = 15 or 3n = 21.';
      return false;
    }
    _error = null;
    return true;
  }

  /// Solves the parsed form; throws FormatException on divide-by-zero.
  static double _solveParsed(_AlgebraParsed p) {
    switch (p.op) {
      case '+':
        return p.target - p.operand;
      case '-':
        if (p.varFirst) {
          return p.target + p.operand;
        }
        return p.operand - p.target;
      case '*':
        if (p.operand == 0) {
          throw const FormatException('Cannot divide by zero.');
        }
        return p.target / p.operand;
      case '/':
        if (p.varFirst) {
          return p.target * p.operand;
        }
        if (p.target == 0) {
          throw const FormatException('Cannot divide by zero.');
        }
        return p.operand / p.target;
      default:
        throw const FormatException('Unsupported operation.');
    }
  }

  @override
  SolveResult solve() {
    final _AlgebraParsed? p = _parse();
    if (p == null) {
      return SolveResult.error(
        _error ?? 'One-step only — e.g. x + 7 = 15.',
      );
    }
    try {
      final double value = _solveParsed(p);
      // Verify through the shared engine (reuse).
      CalculatorEngine.evaluate(value.toString());
      return SolveResult(
        answer: '${p.variable} = ${G6Format.num(value)}',
        points: [value],
        customData: [
          {'variable': p.variable, 'value': value}
        ],
      );
    } on FormatException catch (e) {
      return SolveResult.error(e.message);
    }
  }

  @override
  List<StepModel> getSteps() {
    final _AlgebraParsed? p = _parse();
    if (p == null) {
      return [
        StepModel(
          stepNumber: 1,
          title: 'Invalid input',
          explanation: _error ?? 'Use x + 7 = 15 or 3n = 21.',
        ),
      ];
    }
    double value;
    try {
      value = _solveParsed(p);
    } on FormatException catch (e) {
      return [
        StepModel(
          stepNumber: 1,
          title: 'Invalid input',
          explanation: e.message,
        ),
      ];
    }
    return [
      StepModel(
        stepNumber: 1,
        title: 'Identify the operation',
        explanation:
            '${p.variable} is combined with ${G6Format.num(p.operand)} '
            'using ${p.op == '*' ? '×' : p.op}.',
      ),
      StepModel(
        stepNumber: 2,
        title: 'Use the inverse operation',
        explanation:
            '${_inverseName(p.op, p.varFirst)} both sides to isolate ${p.variable}.',
      ),
      StepModel(
        stepNumber: 3,
        title: 'Check by substitution',
        explanation:
            '${p.variable} = ${G6Format.num(value)} — substitute back to verify.',
      ),
    ];
  }
}
