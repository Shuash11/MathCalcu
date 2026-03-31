import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/slope_theme.dart';
import '../types/slope_solver.dart';

class SlopeStepItem extends StatelessWidget {
  final int number;
  final SlopeStep step;
  final bool isFinal;
  final bool isLast;

  const SlopeStepItem({
    super.key,
    required this.number,
    required this.step,
    this.isFinal = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isFinal) return _FinalBox(step: step);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TimelineRail(number: number, isLast: isLast),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: SlopeTheme.accentColor.withValues(alpha: 0.6),
                      letterSpacing: 0.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: SlopeTheme.cardColor(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: SlopeTheme.accentColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      step.equation,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.watch<ThemeProvider>().textPrimary.withValues(alpha: 0.9),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineRail extends StatelessWidget {
  final int number;
  final bool isLast;

  const _TimelineRail({required this.number, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SlopeTheme.accentColor.withValues(alpha: 0.15),
              border: Border.all(color: SlopeTheme.accentColor, width: 1.5),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: SlopeTheme.accentColor,
                ),
              ),
            ),
          ),
          if (!isLast)
            Expanded(
              child: Container(
                width: 1.5,
                color: SlopeTheme.accentColor.withValues(alpha: 0.2),
                margin: const EdgeInsets.symmetric(vertical: 3),
              ),
            ),
        ],
      ),
    );
  }
}

class _FinalBox extends StatelessWidget {
  final SlopeStep step;

  const _FinalBox({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SlopeTheme.accentColor.withValues(alpha: 0.18),
            SlopeTheme.accentColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: SlopeTheme.accentColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: SlopeTheme.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: SlopeTheme.accentColor.withValues(alpha: 0.35)),
            ),
            child: Text(
              step.label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: SlopeTheme.accentColor,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            step.equation,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.watch<ThemeProvider>().textPrimary,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}