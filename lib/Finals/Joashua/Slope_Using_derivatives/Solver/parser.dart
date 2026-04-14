// parser.dart
// Tokenizer: converts a raw string into a flat list of Token values.
// Parser:    converts the token list into an Expr AST.
// Nothing here differentiates, simplifies, or evaluates — it only reads text.

import 'dart:math' as math;
import 'models.dart';

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