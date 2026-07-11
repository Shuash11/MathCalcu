import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 380;
    const accentColor = FinalsTheme.danger;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(top: 24),
        padding: EdgeInsets.all(isCompact ? 16 : 24),
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
                _StatusIcon(isShowingSteps: isShowingSteps, accentColor: accentColor, size: isCompact ? 40 : 48),
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
  final double size;

  const _StatusIcon({required this.isShowingSteps, required this.accentColor, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
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
        size: size * 0.5,
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

    // Always use fractionalAnswer if provided - this is the authoritative answer from steps.dart
    if (fractionalAnswer != null) {
      // Handle approximation notation (exact ≠ˆ decimal)
      if (fractionalAnswer!.contains(r'\approx')) {
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
                  '≠ˆ ${parts[1].trim()}',
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
      }
      
      // Display fractionalAnswer as-is (whether it's a fraction, constant, or other format)
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
            child: fractionalAnswer!.contains(r'\frac') || fractionalAnswer!.contains(r'\sqrt')
                ? Math.tex(
                    fractionalAnswer!,
                    textStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                    ),
                    onErrorFallback: (err) => Text(
                      fractionalAnswer!,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                        fontFamily: 'serif',
                      ),
                    ),
                  )
                : Text(
                    fractionalAnswer!,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                      fontFamily: 'serif',
                      letterSpacing: -0.5,
                    ),
                  ),
          ),
        ),
      );
    }

    // Fallback: if no fractionalAnswer, format the numerical answer
    return _buildTextDisplay(_formatAnswer(answer!), accentColor, context, wrapFlexible: true);
  }

  String _formatAnswer(double val) {
    if (!val.isFinite) {
      return val.isInfinite ? (val > 0 ? '∞' : '-∞') : 'Undefined';
    }
    if (val == val.toInt()) {
      return val.toInt().toString();
    }
    
    // Try to find a good fraction representation
    final absVal = val.abs();
    for (int d = 1; d <= 1000; d++) {
      final n = absVal * d;
      if ((n - n.round()).abs() < 1e-4) {
        final num = n.round();
        int numerator = num;
        int denominator = d;
        int gcd = _gcd(numerator, denominator);
        numerator = numerator ~/ gcd;
        denominator = denominator ~/ gcd;
        if (denominator == 1) {
          return val < 0 ? "-$numerator" : "$numerator";
        }
        return "${val < 0 ? '-' : ''}\\frac{$numerator}{$denominator}";
      }
    }
    
    // Fallback: try higher tolerance range
    for (int d = 1001; d <= 10000; d += 100) {
      final n = absVal * d;
      if ((n - n.round()).abs() < 1.0) {
        final num = n.round();
        int numerator = num;
        int denominator = d;
        int gcd = _gcd(numerator, denominator);
        numerator = numerator ~/ gcd;
        denominator = denominator ~/ gcd;
        if (denominator <= 1000 && denominator > 1) {
          return "${val < 0 ? '-' : ''}\\frac{$numerator}{$denominator}";
        }
      }
    }
    
    // Absolute last resort: return as integer if very close
    final rounded = val.round();
    if ((val - rounded).abs() < 0.01) {
      return rounded.toInt().toString();
    }
    
    // Never return decimals - return the value as-is in string form without decimal places
    return val.toInt().toString();
  }

  static int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
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
        child: displayVal.contains(r'\frac')
            ? Math.tex(
                displayVal,
                textStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: accentColor,
                ),
                onErrorFallback: (err) => Text(
                  displayVal,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                    fontFamily: 'serif',
                    letterSpacing: -0.5,
                  ),
                ),
              )
            : Text(
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
