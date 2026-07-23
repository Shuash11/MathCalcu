import 'package:calculus_system/shared/widgets/solution_step_card.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/evaluating_limits_solver/by_factoring/solution_steps.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/theme/app_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class FactoringStepsView extends StatelessWidget {
  final List<SolutionStep> steps;

  const FactoringStepsView({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final step in steps)
          SolutionStepCard(
            stepNumber: step.stepNumber,
            title: step.title,
            description: step.explanation,
            design: AppDesign.app,
            mathContent: step.mathematicalExpression == null
                ? const SizedBox.shrink()
                : _MathBox(latex: step.mathematicalExpression!),
          ),
      ],
    );
  }
}

class _MathBox extends StatelessWidget {
  final String latex;
  const _MathBox({required this.latex});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Math.tex(
        latex,
        textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: FinalsTheme.primaryFor(context),
        ),
        onErrorFallback: (err) => Text(
          latex,
          style: TextStyle(
              color: FinalsTheme.primaryFor(context), fontFamily: 'serif'),
        ),
      ),
    );
  }
}
