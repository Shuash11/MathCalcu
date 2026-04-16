import 'package:calculus_system/Finals/Joashua/Evaluating_limits/By_Substitution/solver/expressions_evaluator.dart';

import 'substitution_engine.dart';


/// Represents a single step in the solution
class SolutionStep {
  final int stepNumber;
  final String title;
  final String explanation;
  final String? mathExpression;

  const SolutionStep({
    required this.stepNumber,
    required this.title,
    required this.explanation,
    this.mathExpression,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('┌─ Step $stepNumber: $title');
    buffer.writeln('│  ${explanation.replaceAll('\n', '\n│  ')}');
    if (mathExpression != null) {
      buffer.writeln('│');
      buffer.writeln('│  $mathExpression'.replaceAll('\n', '\n│  '));
    }
    buffer.write('└────────────────────────────────');
    return buffer.toString();
  }
}

/// Generates step-by-step solutions for limits by substitution
class SubstitutionStepsGenerator {
  /// Generate solution steps based on the result
  List<SolutionStep> generate(SubstitutionResult result) {
    if (result.hasError) {
      return _generateErrorSteps(result);
    }

    if (result.needsDifferentMethod) {
      if (result.isFraction && 
          (result.numeratorResult?.value?.abs() ?? 1.0) < 1e-9 &&
          (result.denominatorResult?.value?.abs() ?? 1.0) < 1e-9) {
        return _generateIndeterminateSteps(result);
      }
      return _generateUndefinedSteps(result);
    }

    if (result.classification == LimitClassification.positiveInfinity ||
        result.classification == LimitClassification.negativeInfinity) {
      return _generateInfinitySteps(result);
    }

    return _generateSuccessSteps(result);
  }

  /// Steps for successful direct substitution
  List<SolutionStep> _generateSuccessSteps(SubstitutionResult result) {
    final steps = <SolutionStep>[];

    steps.add(SolutionStep(
      stepNumber: 1,
      title: 'Identify the Problem',
      explanation: 'We need to evaluate:\n'
          'lim(x → ${_fmt(result.approachValue)}) ${result.normalizedExpression}',
    ));

    if (result.isFraction && result.numeratorResult != null && result.denominatorResult != null) {
      steps.add(SolutionStep(
        stepNumber: 2,
        title: 'Check the Denominator First',
        explanation: 'Before substituting, we should check if the denominator '
            'will be zero (which would make the function undefined).',
        mathExpression: 'Denominator at x = ${_fmt(result.approachValue)}:\n'
            '${result.denominatorResult!.description}',
      ));

      steps.add(SolutionStep(
        stepNumber: 3,
        title: 'Substitute into the Numerator',
        explanation: 'Now substitute x = ${_fmt(result.approachValue)} into the numerator.',
        mathExpression: 'Numerator = ${result.numeratorResult!.description}',
      ));

      steps.add(SolutionStep(
        stepNumber: 4,
        title: 'Divide',
        explanation: 'Since the denominator is not zero, we can divide.',
        mathExpression: 'Result = ${result.numeratorResult!.description} / '
            '${result.denominatorResult!.description}\n'
            '= ${result.finalValueDescription}',
      ));
    } else {
      steps.add(SolutionStep(
        stepNumber: 2,
        title: 'Apply Direct Substitution',
        explanation: 'The function appears to be continuous at x = ${_fmt(result.approachValue)}, '
            'so we can substitute directly.',
        mathExpression: 'f(${_fmt(result.approachValue)}) = ${result.finalValueDescription}',
      ));
    }

    steps.add(SolutionStep(
      stepNumber: result.isFraction ? 5 : 3,
      title: 'Final Answer',
      explanation: 'Direct substitution worked! The limit exists and equals the computed value.',
      mathExpression: 'lim(x → ${_fmt(result.approachValue)}) ${result.normalizedExpression} '
          '= ${result.finalValueDescription}',
    ));

    return steps;
  }

