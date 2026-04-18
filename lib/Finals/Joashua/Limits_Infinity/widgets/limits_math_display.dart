import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:calculus_system/Finals/finals_theme.dart';

class LimitsMathDisplay extends StatelessWidget {
  final String latex;
  final double fontSize;
  final Color? textColor;
  final TextAlign textAlign;

  const LimitsMathDisplay({
    super.key,
    required this.latex,
    this.fontSize = 16,
    this.textColor,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? FinalsTheme.primary;
    final parsedLatex = _parseLatex(latex);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Math.tex(
        parsedLatex,
        textStyle: TextStyle(
          fontSize: fontSize,
          color: color,
        ),
        onErrorFallback: (error) {
          return Text(
            latex,
            style: TextStyle(
              fontSize: fontSize,
              color: color,
              fontFamily: 'monospace',
            ),
            textAlign: textAlign,
          );
        },
      ),
    );
  }

  String _parseLatex(String text) {
    return text
        .replaceAll('∞', '\\infty')
        .replaceAll('→', '\\rightarrow')
        .replaceAll('·', '\\cdot')
        .replaceAll('∑', '\\sum')
        .replaceAll('∫', '\\int')
        .replaceAll('√', '\\sqrt')
        .replaceAll('±', '\\pm')
        .replaceAll('≠', '\\neq')
        .replaceAll('≤', '\\leq')
        .replaceAll('≥', '\\geq')
        .replaceAll('²', '^2')
        .replaceAll('³', '^3')
        .replaceAll('⁴', '^4')
        .replaceAll('⁵', '^5')
        .replaceAll('⁶', '^6')
        .replaceAll('⁷', '^7')
        .replaceAll('⁸', '^8')
        .replaceAll('⁹', '^9')
        .replaceAll('⁰', '^0')
        .replaceAll('¹', '^1');
  }
}

class LimitsSolutionStep extends StatelessWidget {
  final String title;
  final String? description;
  final String? latexExpression;
  final String? explanation;
  final SolutionStepType type;
  final int stepIndex;

  const LimitsSolutionStep({
    super.key,
    required this.title,
    this.description,
    this.latexExpression,
    this.explanation,
    this.type = SolutionStepType.normal,
    required this.stepIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(context),
          const SizedBox(width: 16),
          Expanded(
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context) {
    final isConclusion = type == SolutionStepType.conclusion;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isConclusion
                ? FinalsTheme.primary
                : FinalsTheme.primary.withValues(alpha: 0.1),
            border: Border.all(
              color:
                  FinalsTheme.primary.withValues(alpha: isConclusion ? 1 : 0.5),
              width: 2,
            ),
          ),
          child: Center(
            child: isConclusion
                ? Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Colors.white,
                  )
                : Text(
                    '${stepIndex + 1}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: FinalsTheme.primary,
                    ),
                  ),
          ),
        ),
        if (type != SolutionStepType.conclusion)
          Container(
            width: 2,
            height: 60,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  FinalsTheme.primary.withValues(alpha: 0.5),
                  FinalsTheme.primary.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: FinalsTheme.titleStyle(context).copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description!,
            style: FinalsTheme.subtitleStyle(context).copyWith(
              fontSize: 13,
              color: FinalsTheme.primary.withValues(alpha: 0.7),
            ),
          ),
        ],
        if (latexExpression != null) ...[
          const SizedBox(height: 12),
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
            child: LimitsMathDisplay(
              latex: latexExpression!,
              fontSize: 18,
            ),
          ),
        ],
        if (explanation != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: FinalsTheme.cardSecondary(context).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: FinalsTheme.primary.withValues(alpha: 0.08),
              ),
            ),
            child: Text(
              _formatText(explanation!),
              style: FinalsTheme.subtitleStyle(context).copyWith(
                height: 1.6,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatText(String text) {
    return text
        .replaceAll('\\frac{', '⟪')
        .replaceAll('}', '⟫')
        .replaceAll('\\infty', '∞')
        .replaceAll('\\lim', 'lim')
        .replaceAll('\\rightarrow', '→')
        .replaceAll('\\cdot', '·');
  }
}

enum SolutionStepType {
  normal,
  conclusion,
  formula,
  error,
}
