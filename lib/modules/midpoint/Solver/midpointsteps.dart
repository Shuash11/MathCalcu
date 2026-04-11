import 'package:calculus_system/modules/midpoint/Solver/midpointsolver.dart';
import 'package:calculus_system/modules/midpoint/Theme/midpointtheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

// ---------------------------------------------------------------------------
// ENUMS
// ---------------------------------------------------------------------------

enum StepMode { midpoint, endpoint }

// ---------------------------------------------------------------------------
// DATA MODEL
// ---------------------------------------------------------------------------
// A step is either:
//   • single  — one full-width math box  (StepKind.single)
//   • dual    — two side-by-side case boxes (StepKind.dual)
// ---------------------------------------------------------------------------

enum _StepKind { single, dual }

class StepSection {
  final String stepLabel;

  /// Short guide label shown next to the step number.
  final String guide;

  final _StepKind kind;

  // ── single step fields ────────────────────────────────────────────────────
  final String? latexContent;
  final String? plainContent;

  // ── dual step fields ──────────────────────────────────────────────────────
  /// Header label for the left panel, e.g. "x-coordinate"
  final String? leftLabel;

  /// Header label for the right panel, e.g. "y-coordinate"
  final String? rightLabel;

  /// LaTeX for the left case panel.
  final String? leftLatex;

  /// LaTeX for the right case panel.
  final String? rightLatex;

  // Single constructor
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

  // Dual constructor
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

// ---------------------------------------------------------------------------
// STEP BUILDER — pure logic, zero widgets
// ---------------------------------------------------------------------------

class _StepBuilder {
  const _StepBuilder._();

  // ── Midpoint mode ─────────────────────────────────────────────────────────
  //
  // Steps:
  //   1. Identify endpoints          — single (plain text)
  //   2. Midpoint formula            — single (LaTeX)
  //   3. Add both coordinates        — DUAL  (x left | y right)
  //   4. Compute xₘ and yₘ          — DUAL  (x left | y right)
  //   5. Final answer + verify       — single (LaTeX)

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

    return [
      StepSection.single(
        stepLabel: 'Step 1',
        guide: 'Identify endpoints',
        plainContent: 'A = ($x1,  $y1)   →   (x₁, y₁)\n'
            'B = ($x2,  $y2)   →   (x₂, y₂)',
      ),
      const StepSection.single(
        stepLabel: 'Step 2',
        guide: 'Midpoint formula',
        latexContent:
            r'M = \left(\dfrac{x_1+x_2}{2},\;\dfrac{y_1+y_2}{2}\right)',
      ),
      // ── DUAL: add both coordinates side-by-side ──────────────────────────
      StepSection.dual(
        stepLabel: 'Step 3',
        guide: 'Add both coordinates',
        leftLabel: 'x-coordinate',
        rightLabel: 'y-coordinate',
        leftLatex: '\\begin{aligned}'
            'x_1 + x_2 &= $x1 + $x2 \\\\'
            '&= $sumX'
            '\\end{aligned}',
        rightLatex: '\\begin{aligned}'
            'y_1 + y_2 &= $y1 + $y2 \\\\'
            '&= $sumY'
            '\\end{aligned}',
      ),
      // ── DUAL: divide both by 2 side-by-side ─────────────────────────────
      StepSection.dual(
        stepLabel: 'Step 4',
        guide: 'Divide by 2',
        leftLabel: 'Find xₘ',
        rightLabel: 'Find yₘ',
        leftLatex: '\\begin{aligned}'
            'x_m &= \\dfrac{$sumX}{2} \\\\'
            '&= \\boxed{$resX}'
            '\\end{aligned}',
        rightLatex: '\\begin{aligned}'
            'y_m &= \\dfrac{$sumY}{2} \\\\'
            '&= \\boxed{$resY}'
            '\\end{aligned}',
      ),
      StepSection.single(
        stepLabel: 'Step 5',
        guide: 'Answer + verify',
        latexContent: '\\begin{aligned}'
            'M &= \\left($resX,\\;$resY\\right)\\\\[8pt]'
            'x_m &= \\dfrac{$x1+$x2}{2} = $resX \\;\\checkmark \\\\'
            'y_m &= \\dfrac{$y1+$y2}{2} = $resY \\;\\checkmark'
            '\\end{aligned}',
      ),
    ];
  }

