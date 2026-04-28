import 'package:calculus_system/Finals/Joashua/Limits_Infinity/solver/solutions.dart';
import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

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
    return Stack(
      children: [
        // Timeline Line
        if (!isLast)
          Positioned(
            left: 14, // Center of the 28px circle
            top: 28,
            bottom: 0,
            child: Container(
              width: 2,
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

        // Step Content Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number Circle
            SizedBox(
              width: 28,
              height: 28,
              child: Container(
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
                        child: _buildMathExpression(step.formula!),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Explanation
                    if (step.explanation != null)
                      Builder(
                        builder: (ctx) => Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: FinalsTheme.cardSecondary(ctx),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: FinalsTheme.primary.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Text(
                            _formatExplanation(step.explanation!),
                            style: FinalsTheme.subtitleStyle(ctx)
                                .copyWith(height: 1.5),
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Expression
                    if (step.expression != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: FinalsTheme.cardSecondary(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: FinalsTheme.primary.withValues(alpha: 0.15),
                          ),
                        ),
                        child: _buildMathExpression(step.expression.toString()),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatExplanation(String text) {
    var formatted = text
        .replaceAll('\\frac{', '⟪')
        .replaceAll('}', '⟫')
        .replaceAll('\\infty', '∞')
        .replaceAll('\\lim', 'lim')
        .replaceAll('\\rightarrow', '→')
        .replaceAll('\\cdot', '·')
        .replaceAll('x^2', 'x²')
        .replaceAll('x^3', 'x³')
        .replaceAll('x^4', 'x⁴')
        .replaceAllMapped(
            RegExp(r'(\d+)\^(\d+)'), (m) => '${m[1]}${_superscript(m[2]!)}');
    return formatted;
  }

  String _superscript(String num) {
    const superscripts = {
      '0': '⁰',
      '1': '¹',
      '2': '²',
      '3': '³',
      '4': '⁴',
      '5': '⁵',
      '6': '⁶',
      '7': '⁷',
      '8': '⁸',
      '9': '⁹'
    };
    return num.split('').map((c) => superscripts[c] ?? c).join('');
  }

  Widget _buildMathExpression(String expression) {
    final latex = _convertToLatex(expression);

    try {
      return Math.tex(
        latex,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        onErrorFallback: (error) {
          return SelectableText(
            expression,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      );
    } catch (e) {
      return SelectableText(
        expression,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      );
    }
  }

  String _convertToLatex(String expr) {
    var result = expr
        .replaceAll('*', ' \\cdot ')
        .replaceAll('+', ' + ')
        .replaceAll(' - ', ' - ')
        .replaceAll(' / ', ' / ')
        .replaceAllMapped(
            RegExp(r'(\w+)\s*\^\s*(\d+)'), (m) => '${m[1]}^{${m[2]}}')
        .replaceAll('x ^ 2', 'x^{2}')
        .replaceAll('x ^ 3', 'x^{3}')
        .replaceAll('x ^ 4', 'x^{4}')
        .replaceAllMapped(
            RegExp(r'(\d+)\s*\^\s*(\d+)'), (m) => '${m[1]}^{${m[2]}}');

    // Handle division - convert a/b to \frac{a}{b}
    result = _convertDivision(result);

    return result;
  }

  String _convertDivision(String expr) {
    // Match pattern: something / something
    final fractionRegex = RegExp(r'([^\s+-]+)\s*/\s*([^\s+-]+)');
    return expr.replaceAllMapped(fractionRegex, (match) {
      return '\\frac{${match[1]}}{${match[2]}}';
    });
  }
}
