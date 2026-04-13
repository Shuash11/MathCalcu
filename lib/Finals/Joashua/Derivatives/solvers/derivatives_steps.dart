// =====================================================
// DERIVATIVE STEPS - Classroom-Style Step Generator
// Provides detailed, educational explanations
// =====================================================

import 'package:calculus_system/Finals/Joashua/Derivatives/solvers/deriviatives_solver.dart';


/// Classroom-style step formatter for derivative solutions
class ClassroomStepFormatter {
  /// Format all steps in a classroom-friendly manner
  static List<ClassroomStep> formatSteps(DerivativeSteps steps) {
    final classroomSteps = <ClassroomStep>[];
    
    for (int i = 0; i < steps.steps.length; i++) {
      final step = steps.steps[i];
      classroomSteps.add(_formatStep(step, i + 1, steps.variable));
    }
    
    return classroomSteps;
  }
  
  static ClassroomStep _formatStep(DerivativeStep step, int stepNum, String variable) {
    return ClassroomStep(
      stepNumber: stepNum,
      type: step.type,
      title: _getTitle(step),
      explanation: _getExplanation(step, variable),
      expression: step.expression.toString(),
      rule: step.rule,
      tip: _getTip(step),
      highlightedParts: _getHighlightedParts(step)
    );
  }
  
  static String _getTitle(DerivativeStep step) {
    switch (step.type) {
      case StepType.original:
        return 'Problem Statement';
      case StepType.identifyRule:
        return 'Identify the Rule(s)';
      case StepType.applyRule:
        return 'Apply Differentiation';
      case StepType.simplify:
        return 'Simplify';
      case StepType.finalResult:
        return 'Final Answer';
    }
  }
  
  static String _getExplanation(DerivativeStep step, String variable) {
    switch (step.type) {
      case StepType.original:
        return 'We need to find d/d$variable [${step.expression}]';
        
      case StepType.identifyRule:
        return _getRuleExplanation(step);
        
      case StepType.applyRule:
        return _getApplyExplanation(step, variable);
        
      case StepType.simplify:
        return step.description;
        
      case StepType.finalResult:
        return 'After differentiating and simplifying, we obtain the derivative.';
    }
  }
  
