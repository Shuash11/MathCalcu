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

/// Abstract base class for AST nodes
abstract class ASTNode {
  @override
  String toString();
  double evaluate(double x);
  String toLatex();
}

/// Number literal node
class NumberNode extends ASTNode {
  final double value;

  NumberNode(this.value);

  @override
  String toString() {
    if (value == value.toInt() && value.abs() < 1e15)
      return value.toInt().toString();
    return value.toString();
  }

  @override
  double evaluate(double x) => value;

  @override
  String toLatex() => toString();
}

/// Variable node (x)
class VariableNode extends ASTNode {
  @override
  String toString() => 'x';

  @override
  double evaluate(double x) => x;

  @override
  String toLatex() => 'x';
}

/// Binary operation node
class BinaryOpNode extends ASTNode {
  final String operator;
  final ASTNode left;
  final ASTNode right;

  BinaryOpNode(this.operator, this.left, this.right);

  @override
  String toString() {
    final leftStr = _wrapIfNeeded(left, isRight: false);
    final rightStr = _wrapIfNeeded(right, isRight: true);
    return '$leftStr $operator $rightStr';
  }

  String _wrapIfNeeded(ASTNode node, {required bool isRight}) {
    if (node is BinaryOpNode) {
      final childPrec = _precedence(node.operator);
      final myPrec = _precedence(operator);

      if (childPrec < myPrec) return '($node)';

      // Right associative for power
      if (operator == '^' && isRight) return '($node)';

      // Same precedence but not associative for minus and divide
      if (childPrec == myPrec &&
          (operator == '-' || operator == '/') &&
          !isRight) {
        return '($node)';
      }
    }
    if (node is UnaryMinusNode) return '($node)';
    return node.toString();
  }

  int _precedence(String op) {
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
  String toLatex() {
    final opLatex = switch (operator) {
      '*' => '\\cdot ',
      '/' => '\\div ',
      _ => '$operator ',
    };
    final leftLatex = _wrapLatexIfNeeded(left, isRight: false);
    final rightLatex = _wrapLatexIfNeeded(right, isRight: true);
    return '$leftLatex $opLatex $rightLatex';
  }

  String _wrapLatexIfNeeded(ASTNode node, {required bool isRight}) {
    if (node is BinaryOpNode) {
      final childPrec = _precedence(node.operator);
      final myPrec = _precedence(operator);
      if (childPrec < myPrec) return '(${node.toLatex()})';
      if (operator == '^' && isRight) return '(${node.toLatex()})';
    }
    if (node is UnaryMinusNode) return '(${node.toLatex()})';
    return node.toLatex();
  }
}

/// Unary negation node
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
  String toLatex() {
    if (operand is BinaryOpNode || operand is UnaryMinusNode) {
      return '-(${operand.toLatex()})';
    }
    return '-${operand.toLatex()}';
  }
}

/// Function call node (sqrt, abs, etc.)
class FunctionCallNode extends ASTNode {
  final String functionName;
  final ASTNode argument;

  FunctionCallNode(this.functionName, this.argument);

  @override
  String toString() => '$functionName($argument)';

  @override
  double evaluate(double x) {
    final arg = argument.evaluate(x);
    return switch (functionName) {
      'sqrt' => sqrt(arg),
      'abs' => arg.abs(),
      _ => throw StateError('Unknown function: $functionName'),
    };
  }

  @override
  String toLatex() {
    return switch (functionName) {
      'sqrt' => '\\sqrt{${argument.toLatex()}}',
      'abs' => '|${argument.toLatex()}|',
      _ => '$functionName(${argument.toLatex()})',
    };
  }
}

/// Smart parser that can handle expressions without parentheses.
///
/// Key feature: Detects fraction patterns like "x^2-1/x-1"
/// and interprets them as "(x^2-1)/(x-1)" when appropriate.
class SmartParser {
  final List<Token> tokens;
  int _current = 0;

  SmartParser(this.tokens);

  /// Parse with smart fraction detection
  ASTNode parse() {
    // First, try smart fraction detection
    final smartResult = _tryParseAsFraction();
    if (smartResult != null) {
      if (tokens[_current].type != TokenType.eof) {
        throw ParserException(
            'Unexpected token after expression', tokens[_current]);
      }
      return smartResult;
    }

    // Fall back to normal parsing
    final result = _parseExpression();
    if (tokens[_current].type != TokenType.eof) {
      throw ParserException(
          'Unexpected token after expression', tokens[_current]);
    }
    return result;
  }

