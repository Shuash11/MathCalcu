// slope_solver.dart
// Comprehensive solver for finding slopes using derivatives.
// Handles: explicit functions, implicit equations, and parametric equations.
//
// Author: Completed by a Senior Mathematician/Developer
// Usage:
//   dart slope_solver.dart
//   dart slope_solver.dart "y = x^3 - 2x + 1" x=2
//   dart slope_solver.dart "x^2 + y^2 = 25" x=3
//   dart slope_solver.dart "x=cos(t),y=sin(t)" t=1.5708

import 'dart:math' as math;
import 'dart:io';

// ==================== TOKENS ====================

enum TokenType {
  number,
  ident,
  plus,
  minus,
  star,
  slash,
  caret,
  lparen,
  rparen,
  equals,
  comma,
  eof,
}

class Token {
  final TokenType type;
  final String value;
  const Token(this.type, this.value);

  @override
  String toString() => 'Token($type, "$value")';
}

// ==================== TOKENIZER ====================

class Tokenizer {
  final String input;
  int pos = 0;

  static const knownFunctions = {
    'sin',
    'cos',
    'tan',
    'cot',
    'sec',
    'csc',
    'asin',
    'acos',
    'atan',
    'arcsin',
    'arccos',
    'arctan',
    'sinh',
    'cosh',
    'tanh',
    'ln',
    'log',
    'exp',
    'sqrt',
    'abs',
    'cbrt',
  };

  static const knownConstants = {'e', 'pi', 'π'};

  Tokenizer(this.input);

  List<Token> tokenize() {
    final tokens = <Token>[];
    while (pos < input.length) {
      final ch = input[pos];
      if (' \t\n\r'.contains(ch)) {
        pos++;
        continue;
      }
      switch (ch) {
        case '+':
          tokens.add(const Token(TokenType.plus, '+'));
          pos++;
          break;
        case '-':
          tokens.add(const Token(TokenType.minus, '-'));
          pos++;
          break;
        case '*':
          tokens.add(const Token(TokenType.star, '*'));
          pos++;
          break;
        case '/':
          tokens.add(const Token(TokenType.slash, '/'));
          pos++;
          break;
        case '^':
          tokens.add(const Token(TokenType.caret, '^'));
          pos++;
          break;
        case '(':
          tokens.add(const Token(TokenType.lparen, '('));
          pos++;
          break;
        case ')':
          tokens.add(const Token(TokenType.rparen, ')'));
          pos++;
          break;
        case '=':
          tokens.add(const Token(TokenType.equals, '='));
          pos++;
          break;
        case ',':
          tokens.add(const Token(TokenType.comma, ','));
          pos++;
          break;
        default:
          if (_isDigit(ch) || ch == '.') {
            tokens.add(_readNumber());
          } else if (_isAlpha(ch) || ch == '_') {
            tokens.add(_readIdent());
          } else {
            throw FormatException(
                'Unexpected character "$ch" at position $pos');
          }
      }
    }
    tokens.add(const Token(TokenType.eof, ''));
    return tokens;
  }

  Token _readNumber() {
    final start = pos;
    bool hasDot = false;
    while (pos < input.length) {
      final ch = input[pos];
      if (_isDigit(ch)) {
        pos++;
      } else if (ch == '.' && !hasDot) {
        hasDot = true;
        pos++;
      } else {
        break;
      }
    }
    return Token(TokenType.number, input.substring(start, pos));
  }

  Token _readIdent() {
    final start = pos;
    while (pos < input.length &&
        (_isAlpha(input[pos]) || _isDigit(input[pos]) || input[pos] == '_')) {
      pos++;
    }
    return Token(TokenType.ident, input.substring(start, pos));
  }

  bool _isDigit(String ch) => ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
  bool _isAlpha(String ch) {
    final c = ch.codeUnitAt(0);
    return (c >= 65 && c <= 90) || (c >= 97 && c <= 122);
  }
}

// ==================== AST NODES ====================

abstract class Expr {
  const Expr();
  String toMathString();
  Expr clone();

  @override
  String toString() => toMathString();
}

/// Numeric constant: 3, -2.5, 0, 100
class Num extends Expr {
  final double value;
  const Num(this.value);

  @override
  String toMathString() {
    if (value == value.truncateToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
  }

  @override
  Expr clone() => Num(value);

  bool get isZero => value == 0;
  bool get isOne => value == 1;
  bool get isMinusOne => value == -1;
  bool get isInteger => value == value.truncateToDouble();
}

/// Variable: x, y, t, theta, etc.
class Var extends Expr {
  final String name;
  const Var(this.name);

  @override
  String toMathString() => name;

  @override
  Expr clone() => Var(name);
}

/// Named constant: e, pi
class Const extends Expr {
  final String name;
  final double numericValue;
  const Const(this.name, this.numericValue);

  @override
  String toMathString() => name;

  @override
  Expr clone() => Const(name, numericValue);
}

/// Binary operation: +, -, *, /
class BinOp extends Expr {
  final Expr left;
  final String op;
  final Expr right;
  const BinOp(this.left, this.op, this.right);

  @override
  String toMathString() {
    String l = left.toMathString();
    String r = right.toMathString();
    if (left is BinOp && _prec((left as BinOp).op) < _prec(op)) {
      l = '($l)';
    }
    if (left is UnaryNeg && _prec('*') <= _prec(op)) {
      l = '($l)';
    }
    if (right is BinOp) {
      final rp = _prec((right as BinOp).op);
      if (rp < _prec(op) || (rp == _prec(op) && (op == '-' || op == '/'))) {
        r = '($r)';
      }
    }
    if (right is UnaryNeg && (op == '+' || op == '-')) {
      r = '($r)';
    }
    return '$l $op $r';
  }

  static int prec(String op) => const {'+': 1, '-': 1, '*': 2, '/': 2}[op] ?? 0;
  int _prec(String op) => prec(op);

  @override
  Expr clone() => BinOp(left.clone(), op, right.clone());
}

/// Power: base^exponent
class Pow extends Expr {
  final Expr base;
  final Expr exponent;
  const Pow(this.base, this.exponent);

  @override
  String toMathString() {
    String b = base.toMathString();
    String e = exponent.toMathString();
    if (base is BinOp || base is UnaryNeg) b = '($b)';
    if (exponent is BinOp || exponent is UnaryNeg) e = '($e)';
    return '$b^$e';
  }

  @override
  Expr clone() => Pow(base.clone(), exponent.clone());
}

/// Unary negation: -expr
class UnaryNeg extends Expr {
  final Expr operand;
  const UnaryNeg(this.operand);

  @override
  String toMathString() {
    if (operand is BinOp || operand is Pow)
      return '-(${operand.toMathString()})';
    return '-${operand.toMathString()}';
  }

  @override
  Expr clone() => UnaryNeg(operand.clone());
}

/// Function call: sin(x), ln(x), sqrt(x), etc.
class Func extends Expr {
  final String name;
  final Expr arg;
  const Func(this.name, this.arg);

  @override
  String toMathString() => '$name(${arg.toMathString()})';

  @override
  Expr clone() => Func(name, arg.clone());
}

/// Derivative symbol used during implicit differentiation: dy/dx
class DerivSym extends Expr {
  final String varName;
  const DerivSym(this.varName);

  @override
  String toMathString() => varName == 'y' ? 'dy/dx' : 'd$varName/dx';

  @override
  Expr clone() => DerivSym(varName);
}

// ==================== PARSER ====================

class Parser {
  final List<Token> tokens;
  int pos = 0;

  Parser(this.tokens);

