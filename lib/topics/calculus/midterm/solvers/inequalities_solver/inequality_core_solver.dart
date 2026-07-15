class InequalityCoreSolver {
  static String normalize(String input) {
    String s = input
        .trim()
        .replaceAll('\u2212', '-')
        .replaceAll('\u2013', '-')
        .replaceAll('\u2014', '-')
        .replaceAll('\u2264', '<=')
        .replaceAll('\u2265', '>=')
        .replaceAll(' ', '')
        .replaceAll('>=', '≠¥')
        .replaceAll('<=', '≠¤')
        .replaceAll('=>', '≠¥')
        .replaceAll('=<', '≠¤')
        .replaceAll('x²', 'x^2')
        .replaceAll('²', '^2')
        .replaceAllMapped(RegExp(r'abs\(([^)]+)\)'), (m) => '|${m.group(1)}|');
    s = _expandAdjacentLinearFactors(s);
    s = _expandParentheses(s);
    return s;
  }

  static String _expandAdjacentLinearFactors(String s) {
    final pattern = RegExp(r'\(([^()]+)\)\(([^()]+)\)');
    while (pattern.hasMatch(s)) {
      s = s.replaceAllMapped(pattern, (match) {
        final left = parseLinear(match.group(1)!);
        final right = parseLinear(match.group(2)!);
        if (left == null || right == null) return match.group(0)!;

        final a = left['x']! * right['x']!;
        final b = left['x']! * right['c']! + left['c']! * right['x']!;
        final c = left['c']! * right['c']!;
        return _formatQuadratic(a, b, c);
      });
    }
    return s;
  }

  static String _formatQuadratic(double a, double b, double c) {
    final terms = <String>[];
    void addTerm(double value, String variable) {
      if (value == 0) return;
      final sign = value < 0 ? '-' : (terms.isEmpty ? '' : '+');
      final magnitude = value.abs();
      final coefficient = variable.isNotEmpty && magnitude == 1
          ? ''
          : fmt(magnitude);
      terms.add('$sign$coefficient$variable');
    }

    addTerm(a, 'x^2');
    addTerm(b, 'x');
    addTerm(c, '');
    return terms.isEmpty ? '0' : terms.join();
  }

  static String _expandParentheses(String s) {
    final pattern = RegExp(r'(-?\d*\.?\d*)\(([^)]+)\)');
    while (pattern.hasMatch(s)) {
      s = s.replaceAllMapped(pattern, (m) {
        final coefStr = m.group(1)!;
        final inner = m.group(2)!;
        double coef;
        if (coefStr.isEmpty || coefStr == '+') {
          coef = 1;
        } else if (coefStr == '-') {
          coef = -1;
        } else {
          coef = double.tryParse(coefStr) ?? 1;
        }

        final parsed = parseLinear(inner);
        if (parsed == null) return m.group(0)!;
        final newX = parsed['x']! * coef;
        final newC = parsed['c']! * coef;

        String result = '';
        if (newX != 0) {
          if (newX == 1) {
            result += 'x';
          } else if (newX == -1) {
            result += '-x';
          } else {
            result += '${fmt(newX)}x';
          }
        }
        if (newC != 0) {
          if (newC > 0 && result.isNotEmpty) {
            result += '+${fmt(newC)}';
          } else {
            result += fmt(newC);
          }
        }
        if (result.isEmpty) result = '0';
        return result;
      });
    }
    return s;
  }

  static String fmt(double n) {
    if (n == 0) return '0';
    if (!n.isFinite) return n.isNaN ? 'NaN' : (n.isNegative ? r'-\infty' : r'\infty');
    if (n == n.roundToDouble()) return n.toInt().toString();
    for (int denom = 2; denom <= 20; denom++) {
      final numer = (n * denom).round();
      if ((numer / denom - n).abs() < 1e-9) {
        int g = _gcd(numer.abs(), denom);
        final sn = numer ~/ g;
        final sd = denom ~/ g;
        if (sd == 1) return sn.toString();
        return '$sn/$sd';
      }
    }
    return double.parse(n.toStringAsFixed(4)).toString();
  }

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  static bool _isStrict(String normalized) {
    // Check if the inequality uses ONLY strict operators (< or >) 
    // If it has any non-strict operators (≠¤ or ≠¥), it's non-strict
    // If it has BOTH strict and non-strict, it's continued (return null via new method)
    final hasNonStrict = normalized.contains('≠¤') || normalized.contains('≠¥');
    if (hasNonStrict) return false;
    
    // If it has strict operators and no non-strict operators, it's strict
    final hasStrict = normalized.contains('<') || normalized.contains('>');
    return hasStrict;
  }

  static bool _isContinued(String normalized) {
    // Check if inequality has BOTH strict and non-strict operators (mixed)
    final hasStrict = normalized.contains('<') || normalized.contains('>');
    final hasNonStrict = normalized.contains('≠¤') || normalized.contains('≠¥');
    return hasStrict && hasNonStrict;
  }

  static String detectType(String normalized) {
    // Check for continued (mixed operators) first
    if (_isContinued(normalized)) {
      final strictnessStr = '-continued';
      
      if (normalized.contains('|')) return 'absolute$strictnessStr';
      final hasRadical = normalized.contains('sqrt') ||
          normalized.contains('root') ||
          normalized.contains('\u221A') ||
          normalized.contains('√');
      if (hasRadical && normalized.contains('/')) return 'sqrtRational$strictnessStr';
      if (hasRadical) return 'radical$strictnessStr';
      if (normalized.contains('^2')) return 'quadratic$strictnessStr';
      if (normalized.contains('/')) return 'rational$strictnessStr';
      return 'linear$strictnessStr';
    }
    
    // Otherwise, check for strict vs non-strict
    final strictnessStr = _isStrict(normalized) ? '-strict' : '-non-strict';
    
    if (normalized.contains('|')) return 'absolute$strictnessStr';
    final hasRadical = normalized.contains('sqrt') ||
        normalized.contains('root') ||
        normalized.contains('\u221A') ||
        normalized.contains('√');
    if (hasRadical && normalized.contains('/')) return 'sqrtRational$strictnessStr';
    if (hasRadical) return 'radical$strictnessStr';
    if (normalized.contains('^2')) return 'quadratic$strictnessStr';
    if (normalized.contains('√') && normalized.contains('/')) return 'sqrtRational$strictnessStr';
    if (normalized.contains('√')) return 'radical$strictnessStr';
    if (normalized.contains('/')) return 'rational$strictnessStr';
    return 'linear$strictnessStr';
  }

  static String debugNormalize(String input) {
    String s = input
        .trim()
        .replaceAll('\u2212', '-')
        .replaceAll('\u2013', '-')
        .replaceAll('\u2014', '-')
        .replaceAll('\u2264', '<=')
        .replaceAll('\u2265', '>=')
        .replaceAll(' ', '')
        .replaceAll('>=', '≠¥')
        .replaceAll('<=', '≠¤')
        .replaceAll('=>', '≠¥')
        .replaceAll('=<', '≠¤')
        .replaceAll('x²', 'x^2')
        .replaceAll('²', '^2')
        .replaceAllMapped(RegExp(r'abs\(([^)]+)\)'), (m) => '|${m.group(1)}|');
    s = _expandAdjacentLinearFactors(s);
    s = _expandParentheses(s);
    return s;
  }

  static String? extractOperator(String expr) {
    if (expr.contains('≠¥')) return '≠¥';
    if (expr.contains('≠¤')) return '≠¤';
    if (expr.contains('>')) return '>';
    if (expr.contains('<')) return '<';
    return null;
  }

  static List<String>? splitOnOp(String expr, String op) {
    final idx = expr.indexOf(op);
    if (idx == -1) return null;
    final left = expr.substring(0, idx);
    final right = expr.substring(idx + op.length);
    if (left.isEmpty || right.isEmpty) return null;
    return [left, right];
  }

  static Map<String, double>? parseLinear(String expr) {
    expr = expr.trim().replaceAll(' ', '');
    if (expr.isEmpty) return null;

    double xCoef = 0;
    double constant = 0;

    final tokens = <String>[];
    String current = '';
    for (int i = 0; i < expr.length; i++) {
      final ch = expr[i];
      if ((ch == '+' || ch == '-') && i > 0) {
        if (current.isNotEmpty) tokens.add(current);
        current = ch;
      } else {
        current += ch;
      }
    }
    if (current.isNotEmpty) tokens.add(current);

    for (final tok in tokens) {
      if (tok.contains('x')) {
        final parts = tok.split('x');
        final coefStr = parts[0];
        double coef;
        if (coefStr.isEmpty || coefStr == '+') {
          coef = 1;
        } else if (coefStr == '-') {
          coef = -1;
        } else {
          final parsed = tryParseNumber(coefStr);
          if (parsed == null) return null;
          coef = parsed;
        }
        xCoef += coef;
      } else {
        final parsed = tryParseNumber(tok);
        if (parsed == null) return null;
        constant += parsed;
      }
    }
    return {'x': xCoef, 'c': constant};
  }

  static Map<String, double>? parseQuadratic(String expr) {
    expr = expr.trim().replaceAll(' ', '');
    double a = 0, b = 0, c = 0;

    final tokens = <String>[];
    String cur = '';
    for (int i = 0; i < expr.length; i++) {
      final ch = expr[i];
      if ((ch == '+' || ch == '-') && i > 0) {
        if (cur.isNotEmpty) tokens.add(cur);
        cur = ch;
      } else {
        cur += ch;
      }
    }
    if (cur.isNotEmpty) tokens.add(cur);

    for (final tok in tokens) {
      if (tok.contains('^2')) {
        final cs = tok.split('x')[0];
        double coef;
        if (cs.isEmpty || cs == '+') {
          coef = 1;
        } else if (cs == '-') {
          coef = -1;
        } else {
          final parsed = tryParseNumber(cs);
          if (parsed == null) return null;
          coef = parsed;
        }
        a += coef;
      } else if (tok.contains('x')) {
        final cs = tok.split('x')[0];
        double coef;
        if (cs.isEmpty || cs == '+') {
          coef = 1;
        } else if (cs == '-') {
          coef = -1;
        } else {
          final parsed = tryParseNumber(cs);
          if (parsed == null) return null;
          coef = parsed;
        }
        b += coef;
      } else {
        final parsed = tryParseNumber(tok);
        if (parsed == null) return null;
        c += parsed;
      }
    }
    return {'a': a, 'b': b, 'c': c};
  }

  static double? tryParseNumber(String input) {
    var value = input.trim();
    if (value.startsWith('+')) value = value.substring(1);
    if (value.endsWith('.')) value = '${value}0';

    final slash = value.indexOf('/');
    if (slash > 0 && slash == value.lastIndexOf('/')) {
      final numerator = double.tryParse(value.substring(0, slash));
      final denominator = double.tryParse(value.substring(slash + 1));
      if (numerator == null || denominator == null || denominator == 0) {
        return null;
      }
      return numerator / denominator;
    }
    return double.tryParse(value);
  }

  static int? unsupportedPower(String normalized) {
    for (final match in RegExp(r'x\^(\d+)').allMatches(normalized)) {
      final exponent = int.tryParse(match.group(1)!);
      if (exponent != null && exponent > 2) return exponent;
    }
    return null;
  }

  static String flipOp(String op) {
    switch (op) {
      case '>':
        return '<';
      case '<':
        return '>';
      case '≠¥':
        return '≠¤';
      case '≠¤':
        return '≠¥';
      default:
        return op;
    }
  }

  static bool evalOp(double left, String op, double right) {
    switch (op) {
      case '>':
        return left > right;
      case '<':
        return left < right;
      case '≠¥':
        return left >= right;
      case '≠¤':
        return left <= right;
      default:
        return false;
    }
  }

  static String interval(String op, double boundary) {
    final b = fmt(boundary);
    switch (op) {
      case '>':
        return '($b, \\infty)';
      case '≠¥':
        return '[$b, \\infty)';
      case '<':
        return '(-\\infty, $b)';
      case '≠¤':
        return '(-\\infty, $b]';
      default:
        return '';
    }
  }

  static double sqrt(double x) {
    if (x <= 0) return 0;
    double g = x / 2;
    for (int i = 0; i < 60; i++) {
      g = (g + x / g) / 2;
    }
    return g;
  }
}
