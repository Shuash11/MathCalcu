import 'parser.dart';
import 'tokenizer.dart';

class ConjugateProblem {
  final String expression;
  final double approachValue;
  final String variable;

  const ConjugateProblem({
    required this.expression,
    required this.approachValue,
    this.variable = 'x',
  });

  @override
  String toString() => 'lim($variable -> $approachValue) $expression';
}

class ConjugateResult {
  final String originalExpression;
  final double approachValue;
  final String variable;

  final ASTNode? originalNumerator;
  final ASTNode? originalDenominator;

  final double numeratorAtPoint;
  final double denominatorAtPoint;
  final bool isIndeterminate;

  final ASTNode? conjugate;
  final ASTNode? rationalizedNumerator;
  final ASTNode? rationalizedDenominator;
  final bool rationalizedNumeratorNotDenominator;

  final double finalValue;
  final bool solved;
  final String? errorMessage;

  const ConjugateResult({
    required this.originalExpression,
    required this.approachValue,
    required this.variable,
    this.originalNumerator,
    this.originalDenominator,
    required this.numeratorAtPoint,
    required this.denominatorAtPoint,
    required this.isIndeterminate,
    this.conjugate,
    this.rationalizedNumerator,
    this.rationalizedDenominator,
    this.rationalizedNumeratorNotDenominator = false,
    required this.finalValue,
    required this.solved,
    this.errorMessage,
  });

  String get problemNotation =>
      'lim($variable -> $approachValue) $originalExpression';

  String get resultString {
    if (!solved) return errorMessage ?? 'Cannot solve';
    if (finalValue.isNaN) return 'undefined';
    if (finalValue.isInfinite) {
      return finalValue > 0 ? 'infinity' : '-infinity';
    }
    return _formatValue(finalValue);
  }

  static String _formatValue(double n) {
    const tolerance = 1e-9;
    if ((n - n.round()).abs() < tolerance) {
      return n.round().toString();
    }

    for (int denom = 2; denom <= 64; denom++) {
      final numer = n * denom;
      if ((numer - numer.round()).abs() < tolerance) {
        final intNumer = numer.round();
        if (intNumer == 0) return '0';
        final gcdVal = _gcd(intNumer.abs(), denom);
        final simpleNum = intNumer ~/ gcdVal;
        final simpleDen = denom ~/ gcdVal;
        if (simpleDen == 1) return simpleNum.toString();
        if (simpleDen == -1) return (-simpleNum).toString();
        if (simpleNum < 0 && simpleDen < 0) {
          return '${(-simpleNum)}/${(-simpleDen)}';
        }
        return '$simpleNum/$simpleDen';
      }
    }

    return n
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  static int _gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }
}