  /// Parse a full equation or expression.
  /// Returns (leftExpr, rightExpr?) where rightExpr is null if no '=' found.
  (Expr, Expr?) parse() {
    final left = parseAdditive();
    if (current.type == TokenType.equals) {
      advance();
      final right = parseAdditive();
      return (left, right);
    }
    return (left, null);
  }

  Expr parseAdditive() {
    Expr left = parseMultiplicative();
    while (current.type == TokenType.plus || current.type == TokenType.minus) {
      final op = current.value;
      advance();
      final right = parseMultiplicative();
      left = BinOp(left, op, right);
    }
    return left;
  }

  Expr parseMultiplicative() {
    Expr left = parseFactor();
    while (current.type == TokenType.star || current.type == TokenType.slash) {
      final op = current.value;
      advance();
      final right = parseFactor();
      left = BinOp(left, op, right);
    }
    return left;
  }

  /// Factor handles implicit multiplication: 2x, 3sin(x), (a)(b), etc.
  Expr parseFactor() {
    final parts = <Expr>[];
    parts.add(parseUnary());

    while (_canStartAtom(current) && current.type != TokenType.eof) {
      parts.add(parseUnary());
    }

    if (parts.length == 1) return parts.first;
    Expr result = parts[0];
    for (int i = 1; i < parts.length; i++) {
      result = BinOp(result, '*', parts[i]);
    }
    return result;
  }

  bool _canStartAtom(Token t) {
    return t.type == TokenType.number ||
        t.type == TokenType.ident ||
        t.type == TokenType.lparen;
  }

  Expr parseUnary() {
    if (current.type == TokenType.minus) {
      advance();
      final operand = parseUnary();
      return UnaryNeg(operand);
    }
    if (current.type == TokenType.plus) {
      advance();
      return parseUnary();
    }
    return parsePower();
  }

  /// Power is right-associative: 2^3^4 = 2^(3^4)
  Expr parsePower() {
    Expr base = parseAtom();
    if (current.type == TokenType.caret) {
      advance();
      final exponent = parseUnary();
      return Pow(base, exponent);
    }
    return base;
  }

  Expr parseAtom() {
    final t = current;

    if (t.type == TokenType.number) {
      advance();
      return Num(double.parse(t.value));
    }

    if (t.type == TokenType.lparen) {
      advance();
      final expr = parseAdditive();
      _expect(TokenType.rparen);
      return expr;
    }

    if (t.type == TokenType.ident) {
      final name = t.value;

      if (Tokenizer.knownFunctions.contains(name)) {
        advance();
        _expect(TokenType.lparen);
        final arg = parseAdditive();
        _expect(TokenType.rparen);
        return Func(name, arg);
      }

      if (Tokenizer.knownConstants.contains(name)) {
        advance();
        switch (name) {
          case 'e':
            return Const('e', math.e);
          case 'pi':
          case 'π':
            return Const('pi', math.pi);
        }
      }

      advance();

      if (current.type == TokenType.lparen) {
        // Function definition like f(x) = ...
        advance();
        while (
            current.type != TokenType.rparen && current.type != TokenType.eof) {
          advance();
        }
        if (current.type == TokenType.rparen) advance();
        return Var('y');
      }

      return Var(name);
    }

    throw FormatException(
        'Unexpected token "${t.value}" (type: ${t.type}) at position $pos');
  }

  Token get current =>
      pos < tokens.length ? tokens[pos] : const Token(TokenType.eof, '');

  void advance() {
    if (pos < tokens.length) pos++;
  }

  void _expect(TokenType type) {
    if (current.type != type) {
      throw FormatException(
          'Expected ${type.name} but got "${current.value}" at position $pos');
    }
    advance();
  }
}

// ==================== EXPRESSION UTILITIES ====================

class ExprUtils {
  static bool containsVar(Expr e, String varName) {
    if (e is Var) return e.name == varName;
    if (e is Num || e is Const || e is DerivSym) return false;
    if (e is BinOp)
      return containsVar(e.left, varName) || containsVar(e.right, varName);
    if (e is Pow)
      return containsVar(e.base, varName) || containsVar(e.exponent, varName);
    if (e is UnaryNeg) return containsVar(e.operand, varName);
    if (e is Func) return containsVar(e.arg, varName);
    return false;
  }

  static bool containsDerivSym(Expr e) {
    if (e is DerivSym) return true;
    if (e is Num || e is Const || e is Var) return false;
    if (e is BinOp)
      return containsDerivSym(e.left) || containsDerivSym(e.right);
    if (e is Pow)
      return containsDerivSym(e.base) || containsDerivSym(e.exponent);
    if (e is UnaryNeg) return containsDerivSym(e.operand);
    if (e is Func) return containsDerivSym(e.arg);
    return false;
  }

  static Set<String> collectVars(Expr e) {
    if (e is Var) return {e.name};
    if (e is Num || e is Const || e is DerivSym) return {};
    if (e is BinOp) return collectVars(e.left).union(collectVars(e.right));
    if (e is Pow) return collectVars(e.base).union(collectVars(e.exponent));
    if (e is UnaryNeg) return collectVars(e.operand);
    if (e is Func) return collectVars(e.arg);
    return {};
  }

  static Expr substitute(Expr e, String varName, Expr replacement) {
    if (e is Var && e.name == varName) return replacement.clone();
    if (e is Num || e is Const || e is DerivSym) return e.clone();
    if (e is Var) return e.clone();
    if (e is BinOp) {
      return BinOp(
        substitute(e.left, varName, replacement),
        e.op,
        substitute(e.right, varName, replacement),
      );
    }
    if (e is Pow) {
      return Pow(
        substitute(e.base, varName, replacement),
        substitute(e.exponent, varName, replacement),
      );
    }
    if (e is UnaryNeg)
      return UnaryNeg(substitute(e.operand, varName, replacement));
    if (e is Func) return Func(e.name, substitute(e.arg, varName, replacement));
    return e.clone();
  }

  static double evaluate(Expr e, Map<String, double> values) {
    if (e is Num) return e.value;
    if (e is Const) return e.numericValue;
    if (e is Var) {
      if (values.containsKey(e.name)) return values[e.name]!;
      throw Exception('Undefined variable: ${e.name}');
    }
    if (e is DerivSym) {
      final key = e.toMathString();
      if (values.containsKey(key)) return values[key]!;
      throw Exception('Undefined derivative symbol: $key');
    }
    if (e is BinOp) {
      final l = evaluate(e.left, values);
      final r = evaluate(e.right, values);
      switch (e.op) {
        case '+':
          return l + r;
        case '-':
          return l - r;
        case '*':
          return l * r;
        case '/':
          if (r == 0) throw Exception('Division by zero');
          return l / r;
        default:
          throw Exception('Unknown operator: ${e.op}');
      }
    }
    if (e is Pow) {
      final b = evaluate(e.base, values);
      final exp = evaluate(e.exponent, values);
      return math.pow(b, exp).toDouble();
    }
    double sinh(double x) => (math.exp(x) - math.exp(-x)) / 2;
    double cosh(double x) => (math.exp(x) + math.exp(-x)) / 2;
    double tanh(double x) => sinh(x) / cosh(x);

    if (e is UnaryNeg) return -evaluate(e.operand, values);
    if (e is Func) {
      final a = evaluate(e.arg, values);
      switch (e.name) {
        case 'sin':
          return math.sin(a);
        case 'cos':
          return math.cos(a);
        case 'tan':
          return math.tan(a);
        case 'cot':
          return 1 / math.tan(a);
        case 'sec':
          return 1 / math.cos(a);
        case 'csc':
          return 1 / math.sin(a);
        case 'asin':
        case 'arcsin':
          return math.asin(a);
        case 'acos':
        case 'arccos':
          return math.acos(a);
        case 'atan':
        case 'arctan':
          return math.atan(a);
        case 'sinh':
          return sinh(a);
        case 'cosh':
          return cosh(a);
        case 'tanh':
          return tanh(a);

        case 'ln':
          if (a <= 0) throw Exception('ln of non-positive number');
          return math.log(a);
        case 'log':
          if (a <= 0) throw Exception('log of non-positive number');
          return math.log(a) / math.ln10;
        case 'exp':
          return math.exp(a);
        case 'sqrt':
          if (a < 0) throw Exception('sqrt of negative number');
          return math.sqrt(a);
        case 'abs':
          return a.abs();
        case 'cbrt':
          return _cbrt(a);
        default:
          throw Exception('Unknown function: ${e.name}');
      }
    }
    throw Exception('Cannot evaluate expression: ${e.toMathString()}');
  }

