import 'package:calculus_system/Finals/Joashua/Derivatives/solvers/derivatives_steps.dart';
import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:flutter/material.dart';

import 'package:calculus_system/Finals/Joashua/Derivatives/solvers/deriviatives_solver.dart'; // Adjust path

class DerivativeStepTile extends StatelessWidget {
  final ClassroomStep step;
  final int index;
  final bool isLast;

  const DerivativeStepTile({
    Key? key,
    required this.step,
    required this.index,
    this.isLast = false,
  }) : super(key: key);

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
                    color: step.type == StepType.finalResult
                        ? FinalsTheme.primary
                        : FinalsTheme.primary.withValues(alpha: 0.15),
                    border: Border.all(
                      color: step.type == StepType.finalResult
                          ? FinalsTheme.primary
                          : FinalsTheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      step.stepNumber.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: step.type == StepType.finalResult
                            ? Colors.white
                            : FinalsTheme.primary,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          FinalsTheme.primary.withValues(alpha: 0.5),
                          FinalsTheme.primary.withValues(alpha: 0.05),
                        ],
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
                  // Title
                  Text(
                    step.title,
                    style:
                        FinalsTheme.titleStyle(context).copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 8),

                  // Rule (if exists)
                  if (step.rule != null) ...[
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
                        step.rule!,
                        style: FinalsTheme.subtitleStyle(context).copyWith(
                          fontStyle: FontStyle.italic,
                          color: FinalsTheme.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Explanation
                  ..._buildExplanationLines(context),

                  const SizedBox(height: 12),

                  // Expression
                  if (step.expression.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: FinalsTheme.cardSecondary(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SelectableText(
                        step.expression,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],

                  // Tip
                  if (step.tip != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: FinalsTheme.tertiary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline,
                              size: 16, color: FinalsTheme.secondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              step.tip!,
                              style:
                                  FinalsTheme.subtitleStyle(context).copyWith(
                                fontSize: 12,
                                color: FinalsTheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExplanationLines(BuildContext context) {
    final lines =
        step.explanation.split('\n').where((l) => l.trim().isNotEmpty).toList();
    return lines
        .map((line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                line.trim(),
                style: FinalsTheme.subtitleStyle(context),
              ),
            ))
        .toList();
  }
}
