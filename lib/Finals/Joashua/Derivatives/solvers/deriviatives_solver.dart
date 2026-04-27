// =====================================================
// DERIVATIVE SOLVER - Core Engine
// Handles parsing, differentiation, and simplification
// =====================================================

import 'dart:math';

// ============ EXPRESSION TYPES (AST NODES) ===========
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
          // Handle e specially since ln(e) = 1
          if (left is Var) {
            final varName = (left as Var).name;
            if (varName == 'e') {
              return BinOp('*', this, right.diff(variable));
            }
          }
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
        if (sLeft is BinOp && sLeft.op == '*' && sLeft.left is Num && sRight is Num) {
          final numLeft = (sLeft.left as Num).value;
          final numRight = sRight.value;
          if (numLeft == numRight) {
            return sLeft.right.simplify();
          }
          if (numRight != 0 && (numLeft / numRight).round() == numLeft / numRight) {
            return BinOp('*', Num(numLeft / numRight), sLeft.right).simplify();
          }
        }
        if (sLeft is BinOp && sLeft.op == '*' && sLeft.right is Num && sRight is Num) {
          final numLeft = (sLeft.right as Num).value;
          final numRight = sRight.value;
          if (numLeft == numRight) {
            return sLeft.left.simplify();
          }
          if (numRight != 0 && (numLeft / numRight).round() == numLeft / numRight) {
            return BinOp('*', sLeft.left, Num(numLeft / numRight)).simplify();
          }
        }

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
      case 'exp':
        // d/dx[exp(u)] = exp(u) * u'
        return BinOp('*', this, inner);
      case 'sqrt':
        // d/dx[√u] = u'/(2√u)
        return BinOp('/', inner, BinOp('*', const Num(2), Sqrt(arg)));
      case 'abs':
        // d/dx[|u|] = u'*u/|u|
        return BinOp('/', BinOp('*', inner, arg), Func('abs', arg));
    }
    throw ArgumentError('Unknown function: $name');
  }

