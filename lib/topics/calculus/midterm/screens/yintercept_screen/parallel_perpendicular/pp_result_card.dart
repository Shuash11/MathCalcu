// lib/topics/calculus/midterm/screens/yintercept_screen/parallel_perpendicular/pp_result_card.dart

import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/yintercept_solver/yi_solver.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Result card for the Parallel & Perpendicular screen: verdict,
/// slope comparison tiles, and line equation tiles.
class PPResultCard extends StatelessWidget {
  final PPResult result;
  final bool showGraph;
  final VoidCallback onToggleGraph;
  final VoidCallback onShowSteps;

  const PPResultCard({
    super.key,
    required this.result,
    required this.showGraph,
    required this.onToggleGraph,
    required this.onShowSteps,
  });

  Color _verdictColor(BuildContext context) {
    final accent = context.watch<ThemeProvider>().accentColor;
    switch (result.relationship) {
      case PPRelationship.parallel:
        return accent;
      case PPRelationship.perpendicular:
        return accent;
      case PPRelationship.sameLine:
        return accent;
      case PPRelationship.neither:
        return const Color(0xFF64748B);
    }
  }

  String _toStandardForm(int a, int b, int c) {
    return '${_formatTerm(a, 'x')} ${_formatTerm(b, 'y', true)} = ${-c}';
  }

  String _toGeneralForm(int a, int b, int c) {
    return '${_formatTerm(a, 'x')} ${_formatTerm(b, 'y')} ${_formatConstant(c)} = 0';
  }

  String _formatTerm(int coeff, String variable, [bool isStandard = false]) {
    if (coeff == 0) return '';
    final sign = coeff > 0 ? '+' : '-';
    final absCoeff = coeff.abs();
    final coeffStr = absCoeff == 1 ? '' : absCoeff.toString();
    return '$sign $coeffStr$variable';
  }

  String _formatConstant(int c) {
    if (c == 0) return '';
    final sign = c > 0 ? '+' : '-';
    return '$sign ${c.abs()}';
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.watch<ThemeProvider>().accentColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: context.watch<ThemeProvider>().card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context
              .watch<ThemeProvider>()
              .accentColor
              .withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: context
                .watch<ThemeProvider>()
                .accentColor
                .withValues(alpha: 0.15),
            blurRadius: 32,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'RESULT',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context
                        .watch<ThemeProvider>()
                        .textSecondary
                        .withValues(alpha: 0.7),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onToggleGraph,
                child: _buildShowGraphChip(context, accent),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onShowSteps,
                child: _buildShowStepsChip(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Verdict card
          _VerdictCard(
            result: result,
            accent: _verdictColor(context),
          ),

          const SizedBox(height: 16),

          // Slope comparison row
          Row(
            children: [
              Expanded(
                child: _ResultTile(
                  label: 'Slope 1',
                  value: result.slope1?.toDouble().toStringAsFixed(2) ??
                      'undefined',
                  color: context.watch<ThemeProvider>().accentColor,
                  icon: Icons.show_chart_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultTile(
                  label: 'Slope 2',
                  value: result.slope2?.toDouble().toStringAsFixed(2) ??
                      'undefined',
                  color: context.watch<ThemeProvider>().accentColor,
                  icon: Icons.show_chart_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Line 1 equations
          _EquationTile(
            label: 'Line 1 — Slope-Intercept',
            tag: 'y = mx + b',
            equation: result.slopeIntercept1,
            color: context.watch<ThemeProvider>().accentColor,
            tagColor: context.watch<ThemeProvider>().accentColor,
          ),

          const SizedBox(height: 10),

          _EquationTile(
            label: 'Line 1 — Standard Form',
            tag: 'Ax + By = C',
            equation: _toStandardForm(result.a1, result.b1, result.c1),
            color: context.watch<ThemeProvider>().accentColor,
            tagColor: context.watch<ThemeProvider>().accentColor,
          ),

          const SizedBox(height: 10),

          _EquationTile(
            label: 'Line 1 — General Form',
            tag: 'Ax + By + C = 0',
            equation: _toGeneralForm(result.a1, result.b1, result.c1),
            color: accent,
            tagColor: accent,
          ),

          const SizedBox(height: 16),

          // Line 2 equations
          _EquationTile(
            label: 'Line 2 — Slope-Intercept',
            tag: 'y = mx + b',
            equation: result.slopeIntercept2,
            color: context.watch<ThemeProvider>().accentColor,
            tagColor: context.watch<ThemeProvider>().accentColor,
          ),

          const SizedBox(height: 10),

          _EquationTile(
            label: 'Line 2 — Standard Form',
            tag: 'Ax + By = C',
            equation: _toStandardForm(result.a2, result.b2, result.c2),
            color: context.watch<ThemeProvider>().accentColor,
            tagColor: context.watch<ThemeProvider>().accentColor,
          ),

          const SizedBox(height: 10),

          _EquationTile(
            label: 'Line 2 — General Form',
            tag: 'Ax + By + C = 0',
            equation: _toGeneralForm(result.a2, result.b2, result.c2),
            color: accent,
            tagColor: accent,
          ),
        ],
      ),
    );
  }

  Widget _buildShowStepsChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ResponsiveText(
            'Show steps',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: context.watch<ThemeProvider>().accentColor,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded,
              color: context.watch<ThemeProvider>().accentColor, size: 16),
        ],
      ),
    );
  }

  Widget _buildShowGraphChip(BuildContext context, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: showGraph
            ? accent.withValues(alpha: 0.2)
            : accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.show_chart_rounded, color: accent, size: 14),
          const SizedBox(width: 4),
          ResponsiveText(
            showGraph ? 'Hide graph' : 'Show graph',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerdictCard extends StatelessWidget {
  final PPResult result;
  final Color accent;
  const _VerdictCard({required this.result, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.28), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ResponsiveText(
                'VERDICT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: accent,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Icon(Icons.show_chart_rounded, color: accent, size: 16),
              const SizedBox(width: 4),
              ResponsiveText(
                'Tap to graph',
                style: TextStyle(
                  color: accent.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ResponsiveText(
            '${result.verdictSymbol}  ${result.verdict}',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: accent,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _ResultTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color.withValues(alpha: 0.7)),
                const SizedBox(width: 6),
                ResponsiveText(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ResponsiveText(
              value,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
                height: 1.2,
              ),
            ),
          ],
        ),
      );
}

class _EquationTile extends StatelessWidget {
  final String label;
  final String tag;
  final String equation;
  final Color color;
  final Color tagColor;

  const _EquationTile({
    required this.label,
    required this.tag,
    required this.equation,
    required this.color,
    required this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ResponsiveText(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: context
                      .watch<ThemeProvider>()
                      .textSecondary
                      .withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 9,
                    fontFamily: 'monospace',
                    color: tagColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ResponsiveText(
            equation,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
