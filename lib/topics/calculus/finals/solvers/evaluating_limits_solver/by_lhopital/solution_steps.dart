import 'package:calculus_system/topics/calculus/finals/solvers/derivatives_solver/derivatives_solver.dart';

import 'lhopital_engine.dart';

class LhopitalStep {
  final int stepNumber;
  final String title;
  final String explanation;
  final String? latexExpression;

  const LhopitalStep({
    required this.stepNumber,
    required this.title,
    required this.explanation,
    this.latexExpression,
  });
}

class LhopitalStepsGenerator {
  List<LhopitalStep> generate(LhopitalResult result) {
    if (result.errorMessage != null && !result.isIndeterminate) {
      return _generateErrorSteps(result);
    }

    if (!result.solved) {
      return _generateUnsolvableSteps(result);
    }

    return _generateLhopitalSteps(result);
  }

  List<LhopitalStep> _generateLhopitalSteps(LhopitalResult result) {
    final steps = <LhopitalStep>[];
    final approachStr = _fmt(result.approachValue);
    final varName = result.variable;

    final numTex = _tex(result.originalNumerator) ?? '?';
    final denTex = _tex(result.originalDenominator) ?? '1';
    final indeterminateForm =
        result.isInfinityOverInfinity ? '\\infty/\\infty' : '0/0';

    steps.add(LhopitalStep(
      stepNumber: 1,
      title: 'Write the Equation',
      explanation:
          'We need to evaluate the limit as $varName approaches $approachStr.',
      latexExpression:
          '\\lim_{$varName \\to $approachStr} \\frac{$numTex}{$denTex}',
    ));

    steps.add(LhopitalStep(
      stepNumber: 2,
      title: 'Check the Form',
      explanation:
          'Substituting $varName = $approachStr gives $indeterminateForm, which is indeterminate.',
      latexExpression:
          '\\frac{$numTex}{$denTex}\\bigg|_{$varName = $approachStr} = $indeterminateForm',
    ));

    steps.add(const LhopitalStep(
      stepNumber: 3,
      title: "Apply L'Hopital's Rule",
      explanation:
          "Differentiate the numerator and the denominator separately, then take the limit of their ratio.",
      latexExpression:
          '\\lim \\frac{f(x)}{g(x)} = \\lim \\frac{f\'(x)}{g\'(x)}',
    ));

    var stepNumber = 4;
    for (var i = 0; i < result.rounds.length; i++) {
      final round = result.rounds[i];
      final dNumTex = _tex(round.derivativeNumerator) ?? '?';
      final dDenTex = _tex(round.derivativeDenominator) ?? '?';

      steps.add(LhopitalStep(
        stepNumber: stepNumber++,
        title: "Differentiate Numerator (Round ${i + 1})",
        explanation: "The derivative of the numerator is $dNumTex.",
        latexExpression: '\\frac{d}{dx}\\left[$numTex\\right] = $dNumTex',
      ));

      steps.add(LhopitalStep(
        stepNumber: stepNumber++,
        title: "Differentiate Denominator (Round ${i + 1})",
        explanation: "The derivative of the denominator is $dDenTex.",
        latexExpression: '\\frac{d}{dx}\\left[$denTex\\right] = $dDenTex',
      ));

      steps.add(LhopitalStep(
        stepNumber: stepNumber++,
        title: 'Substitute and Evaluate',
        explanation:
            "Substituting gives \\frac{${_fmt(round.numeratorValue)}}{${_fmt(round.denominatorValue)}}.",
        latexExpression:
            '\\frac{$dNumTex}{$dDenTex}\\bigg|_{$varName = $approachStr} = \\frac{${_fmt(round.numeratorValue)}}{${_fmt(round.denominatorValue)}}',
      ));

      if (i < result.rounds.length - 1) {
        steps.add(LhopitalStep(
          stepNumber: stepNumber++,
          title: 'Still Indeterminate',
          explanation:
              'The result is ${round.form}, still indeterminate. Apply L\'Hopital\'s rule again.',
        ));
      }
    }

    final finalAnswer = _fmt(result.finalValue);
    steps.add(LhopitalStep(
      stepNumber: stepNumber,
      title: 'Final Answer',
      explanation: "The limit has been evaluated using L'Hopital's rule.",
      latexExpression:
          '\\boxed{\\lim_{$varName \\to $approachStr} \\frac{$numTex}{$denTex} = $finalAnswer}',
    ));

    return steps;
  }

  List<LhopitalStep> _generateUnsolvableSteps(LhopitalResult result) {
    final approachStr = _fmt(result.approachValue);
    final varName = result.variable;
    final numTex = _tex(result.originalNumerator) ?? result.originalExpression;
    final denTex = _tex(result.originalDenominator) ?? '1';

    final steps = <LhopitalStep>[
      LhopitalStep(
        stepNumber: 1,
        title: 'Write the Equation',
        explanation:
            'We need to evaluate the limit as $varName approaches $approachStr.',
        latexExpression:
            '\\lim_{$varName \\to $approachStr} \\frac{$numTex}{$denTex}',
      ),
      LhopitalStep(
        stepNumber: 2,
        title: 'Check the Form',
        explanation:
            'Substituting $varName = $approachStr gives an indeterminate form.',
        latexExpression: '\\frac{$numTex}{$denTex}',
      ),
      LhopitalStep(
        stepNumber: 3,
        title: "Apply L'Hopital's Rule",
        explanation:
            result.errorMessage ?? "Attempting to apply L'Hopital's rule...",
      ),
    ];

    for (var i = 0; i < result.rounds.length; i++) {
      final round = result.rounds[i];
      final dNumTex = _tex(round.derivativeNumerator) ?? '?';
      final dDenTex = _tex(round.derivativeDenominator) ?? '?';
      steps.add(LhopitalStep(
        stepNumber: steps.length + 1,
        title: 'Round ${i + 1}',
        explanation:
            "Differentiating gives f' = $dNumTex and g' = $dDenTex, which evaluates to ${round.form}.",
        latexExpression: '\\frac{$dNumTex}{$dDenTex} = ${round.form}',
      ));
    }

    steps.add(LhopitalStep(
      stepNumber: steps.length + 1,
      title: 'Cannot Solve',
      explanation:
          "This limit cannot be solved by L'Hopital's rule here. Try a different method like Factoring, Conjugate, or LCD.",
    ));

    return steps;
  }

  List<LhopitalStep> _generateErrorSteps(LhopitalResult result) {
    return [
      LhopitalStep(
        stepNumber: 1,
        title: 'Error',
        explanation: result.errorMessage ?? 'An unexpected error occurred.',
      ),
    ];
  }

  // ── Formatting ───────────────────────────────────────────────

  String _fmt(double n) {
    if (n.isNaN) return '\\text{undefined}';
    if (n.isInfinite) return n > 0 ? '\\infty' : '-\\infty';
    return LhopitalResult.formatValue(n);
  }

  String? _tex(Expr? node) {
    if (node == null) return null;
    var s = node.toString();
    const funcs = [
      'arcsin',
      'arccos',
      'arctan',
      'asin',
      'acos',
      'atan',
      'sin',
      'cos',
      'tan',
      'sec',
      'csc',
      'cot',
      'exp',
      'ln',
      'log',
      'sqrt',
    ];
    for (final f in funcs) {
      s = s.replaceAll('$f(', '\\$f(');
    }
    s = s.replaceAll(' * ', ' \\cdot ');
    return s;
  }
}
