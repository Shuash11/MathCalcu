import 'limit_problem.dart';
import 'solutions.dart';

class LimitSolver {
  LimitSolution solve(LimitProblem problem) {
    if (problem.limitType == LimitType.infinity ||
        problem.limitType == LimitType.negativeInfinity) {
      return _solveInfinityLimit(problem);
    }
    return _solveFiniteLimit(problem);
  }

  LimitSolution _solveInfinityLimit(LimitProblem problem) {
    final expr = problem.expression;
    final steps = <SolutionStep>[];

    final unsupportedCheck = _checkUnsupported(expr);
    if (unsupportedCheck != null) {
      steps.add(SolutionStep(
        description: 'Unsupported function detected',
        type: StepType.analysis,
        formula: unsupportedCheck,
        explanation:
            'This solver supports rational and polynomial functions only.',
      ));
      return LimitSolution(
        problemNotation: problem.problemNotation,
        resultString: 'Not supported',
        finalValue: double.nan,
        methodUsed: 'Error',
        steps: steps,
      );
    }

    steps.add(SolutionStep(
      description: 'Analyze the limit at infinity',
      type: StepType.analysis,
      formula: '\\lim_{x \\to \\infty} f(x)',
      explanation:
          'We need to find what value f(x) approaches as x grows without bound.',
    ));

    if (expr.contains('/')) {
      return _solveRationalInfinity(problem, steps);
    }

    return _solvePolynomialInfinity(problem, steps);
  }

  String? _checkUnsupported(String expr) {
    final clean = expr.toLowerCase();
    final unsupported = ['sin', 'cos', 'tan', 'sqrt', 'ln', 'log', 'exp', 'e^'];
    for (final func in unsupported) {
      if (clean.contains(func)) {
        return '$func(x) - Not supported';
      }
    }
    return null;
  }

