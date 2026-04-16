import 'solver_engine.dart';

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
        title: 'Write the Limit',
        explanation:
            'We need to evaluate the limit as $varName approaches $approachStr.',
        latexExpression:
            '\\lim_{$varName \\to $approachStr} \\left($exprTex\\right)',
      ),
      ConjugateStep(
        stepNumber: 2,
        title: 'Direct Substitution',
        explanation:
            'Since the function is defined at $varName = $approachStr, substitute directly.',
        latexExpression:
            '\\text{Substituting } $varName = $approachStr \\Rightarrow ${_fmt(result.numeratorAtPoint)} / ${_fmt(result.denominatorAtPoint)} = ${_fmt(result.finalValue)}',
      ),
      ConjugateStep(
        stepNumber: 3,
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

    steps.add(ConjugateStep(
      stepNumber: 1,
      title: 'Write the Original Limit',
      explanation:
          'We need to evaluate: lim($varName → $approachStr) \\frac{$numTex}{$denTex}',
      latexExpression:
          '\\lim_{$varName \\to $approachStr} \\frac{$numTex}{$denTex}',
    ));

    steps.add(ConjugateStep(
      stepNumber: 2,
      title: 'Check Direct Substitution',
      explanation:
          'Substituting $varName = $approachStr gives \\frac{0}{0}, which is an indeterminate form.',
      latexExpression:
          '\\frac{$numTex}{$denTex}\\bigg|_{$varName = $approachStr} = \\frac{0}{0}',
    ));

    if (result.rationalizedNumeratorNotDenominator) {
      steps.add(ConjugateStep(
        stepNumber: 3,
        title: 'Identify the Radical in Numerator',
        explanation:
            'The numerator $numTex contains a square root. To resolve the 0/0 form, we rationalize the numerator using its conjugate.',
        latexExpression: '\\text{Numerator: } $numTex',
      ));

      steps.add(ConjugateStep(
        stepNumber: 4,
        title: 'Find the Conjugate of Numerator',
        explanation:
            'The conjugate of the numerator $numTex is obtained by changing the sign: $conjTex.',
        latexExpression: '\\text{Conjugate: } $conjTex',
      ));

      steps.add(ConjugateStep(
        stepNumber: 5,
        title: 'Multiply Numerator by the Conjugate',
        explanation:
            'Multiply the numerator by its conjugate. This is equivalent to multiplying by 1.',
        latexExpression: '\\frac{$numTex \\cdot $conjTex}{$denTex}',
      ));
    } else {
      steps.add(ConjugateStep(
        stepNumber: 3,
        title: 'Identify the Radical in Denominator',
        explanation:
            'The denominator $denTex contains a square root. To resolve the 0/0 form, we rationalize the denominator using its conjugate.',
        latexExpression: '\\text{Denominator: } $denTex',
      ));

      steps.add(ConjugateStep(
        stepNumber: 4,
        title: 'Find the Conjugate of Denominator',
        explanation:
            'The conjugate of the denominator $denTex is obtained by changing the sign: $conjTex.',
        latexExpression: '\\text{Conjugate: } $conjTex',
      ));

      steps.add(ConjugateStep(
        stepNumber: 5,
        title: 'Multiply by the Conjugate',
        explanation:
            'Multiply both numerator and denominator by the conjugate. This is equivalent to multiplying by 1.',
        latexExpression: '\\frac{$numTex}{$denTex \\cdot $conjTex}',
      ));
    }

    steps.add(ConjugateStep(
      stepNumber: 6,
      title: 'Apply Difference of Squares',
      explanation:
          'Using (a - b)(a + b) = a² - b² to eliminate the square root.',
      latexExpression: result.rationalizedNumeratorNotDenominator
          ? '\\text{Numerator becomes: } $ratNumTex'
          : '\\text{Denominator becomes: } $ratDenTex',
    ));

    steps.add(ConjugateStep(
      stepNumber: 7,
      title: 'Simplify the Expression',
      explanation: 'After rationalization, the expression becomes:',
      latexExpression: '\\frac{$ratNumTex}{$ratDenTex}',
    ));

    final newNumVal = result.rationalizedNumerator
            ?.evaluate(result.approachValue, variable: result.variable) ??
        0;
    final newDenVal = result.rationalizedDenominator
            ?.evaluate(result.approachValue, variable: result.variable) ??
        0;

    steps.add(ConjugateStep(
      stepNumber: 8,
      title: 'Simplify and Evaluate',
      explanation:
          'Now substitute $varName = $approachStr into the rationalized expression.',
      latexExpression:
          '\\frac{$ratNumTex}{$ratDenTex}\\bigg|_{$varName = $approachStr} = \\frac{${_fmt(newNumVal)}}{${_fmt(newDenVal)}} = ${_fmt(result.finalValue)}',
    ));

    steps.add(ConjugateStep(
      stepNumber: 9,
      title: 'Final Answer',
      explanation:
          'The limit has been successfully evaluated using the conjugate method.',
      latexExpression:
          '\\boxed{\\lim_{$varName \\to $approachStr} \\frac{$numTex}{$denTex} = ${_fmt(result.finalValue)}}',
    ));

    return steps;
  }

  List<ConjugateStep> _generateUnsolvableSteps(ConjugateResult result) {
    final approachStr = _fmt(result.approachValue);
    final varName = result.variable;
    final exprTex =
        result.originalNumerator?.toTex() ?? result.originalExpression;

    return [
      ConjugateStep(
        stepNumber: 1,
        title: 'Write the Limit',
        explanation: 'We need to evaluate:',
        latexExpression: '\\lim_{$varName \\to $approachStr} \\frac{$exprTex}',
      ),
      ConjugateStep(
        stepNumber: 2,
        title: 'Check Indeterminacy',
        explanation:
            'Substituting $varName = $approachStr gives 0/0 (indeterminate form).',
        latexExpression: '\\frac{0}{0}',
      ),
      ConjugateStep(
        stepNumber: 3,
        title: 'Try Conjugate Method',
        explanation: result.errorMessage ??
            'Attempting to find a conjugate to rationalize...',
      ),
      ConjugateStep(
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
    if (n == n.toInt()) return n.toInt().toString();

    for (int denom = 2; denom <= 12; denom++) {
      final numer = n * denom;
      if ((numer - numer.round()).abs() < 1e-9) {
        final intNumer = numer.round();
        final gcdVal = _gcd(intNumer.abs(), denom);
        final simpleNum = intNumer ~/ gcdVal;
        final simpleDen = denom ~/ gcdVal;
        if (simpleDen == 1) return simpleNum.toString();
        return '$simpleNum/$simpleDen';
      }
    }

    return n
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }
}