  static String _getRuleExplanation(DerivativeStep step) {
    if (step.rule == null) return '';
    
    final rule = step.rule!;
    
    if (rule.contains('Sum/Difference')) {
      return '$rule\n\nThis rule tells us that the derivative of a sum (or difference) is simply the sum (or difference) of the derivatives. We can differentiate each term independently.';
    }
    if (rule.contains('Product Rule')) {
      return '$rule\n\nThe Product Rule is essential when differentiating two functions multiplied together. Remember: "first times derivative of second, plus second times derivative of first".';
    }
    if (rule.contains('Quotient Rule')) {
      return '$rule\n\nThe Quotient Rule handles division of functions. A helpful mnemonic is "low d-high minus high d-low, over the square of what is below".';
    }
    if (rule.contains('Power Rule') && !rule.contains('General')) {
      return '$rule\n\nThe Power Rule is one of the most fundamental rules in calculus. Simply bring the exponent down as a coefficient and reduce the exponent by 1.';
    }
    if (rule.contains('Chain Rule')) {
      return '$rule\n\nThe Chain Rule is used for composite functions - functions inside functions. We differentiate the outer function, then multiply by the derivative of the inner function.';
    }
    if (rule.contains('Exponential Rule')) {
      return '$rule\n\nWhen the base is constant and the exponent is variable, we use this rule. Note the presence of ln(base).';
    }
    if (rule.contains('General Power')) {
      return '$rule\n\nWhen both the base and exponent are variable, we use logarithmic differentiation in disguise.';
    }
    if (rule.contains('Sine')) {
      return '$rule\n\nThe derivative of sine is cosine - one of the most basic trigonometric derivatives to memorize.';
    }
    if (rule.contains('Cosine')) {
      return '$rule\n\nNote the negative sign! The derivative of cosine is negative sine. This is a common source of errors.';
    }
    if (rule.contains('Tangent') && !rule.contains('Arctangent')) {
      return '$rule\n\nRemember that sec^2(x) = 1 + tan^2(x) by the Pythagorean identity for tangent.';
    }
    if (rule.contains('Cotangent') && !rule.contains('Arccotangent')) {
      return '$rule\n\nNote the negative sign! The derivative of cotangent is negative cosecant squared.';
    }
    if (rule.contains('Secant') && !rule.contains('Arcsecant')) {
      return '$rule\n\nThe derivative of secant involves both secant and tangent.';
    }
    if (rule.contains('Cosecant') && !rule.contains('Arccosecant')) {
      return '$rule\n\nNote the negative sign! The derivative of cosecant involves both cosecant and cotangent.';
    }
    if (rule.contains('Natural Log')) {
      return '$rule\n\nThe derivative of the natural logarithm is simply 1/u. This is why natural logarithms are so important in calculus!';
    }
    if (rule.contains('Exponential') && rule.contains('e')) {
      return '$rule\n\nThe exponential function e^x is special - it is its own derivative! This is a unique property of e.';
    }
    if (rule.contains('Arcsine')) {
      return '$rule\n\nBe careful with the domain: arcsin(u) is only defined when |u| <= 1.';
    }
    if (rule.contains('Arccosine')) {
      return '$rule\n\nNote the negative sign! Like cosine, arccosine derivative has a negative sign.';
    }
    if (rule.contains('Arctangent')) {
      return '$rule\n\nThis is one of the "nicer" inverse trig derivatives - no square roots involved!';
    }
    if (rule.contains('Square Root')) {
      return '$rule\n\nSquare roots can be thought of as x^(1/2), so this is actually a special case of the Power Rule with the Chain Rule.';
    }
    if (rule.contains('Absolute Value')) {
      return '$rule\n\nBe careful! The absolute value function is not differentiable at 0. This formula assumes the input is not zero.';
    }
    if (rule.contains('Hyperbolic Sine')) {
      return '$rule\n\nThe derivative of sinh is cosh - similar to regular sine/cosine but without the sign changes!';
    }
    if (rule.contains('Hyperbolic Cosine')) {
      return '$rule\n\nThe derivative of cosh is sinh - notice there is no negative sign, unlike regular cosine!';
    }
    if (rule.contains('Hyperbolic Tangent')) {
      return '$rule\n\nThe derivative of tanh is sech^2 - analogous to the regular tangent derivative.';
    }
    if (rule.contains('Hyperbolic Secant')) {
      return '$rule\n\nNote the negative sign in the derivative of sech!';
    }
    if (rule.contains('Hyperbolic Cosecant')) {
      return '$rule\n\nNote the negative sign in the derivative of csch!';
    }
    if (rule.contains('Hyperbolic Cotangent')) {
      return '$rule\n\nNote the negative sign! The derivative of coth is negative csch squared.';
    }
    if (rule.contains('Logarithm Base')) {
      return '$rule\n\nFor logarithms with any base, we can use the change of base formula or this direct rule.';
    }
    
    return rule;
  }
  
  static String _getApplyExplanation(DerivativeStep step, String variable) {
    final expr = step.expression;
    final buffer = StringBuffer();
    
    buffer.writeln('Applying the differentiation rules:');
    buffer.writeln('');
    buffer.writeln('f\'($variable) = $expr');
    
    return buffer.toString();
  }
  
