import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/two_point_slope_solver/two_point_slope_solver.dart';
import 'package:calculus_system/shared/widgets/solution_step_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

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
                  color: FinalsTheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'STEP-BY-STEP SOLUTION',
                style: FinalsTheme.labelStyle(context),
              ),
            ],
          ),
        ),

        // Steps list
        ...widget.result.steps.asMap().entries.map((entry) {
          final i = entry.key;
          final step = entry.value;

          return FadeTransition(
            opacity: _fadeAnims[i],
            child: SlideTransition(
              position: _slideAnims[i],
              child: SolutionStepCard(
                stepNumber: step.number,
                title: step.title,
                mathContent: _CombinedMathBlock(
                  formula: step.formula,
                  substitution: step.substitution,
                  result: step.result,
                  fontSize: 14,
                  color: FinalsTheme.primary,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _CombinedMathBlock extends StatelessWidget {
  final String formula;
  final String substitution;
  final String result;
  final double fontSize;
  final Color color;

  const _CombinedMathBlock({
    required this.formula,
    required this.substitution,
    required this.result,
    required this.fontSize,
    required this.color,
  });

  Widget _mathWidget(String tex) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Math.tex(
          tex,
          textStyle: TextStyle(
            fontSize: fontSize,
            color: color,
            fontWeight: FontWeight.w500,
          ),
          onErrorFallback: (error) => Text(
            tex,
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: fontSize,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FinalsTheme.cardSecondary(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: FinalsTheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (formula.isNotEmpty) _mathWidget(formula),
          if (formula.isNotEmpty && substitution.isNotEmpty)
            const SizedBox(height: 6),
          if (substitution.isNotEmpty) _mathWidget(substitution),
          if (substitution.isNotEmpty && result.isNotEmpty && result != substitution)
            const SizedBox(height: 6),
          if (result.isNotEmpty && result != substitution) _mathWidget(result),
        ],
      ),
    );
  }
}


