import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/shared/widgets/solution_step_card.dart';
import 'package:calculus_system/theme/app_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

// ─────────────────────────────────────────────────────────────
// STEPS WIDGET — MIGRATED TO SolutionStepCard
//
// Matches the unified solution steps style (slop_screen/slope_steps.dart):
// - stepNumber (numbered amber circle from SolutionStepCard)
// - title (the step guide, e.g. "Substitute values")
// - description (the original step label, e.g. "Step 3")
// - mathContent (a SelectableMath.tex wrapped in horizontal scroll)
//
// All 7 original steps from the custom timeline are preserved:
//   1. Identify given values
//   2. Point-Slope formula
//   3. Substitute values
//   4. Distribute slope (m)  — dual-panel (Expanded ↔ Simplified)
//   5. Solve for y (Slope-Intercept)
//   6. General Form (Ax + By + C = 0)
//   7. Standard Form (Ax + By = C)
// ─────────────────────────────────────────────────────────────

String _simplifyFraction(String frac) {
  if (!frac.contains('/')) return frac;
  final parts = frac.split('/');
  if (parts.length == 2) {
    final num = int.tryParse(parts[0]);
    final den = int.tryParse(parts[1]);
    if (num != null && den != null && den != 0) {
      int a = num.abs();
      int b = den.abs();
      while (b != 0) {
        final t = b;
        b = a % b;
        a = t;
      }
      final gcd = a;
      if (gcd > 1) {
        return '${num ~/ gcd}/${den ~/ gcd}';
      }
    }
  }
  return frac;
}

class PointSlopeSteps extends StatelessWidget {
  final String m;
  final String x1;
  final String y1;
  final String b;
  final String generalForm;
  final String standardForm;

  const PointSlopeSteps({
    super.key,
    required this.m,
    required this.x1,
    required this.y1,
    required this.b,
    required this.generalForm,
    required this.standardForm,
  });