  static String? _getTip(DerivativeStep step) {
    switch (step.type) {
      case StepType.identifyRule:
        if (step.rule?.contains('Product Rule') == true) {
          return 'Tip: Always write out f, g, f\', and g\' separately before applying the Product Rule to avoid mistakes.';
        }
        if (step.rule?.contains('Quotient Rule') == true) {
          return 'Tip: Double-check your signs! The Quotient Rule has a minus in the numerator - this is where many students make errors.';
        }
        if (step.rule?.contains('Chain Rule') == true) {
          return 'Tip: Identify the "inner" and "outer" functions first. The outer function is what you see first, the inner is what is inside the parentheses.';
        }
        if (step.rule?.contains('Power Rule') == true) {
          return 'Tip: For fractional exponents like x^(1/2), the Power Rule still applies: (1/2)x^(-1/2).';
        }
        if (step.rule?.contains('Cosine') == true) {
          return 'Tip: Do not forget the negative sign! This is the most common mistake with cosine derivatives.';
        }
        if (step.rule?.contains('Natural Log') == true) {
          return 'Tip: Remember that ln(x) and log(x) usually mean the same thing in calculus - natural logarithm.';
        }
        return null;
      case StepType.applyRule:
        return 'Tip: Do not rush to simplify - first make sure your derivative is correct, then simplify.';
      case StepType.simplify:
        return null;
      case StepType.original:
        return 'Tip: Before differentiating, check if the expression can be simplified first - it might make differentiation easier.';
      case StepType.finalResult:
        return 'Tip: You can verify your answer by checking a few specific values or using numerical differentiation.';
    }
  }
  
  static List<String> _getHighlightedParts(DerivativeStep step) {
    final parts = <String>[];
    
    if (step.rule != null) {
      final rule = step.rule!;
      
      if (rule.contains('f\'(x)')) {
        parts.add("f'(x)");
        parts.add("g'(x)");
      }
      if (rule.contains('n*x')) {
        parts.add('n');
        parts.add('x^(n-1)');
      }
    }
    
    return parts;
  }
  
  /// Generate a complete classroom-style solution document
  static ClassroomSolution generateFullSolution(DerivativeSteps steps) {
    final formattedSteps = formatSteps(steps);
    
    return ClassroomSolution(
      problem: 'Find f\'(${steps.variable}) where f(${steps.variable}) = ${steps.original}',
      originalExpression: steps.original.toString(),
      finalAnswer: steps.derivative.toString(),
      steps: formattedSteps,
      summary: _generateSummary(steps),
      commonMistakes: _getCommonMistakes(steps),
      relatedConcepts: _getRelatedConcepts(steps)
    );
  }
  
  static String _generateSummary(DerivativeSteps steps) {
    final rules = steps.steps
        .where((s) => s.type == StepType.identifyRule)
        .map((s) => s.rule)
        .whereType<String>()
        .toList();
    
    if (rules.isEmpty) return 'This was a straightforward differentiation problem.';
    
    final buffer = StringBuffer('To solve this problem, we used ');
    
    if (rules.length == 1) {
      buffer.writeln('the ${_extractRuleName(rules.first)}.');
    } else if (rules.length == 2) {
      buffer.writeln('${_extractRuleName(rules.first)} and ${_extractRuleName(rules.last)}.');
    } else {
      buffer.writeln('several rules including:');
      for (int i = 0; i < rules.length - 1; i++) {
        buffer.writeln('  - ${_extractRuleName(rules[i])}');
      }
      buffer.writeln('  and ${_extractRuleName(rules.last)}.');
    }
    
    buffer.writeln('');
    buffer.writeln('The final derivative is: f\'(${steps.variable}) = ${steps.derivative}');
    
    return buffer.toString();
  }
  
