import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class LCDStepsView extends StatelessWidget {
  final List<String> steps;

  const LCDStepsView({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        return _StepTile(
          step: steps[index],
          index: index,
          isLast: index == steps.length - 1,
        );
      },
    );
  }
}

class _StepTile extends StatelessWidget {
  final String step;
  final int index;
  final bool isLast;

  const _StepTile({
    required this.step,
    required this.index,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = FinalsTheme.danger;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      (index + 1).toString(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: accentColor.withValues(alpha: 0.15),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Step content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FormattedStepText(text: step),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormattedStepText extends StatelessWidget {
  final String text;

  const _FormattedStepText({required this.text});

  @override
  Widget build(BuildContext context) {
    // Basic heuristic to identify math snippets in the step string
    // This is a simple implementation that looks for parts enclosed in brackets [] or containing math operators
    
    // For this module, we'll try to detect if a line is primarily math or contains math blocks.
    // The StepGenerator in steps.dart uses brackets [] for some math parts sometimes, 
    // but often it's just raw strings.
    
    bool isMath = _isMathExpression(text);

    if (isMath) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: FinalsTheme.cardSecondary(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: FinalsTheme.danger.withValues(alpha: 0.1)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Math.tex(
            _convertToTex(text),
            textStyle: FinalsTheme.titleStyle(context).copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            onErrorFallback: (err) => Text(text),
          ),
        ),
      );
    }

    return Text(
      text,
      style: FinalsTheme.subtitleStyle(context).copyWith(
        fontSize: 14,
        color: FinalsTheme.textPrimary(context).withValues(alpha: 0.9),
        height: 1.5,
      ),
    );
  }

  bool _isMathExpression(String line) {
    // If it contains specific LCD keywords and looks algebraic
    if (line.contains('/') && (line.contains('x') || line.contains('('))) {
        // If it's short and full of operators, it's likely math
        if (line.length < 50 && RegExp(r'[+\-*/^=]').hasMatch(line)) return true;
    }
    return line.contains('→') || line.startsWith('Numerator') || line.contains('LCD is');
  }

  String _convertToTex(String text) {
    // Simple replacements to make the text look more like LaTeX
    // In a real app, the StepGenerator should return proper LaTeX
    String tex = text;
    tex = tex.replaceAll('*', r'\cdot ');
    // Handle simple fractions like 1/x -> \frac{1}{x}
    // This is very limited, but works for the current StepGenerator's output style
    return tex;
  }
}
