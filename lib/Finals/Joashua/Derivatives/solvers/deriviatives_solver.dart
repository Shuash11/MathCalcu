// =====================================================
// DERIVATIVE SOLVER - Core Engine
// Handles parsing, differentiation, and simplification
// =====================================================

import 'dart:math';

// ============ HYPERBOLIC FUNCTION HELPERS ============

double _sinh(double x) => (exp(x) - exp(-x)) / 2;
double _cosh(double x) => (exp(x) + exp(-x)) / 2;
double _tanh(double x) {
  if (x.abs() > 20) return x > 0 ? 1.0 : -1.0;
  final ex = exp(2 * x);
  return (ex - 1) / (ex + 1);
}

double _sech(double x) => 2 / (exp(x) + exp(-x));
double _csch(double x) => 2 / (exp(x) - exp(-x));
double _coth(double x) {
  if (x.abs() < 1e-10) throw ArgumentError('coth(0) is undefined');
  final ex = exp(2 * x);
  return (ex + 1) / (ex - 1);
}

// ============ EXPRESSION TYPES (AST NODES) ============

/// Abstract base class for all mathematical expressions
abstract class Expr {
  const Expr();

  /// Compute derivative with respect to [variable]
  Expr diff(String variable);

  /// Simplify this expression algebraically
  Expr simplify();

  /// Check if expression contains [variable]
  bool hasVar(String variable);

  /// Check if this is a constant expression (no variables)
  bool get isConst;

  /// Get constant numeric value if possible, null otherwise
  double? get constValue;

  /// Structural equality
  @override
  bool operator ==(Object other);

  @override
  int get hashCode;

  /// Format as string
  @override
  String toString();

  /// Format with specific settings
  String format({bool compact = false});
}

/// Numeric constant (e.g., 5, 3.14, -2)
class Num extends Expr {
  final double value;

  const Num(this.value);

  @override
  Expr diff(String variable) => const Num(0);

  @override
  Expr simplify() => this;

  @override
  bool hasVar(String variable) => false;

  @override
  bool get isConst => true;

  @override
  double? get constValue => value;

  @override
  bool operator ==(Object other) => other is Num && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  @override
  String format({bool compact = false}) => toString();
}

/// Variable (e.g., x, y, t)
class Var extends Expr {
  final String name;

  const Var(this.name);

  @override
  Expr diff(String variable) => Num(name == variable ? 1.0 : 0.0);

  @override
  Expr simplify() => this;

  @override
  bool hasVar(String variable) => name == variable;

  @override
  bool get isConst => false;

  @override
  double? get constValue => null;

  @override
  bool operator ==(Object other) => other is Var && name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => name;

  @override
  String format({bool compact = false}) => name;
}

/// Binary operation (+, -, *, /, ^)
class BinOp extends Expr {
  final String op;
  final Expr left;
  final Expr right;

  const BinOp(this.op, this.left, this.right);

  @override
  Expr diff(String variable) {
    switch (op) {
      case '+':
        return BinOp('+', left.diff(variable), right.diff(variable));
      case '-':
        return BinOp('-', left.diff(variable), right.diff(variable));
      case '*':
        // Product Rule: (fg)' = f'g + fg'
        return BinOp('+', BinOp('*', left.diff(variable), right),
            BinOp('*', left, right.diff(variable)));
      case '/':
        // Quotient Rule: (f/g)' = (f'g - fg') / g²
        return BinOp(
            '/',
            BinOp('-', BinOp('*', left.diff(variable), right),
                BinOp('*', left, right.diff(variable))),
            BinOp('^', right, const Num(2)));
      case '^':
        // Power Rule with chain rule consideration
        if (right.isConst) {
          // Simple power rule: (x^n)' = n*x^(n-1)
          final n = right.constValue!;
          return BinOp('*', BinOp('*', Num(n), BinOp('^', left, Num(n - 1))),
              left.diff(variable));
        } else if (left.isConst) {
          // Exponential: (a^g(x))' = a^g(x) * ln(a) * g'(x)
          return BinOp(
              '*', BinOp('*', this, Func('ln', left)), right.diff(variable));
        } else {
          // General: (f^g)' = f^g * (g' * ln(f) + g * f'/f)
          return BinOp(
              '*',
              this,
              BinOp('+', BinOp('*', right.diff(variable), Func('ln', left)),
                  BinOp('*', right, BinOp('/', left.diff(variable), left))));
        }
      default:
        throw ArgumentError('Unknown operator: $op');
    }
  }