  static String _extractRuleName(String rule) {
    if (rule.contains('Sum/Difference')) return 'Sum/Difference Rule';
    if (rule.contains('Product Rule')) return 'Product Rule';
    if (rule.contains('Quotient Rule')) return 'Quotient Rule';
    if (rule.contains('Power Rule') && !rule.contains('General')) return 'Power Rule';
    if (rule.contains('Chain Rule')) return 'Chain Rule';
    if (rule.contains('Exponential Rule')) return 'Exponential Rule';
    if (rule.contains('General Power')) return 'General Power Rule';
    if (rule.contains('Sine')) return 'Sine Derivative';
    if (rule.contains('Cosine')) return 'Cosine Derivative';
    if (rule.contains('Tangent') && !rule.contains('Arctangent')) return 'Tangent Derivative';
    if (rule.contains('Cotangent')) return 'Cotangent Derivative';
    if (rule.contains('Secant')) return 'Secant Derivative';
    if (rule.contains('Cosecant')) return 'Cosecant Derivative';
    if (rule.contains('Arcsine')) return 'Arcsine Derivative';
    if (rule.contains('Arccosine')) return 'Arccosine Derivative';
    if (rule.contains('Arctangent')) return 'Arctangent Derivative';
    if (rule.contains('Hyperbolic Sine')) return 'Hyperbolic Sine Derivative';
    if (rule.contains('Hyperbolic Cosine')) return 'Hyperbolic Cosine Derivative';
    if (rule.contains('Hyperbolic Tangent')) return 'Hyperbolic Tangent Derivative';
    if (rule.contains('Hyperbolic Secant')) return 'Hyperbolic Secant Derivative';
    if (rule.contains('Hyperbolic Cosecant')) return 'Hyperbolic Cosecant Derivative';
    if (rule.contains('Hyperbolic Cotangent')) return 'Hyperbolic Cotangent Derivative';
    if (rule.contains('Natural Log')) return 'Natural Logarithm Derivative';
    if (rule.contains('Exponential') && rule.contains('e')) return 'Exponential Derivative';
    if (rule.contains('Square Root')) return 'Square Root Derivative';
    if (rule.contains('Absolute Value')) return 'Absolute Value Derivative';
    if (rule.contains('Logarithm Base')) return 'Logarithm Base Change';
    return rule.split(':')[0].trim();
  }
  
  static List<String> _getCommonMistakes(DerivativeSteps steps) {
    final mistakes = <String>[];
    final rules = steps.steps
        .where((s) => s.type == StepType.identifyRule)
        .map((s) => s.rule)
        .whereType<String>()
        .toList();
    
    for (final rule in rules) {
      if (rule.contains('Product Rule')) {
        mistakes.add('Forgetting that the Product Rule has TWO terms, not one');
        mistakes.add('Mixing up which derivative goes with which function');
      }
      if (rule.contains('Quotient Rule')) {
        mistakes.add('Getting the order wrong in the numerator (it is f\'g - fg\', not fg\' - f\'g)');
        mistakes.add('Forgetting to square the denominator');
      }
      if (rule.contains('Chain Rule')) {
        mistakes.add('Forgetting to multiply by the derivative of the inner function');
        mistakes.add('Not correctly identifying what the "inner" function is');
      }
      if (rule.contains('Cosine')) {
        mistakes.add('Forgetting the negative sign in the derivative of cosine');
      }
      if (rule.contains('Tangent') && !rule.contains('Arctangent')) {
        mistakes.add('Writing tan\'(x) = 1/cos^2(x) instead of sec^2(x) (they are equivalent, but sec^2(x) is the standard form)');
      }
      if (rule.contains('Power Rule')) {
        mistakes.add('Forgetting to reduce the exponent by 1');
        mistakes.add('Not bringing the exponent down as a coefficient');
      }
      if (rule.contains('Natural Log')) {
        mistakes.add('Writing ln\'(x) = 1/ln(x) instead of 1/x');
      }
      if (rule.contains('Hyperbolic Cosine')) {
        mistakes.add('Adding a negative sign (cosh\' = sinh, NOT -sinh)');
      }
      if (rule.contains('Hyperbolic Tangent')) {
        mistakes.add('Using tanh\' = sech^2 with a negative sign (there is no negative!)');
      }
    }
    
    return mistakes.isEmpty ? ['Always double-check your algebra when simplifying'] : mistakes;
  }
  
