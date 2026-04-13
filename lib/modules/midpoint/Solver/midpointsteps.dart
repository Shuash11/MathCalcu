import 'package:calculus_system/modules/midpoint/Solver/midpointsolver.dart';
import 'package:calculus_system/modules/midpoint/Theme/midpointtheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

enum StepMode { midpoint, endpoint }

enum _StepKind { single, dual }

class StepSection {
  final String stepLabel;
  final String guide;
  final _StepKind kind;
  final String? latexContent;
  final String? plainContent;
  final String? leftLabel;
  final String? rightLabel;
  final String? leftLatex;
  final String? rightLatex;

  const StepSection.single({
    required this.stepLabel,
    required this.guide,
    this.latexContent,
    this.plainContent,
  })  : kind = _StepKind.single,
        leftLabel = null,
        rightLabel = null,
        leftLatex = null,
        rightLatex = null,
        assert(
          latexContent != null || plainContent != null,
          'Single step needs latexContent or plainContent.',
        );

  const StepSection.dual({
    required this.stepLabel,
    required this.guide,
    required String this.leftLabel,
    required String this.rightLabel,
    required String this.leftLatex,
    required String this.rightLatex,
  })  : kind = _StepKind.dual,
        latexContent = null,
        plainContent = null;
}

class _StepBuilder {
  const _StepBuilder._();

  static List<StepSection> midpoint({
    required Fraction x1,
    required Fraction y1,
    required Fraction x2,
    required Fraction y2,
    required Fraction resX,
    required Fraction resY,
  }) {
    final sumX = MidpointSolver.simplify(
      x1.numerator * x2.denominator + x2.numerator * x1.denominator,
      x1.denominator * x2.denominator,
    );
    final sumY = MidpointSolver.simplify(
      y1.numerator * y2.denominator + y2.numerator * y1.denominator,
      y1.denominator * y2.denominator,
    );

    final x1s = x1.toString();
    final y1s = y1.toString();
    final x2s = x2.toString();
    final y2s = y2.toString();
    final sumXs = sumX.toString();
    final sumYs = sumY.toString();
    final resXs = resX.toString();
    final resYs = resY.toString();

    return [
      // ── Step 1 ──────────────────────────────────────────────────────────
      StepSection.single(
        stepLabel: 'Step 1',
        guide: 'Identify endpoints',
        plainContent: 'A = ($x1s,  $y1s)   →   (x₁, y₁)\n'
            'B = ($x2s,  $y2s)   →   (x₂, y₂)',
      ),

      // ── Step 2 ──────────────────────────────────────────────────────────
      StepSection.single(
        stepLabel: 'Step 2',
        guide: 'Midpoint formula',
        latexContent:
            r'M = \left(\dfrac{x_1+x_2}{2},\;\dfrac{y_1+y_2}{2}\right)',
      ),

      // ── Step 3 ──────────────────────────────────────────────────────────
      // FIX: use raw-string fragments so \\ is a real LaTeX line-break (\\),
      // not the single backslash produced by a non-raw Dart string.
      StepSection.dual(
        stepLabel: 'Step 3',
        guide: 'Add both coordinates',
        leftLabel: 'x-coordinate',
        rightLabel: 'y-coordinate',
        leftLatex: r'\begin{aligned}'
            'x_1 + x_2 &= $x1s + $x2s'
            r' \\'
            '&= $sumXs'
            r'\end{aligned}',
        rightLatex: r'\begin{aligned}'
            'y_1 + y_2 &= $y1s + $y2s'
            r' \\'
            '&= $sumYs'
            r'\end{aligned}',
      ),

      // ── Step 4 ──────────────────────────────────────────────────────────
      StepSection.dual(
        stepLabel: 'Step 4',
        guide: 'Divide by 2',
        leftLabel: 'Find xₘ',
        rightLabel: 'Find yₘ',
        leftLatex: r'\begin{aligned}'
            r'x_m &= \dfrac{' '$sumXs' r'}{2} \\'
            r'&= \boxed{' '$resXs' r'}'
            r'\end{aligned}',
        rightLatex: r'\begin{aligned}'
            r'y_m &= \dfrac{' '$sumYs' r'}{2} \\'
            r'&= \boxed{' '$resYs' r'}'
            r'\end{aligned}',
      ),

      // ── Step 5 ──────────────────────────────────────────────────────────
      // FIX: the previous non-raw string
      //   'M &= \left($resXs,\;$resYs\right)\\[8pt]'
      // caused two bugs:
      //   1. \r (in \right) became a carriage-return character.
      //   2. \\ became a single \, so \\[8pt] became \[8pt] →
      //      "Undefined control sequence: \[".
      // Solution: split every LaTeX fragment into raw strings (r'...') and
      // splice variable values in via adjacent non-raw string literals.
      // \\[8pt] is also not supported by flutter_math_fork (KaTeX subset),
      // so it is replaced with a plain \\ line-break.
      StepSection.single(
        stepLabel: 'Step 5',
        guide: 'Answer + verify',
        latexContent: r'\begin{aligned}'
            r'M &= \left(' '$resXs' r',\;' '$resYs' r'\right)\\'
            r'x_m &= \dfrac{' '$x1s' r'+' '$x2s' r'}{2} = ' '$resXs' r'\;\checkmark \\'
            r'y_m &= \dfrac{' '$y1s' r'+' '$y2s' r'}{2} = ' '$resYs' r'\;\checkmark'
            r'\end{aligned}',
      ),
    ];
  }

