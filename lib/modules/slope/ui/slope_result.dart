import 'package:calculus_system/modules/slope/theme/slope_theme.dart';
import 'package:calculus_system/modules/slope/types/slope_solver.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// SLOPE RESULT CARDS
//
// Three public widgets exported from this file:
//   • SlopeAnswerCard      – shows single-line slope result
//   • SlopeComparisonCard  – shows parallel/perpendicular verdict
//   • SlopeInfoChip        – small chip showing "Line N / slope"
// ─────────────────────────────────────────────────────────────

/// Tappable card showing the slope of a single line.
/// [onTap] opens the steps dialog (wired in the parent screen).
class SlopeAnswerCard extends StatelessWidget {
  final SlopeSolverResult result;
  final VoidCallback onTap;

  const SlopeAnswerCard({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final slopeStr = result.slopeDisplay;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              SlopeTheme.accentColor.withValues(alpha: 0.15),
              SlopeTheme.accentColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: SlopeTheme.accentColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Slope',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: SlopeTheme.accentColor.withValues(alpha: 0.7),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              slopeStr,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: SlopeTheme.textPrimary(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'm = $slopeStr',
              style: TextStyle(
                fontSize: 11,
                color: SlopeTheme.textSecondary(context).withValues(alpha: 0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tappable card showing the parallel/perpendicular/neither verdict
/// together with each line's slope chip.
/// [onTap] opens the comparison dialog (wired in the parent screen).
class SlopeComparisonCard extends StatelessWidget {
  final SlopeComparisonResult result;
  final VoidCallback onTap;

  const SlopeComparisonCard({
    super.key,
    required this.result,
    required this.onTap,
  });

  Color get _color => result.isParallel
      ? const Color(0xFF4ECDC4)
      : result.isPerpendicular
          ? const Color(0xFFFFB347)
          : const Color(0xFF95E1D3);

  String get _label => result.isPerpendicular ? 'Perpendicular' : 'Parallel';

  IconData get _icon {
    if (result.isParallel) return Icons.trending_up_rounded;
    if (result.isPerpendicular) return Icons.add_rounded;
    return Icons.trending_flat_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.12),
              color.withValues(alpha: 0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.isNeither ? 'Neither' : _label,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: color,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Line Relationship',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color.withValues(alpha: 0.6),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: color.withValues(alpha: 0.6)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                result.explanation,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color:
                      SlopeTheme.textPrimary(context).withValues(alpha: 0.75),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SlopeInfoChip(
                    label: 'Line 1',
                    slope: result.slope1.slopeDisplay,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SlopeInfoChip(
                    label: 'Line 2',
                    slope: result.slope2.slopeDisplay,
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

/// Small chip showing a label (e.g. "Line 1") and its slope value.
class SlopeInfoChip extends StatelessWidget {
  final String label;
  final String slope;

  const SlopeInfoChip({
    super.key,
    required this.label,
    required this.slope,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SlopeTheme.cardColor(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: SlopeTheme.accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: SlopeTheme.accentColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            slope,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: SlopeTheme.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}
