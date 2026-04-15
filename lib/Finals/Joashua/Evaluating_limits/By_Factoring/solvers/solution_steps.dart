import 'solver_engine.dart';

/// Represents a single step in the solution process
class SolutionStep {
  final int stepNumber;
  final String title;
  final String explanation;
  final String? mathematicalExpression;

  const SolutionStep({
    required this.stepNumber,
    required this.title,
    required this.explanation,
    this.mathematicalExpression,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('┌─ Step $stepNumber: $title');
    buffer.writeln('│  ${explanation.replaceAll('\n', '\n│  ')}');
    if (mathematicalExpression != null) {
      buffer.writeln('│');
      buffer.writeln('│  $mathematicalExpression'.replaceAll('\n', '\n│  '));
    }
    buffer.write('└────────────────────────────────');
    return buffer.toString();
  }

  /// Get a simple text version without box drawing
  String toPlainText() {
    final buffer = StringBuffer();
    buffer.writeln('Step $stepNumber: $title');
    buffer.writeln(explanation);
    if (mathematicalExpression != null) {
      buffer.writeln(mathematicalExpression);
    }
    return buffer.toString();
  }
}

/// Generates student-friendly step-by-step solutions for limits by factoring.
///
/// The output is designed to mimic how a professor would explain
/// the solution on a whiteboard, with clear reasoning at each step.
class SolutionStepsGenerator {
  /// Generate solution steps based on the result
  List<SolutionStep> generate(SolutionResult result) {
    if (result.errorMessage != null && !result.isIndeterminate) {
      return _generateErrorSteps(result);
    }

    if (!result.isIndeterminate) {
      return _generateDirectSubstitutionSteps(result);
    }

    if (!result.solved) {
      return _generateUnsolvableSteps(result);
    }

    return _generateFactoringSteps(result);
  }

  /// Steps for when direct substitution works
  List<SolutionStep> _generateDirectSubstitutionSteps(SolutionResult result) {
    final approachStr = _fmt(result.approachValue);
    return [
      SolutionStep(
        stepNumber: 1,
        title: 'Identify the Problem',
        explanation: 'We need to evaluate the following limit:',
        mathematicalExpression:
            '\\lim_{x \\to $approachStr} \\frac{${result.originalNumerator.toTex()}}{${result.originalDenominator.toTex()}}',
      ),
      SolutionStep(
        stepNumber: 2,
        title: 'Apply Direct Substitution',
        explanation:
            'Since the function is defined at x = $approachStr, we substitute the value directly into the expression.',
        mathematicalExpression:
            '\\frac{${result.originalNumerator.toTex()}}{${result.originalDenominator.toTex()}} \\bigg|_{x=$approachStr} = '
            '\\frac{${_fmt(result.numAtPoint)}}{${_fmt(result.denAtPoint)}}',
      ),
      SolutionStep(
        stepNumber: 3,
        title: 'Simplify',
        explanation:
            'The result is not an indeterminate form, so the value we found is the limit.',
        mathematicalExpression: '= ${_fmt(result.finalValue)}',
      ),
      SolutionStep(
        stepNumber: 4,
        title: 'Final Answer',
        explanation: 'The limit exists and equals the computed value.',
        mathematicalExpression:
            '\\lim_{x \\to $approachStr} \\frac{${result.originalNumerator.toTex()}}{${result.originalDenominator.toTex()}} = ${_fmt(result.finalValue)}',
      ),
    ];
  }

