import 'package:flutter/material.dart';
import 'package:calculus_system/Finals/finals_theme.dart';

class LimitsAnswerCard extends StatelessWidget {
  final String problemNotation;
  final String resultString;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback onTap;

  const LimitsAnswerCard({
    super.key,
    required this.problemNotation,
    required this.resultString,
    this.hasError = false,
    this.errorMessage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasError ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: hasError
              ? LinearGradient(
                  colors: [
                    FinalsTheme.danger.withValues(alpha: 0.1),
                    FinalsTheme.danger.withValues(alpha: 0.05)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : FinalsTheme.cardGlow(hovered: true),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasError
                ? FinalsTheme.danger.withValues(alpha: 0.3)
                : FinalsTheme.primary.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: hasError
                  ? FinalsTheme.danger.withValues(alpha: 0.1)
                  : FinalsTheme.primary.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  hasError ? 'Error Occurred' : 'Limit Result',
                  style: FinalsTheme.labelStyle(context).copyWith(
                    color: hasError ? FinalsTheme.danger : null,
                    fontSize: 11,
                  ),
                ),
                if (!hasError)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: FinalsTheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: FinalsTheme.primary,
                      size: 18,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (hasError)
              Text(
                errorMessage ?? 'Invalid input or evaluation error.',
                style: FinalsTheme.subtitleStyle(context)
                    .copyWith(color: FinalsTheme.danger),
              )
            else ...[
              Text(
                problemNotation,
                style: FinalsTheme.subtitleStyle(context).copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: FinalsTheme.surface(context).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "= $resultString",
                  style: FinalsTheme.titleStyle(context).copyWith(
                    fontSize: 22,
                    color: FinalsTheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Tap to view step-by-step solution',
                  style: FinalsTheme.labelStyle(context).copyWith(
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
