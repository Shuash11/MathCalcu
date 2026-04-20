import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class LCDAnswerCard extends StatelessWidget {
  final double? answer;
  final String? fractionalAnswer;
  final String method;
  final bool isShowingSteps;
  final VoidCallback onTap;

  const LCDAnswerCard({
    super.key,
    required this.answer,
    this.fractionalAnswer,
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
                _ValueDisplay(
                  answer: answer,
                  fractionalAnswer: fractionalAnswer,
                  accentColor: accentColor,
                ),
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
  final String? fractionalAnswer;
  final Color accentColor;

  const _ValueDisplay({
    required this.answer,
    this.fractionalAnswer,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (answer == null || answer!.isNaN) {
      return _buildTextDisplay('Undefined', accentColor, context, wrapFlexible: true);
    }

    if (fractionalAnswer != null && 
        (fractionalAnswer!.contains(r'\frac') || fractionalAnswer!.contains(r'\approx'))) {
      final parts = fractionalAnswer!.split(r'\approx');
      if (parts.length > 1) {
        return Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Math.tex(
                parts[0].trim(),
                textStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: accentColor,
                ),
                onErrorFallback: (err) => Text(
                  parts[0].trim(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '≈ ${parts[1].trim()}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: accentColor.withValues(alpha: 0.7),
                  fontFamily: 'serif',
                ),
              ),
            ],
          ),
        );
      }
      return Flexible(
        child: Container(
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
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Math.tex(
              fractionalAnswer!,
              textStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: accentColor,
              ),
              onErrorFallback: (err) => _buildTextDisplay(_formatAnswer(answer!), accentColor, context, wrapFlexible: false),
            ),
          ),
        ),
      );
    }

    return _buildTextDisplay(_formatAnswer(answer!), accentColor, context, wrapFlexible: true);
  }

  String _formatAnswer(double val) {
    if (!val.isFinite) {
      return val.isInfinite ? (val > 0 ? '∞' : '-∞') : 'Undefined';
    }
    if (val == val.toInt()) {
      return val.toInt().toString();
    }
    return val.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  Widget _buildTextDisplay(String displayVal, Color accentColor, BuildContext context, {required bool wrapFlexible}) {
    final container = Container(
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
      child: FittedBox(
        fit: BoxFit.scaleDown,
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
      ),
    );
    return wrapFlexible ? Flexible(child: container) : container;
  }
}
