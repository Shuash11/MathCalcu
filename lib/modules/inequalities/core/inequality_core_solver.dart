class InequalityCoreSolver {
  static String normalize(String input) {
    String s = input
        .trim()
        .replaceAll('\u2212', '-')
        .replaceAll('\u2013', '-')
        .replaceAll('\u2014', '-')
        .replaceAll(' ', '')
        .replaceAll('>=', '≥')
        .replaceAll('<=', '≤')
        .replaceAll('=>', '≥')
        .replaceAll('=<', '≤')
        .replaceAll('x²', 'x^2')
        .replaceAll('²', '^2')
        .replaceAllMapped(RegExp(r'abs\(([^)]+)\)'), (m) => '|${m.group(1)}|');
    s = _expandParentheses(s);
    return s;
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

  static String detectType(String normalized) {
    if (normalized.contains('|')) return 'absolute';
    if (normalized.contains('^2')) return 'quadratic';
    if (normalized.contains('/')) return 'rational';
    return 'linear';
  }

  static String? extractOperator(String expr) {
    if (expr.contains('≥')) return '≥';
    if (expr.contains('≤')) return '≤';
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
          coef = double.tryParse(coefStr) ?? 1;
        }
        xCoef += coef;
      } else {
        constant += double.tryParse(tok) ?? 0;
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
          coef = double.tryParse(cs) ?? 1;
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
          coef = double.tryParse(cs) ?? 1;
        }
        b += coef;
      } else {
        c += double.tryParse(tok) ?? 0;
      }
    }
    return {'a': a, 'b': b, 'c': c};
  }

  static String flipOp(String op) {
    switch (op) {
      case '>':
        return '<';
      case '<':
        return '>';
      case '≥':
        return '≤';
      case '≤':
        return '≥';
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
      case '≥':
        return left >= right;
      case '≤':
        return left <= right;
      default:
        return false;
    }
  }

  static String interval(String op, double boundary) {
    final b = fmt(boundary);
    switch (op) {
      case '>':
        return '($b, ∞)';
      case '≥':
        return '[$b, ∞)';
      case '<':
        return '(-∞, $b)';
      case '≤':
        return '(-∞, $b]';
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