  static double _cbrt(double x) {
    return x < 0
        ? -math.pow(-x, 1 / 3).toDouble()
        : math.pow(x, 1 / 3).toDouble();
  }
}

// ==================== SIMPLIFIER ====================

class Simplifier {
  static Expr simplify(Expr e) {
    Expr prev;
    Expr curr = e;
    int iterations = 0;
    do {
      prev = curr;
      curr = _simplifyOnce(curr);
      iterations++;
    } while (curr.toMathString() != prev.toMathString() && iterations < 20);
    return curr;
  }

  static Expr _simplifyOnce(Expr e) {
    if (e is Num || e is Const || e is Var || e is DerivSym) return e;

    if (e is UnaryNeg) {
      final inner = _simplifyOnce(e.operand);
      if (inner is UnaryNeg) return inner.operand;
      if (inner is Num) return Num(-inner.value);
      if (inner is BinOp && inner.op == '-')
        return BinOp(inner.right, '-', inner.left);
      if (inner is BinOp && inner.op == '*' && inner.left is Num) {
        return BinOp(Num(-(inner.left as Num).value), '*', inner.right);
      }
      return UnaryNeg(inner);
    }

    if (e is Func) return Func(e.name, _simplifyOnce(e.arg));

    if (e is Pow) {
      final b = _simplifyOnce(e.base);
      final exp = _simplifyOnce(e.exponent);
      if (exp is Num && exp.isZero) return const Num(1);
      if (exp is Num && exp.isOne) return b;
      if (b is Num && b.isZero && exp is Num && exp.value > 0)
        return const Num(0);
      if (b is Num && b.isOne) return const Num(1);
      if (b is Num && exp is Num) {
        final result = math.pow(b.value, exp.value);
        if (result.isFinite) return Num(result.toDouble());
      }
      if (b is Pow && exp is Num) {
        return _simplifyOnce(Pow(b.base, BinOp(b.exponent, '*', exp)));
      }
      return Pow(b, exp);
    }

    if (e is BinOp) {
      final left = _simplifyOnce(e.left);
      final right = _simplifyOnce(e.right);
      return _simplifyBinOp(left, e.op, right);
    }

    return e;
  }

  static Expr _simplifyBinOp(Expr left, String op, Expr right) {
    if (left is Num && right is Num) {
      switch (op) {
        case '+':
          return Num(left.value + right.value);
        case '-':
          return Num(left.value - right.value);
        case '*':
          return Num(left.value * right.value);
        case '/':
          if (right.value != 0) return Num(left.value / right.value);
          break;
      }
    }

    switch (op) {
      case '+':
        if (left is Num && left.isZero) return right;
        if (right is Num && right.isZero) return left;
        if (right is UnaryNeg) return _simplifyBinOp(left, '-', right.operand);
        if (left is UnaryNeg) return _simplifyBinOp(right, '-', left.operand);
        break;

      case '-':
        if (left is Num && left.isZero) return UnaryNeg(right);
        if (right is Num && right.isZero) return left;
        if (left.toMathString() == right.toMathString()) return const Num(0);
        if (right is UnaryNeg) return _simplifyBinOp(left, '+', right.operand);
        break;

      case '*':
        if (left is Num && left.isZero) return const Num(0);
        if (right is Num && right.isZero) return const Num(0);
        if (left is Num && left.isOne) return right;
        if (right is Num && right.isOne) return left;
        if (left is Num && left.isMinusOne) return UnaryNeg(right);
        if (right is Num && right.isMinusOne) return UnaryNeg(left);
        if (left is Num &&
            right is BinOp &&
            right.op == '*' &&
            right.left is Num) {
          return _simplifyBinOp(
              Num(left.value * (right.left as Num).value), '*', right.right);
        }
        if (right is Num &&
            left is BinOp &&
            left.op == '*' &&
            left.left is Num) {
          return _simplifyBinOp(
              Num((left.left as Num).value * right.value), '*', left.right);
        }
        if (right is BinOp && right.op == '/') {
          return _simplifyBinOp(BinOp(left, '*', right.left), '/', right.right);
        }
        if (left is BinOp && left.op == '/') {
          return _simplifyBinOp(BinOp(left.left, '*', right), '/', left.right);
        }
        if (left is UnaryNeg)
          return UnaryNeg(_simplifyBinOp(left.operand, '*', right));
        if (right is UnaryNeg)
          return UnaryNeg(_simplifyBinOp(left, '*', right.operand));
        break;

      case '/':
        if (left is Num && left.isZero) return const Num(0);
        if (right is Num && right.isOne) return left;
        if (left.toMathString() == right.toMathString()) return const Num(1);
        if (left is BinOp &&
            left.op == '*' &&
            left.right.toMathString() == right.toMathString()) return left.left;
        if (left is BinOp &&
            left.op == '*' &&
            right is BinOp &&
            right.op == '*') {
          if (left.right.toMathString() == right.right.toMathString()) {
            return _simplifyBinOp(left.left, '/', right.left);
          }
        }
        if (left is UnaryNeg && right is! UnaryNeg) {
          return UnaryNeg(_simplifyBinOp(left.operand, '/', right));
        }
        if (right is UnaryNeg && left is! UnaryNeg) {
          return UnaryNeg(_simplifyBinOp(left, '/', right.operand));
        }
        if (left is UnaryNeg && right is UnaryNeg) {
          return _simplifyBinOp(left.operand, '/', right.operand);
        }
        if (left is BinOp && left.op == '/') {
          return _simplifyBinOp(left.left, '/', BinOp(left.right, '*', right));
        }
        if (right is BinOp && right.op == '/') {
          return _simplifyBinOp(BinOp(left, '*', right.right), '/', right.left);
        }
        break;
    }

    return BinOp(left, op, right);
  }

