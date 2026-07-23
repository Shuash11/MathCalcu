import 'package:calculus_system/shared/widgets/solution_step_card.dart';
import 'package:calculus_system/topics/calculus/finals/solvers/evaluating_limits_solver/by_substitution/substitution_steps.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:calculus_system/theme/app_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class SubstitutionStepsView extends StatelessWidget {
  final List<SolutionStep> steps;

  const SubstitutionStepsView({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++)
          SolutionStepCard(
            stepNumber: i + 1,
            title: steps[i].title,
            description: steps[i].explanation,
            design: AppDesign.app,
            mathContent: steps[i].mathExpression == null
                ? const SizedBox.shrink()
                : _MathBox(latex: steps[i].mathExpression!),
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
    final primaryFor = FinalsTheme.primaryFor(context);
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Math.tex(
        latex,
        textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: primaryFor,
        ),
        onErrorFallback: (err) => ResponsiveText(
          latex,
          style: TextStyle(color: primaryFor),
        ),
      ),
    );
  }
}
