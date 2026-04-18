import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:flutter/material.dart';

class ConjugateAnswerCard extends StatelessWidget {
  final String problemNotation;
  final String resultString;
  final String method;
  final bool isShowingSteps;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback onTap;

  const ConjugateAnswerCard({
    super.key,
    required this.problemNotation,
    required this.resultString,
    this.method = 'Conjugate Method',
    this.isShowingSteps = false,
    this.hasError = false,
    this.errorMessage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = FinalsTheme.secondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: FinalsTheme.card(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasError
                ? FinalsTheme.danger.withValues(alpha: 0.4)
                : accentColor.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: hasError
                  ? FinalsTheme.danger.withValues(alpha: 0.1)
                  : accentColor.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: accentColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    method,
                    style: const TextStyle(
                      color: accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  isShowingSteps
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: accentColor,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              problemNotation,
              style: FinalsTheme.subtitleStyle(context).copyWith(
                fontFamily: 'serif',
                fontSize: 15,
                color: FinalsTheme.textSecondary(context),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.linear_scale_rounded,
                  color: accentColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '=',
                  style: TextStyle(
                    color: FinalsTheme.textSecondary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasError ? (errorMessage ?? 'Error') : resultString,
                    style: FinalsTheme.titleStyle(context).copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: hasError ? FinalsTheme.danger : accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
