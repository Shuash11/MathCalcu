// =====================================================
// SHARED EXPRESSION -> LATEX CONVERTER (derivatives)
//
// Single source of truth for the plain-expression -> KaTeX-subset
// conversion used by the derivatives step surfaces. Previously this
// logic lived as two private `_toLatex` methods (plus their private
// helpers) duplicated and subtly drifting between
// derivatives_steptile.dart and derivatives_answer_card.dart.
//
// This implementation is the SAFE SUPERSET of the two former copies:
//   * keeps spaces (steptile behaviour). Spaces are ignored in math
//     mode, and NOT stripping them avoids mangling any LaTeX fragment
//     that is already present.
//   * still normalises whitespace around `^` so `x ^ 2` is handled.
//   * adds the transforms that were only in the steptile copy
//     (`d/dx`, `f'(x)`, square brackets, `\ln`) and the only transform
//     that was only in the answer-card copy (`+` spacing). All of these
//     are harmless in math mode for either usage.
// =====================================================

/// Convert a student-facing plain expression into LaTeX understood by the
/// flutter_math_fork renderer (KaTeX subset).
String exprToLatex(String expr) {
  if (expr.isEmpty) return '';

  String result = expr;

  // 0. Handle d/dx notation.
  result = result.replaceAllMapped(
      RegExp(r'd/d([a-zA-Z])'), (m) => '\\frac{d}{d${m[1]}} ');

  // 1. Keep f'(x) notation intact (normalising pass; parity with the
  //    former steptile copy).
  result = result.replaceAllMapped(
      RegExp(r"([a-zA-Z])'\((\w+)\)"), (m) => "${m[1]}'(${m[2]})");

  // 2. Wrap square brackets so they scale with their contents.
  if (result.contains('[') && !result.contains(r'\left[')) {
    result = result.replaceAll('[', '\\left[ ').replaceAll(']', ' \\right]');
  }

  result = result.replaceAll('*', '##MUL##');

  // 3. Normalise whitespace around carets (spaces are ignored in math
  //    mode) so `x ^ 2` behaves like `x^2`.
  result = result.replaceAll(RegExp(r' *\^ *'), '^');

  // 4. Exponent handling.
  result = result.replaceAllMapped(
      RegExp(r'(\w)\^(-?\d+)'), (m) => '${m[1]}^{${m[2]}}');
  result = result.replaceAllMapped(
      RegExp(r'(\w)\)\^(-?\d+)'), (m) => '${m[1]}^{${m[2]}}');
  // Clean up malformed patterns like ( ^-1 or ^ -1.
  result = result.replaceAllMapped(
      RegExp(r'\(\s*\^\s*(-?\d+)\)'), (m) => '^{${m[1]}}');
  result = result.replaceAll('^ -', '^{-');
  // Remove redundant parentheses in exponents (e.g. x^(-1) -> x^{-1}).
  result = result.replaceAllMapped(
      RegExp(r'\^(\()(-?\d+)(\))'), (m) => '^{${m[2]}}');

  result = _convertFractions(result);
  result = _convertMultiplication(result);

  // Space out the plus sign (harmless: spaces are ignored in math mode).
  result = result.replaceAll('+', ' + ');

  // Use a negative lookbehind to exclude `-` immediately after `^`.
  result = result.replaceAllMapped(
      RegExp(r'(?<![\^])([a-zA-Z0-9\)])-([a-zA-Z0-9\(])'),
      (m) => '${m[1]} - ${m[2]}');

  result = result
      .replaceAll('sqrt(', r'\sqrt{')
      .replaceAllMapped(RegExp(r'sqrt([a-zA-Z])'), (m) => '\\sqrt{${m[1]}}')
      .replaceAllMapped(RegExp(r'sqrt(\d+)'), (m) => '\\sqrt{${m[1]}}')
      .replaceAll('sin(', r'\sin{')
      .replaceAll('cos(', r'\cos{')
      .replaceAll('tan(', r'\tan{')
      .replaceAll('ln(', r'\ln{')
      .replaceAll('exp(', r'\exp{');

  return result;
}