  // ── Endpoint mode ─────────────────────────────────────────────────────────
  //
  // Steps:
  //   1. Identify given values        — single (plain text)
  //   2. Midpoint formula             — single (LaTeX)
  //   3. Rearrange for endpoint       — single (LaTeX)
  //   4. Solve for x₂ and y₂         — DUAL  (x left | y right)
  //   5. Final answer + verify        — single (LaTeX)

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

    return [
      StepSection.single(
        stepLabel: 'Step 1',
        guide: 'Identify given values',
        plainContent: 'M = ($xm,  $ym)   →   midpoint\n'
            'A = ($x1,  $y1)   →   known endpoint\n'
            'B = (x₂, y₂)      →   find this',
      ),
      const StepSection.single(
        stepLabel: 'Step 2',
        guide: 'Midpoint formula',
        latexContent:
            r'M = \left(\dfrac{x_1+x_2}{2},\;\dfrac{y_1+y_2}{2}\right)',
      ),
      const StepSection.single(
        stepLabel: 'Step 3',
        guide: 'Rearrange for unknown endpoint',
        latexContent: r'''\begin{aligned}
x_2 &= 2x_m - x_1 \\
y_2 &= 2y_m - y_1
\end{aligned}''',
      ),
      // ── DUAL: solve x₂ and y₂ side-by-side ──────────────────────────────
      StepSection.dual(
        stepLabel: 'Step 4',
        guide: 'Solve both coordinates',
        leftLabel: 'Solve x₂',
        rightLabel: 'Solve y₂',
        leftLatex: '\\begin{aligned}'
            'x_2 &= 2($xm) - ($x1) \\\\'
            '&= $doubleXm - $x1 \\\\'
            '&= \\boxed{$resX}'
            '\\end{aligned}',
        rightLatex: '\\begin{aligned}'
            'y_2 &= 2($ym) - ($y1) \\\\'
            '&= $doubleYm - $y1 \\\\'
            '&= \\boxed{$resY}'
            '\\end{aligned}',
      ),
      StepSection.single(
        stepLabel: 'Step 5',
        guide: 'Answer + verify',
        latexContent: '\\begin{aligned}'
            'B &= \\left($resX,\\;$resY\\right)\\\\[8pt]'
            'x_m &= \\dfrac{$x1+$resX}{2} = $xm \\;\\checkmark \\\\'
            'y_m &= \\dfrac{$y1+$resY}{2} = $ym \\;\\checkmark'
            '\\end{aligned}',
      ),
    ];
  }
}

