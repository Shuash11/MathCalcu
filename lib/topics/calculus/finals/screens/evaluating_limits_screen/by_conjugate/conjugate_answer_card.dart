import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isCompact = screenWidth < 380;
        final isMedium = screenWidth >= 380 && screenWidth < 600;

        return _ConjugateAnswerCardContent(
          isCompact: isCompact,
          isMedium: isMedium,
          problemNotation: problemNotation,
          resultString: resultString,
          method: method,
          isShowingSteps: isShowingSteps,
          hasError: hasError,
          errorMessage: errorMessage,
          onTap: onTap,
        );
      },
    );
  }
}
class _ConjugateAnswerCardContent extends StatelessWidget {
  final bool isCompact;
  final bool isMedium;
  final String problemNotation;
  final String resultString;
  final String method;
  final bool isShowingSteps;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback onTap;

  const _ConjugateAnswerCardContent({
    required this.isCompact,
    required this.isMedium,
    required this.problemNotation,
    required this.resultString,
    required this.method,
    required this.isShowingSteps,
    required this.hasError,
    this.errorMessage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = FinalsTheme.secondary;

    final cardPadding = isCompact ? 16.0 : (isMedium ? 18.0 : 20.0);
    final methodBadgePaddingH = isCompact ? 8.0 : (isMedium ? 9.0 : 10.0);
    final methodBadgePaddingV = isCompact ? 3.0 : (isMedium ? 3.5 : 4.0);
    final methodFontSize = isCompact ? 10.0 : (isMedium ? 10.5 : 11.0);
    final expandIconSize = isCompact ? 18.0 : (isMedium ? 19.0 : 20.0);
    final problemNotationFontSize = isCompact ? 13.0 : (isMedium ? 14.0 : 15.0);
    final iconSize = isCompact ? 16.0 : (isMedium ? 18.0 : 20.0);
    final equalsFontSize = isCompact ? 16.0 : (isMedium ? 17.0 : 18.0);
    final resultFontSize = isCompact ? 20.0 : (isMedium ? 22.0 : 24.0);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.all(cardPadding),
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
                  padding: EdgeInsets.symmetric(horizontal: methodBadgePaddingH, vertical: methodBadgePaddingV),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: accentColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    method,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: methodFontSize,
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
                  size: expandIconSize,
                ),
              ],
            ),
            SizedBox(height: isCompact ? 12.0 : 16.0),
            Text(
              problemNotation,
              style: FinalsTheme.subtitleStyle(context).copyWith(
                fontFamily: 'serif',
                fontSize: problemNotationFontSize,
                color: FinalsTheme.textSecondary(context),
              ),
            ),
            SizedBox(height: isCompact ? 8.0 : 12.0),
            Row(
              children: [
                Icon(
                  Icons.linear_scale_rounded,
                  color: accentColor,
                  size: iconSize,
                ),
                SizedBox(width: isCompact ? 6.0 : 8.0),
                Text(
                  '=',
                  style: TextStyle(
                    color: FinalsTheme.textSecondary(context),
                    fontSize: equalsFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: isCompact ? 8.0 : 12.0),
                Expanded(
                  child: Text(
                    hasError ? (errorMessage ?? 'Error') : resultString,
                    style: FinalsTheme.titleStyle(context).copyWith(
                      fontSize: resultFontSize,
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
