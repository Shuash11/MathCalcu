// ─────────────────────────────────────────────────────────────
// G6-1 FRACTIONS — add/sub/mul/div with mixed numbers.
// DepEd M6NS-Ia-86. Reuses YIFraction (exact math) + CalculatorEngine
// (decimal check). Offline, pure Dart.
// hintText: 'e.g. 2 1/3 + 1 1/2' — see curriculum_registry.dart.
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/calculator/calculator_engine.dart';
import 'package:calculus_system/core/base_equation.dart';
import 'package:calculus_system/core/solve_result.dart';
import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/shared/widgets/input_validation.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/yintercept_solver/fraction.dart';

import 'g6_support.dart';

/// One parsed fraction operand with DepEd display forms.
class G6FractionOperand {
  final YIFraction value;
  final String improperText;
  final String? mixedSource;

  const G6FractionOperand({
    required this.value,
    required this.improperText,
    this.mixedSource,
  });
}

/// G6-1 solver: `1/2 + 3/4`, `2 1/3 - 1 5/6`, `3/4 × 1/2`, `5/6 ÷ 2/3`.
class G6FractionEquation extends BaseEquation {
  @override
  final String rawInput;

  String? _error;

  G6FractionEquation(this.rawInput);

  static final RegExp _expr = RegExp(
    r'^\s*(-?(?:\d+\s+\d+\s*/\s*\d+|\d+\s*/\s*\d+|\d+))'
    r'\s*([+\-×÷*/])\s*'
    r'(-?(?:\d+\s+\d+\s*/\s*\d+|\d+\s*/\s*\d+|\d+))\s*$',
  );

  static final RegExp _mixed = RegExp(r'^(-?)(\d+)\s+(\d+)\s*/\s*(\d+)$');
  static final RegExp _frac = RegExp(r'^(-?)(\d+)\s*/\s*(\d+)$');
  static final RegExp _whole = RegExp(r'^(-?)(\d+)$');

  String _normalized() {
    return rawInput
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-');
  }

  /// Parses one operand (`2 1/3`, `3/4`, `5`) into an exact fraction.
  static G6FractionOperand parseOperand(String text) {
    final String t = text.trim();
    final RegExpMatch? mixed = _mixed.firstMatch(t);
    if (mixed != null) {
      final String sign = mixed.group(1) ?? '';
      final int whole = int.parse(mixed.group(2)!);
      final int num = int.parse(mixed.group(3)!);
      final int den = int.parse(mixed.group(4)!);
      if (den == 0) {
        throw const FormatException('Denominator cannot be zero.');
      }
      var improper = whole * den + num;
      if (sign == '-') {
        improper = -improper;
      }
      final YIFraction value =
          YIFraction(numerator: improper, denominator: den).simplified();
      return G6FractionOperand(
        value: value,
        improperText: '${improper == 0 ? 0 : improper}/$den',
        mixedSource: t,
      );
    }
    final RegExpMatch? frac = _frac.firstMatch(t);
    if (frac != null) {
      final String sign = frac.group(1) ?? '';
      final int num = int.parse(frac.group(2)!);
      final int den = int.parse(frac.group(3)!);
      if (den == 0) {
        throw const FormatException('Denominator cannot be zero.');
      }
      final int signed = sign == '-' ? -num : num;
      final YIFraction value =
          YIFraction(numerator: signed, denominator: den).simplified();
      return G6FractionOperand(
        value: value,
        improperText: '$signed/$den',
      );
    }
    final RegExpMatch? whole = _whole.firstMatch(t);
    if (whole != null) {
      final String sign = whole.group(1) ?? '';
      final int n = int.parse(whole.group(2)!);
      final int signed = sign == '-' ? -n : n;
      return G6FractionOperand(
        value: YIFraction(numerator: signed, denominator: 1),
        improperText: '$signed/1',
      );
    }
    throw FormatException(
      'Could not read "$t" — use a/b or mixed a b/c.',
    );
  }

  /// Exact → DepEd display (`7/4` → `1 3/4`, `4/2` → `2`).
  static String display(YIFraction f) {
    final YIFraction s = f.simplified();
    if (s.denominator == 1) {
      return '${s.numerator}';
    }
    final bool negative = s.numerator < 0;
    final int absNum = s.numerator.abs();
    if (absNum > s.denominator) {
      final int whole = absNum ~/ s.denominator;
      final int rem = absNum % s.denominator;
      if (rem == 0) {
        return '${negative ? '-' : ''}$whole';
      }
      return '${negative ? '-' : ''}$whole $rem/${s.denominator}';
    }
    return '${negative ? '-' : ''}$absNum/${s.denominator}';
  }