  static List<String> _getRelatedConcepts(DerivativeSteps steps) {
    final concepts = <String>[];
    final rules = steps.steps
        .where((s) => s.type == StepType.identifyRule)
        .map((s) => s.rule)
        .whereType<String>()
        .toList();
    
    concepts.add('Definition of the Derivative as a Limit');
    
    for (final rule in rules) {
      if (rule.contains('Product Rule')) {
        concepts.add('Logarithmic Differentiation (alternative for products)');
      }
      if (rule.contains('Quotient Rule')) {
        concepts.add('Rewriting quotients as products with negative exponents');
      }
      if (rule.contains('Chain Rule')) {
        concepts.add('Implicit Differentiation');
        concepts.add('Related Rates');
      }
      if (rule.contains('Trigonometric') || rule.contains('Sine') || rule.contains('Cosine') || 
          rule.contains('Tangent') || rule.contains('Secant') || rule.contains('Cosecant') || 
          rule.contains('Cotangent')) {
        concepts.add('Trigonometric Identities');
      }
      if (rule.contains('Arcsine') || rule.contains('Arccosine') || rule.contains('Arctangent')) {
        concepts.add('Inverse Function Theorem');
      }
      if (rule.contains('Exponential') || rule.contains('Natural Log')) {
        concepts.add('Logarithmic Differentiation');
      }
      if (rule.contains('Hyperbolic')) {
        concepts.add('Relationship between hyperbolic and trigonometric functions');
      }
    }
    
    concepts.add('Higher-Order Derivatives (second derivative, etc.)');
    concepts.add('Applications of Derivatives (optimization, related rates)');
    
    return concepts.toSet().toList();
  }
}

/// A single classroom-formatted step
class ClassroomStep {
  final int stepNumber;
  final StepType type;
  final String title;
  final String explanation;
  final String expression;
  final String? rule;
  final String? tip;
  final List<String> highlightedParts;
  
  const ClassroomStep({
    required this.stepNumber,
    required this.type,
    required this.title,
    required this.explanation,
    required this.expression,
    this.rule,
    this.tip,
    this.highlightedParts = const []
  });
  
  /// Format as plain text
  String toPlainText() {
    final buffer = StringBuffer();
    buffer.writeln('Step $stepNumber: $title');
    buffer.writeln('-' * 40);
    buffer.writeln(explanation);
    if (expression.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('   $expression');
    }
    if (tip != null) {
      buffer.writeln('');
      buffer.writeln(tip);
    }
    buffer.writeln('');
    return buffer.toString();
  }
  
  /// Format as markdown
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('### Step $stepNumber: $title');
    buffer.writeln('');
    buffer.writeln(explanation);
    if (expression.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln(r'$$');
      buffer.writeln(expression);
      buffer.writeln(r'$$');
    }
    if (tip != null) {
      buffer.writeln('');
      buffer.writeln('> $tip');
    }
    buffer.writeln('');
    buffer.writeln('---');
    buffer.writeln('');
    return buffer.toString();
  }
  
  /// Convert to JSON-serializable map
  Map<String, dynamic> toJson() => {
    'stepNumber': stepNumber,
    'type': type.name,
    'title': title,
    'explanation': explanation,
    'expression': expression,
    'rule': rule,
    'tip': tip,
    'highlightedParts': highlightedParts
  };
}

/// Complete classroom solution document
class ClassroomSolution {
  final String problem;
  final String originalExpression;
  final String finalAnswer;
  final List<ClassroomStep> steps;
  final String summary;
  final List<String> commonMistakes;
  final List<String> relatedConcepts;
  
  const ClassroomSolution({
    required this.problem,
    required this.originalExpression,
    required this.finalAnswer,
    required this.steps,
    required this.summary,
    required this.commonMistakes,
    required this.relatedConcepts
  });
  