  LimitSolution _solveRationalInfinity(
      LimitProblem problem, List<SolutionStep> steps) {
    final expr = problem.expression;
    final isNegInf = problem.limitType == LimitType.negativeInfinity;
    final infinitySymbol = isNegInf ? '-\\infty' : '\\infty';

    final parts = _parseRational(expr);
    if (parts == null) {
      return LimitSolution(
        problemNotation: problem.problemNotation,
        resultString: 'Cannot parse expression',
        finalValue: double.nan,
        methodUsed: 'Parsing',
        steps: steps,
      );
    }

    final numerator = parts['numerator']!;
    final denominator = parts['denominator']!;
    final numDegree = _getDegree(numerator);
    final denDegree = _getDegree(denominator);

    steps.add(SolutionStep(
      description: 'Identify as a rational function',
      type: StepType.analysis,
      formula: 'f(x) = \\frac{$numerator}{$denominator}',
      explanation: 'The given expression is: \\frac{$numerator}{$denominator}',
    ));

    if (numDegree < denDegree) {
      final result = 0.0;
      final resultStr = '0';

      steps.add(SolutionStep(
        description: 'Step 1: Identify highest power of x in denominator',
        type: StepType.transformation,
        formula: 'deg(denominator) = $denDegree > deg(numerator) = $numDegree',
        explanation: 'The denominator has higher degree than numerator.',
      ));

      steps.add(SolutionStep(
        description: 'Step 2: Apply the limit rule',
        type: StepType.transformation,
        formula:
            '\\text{If } deg(N) < deg(D), \\text{ then } \\lim_{x \\to $infinitySymbol} \\frac{N(x)}{D(x)} = 0',
        explanation:
            'When the denominator has higher degree, it grows faster than numerator, so the fraction approaches 0.',
        expression: '= 0',
      ));

      steps.add(SolutionStep(
        description: 'Step 3: State the final result',
        type: StepType.conclusion,
        formula:
            '\\lim_{x \\to $infinitySymbol} \\frac{$numerator}{$denominator} = 0',
        explanation: 'The limit is 0.',
        expression: '= 0',
      ));

      return LimitSolution(
        problemNotation: problem.problemNotation,
        resultString: resultStr,
        finalValue: result,
        methodUsed: 'Degree Comparison',
        steps: steps,
      );
    } else if (numDegree > denDegree) {
      final resultStr = isNegInf ? '-\\infty' : '\\infty';
      final result = isNegInf ? double.negativeInfinity : double.infinity;

      steps.add(SolutionStep(
        description: 'Step 1: Identify highest power',
        type: StepType.transformation,
        formula: 'deg(numerator) = $numDegree > deg(denominator) = $denDegree',
        explanation: 'The numerator has higher degree than denominator.',
      ));

      steps.add(SolutionStep(
        description: 'Step 2: Apply the limit rule',
        type: StepType.transformation,
        formula:
            '\\text{If } deg(N) > deg(D), \\text{ then } \\lim_{x \\to $infinitySymbol} \\frac{N(x)}{D(x)} = \\infty',
        explanation:
            'When numerator has higher degree, it grows faster and the limit goes to infinity.',
        expression: '= $resultStr',
      ));

      steps.add(SolutionStep(
        description: 'Step 3: State the final result',
        type: StepType.conclusion,
        formula:
            '\\lim_{x \\to $infinitySymbol} \\frac{$numerator}{$denominator} = $resultStr',
        expression: '= $resultStr',
      ));

      return LimitSolution(
        problemNotation: problem.problemNotation,
        resultString: resultStr,
        finalValue: result,
        methodUsed: 'Degree Comparison',
        steps: steps,
      );
    } else {
      final numLead = _getLeadingCoeff(numerator);
      final denLead = _getLeadingCoeff(denominator);
      final result = numLead / denLead;
      final resultStr = _formatNumber(result);

      steps.add(SolutionStep(
        description: 'Step 1: Divide by highest power of x in denominator',
        type: StepType.transformation,
        formula:
            '\\lim_{x \\to $infinitySymbol} \\frac{$numerator}{$denominator} \\cdot \\frac{x^{-$denDegree}}{x^{-$denDegree}}',
        explanation:
            'We divide both numerator and denominator by x^$denDegree (highest power in denominator).',
      ));

      final numTerms = _expandDividedTerms(numerator, denDegree);
      final denTerms = _expandDividedTerms(denominator, denDegree);

      steps.add(SolutionStep(
        description: 'Step 2: Simplify each term',
        type: StepType.transformation,
        formula: '\\frac{$numTerms}{$denTerms}',
        explanation:
            'Dividing each term by x^$denDegree: numerator becomes $numTerms, denominator becomes $denTerms.',
      ));

      steps.add(SolutionStep(
        description: 'Step 3: Evaluate as x approaches $infinitySymbol',
        type: StepType.substitution,
        formula:
            '\\text{As } x \\to \\infty: \\frac{1}{x} \\to 0, \\frac{1}{x^2} \\to 0',
        explanation:
            'As x approaches infinity, terms like \\frac{1}{x}, \\frac{1}{x^2} approach 0.',
      ));

      steps.add(SolutionStep(
        description: 'Step 4: Calculate the limit',
        type: StepType.conclusion,
        formula:
            '\\frac{$numLead + 0}{$denLead + 0} = \\frac{$numLead}{$denLead}',
        explanation:
            'Substituting 0 for all \\frac{1}{x^n} terms gives: \\frac{$numLead}{$denLead} = $resultStr',
        expression: '= $resultStr',
      ));

      return LimitSolution(
        problemNotation: problem.problemNotation,
        resultString: resultStr,
        finalValue: result,
        methodUsed: 'Divide by Highest Power',
        steps: steps,
      );
    }
  }

