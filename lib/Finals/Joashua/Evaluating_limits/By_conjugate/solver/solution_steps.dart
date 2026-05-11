import 'solver_engine.dart';
import 'parser.dart';

class ConjugateStep {
  final int stepNumber;
  final String title;
  final String explanation;
  final String? latexExpression;

  const ConjugateStep({
    required this.stepNumber,
    required this.title,
    required this.explanation,
    this.latexExpression,
  });
}

class ConjugateStepsGenerator {
  List<ConjugateStep> generate(ConjugateResult result) {
    if (result.errorMessage != null && !result.isIndeterminate) {
      return _generateErrorSteps(result);
    }

    if (!result.isIndeterminate) {
      return _generateDirectSubstitutionSteps(result);
    }

    if (!result.solved) {
      return _generateUnsolvableSteps(result);
    }

    return _generateConjugateSteps(result);
  }

  List<ConjugateStep> _generateDirectSubstitutionSteps(ConjugateResult result) {
    final approachStr = _fmt(result.approachValue);
    final varName = result.variable;
    final exprTex =
        result.originalNumerator?.toTex() ?? result.originalExpression;

    return [
      ConjugateStep(
        stepNumber: 1,
        title: 'Write the Equation',
        explanation:
            'We need to evaluate the limit as $varName approaches $approachStr.',
        latexExpression:
            '\\lim_{$varName \\to $approachStr} \\left($exprTex\\right)',
      ),
      ConjugateStep(
        stepNumber: 2,
        title: 'Try Substitution',
        explanation:
            'Substitute $varName = $approachStr directly into the expression.',
        latexExpression:
            '\\text{Substituting } $varName = $approachStr',
      ),
      ConjugateStep(
        stepNumber: 3,
        title: 'Check if Denominator is Zero',
        explanation:
            'The denominator is ${_fmt(result.denominatorAtPoint)}, so we can evaluate directly.',
        latexExpression:
            '\\frac{${_fmt(result.numeratorAtPoint)}}{${_fmt(result.denominatorAtPoint)}} = ${_fmt(result.finalValue)}',
      ),
      ConjugateStep(
        stepNumber: 4,
        title: 'Final Answer',
        explanation: 'The limit evaluates to ${_fmt(result.finalValue)}.',
        latexExpression:
            '\\lim_{$varName \\to $approachStr} \\left($exprTex\\right) = ${_fmt(result.finalValue)}',
      ),
    ];
  }

