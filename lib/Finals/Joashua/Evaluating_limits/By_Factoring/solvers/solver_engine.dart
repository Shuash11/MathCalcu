import 'tokenizer.dart';
import 'parser.dart';
import 'polynomial.dart';
import 'factorizer.dart';

/// Represents a limit problem to solve
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

/// Result of solving a limit problem by factoring
class SolutionResult {
  /// Original expression string
  final String originalExpression;

  /// The value x is approaching
  final double approachValue;

  /// Numerator as a polynomial
  final Polynomial originalNumerator;

  /// Denominator as a polynomial
  final Polynomial originalDenominator;

  /// Value of numerator at the approach point
  final double numAtPoint;

  /// Value of denominator at the approach point
  final double denAtPoint;

  /// Whether direct substitution gives 0/0
  final bool isIndeterminate;

  /// Factored form of numerator
  final FactoredForm factoredNumerator;

  /// Factored form of denominator
  final FactoredForm factoredDenominator;

  /// Common factors that were canceled
  final List<LinearFactor> commonFactors;

  /// Simplified numerator after cancellation
  final Polynomial simplifiedNumerator;

  /// Simplified denominator after cancellation
  final Polynomial simplifiedDenominator;

  /// Final computed limit value
  final double finalValue;

  /// Whether the limit was successfully computed
  final bool solved;

  /// Error message if solving failed
  final String? errorMessage;

  const SolutionResult({
    required this.originalExpression,
    required this.approachValue,
    required this.originalNumerator,
    required this.originalDenominator,
    required this.numAtPoint,
    required this.denAtPoint,
    required this.isIndeterminate,
    required this.factoredNumerator,
    required this.factoredDenominator,
    required this.commonFactors,
    required this.simplifiedNumerator,
    required this.simplifiedDenominator,
    required this.finalValue,
    required this.solved,
    this.errorMessage,
  });
}

/// Main solver engine for evaluating limits by factoring.
///
/// This class orchestrates the entire solving process:
/// 1. Tokenize the input expression
/// 2. Parse into an AST
/// 3. Extract numerator and denominator polynomials
/// 4. Attempt direct substitution
/// 5. If indeterminate (0/0), factor and cancel
/// 6. Evaluate the simplified expression
class LimitSolverEngine {
  final PolynomialFactorizer _factorizer = PolynomialFactorizer();

