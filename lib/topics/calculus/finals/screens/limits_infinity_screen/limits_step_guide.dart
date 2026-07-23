import 'package:flutter/material.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';

class LimitsStepGuide extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? mathExpression;
  final String? explanation;
  final bool isConclusion;
  final int stepNumber;

  const LimitsStepGuide({
    super.key,
    required this.title,
    this.subtitle,
    this.mathExpression,
    this.explanation,
    this.isConclusion = false,
    required this.stepNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step header
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isConclusion
                      ? FinalsTheme.primaryFor(context)
                      : FinalsTheme.primaryFor(context).withValues(alpha: 0.1),
                ),
                child: Center(
                  child: isConclusion
                      ? Icon(Icons.check,
                          size: 16, color: FinalsTheme.onPrimaryFor(context))
                      : Text(
                          '$stepNumber',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: FinalsTheme.primaryFor(context),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: FinalsTheme.titleStyle(context).copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color:
                        isConclusion ? FinalsTheme.primaryFor(context) : null,
                  ),
                ),
              ),
            ],
          ),

          // Step content (indented)
          if (subtitle != null || mathExpression != null || explanation != null)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtitle (optional)
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        subtitle!,
                        style: FinalsTheme.subtitleStyle(context).copyWith(
                          fontSize: 13,
                          color: FinalsTheme.primaryFor(context)
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ),

                  // Math expression (optional)
                  if (mathExpression != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: FinalsTheme.cardSecondary(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: FinalsTheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: _buildMathDisplay(context, mathExpression!),
                    ),

                  // Short explanation (optional)
                  if (explanation != null)
                    Text(
                      _formatText(explanation!),
                      style: FinalsTheme.subtitleStyle(context).copyWith(
                        fontSize: 13,
                        height: 1.5,
                        color: FinalsTheme.primaryFor(context)
                            .withValues(alpha: 0.8),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMathDisplay(BuildContext context, String expr) {
    final latex = _toLatex(expr);

    try {
      return Math.tex(
        latex,
        textStyle: TextStyle(
          fontSize: 15,
          color: FinalsTheme.primaryFor(context),
          fontWeight: FontWeight.w500,
        ),
        onErrorFallback: (error) {
          return Text(
            expr,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          );
        },
      );
    } catch (e) {
      return Text(
        expr,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'monospace',
        ),
      );
    }
  }

  String _toLatex(String expr) {
    return expr
        .replaceAll('*', ' \\cdot ')
        .replaceAllMapped(
            RegExp(r'(\w+)\s*\^\s*(\d+)'), (m) => '${m[1]}^{${m[2]}}')
        .replaceAll('x ^ 2', 'x^{2}')
        .replaceAll('x ^ 3', 'x^{3}')
        .replaceAll('x ^ 4', 'x^{4}')
        .replaceAllMapped(
            RegExp(r'(\d+)\s*\^\s*(\d+)'), (m) => '${m[1]}^{${m[2]}}')
        .replaceAllMapped(RegExp(r'([^\s]+)\s*/\s*([^\s]+)'),
            (m) => '\\frac{${m[1]}}{${m[2]}}');
  }

  String _formatText(String text) {
    return text
        .replaceAll('\\infty', '8')
        .replaceAll('\\lim', 'lim')
        .replaceAll('\\rightarrow', '?')
        .replaceAll('\\cdot', '?')
        .replaceAll('x^2', 'x?')
        .replaceAll('x^3', 'x³')
        .replaceAll('x^4', 'x4')
        .replaceAllMapped(
            RegExp(r'(\d+)\^(\d+)'), (m) => '${m[1]}${_superscript(m[2]!)}');
  }

  String _superscript(String num) {
    const superscripts = {
      '0': '°',
      '1': '¹',
      '2': '?',
      '3': '³',
      '4': '4',
      '5': '5',
      '6': '6',
      '7': '7',
      '8': '8',
      '9': '?'
    };
    return num.split('').map((c) => superscripts[c] ?? c).join('');
  }
}
