import 'dart:math' as math;

class CalculatorEngine {
  static double evaluate(String expression) {
    try {
      String expr = _preprocess(expression);
      final result = _parseExpression(expr, 0);
      return result.$1;
    } catch (e) {
      throw FormatException('Invalid expression: $e');
    }
  }

  static String _preprocess(String expr) {
    expr = expr.replaceAll('\u00D7', '*');
    expr = expr.replaceAll('\u00F7', '/');
    expr = expr.replaceAll('\u2212', '-');
    expr = expr.replaceAll('\u03C0', 'pi');
    expr = expr.replaceAll('\u221A', 'sqrt');
    expr = expr.replaceAll('\u221B', 'cbrt');
    expr = expr.replaceAll('^', '^');
    expr = expr.replaceAll('%', '/100');
    return expr;
  }

  static (double, int) _parseExpression(String expr, int pos) {
    return _parseAddSub(expr, pos);
  }

  static (double, int) _parseAddSub(String expr, int pos) {
    final (left, newPos) = _parseMulDiv(expr, pos);
    int p = newPos;
    double result = left;
    while (p < expr.length) {
      if (expr[p] == '+') {
        final (right, np) = _parseMulDiv(expr, p + 1);
        result += right;
        p = np;
      } else if (expr[p] == '-') {
        final (right, np) = _parseMulDiv(expr, p + 1);
        result -= right;
        p = np;
      } else {
        break;
      }
    }
    return (result, p);
  }

  static (double, int) _parseMulDiv(String expr, int pos) {
    final (left, newPos) = _parseUnary(expr, pos);
    int p = newPos;
    double result = left;
    while (p < expr.length) {
      if (expr[p] == '*') {
        final (right, np) = _parseUnary(expr, p + 1);
        result *= right;
        p = np;
      } else if (expr[p] == '/') {
        final (right, np) = _parseUnary(expr, p + 1);
        result /= right;
        p = np;
      } else {
        break;
      }
    }
    return (result, p);
  }

  static (double, int) _parseUnary(String expr, int pos) {
    if (pos < expr.length && expr[pos] == '-') {
      final (val, newPos) = _parsePower(expr, pos + 1);
      return (-val, newPos);
    }
    return _parsePower(expr, pos);
  }

  static (double, int) _parsePower(String expr, int pos) {
    final (base, newPos) = _parseAtom(expr, pos);
    int p = newPos;
    if (p < expr.length && expr[p] == '^') {
      final (exp, np) = _parseUnary(expr, p + 1);
      return (math.pow(base, exp).toDouble(), np);
    }
    return (base, p);
  }

  static (double, int) _parseAtom(String expr, int pos) {
    while (pos < expr.length && expr[pos] == ' ') {
      pos++;
    }

    if (pos < expr.length && expr[pos] == '(') {
      final (val, newPos) = _parseExpression(expr, pos + 1);
      int p = newPos;
      if (p < expr.length && expr[p] == ')') p++;
      return (val, p);
    }

    final functions = <String, double Function(double)>{
      'sqrt': (x) => math.sqrt(x),
      'cbrt': (x) => math.pow(x, 1 / 3).toDouble(),
      'sin': (x) => math.sin(x),
      'cos': (x) => math.cos(x),
      'tan': (x) => math.tan(x),
      'asin': (x) => math.asin(x),
      'acos': (x) => math.acos(x),
      'atan': (x) => math.atan(x),
      'log': (x) => math.log(x) / math.ln10,
      'ln': (x) => math.log(x),
      'abs': (x) => x.abs(),
      'exp': (x) => math.exp(x),
      'ceil': (x) => x.ceilToDouble(),
      'floor': (x) => x.floorToDouble(),
      'round': (x) => x.roundToDouble(),
    };

    for (final fn in functions.keys) {
      if (expr.substring(pos).startsWith(fn)) {
        int p = pos + fn.length;
        while (p < expr.length && expr[p] == ' ') {
          p++;
        }
        if (p < expr.length && expr[p] == '(') {
          final (arg, argEnd) = _parseExpression(expr, p + 1);
          int end = argEnd;
          if (end < expr.length && expr[end] == ')') end++;
          return (functions[fn]!(arg), end);
        } else {
          final (arg, argEnd) = _parseAtom(expr, p);
          return (functions[fn]!(arg), argEnd);
        }
      }
    }

    if (expr.substring(pos).startsWith('pi')) {
      return (math.pi, pos + 2);
    }

    int start = pos;
    while (pos < expr.length && expr[pos].contains(RegExp(r'[0-9.]'))) {
      pos++;
    }
    if (start == pos) {
      throw FormatException('Unexpected character at $pos');
    }
    return (double.parse(expr.substring(start, pos)), pos);
  }

  static String formatResult(double value) {
    // Check for special values
    if (value.isNaN) return 'NaN';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';

    // Try to convert to fraction
    final fraction = _toFraction(value);
    if (fraction != null) return fraction;

    // Fallback to decimal
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    String result = value.toStringAsFixed(10);
    result = result.replaceAll(RegExp(r'0+$'), '');
    result = result.replaceAll(RegExp(r'\.$'), '');
    return result;
  }

  static String? _toFraction(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return null; // Let formatResult handle integers
    }

    const maxDenominator = 10000;
    const tolerance = 1e-10;

    if (value.abs() < tolerance) return '0';

    final sign = value < 0 ? '-' : '';
    double absValue = value.abs();

    // Continued fraction algorithm
    int h1 = 1, h2 = 0;
    int k1 = 0, k2 = 1;
    double b = absValue;

    do {
      int a = b.floor();
      double r = b - a;

      int h = a * h1 + h2;
      int k = a * k1 + k2;

      if (k > maxDenominator) break;

      h2 = h1; h1 = h;
      k2 = k1; k1 = k;

      if (r < tolerance) {
        if (k == 0) return null;
        if (h == 0) return '0';
        // Check if it's a mixed number
        if (h > k) {
          int whole = h ~/ k;
          int remainder = h % k;
          if (remainder == 0) return null;
          return '$sign$whole $remainder/$k';
        }
        return '$sign$h/$k';
      }

      b = 1 / r;
    } while (b < 1e15);

    return null; // Not a clean fraction
  }
}