  Widget _mathLatex(String tex) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableMath.tex(
          tex,
          textStyle: const TextStyle(
            fontSize: 14,
            color: FinalsTheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

  Widget _mathText(BuildContext context, String text) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.85)
        : Colors.black87;
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        height: 1.6,
        color: color,
        fontWeight: FontWeight.w500,
        fontFamily: 'monospace',
      ),
    );
  }

  Widget _buildDualPanel({
    required String leftLabel,
    required String leftLatex,
    required String rightLabel,
    required String rightLatex,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _CasePanel(label: leftLabel, latex: leftLatex),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _CasePanel(label: rightLabel, latex: rightLatex),
        ),
      ],
    );
  }

  String _buildStep3Latex(
    String mSimplified,
    String y1Sign,
    String y1Abs,
    String x1Sign,
    String x1Abs,
  ) {
    final mParaOpen = mSimplified.contains('/') ? r'(' : '';
    final mParaClose = mSimplified.contains('/') ? r')' : '';
    return 'y $y1Sign $y1Abs = '
        '$mParaOpen$mSimplified$mParaClose'
        r'(x $x1Sign $x1Abs)'
            .replaceAll(r'$x1Sign', x1Sign)
            .replaceAll(r'$x1Abs', x1Abs);
  }

  String _buildStep4LeftLatex(
    String mSimplified,
    String y1Sign,
    String y1Abs,
    String x1Sign,
    String x1Abs,
    String x1,
  ) {
    final frac = mSimplified.contains('/');
    final mParaOpen = frac ? r'(' : '';
    final mParaClose = frac ? r')' : '';
    final sep = frac ? r' \cdot x + ' : r'x + ';
    return r'\begin{aligned}'
        'y $y1Sign $y1Abs = $mParaOpen$mSimplified$mParaClose$sep'
        '$mParaOpen$mSimplified$mParaClose \\cdot ($x1Sign $x1Abs)'
        r' \\'
        'y $y1Sign $y1Abs = $mParaOpen$mSimplified$mParaClose$sep'
        '$mParaOpen$mSimplified$mParaClose \\cdot ($x1)'
        r'\end{aligned}';
  }

  String _buildStep4RightLatex(
    String mSimplified,
    String y1Sign,
    String y1Abs,
    String m,
    String x1,
  ) {
    final mVal = double.tryParse(m) ?? 0;
    final xVal = double.tryParse(x1) ?? 0;
    final product = mVal * xVal;
    final sign = product < 0 ? '+' : '-';
    final absVal = product.abs().toString();
    final mWithParens = mSimplified.contains('/') ? '($mSimplified)' : mSimplified;
    final mulSymbol = mSimplified.contains('/') ? r' \cdot ' : ' ';
    return r'\begin{aligned}'
        'y $y1Sign $y1Abs = $mWithParens$mulSymbol'
        'x $sign $absVal'
        r'\end{aligned}';
  }

  String _buildStep5Latex(String mSimplified, String b, String bSimplified) {
    String bSign;
    final bParsed = double.tryParse(b);
    if (bParsed != null) {
      bSign = bParsed >= 0 ? '+' : '-';
    } else {
      bSign = b.trimLeft().startsWith('-') ? '-' : '+';
    }
    final mWithParens = mSimplified.contains('/') ? '($mSimplified)' : mSimplified;
    final dot = mSimplified.contains('/') ? r' \cdot ' : '';
    return 'y = $mWithParens${dot}x $bSign ${bSimplified.replaceAll('-', '')}';
  }

  @override
  Widget build(BuildContext context) {
    final mSimplified = _simplifyFraction(m);
    final bSimplified = _simplifyFraction(b);

    final y1Abs = y1.startsWith('-') ? y1.substring(1) : y1;
    final y1Sign = y1.startsWith('-') ? '+' : '-';
    final x1Abs = x1.startsWith('-') ? x1.substring(1) : x1;
    final x1Sign = x1.startsWith('-') ? '+' : '-';

    final step3Latex = _buildStep3Latex(
        mSimplified, y1Sign, y1Abs, x1Sign, x1Abs);

    final step4LeftLatex = _buildStep4LeftLatex(
      mSimplified,
      y1Sign,
      y1Abs,
      x1Sign,
      x1Abs,
      x1,
    );

    final step4RightLatex = _buildStep4RightLatex(
      mSimplified,
      y1Sign,
      y1Abs,
      m,
      x1,
    );

    final step5Latex = _buildStep5Latex(mSimplified, b, bSimplified);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SolutionStepCard(design: AppDesign.calculus,
          stepNumber: 1,
          title: 'Identify given values',
          description: 'Step 1',
          mathContent: _mathText(context, 'Point:  ($x1, $y1)\nSlope:  m = $m'),
        ),
        SolutionStepCard(design: AppDesign.calculus,
          stepNumber: 2,
          title: 'Point-Slope formula',
          description: 'Step 2',
          mathContent: _mathLatex(r'y - y_1 = m(x - x_1)'),
        ),
        SolutionStepCard(design: AppDesign.calculus,
          stepNumber: 3,
          title: 'Substitute values',
          description: 'Step 3',
          mathContent: _mathLatex(step3Latex),
        ),
        SolutionStepCard(design: AppDesign.calculus,
          stepNumber: 4,
          title: 'Distribute slope (m)',
          description: 'Step 4',
          mathContent: _buildDualPanel(
            leftLabel: 'Expanded form',
            leftLatex: step4LeftLatex,
            rightLabel: 'Simplify',
            rightLatex: step4RightLatex,
          ),
        ),
        SolutionStepCard(design: AppDesign.calculus,
          stepNumber: 5,
          title: 'Solve for y (Slope-Intercept)',
          description: 'Step 5',
          mathContent: _mathLatex(step5Latex),
        ),
        SolutionStepCard(design: AppDesign.calculus,
          stepNumber: 6,
          title: 'General Form (Ax + By + C = 0)',
          description: 'Step 6',
          mathContent: _mathLatex(generalForm),
        ),
        SolutionStepCard(design: AppDesign.calculus,
          stepNumber: 7,
          title: 'Standard Form (Ax + By = C)',
          description: 'Step 7',
          mathContent: _mathLatex(standardForm),
        ),
      ],
    );
  }
}

class _CasePanel extends StatelessWidget {
  final String label;
  final String latex;

  const _CasePanel({required this.label, required this.latex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FinalsTheme.cardSecondary(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: FinalsTheme.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: FinalsTheme.primary.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: FinalsTheme.primary,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableMath.tex(
                latex,
                textStyle: const TextStyle(
                  fontSize: 14,
                  color: FinalsTheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
