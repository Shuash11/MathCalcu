import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:calculus_system/Finals/Joashua/Evaluating_limits/By_conjugate/solver/solution_steps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class ConjugateStepsView extends StatelessWidget {
  final List<ConjugateStep> steps;

  const ConjugateStepsView({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isCompact = screenWidth < 380;
        final isMedium = screenWidth >= 380 && screenWidth < 600;

        return Column(
          children: steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == steps.length - 1;

            return _ConjugateStepTile(
              step: step,
              isLast: isLast,
              accentColor: FinalsTheme.secondary,
              isCompact: isCompact,
              isMedium: isMedium,
            );
          }).toList(),
        );
      },
    );
  }
}

class _ConjugateStepTile extends StatelessWidget {
  final ConjugateStep step;
  final bool isLast;
  final Color accentColor;
  final bool isCompact;
  final bool isMedium;

  const _ConjugateStepTile({
    required this.step,
    required this.isLast,
    required this.accentColor,
    required this.isCompact,
    required this.isMedium,
  });

  @override
  Widget build(BuildContext context) {
    final stepPaddingBottom = isCompact ? 16.0 : (isMedium ? 18.0 : 20.0);
    final stepIndicatorSize = isCompact ? 28.0 : (isMedium ? 32.0 : 36.0);
    final stepIndicatorFontSize = isCompact ? 12.0 : (isMedium ? 13.0 : 14.0);
    final stepShadowBlur = isCompact ? 6.0 : (isMedium ? 7.0 : 8.0);
    final stepContainerPadding = isCompact ? 12.0 : (isMedium ? 14.0 : 16.0);
    final stepTitleFontSize = isCompact ? 14.0 : (isMedium ? 15.0 : 16.0);
    final stepExplanationFontSize = isCompact ? 12.0 : (isMedium ? 12.5 : 13.0);
    final stepLatexFontSize = isCompact ? 13.0 : (isMedium ? 14.0 : 15.0);

    return Padding(
      padding: EdgeInsets.only(bottom: stepPaddingBottom),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: stepIndicatorSize,
                height: stepIndicatorSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor,
                      accentColor.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.3),
                      blurRadius: stepShadowBlur,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${step.stepNumber}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: stepIndicatorFontSize,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentColor.withValues(alpha: 0.4),
                        accentColor.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(stepContainerPadding),
              decoration: BoxDecoration(
                color: FinalsTheme.card(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: FinalsTheme.titleStyle(context).copyWith(
                      fontSize: stepTitleFontSize,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step.explanation,
                    style: FinalsTheme.subtitleStyle(context).copyWith(
                      fontSize: stepExplanationFontSize,
                      height: 1.4,
                    ),
                  ),
                  if (step.latexExpression != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(stepContainerPadding),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.1),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: _buildLatex(step.latexExpression!, accentColor, fontSize: stepLatexFontSize),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatex(String latex, Color color, {double fontSize = 15}) {
    try {
      return Math.tex(
        latex,
        textStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        onErrorFallback: (err) => Text(
          latex,
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: fontSize,
            color: color,
          ),
        ),
      );
    } catch (e) {
      return Text(
        latex,
        style: TextStyle(
          fontFamily: 'serif',
          fontSize: fontSize,
          color: color,
        ),
      );
    }
  }
}
