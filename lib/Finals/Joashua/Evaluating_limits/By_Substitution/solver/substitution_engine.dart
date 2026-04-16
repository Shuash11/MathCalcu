import 'package:calculus_system/Finals/Joashua/Evaluating_limits/By_Substitution/solver/expressions_evaluator.dart';
import 'package:calculus_system/Finals/Joashua/Evaluating_limits/By_Substitution/solver/tokenizer.dart';

import 'smart_parser.dart';

/// Represents a limit problem
class LimitProblem {
  final String expression;
  final double approachValue;

  const LimitProblem({
    required this.expression,
    required this.approachValue,
  });

  @override
  String toString() => 'lim(x → $approachValue) $expression';
}

/// Result of solving a limit by substitution
class SubstitutionResult {
  /// Original input expression
  final String originalExpression;

  /// The value x is approaching
  final double approachValue;

  /// Normalized expression (with parentheses if auto-detected)
  final String normalizedExpression;

  /// Parsed AST of the expression
  final ASTNode? ast;

  /// Value of the full expression at the approach point
  final EvaluationResult fullEvaluation;

  /// Whether direct substitution succeeded
  final bool substitutionSucceeded;

  /// If the expression is a fraction, these hold numerator/denominator results
  final bool isFraction;
  final EvaluationResult? numeratorResult;
  final EvaluationResult? denominatorResult;

  /// Classification of the limit
  final LimitClassification classification;

  /// Final computed limit value
  final double? finalValue;

  /// Human-readable final value
  final String finalValueDescription;

  /// Whether this needs a different method (like factoring)
  final bool needsDifferentMethod;

  /// Suggested method if substitution fails
  final String? suggestedMethod;

  /// Error message if something went wrong
  final String? errorMessage;

  const SubstitutionResult({
    required this.originalExpression,
    required this.approachValue,
    required this.normalizedExpression,
    this.ast,
    required this.fullEvaluation,
    required this.substitutionSucceeded,
    required this.isFraction,
    this.numeratorResult,
    this.denominatorResult,
    required this.classification,
    this.finalValue,
    required this.finalValueDescription,
    required this.needsDifferentMethod,
    this.suggestedMethod,
    this.errorMessage,
  });

  bool get hasError => errorMessage != null;
}