  LimitSolution _solvePolynomialInfinity(
      LimitProblem problem, List<SolutionStep> steps) {
    final expr = problem.expression;
    final isNegInf = problem.limitType == LimitType.negativeInfinity;
    final degree = _getDegree(expr);

    if (degree == 0) {
      final value = _parseNumber(expr);
      steps.add(SolutionStep(
        description: 'Constant function',
        type: StepType.analysis,
        formula: 'f(x) = $value',
        explanation: 'This is a constant function.',
      ));

      steps.add(SolutionStep(
        description: 'Final answer',
        type: StepType.conclusion,
        formula: '\\lim_{x \\to \\infty} $value = $value',
        expression: '= $value',
      ));

      return LimitSolution(
        problemNotation: problem.problemNotation,
        resultString: _formatNumber(value),
        finalValue: value,
        methodUsed: 'Constant',
        steps: steps,
      );
    }

    if (degree > 0) {
      final leadingCoeff = _getLeadingCoeff(expr);
      final result = isNegInf && degree % 2 == 1
          ? double.negativeInfinity
          : double.infinity;
      final resultStr = _formatNumber(result);

      steps.add(SolutionStep(
        description: 'Polynomial of degree $degree',
        type: StepType.analysis,
        formula: 'deg(f) = $degree',
        explanation:
            'This is a polynomial of degree $degree with leading coefficient $leadingCoeff.',
      ));

      steps.add(SolutionStep(
        description: 'Leading term dominates as x → ∞',
        type: StepType.transformation,
        formula: 'Leading term: ${leadingCoeff}x^$degree',
        explanation:
            'For polynomials, the leading term dominates as x grows large.',
      ));

      steps.add(SolutionStep(
        description: 'Final answer',
        type: StepType.conclusion,
        formula:
            '\\lim_{x \\to ${isNegInf ? "-\infty" : "\\infty"}} $expr = $resultStr',
        expression: '= $resultStr',
      ));

      return LimitSolution(
        problemNotation: problem.problemNotation,
        resultString: resultStr,
        finalValue: result,
        methodUsed: 'Polynomial',
        steps: steps,
      );
    }

    return LimitSolution(
      problemNotation: problem.problemNotation,
      resultString: 'Undefined',
      finalValue: double.nan,
      methodUsed: 'Error',
      steps: steps,
    );
  }

  LimitSolution _solveFiniteLimit(LimitProblem problem) {
    final steps = <SolutionStep>[];
    final expr = problem.expression;

    final approachStr = problem.approachValue.toString();
    steps.add(SolutionStep(
      description: 'Analyze the limit at finite value',
      type: StepType.analysis,
      formula: '\\lim_{x \\to $approachStr} f(x)',
      explanation:
          'We need to find what value f(x) approaches as x approaches $approachStr.',
    ));

    if (expr.contains('/')) {
      final parts = _parseRational(expr);
      if (parts != null) {
        final numerator = parts['numerator']!;
        final denominator = parts['denominator']!;

        final numAtPoint = _evaluateAt(numerator, problem.approachValue);
        final denAtPoint = _evaluateAt(denominator, problem.approachValue);

        steps.add(SolutionStep(
          description: 'Direct substitution',
          type: StepType.substitution,
          formula:
              'f(${problem.approachValue}) = N(${problem.approachValue}) / D(${problem.approachValue})',
          explanation:
              'Substituting x = ${problem.approachValue}: numerator = ${_formatNumber(numAtPoint)}, denominator = ${_formatNumber(denAtPoint)}.',
        ));

        if (numAtPoint.abs() < 1e-9 && denAtPoint.abs() < 1e-9) {
          steps.add(SolutionStep(
            description: 'Indeterminate form 0/0 detected',
            type: StepType.transformation,
            formula: '0/0 is undefined',
            explanation:
                'Direct substitution gives 0/0, which is indeterminate. This requires algebraic manipulation.',
          ));

          return LimitSolution(
            problemNotation: problem.problemNotation,
            resultString: 'Indeterminate (0/0)',
            finalValue: double.nan,
            methodUsed: 'Indeterminate Form',
            steps: steps,
          );
        }

        if (denAtPoint.abs() < 1e-9) {
          final result =
              numAtPoint > 0 ? double.infinity : double.negativeInfinity;
          steps.add(SolutionStep(
            description: 'Vertical asymptote',
            type: StepType.conclusion,
            formula: 'Division by zero',
            expression: '= ${_formatNumber(result)}',
          ));

          return LimitSolution(
            problemNotation: problem.problemNotation,
            resultString: _formatNumber(result),
            finalValue: result,
            methodUsed: 'Vertical Asymptote',
            steps: steps,
          );
        }

        final result = numAtPoint / denAtPoint;
        steps.add(SolutionStep(
          description: 'Final answer',
          type: StepType.conclusion,
          formula: '= ${_formatNumber(result)}',
          expression: '= ${_formatNumber(result)}',
        ));

        return LimitSolution(
          problemNotation: problem.problemNotation,
          resultString: _formatNumber(result),
          finalValue: result,
          methodUsed: 'Direct Substitution',
          steps: steps,
        );
      }
    }

    final result = _evaluateAt(expr, problem.approachValue);
    steps.add(SolutionStep(
      description: 'Direct substitution',
      type: StepType.substitution,
      formula: 'f(${problem.approachValue}) = ${_formatNumber(result)}',
      expression: '= ${_formatNumber(result)}',
    ));

    return LimitSolution(
      problemNotation: problem.problemNotation,
      resultString: _formatNumber(result),
      finalValue: result,
      methodUsed: 'Direct Substitution',
      steps: steps,
    );
  }

