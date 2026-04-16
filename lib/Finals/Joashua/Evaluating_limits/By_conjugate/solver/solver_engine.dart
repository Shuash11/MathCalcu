import 'tokenizer.dart';
import 'parser.dart';

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
  String toString() => 'lim($variable → $approachValue) $expression';
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
      'lim($variable → $approachValue) $originalExpression';

  String get resultString {
    if (!solved) return errorMessage ?? 'Cannot solve';
    if (finalValue.isNaN) return 'undefined';
    if (finalValue.isInfinite) return finalValue > 0 ? '∞' : '-∞';
    if (finalValue == finalValue.toInt()) return finalValue.toInt().toString();
    return finalValue
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
}

class ConjugateSolverEngine {
  ConjugateResult solve(ConjugateProblem problem) {
    try {
      final processedExpr = problem.expression.trim();

      final tokenizer = Tokenizer(processedExpr);
      final tokens = tokenizer.tokenize();

      final parser = Parser(tokens);
      final ast = parser.parse();

      final (numerator, denominator) = _extractRationalFunction(ast);

      final numAtPoint =
          numerator.evaluate(problem.approachValue, variable: problem.variable);
      final denAtPoint = denominator.evaluate(problem.approachValue,
          variable: problem.variable);

      final isIndeterminate =
          numAtPoint.abs() < 1e-9 && denAtPoint.abs() < 1e-9;

      if (!isIndeterminate) {
        final value = denAtPoint.abs() < 1e-12
            ? (numAtPoint > 0 ? double.infinity : double.negativeInfinity)
            : numAtPoint / denAtPoint;

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
          solved: true,
        );
      }

      final numHasSqrt = _containsSqrt(numerator);
      final denHasSqrt = _containsSqrt(denominator);

      ASTNode? targetForConjugate;
      bool rationalizeNum = false;

      if (numHasSqrt && !denHasSqrt) {
        targetForConjugate = numerator;
        rationalizeNum = true;
      } else if (denHasSqrt && !numHasSqrt) {
        targetForConjugate = denominator;
        rationalizeNum = false;
      } else if (numHasSqrt && denHasSqrt) {
        targetForConjugate = denominator;
        rationalizeNum = false;
      } else {
        return ConjugateResult(
          originalExpression: problem.expression,
          approachValue: problem.approachValue,
          variable: problem.variable,
          originalNumerator: numerator,
          originalDenominator: denominator,
          numeratorAtPoint: numAtPoint,
          denominatorAtPoint: denAtPoint,
          isIndeterminate: true,
          finalValue: double.nan,
          solved: false,
          errorMessage:
              'No radicals found. Try using Factoring method instead.',
        );
      }

      final conjugate = _findConjugate(targetForConjugate);

      if (conjugate == null) {
        return ConjugateResult(
          originalExpression: problem.expression,
          approachValue: problem.approachValue,
          variable: problem.variable,
          originalNumerator: numerator,
          originalDenominator: denominator,
          numeratorAtPoint: numAtPoint,
          denominatorAtPoint: denAtPoint,
          isIndeterminate: true,
          finalValue: double.nan,
          solved: false,
          errorMessage: 'Could not find a conjugate to rationalize.',
        );
      }

      ASTNode rationalizedNum;
      ASTNode rationalizedDen;

      if (rationalizeNum) {
        rationalizedNum = BinaryOpNode('*', numerator, conjugate);
        rationalizedDen = denominator;
      } else {
        rationalizedNum = numerator;
        rationalizedDen = BinaryOpNode('*', denominator, conjugate);
      }

      final newNumAtPoint = rationalizedNum.evaluate(problem.approachValue,
          variable: problem.variable);
      final newDenAtPoint = rationalizedDen.evaluate(problem.approachValue,
          variable: problem.variable);

      if (newDenAtPoint.abs() < 1e-12) {
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
        finalValue: newNumAtPoint / newDenAtPoint,
        solved: true,
      );
    } on TokenizerException catch (e) {
      return ConjugateResult(
        originalExpression: problem.expression,
        approachValue: problem.approachValue,
        variable: problem.variable,
        numeratorAtPoint: 0,
        denominatorAtPoint: 0,
        isIndeterminate: false,
        finalValue: double.nan,
        solved: false,
        errorMessage: e.toString(),
      );
    } on ParserException catch (e) {
      return ConjugateResult(
        originalExpression: problem.expression,
        approachValue: problem.approachValue,
        variable: problem.variable,
        numeratorAtPoint: 0,
        denominatorAtPoint: 0,
        isIndeterminate: false,
        finalValue: double.nan,
        solved: false,
        errorMessage: e.toString(),
      );
    } catch (e) {
      return ConjugateResult(
        originalExpression: problem.expression,
        approachValue: problem.approachValue,
        variable: problem.variable,
        numeratorAtPoint: 0,
        denominatorAtPoint: 0,
        isIndeterminate: false,
        finalValue: double.nan,
        solved: false,
        errorMessage: 'Error: $e',
      );
    }
  }

  (ASTNode, ASTNode) _extractRationalFunction(ASTNode node) {
    if (node is BinaryOpNode && node.operator == '/') {
      return (node.left, node.right);
    }
    return (node, NumberNode(1));
  }

  bool _containsSqrt(ASTNode node) {
    if (node is SqrtNode) return true;
    if (node is BinaryOpNode) {
      return _containsSqrt(node.left) || _containsSqrt(node.right);
    }
    if (node is UnaryMinusNode) return _containsSqrt(node.operand);
    return false;
  }

  ASTNode? _findConjugate(ASTNode node) {
    if (node is BinaryOpNode &&
        (node.operator == '+' || node.operator == '-')) {
      final conjugateOp = node.operator == '+' ? '-' : '+';
      return BinaryOpNode(conjugateOp, node.left, node.right);
    }
    if (node is SqrtNode) {
      return SqrtNode(node.argument);
    }
    return null;
  }
}
