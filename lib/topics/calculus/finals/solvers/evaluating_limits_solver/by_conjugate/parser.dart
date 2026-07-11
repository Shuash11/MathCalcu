import 'dart:math' as math;

import 'tokenizer.dart';

abstract class ASTNode {
  String toTex();
  double evaluate(double x, {String? variable});
  ASTNode simplify();
}

class NumberNode extends ASTNode {
  final double value;
  NumberNode(this.value);

  @override
  String toTex() {
    if (value == value.toInt()) return value.toInt().toString();
    return value.toString();
  }

  @override
  double evaluate(double x, {String? variable}) => value;

  @override
  ASTNode simplify() => this;
}

class VariableNode extends ASTNode {
  final String name;
  VariableNode(this.name);

  @override
  String toTex() => name;

  @override
  double evaluate(double x, {String? variable}) {
    if (variable == name) return x;
    return 0;
  }

  @override
  ASTNode simplify() => this;
}

class UnaryMinusNode extends ASTNode {
  final ASTNode operand;
  UnaryMinusNode(this.operand);

  @override
  String toTex() => '(-${operand.toTex()})';

  @override
  double evaluate(double x, {String? variable}) =>
      -operand.evaluate(x, variable: variable);

  @override
  ASTNode simplify() {
    final simp = operand.simplify();
    if (simp is NumberNode) {
      return NumberNode(-simp.value);
    }
    return UnaryMinusNode(simp);
  }
}

class BinaryOpNode extends ASTNode {
  final String operator;
  final ASTNode left;
  final ASTNode right;
  BinaryOpNode(this.operator, this.left, this.right);

  @override
  String toTex() {
    final leftTex = _wrapIfNeeded(left, isRight: false);
    final rightTex = _wrapIfNeeded(right, isRight: true);
    return switch (operator) {
      '+' => '$leftTex + $rightTex',
      '-' => '$leftTex - $rightTex',
      '*' => '$leftTex \\cdot $rightTex',
      '/' => '\\frac{$leftTex}{$rightTex}',
      '^' => '($leftTex)^{$rightTex}',
      _ => '($leftTex)$operator($rightTex)',
    };
  }

  String _wrapIfNeeded(ASTNode node, {required bool isRight}) {
    final tex = node.toTex();
    if (node is! BinaryOpNode) return tex;

    final needsWrap = switch (operator) {
      '*' || '/' => node.operator == '+' || node.operator == '-',
      '-' => isRight && (node.operator == '+' || node.operator == '-'),
      '^' => true,
      _ => false,
    };
    return needsWrap ? '($tex)' : tex;
  }

  @override
  double evaluate(double x, {String? variable}) {
    final l = left.evaluate(x, variable: variable);
    final r = right.evaluate(x, variable: variable);
    return switch (operator) {
      '+' => l + r,
      '-' => l - r,
      '*' => l * r,
      '/' => r != 0 ? l / r : double.nan,
      '^' => _pow(l, r),
      _ => double.nan,
    };
  }

  double _pow(double base, double exp) {
    return math.pow(base, exp).toDouble();
  }

  @override
  ASTNode simplify() {
    final simpLeft = left.simplify();
    final simpRight = right.simplify();

    if (simpLeft is NumberNode && simpRight is NumberNode) {
      return NumberNode(BinaryOpNode(operator, simpLeft, simpRight)
          .evaluate(0, variable: 'x'));
    }

    if (operator == '+') {
      if (_isZero(simpLeft)) return simpRight;
      if (_isZero(simpRight)) return simpLeft;
    }
    if (operator == '-') {
      if (_isZero(simpRight)) return simpLeft;
    }
    if (operator == '*') {
      if (_isZero(simpLeft) || _isZero(simpRight)) return NumberNode(0);
      if (_isOne(simpLeft)) return simpRight;
      if (_isOne(simpRight)) return simpLeft;
    }
    if (operator == '/') {
      if (_isZero(simpLeft)) return NumberNode(0);
      if (_isOne(simpRight)) return simpLeft;
    }
    if (operator == '^') {
      if (_isZero(simpRight)) return NumberNode(1);
      if (_isOne(simpRight)) return simpLeft;
      if (simpLeft is SqrtNode &&
          simpRight is NumberNode &&
          (simpRight.value - 2).abs() < 1e-12) {
        return simpLeft.argument.simplify();
      }
    }
    return BinaryOpNode(operator, simpLeft, simpRight);
  }

  bool _isZero(ASTNode node) => node is NumberNode && node.value.abs() < 1e-12;
  bool _isOne(ASTNode node) => node is NumberNode && (node.value - 1).abs() < 1e-12;
}

class SqrtNode extends ASTNode {
  final ASTNode argument;
  SqrtNode(this.argument);

  @override
  String toTex() => '\\sqrt{${argument.toTex()}}';

  @override
  double evaluate(double x, {String? variable}) {
    final arg = argument.evaluate(x, variable: variable);
    if (arg < 0 && arg > -1e-12) return 0;
    return arg >= 0 ? math.sqrt(arg) : double.nan;
  }

  @override
  ASTNode simplify() {
    final simpArg = argument.simplify();
    if (simpArg is NumberNode && simpArg.value >= 0) {
      return NumberNode(math.sqrt(simpArg.value));
    }
    return SqrtNode(simpArg);
  }
}

class AbsNode extends ASTNode {
  final ASTNode argument;
  AbsNode(this.argument);