  /// Separate an expression into the coefficient of DerivSym and the remainder.
  /// Returns (coeffOfDeriv, remainder) such that e = coeffOfDeriv * dy/dx + remainder
  static (Expr, Expr) extractDerivCoeff(Expr e, String derivVar) {
    if (e is DerivSym && e.varName == derivVar)
      return (const Num(1), const Num(0));
    if (!ExprUtils.containsDerivSym(e)) return (const Num(0), e);

    if (e is UnaryNeg) {
      final (c, r) = extractDerivCoeff(e.operand, derivVar);
      return (simplify(UnaryNeg(c)), simplify(UnaryNeg(r)));
    }
    if (e is BinOp) {
      if (e.op == '+') {
        final (lc, lr) = extractDerivCoeff(e.left, derivVar);
        final (rc, rr) = extractDerivCoeff(e.right, derivVar);
        return (simplify(BinOp(lc, '+', rc)), simplify(BinOp(lr, '+', rr)));
      }
      if (e.op == '-') {
        final (lc, lr) = extractDerivCoeff(e.left, derivVar);
        final (rc, rr) = extractDerivCoeff(e.right, derivVar);
        return (simplify(BinOp(lc, '-', rc)), simplify(BinOp(lr, '-', rr)));
      }
      if (e.op == '*') {
        final leftHas = ExprUtils.containsDerivSym(e.left);
        final rightHas = ExprUtils.containsDerivSym(e.right);
        if (!leftHas && rightHas) {
          final (rc, rr) = extractDerivCoeff(e.right, derivVar);
          return (
            simplify(BinOp(e.left, '*', rc)),
            simplify(BinOp(e.left, '*', rr))
          );
        }
        if (leftHas && !rightHas) {
          final (lc, lr) = extractDerivCoeff(e.left, derivVar);
          return (
            simplify(BinOp(lc, '*', e.right)),
            simplify(BinOp(lr, '*', e.right))
          );
        }
        if (leftHas) {
          final (lc, lr) = extractDerivCoeff(e.left, derivVar);
          return (
            simplify(BinOp(lc, '*', e.right)),
            simplify(BinOp(lr, '*', e.right))
          );
        }
      }
      if (e.op == '/') {
        final numHas = ExprUtils.containsDerivSym(e.left);
        final denHas = ExprUtils.containsDerivSym(e.right);
        if (!denHas && numHas) {
          final (nc, nr) = extractDerivCoeff(e.left, derivVar);
          return (
            simplify(BinOp(nc, '/', e.right)),
            simplify(BinOp(nr, '/', e.right))
          );
        }
      }
    }
    if (ExprUtils.containsDerivSym(e)) return (e, const Num(0));
    return (const Num(0), e);
  }
}

// ==================== DIFFERENTIATOR ====================

class Differentiator {
  static Expr differentiate(
    Expr e,
    String varName, {
    Set<String> dependentVars = const {},
  }) {
    if (e is Num) return const Num(0);
    if (e is Const) return const Num(0);

    if (e is Var) {
      if (e.name == varName) return const Num(1);
      if (dependentVars.contains(e.name)) return DerivSym(e.name);
      return const Num(0);
    }

    if (e is DerivSym) return const Num(0);

    if (e is UnaryNeg) {
      return Simplifier.simplify(
        UnaryNeg(
            differentiate(e.operand, varName, dependentVars: dependentVars)),
      );
    }

    if (e is BinOp && (e.op == '+' || e.op == '-')) {
      return Simplifier.simplify(BinOp(
        differentiate(e.left, varName, dependentVars: dependentVars),
        e.op,
        differentiate(e.right, varName, dependentVars: dependentVars),
      ));
    }

    if (e is BinOp && e.op == '*') {
      final df = differentiate(e.left, varName, dependentVars: dependentVars);
      final dg = differentiate(e.right, varName, dependentVars: dependentVars);
      return Simplifier.simplify(BinOp(
        BinOp(df, '*', e.right.clone()),
        '+',
        BinOp(e.left.clone(), '*', dg),
      ));
    }

    if (e is BinOp && e.op == '/') {
      final df = differentiate(e.left, varName, dependentVars: dependentVars);
      final dg = differentiate(e.right, varName, dependentVars: dependentVars);
      return Simplifier.simplify(BinOp(
        BinOp(
          BinOp(df, '*', e.right.clone()),
          '-',
          BinOp(e.left.clone(), '*', dg),
        ),
        '/',
        Pow(e.right.clone(), const Num(2)),
      ));
    }

    if (e is Pow) return _differentiatePow(e, varName, dependentVars);
    if (e is Func) return _differentiateFunc(e, varName, dependentVars);

    throw Exception('Cannot differentiate: ${e.toMathString()}');
  }

  static Expr _differentiatePow(
      Pow e, String varName, Set<String> dependentVars) {
    final baseHasVar = ExprUtils.containsVar(e.base, varName) ||
        _hasDependentVar(e.base, varName, dependentVars);
    final expHasVar = ExprUtils.containsVar(e.exponent, varName) ||
        _hasDependentVar(e.exponent, varName, dependentVars);

    if (!baseHasVar && !expHasVar) return const Num(0);

    // Power rule: d/dx[f^n] = n * f^(n-1) * f'
    if (baseHasVar && !expHasVar) {
      final df = differentiate(e.base, varName, dependentVars: dependentVars);
      return Simplifier.simplify(BinOp(
        BinOp(
          e.exponent.clone(),
          '*',
          Pow(e.base.clone(), BinOp(e.exponent.clone(), '-', const Num(1))),
        ),
        '*',
        df,
      ));
    }

    // Exponential rule: d/dx[a^g] = a^g * ln(a) * g'
    if (!baseHasVar && expHasVar) {
      final dg =
          differentiate(e.exponent, varName, dependentVars: dependentVars);
      return Simplifier.simplify(BinOp(
        BinOp(
          Pow(e.base.clone(), e.exponent.clone()),
          '*',
          Func('ln', e.base.clone()),
        ),
        '*',
        dg,
      ));
    }

    // General rule: d/dx[f^g] = f^g * (g'*ln(f) + g*f'/f)
    final df = differentiate(e.base, varName, dependentVars: dependentVars);
    final dg = differentiate(e.exponent, varName, dependentVars: dependentVars);
    return Simplifier.simplify(BinOp(
      Pow(e.base.clone(), e.exponent.clone()),
      '*',
      BinOp(
        BinOp(dg, '*', Func('ln', e.base.clone())),
        '+',
        BinOp(BinOp(e.exponent.clone(), '*', df), '/', e.base.clone()),
      ),
    ));
  }

  static bool _hasDependentVar(
      Expr e, String varName, Set<String> dependentVars) {
    for (final dv in dependentVars) {
      if (ExprUtils.containsVar(e, dv)) return true;
    }
    return false;
  }

  static Expr _differentiateFunc(
      Func e, String varName, Set<String> dependentVars) {
    final du = differentiate(e.arg, varName, dependentVars: dependentVars);
    final u = e.arg.clone();

    Expr outerDeriv;
    switch (e.name) {
      case 'sin':
        outerDeriv = Func('cos', u);
        break;
      case 'cos':
        outerDeriv = UnaryNeg(Func('sin', u));
        break;
      case 'tan':
        outerDeriv =
            BinOp(const Num(1), '/', Pow(Func('cos', u), const Num(2)));
        break;
      case 'cot':
        outerDeriv = UnaryNeg(
          BinOp(const Num(1), '/', Pow(Func('sin', u), const Num(2))),
        );
        break;
      case 'sec':
        outerDeriv = BinOp(
          Func('sin', u.clone()),
          '/',
          Pow(Func('cos', u), const Num(2)),
        );
        break;
      case 'csc':
        outerDeriv = UnaryNeg(BinOp(
          Func('cos', u.clone()),
          '/',
          Pow(Func('sin', u), const Num(2)),
        ));
        break;
      case 'asin':
      case 'arcsin':
        outerDeriv = BinOp(
          const Num(1),
          '/',
          Func('sqrt', BinOp(const Num(1), '-', Pow(u, const Num(2)))),
        );
        break;
      case 'acos':
      case 'arccos':
        outerDeriv = UnaryNeg(BinOp(
          const Num(1),
          '/',
          Func('sqrt', BinOp(const Num(1), '-', Pow(u, const Num(2)))),
        ));
        break;
      case 'atan':
      case 'arctan':
        outerDeriv = BinOp(
          const Num(1),
          '/',
          BinOp(const Num(1), '+', Pow(u, const Num(2))),
        );
        break;
      case 'sinh':
        outerDeriv = Func('cosh', u);
        break;
      case 'cosh':
        outerDeriv = Func('sinh', u);
        break;
      case 'tanh':
        outerDeriv =
            BinOp(const Num(1), '/', Pow(Func('cosh', u), const Num(2)));
        break;
      case 'ln':
        outerDeriv = BinOp(const Num(1), '/', u);
        break;
      case 'log':
        outerDeriv = BinOp(
          const Num(1),
          '/',
          BinOp(u, '*', Func('ln', const Num(10))),
        );
        break;
      case 'exp':
        outerDeriv = Func('exp', u);
        break;
      case 'sqrt':
        outerDeriv = BinOp(
          const Num(1),
          '/',
          BinOp(const Num(2), '*', Func('sqrt', u)),
        );
        break;
      case 'abs':
        outerDeriv = BinOp(u, '/', Func('abs', u.clone()));
        break;
      case 'cbrt':
        outerDeriv = BinOp(
          const Num(1),
          '/',
          BinOp(
            const Num(3),
            '*',
            Pow(u, BinOp(const Num(2), '/', const Num(3))),
          ),
        );
        break;
      default:
        throw Exception('Cannot differentiate unknown function: ${e.name}');
    }

    return Simplifier.simplify(BinOp(outerDeriv, '*', du));
  }
}

// ==================== PROBLEM TYPES & RESULT ====================

enum ProblemType { explicit, implicit, parametric }

class SlopeResult {
  final ProblemType type;
  final String originalInput;
  final Expr functionExpr;
  final Expr derivative;
  final Expr simplifiedDerivative;
  final double? slopeValue;
  final Map<String, double> point;
  final String independentVar;
  final String? dependentVar;