  @override
  bool validate() {
    final String? empty = FieldValidators.notEmpty(
      rawInput,
      example: '2 1/3 + 1 1/2',
    );
    if (empty != null) {
      _error = empty;
      return false;
    }
    if (rawInput.contains('.')) {
      _error = 'Fractions only — no decimal point. Try G6-2 decimals.';
      return false;
    }
    if (_expr.firstMatch(_normalized()) == null) {
      _error = 'Use a/b or mixed a b/c with + - × ÷ — e.g. 2 1/3 + 1 1/2.';
      return false;
    }
    _error = null;
    return true;
  }

  @override
  SolveResult solve() {
    if (!validate() &&
        _error != null &&
        _expr.firstMatch(_normalized()) == null) {
      return SolveResult.error(_error!);
    }
    final RegExpMatch? m = _expr.firstMatch(_normalized());
    if (m == null) {
      return SolveResult.error(
        _error ?? 'Use a/b or mixed a b/c with + - × ÷.',
      );
    }
    try {
      final G6FractionOperand left = parseOperand(m.group(1)!);
      final G6FractionOperand right = parseOperand(m.group(3)!);
      final String op = m.group(2)!;
      if ((op == '/') && right.value.isZero) {
        return SolveResult.error('Cannot divide by zero.');
      }
      late final YIFraction result;
      if (op == '+') {
        result = left.value + right.value;
      } else if (op == '-') {
        result = left.value - right.value;
      } else if (op == '*') {
        result = left.value * right.value;
      } else {
        result = left.value / right.value;
      }
      final String exact = display(result);
      final String decimal = CalculatorEngine.formatResult(result.toDouble());
      final String answer = exact == decimal ? exact : '$exact = $decimal';
      final int lcd = G6Math.lcm(
        left.value.denominator.abs(),
        right.value.denominator.abs(),
      );
      return SolveResult(
        answer: answer,
        points: [result.toDouble()],
        latex: exact,
        customData: [
          {
            'num': result.numerator,
            'den': result.denominator,
            'decimal': result.toDouble(),
            'lcd': lcd,
          }
        ],
      );
    } on FormatException catch (e) {
      return SolveResult.error(e.message);
    } on StateError {
      return SolveResult.error('Cannot divide by zero.');
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
          explanation: _error ?? 'Use a/b or mixed a b/c — e.g. 1/2 + 3/4.',
        ),
      ];
    }
    try {
      final G6FractionOperand left = parseOperand(m.group(1)!);
      final G6FractionOperand right = parseOperand(m.group(3)!);
      final String op = m.group(2)!;
      final bool isAddSub = op == '+' || op == '-';
      final int lcd = G6Math.lcm(
        left.value.denominator.abs(),
        right.value.denominator.abs(),
      );
      late final YIFraction result;
      if (op == '+') {
        result = left.value + right.value;
      } else if (op == '-') {
        result = left.value - right.value;
      } else if (op == '*') {
        result = left.value * right.value;
      } else {
        result = left.value / right.value;
      }
      final String opWord = isAddSub
          ? (op == '+' ? 'Add' : 'Subtract')
          : (op == '*' ? 'Multiply' : 'Divide');
      final String step2 = isAddSub
          ? 'LCD of ${left.value.denominator} and ${right.value.denominator} '
              'is $lcd. Rewrite: '
              '${left.value.numerator * (lcd ~/ left.value.denominator)}/$lcd '
              '$op ${right.value.numerator * (lcd ~/ right.value.denominator)}/$lcd.'
          : 'No LCD needed. For × multiply across; for ÷ flip the second '
              'fraction, then multiply across.';
      return [
        StepModel(
          stepNumber: 1,
          title: 'Convert mixed to improper',
          explanation:
              '${left.mixedSource ?? left.improperText} → ${left.value.numerator}/'
              '${left.value.denominator}; '
              '${right.mixedSource ?? right.improperText} → '
              '${right.value.numerator}/${right.value.denominator}.',
        ),
        StepModel(
          stepNumber: 2,
          title: 'Find the LCD',
          explanation: step2,
        ),
        StepModel(
          stepNumber: 3,
          title: '$opWord the fractions',
          explanation: '${display(left.value)} $op ${display(right.value)} = '
              '${result.numerator}/${result.denominator} before simplifying.',
        ),
        StepModel(
          stepNumber: 4,
          title: 'Simplify and convert back',
          explanation: 'Simplified: ${display(result)} '
              '(≈ ${CalculatorEngine.formatResult(result.toDouble())}).',
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
    } on StateError {
      return [
        const StepModel(
          stepNumber: 1,
          title: 'Invalid input',
          explanation: 'Cannot divide by zero.',
        ),
      ];
    }
  }
}
