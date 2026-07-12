import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/slope_solver/slope_solver.dart';
import 'package:calculus_system/shared/widgets/solution_step_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

// ─────────────────────────────────────────────────────────────
// STEPS WIDGETS — MIGRATED TO SolutionStepCard
//
// Each step becomes a SolutionStepCard with:
// - stepNumber
// - title (the guide)
// - description (the step label, e.g. "Step 1")
// - mathContent (latex SelectableMath wrapped in scroll)
// ─────────────────────────────────────────────────────────────

class SlopeSteps extends StatelessWidget {
  final SlopeSolverResult result;

  const SlopeSteps({super.key, required this.result});

  List<Widget> _buildSteps(BuildContext context) {
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
      return _buildVerticalSteps(context, x1s, y1s, x2s, y2s);
    }

    if (result.isHorizontal) {
      return _buildHorizontalSteps(context, x1s, y1s, x2s, y2s);
    }

    return _buildGenericSteps(
        context, x1s, y1s, x2s, y2s, dys, dxs, slopeStr);
  }

  List<Widget> _buildVerticalSteps(
      BuildContext context, String x1s, String y1s, String x2s, String y2s) {
    return [
      SolutionStepCard(
        stepNumber: 1,
        title: 'Identify points',
        description: 'Step 1',
        mathContent: _mathText(context, 'A = ($x1s, $y1s)\nB = ($x2s, $y2s)'),
      ),
      SolutionStepCard(
        stepNumber: 2,
        title: 'Check Δx',
        description: 'Step 2',
        mathContent: _mathLatex(
          r'\Delta x = x_2 - x_1 = ' '$x2s' r' - ' '$x1s' r' = 0',
        ),
      ),
      SolutionStepCard(
        stepNumber: 3,
        title: 'Conclusion',
        description: 'Step 3',
        mathContent: _mathLatex(
          r'\Delta x = 0 \implies \text{Vertical line}',
        ),
      ),
      SolutionStepCard(
        stepNumber: 4,
        title: 'Line equation',
        description: 'Step 4',
        mathContent: _mathLatex(r'x = ' '$x1s'),
      ),
    ];
  }

  List<Widget> _buildHorizontalSteps(
      BuildContext context, String x1s, String y1s, String x2s, String y2s) {
    return [
      SolutionStepCard(
        stepNumber: 1,
        title: 'Identify points',
        description: 'Step 1',
        mathContent: _mathText(context, 'A = ($x1s, $y1s)\nB = ($x2s, $y2s)'),
      ),
      SolutionStepCard(
        stepNumber: 2,
        title: 'Check Δy',
        description: 'Step 2',
        mathContent: _mathLatex(
          r'\Delta y = y_2 - y_1 = ' '$y2s' r' - ' '$y1s' r' = 0',
        ),
      ),
      SolutionStepCard(
        stepNumber: 3,
        title: 'Conclusion',
        description: 'Step 3',
        mathContent: _mathLatex(r'\Delta y = 0 \implies m = 0'),
      ),
      SolutionStepCard(
        stepNumber: 4,
        title: 'Slope value',
        description: 'Step 4',
        mathContent: _mathLatex(r'm = 0'),
      ),
    ];
  }

  List<Widget> _buildGenericSteps(
      BuildContext context,
      String x1s,
      String y1s,
      String x2s,
      String y2s,
      String dys,
      String dxs,
      String slopeStr) {
    return [
      SolutionStepCard(
        stepNumber: 1,
        title: 'Identify points',
        description: 'Step 1',
        mathContent: _mathText(
            context, 'A = ($x1s, $y1s)  →  (x₁, y₁)\nB = ($x2s, $y2s)  →  (x₂, y₂)'),
      ),
      SolutionStepCard(
        stepNumber: 2,
        title: 'Slope formula',
        description: 'Step 2',
        mathContent: _mathLatex(r'm = \dfrac{y_2 - y_1}{x_2 - x_1}'),
      ),
      SolutionStepCard(
        stepNumber: 3,
        title: 'Find differences',
        description: 'Step 3',
        mathContent: Row(
          children: [
            Expanded(
              child: _mathLatex(
                r'\begin{aligned}'
                r'y_2 - y_1 &= '
                '$y2s'
                r' - ('
                '$y1s'
                r') \\'
                r'&= '
                '$dys'
                r'\end{aligned}',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _mathLatex(
                r'\begin{aligned}'
                r'x_2 - x_1 &= '
                '$x2s'
                r' - ('
                '$x1s'
                r') \\'
                r'&= '
                '$dxs'
                r'\end{aligned}',
              ),
            ),
          ],
        ),
      ),
      SolutionStepCard(
        stepNumber: 4,
        title: 'Calculate slope',
        description: 'Step 4',
        mathContent: _mathLatex(
          r'\begin{aligned}'
          r'm &= \dfrac{'
          '$dys'
          r'}{'
          '$dxs'
          r'} \\'
          r'&= '
          '$slopeStr'
          r'\end{aligned}',
        ),
      ),
      SolutionStepCard(
        stepNumber: 5,
        title: 'Result',
        description: 'Step 5',
        mathContent: _mathLatex(r'm = ' '$slopeStr'),
      ),
    ];
  }

  String _fmtNum(double n) {
    if (n == n.truncateToDouble()) return n.toInt().toString();
    return n.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: _buildSteps(context),
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

  List<Widget> _buildSteps() {
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
      SolutionStepCard(
        stepNumber: 1,
        title: 'Line 1 points & slope',
        description: 'Step 1',
        mathContent: Row(
          children: [
            Expanded(
              child: _mathLatex(
                r'\begin{aligned}'
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
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _mathLatex(r'm_1 = ' '$m1'),
            ),
          ],
        ),
      ),
      SolutionStepCard(
        stepNumber: 2,
        title: 'Line 2 points & slope',
        description: 'Step 2',
        mathContent: Row(
          children: [
            Expanded(
              child: _mathLatex(
                r'\begin{aligned}'
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
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _mathLatex(r'm_2 = ' '$m2'),
            ),
          ],
        ),
      ),
      SolutionStepCard(
        stepNumber: 3,
        title: 'Check relationship',
        description: 'Step 3',
        mathContent: _mathLatex(
          comparison.isParallel
              ? r'm_1 = m_2 \implies \text{Parallel}'
              : comparison.isPerpendicular
                  ? r'm_1 \cdot m_2 = -1 \implies \text{Perpendicular}'
                  : r'm_1 \neq m_2 \text{ and } m_1 \cdot m_2 \neq -1',
        ),
      ),
      SolutionStepCard(
        stepNumber: 4,
        title: 'Result',
        description: 'Step 4',
        mathContent: _mathLatex(
          relLabel == 'Neither'
              ? r'\text{Neither parallel nor perpendicular}'
              : r'\text{' '$relLabel' r'}',
        ),
      ),
    ];
  }

  String _fmtNum(double n) {
    if (n == n.truncateToDouble()) return n.toInt().toString();
    return n.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: _buildSteps(),
    );
  }
}
