import 'smart_parser.dart';

/// Result of evaluating an expression at a specific point
class EvaluationResult {
  final double value;
  final bool isNaN;
  final bool isInfinity;
  final bool isNegativeInfinity;
  final String description;

  const EvaluationResult({
    required this.value,
    required this.isNaN,
    required this.isInfinity,
    required this.isNegativeInfinity,
    required this.description,
  });

  factory EvaluationResult.fromValue(double v) {
    if (v.isNaN) {
      return const EvaluationResult(
        value: double.nan,
        isNaN: true,
        isInfinity: false,
        isNegativeInfinity: false,
        description: 'undefined',
      );
    }
    if (v.isInfinite) {
      return EvaluationResult(
        value: v,
        isNaN: false,
        isInfinity: v > 0,
        isNegativeInfinity: v < 0,
        description: v > 0 ? '∞' : '-∞',
      );
    }
    return EvaluationResult(
      value: v,
      isNaN: false,
      isInfinity: false,
      isNegativeInfinity: false,
      description: _formatNumber(v),
    );
  }

  static String _formatNumber(double n) {
    if (n == 0) return '0';
    if (n == n.toInt()) return n.toInt().toString();

    // Try to detect simple fractions
    for (int denom = 2; denom <= 100; denom++) {
      final numer = n * denom;
      if ((numer - numer.round()).abs() < 1e-9) {
        final intNumer = numer.round();
        final gcdVal = _gcd(intNumer.abs(), denom);
        final simpleNum = intNumer ~/ gcdVal;
        final simpleDen = denom ~/ gcdVal;
        if (simpleDen == 1) return simpleNum.toString();
        return '$simpleNum/$simpleDen';
      }
    }

    // Round to reasonable precision
    String result = n.toStringAsFixed(6);
    result = result.replaceAll(RegExp(r'0+$'), '');
    result = result.replaceAll(RegExp(r'\.$'), '');
    return result;
  }

  static int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  bool get isDefined => !isNaN && !isInfinity && !isNegativeInfinity;
}

/// Helper class for safe expression evaluation
class ExpressionEvaluator {
  /// Safely evaluate an AST node at a given x value
  static EvaluationResult safeEvaluate(ASTNode node, double x) {
    try {
      final result = node.evaluate(x);
      return EvaluationResult.fromValue(result);
    } catch (e) {
      return const EvaluationResult(
        value: double.nan,
        isNaN: true,
        isInfinity: false,
        isNegativeInfinity: false,
        description: 'error during evaluation',
      );
    }
  }

  /// Check if result is an indeterminate form
  static bool isIndeterminateForm(double numerator, double denominator) {
    final numNearZero = numerator.abs() < 1e-9;
    final denNearZero = denominator.abs() < 1e-9;
    return numNearZero && denNearZero;
  }

  /// Classify the limit result
  static LimitClassification classifyResult(double value) {
    if (value.isNaN) return LimitClassification.undefined;
    if (value.isInfinite) {
      return value > 0
          ? LimitClassification.positiveInfinity
          : LimitClassification.negativeInfinity;
    }
    return LimitClassification.finiteValue;
  }
}

/// Classification of a limit result
enum LimitClassification {
  finiteValue,
  positiveInfinity,
  negativeInfinity,
  undefined,
}
