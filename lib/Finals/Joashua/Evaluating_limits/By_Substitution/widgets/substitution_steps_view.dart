import 'package:calculus_system/Finals/Joashua/Evaluating_limits/By_Substitution/solver/substitution_steps.dart';
import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class SubstitutionStepsView extends StatelessWidget {
  final List<SolutionStep> steps;

  const SubstitutionStepsView({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        return _StepTile(
          step: steps[index],
          index: index,
          isLast: index == steps.length - 1,
        );
      },
    );
  }
}

class _StepTile extends StatelessWidget {
  final SolutionStep step;
  final int index;
  final bool isLast;

  const _StepTile({
    required this.step,
    required this.index,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = FinalsTheme.primary;

    return Stack(
      children: [
        // Timeline line
        if (!isLast)
          Positioned(
            left: 15.25,
            top: 28,
            bottom: 4,
            child: Container(
              width: 1.5,
              color: accentColor.withValues(alpha: 0.15),
            ),
          ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            SizedBox(
              width: 32,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: accentColor.withValues(alpha: 0.4), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    (index + 1).toString(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Step content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: FinalsTheme.titleStyle(context).copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: FinalsTheme.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _FormattedStepContent(text: step.explanation, mathExpression: step.mathExpression),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FormattedStepContent extends StatelessWidget {
  final String text;
  final String? mathExpression;

  const _FormattedStepContent({required this.text, this.mathExpression});

  @override
  Widget build(BuildContext context) {
    const accentColor = FinalsTheme.primary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: FinalsTheme.subtitleStyle(context).copyWith(
            fontSize: 14,
            color: FinalsTheme.textPrimary(context).withValues(alpha: 0.8),
            height: 1.4,
          ),
        ),
        if (mathExpression != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FinalsTheme.cardSecondary(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.1),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Math.tex(
                mathExpression!,
                textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
                onErrorFallback: (err) => Text(
                  mathExpression!,
                  style: const TextStyle(fontFamily: 'serif', color: accentColor),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
