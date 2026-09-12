// -------------------------------------------------------------
// INPUT VALIDATION
// Single source for user-readable inline validation messages.
// Offline-first: pure Dart, no network. Used by all solver
// screens so empty-submit and bad-format errors read the same.
// -------------------------------------------------------------

class FieldValidators {
  FieldValidators._();

  /// Matches a plain number: e.g. 3, -2.5
  static final RegExp numeric = RegExp(r'^-?\d+(\.\d+)?$');

  /// Matches "(x1,y1), (x2,y2)" free-text pair — see distance screen.
  static final RegExp pointPair = RegExp(
    r'^\(\s*-?\d+(\.\d+)?\s*,\s*-?\d+(\.\d+)?\s*\)\s*,\s*\(\s*-?\d+(\.\d+)?\s*,\s*-?\d+(\.\d+)?\s*\)$',
  );

  static const String emptyDefault =
      'Enter an expression — e.g. x^2+3*x';

  /// Returns an error string when [value] is empty, else null.
  static String? notEmpty(String value, {String? example}) {
    if (value.trim().isEmpty) {
      return example == null
          ? 'Enter a value to solve.'
          : 'Enter a value to solve — e.g. $example';
    }
    return null;
  }

  /// Returns an error string when [value] is not a plain number.
  static String? number(String value, String label) {
    if (value.trim().isEmpty) return '$label is required — e.g. 3';
    if (!numeric.hasMatch(value.trim())) {
      return '$label must be a number — e.g. 3 or -2.5';
    }
    return null;
  }

  /// Returns an error string when [value] is not a math expression
  /// (letters, digits, operators, parens, spaces, ^ . ,).
  static String? expression(String value, {String example = 'x^2+3*x'}) {
    if (value.trim().isEmpty) {
      return 'Enter a value to solve — e.g. $example';
    }
    final ok = RegExp(r'^[0-9a-zA-Z+\-*/^().,\s]+$').hasMatch(value);
    if (!ok) return 'Could not parse — check ^ and parentheses.';
    return null;
  }
}

// -------------------------------------------------------------
// INPUT HINTS
// Gold-standard hint/helper copy per input family (§B.2).
// -------------------------------------------------------------

class InputHints {
  InputHints._();

  static const String expressionHint = 'e.g. x² + 3x + ln(x)';
  static const String expressionHelper =
      'Use x, ^, sin/cos/ln/sqrt — e.g. x^2+3*x';

  static const String calculatorHint = 'e.g. (2+3)*4 - sqrt(16)';
  static const String calculatorHelper = 'Supports + - * / ^ ( ) sqrt() %';

  static const String distanceHelper2D =
      'Format: (x1,y1), (x2,y2) — numbers only';
  static const String coordinateHelper = 'Numbers only — e.g. 1, -2.5';

  static const String slopeHelper = 'Enter slope m or two points (x1,y1)';
  static const String limitValueHint = 'e.g. 2';
  static const String limitValueHelper = 'Number or inf / -inf';
}
