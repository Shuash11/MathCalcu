class TokenType {
  static const int number = 0;
  static const int variable = 1;
  static const int operator = 2;
  static const int lparen = 3;
  static const int rparen = 4;
  static const int sqrt = 5;
  static const int end = 6;
}

class Token {
  final int type;
  final dynamic value;

  const Token(this.type, [this.value]);

  @override
  String toString() {
    switch (type) {
      case TokenType.number:
        return 'NUM($value)';
      case TokenType.variable:
        return 'VAR($value)';
      case TokenType.operator:
        return 'OP($value)';
      case TokenType.lparen:
        return 'LPAREN';
      case TokenType.rparen:
        return 'RPAREN';
      case TokenType.sqrt:
        return 'SQRT';
      case TokenType.end:
        return 'END';
      default:
        return 'UNKNOWN';
    }
  }
}

class Tokenizer {
  final String input;
  int pos = 0;

  Tokenizer(this.input);

  List<Token> tokenize() {
    final tokens = <Token>[];
    while (pos < input.length) {
      _skipWhitespace();
      if (pos >= input.length) break;

      final ch = input[pos];

      if (_isDigit(ch) || ch == '.') {
        tokens.add(_readNumber());
      } else if (_isAlpha(ch)) {
        if (ch == 's' &&
            pos + 4 <= input.length &&
            input.substring(pos, pos + 4) == 'sqrt') {
          tokens.add(const Token(TokenType.sqrt));
          pos += 4;
        } else {
          tokens.add(_readVariable());
        }
      } else if (ch == '(') {
        tokens.add(const Token(TokenType.lparen));
        pos++;
      } else if (ch == ')') {
        tokens.add(const Token(TokenType.rparen));
        pos++;
      } else if ('+-*/^'.contains(ch)) {
        tokens.add(Token(TokenType.operator, ch));
        pos++;
      } else {
        pos++;
      }
    }
    tokens.add(const Token(TokenType.end));
    return tokens;
  }

  void _skipWhitespace() {
    while (pos < input.length && ' \t\n'.contains(input[pos])) {
      pos++;
    }
  }

  Token _readNumber() {
    final start = pos;
    while (pos < input.length && (_isDigit(input[pos]) || input[pos] == '.')) {
      pos++;
    }
    final numStr = input.substring(start, pos);
    return Token(TokenType.number, double.parse(numStr));
  }

  Token _readVariable() {
    final start = pos;
    while (pos < input.length && _isAlpha(input[pos])) {
      pos++;
    }
    return Token(TokenType.variable, input.substring(start, pos));
  }

  bool _isDigit(String ch) => ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
  bool _isAlpha(String ch) {
    final code = ch.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }
}

class TokenizerException implements Exception {
  final String message;
  TokenizerException(this.message);

  @override
  String toString() => 'TokenizerError: $message';
}