  /// Solve a limit problem using factoring method
  SolutionResult solve(LimitProblem problem) {
    try {
      String processedExpression = problem.expression.trim();
      
      // ✨ SMART PRE-PARSING
      // If the expression has exactly one '/' and NO parentheses, 
      // we assume the user meant (everything_before) / (everything_after).
      if (processedExpression.contains('/') && 
          !processedExpression.contains('(') && 
          !processedExpression.contains(')')) {
        final parts = processedExpression.split('/');
        if (parts.length == 2) {
          processedExpression = '(${parts[0].trim()}) / (${parts[1].trim()})';
        }
      }

      // Step 1: Tokenize
      final tokenizer = Tokenizer(processedExpression);
      final tokens = tokenizer.tokenize();

      // Step 2: Parse
      final parser = Parser(tokens);
      final ast = parser.parse();

      // Step 3: Extract rational function
      final (numerator, denominator) = _extractRationalFunction(ast);

      // Step 4: Direct substitution
      final numAtPoint = numerator.evaluate(problem.approachValue);
      final denAtPoint = denominator.evaluate(problem.approachValue);

      // Check for indeterminate form
      final isIndeterminate =
          numAtPoint.abs() < 1e-9 && denAtPoint.abs() < 1e-9;

      if (!isIndeterminate) {
        // Direct substitution works
        final value = denAtPoint.abs() < 1e-12
            ? (numAtPoint > 0 ? double.infinity : double.negativeInfinity)
            : numAtPoint / denAtPoint;

        return SolutionResult(
          originalExpression: problem.expression,
          approachValue: problem.approachValue,
          originalNumerator: numerator,
          originalDenominator: denominator,
          numAtPoint: numAtPoint,
          denAtPoint: denAtPoint,
          isIndeterminate: false,
          factoredNumerator: const FactoredForm(1, []),
          factoredDenominator: const FactoredForm(1, []),
          commonFactors: [],
          simplifiedNumerator: numerator,
          simplifiedDenominator: denominator,
          finalValue: value,
          solved: true,
        );
      }

      // Step 5: Factor numerator and denominator
      final factoredNum = _factorizer.factor(numerator);
      final factoredDen = _factorizer.factor(denominator);

      // Step 6: Find common factors
      final commonFactors = _findCommonFactors(
        factoredNum.linearFactors,
        factoredDen.linearFactors,
      );

      if (commonFactors.isEmpty) {
        // Cannot solve by factoring alone
        return SolutionResult(
          originalExpression: problem.expression,
          approachValue: problem.approachValue,
          originalNumerator: numerator,
          originalDenominator: denominator,
          numAtPoint: numAtPoint,
          denAtPoint: denAtPoint,
          isIndeterminate: true,
          factoredNumerator: factoredNum,
          factoredDenominator: factoredDen,
          commonFactors: [],
          simplifiedNumerator: numerator,
          simplifiedDenominator: denominator,
          finalValue: double.nan,
          solved: false,
          errorMessage:
              'No common factors found. This limit may require a different method.',
        );
      }

      // Step 7: Cancel common factors
      var simpNum = factoredNum.toPolynomial();
      var simpDen = factoredDen.toPolynomial();

      for (var factor in commonFactors) {
        simpNum = _divideByLinearFactor(simpNum, factor);
        simpDen = _divideByLinearFactor(simpDen, factor);
      }

      // Step 8: Evaluate simplified expression
      final finalNum = simpNum.evaluate(problem.approachValue);
      final finalDen = simpDen.evaluate(problem.approachValue);

      if (finalDen.abs() < 1e-12) {
        return SolutionResult(
          originalExpression: problem.expression,
          approachValue: problem.approachValue,
          originalNumerator: numerator,
          originalDenominator: denominator,
          numAtPoint: numAtPoint,
          denAtPoint: denAtPoint,
          isIndeterminate: true,
          factoredNumerator: factoredNum,
          factoredDenominator: factoredDen,
          commonFactors: commonFactors,
          simplifiedNumerator: simpNum,
          simplifiedDenominator: simpDen,
          finalValue: double.nan,
          solved: false,
          errorMessage: 'Denominator still zero after cancellation.',
        );
      }

      return SolutionResult(
        originalExpression: problem.expression,
        approachValue: problem.approachValue,
        originalNumerator: numerator,
        originalDenominator: denominator,
        numAtPoint: numAtPoint,
        denAtPoint: denAtPoint,
        isIndeterminate: true,
        factoredNumerator: factoredNum,
        factoredDenominator: factoredDen,
        commonFactors: commonFactors,
        simplifiedNumerator: simpNum,
        simplifiedDenominator: simpDen,
        finalValue: finalNum / finalDen,
        solved: true,
      );
    } on TokenizerException catch (e) {
      return SolutionResult(
        originalExpression: problem.expression,
        approachValue: problem.approachValue,
        originalNumerator: Polynomial(),
        originalDenominator: Polynomial(),
        numAtPoint: 0,
        denAtPoint: 0,
        isIndeterminate: false,
        factoredNumerator: const FactoredForm(1, []),
        factoredDenominator: const FactoredForm(1, []),
        commonFactors: [],
        simplifiedNumerator: Polynomial(),
        simplifiedDenominator: Polynomial(),
        finalValue: double.nan,
        solved: false,
        errorMessage: e.toString(),
      );
    } on ParserException catch (e) {
      return SolutionResult(
        originalExpression: problem.expression,
        approachValue: problem.approachValue,
        originalNumerator: Polynomial(),
        originalDenominator: Polynomial(),
        numAtPoint: 0,
        denAtPoint: 0,
        isIndeterminate: false,
        factoredNumerator: const FactoredForm(1, []),
        factoredDenominator: const FactoredForm(1, []),
        commonFactors: [],
        simplifiedNumerator: Polynomial(),
        simplifiedDenominator: Polynomial(),
        finalValue: double.nan,
        solved: false,
        errorMessage: e.toString(),
      );
    } catch (e) {
      return SolutionResult(
        originalExpression: problem.expression,
        approachValue: problem.approachValue,
        originalNumerator: Polynomial(),
        originalDenominator: Polynomial(),
        numAtPoint: 0,
        denAtPoint: 0,
        isIndeterminate: false,
        factoredNumerator: const FactoredForm(1, []),
        factoredDenominator: const FactoredForm(1, []),
        commonFactors: [],
        simplifiedNumerator: Polynomial(),
        simplifiedDenominator: Polynomial(),
        finalValue: double.nan,
        solved: false,
        errorMessage: 'Unexpected error: $e',
      );
    }
  }

