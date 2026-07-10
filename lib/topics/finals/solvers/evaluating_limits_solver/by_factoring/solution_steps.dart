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
    final varName = 'x';

    return [
      SolutionStep(
        stepNumber: 1,
        title: 'Write the equation',
        explanation: 'We need to evaluate the limit:',
        mathematicalExpression:
            '\\lim_{$varName \\to $approachStr} \\frac{${result.originalNumerator.toTex()}}{${result.originalDenominator.toTex()}}',
      ),
      SolutionStep(
        stepNumber: 2,
        title: 'Try Substitution',
        explanation:
            'Since the function is defined at $varName = $approachStr, we substitute the value directly.',
        mathematicalExpression:
            '\\frac{${result.originalNumerator.toTex()}}{${result.originalDenominator.toTex()}}\\bigg|_{$varName=$approachStr} = \\frac{${_fmt(result.numAtPoint)}}{${_fmt(result.denAtPoint)}}',
      ),
      SolutionStep(
        stepNumber: 3,
        title: 'Check if denominator is zero',
        explanation:
            'The denominator is ${_fmt(result.denAtPoint)}, which is not zero. We can proceed with direct substitution.',
        mathematicalExpression:
            '\\frac{${_fmt(result.numAtPoint)}}{${_fmt(result.denAtPoint)}} = ${_fmt(result.finalValue)}',
      ),
      SolutionStep(
        stepNumber: 4,
        title: 'Substitute x = $approachStr',
        explanation: 'Now substitute the value into the expression.',
        mathematicalExpression:
            '= ${_fmt(result.finalValue)}',
      ),
      SolutionStep(
        stepNumber: 5,
        title: 'Write the limit properly',
        explanation: 'The limit exists and equals:',
        mathematicalExpression:
            '\\boxed{\\lim_{$varName \\to $approachStr} \\frac{${result.originalNumerator.toTex()}}{${result.originalDenominator.toTex()}} = ${_fmt(result.finalValue)}}',
      ),
    ];
  }

  /// Steps for factoring approach
  List<SolutionStep> _generateFactoringSteps(SolutionResult result) {
    final steps = <SolutionStep>[];
    final approachStr = _fmt(result.approachValue);
    final varName = 'x';

    // Step 1: Write the equation
    steps.add(SolutionStep(
      stepNumber: 1,
      title: 'Write the equation',
      explanation: 'We need to evaluate the limit:',
      mathematicalExpression:
          '\\lim_{$varName \\to $approachStr} \\frac{${result.originalNumerator.toTex()}}{${result.originalDenominator.toTex()}}',
    ));

    // Step 2: Try Substitution
    steps.add(SolutionStep(
      stepNumber: 2,
      title: 'Try Substitution',
      explanation:
          'Substituting $varName = $approachStr gives 0/0 (indeterminate form).',
      mathematicalExpression:
          '\\frac{${result.originalNumerator.toTex()}}{${result.originalDenominator.toTex()}}\\bigg|_{$varName=$approachStr} = \\frac{0}{0}',
    ));

    // Step 3: Factor the numerator
    steps.add(SolutionStep(
      stepNumber: 3,
      title: 'Factor the numerator',
      explanation: 'Factor the numerator to reveal common factors.',
      mathematicalExpression:
          '\\frac{${result.originalNumerator.toTex()}}{${result.originalDenominator.toTex()}} = \\frac{${result.factoredNumerator.toTex()}}{${result.originalDenominator.toTex()}}',
    ));

    // Step 4: Rewrite the whole fraction
    steps.add(SolutionStep(
      stepNumber: 4,
      title: 'Rewrite the whole fraction',
      explanation: 'Express with all factors visible.',
      mathematicalExpression:
          '= \\frac{${result.factoredNumerator.toTex()}}{${result.factoredDenominator.toTex()}}',
    ));

    // Step 5: Cancel common factors
    final commonStr = result.commonFactors.map((f) => f.toTex()).join(' × ');
    steps.add(SolutionStep(
      stepNumber: 5,
      title: 'Cancel common factors',
      explanation: 'Cancel ($commonStr) from numerator and denominator.',
      mathematicalExpression:
          '= \\frac{${result.simplifiedNumerator.toTex()}}{${result.simplifiedDenominator.toTex()}}',
    ));

    // Step 6: Substitute x = {value}
    final evalNum = result.simplifiedNumerator.evaluate(result.approachValue);
    final evalDen = result.simplifiedDenominator.evaluate(result.approachValue);
    steps.add(SolutionStep(
      stepNumber: 6,
      title: 'Substitute x = $approachStr',
      explanation: 'Now substitute the value into the simplified expression.',
      mathematicalExpression:
          '= \\frac{${_fmt(evalNum)}}{${_fmt(evalDen)}} = ${_fmt(result.finalValue)}',
    ));

    // Step 7: Write the limit properly (Final Answer)
    steps.add(SolutionStep(
      stepNumber: 7,
      title: 'Write the limit properly',
      explanation: 'The limit has been evaluated successfully.',
      mathematicalExpression:
          '\\boxed{\\lim_{$varName \\to $approachStr} \\frac{${result.originalNumerator.toTex()}}{${result.originalDenominator.toTex()}} = ${_fmt(result.finalValue)}}',
    ));

    return steps;
  }

  /// Steps for when factoring doesn't work
  List<SolutionStep> _generateUnsolvableSteps(SolutionResult result) {
    final approachStr = _fmt(result.approachValue);
    final varName = 'x';
    
    return [
      SolutionStep(
        stepNumber: 1,
        title: 'Write the equation',
        explanation: 'We need to evaluate:',
        mathematicalExpression:
            '\\lim_{$varName \\to $approachStr} \\frac{${result.originalNumerator.toTex()}}{${result.originalDenominator.toTex()}}',
      ),
      SolutionStep(
        stepNumber: 2,
        title: 'Try Substitution',
        explanation:
            'Substituting $varName = $approachStr gives 0/0 (indeterminate form).',
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
        title: 'Cannot Solve',
        explanation:
            'After factoring, we find no common factors to cancel. This limit cannot be resolved by factoring.',
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

  /// Format a number for display - shows fraction if exact, otherwise decimal
  String _fmt(double n) {
    if (n.isNaN) return '\\text{undefined}';
    if (n.isInfinite) return n > 0 ? '\\infty' : '-\\infty';

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