  final Expr? leftSide;
  final Expr? rightSide;
  final Expr? leftDerivative;
  final Expr? rightDerivative;
  final Expr? implicitSlopeExpr;

  final Expr? paramXExpr;
  final Expr? paramYExpr;
  final Expr? dxDt;
  final Expr? dyDt;

  // ── FIX 2: added secondDerivative field so parametric d²y/dx² is preserved ──
  final Expr? secondDerivative;

  // Tangent line details
  final double? tangentSlope;
  final double? tangentYIntercept;
  final String? tangentLineEquation;

  // Normal line details
  final double? normalSlope;
  final String? normalLineEquation;

  const SlopeResult({
    required this.type,
    required this.originalInput,
    required this.functionExpr,
    required this.derivative,
    required this.simplifiedDerivative,
    this.slopeValue,
    required this.point,
    required this.independentVar,
    this.dependentVar,
    this.leftSide,
    this.rightSide,
    this.leftDerivative,
    this.rightDerivative,
    this.implicitSlopeExpr,
    this.paramXExpr,
    this.paramYExpr,
    this.dxDt,
    this.dyDt,
    this.secondDerivative,   // ── FIX 2: wired into constructor ──
    this.tangentSlope,
    this.tangentYIntercept,
    this.normalSlope,
    this.tangentLineEquation,
    this.normalLineEquation,
  });
}

// ==================== SLOPE SOLVER (CORE ENGINE) ====================

class SlopeSolver {
  // ── Public entry point ──────────────────────────────────────────────────────

  /// Solve for the slope/derivative given an input string and optional point.
  ///
  /// [input] may be:
  ///   • Explicit:    "y = 3x^2 - 2x + 1"  or  "f(x) = sin(x)*e^x"
  ///   • Implicit:    "x^2 + y^2 = 25"  or  "x^3 + y^3 = 6xy"
  ///   • Parametric:  "x=cos(t), y=sin(t)"  (comma-separated pair)
  ///
  /// [pointValues] maps variable names → numeric values.
  /// For explicit/implicit supply {"x": value}; for parametric supply {"t": value}.
  static SlopeResult solve(String input, {Map<String, double>? pointValues}) {
    final trimmed = input.trim();

    // Detect parametric: "x=..., y=..." or "x=..., y=..." with a comma
    if (_isParametric(trimmed)) {
      return _solveParametric(trimmed, pointValues ?? {});
    }

    // Parse the equation / expression
    final tokens = Tokenizer(trimmed).tokenize();
    final (left, right) = Parser(tokens).parse();

    if (right == null) {
      // Expression only — treat as y = expr
      return _solveExplicit(Var('y'), left, trimmed, pointValues ?? {});
    }

    // left = right form
    if (left is Var && left.name == 'y') {
      // y = f(x) — explicit
      return _solveExplicit(left, right, trimmed, pointValues ?? {});
    }

    // Check if RHS has no x/y and LHS is purely y (e.g. y = constant)
    final lVars = ExprUtils.collectVars(left);
    final rVars = ExprUtils.collectVars(right);

    // Detect explicit: LHS is just 'y' variable
    if (left is Var && (left.name == 'y' || !rVars.contains('y'))) {
      return _solveExplicit(left, right, trimmed, pointValues ?? {});
    }

    // Detect implicit: both sides may contain x and/or y
    if (lVars.contains('y') ||
        rVars.contains('y') ||
        lVars.contains('x') ||
        rVars.contains('x')) {
      return _solveImplicit(left, right, trimmed, pointValues ?? {});
    }

    // Fallback — treat as implicit
    return _solveImplicit(left, right, trimmed, pointValues ?? {});
  }

  // ── Parametric detection ────────────────────────────────────────────────────

  static bool _isParametric(String s) {
    // Must have exactly one top-level comma separating two equations
    int depth = 0;
    for (int i = 0; i < s.length; i++) {
      if (s[i] == '(')
        depth++;
      else if (s[i] == ')')
        depth--;
      else if (s[i] == ',' && depth == 0) return true;
    }
    return false;
  }

  // ── Explicit solver: y = f(x) ───────────────────────────────────────────────

  static SlopeResult _solveExplicit(
    Expr lhsVar,
    Expr rhs,
    String originalInput,
    Map<String, double> pointValues,
  ) {
    final indepVar = 'x'; // always x for explicit
    final depVar = (lhsVar is Var) ? lhsVar.name : 'y';

    // Symbolic derivative dy/dx = d(rhs)/dx
    final rawDeriv = Differentiator.differentiate(rhs, indepVar);
    final simplified = Simplifier.simplify(rawDeriv);

    double? slopeVal;
    double? tangentSlope;
    double? tangentYIntercept;
    double? normalSlope;
    String? tangentEq;
    String? normalEq;

    if (pointValues.containsKey(indepVar)) {
      final xVal = pointValues[indepVar]!;
      try {
        slopeVal = ExprUtils.evaluate(simplified, pointValues);
        tangentSlope = slopeVal;

        // y-value at the point
        final yVal = ExprUtils.evaluate(rhs, pointValues);
        // y - y0 = m(x - x0)  =>  y = mx + (y0 - m*x0)
        tangentYIntercept = yVal - tangentSlope * xVal;
        tangentEq = _lineEquation(tangentSlope, tangentYIntercept, xVal, yVal);

        // Normal line: perpendicular slope = -1/m (if m ≠ 0)
        if (tangentSlope != 0 && tangentSlope.isFinite) {
          normalSlope = -1.0 / tangentSlope;
          final normYInt = yVal - normalSlope * xVal;
          normalEq = _lineEquation(normalSlope, normYInt, xVal, yVal);
        } else if (tangentSlope == 0) {
          normalEq = 'x = ${_fmt(xVal)} (vertical line)';
        }
      } catch (_) {}
    }

    return SlopeResult(
      type: ProblemType.explicit,
      originalInput: originalInput,
      functionExpr: rhs,
      derivative: rawDeriv,
      simplifiedDerivative: simplified,
      slopeValue: slopeVal,
      point: pointValues,
      independentVar: indepVar,
      dependentVar: depVar,
      tangentSlope: tangentSlope,
      tangentYIntercept: tangentYIntercept,
      normalSlope: normalSlope,
      tangentLineEquation: tangentEq,
      normalLineEquation: normalEq,
    );
  }

  // ── Implicit solver: F(x,y) = G(x,y) ──────────────────────────────────────