  /// Extract numerator and denominator polynomials from AST
  (Polynomial, Polynomial) _extractRationalFunction(ASTNode node) {
    // Look for top-level division
    if (node is BinaryOpNode && node.operator == '/') {
      // Handle chained divisions: a/b/c → (a/b)/c
      final numerator = _toPolynomial(node.left);
      final denominator = _toPolynomial(node.right);
      return (numerator, denominator);
    }

    // No division - treat as numerator over constant 1
    return (_toPolynomial(node), Polynomial.constant(1));
  }

  /// Convert an AST node to a Polynomial
  Polynomial _toPolynomial(ASTNode node) {
    if (node is NumberNode) {
      return Polynomial.constant(node.value);
    }

    if (node is VariableNode) {
      return Polynomial.linear(1, 0); // x
    }

    if (node is UnaryMinusNode) {
      return -_toPolynomial(node.operand);
    }

    if (node is BinaryOpNode) {
      // Don't descend into division - that's handled separately
      if (node.operator == '/') {
        throw StateError(
            'Division found where polynomial expected. Ensure expression is a simple fraction.');
      }

      final left = _toPolynomial(node.left);
      final right = _toPolynomial(node.right);

      return switch (node.operator) {
        '+' => left + right,
        '-' => left - right,
        '*' => left * right,
        '^' => _handleExponentiation(left, node.right),
        _ => throw StateError('Unexpected operator: ${node.operator}'),
      };
    }

    throw StateError('Cannot convert to polynomial: $node');
  }

  /// Handle exponentiation (only non-negative integer exponents supported)
  Polynomial _handleExponentiation(Polynomial base, ASTNode exponentNode) {
    if (exponentNode is! NumberNode) {
      throw StateError('Only numeric exponents are supported');
    }

    final exp = exponentNode.value;
    if (exp != exp.toInt() || exp < 0) {
      throw StateError('Only non-negative integer exponents are supported');
    }

    Polynomial result = Polynomial.constant(1);
    for (int i = 0; i < exp.toInt(); i++) {
      result = result * base;
    }
    return result;
  }

  /// Find common linear factors between two lists
  List<LinearFactor> _findCommonFactors(
    List<LinearFactor> factors1,
    List<LinearFactor> factors2,
  ) {
    final common = <LinearFactor>[];
    final remaining = List<LinearFactor>.from(factors2);

    for (var f1 in factors1) {
      for (int i = 0; i < remaining.length; i++) {
        if (f1 == remaining[i]) {
          common.add(f1);
          remaining.removeAt(i);
          break;
        }
      }
    }

    return common;
  }

  /// Divide a polynomial by a linear factor using synthetic division
  Polynomial _divideByLinearFactor(Polynomial p, LinearFactor factor) {
    if (factor.a.abs() < 1e-12) return p;
    final root = factor.root;
    return _syntheticDivision(p, root);
  }

  /// Perform synthetic division by (x - root)
  Polynomial _syntheticDivision(Polynomial p, double root) {
    final n = p.degree;
    if (n < 1) return p;

    // Coefficients in descending order
    final coeffs = List<double>.generate(n + 1, (i) => p[n - i]);

    final newCoeffs = <int, double>{};
    double carry = 0;

    for (int i = 0; i < n; i++) {
      carry = coeffs[i] + carry * root;
      newCoeffs[n - 1 - i] = carry;
    }

    return Polynomial.fromCoeffs(newCoeffs);
  }
}
