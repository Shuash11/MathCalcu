// ─────────────────────────────────────────────────────────────
// G6-2 DECIMALS — four operations + repeating-decimal classifier.
// DepEd M6NS-Ib-106. Reuses CalculatorEngine for the numeric value;
// exact rational check decides terminating vs repeating. Offline.
// hintText: 'e.g. 3.25 × 1.2'.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/calculator/calculator_engine.dart';
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';

import 'g6_support.dart';

/// Exact decimal operand as a rational (digits / 10^places).
class _DecimalRational {
  final int num;
  final int den;

  const _DecimalRational(this.num, this.den);

  factory _DecimalRational.parse(String text) {
    final String t = text.trim();
    final bool negative = t.startsWith('-');
    final String body = negative ? t.substring(1) : t;
    if (!body.contains('.')) {
      final int n = int.parse(body);
      return _DecimalRational(negative ? -n : n, 1);
    }
    final List<String> parts = body.split('.');
    final int places = parts[1].length;
    var denom = 1;
    for (var i = 0; i < places; i++) {
      denom *= 10;
    }
    final int digits = int.parse('${parts[0]}${parts[1]}');
    final int signed = negative ? -digits : digits;
    final int g = G6Math.gcd(signed, denom);
    return _DecimalRational(signed ~/ g, denom ~/ g);
  }
}

/// G6-2 solver: `3.25 × 1.2`, `7.5 ÷ 0.25`, `0.5 + 0.25`.
class G6DecimalEquation extends BaseEquation {
  @override
  final String rawInput;

  String? _error;

  G6DecimalEquation(this.rawInput);

  static final RegExp _expr = RegExp(
    r'^\s*(-?\d+(?:\.\d+)?)\s*([+\-×÷*/])\s*(-?\d+(?:\.\d+)?)\s*$',
  );

  String _normalized() {
    return rawInput
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-');
  }

  /// CalculatorEngine stops at spaces, so evaluate the spaceless form.
  String _engineExpr() => _normalized().replaceAll(' ', '');

  /// True when the simplified denominator has a prime factor
  /// other than 2 or 5 (then the decimal repeats).
  static bool isRepeating(int num, int den) {
    var d = den.abs();
    if (d == 1) {
      return false;
    }
    while (d % 2 == 0) {
      d ~/= 2;
    }
    while (d % 5 == 0) {
      d ~/= 5;
    }
    return d != 1;
  }

  /// Exact rational result of the operation (for classification).
  static List<int> _exact(String a, String op, String b) {
    final _DecimalRational left = _DecimalRational.parse(a);
    final _DecimalRational right = _DecimalRational.parse(b);
    var num = 0;
    var den = 1;
    if (op == '+') {
      num = left.num * right.den + right.num * left.den;
      den = left.den * right.den;
    } else if (op == '-') {
      num = left.num * right.den - right.num * left.den;
      den = left.den * right.den;
    } else if (op == '*') {
      num = left.num * right.num;
      den = left.den * right.den;
    } else {
      num = left.num * right.den;
      den = left.den * right.num;
      if (den == 0) {
        throw const FormatException('Divisor cannot be zero.');
      }
      if (den < 0) {
        num = -num;
        den = -den;
      }
    }
    final int g = G6Math.gcd(num, den);
    return [num ~/ g, den ~/ g];
  }

  static int _places(String text) {
    final String t = text.trim();
    if (!t.contains('.')) {
      return 0;
    }
    return t.split('.')[1].length;
  }

  @override
  bool validate() {
    final String? empty = FieldValidators.notEmpty(
      rawInput,
      example: '3.25 × 1.2',
    );
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (!rawInput.contains('.')) {
      _error = 'Use a decimal point — e.g. 3.25 × 1.2.';
      return false;
    }
    if (_expr.firstMatch(_normalized()) == null) {
      _error = 'Use decimals with + - × ÷ — e.g. 7.5 ÷ 0.25.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    final RegExpMatch? m = _expr.firstMatch(_normalized());
    if (m == null) {
      return SolveResult.error(
        _error ?? 'Use decimals with + - × ÷ — e.g. 3.25 × 1.2.',
      );
    }
    final String a = m.group(1)!;
    final String op = m.group(2)!;
    final String b = m.group(3)!;
    if ((op == '/') && double.parse(b) == 0) {
      return SolveResult.error('Divisor cannot be zero.');
    }
    try {
      final double value = CalculatorEngine.evaluate(_engineExpr());
      final List<int> exact = _exact(a, op == '*' ? '*' : op, b);
      final bool repeating = isRepeating(exact[0], exact[1]);
      final String formatted = G6Format.num(value);
      final String tag = repeating ? ' (repeating decimal)' : ' (terminating)';
      return SolveResult(
        answer: '$formatted$tag',
        points: [value],
        customData: [
          {
            'value': value,
            'places': _places(a) + _places(b),
            'repeating': repeating,
            'exactNum': exact[0],
            'exactDen': exact[1],
          }
        ],
      );
    } on FormatException catch (e) {
      return SolveResult.error(e.message);
    }
  }

  @override
  List<StepModel> getSteps() {
    final RegExpMatch? m = _expr.firstMatch(_normalized());
    if (m == null) {
      return [
        StepModel(
          stepNumber: 1,
          title: 'Invalid input',
          explanation: _error ?? 'Use decimals — e.g. 3.25 × 1.2.',
        ),
      ];
    }
    final String a = m.group(1)!;
    final String op = m.group(2)!;
    final String b = m.group(3)!;
    try {
      final double value = CalculatorEngine.evaluate(_engineExpr());
      final List<int> exact = _exact(a, op == '*' ? '*' : op, b);
      final bool repeating = isRepeating(exact[0], exact[1]);
      final String opWord = op == '+'
          ? 'Add'
          : op == '-'
              ? 'Subtract'
              : op == '*'
                  ? 'Multiply'
                  : 'Divide';
      return [
        StepModel(
          stepNumber: 1,
          title: 'Ignore the decimal points',
          explanation:
              '$opWord as whole numbers first: ${a.replaceAll('.', '')} '
              '$op ${b.replaceAll('.', '')}.',
        ),
        StepModel(
          stepNumber: 2,
          title: 'Compute with whole numbers',
          explanation: 'Then handle the decimal places for $opWord.',
        ),
        StepModel(
          stepNumber: 3,
          title: 'Place the decimal point',
          explanation:
              '$a has ${_places(a)} place(s), $b has ${_places(b)} place(s). '
              'Result: ${G6Format.num(value)}.',
        ),
        StepModel(
          stepNumber: 4,
          title: repeating ? 'Repeating decimal' : 'Terminating decimal',
          explanation: repeating
              ? 'Exact form ${exact[0]}/${exact[1]} never ends — mark it repeating.'
              : 'Exact form ${exact[0]}/${exact[1]} ends — terminating.',
        ),
      ];
    } on FormatException catch (e) {
      return [
        StepModel(
          stepNumber: 1,
          title: 'Invalid input',
          explanation: e.message,
        ),
      ];
    }
  }
}
