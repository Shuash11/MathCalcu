import 'dart:math';
import 'package:calculus_system/topics/midterm/theme/distance_theme/distancetheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class StepSection {
  final String title;
  final String latex;
  final bool isFormula;
  final bool isResult;
  const StepSection({
    required this.title,
    required this.latex,
    this.isFormula = false,
    this.isResult = false,
  });
}

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

  List<StepSection> get _steps {
    if (!is2D) {
      final double diff = (x2 - x1).abs();
      return [
        const StepSection(
          title: 'Step 1 — Write the formula',
          latex: r'd = |x_2 - x_1|',
          isFormula: true,
        ),
        StepSection(
          title: 'Step 2 — Substitute the given values',
          latex: 'd = \\left| ${_signed(x2)} - ${_signed(x1)} \\right|',
          isFormula: true,
        ),
        StepSection(
          title: 'Step 3 — Subtract inside absolute value',
          latex: 'd = \\left| ${_fmt(x2 - x1)} \\right|',
          isFormula: true,
        ),
        StepSection(
          title: 'Step 4 — Apply absolute value',
          latex: 'd = ${_fmt(diff)}',
          isFormula: true,
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
      const StepSection(
        title: 'Step 1 — Write the formula',
        latex: r'd = \sqrt{(x_2-x_1)^2 + (y_2-y_1)^2}',
        isFormula: true,
      ),
      StepSection(
        title: 'Step 2 — Substitute the given values',
        latex: 'd = \\sqrt{\\left(${_signed(x2)}-${_signed(x1)}\\right)^2 + \\left(${_signed(y2!)}-${_signed(y1!)}\\right)^2}',
        isFormula: true,
      ),
      StepSection(
        title: 'Step 3 — Square each term',
        latex: 'd = \\sqrt{${_fmt(dx)}^2 + ${_fmt(dy)}^2}',
        isFormula: true,
      ),
      StepSection(
        title: 'Step 4 — Compute the squares',
        latex: 'd = \\sqrt{${_fmt(dx2)} + ${_fmt(dy2)}}',
        isFormula: true,
      ),
      StepSection(
        title: 'Step 5 — Add and take square root',
        latex: 'd = \\sqrt{${_fmt(sum)}}',
        isFormula: true,
      ),
      ..._sqrtSteps(sum, radical),
    ];
  }

  List<StepSection> _sqrtSteps(double sum, RadicalResult r) {
    final String sumStr = _fmt(sum);

    if (r.isPerfectSquare) {
      return [
        StepSection(
          title: 'Step 6 — Take the square root',
          latex: 'd = \\sqrt{$sumStr} = ${r.coefficient}',
          isFormula: true,
          isResult: true,
        ),
      ];
    }

    final bool canSimplify = r.coefficient > 1;

    if (canSimplify) {
      return [
        StepSection(
          title: 'Step 6 — Simplify the radical',
          latex: '\\sqrt{$sumStr} = ${r.coefficient}\\sqrt{${r.radicand}}',
          isFormula: true,
        ),
        StepSection(
          title: 'Step 7 — Approximate the decimal value',
          latex: 'd = ${r.coefficient}\\sqrt{${r.radicand}} \\approx ${r.toDecimalString()}',
          isFormula: true,
          isResult: true,
        ),
      ];
    }

    return [
      StepSection(
        title: 'Step 6 — Evaluate the square root',
        latex: 'd = \\sqrt{$sumStr} \\approx ${r.toDecimalString()}',
        isFormula: true,
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
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: DistanceTheme.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: DistanceTheme.accent15),
          ),
          child: Row(children: [
            const Icon(Icons.school_rounded,
                color: DistanceTheme.accent, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Distance Formula — Step by Step',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: DistanceTheme.accent,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${steps.length} steps',
              style: TextStyle(fontSize: 11, color: DistanceTheme.text40(context)),
            ),
          ]),
        ),
        ...List.generate(
          steps.length,
          (i) => _StepItem(
            step: steps[i],
            isLast: i == steps.length - 1,
          ),
        ),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  final StepSection step;
  final bool isLast;
  const _StepItem({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: step.isResult
                  ? DistanceTheme.accent
                  : DistanceTheme.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: step.isResult
                  ? null
                  : Border.all(color: DistanceTheme.accent30),
            ),
            child: Center(
              child: step.isResult
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : const Icon(Icons.edit_rounded,
                      color: DistanceTheme.accent, size: 13),
            ),
          ),
          if (!isLast)
            Container(
              width: 2,
              margin: const EdgeInsets.symmetric(vertical: 4),
              height: 50,
              color: DistanceTheme.accent.withValues(alpha: 0.15),
            ),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: step.isResult
                  ? DistanceTheme.accent.withValues(alpha: 0.08)
                  : DistanceTheme.card(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: step.isResult
                    ? DistanceTheme.accent30
                    : DistanceTheme.accent.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: step.isResult
                        ? DistanceTheme.accent
                        : DistanceTheme.text70(context),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SelectableMath.tex(
                      step.latex,
                      textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            step.isResult ? FontWeight.w600 : FontWeight.w500,
                        color: step.isResult
                            ? DistanceTheme.text(context)
                            : DistanceTheme.text55(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
