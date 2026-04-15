library lcd_math_engine;
/// src/lcd_engine.dart
import 'dart:math';

import 'steps.dart';

// ==========================================
// 1. ABSTRACT SYNTAX TREE (AST) NODES
// ==========================================
abstract class MathNode {
  const MathNode();
}

class NumberNode extends MathNode {
  final double value;
  const NumberNode(this.value);
}

class VariableNode extends MathNode {
  final String name;
  const VariableNode(this.name);
}

class BinaryOpNode extends MathNode {
  final String op;
  final MathNode left;
  final MathNode right;
  const BinaryOpNode(this.op, this.left, this.right);
}

class FunctionNode extends MathNode {
  final String name; // e.g., 'sqrt'
  final MathNode arg;
  const FunctionNode(this.name, this.arg);
}

class UnaryMinusNode extends MathNode {
  final MathNode child;
  const UnaryMinusNode(this.child);
}

// ==========================================
// 2. TOKENIZER (LEXER)
// ==========================================
enum TokenType { number, variable, operator, lparen, rparen, function, eof }

class Token {
  final TokenType type;
  final String value;
  const Token(this.type, this.value);
}

class Tokenizer {
  final String input;
  int _pos = 0;

  Tokenizer(this.input);

  List<Token> tokenize() {
    final tokens = <Token>[];
    while (_pos < input.length) {
      final ch = input[_pos];
      if (RegExp(r'\s').hasMatch(ch)) {
        _pos++;
      } else if (RegExp(r'[0-9.]').hasMatch(ch)) {
        tokens.add(_readNumber());
      } else if (RegExp(r'[a-z]').hasMatch(ch)) {
        tokens.add(_readIdentifier());
      } else if (ch == '(') {
        tokens.add(Token(TokenType.lparen, ch));
        _pos++;
      } else if (ch == ')') {
        tokens.add(Token(TokenType.rparen, ch));
        _pos++;
      } else if (ch == '√' || ch == '\u221A') {
        tokens.add(Token(TokenType.function, 'sqrt'));
        _pos++;
      } else if (RegExp(r'[+\-*/^]').hasMatch(ch)) {
        tokens.add(Token(TokenType.operator, ch));
        _pos++;
      } else {
        throw Exception("Invalid character: $ch");
      }
    }
    tokens.add(const Token(TokenType.eof, ''));
    return tokens;
  }

  Token _readNumber() {
    final buffer = StringBuffer();
    while (_pos < input.length && RegExp(r'[0-9.]').hasMatch(input[_pos])) {
      buffer.write(input[_pos++]);
    }
    return Token(TokenType.number, buffer.toString());
  }

  Token _readIdentifier() {
    final buffer = StringBuffer();
    while (_pos < input.length && RegExp(r'[a-z]').hasMatch(input[_pos])) {
      buffer.write(input[_pos++]);
    }
    final val = buffer.toString();
    // Check if it's a known function like sqrt
    if (val == 'sqrt') return Token(TokenType.function, val);
    return Token(TokenType.variable, val);
  }
}

// ==========================================
// 3. PARSER (Recursive Descent)
// ==========================================
class Parser {
  final List<Token> tokens;
  int _current = 0;

  Parser(this.tokens);

  MathNode parse() {
    final node = _parseExpression();
    if (_current < tokens.length - 1) {
      throw Exception("Unexpected token at end");
    }
    return node;
  }

  MathNode _parseExpression() => _parseAddSub();

  MathNode _parseAddSub() {
    var left = _parseMulDiv();
    while (_current < tokens.length &&
        (tokens[_current].value == '+' || tokens[_current].value == '-')) {
      final op = tokens[_current++].value;
      final right = _parseMulDiv();
      left = BinaryOpNode(op, left, right);
    }
    return left;
  }

  MathNode _parseMulDiv() {
    var left = _parsePower();
    while (_current < tokens.length &&
        (tokens[_current].value == '*' || tokens[_current].value == '/')) {
      final op = tokens[_current++].value;
      final right = _parsePower();
      left = BinaryOpNode(op, left, right);
    }
    return left;
  }

