import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:flutter/material.dart';

class LCDAnswerCard extends StatelessWidget {
  final double? answer;
  final String method;
  final bool isShowingSteps;
  final VoidCallback onTap;

  const LCDAnswerCard({
    super.key,
    required this.answer,
    required this.method,
    required this.isShowingSteps,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = FinalsTheme.danger;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.all(24),
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
              color: accentColor.withValues(alpha: isShowingSteps ? 0.15 : 0.05),
              blurRadius: isShowingSteps ? 30 : 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _StatusIcon(isShowingSteps: isShowingSteps, accentColor: accentColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FINAL ANSWER',
                        style: FinalsTheme.labelStyle(context).copyWith(
                          color: accentColor,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        method,
                        style: FinalsTheme.subtitleStyle(context).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _ValueDisplay(answer: answer, accentColor: accentColor),
              ],
            ),
            
            // Interaction hint
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: !isShowingSteps
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.expand_more_rounded, size: 16, color: accentColor.withValues(alpha: 0.5)),
                          const SizedBox(width: 8),
                          Text(
                            'TAP TO REVEAL SOLUTIONS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: accentColor.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.expand_more_rounded, size: 16, color: accentColor.withValues(alpha: 0.5)),
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

  const _StatusIcon({required this.isShowingSteps, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isShowingSteps ? accentColor : accentColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Icon(
        isShowingSteps ? Icons.auto_awesome_rounded : Icons.check_rounded,
        color: isShowingSteps ? Colors.white : accentColor,
        size: 24,
      ),
    );
  }
}

class _ValueDisplay extends StatelessWidget {
  final double? answer;
  final Color accentColor;

  const _ValueDisplay({required this.answer, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final String displayVal = answer == null
        ? 'Undefined'
        : (answer! == answer!.toInt() ? answer!.toInt().toString() : answer!.toStringAsFixed(4));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
      child: Text(
        displayVal,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: accentColor,
          fontFamily: 'serif',
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
