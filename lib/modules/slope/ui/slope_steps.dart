import 'package:calculus_system/modules/slope/theme/slope_theme.dart';
import 'package:calculus_system/modules/slope/types/slope_solver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class SlopeSteps extends StatelessWidget {
  final SlopeSolverResult result;

  const SlopeSteps({super.key, required this.result});

  List<StepSection> _buildSteps() {
    final x1s = _fmtNum(result.x1);
    final y1s = _fmtNum(result.y1);
    final x2s = _fmtNum(result.x2);
    final y2s = _fmtNum(result.y2);
    final dy = result.deltaY;
    final dx = result.deltaX;
    final dys = _fmtNum(dy);
    final dxs = _fmtNum(dx);
    final slopeStr = result.slopeDisplay;

    if (result.isVertical) {
      return [
        StepSection.single(
          stepLabel: 'Step 1',
          guide: 'Identify points',
          plainContent: 'A = ($x1s, $y1s)\nB = ($x2s, $y2s)',
        ),
        StepSection.single(
          stepLabel: 'Step 2',
          guide: 'Check Δx',
          latexContent: r'\Delta x = x_2 - x_1 = ' '$x2s' r' - ' '$x1s' r' = 0',
        ),
        StepSection.single(
          stepLabel: 'Step 3',
          guide: 'Conclusion',
          latexContent: r'\Delta x = 0 \implies \text{Vertical line}',
        ),
        StepSection.single(
          stepLabel: 'Step 4',
          guide: 'Line equation',
          latexContent: r'x = ' '$x1s',
        ),
      ];
    }

    if (result.isHorizontal) {
      return [
        StepSection.single(
          stepLabel: 'Step 1',
          guide: 'Identify points',
          plainContent: 'A = ($x1s, $y1s)\nB = ($x2s, $y2s)',
        ),
        StepSection.single(
          stepLabel: 'Step 2',
          guide: 'Check Δy',
          latexContent: r'\Delta y = y_2 - y_1 = ' '$y2s' r' - ' '$y1s' r' = 0',
        ),
        StepSection.single(
          stepLabel: 'Step 3',
          guide: 'Conclusion',
          latexContent: r'\Delta y = 0 \implies m = 0',
        ),
        StepSection.single(
          stepLabel: 'Step 4',
          guide: 'Slope value',
          latexContent: r'm = 0',
        ),
      ];
    }

    return [
      StepSection.single(
        stepLabel: 'Step 1',
        guide: 'Identify points',
        plainContent:
            'A = ($x1s, $y1s)  →  (x₁, y₁)\nB = ($x2s, $y2s)  →  (x₂, y₂)',
      ),
      StepSection.single(
        stepLabel: 'Step 2',
        guide: 'Slope formula',
        latexContent: r'm = \dfrac{y_2 - y_1}{x_2 - x_1}',
      ),
      StepSection.dual(
        stepLabel: 'Step 3',
        guide: 'Find differences',
        leftLabel: 'Δy',
        rightLabel: 'Δx',
        leftLatex: r'\begin{aligned}'
            r'y_2 - y_1 &= '
            '$y2s'
            r' - ('
            '$y1s'
            r') \\'
            r'&= '
            '$dys'
            r'\end{aligned}',
        rightLatex: r'\begin{aligned}'
            r'x_2 - x_1 &= '
            '$x2s'
            r' - ('
            '$x1s'
            r') \\'
            r'&= '
            '$dxs'
            r'\end{aligned}',
      ),
      StepSection.single(
        stepLabel: 'Step 4',
        guide: 'Calculate slope',
        latexContent: r'\begin{aligned}'
            r'm &= \dfrac{'
            '$dys'
            r'}{'
            '$dxs'
            r'} \\'
            r'&= '
            '$slopeStr'
            r'\end{aligned}',
      ),
      StepSection.single(
        stepLabel: 'Step 5',
        guide: 'Result',
        latexContent: r'm = ' '$slopeStr',
      ),
    ];
  }

  String _fmtNum(double n) {
    if (n == n.truncateToDouble()) return n.toInt().toString();
    return n.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
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
        _Header(stepCount: steps.length, isSmall: isSmall),
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

class SlopeComparisonSteps extends StatelessWidget {
  final SlopeComparisonResult comparison;
  final SlopeSolverResult result1;
  final SlopeSolverResult result2;

  const SlopeComparisonSteps({
    super.key,
    required this.comparison,
    required this.result1,
    required this.result2,
  });

  List<StepSection> _buildSteps() {
    final x1s1 = _fmtNum(result1.x1);
    final y1s1 = _fmtNum(result1.y1);
    final x2s1 = _fmtNum(result1.x2);
    final y2s1 = _fmtNum(result1.y2);
    final m1 = result1.slopeDisplay;

    final x1s2 = _fmtNum(result2.x1);
    final y1s2 = _fmtNum(result2.y1);
    final x2s2 = _fmtNum(result2.x2);
    final y2s2 = _fmtNum(result2.y2);
    final m2 = result2.slopeDisplay;

    final relLabel = comparison.isParallel
        ? 'Parallel'
        : comparison.isPerpendicular
            ? 'Perpendicular'
            : 'Neither';

    return [
      StepSection.dual(
        stepLabel: 'Step 1',
        guide: 'Line 1 points & slope',
        leftLabel: 'Line 1 Points',
        rightLabel: 'Slope',
        leftLatex: r'\begin{aligned}'
            r'&('
            '$x1s1'
            r', '
            '$y1s1'
            r') \\'
            r'&('
            '$x2s1'
            r', '
            '$y2s1'
            r')'
            r'\end{aligned}',
        rightLatex: r'm_1 = ' '$m1',
      ),
      StepSection.dual(
        stepLabel: 'Step 2',
        guide: 'Line 2 points & slope',
        leftLabel: 'Line 2 Points',
        rightLabel: 'Slope',
        leftLatex: r'\begin{aligned}'
            r'&('
            '$x1s2'
            r', '
            '$y1s2'
            r') \\'
            r'&('
            '$x2s2'
            r', '
            '$y2s2'
            r')'
            r'\end{aligned}',
        rightLatex: r'm_2 = ' '$m2',
      ),
      StepSection.single(
        stepLabel: 'Step 3',
        guide: 'Check relationship',
        latexContent: comparison.isParallel
            ? r'm_1 = m_2 \implies \text{Parallel}'
            : comparison.isPerpendicular
                ? r'm_1 \cdot m_2 = -1 \implies \text{Perpendicular}'
                : r'm_1 \neq m_2 \text{ and } m_1 \cdot m_2 \neq -1',
      ),
      StepSection.single(
        stepLabel: 'Step 4',
        guide: 'Result',
        latexContent: relLabel == 'Neither'
            ? r'\text{Neither parallel nor perpendicular}'
            : r'\text{' '$relLabel' r'}',
      ),
    ];
  }

  String _fmtNum(double n) {
    if (n == n.truncateToDouble()) return n.toInt().toString();
    return n.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
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
        _Header(stepCount: steps.length, isSmall: isSmall),
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

enum _StepKind { single, dual }

class _Header extends StatelessWidget {
  final int stepCount;
  final bool isSmall;

  const _Header({required this.stepCount, required this.isSmall});

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
          color: SlopeTheme.accentColor.withValues(alpha: 0.6),
        ),
        Text(
          'Solution',
          style: TextStyle(
            fontSize: isSmall ? 11 : 12,
            fontWeight: FontWeight.w700,
            color: SlopeTheme.accentColor.withValues(alpha: 0.6),
            letterSpacing: 0.2,
          ),
        ),
        _Chip(label: '$stepCount steps', isSmall: isSmall),
        _Chip(label: 'Find Slope', isSmall: isSmall),
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
        color: SlopeTheme.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isSmall ? 9 : 10,
          fontWeight: FontWeight.w700,
          color: SlopeTheme.accentColor.withValues(alpha: 0.7),
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
            color: SlopeTheme.accentColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: SlopeTheme.accentColor.withValues(alpha: 0.4),
              width: isSmall ? 1.2 : 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 10 : 12,
              fontWeight: FontWeight.w900,
              color: SlopeTheme.accentColor,
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
                  SlopeTheme.accentColor.withValues(alpha: 0.3),
                  SlopeTheme.accentColor.withValues(alpha: 0.04),
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
              color: SlopeTheme.accentColor.withValues(alpha: 0.5),
              letterSpacing: 0.6,
            ),
          ),
          TextSpan(
            text: '  ·  ',
            style: TextStyle(
              fontSize: isSmall ? 9 : 10,
              color: SlopeTheme.textSecondary(context).withValues(alpha: 0.4),
            ),
          ),
          TextSpan(
            text: guide,
            style: TextStyle(
              fontSize: isSmall ? 12 : 13,
              fontWeight: FontWeight.w700,
              color: SlopeTheme.textPrimary(context),
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
        color: SlopeTheme.accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 10),
        border: Border.all(
          color: SlopeTheme.accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: step.latexContent != null
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableMath.tex(
                step.latexContent!,
                textStyle: TextStyle(
                  fontSize: fontSize,
                  color: SlopeTheme.textPrimary(context),
                ),
              ),
            )
          : Text(
              step.plainContent!,
              style: TextStyle(
                fontSize: isSmall ? 12 : 13,
                height: 1.75,
                color: SlopeTheme.textSecondary(context).withValues(alpha: 0.5),
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
        color: SlopeTheme.accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 10),
        border: Border.all(
          color: SlopeTheme.accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: headerPadding,
            decoration: BoxDecoration(
              color: SlopeTheme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isSmall ? 8 : 10),
                topRight: Radius.circular(isSmall ? 8 : 10),
              ),
              border: Border(
                bottom: BorderSide(
                  color: SlopeTheme.accentColor.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: labelSize,
                fontWeight: FontWeight.w700,
                color: SlopeTheme.accentColor,
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
                  color: SlopeTheme.textPrimary(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