  /// Steps for factoring approach
  List<SolutionStep> _generateFactoringSteps(SolutionResult result) {
    final steps = <SolutionStep>[];
    final approachStr = _fmt(result.approachValue);

    // Step 1: Factor
    final numIsFactored = result.originalNumerator.degree > 1;
    final denIsFactored = result.originalDenominator.degree > 1;

    String factorTitle = 'Factor the expression';
    if (numIsFactored && !denIsFactored) {
      factorTitle = 'Factor the numerator';
    } else if (!numIsFactored && denIsFactored) {
      factorTitle = 'Factor the denominator';
    } else if (numIsFactored && denIsFactored) {
      factorTitle = 'Factor both parts';
    }

    steps.add(SolutionStep(
      stepNumber: 1,
      title: factorTitle,
      explanation:
          'Since direct substitution gives 0/0, we factor to reveal the hidden common factors that cause the zero in the denominator.',
      mathematicalExpression:
          '\\lim_{x \\to $approachStr} \\frac{${result.originalNumerator.toTex()}}{${result.originalDenominator.toTex()}} = '
          '\\lim_{x \\to $approachStr} \\frac{${result.factoredNumerator.toTex()}}{${result.factoredDenominator.toTex()}}',
    ));

    // Step 2: Cancel
    final commonStr = result.commonFactors.map((f) => f.toTex()).join(' ');
    steps.add(SolutionStep(
      stepNumber: 2,
      title: 'Cancel the common factor',
      explanation:
          'We can divide both the numerator and the denominator by ($commonStr) because x approaches $approachStr but never actually equals it.',
      mathematicalExpression:
          '\\lim_{x \\to $approachStr} \\frac{${result.factoredNumerator.toTex()}}{${result.factoredDenominator.toTex()}} = '
          '\\lim_{x \\to $approachStr} \\frac{${result.simplifiedNumerator.toTex()}}{${result.simplifiedDenominator.toTex()}}',
    ));

    // Step 3: Evaluate
    final simplifiedResult = result.finalValue;
    final simpNum = result.simplifiedNumerator.toTex();
    final simpDen = result.simplifiedDenominator.toTex();

    String evalExpr;
    if (result.simplifiedDenominator.isConstant &&
        result.simplifiedDenominator.constantTerm == 1) {
      evalExpr =
          '\\lim_{x \\to $approachStr} ($simpNum) = ${_fmt(result.simplifiedNumerator.evaluate(result.approachValue))} = ${_fmt(simplifiedResult)}';
    } else {
      evalExpr =
          '\\lim_{x \\to $approachStr} \\frac{$simpNum}{$simpDen} = \\frac{${_fmt(result.simplifiedNumerator.evaluate(result.approachValue))}}{${_fmt(result.simplifiedDenominator.evaluate(result.approachValue))}} = ${_fmt(simplifiedResult)}';
    }

    steps.add(SolutionStep(
      stepNumber: 3,
      title: 'Evaluate the limit by direct substitution',
      explanation:
          'Now that the indeterminate form is resolved, we substitute x = $approachStr to find the final value.',
      mathematicalExpression: evalExpr,
    ));

    return steps;
  }

  /// Steps for when factoring doesn't work
  List<SolutionStep> _generateUnsolvableSteps(SolutionResult result) {
    final approachStr = _fmt(result.approachValue);
    return [
      SolutionStep(
        stepNumber: 1,
        title: 'Problem Setup',
        explanation: 'We need to evaluate:',
        mathematicalExpression:
            '\\lim_{x \\to $approachStr} \\frac{${result.originalNumerator.toTex()}}{${result.originalDenominator.toTex()}}',
      ),
      SolutionStep(
        stepNumber: 2,
        title: 'Check Indeterminacy',
        explanation:
            'Substituting x = $approachStr gives 0/0 (indeterminate form).',
        mathematicalExpression: '\\frac{0}{0}',
      ),
      SolutionStep(
        stepNumber: 3,
        title: 'Attempt Factoring',
        explanation: 'We try factoring both numerator and denominator.',
        mathematicalExpression:
            '\\text{Num:} ${result.factoredNumerator.toTex()} \\\\ \\text{Den:} ${result.factoredDenominator.toTex()}',
      ),
      const SolutionStep(
        stepNumber: 4,
        title: 'Result: No common factors',
        explanation: 'After factoring, we find no common factors to cancel. '
            'This limit cannot be resolved by factoring.',
      ),
    ];
  }

  /// Steps for error cases
  List<SolutionStep> _generateErrorSteps(SolutionResult result) {
    return [
      SolutionStep(
        stepNumber: 1,
        title: 'Error',
        explanation: result.errorMessage ?? 'An unknown error occurred.',
      ),
    ];
  }

  /// Format a number for display
  String _fmt(double n) {
    if (n.isNaN) return 'undefined';
    if (n.isInfinite) return n > 0 ? '∞' : '-∞';
    if (n == n.toInt()) return n.toInt().toString();

    // Try simple fractions
    for (int denom = 2; denom <= 12; denom++) {
      final numer = n * denom;
      if ((numer - numer.round()).abs() < 1e-9) {
        final intNumer = numer.round();
        // Simplify the fraction
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
