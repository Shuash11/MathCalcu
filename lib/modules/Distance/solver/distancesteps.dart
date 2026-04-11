import 'dart:math';
import 'package:calculus_system/modules/Distance/Theme/distancetheme.dart';
import 'package:flutter/material.dart';

class StepSection {
  final String title;
  final String content;
  final bool isFormula;
  final bool isResult;
  const StepSection({
    required this.title,
    required this.content,
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

  // Wraps a negative number in parentheses for clean display
  String _signed(double n) => n < 0 ? '(${_fmt(n)})' : _fmt(n);

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
    // ── 1D ──────────────────────────────────────────────
    if (!is2D) {
      final double diff = (x2 - x1).abs();
      return [
        const StepSection(
          title: 'Step 1 — Write the formula',
          content: 'd  =  | x2 - x1 |',
          isFormula: true,
        ),
        StepSection(
          title: 'Step 2 — Substitute the given values',
          content: 'd  =  | ${_signed(x2)} - ${_signed(x1)} |',
          isFormula: true,
        ),
        StepSection(
          title: 'Step 3 — Subtract inside the absolute value',
          content: 'd  =  | ${_fmt(x2 - x1)} |',
          isFormula: true,
        ),
        StepSection(
          title: 'Step 4 — Apply absolute value',
          content: 'd  =  ${_fmt(diff)}',
          isFormula: true,
          isResult: true,
        ),
      ];
    }

    // ── 2D ──────────────────────────────────────────────
    final double dx = x2 - x1;
    final double dy = y2! - y1!;
    final double dx2 = dx * dx;
    final double dy2 = dy * dy;
    final double sum = dx2 + dy2;
    final RadicalResult radical = _simplifyRadical(sum);

    return [
      // 1 — Formula
      const StepSection(
        title: 'Step 1 — Write the formula',
        content: 'd  =  √( (x2 - x1)²  +  (y2 - y1)² )',
        isFormula: true,
      ),

      // 2 — Substitute
      StepSection(
        title: 'Step 2 — Substitute the given values',
        content:
            'd  =  √( (${_signed(x2)} - ${_signed(x1)})²  +  (${_signed(y2!)} - ${_signed(y1!)})² )',
        isFormula: true,
      ),

      // 3 — Compute differences inside the parentheses
      StepSection(
        title: 'Step 3 — Compute the differences inside each parenthesis',
        content: 'x2 - x1  =  ${_signed(x2)} - ${_signed(x1)}  =  ${_fmt(dx)}\n'
            'y2 - y1  =  ${_signed(y2!)} - ${_signed(y1!)}  =  ${_fmt(dy)}\n\n'
            'd  =  √( (${_fmt(dx)})²  +  (${_fmt(dy)})² )',
        isFormula: true,
      ),

      // 4 — Square each difference
      StepSection(
        title: 'Step 4 — Square each difference',
        content: '(${_fmt(dx)})²  =  ${_fmt(dx2)}\n'
            '(${_fmt(dy)})²  =  ${_fmt(dy2)}\n\n'
            'd  =  √( ${_fmt(dx2)}  +  ${_fmt(dy2)} )',
        isFormula: true,
      ),

      // 5 — Add the squares
      StepSection(
        title: 'Step 5 — Add the squares under the sqrt',
        content: '${_fmt(dx2)}  +  ${_fmt(dy2)}  =  ${_fmt(sum)}\n\n'
            'd  =  √( ${_fmt(sum)} )',
        isFormula: true,
      ),

      // 6 — Evaluate the sqrt (branches here)
      ..._sqrtSteps(sum, radical),
    ];
  }

  /// Returns the final 1 or 2 steps depending on perfect square or not.
  List<StepSection> _sqrtSteps(double sum, RadicalResult r) {
    final String sumStr = _fmt(sum);

    // Perfect square — single result step, no approximation needed
    if (r.isPerfectSquare) {
      return [
        StepSection(
          title: 'Step 6 — Take the square root',
          content: 'sqrt( $sumStr ) is a perfect square\n\n'
              'd  =  ${r.coefficient}',
          isFormula: true,
          isResult: true,
        ),
      ];
    }

    // Not a perfect square — simplify radical first, then approximate
    final bool canSimplify = r.coefficient > 1;

    if (canSimplify) {
      return [
        StepSection(
          title: 'Step 6 — Simplify the radical',
          content: '√( $sumStr ) is not a perfect square\n\n'
              'Factor out the largest perfect square:\n'
              '√( $sumStr )  =  √( ${r.coefficient * r.coefficient} x ${r.radicand} )\n'
              '               =  ${r.coefficient} √( ${r.radicand} )',
          isFormula: true,
        ),
        StepSection(
          title: 'Step 7 — Approximate the decimal value',
          content: 'd  =  ${r.coefficient} √( ${r.radicand} )\n'
              'd  =  ${r.toDecimalString()}',
          isFormula: true,
          isResult: true,
        ),
      ];
    }

    // Cannot simplify — radical stays as-is, just approximate
    return [
      StepSection(
        title: 'Step 6 — Evaluate the square root',
        content: '√( $sumStr ) cannot be simplified further\n\n'
            'd  =  √( $sumStr )\n'
            'd  =  ${r.toDecimalString()}',
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
            const Text(
              'Distance Formula — Step by Step',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: DistanceTheme.accent,
              ),
            ),
            const Spacer(),
            Text(
              '${steps.length} steps',
              style:
                  TextStyle(fontSize: 11, color: DistanceTheme.text40(context)),
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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
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
              Expanded(
                child: Container(
                  width: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: DistanceTheme.accent.withValues(alpha: 0.15),
                ),
              ),
          ]),

          const SizedBox(width: 12),

          // Card
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
                  // Step title
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
                  const SizedBox(height: 8),
                  // Content block
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      step.content,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        height: 1.6,
                        fontWeight:
                            step.isResult ? FontWeight.w600 : FontWeight.w500,
                        color: step.isResult
                            ? DistanceTheme.text(context)
                            : DistanceTheme.text55(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