  static List<StepSection> endpoint({
    required Fraction xm,
    required Fraction ym,
    required Fraction x1,
    required Fraction y1,
    required Fraction resX,
    required Fraction resY,
  }) {
    final doubleXm = MidpointSolver.multiplyFractionByInt(xm, 2);
    final doubleYm = MidpointSolver.multiplyFractionByInt(ym, 2);

    final xms = xm.toString();
    final yms = ym.toString();
    final x1s = x1.toString();
    final y1s = y1.toString();
    final doubleXms = doubleXm.toString();
    final doubleYms = doubleYm.toString();
    final resXs = resX.toString();
    final resYs = resY.toString();

    return [
      // ── Step 1 ──────────────────────────────────────────────────────────
      StepSection.single(
        stepLabel: 'Step 1',
        guide: 'Identify given values',
        plainContent: 'M = ($xms,  $yms)   →   midpoint\n'
            'A = ($x1s,  $y1s)   →   known endpoint\n'
            'B = (x₂, y₂)      →   find this',
      ),

      // ── Step 2 ──────────────────────────────────────────────────────────
      StepSection.single(
        stepLabel: 'Step 2',
        guide: 'Midpoint formula',
        latexContent:
            r'M = \left(\dfrac{x_1+x_2}{2},\;\dfrac{y_1+y_2}{2}\right)',
      ),

      // ── Step 3 ──────────────────────────────────────────────────────────
      StepSection.single(
        stepLabel: 'Step 3',
        guide: 'Rearrange for unknown endpoint',
        latexContent:
            r'\begin{aligned} x_2 &= 2x_m - x_1 \\ y_2 &= 2y_m - y_1 \end{aligned}',
      ),

      // ── Step 4 ──────────────────────────────────────────────────────────
      StepSection.dual(
        stepLabel: 'Step 4',
        guide: 'Solve both coordinates',
        leftLabel: 'Solve x₂',
        rightLabel: 'Solve y₂',
        leftLatex: r'\begin{aligned}'
            r'x_2 &= 2(' '$xms' r') - (' '$x1s' r') \\'
            r'&= ' '$doubleXms' r' - ' '$x1s' r' \\'
            r'&= \boxed{' '$resXs' r'}'
            r'\end{aligned}',
        rightLatex: r'\begin{aligned}'
            r'y_2 &= 2(' '$yms' r') - (' '$y1s' r') \\'
            r'&= ' '$doubleYms' r' - ' '$y1s' r' \\'
            r'&= \boxed{' '$resYs' r'}'
            r'\end{aligned}',
      ),

      // ── Step 5 ──────────────────────────────────────────────────────────
      // Same fix as midpoint Step 5: all LaTeX in raw strings, no \\[8pt].
      StepSection.single(
        stepLabel: 'Step 5',
        guide: 'Answer + verify',
        latexContent: r'\begin{aligned}'
            r'B &= \left(' '$resXs' r',\;' '$resYs' r'\right)\\'
            r'x_m &= \dfrac{' '$x1s' r'+' '$resXs' r'}{2} = ' '$xms' r'\;\checkmark \\'
            r'y_m &= \dfrac{' '$y1s' r'+' '$resYs' r'}{2} = ' '$yms' r'\;\checkmark'
            r'\end{aligned}',
      ),
    ];
  }
}

class MidpointSteps extends StatelessWidget {
  final StepMode mode;
  final String rawAX;
  final String rawAY;
  final String rawBX;
  final String rawBY;
  final Fraction resX;
  final Fraction resY;

  const MidpointSteps({
    super.key,
    required this.mode,
    required this.rawAX,
    required this.rawAY,
    required this.rawBX,
    required this.rawBY,
    required this.resX,
    required this.resY,
  });

  Fraction? _parse(String raw, String label) =>
      MidpointSolver.parseFraction(raw, label).fraction;