  /// Format as plain text
  String toPlainText() {
    final buffer = StringBuffer();
    
    buffer.writeln('=' * 50);
    buffer.writeln('         DERIVATIVE SOLUTION');
    buffer.writeln('=' * 50);
    buffer.writeln('');
    buffer.writeln('PROBLEM: $problem');
    buffer.writeln('');
    buffer.writeln('-' * 50);
    buffer.writeln('');
    
    for (final step in steps) {
      buffer.write(step.toPlainText());
    }
    
    buffer.writeln('=' * 50);
    buffer.writeln('              SUMMARY');
    buffer.writeln('=' * 50);
    buffer.writeln('');
    buffer.writeln(summary);
    buffer.writeln('');
    
    if (commonMistakes.isNotEmpty) {
      buffer.writeln('-' * 50);
      buffer.writeln('         COMMON MISTAKES TO AVOID');
      buffer.writeln('-' * 50);
      buffer.writeln('');
      for (int i = 0; i < commonMistakes.length; i++) {
        buffer.writeln('${i + 1}. ${commonMistakes[i]}');
      }
      buffer.writeln('');
    }
    
    if (relatedConcepts.isNotEmpty) {
      buffer.writeln('-' * 50);
      buffer.writeln('         RELATED CONCEPTS');
      buffer.writeln('-' * 50);
      buffer.writeln('');
      for (final concept in relatedConcepts) {
        buffer.writeln('- $concept');
      }
      buffer.writeln('');
    }
    
    return buffer.toString();
  }
  
  /// Format as markdown
  String toMarkdown() {
    final buffer = StringBuffer();
    
    buffer.writeln('# Derivative Solution');
    buffer.writeln('');
    buffer.writeln('## Problem');
    buffer.writeln('');
    buffer.writeln('Find the derivative of: **$originalExpression**');
    buffer.writeln('');
    buffer.writeln('---');
    buffer.writeln('');
    
    for (final step in steps) {
      buffer.write(step.toMarkdown());
    }
    
    buffer.writeln('## Final Answer');
    buffer.writeln('');
    buffer.writeln(r'$$');
    buffer.writeln("f'(x) = $finalAnswer");
    buffer.writeln(r'$$');
    buffer.writeln('');
    
    buffer.writeln('## Summary');
    buffer.writeln('');
    buffer.writeln(summary);
    buffer.writeln('');
    
    if (commonMistakes.isNotEmpty) {
      buffer.writeln('## Common Mistakes to Avoid');
      buffer.writeln('');
      for (final mistake in commonMistakes) {
        buffer.writeln('- $mistake');
      }
      buffer.writeln('');
    }
    
    if (relatedConcepts.isNotEmpty) {
      buffer.writeln('## Related Concepts');
      buffer.writeln('');
      for (final concept in relatedConcepts) {
        buffer.writeln('- $concept');
      }
      buffer.writeln('');
    }
    
    return buffer.toString();
  }
  
  /// Convert to JSON-serializable map
  Map<String, dynamic> toJson() => {
    'problem': problem,
    'originalExpression': originalExpression,
    'finalAnswer': finalAnswer,
    'steps': steps.map((s) => s.toJson()).toList(),
    'summary': summary,
    'commonMistakes': commonMistakes,
    'relatedConcepts': relatedConcepts
  };
}

// ============ EXTENDED STEP GENERATOR ============

/// Advanced step generator with more detailed breakdowns
class AdvancedStepGenerator {
  /// Generate steps with sub-steps for complex expressions
  static ClassroomSolution generateDetailedSolution(String expression, String variable) {
    final steps = DerivativeSolver.getSteps(expression, variable);
    final solution = ClassroomStepFormatter.generateFullSolution(steps);
    
    return _enhanceSolution(solution, steps);
  }
  
  static ClassroomSolution _enhanceSolution(ClassroomSolution solution, DerivativeSteps rawSteps) {
    final enhancedSteps = <ClassroomStep>[];
    
    for (final step in solution.steps) {
      enhancedSteps.add(step);
      
      if (step.type == StepType.applyRule) {
        final subSteps = _generateSubSteps(rawSteps.original, rawSteps.variable);
        enhancedSteps.addAll(subSteps);
      }
    }
    
    return ClassroomSolution(
      problem: solution.problem,
      originalExpression: solution.originalExpression,
      finalAnswer: solution.finalAnswer,
      steps: enhancedSteps,
      summary: solution.summary,
      commonMistakes: solution.commonMistakes,
      relatedConcepts: solution.relatedConcepts
    );
  }
  