class ConjugateSolverEngine {
  ConjugateResult solve(ConjugateProblem problem) {
    try {
      final (numerator, denominator) =
          _parseExpressionAsFraction(problem.expression.trim());

      final numAtPoint =
          numerator.evaluate(problem.approachValue, variable: problem.variable);
      final denAtPoint = denominator.evaluate(
        problem.approachValue,
        variable: problem.variable,
      );

      final isIndeterminate =
          numAtPoint.abs() < 1e-9 && denAtPoint.abs() < 1e-9;

      if (!isIndeterminate) {
        final value = _safeDivide(numAtPoint, denAtPoint);
        return ConjugateResult(
          originalExpression: problem.expression,
          approachValue: problem.approachValue,
          variable: problem.variable,
          originalNumerator: numerator,
          originalDenominator: denominator,
          numeratorAtPoint: numAtPoint,
          denominatorAtPoint: denAtPoint,
          isIndeterminate: false,
          finalValue: value,
          solved: _isUsableNumber(value) || value.isInfinite,
        );
      }

      final numHasSqrt = _containsSqrt(numerator);
      final denHasSqrt = _containsSqrt(denominator);

      ASTNode? targetForConjugate;
      var rationalizeNum = false;

      if (numHasSqrt && !denHasSqrt) {
        targetForConjugate = numerator;
        rationalizeNum = true;
      } else if (denHasSqrt) {
        targetForConjugate = denominator;
      } else {
        return _failure(
          problem,
          numerator,
          denominator,
          numAtPoint,
          denAtPoint,
          true,
          'No radicals found. Try using Factoring method instead.',
        );
      }

      final conjugate = _findConjugate(targetForConjugate);
      if (conjugate == null) {
        return _failure(
          problem,
          numerator,
          denominator,
          numAtPoint,
          denAtPoint,
          true,
          'Could not find a conjugate to rationalize.',
        );
      }

      final ASTNode rationalizedNum;
      final ASTNode rationalizedDen;
      if (rationalizeNum) {
        rationalizedNum = _differenceOfSquares(targetForConjugate).simplify();
        rationalizedDen = BinaryOpNode('*', denominator, conjugate).simplify();
      } else {
        rationalizedNum = BinaryOpNode('*', numerator, conjugate).simplify();
        rationalizedDen = _differenceOfSquares(targetForConjugate).simplify();
      }

      final finalValue = _evaluateAfterRationalizing(
        rationalizedNum,
        rationalizedDen,
        problem.approachValue,
        problem.variable,
      );

      if (!_isUsableNumber(finalValue)) {
        return ConjugateResult(
          originalExpression: problem.expression,
          approachValue: problem.approachValue,
          variable: problem.variable,
          originalNumerator: numerator,
          originalDenominator: denominator,
          numeratorAtPoint: numAtPoint,
          denominatorAtPoint: denAtPoint,
          isIndeterminate: true,
          conjugate: conjugate,
          rationalizedNumerator: rationalizedNum,
          rationalizedDenominator: rationalizedDen,
          rationalizedNumeratorNotDenominator: rationalizeNum,
          finalValue: double.nan,
          solved: false,
          errorMessage: 'Still indeterminate after rationalization.',
        );
      }

      return ConjugateResult(
        originalExpression: problem.expression,
        approachValue: problem.approachValue,
        variable: problem.variable,
        originalNumerator: numerator,
        originalDenominator: denominator,
        numeratorAtPoint: numAtPoint,
        denominatorAtPoint: denAtPoint,
        isIndeterminate: true,
        conjugate: conjugate,
        rationalizedNumerator: rationalizedNum,
        rationalizedDenominator: rationalizedDen,
        rationalizedNumeratorNotDenominator: rationalizeNum,
        finalValue: finalValue,
        solved: true,
      );
    } on TokenizerException catch (e) {
      return _parseError(problem, e.toString());
    } on ParserException catch (e) {
      return _parseError(problem, e.toString());
    } catch (e) {
      return _parseError(problem, 'Error: $e');
    }
  }

  ConjugateResult _parseError(ConjugateProblem problem, String message) {
    return ConjugateResult(
      originalExpression: problem.expression,
      approachValue: problem.approachValue,
      variable: problem.variable,
      numeratorAtPoint: 0,
      denominatorAtPoint: 0,
      isIndeterminate: false,
      finalValue: double.nan,
      solved: false,
      errorMessage: message,
    );
  }

  ConjugateResult _failure(
    ConjugateProblem problem,
    ASTNode numerator,
    ASTNode denominator,
    double numAtPoint,
    double denAtPoint,
    bool isIndeterminate,
    String message,
  ) {
    return ConjugateResult(
      originalExpression: problem.expression,
      approachValue: problem.approachValue,
      variable: problem.variable,
      originalNumerator: numerator,
      originalDenominator: denominator,
      numeratorAtPoint: numAtPoint,
      denominatorAtPoint: denAtPoint,
      isIndeterminate: isIndeterminate,
      finalValue: double.nan,
      solved: false,
      errorMessage: message,
    );
  }

  (ASTNode, ASTNode) _parseExpressionAsFraction(String expression) {
    final splitIndex = _findMainFractionSlash(expression);
    if (splitIndex != -1) {
      final numerator = expression.substring(0, splitIndex).trim();
      final denominator = expression.substring(splitIndex + 1).trim();
      if (numerator.isNotEmpty && denominator.isNotEmpty) {
        return (_parse(numerator), _parse(denominator));
      }
    }

    final ast = _parse(expression);
    if (ast is BinaryOpNode && ast.operator == '/') {
      return (ast.left, ast.right);
    }
    return (ast, NumberNode(1));
  }

  ASTNode _parse(String expression) {
    final tokenizer = Tokenizer(_stripOuterParentheses(expression));
    final tokens = tokenizer.tokenize();
    final parser = Parser(tokens);
    return parser.parse().simplify();
  }