/// Main engine for evaluating limits by direct substitution.
///
/// This solver:
/// 1. Parses the expression (with smart fraction detection)
/// 2. Attempts direct substitution
/// 3. Classifies the result
/// 4. Suggests alternative methods if needed
class SubstitutionEngine {
  /// Solve a limit problem using direct substitution
  SubstitutionResult solve(LimitProblem problem) {
    try {
      // Step 1: Tokenize
      final tokenizer = SmartTokenizer(problem.expression);
      final tokens = tokenizer.tokenize();

      // Step 2: Parse (with smart fraction detection)
      final parser = SmartParser(tokens);
      final ast = parser.parse();
      final normalizedExpr = ast.toString();

      // Step 3: Check if it's a fraction
      final fractionInfo = _extractFractionInfo(ast);

      // Step 4: Evaluate
      final fullResult =
          ExpressionEvaluator.safeEvaluate(ast, problem.approachValue);

      // Step 5: Handle fraction case specially for better diagnosis
      if (fractionInfo.isFraction) {
        final numResult = ExpressionEvaluator.safeEvaluate(
            fractionInfo.numerator!, problem.approachValue);
        final denResult = ExpressionEvaluator.safeEvaluate(
            fractionInfo.denominator!, problem.approachValue);

        // Check for 0/0 form
        if (numResult.value.abs() < 1e-9 && denResult.value.abs() < 1e-9) {
          return SubstitutionResult(
            originalExpression: problem.expression,
            approachValue: problem.approachValue,
            normalizedExpression: normalizedExpr,
            ast: ast,
            fullEvaluation: fullResult,
            substitutionSucceeded: false,
            isFraction: true,
            numeratorResult: numResult,
            denominatorResult: denResult,
            classification: LimitClassification.undefined,
            finalValue: null,
            finalValueDescription: 'indeterminate form (0/0)',
            needsDifferentMethod: true,
            suggestedMethod: 'Factoring - try canceling common factors',
            errorMessage: null,
          );
        }

        // Check for non-zero/0
        if (denResult.value.abs() < 1e-9 && numResult.value.abs() >= 1e-9) {
          final sign = numResult.value > 0 ? '+' : '-';
          final infinity =
              sign == '+' ? double.infinity : double.negativeInfinity;

          return SubstitutionResult(
            originalExpression: problem.expression,
            approachValue: problem.approachValue,
            normalizedExpression: normalizedExpr,
            ast: ast,
            fullEvaluation: fullResult,
            substitutionSucceeded: false,
            isFraction: true,
            numeratorResult: numResult,
            denominatorResult: denResult,
            classification: sign == '+'
                ? LimitClassification.positiveInfinity
                : LimitClassification.negativeInfinity,
            finalValue: infinity,
            finalValueDescription: sign == '+' ? '∞' : '-∞',
            needsDifferentMethod: false,
            suggestedMethod: null,
            errorMessage: null,
          );
        }

        // Normal fraction evaluation
        final value = numResult.value / denResult.value;
        return SubstitutionResult(
          originalExpression: problem.expression,
          approachValue: problem.approachValue,
          normalizedExpression: normalizedExpr,
          ast: ast,
          fullEvaluation:
              ExpressionEvaluator.safeEvaluate(ast, problem.approachValue),
          substitutionSucceeded: true,
          isFraction: true,
          numeratorResult: numResult,
          denominatorResult: denResult,
          classification: ExpressionEvaluator.classifyResult(value),
          finalValue: value,
          finalValueDescription: fullResult.description,
          needsDifferentMethod: false,
          suggestedMethod: null,
          errorMessage: null,
        );
      }

      // Non-fraction case
      if (fullResult.isDefined) {
        return SubstitutionResult(
          originalExpression: problem.expression,
          approachValue: problem.approachValue,
          normalizedExpression: normalizedExpr,
          ast: ast,
          fullEvaluation: fullResult,
          substitutionSucceeded: true,
          isFraction: false,
          classification: LimitClassification.finiteValue,
          finalValue: fullResult.value,
          finalValueDescription: fullResult.description,
          needsDifferentMethod: false,
          suggestedMethod: null,
          errorMessage: null,
        );
      }

      if (fullResult.isInfinity || fullResult.isNegativeInfinity) {
        return SubstitutionResult(
          originalExpression: problem.expression,
          approachValue: problem.approachValue,
          normalizedExpression: normalizedExpr,
          ast: ast,
          fullEvaluation: fullResult,
          substitutionSucceeded: false,
          isFraction: false,
          classification: fullResult.isInfinity
              ? LimitClassification.positiveInfinity
              : LimitClassification.negativeInfinity,
          finalValue: fullResult.value,
          finalValueDescription: fullResult.description,
          needsDifferentMethod: false,
          suggestedMethod: null,
          errorMessage: null,
        );
      }

      // Undefined result
      return SubstitutionResult(
        originalExpression: problem.expression,
        approachValue: problem.approachValue,
        normalizedExpression: normalizedExpr,
        ast: ast,
        fullEvaluation: fullResult,
        substitutionSucceeded: false,
        isFraction: false,
        classification: LimitClassification.undefined,
        finalValue: null,
        finalValueDescription: 'undefined',
        needsDifferentMethod: true,
        suggestedMethod: 'Check the expression for domain issues',
        errorMessage: null,
      );
    } on TokenizerException catch (e) {
      return SubstitutionResult(
        originalExpression: problem.expression,
        approachValue: problem.approachValue,
        normalizedExpression: problem.expression,
        fullEvaluation: const EvaluationResult(
          value: double.nan,
          isNaN: true,
          isInfinity: false,
          isNegativeInfinity: false,
          description: 'error',
        ),
        substitutionSucceeded: false,
        isFraction: false,
        classification: LimitClassification.undefined,
        finalValue: null,
        finalValueDescription: 'error',
        needsDifferentMethod: false,
        errorMessage: e.toString(),
      );
    } on ParserException catch (e) {
      return SubstitutionResult(
        originalExpression: problem.expression,
        approachValue: problem.approachValue,
        normalizedExpression: problem.expression,
        fullEvaluation: const EvaluationResult(
          value: double.nan,
          isNaN: true,
          isInfinity: false,
          isNegativeInfinity: false,
          description: 'error',
        ),
        substitutionSucceeded: false,
        isFraction: false,
        classification: LimitClassification.undefined,
        finalValue: null,
        finalValueDescription: 'error',
        needsDifferentMethod: false,
        errorMessage: e.toString(),
      );
    } catch (e) {
      return SubstitutionResult(
        originalExpression: problem.expression,
        approachValue: problem.approachValue,
        normalizedExpression: problem.expression,
        fullEvaluation: const EvaluationResult(
          value: double.nan,
          isNaN: true,
          isInfinity: false,
          isNegativeInfinity: false,
          description: 'error',
        ),
        substitutionSucceeded: false,
        isFraction: false,
        classification: LimitClassification.undefined,
        finalValue: null,
        finalValueDescription: 'error',
        needsDifferentMethod: false,
        errorMessage: 'Unexpected error: $e',
      );
    }
  }

  /// Extract numerator and denominator from a division AST
  _FractionInfo _extractFractionInfo(ASTNode node) {
    if (node is BinaryOpNode && node.operator == '/') {
      return _FractionInfo(
          isFraction: true, numerator: node.left, denominator: node.right);
    }
    return const _FractionInfo(isFraction: false);
  }
}

class _FractionInfo {
  final bool isFraction;
  final ASTNode? numerator;
  final ASTNode? denominator;

  const _FractionInfo(
      {required this.isFraction, this.numerator, this.denominator});
}