  /// Steps for 0/0 indeterminate form
  List<SolutionStep> _generateIndeterminateSteps(SubstitutionResult result) {
    return [
      SolutionStep(
        stepNumber: 1,
        title: 'Identify the Problem',
        explanation: 'We need to evaluate:\n'
            'lim(x → ${_fmt(result.approachValue)}) ${result.normalizedExpression}',
      ),
      SolutionStep(
        stepNumber: 2,
        title: 'Apply Direct Substitution',
        explanation: 'Let\'s try substituting x = ${_fmt(result.approachValue)} directly.',
        mathExpression: 'Numerator at x = ${_fmt(result.approachValue)}: ${result.numeratorResult?.description ?? "0"}\n'
            'Denominator at x = ${_fmt(result.approachValue)}: ${result.denominatorResult?.description ?? "0"}\n\n'
            'Result: 0/0',
      ),
   const  SolutionStep(
        stepNumber: 3,
        title: 'Identify the Problem',
        explanation: 'We obtained 0/0, which is an indeterminate form.\n\n'
            'An indeterminate form means we cannot determine the limit from '
            'direct substitution alone. The expression might:\n'
            '• Approach a finite value\n'
            '• Approach infinity\n'
            '• Not exist at all\n\n'
            'We need to use a different technique to evaluate this limit.',
      ),
      SolutionStep(
        stepNumber: 4,
        title: 'Recommendation',
        explanation: '${result.suggestedMethod ?? "Try a different method."}\n\n'
            'For rational functions (polynomial ÷ polynomial) that give 0/0, '
            'the most common approach is:\n\n'
            '1. FACTOR both numerator and denominator\n'
            '2. CANCEL any common factors\n'
            '3. Try substitution again\n\n'
            'Other methods that might work:\n'
            '• L\'Hôpital\'s Rule (take derivatives)\n'
            '• Rationalization (for roots)\n'
            '• Algebraic manipulation',
        mathExpression: 'This limit CANNOT be solved by direct substitution alone.\n'
            'Try the "Factoring" method instead.',
      ),
    ];
  }

  /// Steps for infinity results
  List<SolutionStep> _generateInfinitySteps(SubstitutionResult result) {
    return [
      SolutionStep(
        stepNumber: 1,
        title: 'Identify the Problem',
        explanation: 'We need to evaluate:\n'
            'lim(x → ${_fmt(result.approachValue)}) ${result.normalizedExpression}',
      ),
      SolutionStep(
        stepNumber: 2,
        title: 'Apply Direct Substitution',
        explanation: 'Let\'s substitute x = ${_fmt(result.approachValue)}.',
        mathExpression: result.isFraction 
            ? 'Numerator: ${result.numeratorResult?.description ?? "?"}\n'
              'Denominator: ${result.denominatorResult?.description ?? "?"}'
            : 'f(${_fmt(result.approachValue)}) = ${result.finalValueDescription}',
      ),
      SolutionStep(
        stepNumber: 3,
        title: 'Analyze the Result',
        explanation: result.isFraction
            ? 'The numerator evaluates to a non-zero value, but the denominator is zero.\n\n'
              'This means the function grows without bound as x approaches ${_fmt(result.approachValue)}.\n\n'
              'To determine whether it\'s +∞ or -∞, we need to check the signs:\n'
              '• Numerator sign: ${_getSign(result.numeratorResult?.value)}\n'
              '• Denominator sign near ${_fmt(result.approachValue)}: ${_getSign(result.denominatorResult?.value)}'
            : 'The function evaluates to infinity, meaning it grows without bound.',
      ),
      SolutionStep(
        stepNumber: 4,
        title: 'Final Answer',
        explanation: 'The limit does not exist as a finite number. The function '
            'grows without bound.',
        mathExpression: 'lim(x → ${_fmt(result.approachValue)}) ${result.normalizedExpression} '
            '= ${result.finalValueDescription}',
      ),
    ];
  }

  /// Steps for undefined results
  List<SolutionStep> _generateUndefinedSteps(SubstitutionResult result) {
    return [
      SolutionStep(
        stepNumber: 1,
        title: 'Identify the Problem',
        explanation: 'We need to evaluate:\n'
            'lim(x → ${_fmt(result.approachValue)}) ${result.normalizedExpression}',
      ),
      SolutionStep(
        stepNumber: 2,
        title: 'Apply Direct Substitution',
        explanation: 'Substituting x = ${_fmt(result.approachValue)} gives an undefined result.',
        mathExpression: 'f(${_fmt(result.approachValue)}) = undefined',
      ),
      SolutionStep(
        stepNumber: 3,
        title: 'Analysis',
        explanation: 'The expression is undefined at this point. This could be due to:\n'
            '• Division by zero\n'
            '• Square root of a negative number\n'
            '• Logarithm of zero or negative number\n\n'
            '${result.suggestedMethod ?? "Further analysis is needed."}',
      ),
    ];
  }

  /// Steps for error cases
  List<SolutionStep> _generateErrorSteps(SubstitutionResult result) {
    return [
      SolutionStep(
        stepNumber: 1,
        title: 'Error',
        explanation: result.errorMessage ?? 'An unknown error occurred.',
      ),
    ];
  }

  String _getSign(double? value) {
    if (value == null) return 'unknown';
    if (value > 0) return 'positive (+)';
    if (value < 0) return 'negative (-)';
    return 'zero (0)';
  }

  String _fmt(double n) {
    if (n.isNaN) return '?';
    if (n.isInfinite) return n > 0 ? '∞' : '-∞';
    if (n == n.toInt()) return n.toInt().toString();
    return n.toStringAsFixed(2);
  }
}