  @override
  String toTex() => '|${argument.toTex()}|';

  @override
  double evaluate(double x, {String? variable}) {
    return argument.evaluate(x, variable: variable).abs();
  }

  @override
  ASTNode simplify() {
    final simpArg = argument.simplify();
    if (simpArg is NumberNode) {
      return NumberNode(simpArg.value.abs());
    }
    return AbsNode(simpArg);
  }
}

class Parser {
  final List<Token> tokens;
  int pos = 0;
  List<int> _parenStack = [];

  Parser(this.tokens);

  ASTNode parse() {
    _parenStack = [];
    final result = _parseExpression();
    if (pos < tokens.length - 1) {
      final token = tokens[pos];
      final context = _getTokenContext(token);
      if (token.type == TokenType.rparen) {
        throw ParserException('Unexpected ")". There\'s an extra closing parenthesis or a missing opening "("$context');
      }
      if (_parenStack.isNotEmpty) {
        final mismatchedPos = _parenStack.removeLast();
        throw ParserException('Mismatched parenthesis: extra ")" found near position $mismatchedPos. Did you forget an opening "("$context?');
      }
      throw ParserException('Unexpected token "$token" at position $pos$context');
    }
    return result;
  }

  String _getTokenContext(Token token) {
    if (pos > 0 && pos < tokens.length) {
      final before = tokens[pos - 1];
      final after = pos + 1 < tokens.length ? tokens[pos + 1] : null;
      final beforeStr = before.type == TokenType.end ? '' : '$before ';
      final afterStr = after != null ? ' $after' : '';
      return '\nNear: ...$beforeStr$token$afterStr...';
    }
    return '';
  }

  ASTNode _parseExpression() => _parseAddSub();

  ASTNode _parseAddSub() {
    var left = _parseMulDiv();
    while (pos < tokens.length - 1) {
      final token = tokens[pos];
      if (token.type == TokenType.operator &&
          (token.value == '+' || token.value == '-')) {
        pos++;
        final right = _parseMulDiv();
        left = BinaryOpNode(token.value as String, left, right);
      } else {
        break;
      }
    }
    return left;
  }

  ASTNode _parseMulDiv() {
    var left = _parsePower();
    while (pos < tokens.length - 1) {
      final token = tokens[pos];
      if (token.type == TokenType.operator &&
          (token.value == '*' || token.value == '/')) {
        pos++;
        final right = _parsePower();
        left = BinaryOpNode(token.value as String, left, right);
      } else {
        break;
      }
    }
    return left;
  }

  ASTNode _parsePower() {
    var left = _parseUnary();
    while (pos < tokens.length - 1) {
      final token = tokens[pos];
      if (token.type == TokenType.operator && token.value == '^') {
        pos++;
        final right = _parseUnary();
        left = BinaryOpNode('^', left, right);
      } else {
        break;
      }
    }
    return left;
  }

  ASTNode _parseUnary() {
    final token = tokens[pos];
    if (token.type == TokenType.operator && token.value == '-') {
      pos++;
      final operand = _parseUnary();
      return UnaryMinusNode(operand);
    }
    return _parsePrimary();
  }

  ASTNode _parsePrimary() {
    final token = tokens[pos];

    if (token.type == TokenType.number) {
      pos++;
      return NumberNode(token.value as double);
    }

    if (token.type == TokenType.variable) {
      pos++;
      return VariableNode(token.value as String);
    }

    if (token.type == TokenType.sqrt) {
      pos++;
      if (tokens[pos].type == TokenType.lparen) {
        _parenStack.add(pos);
        pos++;
        final arg = _parseExpression();
        if (tokens[pos].type != TokenType.rparen) {
          final openingPos = _parenStack.isNotEmpty ? _parenStack.removeLast() : 0;
          throw ParserException('Missing closing ")". The opening "(" at position $openingPos was never closed.');
        }
        _parenStack.removeLast();
        pos++;
        return SqrtNode(arg);
      }
      return SqrtNode(_parseUnary());
    }

    if (token.type == TokenType.abs) {
      pos++;
      if (tokens[pos].type != TokenType.lparen) {
        throw ParserException('Expected ( after abs');
      }
      _parenStack.add(pos);
      pos++;
      final arg = _parseExpression();
      if (tokens[pos].type != TokenType.rparen) {
        final openingPos = _parenStack.isNotEmpty ? _parenStack.removeLast() : 0;
        throw ParserException('Missing closing ")". The opening "(" at position $openingPos was never closed.');
      }
      _parenStack.removeLast();
      pos++;
      return AbsNode(arg);
    }

    if (token.type == TokenType.lparen) {
      _parenStack.add(pos);
      pos++;
      final expr = _parseExpression();
      if (tokens[pos].type != TokenType.rparen) {
        if (_parenStack.isNotEmpty) {
          final openingPos = _parenStack.last;
          _parenStack.removeLast();
          throw ParserException('Missing closing ")". The opening "(" at position $openingPos was never closed.');
        }
        throw ParserException('Missing closing ")"');
      }
      _parenStack.removeLast();
      pos++;
      return expr;
    }

    if (token.type == TokenType.rparen) {
      throw ParserException('Unexpected ")". There\'s an extra closing parenthesis or a missing opening "("');
    }

    throw ParserException('Unexpected token: $token');
  }
}

class ParserException implements Exception {
  final String message;
  ParserException(this.message);

  @override
  String toString() => 'ParserError: $message';
}
