import 'package:calculus_system/modules/circles/center_raidus_form/Theme/center_radius_theme.dart';
import 'package:calculus_system/modules/circles/center_raidus_form/solver/center_radius_solver.dart';
import 'package:flutter/material.dart';

class StepTile extends StatelessWidget {
  final SolverStep step;
  final int index;
  final bool isLast;

  const StepTile({
    super.key,
    required this.step,
    required this.index,
    required this.isLast,
  });

  Color _resolveColor(SolverColors? c) {
    return switch (c) {
      SolverColors.teal => FindingCenterRadiusTheme.teal,
      SolverColors.cyan => FindingCenterRadiusTheme.cyan,
      null => FindingCenterRadiusTheme.textSecondary.withValues(alpha: 0.4),
    };
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _resolveColor(step.color);

    if (step.isFinal) return _FinalBox(step: step, accentColor: accentColor);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TimelineRail(
              accentColor: accentColor,
              label: step.arrow ? '★' : '${index + 1}',
              isArrow: step.arrow,
              isLast: isLast),
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
                      color: FindingCenterRadiusTheme.textSecondary
                          .withValues(alpha: 0.55),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: FindingCenterRadiusTheme.inputBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: accentColor.withValues(alpha: 0.15)),
                    ),
                    child: Text(
                      step.equation,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: step.color != null
                            ? accentColor
                            : FindingCenterRadiusTheme.textPrimary
                                .withValues(alpha: 0.9),
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
  final Color accentColor;
  final String label;
  final bool isArrow;
  final bool isLast;

  const _TimelineRail({
    required this.accentColor,
    required this.label,
    required this.isArrow,
    required this.isLast,
  });

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
              color: accentColor.withValues(alpha: 0.15),
              border: Border.all(color: accentColor, width: 1.5),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isArrow ? 8 : 9,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ),
          ),
          if (!isLast)
            Expanded(
              child: Container(
                width: 1.5,
                color: accentColor.withValues(alpha: 0.2),
                margin: const EdgeInsets.symmetric(vertical: 3),
              ),
            ),
        ],
      ),
    );
  }
}

class _FinalBox extends StatelessWidget {
  final SolverStep step;
  final Color accentColor;

  const _FinalBox({required this.step, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.18),
            accentColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: accentColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentColor.withValues(alpha: 0.35)),
            ),
            child: Text(
              step.label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: accentColor,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            step.equation,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: accentColor,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
          ),
          if (step.subLines.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              height: 1,
              color: FindingCenterRadiusTheme.textSecondary
                  .withValues(alpha: 0.15),
            ),
            const SizedBox(height: 12),
            ...step.subLines.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  s,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: FindingCenterRadiusTheme.textPrimary
                        .withValues(alpha: 0.85),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