@override
  Expr simplify() {
    final sArg = arg.simplify();

    // Evaluate constant arguments
    if (sArg.isConst) {
      final v = sArg.constValue!;
      try {
        switch (name) {
          case 'exp':
            return Num(exp(v));
          case 'sqrt':
            if (v < 0) return this;
            return Num(sqrt(v));
          case 'abs':
            return Num(v.abs());
        }
      } catch (e) {
        return this;
      }
    }

    // sqrt(x^2) = |x|
    if (name == 'sqrt' &&
        sArg is BinOp &&
        sArg.op == '^' &&
        sArg.right == const Num(2)) {
      return Abs(sArg.left);
    }

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

/// Square root function (√x)
class Sqrt extends Expr {
  final Expr arg;

  const Sqrt(this.arg);

  @override
  Expr diff(String variable) {
    // d/dx[√u] = u'/(2√u)
    final innerDiff = arg.diff(variable);
    final result = BinOp('/', innerDiff, BinOp('*', const Num(2), Sqrt(arg)));
    return result;
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
      } else if (_isLetter(char) || char == '√') {
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
        (_isLetter(input[_pos]) || _isDigit(input[_pos]) || input[_pos] == '√')) {
      buffer.write(input[_pos]);
      _pos++;
    }

    var value = buffer.toString().toLowerCase();
    
    // Convert √ to sqrt
    if (value.contains('√')) {
      value = value.replaceAll('√', 'sqrt');
    }
    
    const functions = {
      'exp',
      'sqrt',
      'abs',
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
    String processed = _preprocessImplicitMultiplication(expression);
    final tokenizer = Tokenizer(processed);
    final tokens = tokenizer.tokenize();
    final parser = Parser(tokens);
    return parser.parse();
  }

  static String _preprocessImplicitMultiplication(String input) {
    String result = input;
    // Handle )(  - parenthesis followed by parenthesis
    result = result.replaceAllMapped(RegExp(r'(\))(\s*)(\()'), (m) => '${m[1]}*${m[3]}');
    // Handle )(  with no space
    result = result.replaceAllMapped(RegExp(r'(\))(\()'), (m) => '${m[1]}*${m[2]}');
    // Handle )number
    result = result.replaceAllMapped(RegExp(r'(\))(\d)'), (m) => '${m[1]}*${m[2]}');
    // Handle number(
    result = result.replaceAllMapped(RegExp(r'(\d)(\()'), (m) => '${m[1]}*${m[2]}');
    // Handle variableletter and variablenumber (only for single letters, not function names like ln, log, exp)
    result = result.replaceAllMapped(RegExp(r'(?<![a-zA-Z])([a-zA-Z])(\()'), (m) => '${m[1]}*${m[2]}');
    result = result.replaceAllMapped(RegExp(r'(?<![a-zA-Z])([a-zA-Z])(\d)'), (m) => '${m[1]}*${m[2]}');
    
    // Handle sqrt without parentheses: sqrtx -> sqrt(x), sqrt2 -> sqrt(2)
    result = result.replaceAllMapped(RegExp(r'sqrt([a-zA-Z])'), (m) => 'sqrt(${m[1]})');
    result = result.replaceAllMapped(RegExp(r'sqrt(\d)'), (m) => 'sqrt(${m[1]})');
    // Handle √ character directly: √x -> sqrt(x), √2 -> sqrt(2)
    result = result.replaceAllMapped(RegExp(r'√([a-zA-Z])'), (m) => 'sqrt(${m[1]})');
    result = result.replaceAllMapped(RegExp(r'√(\d)'), (m) => 'sqrt(${m[1]})');
    result = result.replaceAllMapped(RegExp(r'√(\()'), (m) => 'sqrt(');
    
    // Remove extra spaces
    result = result.replaceAll(RegExp(r'\s+'), '');
    return result;
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

  /// Smart rule detection - find the main rule for this expression
  static String _determineMainRule(Expr expr) {
    // Check if it's a simple power (polynomial)
    if (expr is BinOp && expr.op == '^' && expr.right.isConst) {
      return 'Power Rule: \\frac{d}{dx}x^n = n \\cdot x^{n-1}';
    }
    // Check if it's exponential (a^x)
    if (expr is BinOp && expr.op == '^' && expr.left.isConst && !expr.right.isConst) {
      return 'Exponential Rule: \\frac{d}{dx}a^x = a^x \\ln(a)';
    }
    // Check primary operation (left to right priority)
    if (expr is BinOp) {
      switch (expr.op) {
        case '/':
          return 'Quotient Rule: \\frac{d}{dx}\\frac{f}{g} = \\frac{f\'g - fg\'}{g^2}';
        case '*':
          if (expr.left.isConst || expr.right.isConst) {
            return 'Constant Multiple: \\frac{d}{dx}(c \\cdot f) = c \\cdot f\'';
          }
          return 'Product Rule: \\frac{d}{dx}(f \\cdot g) = f\'g + fg\'';
        case '+':
        case '-':
          if (_containsPower(expr)) {
            return 'Power Rule: \\frac{d}{dx}x^n = n \\cdot x^{n-1}';
          }
          return 'Sum Rule: \\frac{d}{dx}(f + g) = f\' + g\'';
      }
    }
    if (expr is Func) {
      if (expr.arg.hasVar('x')) {
        return 'Chain Rule: (f \\circ g)\' = f\'(g) \\cdot g\'';
      }
      if (expr.name == 'exp') {
        return 'Exponential: \\frac{d}{dx}e^u = e^u \\cdot u\'';
      }
      if (expr.name == 'sqrt') {
        return 'Square Root: \\frac{d}{dx}\\sqrt{u} = \\frac{u\'}{2\\sqrt{u}}';
      }
      return 'Function Derivative';
    }
    if (expr is Sqrt) {
      if (expr.arg.hasVar('x')) {
        return 'Chain Rule';
      }
      return 'Square Root Derivative';
    }
    return 'Basic Derivative';
  }

  static bool _containsPower(Expr expr) {
    if (expr is BinOp && expr.op == '^') return true;
    if (expr is BinOp) {
      return _containsPower(expr.left) || _containsPower(expr.right);
    }
    if (expr is Func) return _containsPower(expr.arg);
    if (expr is Sqrt) return _containsPower(expr.arg);
    return false;
  }

  static DerivativeSteps _generateSteps(Expr expr, String variable) {
    final steps = <DerivativeStep>[];
    final mainRule = _determineMainRule(expr);

    steps.add(DerivativeStep(
        type: StepType.original,
        description: 'Find derivative of f($variable) = ${expr.toString()}',
        expression: expr,
        rule: null));

    // Step 1: Show the rule being applied
    steps.add(DerivativeStep(
        type: StepType.identifyRule,
        description: 'Apply: $mainRule',
        expression: expr,
        rule: mainRule));

    // Step 2: Compute derivative
    final rawDerivative = expr.diff(variable);
    steps.add(DerivativeStep(
        type: StepType.applyRule,
        description: 'Compute derivative',
        expression: rawDerivative,
        rule: null));

    // Step 3: Simplify (if needed)
    final simplified = simplify(rawDerivative);
    if (simplified != rawDerivative) {
      steps.add(DerivativeStep(
          type: StepType.simplify,
          description: 'Simplify the result',
          expression: simplified,
          rule: null));
    }

    // Step 4: Final answer
    steps.add(DerivativeStep(
        type: StepType.finalResult,
        description: 'Derivative: f\'($variable) = ${simplified.toString()}',
        expression: simplified,
        rule: null));

    return DerivativeSteps(
        original: expr,
        variable: variable,
        derivative: simplified,
        steps: steps);
  }
}
