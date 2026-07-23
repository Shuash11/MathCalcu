import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:flutter/material.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';

class FactoringAnswerCard extends StatelessWidget {
  final double? answer;
  final String method;
  final bool isShowingSteps;
  final VoidCallback onTap;
  final String? error;

  const FactoringAnswerCard({
    super.key,
    required this.answer,
    required this.method,
    required this.isShowingSteps,
    required this.onTap,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isCompact = screenWidth < 380;
        final isMedium = screenWidth >= 380 && screenWidth < 600;

        return _FactoringAnswerCardContent(
          isCompact: isCompact,
          isMedium: isMedium,
          answer: answer,
          method: method,
          isShowingSteps: isShowingSteps,
          onTap: onTap,
          error: error,
        );
      },
    );
  }
}

class _FactoringAnswerCardContent extends StatelessWidget {
  final bool isCompact;
  final bool isMedium;
  final double? answer;
  final String method;
  final bool isShowingSteps;
  final VoidCallback onTap;
  final String? error;

  const _FactoringAnswerCardContent({
    required this.isCompact,
    required this.isMedium,
    required this.answer,
    required this.method,
    required this.isShowingSteps,
    required this.onTap,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = FinalsTheme.primaryFor(context);

    final cardPadding = isCompact ? 16.0 : (isMedium ? 20.0 : 24.0);
    final statusIconSize = isCompact ? 40.0 : (isMedium ? 44.0 : 48.0);
    final statusIconChildSize = isCompact ? 20.0 : (isMedium ? 22.0 : 24.0);
    final labelFontSize = isCompact ? 10.0 : (isMedium ? 10.5 : 11.0);
    final methodFontSize = isCompact ? 13.0 : (isMedium ? 13.5 : 14.0);
    final expandIconSize = isCompact ? 14.0 : (isMedium ? 15.0 : 16.0);
    final tapHintFontSize = isCompact ? 9.0 : (isMedium ? 9.5 : 10.0);
    final valueDisplayFontSize = isCompact ? 20.0 : (isMedium ? 22.0 : 24.0);
    final valuePaddingH = isCompact ? 12.0 : (isMedium ? 14.0 : 16.0);
    final valuePaddingV = isCompact ? 8.0 : (isMedium ? 9.0 : 10.0);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.only(top: isCompact ? 16.0 : 24.0),
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentColor.withValues(alpha: 0.1),
              accentColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: accentColor.withValues(alpha: isShowingSteps ? 0.6 : 0.2),
            width: isShowingSteps ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  accentColor.withValues(alpha: isShowingSteps ? 0.15 : 0.05),
              blurRadius: isShowingSteps ? 30 : 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _StatusIcon(
                  isShowingSteps: isShowingSteps,
                  accentColor: accentColor,
                  size: statusIconSize,
                  childSize: statusIconChildSize,
                ),
                SizedBox(width: isCompact ? 12.0 : 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ResponsiveText(
                        '',
                        style: FinalsTheme.labelStyle(context).copyWith(
                          color: accentColor,
                          fontSize: labelFontSize,
                        ),
                      ),
                      SizedBox(height: isCompact ? 2.0 : 4.0),
                      Text(
                        method,
                        style: FinalsTheme.subtitleStyle(context).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: methodFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
                _ValueDisplay(
                  answer: answer,
                  error: error,
                  accentColor: accentColor,
                  fontSize: valueDisplayFontSize,
                  paddingH: valuePaddingH,
                  paddingV: valuePaddingV,
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: !isShowingSteps
                  ? Padding(
                      padding: EdgeInsets.only(top: isCompact ? 12.0 : 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.expand_more_rounded,
                              size: expandIconSize,
                              color: accentColor.withValues(alpha: 0.5)),
                          SizedBox(width: isCompact ? 6.0 : 8.0),
                          ResponsiveText(
                            '',
                            style: TextStyle(
                              fontSize: tapHintFontSize,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: accentColor.withValues(alpha: 0.6),
                            ),
                          ),
                          SizedBox(width: isCompact ? 6.0 : 8.0),
                          Icon(Icons.expand_more_rounded,
                              size: expandIconSize,
                              color: accentColor.withValues(alpha: 0.5)),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final bool isShowingSteps;
  final Color accentColor;
  final double size;
  final double childSize;

  const _StatusIcon({
    required this.isShowingSteps,
    required this.accentColor,
    required this.size,
    required this.childSize,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color:
            isShowingSteps ? accentColor : accentColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Icon(
        isShowingSteps ? Icons.auto_awesome_rounded : Icons.check_rounded,
        color: isShowingSteps ? FinalsTheme.onPrimaryFor(context) : accentColor,
        size: childSize,
      ),
    );
  }
}

class _ValueDisplay extends StatelessWidget {
  final double? answer;
  final String? error;
  final Color accentColor;
  final double fontSize;
  final double paddingH;
  final double paddingV;

  const _ValueDisplay({
    required this.answer,
    this.error,
    required this.accentColor,
    required this.fontSize,
    required this.paddingH,
    required this.paddingV,
  });

  @override
  Widget build(BuildContext context) {
    String displayVal = 'Error';
    if (error != null) {
      displayVal = 'Failed';
    } else if (answer == null || answer!.isNaN) {
      displayVal = 'Undefined';
    } else if (answer!.isInfinite) {
      displayVal = answer! > 0 ? '8' : '-8';
    } else {
      displayVal = answer! == answer!.toInt()
          ? answer!.toInt().toString()
          : answer!.toStringAsFixed(4);
    }

    return _buildTextDisplay(displayVal, accentColor, context);
  }

  Widget _buildTextDisplay(
      String displayVal, Color accentColor, BuildContext context) {
    final container = Container(
      padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
      decoration: BoxDecoration(
        color: FinalsTheme.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          displayVal,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: accentColor,
            fontFamily: 'serif',
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
    return Flexible(child: container);
  }
}