// ---------------------------------------------------------------------------
// ROOT WIDGET
// ---------------------------------------------------------------------------

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(stepCount: steps.length, mode: mode),
        const SizedBox(height: 16),
        _Timeline(steps: steps),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// HEADER
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final int stepCount;
  final StepMode mode;

  const _Header({required this.stepCount, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.school_rounded,
          size: 13,
          color: MidpointTheme.accent(context).withValues(alpha: 0.6),
        ),
        const SizedBox(width: 6),
        Text(
          'Solution',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: MidpointTheme.accent(context).withValues(alpha: 0.6),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(width: 6),
        _Chip(label: '$stepCount steps'),
        const SizedBox(width: 4),
        _Chip(
          label: mode == StepMode.midpoint ? 'Find Midpoint' : 'Find Endpoint',
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: MidpointTheme.accent(context).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: MidpointTheme.accent(context).withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TIMELINE
// ---------------------------------------------------------------------------

class _Timeline extends StatelessWidget {
  final List<StepSection> steps;
  const _Timeline({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++)
          _StepRow(
            step: steps[i],
            isLast: i == steps.length - 1,
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// STEP ROW — dispatches to single or dual body
// ---------------------------------------------------------------------------

class _StepRow extends StatelessWidget {
  final StepSection step;
  final bool isLast;

  const _StepRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline column
        _Dot(
          label: step.stepLabel.replaceAll(RegExp(r'[^0-9]'), ''),
          isLast: isLast,
        ),
        const SizedBox(width: 14),

        // Content column
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GuideLabel(
                  stepLabel: step.stepLabel,
                  guide: step.guide,
                ),
                const SizedBox(height: 8),
                // Dispatch on kind
                if (step.kind == _StepKind.single)
                  _SingleMathBox(step: step)
                else
                  _DualCaseRow(step: step),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// DOT + CONNECTOR LINE
// ---------------------------------------------------------------------------

class _Dot extends StatelessWidget {
  final String label;
  final bool isLast;

  const _Dot({required this.label, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: MidpointTheme.accent(context).withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: MidpointTheme.accent(context).withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: MidpointTheme.accent(context),
            ),
          ),
        ),
        if (!isLast)
          Container(
            width: 2,
            height: 90,
            margin: const EdgeInsets.symmetric(vertical: 3),
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

// ---------------------------------------------------------------------------
// GUIDE LABEL  — "Step N  ·  <guide>"
// ---------------------------------------------------------------------------

class _GuideLabel extends StatelessWidget {
  final String stepLabel;
  final String guide;

  const _GuideLabel({required this.stepLabel, required this.guide});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: stepLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: MidpointTheme.accent(context).withValues(alpha: 0.5),
              letterSpacing: 0.6,
            ),
          ),
          TextSpan(
            text: '  ·  ',
            style: TextStyle(
              fontSize: 10,
              color: MidpointTheme.text40(context),
            ),
          ),
          TextSpan(
            text: guide,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: MidpointTheme.text(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SINGLE MATH BOX  — full width, one formula
// ---------------------------------------------------------------------------

class _SingleMathBox extends StatelessWidget {
  final StepSection step;
  const _SingleMathBox({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: MidpointTheme.accent(context).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
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
                  fontSize: 15,
                  color: MidpointTheme.text(context),
                ),
              ),
            )
          : Text(
              step.plainContent!,
              style: TextStyle(
                fontSize: 13,
                height: 1.75,
                color: MidpointTheme.text50(context),
                fontWeight: FontWeight.w500,
                fontFamily: 'monospace',
              ),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// DUAL CASE ROW  — two panels side-by-side, mirroring the screenshot layout
//
// Each panel has:
//   • a small case label header  (e.g. "x-coordinate")
//   • the full math steps below it
//
// Both panels share equal width via Expanded + a visible gap between them.
// ---------------------------------------------------------------------------

class _DualCaseRow extends StatelessWidget {
  final StepSection step;
  const _DualCaseRow({required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left panel
        Expanded(
          child: _CasePanel(
            label: step.leftLabel!,
            latex: step.leftLatex!,
          ),
        ),
        const SizedBox(width: 10),
        // Right panel
        Expanded(
          child: _CasePanel(
            label: step.rightLabel!,
            latex: step.rightLatex!,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// CASE PANEL  — individual panel inside a dual step
// ---------------------------------------------------------------------------

class _CasePanel extends StatelessWidget {
  final String label;
  final String latex;

  const _CasePanel({required this.label, required this.latex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MidpointTheme.accent(context).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: MidpointTheme.accent(context).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Case label header — thin accent strip at top
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: MidpointTheme.accent(context).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
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
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: MidpointTheme.accent(context),
                letterSpacing: 0.3,
              ),
            ),
          ),

          // Math body
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableMath.tex(
                latex,
                textStyle: TextStyle(
                  fontSize: 14,
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

// ---------------------------------------------------------------------------
// ERROR CARD
// ---------------------------------------------------------------------------

class _ErrorCard extends StatelessWidget {
  const _ErrorCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Text(
        'Invalid input. Use whole numbers or fractions (e.g. 3, −2, 1/2).',
        style: TextStyle(
          fontSize: 13,
          height: 1.6,
          color: Colors.red.shade400,
        ),
      ),
    );
  }
}