  List<ConjugateStep> _generateConjugateSteps(ConjugateResult result) {
    final steps = <ConjugateStep>[];
    final approachStr = _fmt(result.approachValue);
    final varName = result.variable;

    final numTex = result.originalNumerator?.toTex() ?? '?';
    final denTex = result.originalDenominator?.toTex() ?? '1';
    final conjTex = result.conjugate?.toTex() ?? '?';
    final ratNumTex = result.rationalizedNumerator?.toTex() ?? '?';
    final ratDenTex = result.rationalizedDenominator?.toTex() ?? '?';

    final isRationalizingNumerator = result.rationalizedNumeratorNotDenominator;

    steps.add(ConjugateStep(
      stepNumber: 1,
      title: 'Write the Equation',
      explanation:
          'We need to evaluate the limit as $varName approaches $approachStr.',
      latexExpression:
          '\\lim_{$varName \\to $approachStr} \\frac{$numTex}{$denTex}',
    ));

    steps.add(ConjugateStep(
      stepNumber: 2,
      title: 'Try Substitution',
      explanation:
          'Substituting $varName = $approachStr gives \\frac{0}{0}, which is indeterminate.',
      latexExpression:
          '\\frac{$numTex}{$denTex}\\bigg|_{$varName = $approachStr} = \\frac{0}{0}',
    ));

    steps.add(ConjugateStep(
      stepNumber: 3,
      title: 'Identify the Conjugate',
      explanation: isRationalizingNumerator
          ? 'The numerator contains a square root. Its conjugate is $conjTex.'
          : 'The denominator contains a square root. Its conjugate is $conjTex.',
      latexExpression: '\\text{Conjugate: } $conjTex',
    ));

    steps.add(ConjugateStep(
      stepNumber: 4,
      title: 'Multiply Top and Bottom by the Conjugate',
      explanation: 'Multiply both numerator and denominator by the conjugate.',
      latexExpression: isRationalizingNumerator
          ? '\\frac{$numTex}{$denTex} \\cdot \\frac{$conjTex}{$conjTex} = \\frac{$numTex \\cdot $conjTex}{$denTex \\cdot $conjTex}'
          : '\\frac{$numTex}{$denTex} \\cdot \\frac{$conjTex}{$conjTex} = \\frac{$numTex \\cdot $conjTex}{$denTex \\cdot $conjTex}',
    ));

    final numNode = result.originalNumerator;
    final denNode = result.originalDenominator;
    String? numeratorExpansion;
    String? denominatorExpansion;

    if (numNode != null) {
      numeratorExpansion = _expandNode(numNode);
    }
    if (denNode != null) {
      denominatorExpansion = _expandNode(denNode);
    }

    if (isRationalizingNumerator) {
      steps.add(ConjugateStep(
        stepNumber: 5,
        title: 'Expand the Numerator',
        explanation:
            'Using the difference of squares formula: (a - b)(a + b) = a² - b²',
        latexExpression: numeratorExpansion ??
            '\\text{Numerator: } $numTex \\cdot $conjTex = \\text{expanding...}',
      ));

      steps.add(ConjugateStep(
        stepNumber: 6,
        title: 'Expand the Denominator',
        explanation: 'The denominator remains multiplied by the conjugate.',
        latexExpression:
            '\\text{Denominator: } $denTex \\cdot $conjTex',
      ));
    } else {
      steps.add(ConjugateStep(
        stepNumber: 5,
        title: 'Expand the Numerator',
        explanation: 'The numerator is multiplied by the conjugate.',
        latexExpression: '\\text{Numerator: } $numTex \\cdot $conjTex',
      ));

      steps.add(ConjugateStep(
        stepNumber: 6,
        title: 'Expand the Denominator',
        explanation:
            'Using the difference of squares formula: (a - b)(a + b) = a² - b²',
        latexExpression: denominatorExpansion ??
            '\\text{Denominator: } $denTex \\cdot $conjTex = \\text{expanding...}',
      ));
    }

    steps.add(ConjugateStep(
      stepNumber: 7,
      title: 'Rewrite the Fraction',
      explanation: 'After rationalization, we get:',
      latexExpression: '\\frac{$ratNumTex}{$ratDenTex}',
    ));

    steps.add(ConjugateStep(
      stepNumber: 8,
      title: 'Cancel Common Factors',
      explanation:
          'Look for any ${varName} terms that can be cancelled from numerator and denominator.',
      latexExpression: '\\frac{$ratNumTex}{$ratDenTex} \\Rightarrow \\text{cancelled form}',
    ));

    final newNumVal = result.rationalizedNumerator
            ?.evaluate(result.approachValue, variable: result.variable) ??
        0;
    final newDenVal = result.rationalizedDenominator
            ?.evaluate(result.approachValue, variable: result.variable) ??
        0;

    steps.add(ConjugateStep(
      stepNumber: 9,
      title: 'Substitute x = $approachStr',
      explanation:
          'Now substitute $varName = $approachStr into the simplified expression.',
      latexExpression:
          '\\frac{$ratNumTex}{$ratDenTex}\\bigg|_{$varName = $approachStr} = \\frac{${_fmt(newNumVal)}}{${_fmt(newDenVal)}} = ${_fmt(result.finalValue)}',
    ));

    final finalAnswer = _fmt(result.finalValue);
    steps.add(ConjugateStep(
      stepNumber: 10,
      title: 'Final Answer',
      explanation: 'The limit has been evaluated successfully.',
      latexExpression:
          '\\boxed{\\lim_{$varName \\to $approachStr} \\frac{$numTex}{$denTex} = $finalAnswer}',
    ));

    return steps;
  }

  String _expandNode(ASTNode node) {
    if (node is BinaryOpNode && (node.operator == '+' || node.operator == '-')) {
      final left = node.left;
      final right = node.right;
      final op = node.operator;

      if (left is SqrtNode) {
        final sqrtArg = left.argument.toTex();
        final rightTex = right.toTex();
        return '(\\sqrt{$sqrtArg} $op $rightTex)(\\sqrt{$sqrtArg} $op (-$rightTex)) = ($sqrtArg) - ($rightTex)^2';
      }
    }
    return node.toTex();
  }

  List<ConjugateStep> _generateUnsolvableSteps(ConjugateResult result) {
    final approachStr = _fmt(result.approachValue);
    final varName = result.variable;
    final exprTex =
        result.originalNumerator?.toTex() ?? result.originalExpression;

    return [
      ConjugateStep(
        stepNumber: 1,
        title: 'Write the Equation',
        explanation: 'We need to evaluate:',
        latexExpression: '\\lim_{$varName \\to $approachStr} \\frac{$exprTex}',
      ),
      ConjugateStep(
        stepNumber: 2,
        title: 'Try Substitution',
        explanation:
            'Substituting $varName = $approachStr gives 0/0 (indeterminate form).',
        latexExpression: '\\frac{0}{0}',
      ),
      ConjugateStep(
        stepNumber: 3,
        title: 'Identify the Conjugate',
        explanation: result.errorMessage ??
            'Attempting to find a conjugate to rationalize...',
      ),
      const ConjugateStep(
        stepNumber: 4,
        title: 'Cannot Solve',
        explanation:
            'This limit cannot be solved by the conjugate method. Try a different approach like Factoring or LCD.',
      ),
    ];
  }

  List<ConjugateStep> _generateErrorSteps(ConjugateResult result) {
    return [
      ConjugateStep(
        stepNumber: 1,
        title: 'Error',
        explanation: result.errorMessage ?? 'An unexpected error occurred.',
      ),
    ];
  }

  String _fmt(double n) {
    if (n.isNaN) return '\\text{undefined}';
    if (n.isInfinite) return n > 0 ? '\\infty' : '-\\infty';

    final tolerance = 1e-9;
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

  int _gcd(int a, int b) {
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