  static SlopeResult _solveImplicit(
    Expr lhs,
    Expr rhs,
    String originalInput,
    Map<String, double> pointValues,
  ) {
    // Rewrite as F(x,y) = lhs - rhs = 0
    final F = Simplifier.simplify(BinOp(lhs, '-', rhs));

    // Differentiate both sides wrt x, treating y as y(x)
    final dLhs = Differentiator.differentiate(lhs, 'x', dependentVars: {'y'});
    final dRhs = Differentiator.differentiate(rhs, 'x', dependentVars: {'y'});

    // Arrange:  dLhs - dRhs = 0
    // Collect coefficient of dy/dx and the remainder
    final diffExpr = Simplifier.simplify(BinOp(dLhs, '-', dRhs));
    final (coeff, remainder) = Simplifier.extractDerivCoeff(diffExpr, 'y');

    // dy/dx = -remainder / coeff  (from coeff * dy/dx + remainder = 0)
    final implicitSlope = Simplifier.simplify(
      BinOp(UnaryNeg(remainder), '/', coeff),
    );

    // ── FIX 1: removed dead Fx / Fy computation that was never used ──
    // The classic -F_x / F_y formula was being computed but silently discarded.
    // Additionally, the Fy was differentiated with dependentVars: {'y'} which
    // would introduce dy/dx terms, making it wrong for direct division anyway.

    double? slopeVal;
    double? tangentSlope;
    String? tangentEq;
    double? normalSlope;
    String? normalEq;

    if (pointValues.containsKey('x') && pointValues.containsKey('y')) {
      try {
        slopeVal = ExprUtils.evaluate(implicitSlope, pointValues);
        tangentSlope = slopeVal;
        final xVal = pointValues['x']!;
        final yVal = pointValues['y']!;

        final yInt = yVal - tangentSlope * xVal;
        tangentEq = _lineEquation(tangentSlope, yInt, xVal, yVal);

        if (tangentSlope != 0 && tangentSlope.isFinite) {
          normalSlope = -1.0 / tangentSlope;
          final nYInt = yVal - normalSlope * xVal;
          normalEq = _lineEquation(normalSlope, nYInt, xVal, yVal);
        } else if (tangentSlope == 0) {
          normalEq = 'x = ${_fmt(pointValues['x']!)} (vertical line)';
        }
      } catch (_) {}
    }

    return SlopeResult(
      type: ProblemType.implicit,
      originalInput: originalInput,
      functionExpr: F,
      derivative: diffExpr,
      simplifiedDerivative: implicitSlope,
      slopeValue: slopeVal,
      point: pointValues,
      independentVar: 'x',
      dependentVar: 'y',
      leftSide: lhs,
      rightSide: rhs,
      leftDerivative: dLhs,
      rightDerivative: dRhs,
      implicitSlopeExpr: implicitSlope,
      tangentSlope: tangentSlope,
      tangentLineEquation: tangentEq,
      normalSlope: normalSlope,
      normalLineEquation: normalEq,
    );
  }

  // ── Parametric solver: x=f(t), y=g(t) ─────────────────────────────────────

