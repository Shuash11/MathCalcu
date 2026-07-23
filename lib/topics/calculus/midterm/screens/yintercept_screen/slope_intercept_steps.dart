import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/yintercept_solver/yi_steps.dart';
import 'package:calculus_system/shared/widgets/solution_step_card.dart';
import 'package:calculus_system/theme/app_design.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

// ─────────────────────────────────────────────────────────────
// STEPS WIDGET — MIGRATED TO SolutionStepCard
//
// Each YISolverStep is rendered as a SolutionStepCard with:
// - stepNumber
// - title  (heading from solver)
// - mathContent (a vertical stack of formula, substitution,
//   sub-steps, dual panels, and the result + explanation)
//
// Supports both layouts:
//   YIStepLayout.single  → formula + substitution + sub-steps + result
//   YIStepLayout.dual    → two side-by-side panels + combined result
// ─────────────────────────────────────────────────────────────

class YInterceptSteps extends StatelessWidget {
  final List<YISolverStep> steps;
  final Color accentColor;

  const YInterceptSteps({
    super.key,
    required this.steps,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children:
          steps.map((s) => _buildStep(context, s)).toList(growable: false),
    );
  }

  Widget _buildStep(BuildContext context, YISolverStep step) {
    return SolutionStepCard(
      design: AppDesign.app,
      stepNumber: step.number,
      title: step.title,
      mathContent: step.layout == YIStepLayout.dual
          ? _buildDual(context, step)
          : _buildSingle(context, step),
    );
  }

  // ── Single layout ─────────────────────────────────────────

  Widget _buildSingle(BuildContext context, YISolverStep step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (step.formulaLatex.isNotEmpty) ...[
          _FormulaChip(latex: step.formulaLatex),
          const SizedBox(height: 10),
        ],
        if (step.substitutionLatex.isNotEmpty) ...[
          _LatexLine(
            latex: step.substitutionLatex,
            fontSize: 14,
            color: accentColor.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 10),
        ],
        if (step.subSteps.isNotEmpty) ...[
          ...step.subSteps.map((sub) => _SubStepLine(
                subStep: sub,
                accentColor: accentColor,
              )),
          const SizedBox(height: 10),
        ],
        if (step.resultLatex.isNotEmpty) _ResultBox(latex: step.resultLatex),
        if (step.explanation.isNotEmpty) ...[
          const SizedBox(height: 8),
          _ExplanationText(text: step.explanation, context: context),
        ],
      ],
    );
  }

  // ── Dual layout ───────────────────────────────────────────

  Widget _buildDual(BuildContext context, YISolverStep step) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _DualPanel(
                label: step.leftLabel ?? '',
                latex: step.leftLatex ?? '',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DualPanel(
                label: step.rightLabel ?? '',
                latex: step.rightLatex ?? '',
              ),
            ),
          ],
        ),
        if (step.resultLatex.isNotEmpty) ...[
          const SizedBox(height: 12),
          _ResultBox(latex: step.resultLatex),
        ],
      ],
    );
  }
}

// ── Small reusable sub-widgets (kept local; same look as before) ───

class _FormulaChip extends StatelessWidget {
  final String latex;
  const _FormulaChip({required this.latex});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: FinalsTheme.cardSecondary(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Math.tex(
        latex,
        textStyle: TextStyle(
          fontSize: 13,
          color: FinalsTheme.primaryFor(context).withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

class _LatexLine extends StatelessWidget {
  final String latex;
  final double fontSize;
  final Color color;
  const _LatexLine({
    required this.latex,
    this.fontSize = 14,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Math.tex(
      latex,
      textStyle: TextStyle(fontSize: fontSize, color: color),
    );
  }
}

class _ResultBox extends StatelessWidget {
  final String latex;
  const _ResultBox({required this.latex});

  @override
  Widget build(BuildContext context) {
    final primaryColor = FinalsTheme.primaryFor(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.35),
        ),
      ),
      child: Math.tex(
        latex,
        textStyle: TextStyle(
          fontSize: 16,
          color: primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ExplanationText extends StatelessWidget {
  final String text;
  final BuildContext context;
  const _ExplanationText({required this.text, required this.context});

  @override
  Widget build(BuildContext outerContext) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.5);
    return ResponsiveText(
      text,
      style: TextStyle(
        fontSize: 11.5,
        color: color,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class _SubStepLine extends StatelessWidget {
  final YISubStep subStep;
  final Color accentColor;
  const _SubStepLine({required this.subStep, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.85)
        : Colors.black87;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 8),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subStep.label.isNotEmpty)
                  ResponsiveText(
                    subStep.label,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: textColor.withValues(alpha: 0.55),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                const SizedBox(height: 2),
                Math.tex(
                  subStep.latex,
                  textStyle: TextStyle(
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DualPanel extends StatelessWidget {
  final String label;
  final String latex;
  const _DualPanel({required this.label, required this.latex});

  @override
  Widget build(BuildContext context) {
    final primaryColor = FinalsTheme.primaryFor(context);
    return Container(
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: ResponsiveText(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: primaryColor.withValues(alpha: 0.85),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SelectableMath.tex(
              latex,
              textStyle: TextStyle(
                fontSize: 16,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
