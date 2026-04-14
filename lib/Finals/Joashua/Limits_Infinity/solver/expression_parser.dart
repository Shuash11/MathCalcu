// lib/parser/expression_parser.dart

import 'ast_nodes.dart';
import 'tokenizer.dart';

/// Parses tokens into an AST
class ExpressionParser {
  final List<Token> tokens;
  int _position = 0;
  
  ExpressionParser(this.tokens);
  
  /// Parse the entire expression
  ASTNode parse() {
    var result = _parseExpression();
    if (_current.type != TokenType.eof) {
      throw ParseException('Unexpected token: ${_current.value}');
    }
    return result;
  }
  
  Token get _current => tokens[_position];
  
  void _advance() {
    if (_position < tokens.length - 1) {
      _position++;
    }
  }
  
  void _expect(TokenType type) {
    if (_current.type != type) {
      throw ParseException('Expected $type, got ${_current.type}');
    }
    _advance();
  }
  
  /// expression = term (('+' | '-') term)*
  ASTNode _parseExpression() {
    var left = _parseTerm();
    
    while (_current.type == TokenType.operator && 
           (_current.value == '+' || _current.value == '-')) {
      var op = _current.value;
      _advance();
      var right = _parseTerm();
      left = BinaryOpNode(left, op, right);
    }
    
    return left;
  }
  
  /// term = power (('*' | '/') power)*
  ASTNode _parseTerm() {
    var left = _parsePower();
    
    while (_current.type == TokenType.operator && 
           (_current.value == '*' || _current.value == '/')) {
      var op = _current.value;
      _advance();
      
      // Handle implicit multiplication: 2x, 2(3+x), x(x+1)
      var right = _parsePower();
      left = BinaryOpNode(left, op, right);
    }
    
    // Handle implicit multiplication: 2x, 2sin(x), etc.
    if (_current.type == TokenType.number ||
        _current.type == TokenType.variable ||
        _current.type == TokenType.function ||
        _current.type == TokenType.leftParen ||
        _current.type == TokenType.pi ||
        _current.type == TokenType.e ||
        _current.type == TokenType.infinity) {
      var right = _parsePower();
      left = BinaryOpNode(left, '*', right);
    }
    
    return left;
  }
  
  /// power = unary ('^' unary)*
  ASTNode _parsePower() {
    var base = _parseUnary();
    
    if (_current.type == TokenType.operator && _current.value == '^') {
      _advance();
      var exponent = _parseUnary(); // Right-associative
      return BinaryOpNode(base, '^', exponent);
    }
    
    return base;
  }
  
  /// unary = ('-')? postfix
  ASTNode _parseUnary() {
    // Handle unary minus
    if (_current.type == TokenType.operator && _current.value == '-') {
      _advance();
      var operand = _parseUnary();
      return UnaryMinusNode(operand);
    }
    
    // Handle unary plus
    if (_current.type == TokenType.operator && _current.value == '+') {
      _advance();
      return _parseUnary();
    }
    
    return _parsePostfix();
  }
  
  /// postfix = primary ('!')?
  ASTNode _parsePostfix() {
    var node = _parsePrimary();
    
    // Handle factorial if needed in the future
    return node;
  }
  
  /// primary = number | variable | infinity | pi | e | function | '(' expression ')'
  ASTNode _parsePrimary() {
    var token = _current;
    
    switch (token.type) {
      case TokenType.number:
        _advance();
        return NumberNode(double.parse(token.value));
        
      case TokenType.variable:
        _advance();
        return VariableNode(token.value);
        
      case TokenType.infinity:
        _advance();
        return InfinityNode(false);
        
      case TokenType.pi:
        _advance();
        return NumberNode(3.14159265358979323846);
        
      case TokenType.e:
        _advance();
        return NumberNode(2.71828182845904523536);
        
      case TokenType.function:
        return _parseFunction();
        
      case TokenType.leftParen:
        _advance();
        var expr = _parseExpression();
        _expect(TokenType.rightParen);
        return expr;
        
      default:
        throw ParseException('Unexpected token: ${token.value}');
    }
  }
  
  /// function = identifier '(' expression (',' expression)* ')'
  ASTNode _parseFunction() {
    var funcName = _current.value;
    _advance();
    _expect(TokenType.leftParen);
    
    var argument = _parseExpression();
    
    // Handle additional arguments if present
    // Currently we only support single-argument functions
    
    _expect(TokenType.rightParen);
    
    // Special case: sqrt without parentheses can be handled as sqrt(x)
    return FunctionNode(funcName, argument);
  }
}

/// Parse a mathematical expression string into an AST
ASTNode parseExpression(String input) {
  var tokenizer = Tokenizer(input);
  var tokens = tokenizer.tokenize();
  var parser = ExpressionParser(tokens);
  return parser.parse();
}

/// Exception thrown when parsing fails
class ParseException implements Exception {
  final String message;
  ParseException(this.message);
  
  @override
  String toString() => 'ParseException: $message';
}