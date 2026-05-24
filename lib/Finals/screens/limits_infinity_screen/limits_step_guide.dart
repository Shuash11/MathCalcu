import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:calculus_system/Finals/finals_theme.dart';

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
                      ? FinalsTheme.primary
                      : FinalsTheme.primary.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: isConclusion
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          '$stepNumber',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: FinalsTheme.primary,
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
                    color: isConclusion ? FinalsTheme.primary : null,
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
                          color: FinalsTheme.primary.withValues(alpha: 0.7),
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
                      child: _buildMathDisplay(mathExpression!),
                    ),

                  // Short explanation (optional)
                  if (explanation != null)
                    Text(
                      _formatText(explanation!),
                      style: FinalsTheme.subtitleStyle(context).copyWith(
                        fontSize: 13,
                        height: 1.5,
                        color: FinalsTheme.primary.withValues(alpha: 0.8),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMathDisplay(String expr) {
    final latex = _toLatex(expr);

    try {
      return Math.tex(
        latex,
        textStyle: const TextStyle(
          fontSize: 15,
          color: FinalsTheme.primary,
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
        .replaceAll('\\infty', '∞')
        .replaceAll('\\lim', 'lim')
        .replaceAll('\\rightarrow', '→')
        .replaceAll('\\cdot', '·')
        .replaceAll('x^2', 'x²')
        .replaceAll('x^3', 'x³')
        .replaceAll('x^4', 'x⁴')
        .replaceAllMapped(
            RegExp(r'(\d+)\^(\d+)'), (m) => '${m[1]}${_superscript(m[2]!)}');
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
}
