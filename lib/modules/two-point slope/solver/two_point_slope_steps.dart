import 'package:calculus_system/modules/two-point%20slope/Theme/two_point_slope_theme.dart';
import 'package:calculus_system/modules/two-point%20slope/solver/two_point_slope_solver.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// STEPS WIDGET
// Displays the full step-by-step working for the solution.
// Completely self-contained — just pass in the result.
// ─────────────────────────────────────────────────────────────

class TwoPointSlopeSteps extends StatefulWidget {
  final TwoPointSlopeResult result;

  const TwoPointSlopeSteps({super.key, required this.result});

  @override
  State<TwoPointSlopeSteps> createState() => _TwoPointSlopeStepsState();
}

class _TwoPointSlopeStepsState extends State<TwoPointSlopeSteps>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  // One color per step — cycles through step palette
  static const List<Color> _stepColors = [
    TwoPointSlopeTheme.stepBlue,
    TwoPointSlopeTheme.stepGreen,
    TwoPointSlopeTheme.stepPurple,
    TwoPointSlopeTheme.stepOrange,
    TwoPointSlopeTheme.primary,
  ];

  @override
  void initState() {
    super.initState();
    _buildAnimations();
  }

  void _buildAnimations() {
    final count = widget.result.steps.length;
    _controllers = List.generate(
      count,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _fadeAnims = _controllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _slideAnims = _controllers
        .map((c) => Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)))
        .toList();

    for (int i = 0; i < count; i++) {
      Future.delayed(Duration(milliseconds: 80 * i), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 20,
                decoration: BoxDecoration(
                  color: TwoPointSlopeTheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'STEP-BY-STEP SOLUTION',
                style: TwoPointSlopeTheme.labelStyle(context),
              ),
            ],
          ),
        ),

        // Steps list
        ...widget.result.steps.asMap().entries.map((entry) {
          final i = entry.key;
          final step = entry.value;
          final color = _stepColors[i % _stepColors.length];

          return FadeTransition(
            opacity: _fadeAnims[i],
            child: SlideTransition(
              position: _slideAnims[i],
              child: _StepCard(step: step, color: color),
            ),
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Individual step card
// ─────────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  final SolverStep step;
  final Color color;

  const _StepCard({required this.step, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: TwoPointSlopeTheme.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Colored left bar + number
              Container(
                width: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  border: Border(
                    right: BorderSide(
                      color: color.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${step.number}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        step.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Formula
                      _FormulaRow(
                        label: 'Formula',
                        value: step.formula,
                        color: TwoPointSlopeTheme.textSecondary(context),
                      ),
                      const SizedBox(height: 6),

                      // Substitution
                      _FormulaRow(
                        label: 'Substitute',
                        value: step.substitution,
                        color: TwoPointSlopeTheme.textPrimary(context),
                      ),
                      const SizedBox(height: 6),

                      // Result
                      _FormulaRow(
                        label: 'Result',
                        value: step.result,
                        color: color,
                        bold: true,
                      ),

                      const SizedBox(height: 10),
                      const Divider(
                        color: Color(0xFF222230),
                        height: 1,
                      ),
                      const SizedBox(height: 10),

                      // Explanation
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: color.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              step.explanation,
                              style: TextStyle(
                                fontSize: 12,
                                color: TwoPointSlopeTheme.textSecondary(context)
                                    .withValues(alpha: 0.8),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormulaRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool bold;

  const _FormulaRow({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: TwoPointSlopeTheme.textMuted(context),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: color,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