  MathNode _parsePower() {
    var base = _parseUnary();
    if (_current < tokens.length && tokens[_current].value == '^') {
      _current++;
      final exp = _parseUnary();
      base = BinaryOpNode('^', base, exp);
    }
    return base;
  }

  MathNode _parseUnary() {
    if (tokens[_current].value == '-') {
      _current++;
      final child = _parsePrimary();
      return UnaryMinusNode(child);
    }
    return _parsePrimary();
  }

  MathNode _parsePrimary() {
    final token = tokens[_current];
    if (token.type == TokenType.number) {
      _current++;
      return NumberNode(double.parse(token.value));
    } else if (token.type == TokenType.variable) {
      _current++;
      return VariableNode(token.value);
    } else if (token.type == TokenType.function) {
      _current++;
      final funcName = token.value;
      _expect(TokenType.lparen);
      
      // Handle empty function argument like sqrt()
      if (_current < tokens.length && tokens[_current].type == TokenType.rparen) {
        _current++;
        return FunctionNode(funcName, const NumberNode(0));
      }
      
      final arg = _parseExpression();
      _expect(TokenType.rparen);
      return FunctionNode(funcName, arg);
    } else if (token.type == TokenType.lparen) {
      _current++;
      
      // Handle empty parentheses ()
      if (_current < tokens.length && tokens[_current].type == TokenType.rparen) {
        _current++;
        return const NumberNode(0);
      }
      
      final expr = _parseExpression();
      _expect(TokenType.rparen);
      return expr;
    }
    
    throw Exception("Math Error: Unexpected '${token.value}' at this position.");
  }

  void _expect(TokenType type) {
    if (tokens[_current].type != type) throw Exception("Expected $type");
    _current++;
  }
}

// ==========================================
// 4. ENGINE EVALUATOR & STRATEGY ROUTER
// ==========================================
enum LimitStrategy { directSubstitution, lcd, conjugate, unknown }

class LimitEngine {
  /// Main entry point to solve a limit
  static LimitSolution solve(
      String equation, String variable, double approachValue) {
    // Clean up input
    equation = equation.replaceAll(' ', '').replaceAll('lim', '');
    
    // Smart Preprocessing: If user types "1/x - 1/3 / x-3", help them by wrapping 
    // the likely numerator and denominator.
    equation = _smartPreprocess(equation);

    final tokens = Tokenizer(equation).tokenize();
    final ast = Parser(tokens).parse();

    // Step 1: Try Direct Substitution
    double? directResult;
    try {
      directResult = _evaluate(ast, variable, approachValue);
    } catch (e) {
      // Catches division by zero or sqrt of negative number
      // This means we likely have an indeterminate form
    }

    if (directResult != null && directResult.isFinite) {
      return StepGenerator.directSubstitutionSuccess(
          equation, variable, approachValue, directResult);
    }

    // Step 2: Identify Indeterminate Form (0/0) and Route Strategy
    final strategy = _identifyStrategy(ast, variable, approachValue);

    // Step 3: Pass the AST to the StepGenerator so it can extract exact algebra strings
    if (strategy == LimitStrategy.conjugate) {
      return StepGenerator.solveByConjugate(
          equation, variable, approachValue, ast);
    } else if (strategy == LimitStrategy.lcd) {
      return StepGenerator.solveByLCD(equation, variable, approachValue, ast);
    }

    return StepGenerator.unknownForm(equation, variable, approachValue);
  }

