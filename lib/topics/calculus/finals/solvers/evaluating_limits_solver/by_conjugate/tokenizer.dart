class TokenType {
  static const int number = 0;
  static const int variable = 1;
  static const int operator = 2;
  static const int lparen = 3;
  static const int rparen = 4;
  static const int sqrt = 5;
  static const int abs = 6;
  static const int end = 7;
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
      case TokenType.abs:
        return 'ABS';
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

  String _preprocess() {
    var result = input
        .replaceAll('−', '-')
        .replaceAll('–', '-')
        .replaceAll('??"', '-')
        .replaceAll('√', 'sqrt')
        .replaceAll('??ˆš', 'sqrt')
        .replaceAll('??', '*')
        .replaceAll('?', '/');

    result = result
        .replaceAll('⁰', '^0')
        .replaceAll('¹', '^1')
        .replaceAll('?', '^2')
        .replaceAll('³', '^3')
        .replaceAll('⁴', '^4')
        .replaceAll('⁵', '^5')
        .replaceAll('⁶', '^6')
        .replaceAll('⁷', '^7')
        .replaceAll('⁸', '^8')
        .replaceAll('⁹', '^9')
        .replaceAll('??°', '^0')
        .replaceAll('??¹', '^1')
        .replaceAll('???', '^2')
        .replaceAll('??³', '^3')
        .replaceAll('??´', '^4')
        .replaceAll('??µ', '^5')
        .replaceAll('??¶', '^6')
        .replaceAll('???', '^7')
        .replaceAll('??¸', '^8')
        .replaceAll('??¹', '^9');

    final absBuf = StringBuffer();
    var inAbs = false;
    for (var i = 0; i < result.length; i++) {
      if (result[i] == '|') {
        absBuf.write(inAbs ? ')' : 'abs(');
        inAbs = !inAbs;
      } else {
        absBuf.write(result[i]);
      }
    }

    return absBuf.toString();
  }

  List<Token> tokenize() {
    final processedInput = _preprocess();
    pos = 0;
    final tokens = <Token>[];

    while (pos < processedInput.length) {
      _skipWhitespace(processedInput);
      if (pos >= processedInput.length) break;

      final ch = processedInput[pos];

      if (_isDigit(ch) || ch == '.') {
        tokens.add(_readNumber(processedInput));
      } else if (_isAlpha(ch)) {
        if (_startsWithWord(processedInput, 'sqrt')) {
          tokens.add(const Token(TokenType.sqrt));
          pos += 4;
        } else if (_startsWithWord(processedInput, 'abs')) {
          tokens.add(const Token(TokenType.abs));
          pos += 3;
        } else {
          tokens.add(_readVariable(processedInput));
        }
      } else if (ch == '(') {
        tokens.add(const Token(TokenType.lparen));
        pos++;
      } else if (ch == ')') {
        tokens.add(const Token(TokenType.rparen));
        pos++;
      } else if ('+-*/^<>≤≥'.contains(ch)) {
        tokens.add(Token(TokenType.operator, ch));
        pos++;
      } else {
        throw TokenizerException('Unexpected character "$ch"');
      }
    }

    tokens.add(const Token(TokenType.end));
    return _insertImplicitMultiplication(tokens);
  }

  bool _startsWithWord(String s, String word) {
    if (pos + word.length > s.length) return false;
    return s.substring(pos, pos + word.length).toLowerCase() == word;
  }

  List<Token> _insertImplicitMultiplication(List<Token> source) {
    final output = <Token>[];
    for (var i = 0; i < source.length; i++) {
      final current = source[i];
      output.add(current);
      if (current.type == TokenType.end || i == source.length - 1) continue;

      final next = source[i + 1];
      if (_canEndFactor(current) && _canStartFactor(next)) {
        output.add(const Token(TokenType.operator, '*'));
      }
    }
    return output;
  }

  bool _canEndFactor(Token token) {
    return token.type == TokenType.number ||
        token.type == TokenType.variable ||
        token.type == TokenType.rparen;
  }

  bool _canStartFactor(Token token) {
    return token.type == TokenType.number ||
        token.type == TokenType.variable ||
        token.type == TokenType.lparen ||
        token.type == TokenType.sqrt ||
        token.type == TokenType.abs;
  }

  void _skipWhitespace(String s) {
    while (pos < s.length && ' \t\n\r'.contains(s[pos])) {
      pos++;
    }
  }

  Token _readNumber(String s) {
    final start = pos;
    var dotCount = 0;
    while (pos < s.length && (_isDigit(s[pos]) || s[pos] == '.')) {
      if (s[pos] == '.') dotCount++;
      if (dotCount > 1) {
        throw TokenizerException('Invalid number near "${s.substring(start, pos + 1)}"');
      }
      pos++;
    }

    final numStr = s.substring(start, pos);
    final value = double.tryParse(numStr);
    if (value == null) {
      throw TokenizerException('Invalid number "$numStr"');
    }
    return Token(TokenType.number, value);
  }

  Token _readVariable(String s) {
    final start = pos;
    while (pos < s.length && (_isAlpha(s[pos]) || _isDigit(s[pos]))) {
      pos++;
    }
    return Token(TokenType.variable, s.substring(start, pos));
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