  Map<String, String>? _parseRational(String expr) {
    final divisions = <int>[];
    int depth = 0;
    for (int i = 0; i < expr.length; i++) {
      if (expr[i] == '(') depth++;
      if (expr[i] == ')') depth--;
      if (expr[i] == '/' && depth == 0) divisions.add(i);
    }

    if (divisions.isEmpty) return null;
    final idx = divisions.first;
    return {
      'numerator': expr.substring(0, idx).trim(),
      'denominator': expr.substring(idx + 1).trim(),
    };
  }

  int _getDegree(String expr) {
    final clean = _prepareExpression(expr);
    if (_isNumber(clean)) return 0;

    final terms = <String>[];
    int depth = 0;
    int lastStart = 0;
    for (int i = 0; i < clean.length; i++) {
      if (clean[i] == '(') depth++;
      if (clean[i] == ')') depth--;
      if (clean[i] == '+' && depth == 0 && i > 0) {
        terms.add(clean.substring(lastStart, i).trim());
        lastStart = i + 1;
      }
    }
    terms.add(clean.substring(lastStart).trim());

    int maxDegree = 0;
    for (final term in terms) {
      final match = RegExp(r'(\w+)\s*\^\s*(\d+)').firstMatch(term);
      if (match != null && match.group(2) != null) {
        final d = int.tryParse(match.group(2)!) ?? 0;
        if (d > maxDegree) maxDegree = d;
      } else if (term.contains(RegExp(r'[a-zA-Z]'))) {
        if (maxDegree < 1) maxDegree = 1;
      }
    }

    return maxDegree;
  }

