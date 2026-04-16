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
    final leftTex = left.toTex();
    final rightTex = right.toTex();
    return switch (operator) {
      '+' => '$leftTex + $rightTex',
      '-' => '$leftTex - $rightTex',
      '*' => '$leftTex \\cdot $rightTex',
      '/' => '\\frac{$leftTex}{$rightTex}',
      '^' => '($leftTex)^{$rightTex}',
      _ => '($leftTex)$operator($rightTex)',
    };
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
    if (exp == exp.toInt() && exp >= 0) {
      double result = 1;
      for (int i = 0; i < exp.toInt(); i++) {
        result *= base;
      }
      return result;
    }
    return double.nan;
  }

  @override
  ASTNode simplify() {
    final simpLeft = left.simplify();
    final simpRight = right.simplify();

    if (simpLeft is NumberNode && simpRight is NumberNode) {
      final result = evaluate(0, variable: 'x');
      return NumberNode(result);
    }
    return BinaryOpNode(operator, simpLeft, simpRight);
  }
}

class SqrtNode extends ASTNode {
  final ASTNode argument;
  SqrtNode(this.argument);

  @override
  String toTex() => '\\sqrt{${argument.toTex()}}';

  @override
  double evaluate(double x, {String? variable}) {
    final arg = argument.evaluate(x, variable: variable);
    return arg >= 0 ? _sqrt(arg) : double.nan;
  }

  double _sqrt(double n) {
    if (n == 0) return 0;
    double guess = n / 2;
    for (int i = 0; i < 20; i++) {
      guess = (guess + n / guess) / 2;
    }
    return guess;
  }

  @override
  ASTNode simplify() {
    final simpArg = argument.simplify();
    if (simpArg is NumberNode && simpArg.value >= 0) {
      return NumberNode(_sqrt(simpArg.value));
    }
    return SqrtNode(simpArg);
  }
}

class Parser {
  final List<Token> tokens;
  int pos = 0;

  Parser(this.tokens);

  ASTNode parse() {
    final result = _parseExpression();
    if (pos < tokens.length - 1) {
      throw ParserException('Unexpected token at position $pos');
    }
    return result;
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
      if (tokens[pos].type != TokenType.lparen) {
        throw ParserException('Expected ( after sqrt');
      }
      pos++;
      final arg = _parseExpression();
      if (tokens[pos].type != TokenType.rparen) {
        throw ParserException('Expected ) after sqrt argument');
      }
      pos++;
      return SqrtNode(arg);
    }

    if (token.type == TokenType.lparen) {
      pos++;
      final expr = _parseExpression();
      if (tokens[pos].type != TokenType.rparen) {
        throw ParserException('Expected closing parenthesis');
      }
      pos++;
      return expr;
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
