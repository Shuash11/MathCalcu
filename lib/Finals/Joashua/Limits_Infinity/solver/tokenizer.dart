// lib/parser/tokenizer.dart

/// Token types for mathematical expressions
enum TokenType {
  number,
  variable,
  operator,
  leftParen,
  rightParen,
  comma,
  function,
  infinity,
  pi,
  e,          // Euler's number
  eof,
}

/// A single token from the input
class Token {
  final TokenType type;
  final String value;
  final int position;
  
  const Token(this.type, this.value, this.position);
  
  @override
  String toString() => 'Token($type, "$value")';
}

/// Tokenizes a mathematical expression string
class Tokenizer {
  final String input;
  int _position = 0;
  
  Tokenizer(this.input);
  
  /// List of known mathematical functions
  static const _functions = [
    'sin', 'cos', 'tan', 'cot', 'sec', 'csc',
    'arcsin', 'arccos', 'arctan',
    'sinh', 'cosh', 'tanh',
    'ln', 'log', 'log10', 'log2',
    'sqrt', 'cbrt', 'abs', 'exp',
    'ceil', 'floor'
  ];
  
  /// Tokenize the entire input
  List<Token> tokenize() {
    var tokens = <Token>[];
    
    while (_position < input.length) {
      var char = input[_position];
      
      // Skip whitespace
      if (_isWhitespace(char)) {
        _position++;
        continue;
      }
      
      // Numbers
      if (_isDigit(char) || (char == '.' && _position + 1 < input.length && _isDigit(input[_position + 1]))) {
        tokens.add(_readNumber());
        continue;
      }
      
      // Variables (letters that aren't functions)
      if (_isLetter(char)) {
        var token = _readIdentifier();
        if (token != null) {
          tokens.add(token);
        }
        continue;
      }
      
      // Operators
      if (_isOperator(char)) {
        // Check for two-character operators
        if (char == '*' && _position + 1 < input.length && input[_position + 1] == '*') {
          tokens.add(Token(TokenType.operator, '^', _position));
          _position += 2;
          continue;
        }
        tokens.add(Token(TokenType.operator, char, _position));
        _position++;
        continue;
      }
      
      // Parentheses
      if (char == '(') {
        tokens.add(Token(TokenType.leftParen, '(', _position));
        _position++;
        continue;
      }
      if (char == ')') {
        tokens.add(Token(TokenType.rightParen, ')', _position));
        _position++;
        continue;
      }
      
      // Comma (for multi-argument functions)
      if (char == ',') {
        tokens.add(Token(TokenType.comma, ',', _position));
        _position++;
        continue;
      }
      
      // Unknown character - skip
      _position++;
    }
    
    tokens.add(Token(TokenType.eof, '', _position));
    return tokens;
  }
  
  Token _readNumber() {
    var start = _position;
    var hasDecimal = false;
    
    while (_position < input.length) {
      var char = input[_position];
      
      if (char == '.' && !hasDecimal) {
        hasDecimal = true;
        _position++;
      } else if (_isDigit(char)) {
        _position++;
      } else {
        break;
      }
    }
    
    return Token(TokenType.number, input.substring(start, _position), start);
  }
  
  Token? _readIdentifier() {
    var start = _position;
    
    while (_position < input.length && _isLetter(input[_position])) {
      _position++;
    }
    
    var identifier = input.substring(start, _position).toLowerCase();
    
    // Check for infinity
    if (identifier == 'inf' || identifier == 'infinity' || identifier == '∞') {
      return Token(TokenType.infinity, identifier, start);
    }
    
    // Check for pi
    if (identifier == 'pi' || identifier == 'π') {
      return Token(TokenType.pi, identifier, start);
    }
    
    // Check for Euler's number
    if (identifier == 'e' && (_position >= input.length || !_isLetter(input[_position]))) {
      return Token(TokenType.e, identifier, start);
    }
    
    // Check for functions (longest match first)
    for (var func in _functions) {
      if (identifier.startsWith(func)) {
        // Make sure it's not a longer identifier
        if (identifier.length == func.length) {
          return Token(TokenType.function, func, start);
        }
      }
    }
    
    // It's a variable
    return Token(TokenType.variable, identifier, start);
  }
  
  bool _isDigit(String char) => char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
  bool _isLetter(String char) {
    var code = char.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122) || char == 'π' || char == '∞';
  }
  bool _isWhitespace(String char) => char == ' ' || char == '\t' || char == '\n' || char == '\r';
  bool _isOperator(String char) => char == '+' || char == '-' || char == '*' || char == '/' || char == '^';
}