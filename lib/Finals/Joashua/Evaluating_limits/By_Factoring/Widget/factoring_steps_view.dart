import 'package:calculus_system/Finals/Joashua/Evaluating_limits/By_Factoring/solvers/solution_steps.dart';
import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class FactoringStepsView extends StatelessWidget {
  final List<SolutionStep> steps;

  const FactoringStepsView({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isCompact = screenWidth < 380;
        final isMedium = screenWidth >= 380 && screenWidth < 600;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: steps.length,
          itemBuilder: (context, index) {
            return _StepTile(
              step: steps[index],
              index: index,
              isLast: index == steps.length - 1,
              isCompact: isCompact,
              isMedium: isMedium,
            );
          },
        );
      },
    );
  }
}

class _StepTile extends StatelessWidget {
  final SolutionStep step;
  final int index;
  final bool isLast;
  final bool isCompact;
  final bool isMedium;

  const _StepTile({
    required this.step,
    required this.index,
    required this.isLast,
    required this.isCompact,
    required this.isMedium,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = FinalsTheme.primary;

    final stepIndicatorSize = isCompact ? 24.0 : (isMedium ? 28.0 : 32.0);
    final stepIndicatorFontSize = isCompact ? 10.0 : (isMedium ? 11.0 : 12.0);
    final stepTitleFontSize = isCompact ? 14.0 : (isMedium ? 15.0 : 16.0);
    final stepExplanationFontSize = isCompact ? 12.0 : (isMedium ? 13.0 : 14.0);
    final stepContainerPadding = isCompact ? 12.0 : (isMedium ? 14.0 : 16.0);
    final stepLatexFontSize = isCompact ? 13.0 : (isMedium ? 14.0 : 15.0);
    final stepPaddingBottom = isCompact ? 16.0 : (isMedium ? 20.0 : 24.0);
    final timelineLeft = isCompact ? 12.0 : (isMedium ? 14.0 : 15.25);

    return Stack(
      children: [
        if (!isLast)
          Positioned(
            left: timelineLeft,
            top: stepIndicatorSize + 4,
            bottom: 4,
            child: Container(
              width: 1.5,
              color: accentColor.withValues(alpha: 0.15),
            ),
          ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: stepIndicatorSize + (isCompact ? 4 : 8),
              child: Container(
                width: stepIndicatorSize,
                height: stepIndicatorSize,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: accentColor.withValues(alpha: 0.4), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    (index + 1).toString(),
                    style: TextStyle(
                      fontSize: stepIndicatorFontSize,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: isCompact ? 12.0 : 16.0),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: stepPaddingBottom),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: FinalsTheme.titleStyle(context).copyWith(
                        fontSize: stepTitleFontSize,
                        fontWeight: FontWeight.w700,
                        color: FinalsTheme.textPrimary(context),
                      ),
                    ),
                    SizedBox(height: isCompact ? 6.0 : 8.0),
                    _FormattedStepContent(
                      text: step.explanation,
                      mathExpression: step.mathematicalExpression,
                      isCompact: isCompact,
                      isMedium: isMedium,
                      latexFontSize: stepLatexFontSize,
                      containerPadding: stepContainerPadding,
                      explanationFontSize: stepExplanationFontSize,
                    ),
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
  final bool isCompact;
  final bool isMedium;
  final double latexFontSize;
  final double containerPadding;
  final double explanationFontSize;

  const _FormattedStepContent({
    required this.text,
    this.mathExpression,
    required this.isCompact,
    required this.isMedium,
    required this.latexFontSize,
    required this.containerPadding,
    required this.explanationFontSize,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = FinalsTheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: FinalsTheme.subtitleStyle(context).copyWith(
            fontSize: explanationFontSize,
            color: FinalsTheme.textPrimary(context).withValues(alpha: 0.8),
            height: 1.4,
          ),
        ),
        if (mathExpression != null) ...[
          SizedBox(height: isCompact ? 8.0 : 12.0),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(containerPadding),
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
                  fontSize: latexFontSize,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
                onErrorFallback: (err) => Text(
                  mathExpression!,
                  style: TextStyle(fontFamily: 'serif', color: accentColor, fontSize: latexFontSize),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}