  @override
  Expr simplify() {
    Expr sLeft = left.simplify();
    Expr sRight = right.simplify();

    // If both are constants, evaluate
    if (sLeft.isConst && sRight.isConst) {
      final l = sLeft.constValue!;
      final r = sRight.constValue!;
      switch (op) {
        case '+':
          return Num(l + r);
        case '-':
          return Num(l - r);
        case '*':
          return Num(l * r);
        case '/':
          return r != 0 ? Num(l / r) : this;
        case '^':
          return Num(pow(l, r).toDouble());
      }
    }

    switch (op) {
      case '+':
        if (_isZero(sLeft)) return sRight;
        if (_isZero(sRight)) return sLeft;
        if (sLeft == sRight) return BinOp('*', const Num(2), sLeft);

      case '-':
        if (_isZero(sLeft)) return Neg(sRight);
        if (_isZero(sRight)) return sLeft;
        if (sLeft == sRight) return const Num(0);

      case '*':
        if (_isZero(sLeft) || _isZero(sRight)) return const Num(0);
        if (_isOne(sLeft)) return sRight;
        if (_isOne(sRight)) return sLeft;
        if (sLeft is Num && sRight is Num) {
          return Num(sLeft.value * sRight.value);
        }
        // Combine: n * (n2 * x) -> (n * n2) * x
        if (sLeft is Num &&
            sRight is BinOp &&
            sRight.op == '*' &&
            sRight.left is Num) {
          return BinOp('*', Num(sLeft.value * (sRight.left as Num).value),
                  sRight.right)
              .simplify();
        }

      case '/':
        if (_isZero(sLeft)) return const Num(0);
        if (_isOne(sRight)) return sLeft;
        if (sLeft == sRight) return const Num(1);

      case '^':
        if (_isZero(sRight)) return const Num(1);
        if (_isOne(sRight)) return sLeft;
        if (_isZero(sLeft) && sRight.isConst && sRight.constValue! > 0) {
          return const Num(0);
        }
        if (_isOne(sLeft)) return const Num(1);
    }

    return BinOp(op, sLeft, sRight);
  }

  bool _isZero(Expr e) => e.isConst && e.constValue == 0;
  bool _isOne(Expr e) => e.isConst && e.constValue == 1;

  @override
  bool hasVar(String variable) =>
      left.hasVar(variable) || right.hasVar(variable);

  @override
  bool get isConst => left.isConst && right.isConst;