  /// Try to detect and parse a fraction pattern.
  ///
  /// Detects patterns like:
  /// - "x^2-1/x-1" → (x^2-1)/(x-1)
  /// - "2x+3/x^2+1" → (2x+3)/(x^2+1)
  ///
  /// Does NOT convert:
  /// - "x/2+x" → x/2+x (standard order of operations)
  /// - "1/2+x" → 1/2+x (standard order of operations)
  ASTNode? _tryParseAsFraction() {
    // Only attempt if there's at least one division
    if (!_hasDivision()) return null;

    // Find the "main" division - the one that looks like a fraction separator
    final divIndex = _findMainFractionDivision();
    if (divIndex == null) return null;

    // Save current position
    final savedPosition = _current;

    // Try to parse left side as a polynomial-like expression (NOT including the division)
    final leftTokens = tokens.sublist(0, divIndex);
    final leftParser = SmartParser(leftTokens);
    ASTNode? left;
    try {
      left = leftParser._parseExpression();
      // For left side, we need to check if parser consumed all tokens EXCEPT EOF
      if (leftParser._current != leftParser.tokens.length - 1) {
        _current = savedPosition;
        return null;
      }
    } catch (e) {
      _current = savedPosition;
      return null;
    }

    // Try to parse right side as a polynomial-like expression
    final rightTokens = tokens.sublist(divIndex + 1);
    final rightParser = SmartParser(rightTokens);
    ASTNode? right;
    try {
      right = rightParser._parseExpression();
      if (rightParser._current != rightParser.tokens.length - 1) {
        _current = savedPosition;
        return null;
      }
    } catch (e) {
      _current = savedPosition;
      return null;
    }

    // Check if both sides look like they could be polynomial parts
    if (!_looksLikePolynomialPart(left) || !_looksLikePolynomialPart(right)) {
      _current = savedPosition;
      return null;
    }

    // Skip to end of original tokens
    _current = tokens.length - 1;

    return BinaryOpNode('/', left, right);
  }

  /// Check if there's any division in the remaining tokens
  bool _hasDivision() {
    for (int i = _current; i < tokens.length; i++) {
      if (tokens[i].type == TokenType.divide) return true;
    }
    return false;
  }

  /// Find the main division that looks like a fraction separator.
  ///
  /// Heuristics:
  /// - Should be at "top level" (not inside parens)
  /// - Both sides should have variable terms
  /// - Prefer division that's roughly in the "middle" of the expression
  int? _findMainFractionDivision() {
    final divisions = <int>[];
    int depth = 0;

    for (int i = _current; i < tokens.length; i++) {
      final token = tokens[i];
      if (token.type == TokenType.leftParen) depth++;
      if (token.type == TokenType.rightParen) depth--;

      if (token.type == TokenType.divide && depth == 0) {
        divisions.add(i);
      }
    }

    if (divisions.isEmpty) return null;

    // For each division, check if both sides have 'x'
    final validDivisions = <int>[];
    for (var divPos in divisions) {
      final leftHasX = _sectionHasVariable(_current, divPos);
      final rightHasX = _sectionHasVariable(divPos + 1, tokens.length - 1);

      if (leftHasX && rightHasX) {
        validDivisions.add(divPos);
      }
    }

    if (validDivisions.isEmpty) return null;

    // If multiple valid divisions, prefer the one that creates
    // balanced-looking numerator and denominator
    if (validDivisions.length == 1) return validDivisions.first;

    // Pick the one closest to the middle
    final mid = (_current + tokens.length) ~/ 2;
    validDivisions.sort((a, b) => (a - mid).abs().compareTo((b - mid).abs()));

    return validDivisions.first;
  }

  /// Check if a section of tokens contains a variable
  bool _sectionHasVariable(int start, int end) {
    if (start >= end) return false;
    for (int i = start; i < end && i < tokens.length; i++) {
      if (tokens[i].type == TokenType.variable) return true;
    }
    return false;
  }

  /// Check if an AST node looks like a polynomial part
  /// (not a simple constant or single variable division)
  bool _looksLikePolynomialPart(ASTNode node) {
    // Single number is NOT a polynomial part
    if (node is NumberNode) return false;

    // Single variable alone IS okay
    if (node is VariableNode) return true;

    // Anything else (binary ops, functions) is likely a polynomial part
    return true;
  }

  // ===== Standard Recursive Descent Parser =====

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

  ASTNode _parsePower() {
    var base = _parseUnary();

    if (tokens[_current].type == TokenType.power) {
      _current++;
      final exponent = _parseUnary();
      base = BinaryOpNode('^', base, exponent);
    }

    return base;
  }

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

  ASTNode _parseAtom() {
    final token = tokens[_current];

    // Function calls: sqrt, abs
    if (token.type == TokenType.sqrt || token.type == TokenType.abs) {
      final funcName = token.value;
      _current++;
      if (tokens[_current].type != TokenType.leftParen) {
        throw ParserException('Expected "(" after $funcName', tokens[_current]);
      }
      _current++;
      final arg = _parseExpression();
      if (tokens[_current].type != TokenType.rightParen) {
        throw ParserException(
            'Expected ")" after function argument', tokens[_current]);
      }
      _current++;
      return FunctionCallNode(funcName, arg);
    }

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
      final expr = _parseExpression();
      if (tokens[_current].type != TokenType.rightParen) {
        throw ParserException(
            'Expected ")" but found "${tokens[_current].value}"',
            tokens[_current]);
      }
      _current++;
      return expr;
    }

    throw ParserException('Unexpected token "${token.value}"', token);
  }
}
