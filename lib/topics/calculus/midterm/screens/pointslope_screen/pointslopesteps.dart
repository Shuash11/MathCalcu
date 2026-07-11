import 'package:calculus_system/topics/calculus/midterm/theme/pointslope_theme/pointslopetheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

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
        rightLatex = null;

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

  static List<StepSection> pointSlope({
    required String m,
    required String x1,
    required String y1,
    required String b,
    required String generalForm,
    required String standardForm,
  }) {
    final mSimplified = _simplifyFraction(m);
    final bSimplified = _simplifyFraction(b);

    final y1Abs = y1.startsWith('-') ? y1.substring(1) : y1;
    final y1Sign = y1.startsWith('-') ? '+' : '-';
    final x1Abs = x1.startsWith('-') ? x1.substring(1) : x1;
    final x1Sign = x1.startsWith('-') ? '+' : '-';

    return [
      StepSection.single(
        stepLabel: 'Step 1',
        guide: 'Identify given values',
        plainContent: 'Point:  ($x1, $y1)\nSlope:  m = $m',
      ),
      StepSection.single(
        stepLabel: 'Step 2',
        guide: 'Point-Slope formula',
        latexContent: r'y - y_1 = m(x - x_1)',
      ),
      StepSection.single(
        stepLabel: 'Step 3',
        guide: 'Substitute values',
        latexContent: r'y ' +
            y1Sign +
            r' ' +
            y1Abs +
            r' = ' +
            (mSimplified.contains('/') ? '(' : '') +
            mSimplified +
            (mSimplified.contains('/') ? ')' : '') +
            r'(x ' +
            x1Sign +
            r' ' +
            x1Abs +
            r')',
      ),
      StepSection.dual(
        stepLabel: 'Step 4',
        guide: 'Distribute slope (m)',
        leftLabel: 'Expanded form',
        rightLabel: 'Simplify',
        leftLatex: r'\begin{aligned}'
                r'y ' +
            y1Sign +
            r' ' +
            y1Abs +
            r' &= ' +
            (mSimplified.contains('/') ? '(' : '') +
            mSimplified +
            (mSimplified.contains('/') ? ')' : '') +
            (mSimplified.contains('/') ? r' \cdot x + ' : r'x + ') +
            (mSimplified.contains('/') ? '(' : '') +
            mSimplified +
            (mSimplified.contains('/') ? ')' : '') +
            r' \cdot (' +
            x1Sign +
            r' ' +
            x1Abs +
            r')'
                r' \\'
                r'y ' +
            y1Sign +
            r' ' +
            y1Abs +
            r' &= ' +
            (mSimplified.contains('/') ? '(' : '') +
            mSimplified +
            (mSimplified.contains('/') ? ')' : '') +
            (mSimplified.contains('/') ? r' \cdot x + ' : r'x + ') +
            (mSimplified.contains('/') ? '(' : '') +
            mSimplified +
            (mSimplified.contains('/') ? ')' : '') +
            r' \cdot (' +
            x1 +
            r')'
                r'\end{aligned}',
        rightLatex: _buildStep4RightLatex(m, x1, y1Sign, y1Abs, mSimplified),
      ),
      StepSection.single(
        stepLabel: 'Step 5',
        guide: 'Solve for y (Slope-Intercept)',
        latexContent: r'y = ' +
            (mSimplified.contains('/') ? '(' : '') +
            mSimplified +
            (mSimplified.contains('/') ? ')' : '') +
            (mSimplified.contains('/') ? r' \cdot ' : '') +
            r'x ' +
            (int.parse(b) >= 0 ? '+' : r'-') +
            r' ' +
            bSimplified.replaceAll('-', ''),
      ),
      StepSection.single(
        stepLabel: 'Step 6',
        guide: 'General Form (Ax + By + C = 0)',
        latexContent: generalForm,
      ),
      StepSection.single(
        stepLabel: 'Step 7',
        guide: 'Standard Form (Ax + By = C)',
        latexContent: standardForm,
      ),
    ];
  }

  static String _simplifyFraction(String frac) {
    if (!frac.contains('/')) return frac;
    final parts = frac.split('/');
    if (parts.length == 2) {
      final num = int.tryParse(parts[0]);
      final den = int.tryParse(parts[1]);
      if (num != null && den != null && den != 0) {
        final gcd = _gcd(num.abs(), den.abs());
        if (gcd > 1) {
          return '${num ~/ gcd}/${den ~/ gcd}';
        }
      }
    }
    return frac;
  }

  static int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  static String _buildStep4RightLatex(
      String m, String x1, String y1Sign, String y1Abs, String mSimplified) {
    final mVal = int.tryParse(m) ?? 0;
    final xVal = int.tryParse(x1) ?? 0;
    final product = mVal * xVal;
    final sign = product < 0 ? '+' : '-';
    final absVal = product.abs().toString();
    final mWithParens = mSimplified.contains('/') ? '($mSimplified)' : mSimplified;
    final mulSymbol = mSimplified.contains('/') ? r' \cdot ' : ' ';
    final latex = 'y $y1Sign $y1Abs &= $mWithParens$mulSymbol x $sign $absVal';
    return r'\begin{aligned}' + latex + r'\end{aligned}';
  }
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

  List<StepSection> _buildSteps() {
    return _StepBuilder.pointSlope(
      m: m,
      x1: x1,
      y1: y1,
      b: b,
      generalForm: generalForm,
      standardForm: standardForm,
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps();

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;
    final isMedium = screenWidth < 400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Header(
          stepCount: steps.length,
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

class _Header extends StatelessWidget {
  final int stepCount;
  final bool isSmall;

  const _Header({
    required this.stepCount,
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
          color: PSTheme.electricPurple.withValues(alpha: 0.6),
        ),
        Text(
          'Solution',
          style: TextStyle(
            fontSize: isSmall ? 11 : 12,
            fontWeight: FontWeight.w700,
            color: PSTheme.electricPurple.withValues(alpha: 0.6),
            letterSpacing: 0.2,
          ),
        ),
        _Chip(label: '$stepCount steps', isSmall: isSmall),
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
        color: PSTheme.deepViolet.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isSmall ? 9 : 10,
          fontWeight: FontWeight.w700,
          color: PSTheme.deepViolet.withValues(alpha: 0.7),
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
            color: PSTheme.deepViolet.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: PSTheme.deepViolet.withValues(alpha: 0.4),
              width: isSmall ? 1.2 : 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 10 : 12,
              fontWeight: FontWeight.w900,
              color: PSTheme.deepViolet,
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
                  PSTheme.deepViolet.withValues(alpha: 0.3),
                  PSTheme.deepViolet.withValues(alpha: 0.04),
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
              color: PSTheme.electricPurple.withValues(alpha: 0.5),
              letterSpacing: 0.6,
            ),
          ),
          TextSpan(
            text: '  Â·  ',
            style: TextStyle(
              fontSize: isSmall ? 9 : 10,
              color: PSTheme.softLavender.withValues(alpha: 0.4),
            ),
          ),
          TextSpan(
            text: guide,
            style: TextStyle(
              fontSize: isSmall ? 12 : 13,
              fontWeight: FontWeight.w700,
              color: PSTheme.isLight(context) ? Colors.black87 : Colors.white,
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
        color: PSTheme.deepViolet.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 10),
        border: Border.all(
          color: PSTheme.deepViolet.withValues(alpha: 0.2),
        ),
      ),
      child: step.latexContent != null
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableMath.tex(
                step.latexContent!,
                textStyle: TextStyle(
                  fontSize: fontSize,
                  color:
                      PSTheme.isLight(context) ? Colors.black87 : Colors.white,
                ),
              ),
            )
          : Text(
              step.plainContent!,
              style: TextStyle(
                fontSize: isSmall ? 12 : 13,
                height: 1.75,
                color: PSTheme.isLight(context)
                    ? Colors.black54
                    : Colors.white.withValues(alpha: 0.5),
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
        color: PSTheme.deepViolet.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 10),
        border: Border.all(
          color: PSTheme.deepViolet.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: headerPadding,
            decoration: BoxDecoration(
              color: PSTheme.deepViolet.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isSmall ? 8 : 10),
                topRight: Radius.circular(isSmall ? 8 : 10),
              ),
              border: Border(
                bottom: BorderSide(
                  color: PSTheme.deepViolet.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: labelSize,
                fontWeight: FontWeight.w700,
                color: PSTheme.deepViolet,
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
                  color:
                      PSTheme.isLight(context) ? Colors.black87 : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