  static double _evaluate(MathNode node, String varName, double val) {
    if (node is NumberNode) return node.value;
    if (node is VariableNode) return val;
    if (node is UnaryMinusNode) return -_evaluate(node.child, varName, val);
    if (node is FunctionNode) {
      if (node.name == 'sqrt') {
        final argVal = _evaluate(node.arg, varName, val);
        // Proper mathematical protection: if the inside is negative, the limit
        // doesn't exist in the real plane. We throw to trigger strategy routing.
        if (argVal < 0) throw Exception("Square root of negative number");
        return sqrt(argVal);
      }
      throw UnimplementedError("Unknown function: ${node.name}");
    }
    if (node is BinaryOpNode) {
      final l = _evaluate(node.left, varName, val);
      final r = _evaluate(node.right, varName, val);
      switch (node.op) {
        case '+':
          return l + r;
        case '-':
          return l - r;
        case '*':
          return l * r;
        case '/':
          if (r == 0) throw Exception("Division by zero");
          return l / r;
        case '^':
          return pow(l, r).toDouble();
        default:
          throw Exception("Unknown operator: ${node.op}");
      }
    }
    throw Exception("Unknown AST Node type");
  }

  static LimitStrategy _identifyStrategy(
      MathNode node, String varName, double val) {
    // Heuristic: Does the AST contain a sqrt function? Assume Conjugate.
    if (_containsFunction(node, 'sqrt')) return LimitStrategy.conjugate;

    // Heuristic: Does the top-level structure have divisions inside the numerator or denominator? Assume LCD.
    if (_hasNestedFractions(node)) return LimitStrategy.lcd;

    return LimitStrategy.unknown;
  }

  static bool _containsFunction(MathNode node, String name) {
    if (node is FunctionNode && node.name == name) return true;
    if (node is BinaryOpNode) {
      return _containsFunction(node.left, name) ||
          _containsFunction(node.right, name);
    }
    if (node is UnaryMinusNode) return _containsFunction(node.child, name);
    return false;
  }

  static bool _hasNestedFractions(MathNode node) {
    if (node is BinaryOpNode) {
      // A "complex fraction" is one where the overall numerator itself
      // contains a division (e.g. (1/x - 1/3) / (x - 3)).
      // We deliberately do NOT match just any +/- in the numerator — that
      // would wrongly catch conjugate or polynomial-factoring problems.
      if (node.op == '/' && _containsOp(node.left, '/')) return true;
      return _hasNestedFractions(node.left) || _hasNestedFractions(node.right);
    }
    if (node is UnaryMinusNode) return _hasNestedFractions(node.child);
    return false;
  }

  static bool _containsOp(MathNode node, String op) {
    if (node is BinaryOpNode) {
      if (node.op == op) return true;
      return _containsOp(node.left, op) || _containsOp(node.right, op);
    }
    if (node is UnaryMinusNode) return _containsOp(node.child, op);
    return false;
  }

  /// Helps users who forget outer parentheses: "1/x - 1/3 / x - 3" -> "(1/x - 1/3) / (x - 3)"
  static String _smartPreprocess(String input) {
    if (input.startsWith('(') && input.endsWith(')')) return input;

    // Count occurrences of '/'
    int slashCount = '/'.allMatches(input).length;
    if (slashCount < 2) return input; // Only one slash, ambiguity is low

    // Heuristic: Find the division that splits the expression into a complex numerator 
    // and a simple binomial denominator (common in limit problems).
    // Usually the 'main' division is the LAST one that isn't inside parentheses,
    // OR it's the one splitting the expression into the largest chunks.
    
    // For "1/x - 1/3 / x - 3", the divisions are at indices 1, 9, and 13.
    // If we pick index 9: numerator "1/x-1/3", denominator "x-3".
    // This looks like a valid limit problem!
    
    // We try to find a division index 'i' such that 
    // numerator = input.substring(0, i) and denominator = input.substring(i+1)
    // and numerator contains a '/' while denominator does NOT (for standard LCD/Conjugate).
    for (int i = input.length - 1; i >= 0; i--) {
      if (input[i] == '/') {
        String num = input.substring(0, i);
        String den = input.substring(i + 1);
        
        // If numerator has its own division and denominator looks like a linear factor (no /)
        if (num.contains('/') && !den.contains('/')) {
           return "($num)/($den)";
        }
      }
    }

    return input; 
  }
}
