import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/solutions.dart';
import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:flutter/material.dart';

class LimitsStepTile extends StatelessWidget {
  final SolutionStep step;
  final int index;
  final bool isLast;

  const LimitsStepTile({
    super.key,
    required this.step,
    required this.index,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line & Number
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.type == StepType.conclusion
                        ? FinalsTheme.primary
                        : FinalsTheme.primary.withValues(alpha: 0.15),
                    border: Border.all(
                      color: step.type == StepType.conclusion
                          ? FinalsTheme.primary
                          : FinalsTheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      (index + 1).toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: step.type == StepType.conclusion
                            ? Colors.white
                            : FinalsTheme.primary,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            FinalsTheme.primary.withValues(alpha: 0.5),
                            FinalsTheme.primary.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Step Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title / Description
                  Text(
                    step.description,
                    style:
                        FinalsTheme.titleStyle(context).copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 8),

                  // Formula (if exists)
                  if (step.formula != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: FinalsTheme.secondary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: FinalsTheme.secondary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Using: ${step.formula!}',
                        style: FinalsTheme.subtitleStyle(context).copyWith(
                          fontStyle: FontStyle.italic,
                          color: FinalsTheme.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Explanation
                  if (step.explanation != null)
                    Text(
                      step.explanation!,
                      style: FinalsTheme.subtitleStyle(context),
                    ),

                  const SizedBox(height: 12),

                  // Expression
                  if (step.expression != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: FinalsTheme.cardSecondary(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SelectableText(
                        step.expression.toString(),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
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
}
