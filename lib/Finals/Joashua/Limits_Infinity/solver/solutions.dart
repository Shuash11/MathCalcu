enum StepType {
  analysis,
  transformation,
  simplification,
  substitution,
  conclusion,
}

class SolutionStep {
  final String description;
  final StepType type;
  final String? formula;
  final String? explanation;
  final dynamic expression;

  const SolutionStep({
    required this.description,
    required this.type,
    this.formula,
    this.explanation,
    this.expression,
  });
}

class LimitSolution {
  final String problemNotation;
  final String resultString;
  final double finalValue;
  final String methodUsed;
  final List<SolutionStep> steps;

  const LimitSolution({
    required this.problemNotation,
    required this.resultString,
    required this.finalValue,
    required this.methodUsed,
    required this.steps,
  });
}
