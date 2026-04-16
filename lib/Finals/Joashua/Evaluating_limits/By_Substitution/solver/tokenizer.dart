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
  sqrt, // sqrt symbol or function
  abs, // absolute value
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

/// Enhanced tokenizer that handles various mathematical notations.
///
/// Features:
/// - Implicit multiplication (2x, x(x+1), (x+1)(x-1))
/// - Square root notation (√ or sqrt)
/// - Absolute value notation (|x|)
class SmartTokenizer {
  final String input;
  int _position = 0;

  SmartTokenizer(this.input);

  /// Pre-process input to handle special notations
  String _preprocess() {
    String result = input;

    // Replace √ with sqrt(
    result = result.replaceAll('√', 'sqrt(');

    // Replace |...| with abs(...)... - need to handle matching
    result = _convertAbsoluteValue(result);

    return result;
  }

  /// Convert |expr| to abs(expr)
  String _convertAbsoluteValue(String s) {
    final result = StringBuffer();
    int i = 0;
    bool inAbs = false;

    while (i < s.length) {
      if (s[i] == '|') {
        if (!inAbs) {
          result.write('abs(');
          inAbs = true;
        } else {
          result.write(')');
          inAbs = false;
        }
        i++;
      } else {
        result.write(s[i]);
        i++;
      }
    }

    return result.toString();
  }

  /// Tokenize the entire input string
  List<Token> tokenize() {
    final preprocessed = _preprocess();
    final tokenizer = _SimpleTokenizer(preprocessed);
    return tokenizer.tokenize();
  }
}

/// Internal simple tokenizer
class _SimpleTokenizer {
  final String input;
  int _position = 0;

  _SimpleTokenizer(this.input);

  List<Token> tokenize() {
    final tokens = <Token>[];

    while (_position < input.length) {
      final char = input[_position];

      // Skip whitespace
      if (_isWhitespace(char)) {
        _position++;
        continue;
      }

      // Read multi-character tokens first
      if (_position + 3 < input.length &&
          input.substring(_position, _position + 4) == 'sqrt') {
        tokens.add(Token(TokenType.sqrt, 'sqrt', _position));
        _position += 4;
        continue;
      }

      if (_position + 2 < input.length &&
          input.substring(_position, _position + 3) == 'abs') {
        tokens.add(Token(TokenType.abs, 'abs', _position));
        _position += 3;
        continue;
      }

      Token? currentToken;

      // Number
      if (_isDigit(char) ||
          (char == '.' &&
              _position + 1 < input.length &&
              _isDigit(input[_position + 1]))) {
        currentToken = _readNumber();
      }
      // Variable
      else if (char.toLowerCase() == 'x') {
        currentToken = Token(TokenType.variable, 'x', _position);
        _position++;
      }
      // Operators and parens
      else {
        final tokenType = _getTokenType(char);
        if (tokenType != null) {
          currentToken = Token(tokenType, char, _position);
          _position++;
        } else {
          throw TokenizerException('Unexpected character "$char"', _position);
        }
      }

      // Insert implicit multiplication
      if (tokens.isNotEmpty && currentToken != null) {
        if (_needsImplicitMultiply(tokens.last, currentToken)) {
          tokens.add(Token(TokenType.multiply, '*', currentToken.position));
        }
      }

      tokens.add(currentToken!);
    }

    tokens.add(Token(TokenType.eof, '', _position));
    return tokens;
  }

  Token _readNumber() {
    final start = _position;
    final buffer = StringBuffer();

    while (_position < input.length && _isDigit(input[_position])) {
      buffer.write(input[_position]);
      _position++;
    }

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

  bool _needsImplicitMultiply(Token prev, Token curr) {
    // number → variable or '(' or function
    if (prev.type == TokenType.number) {
      return curr.type == TokenType.variable ||
          curr.type == TokenType.leftParen ||
          curr.type == TokenType.sqrt ||
          curr.type == TokenType.abs;
    }
    // variable → '(' or function
    if (prev.type == TokenType.variable) {
      return curr.type == TokenType.leftParen ||
          curr.type == TokenType.sqrt ||
          curr.type == TokenType.abs;
    }
    // ')' → number, variable, '(' or function
    if (prev.type == TokenType.rightParen) {
      return curr.type == TokenType.number ||
          curr.type == TokenType.variable ||
          curr.type == TokenType.leftParen ||
          curr.type == TokenType.sqrt ||
          curr.type == TokenType.abs;
    }
    return false;
  }

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
    return code >= 48 && code <= 57;
  }

  bool _isWhitespace(String char) =>
      char == ' ' || char == '\t' || char == '\n' || char == '\r';
}