String _convertMultiplication(String expr) {
  String result = expr;

  // 1. Digit * Variable -> digitvariable (e.g. 2*x -> 2x).
  result = result.replaceAllMapped(
      RegExp(r'([0-9])\s*##MUL##\s*([a-zA-Z])'), (m) => '${m[1]}${m[2]}');

  // 2. Digit * ( -> digit(.
  result = result.replaceAllMapped(
      RegExp(r'([0-9])\s*##MUL##\s*\('), (m) => '${m[1]}(');

  // 3. ) * Digit -> )digit.
  result = result.replaceAllMapped(
      RegExp(r'\)\s*##MUL##\s*([0-9])'), (m) => ')${m[1]}');

  // 4. Variable * Variable -> variablevariable.
  result = result.replaceAllMapped(
      RegExp(r'([a-zA-Z])\s*##MUL##\s*([a-zA-Z])'), (m) => '${m[1]}${m[2]}');

  // 5. Variable * ( -> variable(.
  result = result.replaceAllMapped(
      RegExp(r'([a-zA-Z])\s*##MUL##\s*\('), (m) => '${m[1]}(');

  // 6. ) * Variable -> )variable.
  result = result.replaceAllMapped(
      RegExp(r'\)\s*##MUL##\s*([a-zA-Z])'), (m) => ')${m[1]}');

  // 7. ) * ( -> )(
  result = result.replaceAllMapped(RegExp(r'\)\s*##MUL##\s*\('), (m) => ')(');

  // 8. All remaining ##MUL## become \cdot.
  result = result.replaceAll('##MUL##', r'\cdot ');

  return result;
}

String _convertFractions(String expr) {
  final buffer = StringBuffer();
  int i = 0;
  int lastWritePos = 0;

  while (i < expr.length) {
    if (expr[i] == '/') {
      int numStart = _findNumeratorStart(expr, i);
      int denEnd = _findDenominatorEnd(expr, i);

      String num = expr.substring(numStart, i).trim();
      String den = expr.substring(i + 1, denEnd).trim();

      if (num.isEmpty || den.isEmpty) {
        buffer.write(expr[i]);
        i++;
        continue;
      }

      num = _stripOuterParens(num);
      den = _stripOuterParens(den);

      String frac = '\\frac{$num}{$den}';

      buffer.write(expr.substring(lastWritePos, numStart));
      buffer.write(frac);
      lastWritePos = denEnd;
      i = denEnd;
    } else {
      i++;
    }
  }

  buffer.write(expr.substring(lastWritePos));
  return buffer.toString();
}

String _stripOuterParens(String s) {
  if (s.isEmpty) return s;
  if (s.startsWith('(') && s.endsWith(')')) {
    final inner = s.substring(1, s.length - 1);
    if (_isBalancedParens(s) || _isBalancedParens(inner)) {
      return inner.trim();
    }
  }
  return s;
}

bool _isBalancedParens(String s) {
  int depth = 0;
  for (int i = 0; i < s.length; i++) {
    if (s[i] == '(') depth++;
    if (s[i] == ')') {
      depth--;
      if (depth < 0) return false;
    }
  }
  return depth == 0;
}

int _findNumeratorStart(String s, int slashPos) {
  int depth = 0;
  int i = slashPos - 1;
  while (i >= 0) {
    if (s[i] == ' ') {
      i--;
      continue;
    }
    if (s[i] == ')') {
      int match = _findMatchingOpen(s, i);
      if (match == -1) {
        i--;
        continue;
      }
      depth++;
      i = match - 1;
    } else if (s[i] == '(') {
      if (depth == 0) return i;
      depth--;
      i--;
    } else {
      if (depth == 0) {
        if (s[i] == '+' || s[i] == '-' || s[i] == '*' || s[i] == '#') {
          return i + 1;
        }
        if (i == 0) {
          return 0;
        }
      }
      i--;
    }
  }
  return 0;
}

int _findDenominatorEnd(String s, int slashPos) {
  int depth = 0;
  int i = slashPos + 1;
  while (i < s.length) {
    if (s[i] == ' ') {
      i++;
      continue;
    }
    if (s[i] == '(') {
      int match = _findMatchingClose(s, i);
      if (match == -1) {
        i++;
        continue;
      }
      depth++;
      i = match + 1;
    } else if (s[i] == ')') {
      if (depth == 0) return i;
      depth--;
      i++;
    } else {
      if (depth == 0 &&
          (s[i] == '+' ||
              s[i] == '-' ||
              s[i] == '*' ||
              s[i] == '#' ||
              s[i] == '^' ||
              s[i] == ')')) {
        return i;
      }
      i++;
    }
  }
  return s.length;
}

int _findMatchingOpen(String s, int closePos) {
  int depth = 1;
  for (int i = closePos - 1; i >= 0; i--) {
    if (s[i] == ')') depth++;
    if (s[i] == '(') {
      depth--;
      if (depth == 0) return i;
    }
  }
  return -1;
}

int _findMatchingClose(String s, int openPos) {
  int depth = 1;
  for (int i = openPos + 1; i < s.length; i++) {
    if (s[i] == '(') depth++;
    if (s[i] == ')') {
      depth--;
      if (depth == 0) return i;
    }
  }
  return -1;
}
