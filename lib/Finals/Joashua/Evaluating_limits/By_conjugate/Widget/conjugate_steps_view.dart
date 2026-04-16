import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:calculus_system/Finals/Joashua/Evaluating_limits/By_Conjugate/solver/solution_steps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class ConjugateStepsView extends StatelessWidget {
  final List<ConjugateStep> steps;

  const ConjugateStepsView({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isLast = index == steps.length - 1;

        return _ConjugateStepTile(
          step: step,
          isLast: isLast,
          accentColor: FinalsTheme.secondary,
        );
      }).toList(),
    );
  }
}

class _ConjugateStepTile extends StatelessWidget {
  final ConjugateStep step;
  final bool isLast;
  final Color accentColor;

  const _ConjugateStepTile({
    required this.step,
    required this.isLast,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
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
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${step.stepNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
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
              padding: const EdgeInsets.all(16),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step.explanation,
                    style: FinalsTheme.subtitleStyle(context).copyWith(
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  if (step.latexExpression != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
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
                        child: _buildLatex(step.latexExpression!, accentColor),
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

  Widget _buildLatex(String latex, Color color) {
    try {
      return Math.tex(
        latex,
        textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        onErrorFallback: (err) => Text(
          latex,
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 14,
            color: color,
          ),
        ),
      );
    } catch (e) {
      return Text(
        latex,
        style: TextStyle(
          fontFamily: 'serif',
          fontSize: 14,
          color: color,
        ),
      );
    }
  }
}