  @override
  double? get constValue {
    if (!isConst) return null;
    final l = left.constValue!;
    final r = right.constValue!;
    switch (op) {
      case '+':
        return l + r;
      case '-':
        return l - r;
      case '*':
        return l * r;
      case '/':
        return r != 0 ? l / r : null;
      case '^':
        return pow(l, r).toDouble();
      default:
        return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is BinOp &&
      op == other.op &&
      left == other.left &&
      right == other.right;

  @override
  int get hashCode => Object.hash(op, left, right);

  @override
  String toString() {
    final lStr = _wrapLeft(left);
    final rStr = _wrapRight(right);
    return '$lStr $op $rStr';
  }

  @override
  String format({bool compact = false}) {
    if (compact) {
      return '${left.format(compact: true)}$op${right.format(compact: true)}';
    }
    return toString();
  }

  String _wrapLeft(Expr e) {
    if (e is BinOp) {
      final prec = _precedence(op);
      final ePrec = _precedence(e.op);
      if (ePrec < prec) return '($e)';
      if (ePrec == prec && (op == '-' || op == '/')) return '($e)';
    }
    if (e is Neg) return '($e)';
    return e.toString();
  }

  String _wrapRight(Expr e) {
    if (e is BinOp) {
      final prec = _precedence(op);
      final ePrec = _precedence(e.op);
      if (ePrec < prec) return '($e)';
      if (ePrec == prec && (op == '-' || op == '/' || op == '^')) return '($e)';
    }
    if (e is Neg) return '($e)';
    return e.toString();
  }

  static int _precedence(String op) {
    switch (op) {
      case '+':
      case '-':
        return 1;
      case '*':
      case '/':
        return 2;
      case '^':
        return 3;
      default:
        return 0;
    }
  }
}

/// Unary negation (-x)
class Neg extends Expr {
  final Expr expr;

  const Neg(this.expr);

  @override
  Expr diff(String variable) => Neg(expr.diff(variable));

  @override
  Expr simplify() {
    final s = expr.simplify();
    if (s is Num) return Num(-s.value);
    if (s is Neg) return s.expr;
    // -1 * x -> -x (keep as Neg for cleaner output)
    if (s is BinOp && s.op == '*' && s.left is Num && s.left.constValue == 1) {
      return Neg(s.right);
    }
    return Neg(s);
  }

  @override
  bool hasVar(String variable) => expr.hasVar(variable);

  @override
  bool get isConst => expr.isConst;

  @override
  double? get constValue {
    if (!isConst) return null;
    final v = expr.constValue;
    return v != null ? -v : null;
  }

  @override
  bool operator ==(Object other) => other is Neg && expr == other.expr;

  @override
  int get hashCode => expr.hashCode;

  @override
  String toString() => '-$expr';

  @override
  String format({bool compact = false}) => '-${expr.format(compact: compact)}';
}

/// Function application (sin, cos, tan, ln, exp, etc.)
class Func extends Expr {
  final String name;
  final Expr arg;

  const Func(this.name, this.arg);

  @override
  Expr diff(String variable) {
    final inner = arg.diff(variable);

    switch (name) {
      case 'sin':
        // d/dx[sin(u)] = cos(u) * u'
        return BinOp('*', Func('cos', arg), inner);
      case 'cos':
        // d/dx[cos(u)] = -sin(u) * u'
        return BinOp('*', Neg(Func('sin', arg)), inner);
      case 'tan':
        // d/dx[tan(u)] = sec²(u) * u'
        return BinOp('*', BinOp('^', Func('sec', arg), const Num(2)), inner);
      case 'cot':
        // d/dx[cot(u)] = -csc²(u) * u'
        return BinOp(
            '*', Neg(BinOp('^', Func('csc', arg), const Num(2))), inner);
      case 'sec':
        // d/dx[sec(u)] = sec(u)*tan(u) * u'
        return BinOp(
            '*', BinOp('*', Func('sec', arg), Func('tan', arg)), inner);
      case 'csc':
        // d/dx[csc(u)] = -csc(u)*cot(u) * u'
        return BinOp(
            '*', Neg(BinOp('*', Func('csc', arg), Func('cot', arg))), inner);
      case 'arcsin':
      case 'asin':
        // d/dx[arcsin(u)] = u'/√(1-u²)
        return BinOp(
            '*',
            BinOp('/', const Num(1),
                Sqrt(BinOp('-', const Num(1), BinOp('^', arg, const Num(2))))),
            inner);
      case 'arccos':
      case 'acos':
        // d/dx[arccos(u)] = -u'/√(1-u²)
        return BinOp(
            '*',
            Neg(BinOp('/', const Num(1),
                Sqrt(BinOp('-', const Num(1), BinOp('^', arg, const Num(2)))))),
            inner);
      case 'arctan':
      case 'atan':
        // d/dx[arctan(u)] = u'/(1+u²)
        return BinOp(
            '*',
            BinOp('/', const Num(1),
                BinOp('+', const Num(1), BinOp('^', arg, const Num(2)))),
            inner);
      case 'sinh':
        // d/dx[sinh(u)] = cosh(u) * u'
        return BinOp('*', Func('cosh', arg), inner);
      case 'cosh':
        // d/dx[cosh(u)] = sinh(u) * u'
        return BinOp('*', Func('sinh', arg), inner);
      case 'tanh':
        // d/dx[tanh(u)] = sech²(u) * u'
        return BinOp('*', BinOp('^', Func('sech', arg), const Num(2)), inner);
      case 'sech':
        // d/dx[sech(u)] = -sech(u)*tanh(u) * u'
        return BinOp(
            '*', Neg(BinOp('*', Func('sech', arg), Func('tanh', arg))), inner);
      case 'csch':
        // d/dx[csch(u)] = -csch(u)*coth(u) * u'
        return BinOp(
            '*', Neg(BinOp('*', Func('csch', arg), Func('coth', arg))), inner);
      case 'coth':
        // d/dx[coth(u)] = -csch²(u) * u'
        return BinOp(
            '*', Neg(BinOp('^', Func('csch', arg), const Num(2))), inner);
      case 'ln':
      case 'log':
        // d/dx[ln(u)] = u'/u
        return BinOp('/', inner, arg);
      case 'log10':
      case 'log2':
        // d/dx[log_b(u)] = u'/(u*ln(b))
        final base = name == 'log10' ? 10.0 : 2.0;
        return BinOp('/', inner, BinOp('*', arg, Func('ln', Num(base))));
      case 'exp':
        // d/dx[exp(u)] = exp(u) * u'
        return BinOp('*', this, inner);
      case 'sqrt':
        // d/dx[√u] = u'/(2√u)
        return BinOp('/', inner, BinOp('*', const Num(2), Sqrt(arg)));
      case 'abs':
        // d/dx[|u|] = u'*u/|u|
        return BinOp('/', BinOp('*', inner, arg), Func('abs', arg));
      default:
        throw ArgumentError('Unknown function: $name');
    }
  }

  @override
  Expr simplify() {
    final sArg = arg.simplify();

    // Evaluate constant arguments
    if (sArg.isConst) {
      final v = sArg.constValue!;
      try {
        switch (name) {
          case 'sin':
            return Num(sin(v));
          case 'cos':
            return Num(cos(v));
          case 'tan':
            if (cos(v).abs() < 1e-10) return this;
            return Num(tan(v));
          case 'sec':
            if (cos(v).abs() < 1e-10) return this;
            return Num(1 / cos(v));
          case 'csc':
            if (sin(v).abs() < 1e-10) return this;
            return Num(1 / sin(v));
          case 'cot':
            if (sin(v).abs() < 1e-10) return this;
            return Num(cos(v) / sin(v));
          case 'ln':
          case 'log':
            if (v <= 0) return this;
            return Num(log(v));
          case 'exp':
            return Num(exp(v));
          case 'sqrt':
            if (v < 0) return this;
            return Num(sqrt(v));
          case 'abs':
            return Num(v.abs());
          case 'sinh':
            return Num(_sinh(v));
          case 'cosh':
            return Num(_cosh(v));
          case 'tanh':
            return Num(_tanh(v));
          case 'sech':
            return Num(_sech(v));
          case 'csch':
            if (v.abs() < 1e-10) return this;
            return Num(_csch(v));
          case 'coth':
            if (v.abs() < 1e-10) return this;
            return Num(_coth(v));
          case 'log10':
            if (v <= 0) return this;
            return Num(log(v) / log(10));
          case 'log2':
            if (v <= 0) return this;
            return Num(log(v) / log(2));
          case 'arcsin':
          case 'asin':
            if (v.abs() > 1) return this;
            return Num(asin(v));
          case 'arccos':
          case 'acos':
            if (v.abs() > 1) return this;
            return Num(acos(v));
          case 'arctan':
          case 'atan':
            return Num(atan(v));
        }
      } catch (e) {
        return this;
      }
    }

    // ln(e^x) = x
    if (name == 'ln' && sArg is Func && sArg.name == 'exp') {
      return sArg.arg;
    }
    // exp(ln(x)) = x
    if (name == 'exp' && sArg is Func && sArg.name == 'ln') {
      return sArg.arg;
    }
    // sqrt(x^2) = |x|
    if (name == 'sqrt' &&
        sArg is BinOp &&
        sArg.op == '^' &&
        sArg.right == const Num(2)) {
      return Abs(sArg.left);
    }
    // sin(0) = 0, cos(0) = 1, etc. (redundant but safe)

    return Func(name, sArg);
  }

  @override
  bool hasVar(String variable) => arg.hasVar(variable);

  @override
  bool get isConst => arg.isConst;

  @override
  double? get constValue => null;

  @override
  bool operator ==(Object other) =>
      other is Func && name == other.name && arg == other.arg;

  @override
  int get hashCode => Object.hash(name, arg);

  @override
  String toString() => '$name($arg)';

  @override
  String format({bool compact = false}) =>
      '$name(${arg.format(compact: compact)})';
}

/// Logarithm with explicit base: log_b(x)
class LogBase extends Expr {
  final Expr base;
  final Expr arg;

  const LogBase(this.base, this.arg);

  @override
  Expr diff(String variable) {
    // d/dx[log_b(u)] = u' / (u * ln(b))
    return BinOp('/', arg.diff(variable), BinOp('*', arg, Func('ln', base)));
  }

  @override
  Expr simplify() {
    final sBase = base.simplify();
    final sArg = arg.simplify();

    // If base is e, convert to ln
    if (sBase is Num && (sBase.value - e).abs() < 1e-10) {
      return Func('ln', sArg);
    }
    // If base is 10, use log10
    if (sBase is Num && sBase.value == 10) {
      return Func('log10', sArg);
    }
    // If base is 2, use log2
    if (sBase is Num && sBase.value == 2) {
      return Func('log2', sArg);
    }

    return LogBase(sBase, sArg);
  }

  @override
  bool hasVar(String variable) => base.hasVar(variable) || arg.hasVar(variable);

  @override
  bool get isConst => base.isConst && arg.isConst;

  @override
  double? get constValue => null;

  @override
  bool operator ==(Object other) =>
      other is LogBase && base == other.base && arg == other.arg;

  @override
  int get hashCode => Object.hash(base, arg);

  @override
  String toString() => 'log_${base}($arg)';

  @override
  String format({bool compact = false}) => toString();
}

/// Square root function (√x)
class Sqrt extends Expr {
  final Expr arg;

  const Sqrt(this.arg);

  @override
  Expr diff(String variable) {
    // d/dx[√u] = u'/(2√u)
    return BinOp('/', arg.diff(variable), BinOp('*', const Num(2), Sqrt(arg)));
  }

  @override
  Expr simplify() {
    final sArg = arg.simplify();
    if (sArg.isConst) {
      final v = sArg.constValue!;
      if (v >= 0) return Num(sqrt(v));
    }
    // sqrt(x^2) = |x|
    if (sArg is BinOp && sArg.op == '^' && sArg.right == const Num(2)) {
      return Abs(sArg.left);
    }
    return Sqrt(sArg);
  }

  @override
  bool hasVar(String variable) => arg.hasVar(variable);

  @override
  bool get isConst => arg.isConst;

  @override
  double? get constValue => null;

  @override
  bool operator ==(Object other) => other is Sqrt && arg == other.arg;

  @override
  int get hashCode => arg.hashCode;

  @override
  String toString() => '√($arg)';

  @override
  String format({bool compact = false}) => '√(${arg.format(compact: compact)})';
}

/// Absolute value function (|x|)
class Abs extends Expr {
  final Expr arg;

  const Abs(this.arg);

  @override
  Expr diff(String variable) {
    // d/dx[|u|] = u' * u / |u|
    return BinOp('*', arg.diff(variable), BinOp('/', arg, Abs(arg)));
  }

  @override
  Expr simplify() {
    final sArg = arg.simplify();
    if (sArg.isConst) {
      return Num(sArg.constValue!.abs());
    }
    return Abs(sArg);
  }

  @override
  bool hasVar(String variable) => arg.hasVar(variable);

  @override
  bool get isConst => arg.isConst;

  @override
  double? get constValue => null;

  @override
  bool operator ==(Object other) => other is Abs && arg == other.arg;

  @override
  int get hashCode => arg.hashCode;

  @override
  String toString() => '|$arg|';

  @override
  String format({bool compact = false}) => '|${arg.format(compact: compact)}|';
}

// ============ TOKENIZER ============

enum TokenType {
  number,
  variable,
  operator,
  lParen,
  rParen,
  comma,
  function,
  eof
}

class Token {
  final TokenType type;
  final String value;
  final int position;

  const Token(this.type, this.value, this.position);

  @override
  String toString() => 'Token($type, "$value")';
}

class ParseException implements Exception {
  final String message;
  final int position;

  ParseException(this.message, this.position);

  @override
  String toString() => 'ParseException: $message at position $position';
}

class Tokenizer {
  final String input;
  int _pos = 0;

  Tokenizer(this.input);

  List<Token> tokenize() {
    final tokens = <Token>[];

    while (_pos < input.length) {
      _skipWhitespace();
      if (_pos >= input.length) break;

      final char = input[_pos];
      final startPos = _pos;

      if (_isDigit(char) ||
          (char == '.' &&
              _pos + 1 < input.length &&
              _isDigit(input[_pos + 1]))) {
        tokens.add(_readNumber(startPos));
      } else if (_isLetter(char)) {
        tokens.add(_readIdentifier(startPos));
      } else if ('+-*/^'.contains(char)) {
        tokens.add(Token(TokenType.operator, char, startPos));
        _pos++;
      } else if (char == '(') {
        tokens.add(Token(TokenType.lParen, '(', startPos));
        _pos++;
      } else if (char == ')') {
        tokens.add(Token(TokenType.rParen, ')', startPos));
        _pos++;
      } else if (char == ',') {
        tokens.add(Token(TokenType.comma, ',', startPos));
        _pos++;
      } else {
        throw ParseException(
            'Unexpected character "$char" at position $startPos', startPos);
      }
    }

    tokens.add(Token(TokenType.eof, '', _pos));
    return tokens;
  }

  void _skipWhitespace() {
    while (_pos < input.length && input[_pos].contains(RegExp(r'\s'))) {
      _pos++;
    }
  }

  bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
  bool _isLetter(String c) {
    final code = c.toLowerCase().codeUnitAt(0);
    return code >= 97 && code <= 122;
  }

  Token _readNumber(int startPos) {
    final buffer = StringBuffer();
    bool hasDecimal = false;

    while (_pos < input.length) {
      final c = input[_pos];
      if (_isDigit(c)) {
        buffer.write(c);
        _pos++;
      } else if (c == '.' && !hasDecimal) {
        buffer.write(c);
        hasDecimal = true;
        _pos++;
      } else {
        break;
      }
    }

    return Token(TokenType.number, buffer.toString(), startPos);
  }

  Token _readIdentifier(int startPos) {
    final buffer = StringBuffer();

    while (_pos < input.length &&
        (_isLetter(input[_pos]) || _isDigit(input[_pos]))) {
      buffer.write(input[_pos]);
      _pos++;
    }

    final value = buffer.toString().toLowerCase();
    const functions = {
      'sin',
      'cos',
      'tan',
      'cot',
      'sec',
      'csc',
      'arcsin',
      'arccos',
      'arctan',
      'asin',
      'acos',
      'atan',
      'sinh',
      'cosh',
      'tanh',
      'sech',
      'csch',
      'coth',
      'ln',
      'log',
      'log10',
      'log2',
      'exp',
      'sqrt',
      'abs',
      'log_base'
    };

    final type =
        functions.contains(value) ? TokenType.function : TokenType.variable;
    return Token(type, value, startPos);
  }
}

// ============ PARSER ============

class Parser {
  final List<Token> tokens;
  int _current = 0;

  Parser(this.tokens);

  Expr parse() {
    final expr = _parseExpression();
    if (_current < tokens.length && tokens[_current].type != TokenType.eof) {
      throw ParseException(
          'Unexpected token: ${tokens[_current]}', tokens[_current].position);
    }
    return expr;
  }

  Expr _parseExpression() {
    return _parseAddSub();
  }

  Expr _parseAddSub() {
    var left = _parseMulDiv();

    while (_matchOperator('+') || _matchOperator('-')) {
      final op = tokens[_current - 1].value;
      final right = _parseMulDiv();
      left = BinOp(op, left, right);
    }

    return left;
  }

  Expr _parseMulDiv() {
    var left = _parseUnary();

    while (true) {
      if (_matchOperator('*') || _matchOperator('/')) {
        final op = tokens[_current - 1].value;
        final right = _parseUnary();
        left = BinOp(op, left, right);
      } else if (_isImplicitMul()) {
        final right = _parseUnary();
        left = BinOp('*', left, right);
      } else {
        break;
      }
    }

    return left;
  }

  bool _isImplicitMul() {
    if (_current >= tokens.length) return false;
    final next = tokens[_current];
    final prev = tokens[_current - 1];

    if (prev.type == TokenType.rParen) {
      return next.type == TokenType.lParen ||
          next.type == TokenType.number ||
          next.type == TokenType.variable ||
          next.type == TokenType.function;
    }

    if (prev.type == TokenType.number) {
      return next.type == TokenType.variable ||
          next.type == TokenType.function ||
          next.type == TokenType.lParen;
    }

    if (prev.type == TokenType.variable) {
      return next.type == TokenType.variable ||
          next.type == TokenType.function ||
          next.type == TokenType.lParen;
    }

    return false;
  }

  Expr _parseUnary() {
    if (_matchOperator('-')) {
      final expr = _parseUnary();
      return Neg(expr);
    }
    if (_matchOperator('+')) {
      return _parseUnary();
    }
    return _parsePower();
  }

  Expr _parsePower() {
    var base = _parsePrimary();

    if (_matchOperator('^')) {
      final exp = _parseUnary();
      base = BinOp('^', base, exp);
    }

    return base;
  }

  Expr _parsePrimary() {
    final token = _peek();

    switch (token.type) {
      case TokenType.number:
        _advance();
        return Num(double.parse(token.value));

      case TokenType.variable:
        _advance();
        return Var(token.value);

      case TokenType.function:
        return _parseFunction();

      case TokenType.lParen:
        _advance();
        final expr = _parseExpression();
        _expect(TokenType.rParen);
        return expr;

      case TokenType.eof:
        throw ParseException('Unexpected end of expression', token.position);

      default:
        throw ParseException('Unexpected token: $token', token.position);
    }
  }

  Expr _parseFunction() {
    final funcToken = _advance();
    final name = funcToken.value;

    _expect(TokenType.lParen);
    final arg = _parseExpression();

    if (name == 'log_base' && _match(TokenType.comma)) {
      final base = _parseExpression();
      _expect(TokenType.rParen);
      return LogBase(base, arg);
    }

    _expect(TokenType.rParen);

    if (name == 'sqrt') {
      return Sqrt(arg);
    }
    if (name == 'abs') {
      return Abs(arg);
    }

    return Func(name, arg);
  }

  Token _peek() => tokens[_current];
  Token _advance() => tokens[_current++];

  bool _matchOperator(String op) {
    if (_peek().type == TokenType.operator && _peek().value == op) {
      _advance();
      return true;
    }
    return false;
  }

  bool _match(TokenType type) {
    if (_peek().type == type) {
      _advance();
      return true;
    }
    return false;
  }

  void _expect(TokenType type) {
    if (_peek().type != type) {
      throw ParseException(
          'Expected $type, got ${_peek().type}', _peek().position);
    }
    _advance();
  }
}

// ============ STEP DATA CLASSES ============

enum StepType { original, identifyRule, applyRule, simplify, finalResult }

class DerivativeStep {
  final StepType type;
  final String description;
  final Expr expression;
  final String? rule;

  const DerivativeStep(
      {required this.type,
      required this.description,
      required this.expression,
      this.rule});

  @override
  String toString() => '[$type] $description: $expression';
}

class DerivativeSteps {
  final Expr original;
  final String variable;
  final Expr derivative;
  final List<DerivativeStep> steps;

  const DerivativeSteps(
      {required this.original,
      required this.variable,
      required this.derivative,
      required this.steps});
}

// ============ SOLVER CLASS ============

class DerivativeSolver {
  /// Parse an expression string into an AST
  static Expr parse(String expression) {
    final tokenizer = Tokenizer(expression);
    final tokens = tokenizer.tokenize();
    final parser = Parser(tokens);
    return parser.parse();
  }

  /// Compute the derivative of [expr] with respect to [variable]
  static Expr differentiate(Expr expr, String variable) {
    return expr.diff(variable);
  }

  /// Simplify an expression
  static Expr simplify(Expr expr) {
    return _deepSimplify(expr, 10);
  }

  static Expr _deepSimplify(Expr expr, int depth) {
    if (depth <= 0) return expr;

    Expr result = expr.simplify();

    for (int i = 0; i < depth; i++) {
      final newResult = result.simplify();
      if (newResult == result) break;
      result = newResult;
    }

    return result;
  }

  /// Full pipeline: parse -> differentiate -> simplify
  static Expr solve(String expression, String variable) {
    final parsed = parse(expression);
    final derivative = differentiate(parsed, variable);
    return simplify(derivative);
  }

  /// Get intermediate results for step-by-step
  static DerivativeSteps getSteps(String expression, String variable) {
    final parsed = parse(expression);
    return _generateSteps(parsed, variable);
  }

  static DerivativeSteps _generateSteps(Expr expr, String variable) {
    final steps = <DerivativeStep>[];

    steps.add(DerivativeStep(
        type: StepType.original,
        description:
            'Find the derivative of the function with respect to $variable',
        expression: expr,
        rule: null));

    final rules = _identifyRules(expr);
    for (final rule in rules) {
      steps.add(DerivativeStep(
          type: StepType.identifyRule,
          description: 'Identify the differentiation rule: $rule',
          expression: expr,
          rule: rule));
    }

    final rawDerivative = expr.diff(variable);
    steps.add(DerivativeStep(
        type: StepType.applyRule,
        description: 'Apply the differentiation rule(s)',
        expression: rawDerivative,
        rule: null));

    final simplifiedSteps = _generateSimplificationSteps(rawDerivative);
    steps.addAll(simplifiedSteps);

    final finalResult = simplify(rawDerivative);
    steps.add(DerivativeStep(
        type: StepType.finalResult,
        description: 'Final answer',
        expression: finalResult,
        rule: null));

    return DerivativeSteps(
        original: expr,
        variable: variable,
        derivative: finalResult,
        steps: steps);
  }

  static List<String> _identifyRules(Expr expr) {
    final rules = <String>[];
    _collectRules(expr, rules);
    return rules.toSet().toList();
  }

  static void _collectRules(Expr expr, List<String> rules) {
    if (expr is BinOp) {
      switch (expr.op) {
        case '+':
          rules.add('Sum/Difference Rule: d/dx[f(x) + g(x)] = f\'(x) + g\'(x)');
          _collectRules(expr.left, rules);
          _collectRules(expr.right, rules);
          break;
        case '-':
          rules.add('Sum/Difference Rule: d/dx[f(x) - g(x)] = f\'(x) - g\'(x)');
          _collectRules(expr.left, rules);
          _collectRules(expr.right, rules);
          break;
        case '*':
          rules
              .add('Product Rule: d/dx[f(x)·g(x)] = f\'(x)·g(x) + f(x)·g\'(x)');
          _collectRules(expr.left, rules);
          _collectRules(expr.right, rules);
          break;
        case '/':
          rules.add(
              'Quotient Rule: d/dx[f(x)/g(x)] = [f\'(x)·g(x) - f(x)·g\'(x)] / g²(x)');
          _collectRules(expr.left, rules);
          _collectRules(expr.right, rules);
          break;
        case '^':
          if (expr.right.isConst) {
            rules.add('Power Rule: d/dx[xⁿ] = n·xⁿ⁻¹');
          } else if (expr.left.isConst) {
            rules.add('Exponential Rule: d/dx[aᵍ⁽ˣ⁾] = aᵍ⁽ˣ⁾·ln(a)·g\'(x)');
          } else {
            rules
                .add('General Power Rule: d/dx[fᵍ] = fᵍ·(g\'·ln(f) + g·f\'/f)');
          }
          _collectRules(expr.left, rules);
          _collectRules(expr.right, rules);
          break;
      }
    } else if (expr is Func) {
      if (expr.arg.hasVar('x')) {
        rules.add('Chain Rule: d/dx[f(g(x))] = f\'(g(x))·g\'(x)');
      }
      switch (expr.name) {
        case 'sin':
          rules.add('Derivative of Sine: d/dx[sin(u)] = cos(u)');
          break;
        case 'cos':
          rules.add('Derivative of Cosine: d/dx[cos(u)] = -sin(u)');
          break;
        case 'tan':
          rules.add('Derivative of Tangent: d/dx[tan(u)] = sec²(u)');
          break;
        case 'cot':
          rules.add('Derivative of Cotangent: d/dx[cot(u)] = -csc²(u)');
          break;
        case 'sec':
          rules.add('Derivative of Secant: d/dx[sec(u)] = sec(u)·tan(u)');
          break;
        case 'csc':
          rules.add('Derivative of Cosecant: d/dx[csc(u)] = -csc(u)·cot(u)');
          break;
        case 'arcsin':
        case 'asin':
          rules.add('Derivative of Arcsine: d/dx[arcsin(u)] = 1/√(1-u²)');
          break;
        case 'arccos':
        case 'acos':
          rules.add('Derivative of Arccosine: d/dx[arccos(u)] = -1/√(1-u²)');
          break;
        case 'arctan':
        case 'atan':
          rules.add('Derivative of Arctangent: d/dx[arctan(u)] = 1/(1+u²)');
          break;
        case 'sinh':
          rules.add('Derivative of Hyperbolic Sine: d/dx[sinh(u)] = cosh(u)');
          break;
        case 'cosh':
          rules.add('Derivative of Hyperbolic Cosine: d/dx[cosh(u)] = sinh(u)');
          break;
        case 'tanh':
          rules.add(
              'Derivative of Hyperbolic Tangent: d/dx[tanh(u)] = sech²(u)');
          break;
        case 'sech':
          rules.add(
              'Derivative of Hyperbolic Secant: d/dx[sech(u)] = -sech(u)·tanh(u)');
          break;
        case 'csch':
          rules.add(
              'Derivative of Hyperbolic Cosecant: d/dx[csch(u)] = -csch(u)·coth(u)');
          break;
        case 'coth':
          rules.add(
              'Derivative of Hyperbolic Cotangent: d/dx[coth(u)] = -csch²(u)');
          break;
        case 'ln':
        case 'log':
          rules.add('Derivative of Natural Log: d/dx[ln(u)] = 1/u');
          break;
        case 'exp':
          rules.add('Derivative of Exponential: d/dx[eᵘ] = eᵘ');
          break;
        case 'sqrt':
          rules.add('Derivative of Square Root: d/dx[√u] = 1/(2√u)');
          break;
        case 'abs':
          rules.add('Derivative of Absolute Value: d/dx[|u|] = u/|u|');
          break;
      }
      _collectRules(expr.arg, rules);
    } else if (expr is Sqrt) {
      rules.add('Derivative of Square Root: d/dx[√u] = 1/(2√u)');
      _collectRules(expr.arg, rules);
    } else if (expr is Abs) {
      rules.add('Derivative of Absolute Value: d/dx[|u|] = u/|u|');
      _collectRules(expr.arg, rules);
    } else if (expr is LogBase) {
      rules.add('Logarithm Base Change: d/dx[log_b(u)] = 1/(u·ln(b))');
      _collectRules(expr.arg, rules);
    }
  }

  static List<DerivativeStep> _generateSimplificationSteps(Expr expr) {
    final steps = <DerivativeStep>[];
    var current = expr;

    for (int i = 0; i < 10; i++) {
      final simplified = current.simplify();
      if (simplified == current) break;

      steps.add(DerivativeStep(
          type: StepType.simplify,
          description: _describeSimplification(current, simplified),
          expression: simplified,
          rule: null));

      current = simplified;
    }

    return steps;
  }

  static String _describeSimplification(Expr before, Expr after) {
    if (before is BinOp && after is Num) {
      return 'Evaluate the constant expression: $before = $after';
    }
    if (before is BinOp && before.op == '*' && _isZeroExpr(before.left)) {
      return 'Any number multiplied by 0 equals 0';
    }
    if (before is BinOp && before.op == '*' && _isZeroExpr(before.right)) {
      return 'Any number multiplied by 0 equals 0';
    }
    if (before is BinOp && before.op == '*' && _isOneExpr(before.left)) {
      return 'Any number multiplied by 1 equals itself';
    }
    if (before is BinOp && before.op == '*' && _isOneExpr(before.right)) {
      return 'Any number multiplied by 1 equals itself';
    }
    if (before is BinOp && before.op == '+' && _isZeroExpr(before.left)) {
      return 'Adding 0 does not change the value';
    }
    if (before is BinOp && before.op == '+' && _isZeroExpr(before.right)) {
      return 'Adding 0 does not change the value';
    }
    if (before is BinOp && before.op == '^' && _isOneExpr(before.right)) {
      return 'Any number raised to power 1 equals itself';
    }
    if (before is BinOp && before.op == '^' && _isZeroExpr(before.right)) {
      return 'Any non-zero number raised to power 0 equals 1';
    }
    if (before is BinOp && before.op == '-' && before.left == before.right) {
      return 'A number minus itself equals 0';
    }
    if (before is Neg && after is Num) {
      return 'Apply the negation: $before = $after';
    }
    if (before is Func && after is Num) {
      return 'Evaluate ${before.name}(${before.arg}) = $after';
    }

    return 'Simplify: $before → $after';
  }

  static bool _isZeroExpr(Expr e) => e.isConst && e.constValue == 0;
  static bool _isOneExpr(Expr e) => e.isConst && e.constValue == 1;
}