  List<StepSection>? _buildSteps() {
    final a1 = _parse(rawAX, 'x₁');
    final a2 = _parse(rawAY, 'y₁');
    final b1 = _parse(rawBX, 'x₂');
    final b2 = _parse(rawBY, 'y₂');
    if (a1 == null || a2 == null || b1 == null || b2 == null) return null;

    return mode == StepMode.endpoint
        ? _StepBuilder.endpoint(
            xm: a1,
            ym: a2,
            x1: b1,
            y1: b2,
            resX: resX,
            resY: resY,
          )
        : _StepBuilder.midpoint(
            x1: a1,
            y1: a2,
            x2: b1,
            y2: b2,
            resX: resX,
            resY: resY,
          );
  }

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps();
    if (steps == null) return const _ErrorCard();

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;
    final isMedium = screenWidth < 400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Header(
          stepCount: steps.length,
          mode: mode,
          isSmall: isSmall,
        ),
        SizedBox(height: isSmall ? 12 : 16),
        _Timeline(
          steps: steps,
          isSmall: isSmall,
          isMedium: isMedium,
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Supporting widgets (unchanged from original)
// ────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int stepCount;
  final StepMode mode;
  final bool isSmall;

  const _Header({
    required this.stepCount,
    required this.mode,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: isSmall ? 4 : 6,
      runSpacing: 6,
      children: [
        Icon(
          Icons.school_rounded,
          size: isSmall ? 12 : 13,
          color: MidpointTheme.accent(context).withValues(alpha: 0.6),
        ),
        Text(
          'Solution',
          style: TextStyle(
            fontSize: isSmall ? 11 : 12,
            fontWeight: FontWeight.w700,
            color: MidpointTheme.accent(context).withValues(alpha: 0.6),
            letterSpacing: 0.2,
          ),
        ),
        _Chip(label: '$stepCount steps', isSmall: isSmall),
        _Chip(
          label: mode == StepMode.midpoint ? 'Find Midpoint' : 'Find Endpoint',
          isSmall: isSmall,
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSmall;

  const _Chip({required this.label, required this.isSmall});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 7,
        vertical: isSmall ? 1.5 : 2,
      ),
      decoration: BoxDecoration(
        color: MidpointTheme.accent(context).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isSmall ? 9 : 10,
          fontWeight: FontWeight.w700,
          color: MidpointTheme.accent(context).withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final List<StepSection> steps;
  final bool isSmall;
  final bool isMedium;

  const _Timeline({
    required this.steps,
    required this.isSmall,
    required this.isMedium,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++)
          _StepRow(
            step: steps[i],
            isLast: i == steps.length - 1,
            isSmall: isSmall,
            isMedium: isMedium,
          ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  final StepSection step;
  final bool isLast;
  final bool isSmall;
  final bool isMedium;

  const _StepRow({
    required this.step,
    required this.isLast,
    required this.isSmall,
    required this.isMedium,
  });

  @override
  Widget build(BuildContext context) {
    final dotSize = isSmall ? 26.0 : 30.0;
    final spacing = isSmall ? 10.0 : 14.0;
    final bottomPadding = isLast ? 0.0 : (isSmall ? 20.0 : 28.0);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimelineDot(
            label: step.stepLabel.replaceAll(RegExp(r'[^0-9]'), ''),
            isLast: isLast,
            size: dotSize,
            isSmall: isSmall,
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _GuideLabel(
                  stepLabel: step.stepLabel,
                  guide: step.guide,
                  isSmall: isSmall,
                ),
                SizedBox(height: isSmall ? 6 : 8),
                if (step.kind == _StepKind.single)
                  _SingleMathBox(
                    step: step,
                    isSmall: isSmall,
                    isMedium: isMedium,
                  )
                else
                  _DualCaseRow(
                    step: step,
                    isSmall: isSmall,
                    isMedium: isMedium,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineDot extends StatelessWidget {
  final String label;
  final bool isLast;
  final double size;
  final bool isSmall;

  const _TimelineDot({
    required this.label,
    required this.isLast,
    required this.size,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: MidpointTheme.accent(context).withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: MidpointTheme.accent(context).withValues(alpha: 0.4),
              width: isSmall ? 1.2 : 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 10 : 12,
              fontWeight: FontWeight.w900,
              color: MidpointTheme.accent(context),
            ),
          ),
        ),
        if (!isLast)
          Container(
            width: isSmall ? 1.5 : 2,
            height: isSmall ? 50 : 70,
            margin: EdgeInsets.symmetric(vertical: isSmall ? 2 : 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  MidpointTheme.accent(context).withValues(alpha: 0.3),
                  MidpointTheme.accent(context).withValues(alpha: 0.04),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _GuideLabel extends StatelessWidget {
  final String stepLabel;
  final String guide;
  final bool isSmall;

  const _GuideLabel({
    required this.stepLabel,
    required this.guide,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: stepLabel,
            style: TextStyle(
              fontSize: isSmall ? 9 : 10,
              fontWeight: FontWeight.w700,
              color: MidpointTheme.accent(context).withValues(alpha: 0.5),
              letterSpacing: 0.6,
            ),
          ),
          TextSpan(
            text: '  ·  ',
            style: TextStyle(
              fontSize: isSmall ? 9 : 10,
              color: MidpointTheme.text40(context),
            ),
          ),
          TextSpan(
            text: guide,
            style: TextStyle(
              fontSize: isSmall ? 12 : 13,
              fontWeight: FontWeight.w700,
              color: MidpointTheme.text(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _SingleMathBox extends StatelessWidget {
  final StepSection step;
  final bool isSmall;
  final bool isMedium;

  const _SingleMathBox({
    required this.step,
    required this.isSmall,
    required this.isMedium,
  });

  @override
  Widget build(BuildContext context) {
    final padding = isSmall ? 10.0 : 14.0;
    final fontSize = isSmall ? 13.0 : (isMedium ? 14.0 : 15.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
      decoration: BoxDecoration(
        color: MidpointTheme.accent(context).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 10),
        border: Border.all(
          color: MidpointTheme.accent(context).withValues(alpha: 0.2),
        ),
      ),
      child: step.latexContent != null
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableMath.tex(
                step.latexContent!,
                textStyle: TextStyle(
                  fontSize: fontSize,
                  color: MidpointTheme.text(context),
                ),
              ),
            )
          : Text(
              step.plainContent!,
              style: TextStyle(
                fontSize: isSmall ? 12 : 13,
                height: 1.75,
                color: MidpointTheme.text50(context),
                fontWeight: FontWeight.w500,
                fontFamily: 'monospace',
              ),
            ),
    );
  }
}

class _DualCaseRow extends StatelessWidget {
  final StepSection step;
  final bool isSmall;
  final bool isMedium;

  const _DualCaseRow({
    required this.step,
    required this.isSmall,
    required this.isMedium,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 340) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CasePanel(
            label: step.leftLabel!,
            latex: step.leftLatex!,
            isSmall: isSmall,
            isMedium: isMedium,
          ),
          SizedBox(height: isSmall ? 8 : 10),
          _CasePanel(
            label: step.rightLabel!,
            latex: step.rightLatex!,
            isSmall: isSmall,
            isMedium: isMedium,
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _CasePanel(
            label: step.leftLabel!,
            latex: step.leftLatex!,
            isSmall: isSmall,
            isMedium: isMedium,
          ),
        ),
        SizedBox(width: isSmall ? 6 : 10),
        Expanded(
          child: _CasePanel(
            label: step.rightLabel!,
            latex: step.rightLatex!,
            isSmall: isSmall,
            isMedium: isMedium,
          ),
        ),
      ],
    );
  }
}

class _CasePanel extends StatelessWidget {
  final String label;
  final String latex;
  final bool isSmall;
  final bool isMedium;

  const _CasePanel({
    required this.label,
    required this.latex,
    required this.isSmall,
    required this.isMedium,
  });

  @override
  Widget build(BuildContext context) {
    final headerPadding = isSmall
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 7);
    final bodyPadding = isSmall
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 10)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 14);
    final fontSize = isSmall ? 12.0 : (isMedium ? 13.0 : 14.0);
    final labelSize = isSmall ? 10.0 : 11.0;

    return Container(
      decoration: BoxDecoration(
        color: MidpointTheme.accent(context).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 10),
        border: Border.all(
          color: MidpointTheme.accent(context).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: headerPadding,
            decoration: BoxDecoration(
              color: MidpointTheme.accent(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isSmall ? 8 : 10),
                topRight: Radius.circular(isSmall ? 8 : 10),
              ),
              border: Border(
                bottom: BorderSide(
                  color: MidpointTheme.accent(context).withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: labelSize,
                fontWeight: FontWeight.w700,
                color: MidpointTheme.accent(context),
                letterSpacing: 0.3,
              ),
            ),
          ),
          Padding(
            padding: bodyPadding,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableMath.tex(
                latex,
                textStyle: TextStyle(
                  fontSize: fontSize,
                  color: MidpointTheme.text(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard();

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 360;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 10),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: Colors.red.shade400, size: isSmall ? 16 : 18),
          SizedBox(width: isSmall ? 10 : 14),
          Expanded(
            child: Text(
              'Invalid input. Use whole numbers or fractions (e.g. 3, −2, 1/2).',
              style: TextStyle(
                fontSize: isSmall ? 12 : 13,
                height: 1.6,
                color: Colors.red.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}