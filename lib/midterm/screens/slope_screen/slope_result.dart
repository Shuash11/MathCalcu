import 'package:calculus_system/midterm/theme/slope_theme/slope_theme.dart';
import 'package:calculus_system/midterm/solvers/slope_solver/slope_solver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

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
    final isVertical = result.isVertical;
    final isHorizontal = result.isHorizontal;

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
            _SlopeDisplay(slopeStr: slopeStr, isVertical: isVertical, isHorizontal: isHorizontal),
            const SizedBox(height: 4),
            Math.tex(
              isVertical ? r'x = c' : (isHorizontal ? r'm = 0' : r'm = ' + _toLatexSlope(slopeStr)),
              textStyle: TextStyle(
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

  String _toLatexSlope(String slopeStr) {
    if (slopeStr.contains('/')) {
      final parts = slopeStr.split('/');
      // ignore: prefer_interpolation_to_compose_strings
      return r'\frac{' + parts[0] + '}{' + parts[1] + '}';
    }
    return slopeStr;
  }
}

class _SlopeDisplay extends StatelessWidget {
  final String slopeStr;
  final bool isVertical;
  final bool isHorizontal;

  const _SlopeDisplay({
    required this.slopeStr,
    required this.isVertical,
    required this.isHorizontal,
  });

  @override
  Widget build(BuildContext context) {
    String latex;
    if (isVertical) {
      latex = r'x = c';
    } else if (isHorizontal) {
      latex = r'0';
    } else {
      latex = _toLatexFrac(slopeStr);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Math.tex(
        latex,
        textStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: SlopeTheme.textPrimary(context),
        ),
      ),
    );
  }

  String _toLatexFrac(String slopeStr) {
    if (slopeStr.contains('/')) {
      final parts = slopeStr.split('/');
      return r'\frac{' + parts[0] + '}{' + parts[1] + '}';
    }
    return slopeStr;
  }
}

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
                    isVertical: result.slope1.isVertical,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SlopeInfoChip(
                    label: 'Line 2',
                    slope: result.slope2.slopeDisplay,
                    isVertical: result.slope2.isVertical,
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

class SlopeInfoChip extends StatelessWidget {
  final String label;
  final String slope;
  final bool isVertical;

  const SlopeInfoChip({
    super.key,
    required this.label,
    required this.slope,
    this.isVertical = false,
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Math.tex(
              isVertical ? r'\infty' : _toLatexFrac(slope),
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: SlopeTheme.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _toLatexFrac(String slopeStr) {
    if (slopeStr.contains('/')) {
      final parts = slopeStr.split('/');
      return r'\frac{' + parts[0] + '}{' + parts[1] + '}';
    }
    return slopeStr;
  }
}
