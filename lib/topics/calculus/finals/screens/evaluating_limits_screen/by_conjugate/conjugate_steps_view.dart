import 'package:calculus_system/shared/widgets/solution_step_card.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/evaluating_limits_solver/by_conjugate/solution_steps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class ConjugateStepsView extends StatelessWidget {
  final List<ConjugateStep> steps;

  const ConjugateStepsView({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: steps.map((step) {
        return SolutionStepCard(
          stepNumber: step.stepNumber,
          title: step.title,
          description: step.explanation,
          mathContent: step.latexExpression != null
              ? _buildLatex(step.latexExpression!)
              : const SizedBox.shrink(),
        );
      }).toList(),
    );
  }

  Widget _buildLatex(String latex) {
    try {
      return Math.tex(
        latex,
        textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: FinalsTheme.primary,
        ),
        onErrorFallback: (err) => Text(
          latex,
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 15,
            color: FinalsTheme.primary,
          ),
        ),
      );
    } catch (e) {
      return Text(
        latex,
        style: TextStyle(
          fontFamily: 'serif',
          fontSize: 15,
          color: FinalsTheme.primary,
        ),
      );
    }
  }
}
