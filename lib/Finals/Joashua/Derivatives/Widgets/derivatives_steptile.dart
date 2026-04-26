import 'package:calculus_system/Finals/Joashua/Derivatives/solvers/derivatives_steps.dart';
import 'package:calculus_system/Finals/Joashua/Derivatives/solvers/deriviatives_solver.dart';
import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class DerivativeStepTile extends StatelessWidget {
  final ClassroomStep step;
  final int index;
  final bool isLast;

  const DerivativeStepTile({
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
                  Expanded(
                    child: Container(
                      width: 2,
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

                  // Rule formula (for identifyRule steps)
                  if (step.type == StepType.identifyRule && step.rule != null) ...[
                    _buildRuleFormula(context),
                    const SizedBox(height: 12),
                  ],

                  // Explanation (skip for simplify steps - TASK D)
                  if (step.type != StepType.simplify)
                    ..._buildExplanationLines(context),

                  const SizedBox(height: 12),

                  // Expression (rendered as LaTeX - scales to fit)
                  if (step.expression.toString().isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: FinalsTheme.cardSecondary(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: _buildLatex(_toLatex(step.expression.toString()), context),
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
                          const Icon(Icons.lightbulb_outline,
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

  Widget _buildRuleFormula(BuildContext context) {
    final colonIndex = step.rule!.indexOf(':');
    final formula = colonIndex != -1 ? step.rule!.substring(colonIndex + 1).trim() : '';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: FinalsTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(
            color: FinalsTheme.primary,
            width: 3,
          ),
        ),
      ),
      child: _buildLatex(formula, context),
    );
  }

  Widget _buildLatex(String tex, BuildContext ctx) {
    if (tex.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SelectableMath.tex(
        tex,
        textStyle: TextStyle(
          fontSize: 14,
          color: FinalsTheme.textPrimary(ctx),
        ),
      ),
    );
  }

  String _toLatex(String expr) {
    return expr
        .replaceAll('/', r' \frac{}{')
        .replaceAllMapped(RegExp(r'(\w+)\^(\d+)'), (m) => '^{${m[2]}}')
        .replaceAll('sqrt(', r'\sqrt{')
        .replaceAll('sin(', r'\sin{')
        .replaceAll('cos(', r'\cos{')
        .replaceAll('tan(', r'\tan{')
        .replaceAll('ln(', r'\ln{')
        .replaceAll('exp(', r'\exp{')
        .replaceAllMapped(RegExp(r'(\w)\)'), (m) => '${m[1]}}');
  }
}
