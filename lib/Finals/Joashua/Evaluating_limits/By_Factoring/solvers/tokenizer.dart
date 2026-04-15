/// Token types for mathematical expressions
enum TokenType {
  number,
  variable,
  plus,
  minus,
  multiply,
  divide,
  power,
  leftParen,
  rightParen,
  function,
  eof,
}

/// Represents a single token extracted from input
class Token {
  final TokenType type;
  final String value;
  final int position;

  const Token(this.type, this.value, this.position);

  @override
  String toString() => 'Token($type, "$value", pos=$position)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Token && type == other.type && value == other.value;

  @override
  int get hashCode => type.hashCode ^ value.hashCode;
}

/// Exception thrown when tokenization fails
class TokenizerException implements Exception {
  final String message;
  final int? position;

  const TokenizerException(this.message, [this.position]);

  @override
  String toString() {
    if (position != null) {
      return 'TokenizerError at position $position: $message';
    }
    return 'TokenizerError: $message';
  }
}

/// Converts a mathematical expression string into a list of tokens.
/// 
/// Handles implicit multiplication (e.g., "2x" → "2 * x", "(x+1)(x-1)" → "(x+1) * (x-1)")
class Tokenizer {
  final String input;
  int _position = 0;

  Tokenizer(this.input);

  /// Tokenize the entire input string
  List<Token> tokenize() {
    final tokens = <Token>[];

    while (_position < input.length) {
      final char = input[_position];

      // Skip whitespace characters
      if (_isWhitespace(char)) {
        _position++;
        continue;
      }

      // Read a number (integer or decimal)
      final Token currentToken;

      if (_isDigit(char) ||
          (char == '.' &&
              _position + 1 < input.length &&
              _isDigit(input[_position + 1]))) {
        currentToken = _readNumber();
      }
      // Read variable 'x'
      else if (char.toLowerCase() == 'x') {
        currentToken = Token(TokenType.variable, 'x', _position);
        _position++;
      }
      // Read operators and parentheses
      else {
        final tokenType = _getTokenType(char);
        if (tokenType != null) {
          currentToken = Token(tokenType, char, _position);
          _position++;
        } else if (char == '√' || char == '\u221A') {
          currentToken = Token(TokenType.function, 'sqrt', _position);
          _position++;
        } else {
          throw TokenizerException(
              'Unexpected character "$char"', _position);
        }
      }

      // Insert implicit multiplication token where needed
      if (tokens.isNotEmpty) {
        if (_needsImplicitMultiply(tokens.last, currentToken)) {
          tokens.add(Token(TokenType.multiply, '*', currentToken.position));
        }
      }

      tokens.add(currentToken);
    }

    tokens.add(Token(TokenType.eof, '', _position));
    return tokens;
  }

  /// Read a complete number (handles integers and decimals)
  Token _readNumber() {
    final start = _position;
    final buffer = StringBuffer();

    // Read integer part
    while (_position < input.length && _isDigit(input[_position])) {
      buffer.write(input[_position]);
      _position++;
    }

    // Read decimal part if present
    if (_position < input.length && input[_position] == '.') {
      buffer.write('.');
      _position++;
      while (_position < input.length && _isDigit(input[_position])) {
        buffer.write(input[_position]);
        _position++;
      }
    }

    return Token(TokenType.number, buffer.toString(), start);
  }

  /// Determine if implicit multiplication should be inserted between two tokens
  bool _needsImplicitMultiply(Token prev, Token curr) {
    // number followed by variable or '(' : 2x, 2(x+1)
    if (prev.type == TokenType.number) {
      return curr.type == TokenType.variable ||
          curr.type == TokenType.leftParen;
    }
    // variable followed by '(' : x(x+1)
    if (prev.type == TokenType.variable) {
      return curr.type == TokenType.leftParen;
    }
    // ')' followed by number, variable, or '(' : (x+1)2, (x+1)x, (x+1)(x-1)
    if (prev.type == TokenType.rightParen) {
      return curr.type == TokenType.number ||
          curr.type == TokenType.variable ||
          curr.type == TokenType.leftParen;
    }
    return false;
  }

  /// Map a character to its token type
  TokenType? _getTokenType(String char) {
    return switch (char) {
      '+' => TokenType.plus,
      '-' => TokenType.minus,
      '*' => TokenType.multiply,
      '/' => TokenType.divide,
      '^' => TokenType.power,
      '(' => TokenType.leftParen,
      ')' => TokenType.rightParen,
      _ => null,
    };
  }

  bool _isDigit(String char) {
    final code = char.codeUnitAt(0);
    return code >= 48 && code <= 57; // '0' to '9'
  }

  bool _isWhitespace(String char) =>
      char == ' ' || char == '\t' || char == '\n' || char == '\r';
}