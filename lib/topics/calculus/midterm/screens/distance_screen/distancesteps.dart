import 'dart:math';
import 'package:calculus_system/shared/widgets/solution_step_card.dart';
import 'package:calculus_system/theme/app_design.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class RadicalResult {
  final int coefficient;
  final int radicand;
  final bool isPerfectSquare;
  final double decimalValue;
  const RadicalResult({
    required this.coefficient,
    required this.radicand,
    required this.isPerfectSquare,
    required this.decimalValue,
  });

  String toDecimalString() => decimalValue
      .toStringAsFixed(4)
      .replaceAll(RegExp(r'0+$'), '')
      .replaceAll(RegExp(r'\.$'), '');
}

class DistanceSteps extends StatelessWidget {
  final bool is2D;
  final double x1;
  final double? y1;
  final double x2;
  final double? y2;
  final double distance;

  const DistanceSteps({
    super.key,
    required this.is2D,
    required this.x1,
    this.y1,
    required this.x2,
    this.y2,
    required this.distance,
  });

  String _fmt(double n) {
    if (n == n.toInt()) return n.toInt().toString();
    return n
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  String _signed(double n) {
    final s = _fmt(n);
    if (n < 0) return '($s)';
    return s;
  }

  RadicalResult _simplifyRadical(double value) {
    final int n = value.round();
    final double sqrtN = sqrt(n);
    if ((sqrtN - sqrtN.roundToDouble()).abs() < 1e-9) {
      return RadicalResult(
        coefficient: sqrtN.round(),
        radicand: 1,
        isPerfectSquare: true,
        decimalValue: sqrtN,
      );
    }
    int coefficient = 1;
    int remaining = n;
    for (int i = 2; i * i <= n; i++) {
      while (remaining % (i * i) == 0) {
        coefficient *= i;
        remaining ~/= (i * i);
      }
    }
    return RadicalResult(
      coefficient: coefficient,
      radicand: remaining,
      isPerfectSquare: false,
      decimalValue: sqrt(n),
    );
  }

  List<_Step> get _steps {
    if (!is2D) {
      final double diff = (x2 - x1).abs();
      return [
        const _Step(
          title: 'Write the formula',
          latex: r'd = |x_2 - x_1|',
          isResult: false,
        ),
        _Step(
          title: 'Substitute the given values',
          latex: 'd = \\left| ${_signed(x2)} - ${_signed(x1)} \\right|',
          isResult: false,
        ),
        _Step(
          title: 'Subtract inside absolute value',
          latex: 'd = \\left| ${_fmt(x2 - x1)} \\right|',
          isResult: false,
        ),
        _Step(
          title: 'Apply absolute value',
          latex: 'd = ${_fmt(diff)}',
          isResult: true,
        ),
      ];
    }

    final double dx = x2 - x1;
    final double dy = y2! - y1!;
    final double dx2 = dx * dx;
    final double dy2 = dy * dy;
    final double sum = dx2 + dy2;
    final RadicalResult radical = _simplifyRadical(sum);

    return [
      const _Step(
        title: 'Write the formula',
        latex: r'd = \sqrt{(x_2-x_1)^2 + (y_2-y_1)^2}',
        isResult: false,
      ),
      _Step(
        title: 'Substitute the given values',
        latex:
            'd = \\sqrt{\\left(${_signed(x2)}-${_signed(x1)}\\right)^2 + \\left(${_signed(y2!)}-${_signed(y1!)}\\right)^2}',
        isResult: false,
      ),
      _Step(
        title: 'Square each term',
        latex: 'd = \\sqrt{${_fmt(dx)}^2 + ${_fmt(dy)}^2}',
        isResult: false,
      ),
      _Step(
        title: 'Compute the squares',
        latex: 'd = \\sqrt{${_fmt(dx2)} + ${_fmt(dy2)}}',
        isResult: false,
      ),
      _Step(
        title: 'Add and take square root',
        latex: 'd = \\sqrt{${_fmt(sum)}}',
        isResult: false,
      ),
      ..._sqrtSteps(sum, radical),
    ];
  }

  List<_Step> _sqrtSteps(double sum, RadicalResult r) {
    final String sumStr = _fmt(sum);

    if (r.isPerfectSquare) {
      return [
        _Step(
          title: 'Take the square root',
          latex: 'd = \\sqrt{$sumStr} = ${r.coefficient}',
          isResult: true,
        ),
      ];
    }

    final bool canSimplify = r.coefficient > 1;

    if (canSimplify) {
      return [
        _Step(
          title: 'Simplify the radical',
          latex: '\\sqrt{$sumStr} = ${r.coefficient}\\sqrt{${r.radicand}}',
          isResult: false,
        ),
        _Step(
          title: 'Approximate the decimal value',
          latex:
              'd = ${r.coefficient}\\sqrt{${r.radicand}} \\approx ${r.toDecimalString()}',
          isResult: true,
        ),
      ];
    }

    return [
      _Step(
        title: 'Evaluate the square root',
        latex: 'd = \\sqrt{$sumStr} \\approx ${r.toDecimalString()}',
        isResult: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++)
          SolutionStepCard(
            design: AppDesign.app,
            stepNumber: i + 1,
            title: steps[i].title,
            mathContent: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableMath.tex(
                steps[i].latex,
                textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      steps[i].isResult ? FontWeight.w600 : FontWeight.w500,
                  color: steps[i].isResult
                      ? FinalsTheme.primaryFor(context)
                      : FinalsTheme.textSecondary(context),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Step {
  final String title;
  final String latex;
  final bool isResult;
  const _Step({
    required this.title,
    required this.latex,
    required this.isResult,
  });
}