  int _findMainFractionSlash(String expression) {
    var depth = 0;
    var slashIndex = -1;
    for (var i = 0; i < expression.length; i++) {
      final ch = expression[i];
      if (ch == '(') {
        depth++;
      } else if (ch == ')') {
        depth--;
      } else if (ch == '/' && depth == 0) {
        slashIndex = i;
      }
    }
    return slashIndex;
  }

  String _stripOuterParentheses(String expression) {
    var result = expression.trim();
    while (result.startsWith('(') &&
        result.endsWith(')') &&
        _outerParenthesesWrapAll(result)) {
      result = result.substring(1, result.length - 1).trim();
    }
    return result;
  }

  bool _outerParenthesesWrapAll(String expression) {
    var depth = 0;
    for (var i = 0; i < expression.length; i++) {
      final ch = expression[i];
      if (ch == '(') depth++;
      if (ch == ')') depth--;
      if (depth == 0 && i < expression.length - 1) return false;
      if (depth < 0) return false;
    }
    return depth == 0;
  }

  bool _containsSqrt(ASTNode node) {
    if (node is SqrtNode) return true;
    if (node is BinaryOpNode) {
      return _containsSqrt(node.left) || _containsSqrt(node.right);
    }
    if (node is UnaryMinusNode) return _containsSqrt(node.operand);
    if (node is AbsNode) return _containsSqrt(node.argument);
    return false;
  }

  ASTNode? _findConjugate(ASTNode node) {
    if (node is BinaryOpNode &&
        (node.operator == '+' || node.operator == '-')) {
      final conjugateOp = node.operator == '+' ? '-' : '+';
      return BinaryOpNode(conjugateOp, node.left, node.right).simplify();
    }
    if (node is UnaryMinusNode) {
      final inner = _findConjugate(node.operand);
      return inner == null ? null : UnaryMinusNode(inner).simplify();
    }
    return null;
  }

  ASTNode _differenceOfSquares(ASTNode node) {
    if (node is BinaryOpNode &&
        (node.operator == '+' || node.operator == '-')) {
      return BinaryOpNode(
        '-',
        BinaryOpNode('^', node.left, NumberNode(2)),
        BinaryOpNode('^', node.right, NumberNode(2)),
      );
    }
    return BinaryOpNode('*', node, node);
  }

  double _evaluateAfterRationalizing(
    ASTNode numerator,
    ASTNode denominator,
    double approach,
    String variable,
  ) {
    final direct = _safeDivide(
      numerator.evaluate(approach, variable: variable),
      denominator.evaluate(approach, variable: variable),
    );
    if (_isUsableNumber(direct)) return direct;
    return _estimateLimit(numerator, denominator, approach, variable);
  }

  double _estimateLimit(
    ASTNode numerator,
    ASTNode denominator,
    double approach,
    String variable,
  ) {
    final candidates = <double>[];
    final scale = approach.abs() > 1 ? approach.abs() : 1.0;

    for (final hFactor in const [1e-3, 5e-4, 1e-4, 5e-5, 1e-5, 5e-6, 1e-6]) {
      final h = hFactor * scale;
      final left = _safeValue(numerator, denominator, approach - h, variable);
      final right = _safeValue(numerator, denominator, approach + h, variable);

      if (_isUsableNumber(left) && _isUsableNumber(right)) {
        final tolerance = 1e-4 * (1 + left.abs() + right.abs());
        if ((left - right).abs() <= tolerance) {
          candidates.add((left + right) / 2);
        }
      } else if (_isUsableNumber(left)) {
        candidates.add(left);
      } else if (_isUsableNumber(right)) {
        candidates.add(right);
      }
    }

    if (candidates.isEmpty) return double.nan;
    return candidates.last;
  }

  double _safeValue(
    ASTNode numerator,
    ASTNode denominator,
    double x,
    String variable,
  ) {
    return _safeDivide(
      numerator.evaluate(x, variable: variable),
      denominator.evaluate(x, variable: variable),
    );
  }

  double _safeDivide(double numerator, double denominator) {
    if (numerator.isNaN || denominator.isNaN) return double.nan;
    if (denominator.abs() < 1e-12) {
      if (numerator.abs() < 1e-12) return double.nan;
      return numerator > 0 ? double.infinity : double.negativeInfinity;
    }
    return numerator / denominator;
  }

  bool _isUsableNumber(double value) {
    return !value.isNaN && !value.isInfinite;
  }
}