  static List<ClassroomStep> _generateSubSteps(Expr expr, String variable) {
    final subSteps = <ClassroomStep>[];
    int subNum = 1;
    
    void processExpr(Expr e) {
      if (e is BinOp && e.op == '*') {
        subSteps.add(ClassroomStep(
          stepNumber: subNum++,
          type: StepType.simplify,
          title: 'Breaking Down Product Rule',
          explanation: 'Let us identify each part:\n'
              '  - f($variable) = ${e.left}\n'
              '  - g($variable) = ${e.right}\n'
              '  - f\'($variable) = ${e.left.diff(variable).simplify()}\n'
              '  - g\'($variable) = ${e.right.diff(variable).simplify()}',
          expression: '',
          tip: 'Always find f\' and g\' separately before combining them'
        ));
      }
      
      if (e is BinOp && e.op == '/') {
        subSteps.add(ClassroomStep(
          stepNumber: subNum++,
          type: StepType.simplify,
          title: 'Breaking Down Quotient Rule',
          explanation: 'Let us identify each part:\n'
              '  - f($variable) = ${e.left} (numerator)\n'
              '  - g($variable) = ${e.right} (denominator)\n'
              '  - f\'($variable) = ${e.left.diff(variable).simplify()}\n'
              '  - g\'($variable) = ${e.right.diff(variable).simplify()}',
          expression: '',
          tip: 'Remember: "Low D-High minus High D-Low, over Low squared"'
        ));
      }
      
      if (e is Func && e.arg.hasVar(variable)) {
        subSteps.add(ClassroomStep(
          stepNumber: subNum++,
          type: StepType.simplify,
          title: 'Applying Chain Rule',
          explanation: 'For ${e.name}(...):\n'
              '  - Outer function: ${e.name}(u)\n'
              '  - Inner function: u = ${e.arg}\n'
              '  - Derivative of outer: ${_outerDerivative(e.name)}\n'
              '  - Derivative of inner: ${e.arg.diff(variable).simplify()}',
          expression: '',
          tip: 'The Chain Rule says: (outer derivative evaluated at inner) x (inner derivative)'
        ));
      }
      
      if (e is BinOp) {
        processExpr(e.left);
        processExpr(e.right);
      } else if (e is Func) {
        processExpr(e.arg);
      } else if (e is Neg) {
        processExpr(e.expr);
      }
    }
    
    processExpr(expr);
    return subSteps;
  }
  
  static String _outerDerivative(String funcName) {
    switch (funcName) {
      case 'sin': return 'cos(u)';
      case 'cos': return '-sin(u)';
      case 'tan': return 'sec^2(u)';
      case 'cot': return '-csc^2(u)';
      case 'sec': return 'sec(u)tan(u)';
      case 'csc': return '-csc(u)cot(u)';
      case 'ln': 
      case 'log': return '1/u';
      case 'exp': return 'e^u';
      case 'sqrt': return '1/(2*sqrt(u))';
      case 'arcsin': 
      case 'asin': return '1/sqrt(1-u^2)';
      case 'arccos': 
      case 'acos': return '-1/sqrt(1-u^2)';
      case 'arctan': 
      case 'atan': return '1/(1+u^2)';
      case 'sinh': return 'cosh(u)';
      case 'cosh': return 'sinh(u)';
      case 'tanh': return 'sech^2(u)';
      case 'sech': return '-sech(u)tanh(u)';
      case 'csch': return '-csch(u)coth(u)';
      case 'coth': return '-csch^2(u)';
      default: return '?';
    }
  }
}

// ============ EXAMPLE USAGE ============