  double _getLeadingCoeff(String expr) {
    final clean = _prepareExpression(expr);
    if (_isNumber(clean)) return double.tryParse(clean) ?? 1;

    final patterns = [
      RegExp(r'^(\d+\.?\d*)\s*\*?\s*(\w+)\s*\^\s*(\d+)'),
      RegExp(r'(?:^|[\+\-])(\d+\.?\d*)\s*\*?\s*(\w+)\s*\^\s*(\d+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(clean);
      if (match != null) {
        return double.tryParse(match.group(1)!) ?? 1;
      }
    }

    final simplePattern = RegExp(r'(?:^|[\+\-])(\d+\.?\d*)\s*\*?\s*(\w+)');
    final simpleMatch = simplePattern.firstMatch(clean);
    if (simpleMatch != null) {
      return double.tryParse(simpleMatch.group(1)!) ?? 1;
    }

    return 1;
  }

  double _evaluateAt(String expr, double x) {
    final clean = _prepareExpression(expr);

    if (_isNumber(clean)) {
      return double.tryParse(clean) ?? 0;
    }

    try {
      String processed = clean;
      processed =
          processed.replaceAll(RegExp(r'(\d+)\s*\*?\s*(\w+)'), r'(\1*\2)');

      final powerRegex = RegExp(r'(\w+)\s*\^\s*(\d+)');
      var match = powerRegex.firstMatch(processed);
      while (match != null) {
        final base = match.group(1)!;
        final exp = int.tryParse(match.group(2)!) ?? 1;
        String replacement;
        if (base == 'x') {
          replacement = Math.pow(x, exp).toString();
        } else {
          replacement = match.group(0)!;
        }
        processed = processed.replaceFirst(match.group(0)!, replacement);
        match = powerRegex.firstMatch(processed);
      }

      final evalStr = processed.replaceAll('x', '(${x.toString()})');

      return _safeEval(evalStr);
    } catch (e) {
      return double.nan;
    }
  }

  double _safeEval(String expr) {
    try {
      final clean = expr.replaceAll(RegExp(r'[^\d+\-*/().]'), '');
      if (clean.isEmpty) return 0;

      return _evaluateSimple(clean);
    } catch (e) {
      return double.nan;
    }
  }

  double _evaluateSimple(String expr) {
    expr = expr.trim();

    if (!RegExp(r'^[\d.\-]+$').hasMatch(expr)) {
      if (expr.contains('/')) {
        final parts = expr.split('/');
        if (parts.length == 2) {
          final num = double.tryParse(parts[0].trim()) ?? 0;
          final den = double.tryParse(parts[1].trim()) ?? 1;
          if (den == 0) return double.nan;
          return num / den;
        }
      }
    }

    return double.tryParse(expr) ?? 0;
  }

  String _prepareExpression(String expr) {
    var result = expr.trim();
    result = result.replaceAll(' ', '');
    result = result.replaceAll('*', '');

    if (!result.contains('(') && !result.contains(')')) {
      if (result.contains('/')) {
        return result;
      }
    }

    return result;
  }

  bool _isNumber(String expr) {
    return RegExp(r'^\d+\.?\d*$').hasMatch(expr.trim());
  }

  double _parseNumber(String expr) {
    return double.tryParse(expr.trim()) ?? 0;
  }

  String _formatNumber(double value) {
    if (value.isNaN) return 'Undefined';
    if (value.isInfinite) {
      return value > 0 ? '∞' : '-∞';
    }
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
}

String _expandDividedTerms(String expr, int divideByPower) {
  final terms = <String>[];
  final clean =
      expr.replaceAll(' ', '').replaceAll('*', '').replaceAll('(x)', '(x)');

  final termPattern = RegExp(r'([+-]?\d*\.?\d*x\^?\d*|[+-]?\d*x|[+-]?\d+)');
  final matches = termPattern.allMatches(clean);

  for (final match in matches) {
    final term = match.group(0);
    if (term == null || term.isEmpty) continue;

    if (term.contains('x')) {
      if (term.contains('^')) {
        final baseAndExp = RegExp(r'([+-]?\d*\.?\d*)x\^(\d+)').firstMatch(term);
        if (baseAndExp != null) {
          final coeffStr = baseAndExp.group(1) ?? '1';
          final coeff = coeffStr.isEmpty || coeffStr == '+'
              ? 1.0
              : (coeffStr == '-' ? -1.0 : double.tryParse(coeffStr) ?? 1.0);
          final exp = int.tryParse(baseAndExp.group(2)!) ?? 1;
          final newExp = exp - divideByPower;
          if (newExp > 0) {
            terms.add('${coeff}x^$newExp');
          } else if (newExp == 0) {
            terms.add('$coeff');
          } else {
            final absExp = -newExp;
            if (absExp == 1) {
              terms.add('\\frac{$coeff}{x}');
            } else {
              terms.add('\\frac{$coeff}{x^{$absExp}}');
            }
          }
        }
      } else {
        final coeffMatch = RegExp(r'([+-]?\d+\.?\d*)x').firstMatch(term);
        final coeffStr = coeffMatch != null ? coeffMatch.group(1) ?? '1' : '1';
        final coeff = coeffStr.isEmpty || coeffStr == '+'
            ? 1.0
            : (coeffStr == '-' ? -1.0 : double.tryParse(coeffStr) ?? 1.0);
        final newExp = 1 - divideByPower;
        if (newExp > 0) {
          terms.add('${coeff}x^$newExp');
        } else if (newExp == 0) {
          terms.add('$coeff');
        } else {
          terms.add('\\frac{$coeff}{x}');
        }
      }
    } else {
      final constVal = double.tryParse(term) ?? 0;
      if (divideByPower > 0) {
        if (divideByPower == 1) {
          terms.add('\\frac{$constVal}{x}');
        } else {
          terms.add('\\frac{$constVal}{x^{$divideByPower}}');
        }
      } else {
        terms.add('$constVal');
      }
    }
  }

  if (terms.isEmpty) return '1';
  return terms.join(' + ');
}

class Math {
  static double pow(double base, int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
}