  static SlopeResult _solveParametric(
    String input,
    Map<String, double> pointValues,
  ) {
    // Split at the top-level comma
    final parts = _splitTopLevel(input);
    if (parts.length != 2) {
      throw FormatException(
          'Parametric input must have exactly two expressions: "x=..., y=..."');
    }

    Expr? xExpr, yExpr;
    String paramVar = 't';

    for (final part in parts) {
      final tokens = Tokenizer(part.trim()).tokenize();
      final (lhs, rhs) = Parser(tokens).parse();
      if (rhs == null) {
        throw FormatException(
            'Parametric part must be an equation: "${part.trim()}"');
      }
      if (lhs is Var && lhs.name == 'x') {
        xExpr = rhs;
        // Infer parameter variable (e.g., t, theta)
        final vars = ExprUtils.collectVars(rhs);
        if (vars.isNotEmpty) paramVar = vars.first;
      } else if (lhs is Var && lhs.name == 'y') {
        yExpr = rhs;
      } else {
        throw FormatException(
            'Expected "x=..." and "y=...", got "${part.trim()}"');
      }
    }

    if (xExpr == null || yExpr == null) {
      throw FormatException(
          'Could not find both x(t) and y(t) in parametric input');
    }

    // Collect parameter from expressions if not found yet
    final xVars = ExprUtils.collectVars(xExpr);
    final yVars = ExprUtils.collectVars(yExpr);
    final allVars = xVars.union(yVars).difference({'x', 'y'});
    if (allVars.isNotEmpty) paramVar = allVars.first;

    // dx/dt and dy/dt
    final dxDt =
        Simplifier.simplify(Differentiator.differentiate(xExpr, paramVar));
    final dyDt =
        Simplifier.simplify(Differentiator.differentiate(yExpr, paramVar));

    // dy/dx = (dy/dt) / (dx/dt)
    final parametricSlope = Simplifier.simplify(BinOp(dyDt, '/', dxDt));

    // ── FIX 2: d²y/dx² computed and now stored in secondDerivative ──
    // d²y/dx² = (d/dt[dy/dx]) / (dx/dt)
    final dSlopeDt = Simplifier.simplify(
      Differentiator.differentiate(parametricSlope, paramVar),
    );
    final secondDeriv = Simplifier.simplify(BinOp(dSlopeDt, '/', dxDt));

    double? slopeVal;
    double? tangentSlope;
    String? tangentEq;
    double? normalSlope;
    String? normalEq;

    if (pointValues.containsKey(paramVar)) {
      try {
        // ── FIX 3: tVal is now used in both the vertical and normal-slope
        //           tangent branches so the parameter value always appears
        //           in the tangent line label for consistency ──
        final tVal = pointValues[paramVar]!;
        final xVal = ExprUtils.evaluate(xExpr, pointValues);
        final yVal = ExprUtils.evaluate(yExpr, pointValues);
        final dxVal = ExprUtils.evaluate(dxDt, pointValues);
        final dyVal = ExprUtils.evaluate(dyDt, pointValues);

        if (dxVal == 0) {
          // Vertical tangent
          tangentEq =
              'x = ${_fmt(xVal)} (vertical tangent at $paramVar=${_fmt(tVal)})';
        } else {
          slopeVal = dyVal / dxVal;
          tangentSlope = slopeVal;
          final yInt = yVal - tangentSlope * xVal;
          // Include parameter value in label so output is unambiguous
          tangentEq =
              '${_lineEquation(tangentSlope, yInt, xVal, yVal)}  [at $paramVar=${_fmt(tVal)}]';

          if (tangentSlope != 0 && tangentSlope.isFinite) {
            normalSlope = -1.0 / tangentSlope;
            final nYInt = yVal - normalSlope * xVal;
            // Include parameter value in normal line label too
            normalEq =
                '${_lineEquation(normalSlope, nYInt, xVal, yVal)}  [at $paramVar=${_fmt(tVal)}]';
          } else if (tangentSlope == 0) {
            normalEq =
                'x = ${_fmt(xVal)} (vertical line at $paramVar=${_fmt(tVal)})';
          }
        }
      } catch (_) {}
    }

    return SlopeResult(
      type: ProblemType.parametric,
      originalInput: input,
      functionExpr: parametricSlope,
      derivative: parametricSlope,
      simplifiedDerivative: parametricSlope,
      slopeValue: slopeVal,
      point: pointValues,
      independentVar: paramVar,
      dependentVar: 'y',
      paramXExpr: xExpr,
      paramYExpr: yExpr,
      dxDt: dxDt,
      dyDt: dyDt,
      secondDerivative: secondDeriv,   // ── FIX 2: wired in ──
      tangentSlope: tangentSlope,
      tangentLineEquation: tangentEq,
      normalSlope: normalSlope,
      normalLineEquation: normalEq,
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Split a string at top-level commas (not inside parentheses).
  static List<String> _splitTopLevel(String s) {
    final parts = <String>[];
    int depth = 0;
    int start = 0;
    for (int i = 0; i < s.length; i++) {
      if (s[i] == '(')
        depth++;
      else if (s[i] == ')')
        depth--;
      else if (s[i] == ',' && depth == 0) {
        parts.add(s.substring(start, i).trim());
        start = i + 1;
      }
    }
    parts.add(s.substring(start).trim());
    return parts;
  }

  /// Format a double for display.
  static String _fmt(double v) {
    if (v == v.truncateToDouble() && v.abs() < 1e10)
      return v.toInt().toString();
    return v.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
  }

  /// Build a human-readable tangent/normal line equation.
  /// Returns "y = mx + b" form, or "y = mx - |b|" to avoid double signs.
  static String _lineEquation(double m, double b, double x0, double y0) {
    if (m == 0) return 'y = ${_fmt(y0)}';
    if (!m.isFinite) return 'x = ${_fmt(x0)} (vertical line)';

    final mStr = _fmt(m);
    if (b == 0) return 'y = ${mStr}x';
    if (b > 0) return 'y = ${mStr}x + ${_fmt(b)}';
    return 'y = ${mStr}x - ${_fmt(b.abs())}';
  }
}

// ==================== STEP-BY-STEP EXPLAINER ====================

/// Generates a human-readable, step-by-step solution walkthrough.
class StepExplainer {
  static List<String> explain(SlopeResult result) {
    switch (result.type) {
      case ProblemType.explicit:
        return _explainExplicit(result);
      case ProblemType.implicit:
        return _explainImplicit(result);
      case ProblemType.parametric:
        return _explainParametric(result);
    }
  }

  static List<String> _explainExplicit(SlopeResult r) {
    final steps = <String>[];
    final indep = r.independentVar;
    final dep = r.dependentVar ?? 'y';

    steps.add('GIVEN:  $dep = ${r.functionExpr.toMathString()}');
    steps.add('');
    steps.add('STEP 1 — Identify the function');
    steps.add('  f($indep) = ${r.functionExpr.toMathString()}');
    steps.add('');
    steps.add('STEP 2 — Differentiate with respect to $indep');
    steps.add('  d$dep/d$indep = ${r.derivative.toMathString()}');
    if (r.derivative.toMathString() != r.simplifiedDerivative.toMathString()) {
      steps.add('');
      steps.add('STEP 3 — Simplify the derivative');
      steps.add('  d$dep/d$indep = ${r.simplifiedDerivative.toMathString()}');
    } else {
      steps.add('  (already in simplified form)');
    }

    if (r.point.containsKey(indep) && r.slopeValue != null) {
      final xVal = r.point[indep]!;
      steps.add('');
      steps.add(
          'STEP ${r.derivative.toMathString() != r.simplifiedDerivative.toMathString() ? 4 : 3} — Evaluate at $indep = ${_fmt(xVal)}');
      steps.add(
          '  slope = ${r.simplifiedDerivative.toMathString()} | $indep=${_fmt(xVal)} = ${_fmt(r.slopeValue!)}');
    }

    _appendLines(steps, r);
    return steps;
  }

  static List<String> _explainImplicit(SlopeResult r) {
    final steps = <String>[];

    steps.add(
        'GIVEN (implicit):  ${r.leftSide?.toMathString() ?? ''} = ${r.rightSide?.toMathString() ?? ''}');
    steps.add('');
    steps.add('STEP 1 — Differentiate both sides with respect to x');
    steps.add('  Treat y as a function of x: y = y(x)');
    steps.add(
        '  Left  side: d/dx[${r.leftSide?.toMathString() ?? ''}] = ${r.leftDerivative?.toMathString() ?? ''}');
    steps.add(
        '  Right side: d/dx[${r.rightSide?.toMathString() ?? ''}] = ${r.rightDerivative?.toMathString() ?? ''}');
    steps.add('');
    steps.add('STEP 2 — Set derivatives equal and collect dy/dx terms');
    steps.add('  ${r.derivative.toMathString()} = 0');
    steps.add('');
    steps.add('STEP 3 — Solve for dy/dx');
    steps.add(
        '  dy/dx = ${r.implicitSlopeExpr?.toMathString() ?? r.simplifiedDerivative.toMathString()}');

    if (r.point.containsKey('x') &&
        r.point.containsKey('y') &&
        r.slopeValue != null) {
      final xVal = r.point['x']!;
      final yVal = r.point['y']!;
      steps.add('');
      steps.add('STEP 4 — Evaluate at (${_fmt(xVal)}, ${_fmt(yVal)})');
      steps.add('  dy/dx = ${_fmt(r.slopeValue!)}');
    }

    _appendLines(steps, r);
    return steps;
  }

  static List<String> _explainParametric(SlopeResult r) {
    final steps = <String>[];
    final t = r.independentVar;

    steps.add('GIVEN (parametric):');
    steps.add('  x($t) = ${r.paramXExpr?.toMathString() ?? ''}');
    steps.add('  y($t) = ${r.paramYExpr?.toMathString() ?? ''}');
    steps.add('');
    steps.add('STEP 1 — Find dx/d$t and dy/d$t');
    steps.add('  dx/d$t = ${r.dxDt?.toMathString() ?? ''}');
    steps.add('  dy/d$t = ${r.dyDt?.toMathString() ?? ''}');
    steps.add('');
    steps.add('STEP 2 — Apply the parametric slope formula');
    steps.add('  dy/dx = (dy/d$t) / (dx/d$t)');
    steps.add(
        '        = (${r.dyDt?.toMathString() ?? ''}) / (${r.dxDt?.toMathString() ?? ''})');
    steps.add('        = ${r.simplifiedDerivative.toMathString()}');

    // ── FIX 2: surface the second derivative in the step output ──
    if (r.secondDerivative != null) {
      steps.add('');
      steps.add('STEP 3 — Second derivative (concavity)');
      steps.add('  d²y/dx² = (d/d$t[dy/dx]) / (dx/d$t)');
      steps.add('          = ${r.secondDerivative!.toMathString()}');
    }

    if (r.point.containsKey(t) && r.slopeValue != null) {
      final stepNum = r.secondDerivative != null ? 4 : 3;
      final tVal = r.point[t]!;
      steps.add('');
      steps.add('STEP $stepNum — Evaluate at $t = ${_fmt(tVal)}');
      final xVal = r.paramXExpr != null
          ? ExprUtils.evaluate(r.paramXExpr!, r.point)
          : double.nan;
      final yVal = r.paramYExpr != null
          ? ExprUtils.evaluate(r.paramYExpr!, r.point)
          : double.nan;
      if (!xVal.isNaN && !yVal.isNaN) {
        steps.add('  x = ${_fmt(xVal)},  y = ${_fmt(yVal)}');
      }
      steps.add('  dy/dx = ${_fmt(r.slopeValue!)}');
    }

    _appendLines(steps, r);
    return steps;
  }

  static void _appendLines(List<String> steps, SlopeResult r) {
    if (r.tangentLineEquation != null) {
      steps.add('');
      steps.add('TANGENT LINE:  ${r.tangentLineEquation}');
    }
    if (r.normalLineEquation != null) {
      steps.add('NORMAL LINE:   ${r.normalLineEquation}');
    }
  }

  static String _fmt(double v) {
    if (v == v.truncateToDouble() && v.abs() < 1e10)
      return v.toInt().toString();
    return v.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
  }
}

// ==================== PRETTY PRINTER ====================

/// Renders a SlopeResult to the terminal with ANSI colour.
class PrettyPrinter {
  static const _reset = '\x1B[0m';
  static const _bold = '\x1B[1m';
  static const _cyan = '\x1B[36m';
  static const _green = '\x1B[32m';
  static const _yellow = '\x1B[33m';
  static const _blue = '\x1B[34m';


  static void print(SlopeResult result) {
    final w = 62;
    final bar = '═' * w;

    _writeln('$_bold$_cyan╔$bar╗$_reset');
    _writeln('$_bold$_cyan║${_center('SLOPE SOLVER', w)}║$_reset');
    _writeln('$_bold$_cyan╚$bar╝$_reset');
    _writeln('');

    // Type badge
    final typeLabel = {
      ProblemType.explicit: '  EXPLICIT  ',
      ProblemType.implicit: '  IMPLICIT  ',
      ProblemType.parametric: ' PARAMETRIC ',
    }[result.type]!;
    _writeln('$_bold$_blue[$typeLabel]$_reset  ${result.originalInput}');
    _writeln('');

    // Steps
    final steps = StepExplainer.explain(result);
    for (final step in steps) {
      if (step.startsWith('GIVEN') ||
          step.startsWith('STEP') ||
          step.startsWith('TANGENT') ||
          step.startsWith('NORMAL')) {
        _writeln('$_bold$_yellow$step$_reset');
      } else {
        _writeln(step);
      }
    }

    // Summary box
    _writeln('');
    _writeln('$_bold$_green┌─── RESULT SUMMARY ${'─' * (w - 19)}┐$_reset');
    _writeln(
        '$_bold$_green│$_reset  Derivative:  ${result.simplifiedDerivative.toMathString()}${' ' * _pad(result.simplifiedDerivative.toMathString(), w - 15)}$_bold$_green│$_reset');
    if (result.secondDerivative != null) {
      // ── FIX 2: show second derivative in summary box for parametric results ──
      final sd = result.secondDerivative!.toMathString();
      _writeln(
          '$_bold$_green│$_reset  2nd deriv:   $sd${' ' * _pad(sd, w - 15)}$_bold$_green│$_reset');
    }
    if (result.slopeValue != null) {
      final sv = _fmtD(result.slopeValue!);
      _writeln(
          '$_bold$_green│$_reset  Slope value: $sv${' ' * _pad(sv, w - 15)}$_bold$_green│$_reset');
    }
    if (result.tangentLineEquation != null) {
      final tl = result.tangentLineEquation!;
      _writeln(
          '$_bold$_green│$_reset  Tangent:     $tl${' ' * _pad(tl, w - 15)}$_bold$_green│$_reset');
    }
    if (result.normalLineEquation != null) {
      final nl = result.normalLineEquation!;
      _writeln(
          '$_bold$_green│$_reset  Normal:      $nl${' ' * _pad(nl, w - 15)}$_bold$_green│$_reset');
    }
    _writeln('$_bold$_green└${'─' * w}┘$_reset');
  }

  static void _writeln(String s) => stdout.writeln(s);

  static String _center(String s, int width) {
    final pad = (width - s.length) ~/ 2;
    return ' ' * pad + s + ' ' * (width - pad - s.length);
  }

  static int _pad(String s, int total) {
    final rem = total - s.length;
    return rem < 0 ? 0 : rem;
  }

  static String _fmtD(double v) {
    if (v == v.truncateToDouble() && v.abs() < 1e10) {
      return v.toInt().toString();
    }
    return v.toStringAsFixed(8).replaceAll(RegExp(r'\.?0+$'), '');
  }
}

// ==================== DEMO / MAIN ====================
/// Parses CLI args like: "y = sin(x)" x=1.5708
/// Returns (equation_string, {var: value, ...})
(String, Map<String, double>) _parseArgs(List<String> args) {
  if (args.isEmpty) return ('', {});

  // Collect equation tokens (non key=value) and value tokens
  final eqParts = <String>[];
  final vals = <String, double>{};

  for (final arg in args) {
    final kv =
        RegExp(r'^([a-zA-Z_][a-zA-Z0-9_]*)=([-\d.eE+]+)$').firstMatch(arg);
    if (kv != null) {
      vals[kv.group(1)!] = double.parse(kv.group(2)!);
    } else {
      eqParts.add(arg);
    }
  }

  return (eqParts.join(' '), vals);
}

void main(List<String> args) {
  // ── Demo suite (runs when no args are given) ───────────────────────────────
  final demos = <(String, Map<String, double>)>[
    // Explicit — polynomial
    ('y = x^3 - 3x^2 + 2', {'x': 2.0}),
    // Explicit — trig
    ('y = sin(x) * cos(x)', {'x': 0.0}),
    // Explicit — exponential / ln combo
    ('y = e^x * ln(x)', {'x': 1.0}),
    // Explicit — quotient rule
    ('y = (x^2 + 1) / (x - 1)', {'x': 3.0}),
    // Explicit — chain rule inside power
    ('y = (sin(x))^3', {'x': 1.5708}),
    // Explicit — sqrt
    ('y = sqrt(x^2 + 1)', {'x': 2.0}),
    // Implicit — circle
    ('x^2 + y^2 = 25', {'x': 3.0, 'y': 4.0}),
    // Implicit — Folium of Descartes (symmetric node at (3,3))
    ('x^3 + y^3 = 6*x*y', {'x': 3.0, 'y': 3.0}),
    // Implicit — ellipse
    ('4*x^2 + 9*y^2 = 36', {'x': 0.0, 'y': 2.0}),
    // Parametric — unit circle
    ('x=cos(t), y=sin(t)', {'t': 0.7854}),
    // Parametric — cycloid
    ('x=t - sin(t), y=1 - cos(t)', {'t': 1.5708}),
    // Parametric — astroid
    ('x=cos(t)^3, y=sin(t)^3', {'t': 0.5236}),
  ];

  if (args.isNotEmpty) {
    // Run single problem from CLI
    final (eq, vals) = _parseArgs(args);
    if (eq.isEmpty) {
      stderr.writeln(
          'Usage: dart slope_solver.dart "<equation>" [var=value ...]');
      stderr.writeln('Examples:');
      stderr.writeln('  dart slope_solver.dart "y = x^3 - 2x + 1" x=2');
      stderr.writeln('  dart slope_solver.dart "x^2 + y^2 = 25" x=3 y=4');
      stderr.writeln('  dart slope_solver.dart "x=cos(t), y=sin(t)" t=1.5708');
      exit(1);
    }
    try {
      final result = SlopeSolver.solve(eq, pointValues: vals);
      PrettyPrinter.print(result);
    } catch (e) {
      stderr.writeln('Error: $e');
      exit(1);
    }
    return;
  }
  // Full demo suite
  stdout.writeln('\n${'═' * 64}');
  stdout.writeln('  SLOPE SOLVER — COMPREHENSIVE DEMO');
  stdout.writeln('${'═' * 64}\n');

  int passed = 0;
  int failed = 0;

  for (int i = 0; i < demos.length; i++) {
    final (eq, vals) = demos[i];
    stdout.writeln('\n[Demo ${i + 1}/${demos.length}]');
    try {
      final result = SlopeSolver.solve(eq, pointValues: vals);
      PrettyPrinter.print(result);
      passed++;
    } catch (e, st) {
      stderr.writeln('  !! Error solving "$eq": $e');
      stderr.writeln(st);
      failed++;
    }
    stdout.writeln();
  }

  stdout.writeln('${'═' * 64}');
  stdout.writeln(
      '  RESULTS: $passed passed, $failed failed out of ${demos.length} demos');
  stdout.writeln('${'═' * 64}\n');
}