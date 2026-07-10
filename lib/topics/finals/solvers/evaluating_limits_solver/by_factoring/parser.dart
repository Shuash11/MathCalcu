import 'dart:math';
import 'tokenizer.dart';

/// Exception thrown when parsing fails
class ParserException implements Exception {
  final String message;
  final Token? unexpectedToken;

  const ParserException(this.message, [this.unexpectedToken]);

  @override
  String toString() {
    if (unexpectedToken != null) {
      return 'ParserError at position ${unexpectedToken!.position}: $message';
    }
    return 'ParserError: $message';
  }
}

/// Abstract base class for Abstract Syntax Tree nodes
abstract class ASTNode {
  /// String representation of the expression
  @override
  String toString();

  /// Evaluate the expression at x = value
  double evaluate(double x);

  /// Check if this subtree contains any division operations
  bool get hasDivision;
}

/// Number literal node (e.g., 42, 3.14)
class NumberNode extends ASTNode {
  final double value;

  NumberNode(this.value);

  @override
  String toString() {
    if (value == value.toInt()) return value.toInt().toString();
    return value.toString();
  }

  @override
  double evaluate(double x) => value;

  @override
  bool get hasDivision => false;
}

/// Variable node (represents 'x')
class VariableNode extends ASTNode {
  @override
  String toString() => 'x';

  @override
  double evaluate(double x) => x;

  @override
  bool get hasDivision => false;
}

/// Binary operation node (e.g., a + b, a * b, a ^ b)
class BinaryOpNode extends ASTNode {
  final String operator;
  final ASTNode left;
  final ASTNode right;

  BinaryOpNode(this.operator, this.left, this.right);

  @override
  String toString() {
    final leftStr = _wrapIfLowerPrecedence(left);
    final rightStr = _wrapIfLowerPrecedence(right);
    return '$leftStr $operator $rightStr';
  }

  String _wrapIfLowerPrecedence(ASTNode node) {
    if (node is BinaryOpNode) {
      // Wrap in parentheses if child has lower precedence
      if (_getPrecedence(node.operator) < _getPrecedence(operator)) {
        return '($node)';
      }
      // For right operand of power, always wrap to avoid ambiguity
      if (operator == '^' && node.operator != '^') {
        return '($node)';
      }
    }
    if (node is UnaryMinusNode) {
      return '($node)';
    }
    return node.toString();
  }

  int _getPrecedence(String op) {
    return switch (op) {
      '+' || '-' => 1,
      '*' || '/' => 2,
      '^' => 3,
      _ => 0,
    };
  }

  @override
  double evaluate(double x) {
    final l = left.evaluate(x);
    final r = right.evaluate(x);
    return switch (operator) {
      '+' => l + r,
      '-' => l - r,
      '*' => l * r,
      '/' => l / r,
      '^' => pow(l, r).toDouble(),
      _ => throw StateError('Unknown operator: $operator'),
    };
  }

  @override
  bool get hasDivision =>
      operator == '/' || left.hasDivision || right.hasDivision;
}

/// Unary negation node (e.g., -x, -(a+b))
class UnaryMinusNode extends ASTNode {
  final ASTNode operand;

  UnaryMinusNode(this.operand);

  @override
  String toString() {
    if (operand is BinaryOpNode || operand is UnaryMinusNode) {
      return '-($operand)';
    }
    return '-$operand';
  }

  @override
  double evaluate(double x) => -operand.evaluate(x);

  @override
  bool get hasDivision => operand.hasDivision;
}

/// Recursive descent parser for mathematical expressions.
///
/// Grammar:
///   Expression → Term (('+' | '-') Term)*
///   Term       → Power (('*' | '/') Power)*
///   Power      → Unary ('^' Unary)?
///   Unary      → '-' Unary | '+' Unary | Atom
///   Atom       → Number | Variable | '(' Expression ')'
class Parser {
  final List<Token> tokens;
  int _current = 0;

  Parser(this.tokens);

  /// Parse the complete expression and return AST
  ASTNode parse() {
    final result = _parseExpression();
    if (tokens[_current].type != TokenType.eof) {
      throw ParserException(
          'Unexpected token after expression', tokens[_current]);
    }
    return result;
  }

  /// Expression = Term (('+' | '-') Term)*
  ASTNode _parseExpression() {
    var left = _parseTerm();

    while (tokens[_current].type == TokenType.plus ||
        tokens[_current].type == TokenType.minus) {
      final op = tokens[_current].value;
      _current++;
      final right = _parseTerm();
      left = BinaryOpNode(op, left, right);
    }

    return left;
  }

  /// Term = Power (('*' | '/') Power)*
  ASTNode _parseTerm() {
    var left = _parsePower();

    while (tokens[_current].type == TokenType.multiply ||
        tokens[_current].type == TokenType.divide) {
      final op = tokens[_current].value;
      _current++;
      final right = _parsePower();
      left = BinaryOpNode(op, left, right);
    }

    return left;
  }

  /// Power = Unary ('^' Unary)?
  ASTNode _parsePower() {
    var base = _parseUnary();

    if (tokens[_current].type == TokenType.power) {
      _current++;
      final exponent = _parseUnary();
      base = BinaryOpNode('^', base, exponent);
    }

    return base;
  }

  /// Unary = '-' Unary | '+' Unary | Atom
  ASTNode _parseUnary() {
    if (tokens[_current].type == TokenType.minus) {
      _current++;
      final operand = _parseUnary();
      return UnaryMinusNode(operand);
    }
    if (tokens[_current].type == TokenType.plus) {
      _current++;
      return _parseUnary();
    }
    return _parseAtom();
  }

  /// Atom = Number | Variable | '(' Expression ')'
  ASTNode _parseAtom() {
    final token = tokens[_current];

    if (token.type == TokenType.number) {
      _current++;
      return NumberNode(double.parse(token.value));
    }

    if (token.type == TokenType.variable) {
      _current++;
      return VariableNode();
    }

    if (token.type == TokenType.leftParen) {
      _current++;
      
      if (_current < tokens.length && tokens[_current].type == TokenType.rightParen) {
        _current++;
        return NumberNode(0);
      }
      
      final expr = _parseExpression();
      if (tokens[_current].type != TokenType.rightParen) {
        throw ParserException(
            'Expected ")" but found "${tokens[_current].value}"',
            tokens[_current]);
      }
      _current++;
      return expr;
    }

    if (token.type == TokenType.function) {
      _current++;
      final funcName = token.value;
      if (funcName == 'sqrt') {
        if (_current >= tokens.length ||
            tokens[_current].type != TokenType.leftParen) {
          throw ParserException('Expected "(" after $funcName',
              _current < tokens.length ? tokens[_current] : null);
        }
        _current++;

        if (_current < tokens.length &&
            tokens[_current].type == TokenType.rightParen) {
          _current++;
          return BinaryOpNode('^', NumberNode(0), NumberNode(0.5));
        }

        final arg = _parseExpression();
        if (_current >= tokens.length ||
            tokens[_current].type != TokenType.rightParen) {
          throw ParserException(
              'Expected ")" after function argument',
              _current < tokens.length ? tokens[_current] : null);
        }
        _current++;
        // We lack a FunctionNode in this specific parser's AST,
        // but we can simulate sqrt(x) as x^(0.5) to keep it simple for Factoring solver
        return BinaryOpNode('^', arg, NumberNode(0.5));
      }
    }

    throw ParserException('Unexpected token "${token.value}"', token);
  }
}
