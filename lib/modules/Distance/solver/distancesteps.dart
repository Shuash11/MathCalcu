import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/distancetheme.dart';

/// Step data model for distance calculation breakdown
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

/// Helper class for radical simplification
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

  @override
  String toString() {
    if (isPerfectSquare) return coefficient.toString();
    if (coefficient == 1) return '√$radicand';
    return '$coefficient√$radicand';
  }

  String toDecimalString() => decimalValue.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
}

/// Displays detailed calculation steps with expandable sections
class DistanceSteps extends StatelessWidget {
  final bool is2D;
  final double x1;
  final double? y1;
  final double x2;
  final double? y2;
  final double distance;
  final bool showImmediately;

  const DistanceSteps({
    super.key,
    required this.is2D,
    required this.x1,
    this.y1,
    required this.x2,
    this.y2,
    required this.distance,
    this.showImmediately = false,
  });

  /// Simplify √n to a√b form where b has no perfect square factors
  RadicalResult _simplifyRadical(double value) {
    if (value < 0) return RadicalResult(coefficient: 0, radicand: 0, isPerfectSquare: false, decimalValue: value);
    
    final int n = value.round();
    final double sqrtN = sqrt(n);
    
    // Check if perfect square
    if (sqrtN == sqrtN.roundToDouble()) {
      return RadicalResult(
        coefficient: sqrtN.round(),
        radicand: 1,
        isPerfectSquare: true,
        decimalValue: sqrtN,
      );
    }

    // Find largest perfect square factor
    int largestSquare = 1;
    int remaining = n;
    
    for (int i = 2; i * i <= n; i++) {
      while (remaining % (i * i) == 0) {
        largestSquare *= i;
        remaining ~/= (i * i);
      }
    }

    return RadicalResult(
      coefficient: largestSquare,
      radicand: remaining,
      isPerfectSquare: false,
      decimalValue: sqrt(n),
    );
  }

  String _format(double n) {
    if (n == n.toInt()) return n.toInt().toString();
    return n.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  List<StepSection> get _steps {
    if (is2D) {
      final double dy = (y2! - y1!);
      final double dx = (x2 - x1);
      final double dySquared = dy * dy;
      final double dxSquared = dx * dx;
      final double sum = dxSquared + dySquared;
      
      // Simplify the final radical
      final radical = _simplifyRadical(sum);

      return [
        StepSection(
          title: 'Identify Coordinates',
          content: 'Point A: (${_format(x1)}, ${_format(y1!)})\nPoint B: (${_format(x2)}, ${_format(y2!)})',
        ),
        StepSection(
          title: 'Calculate Differences',
          content: 'x = ${_format(x2)} − ${_format(x1)} = ${_format(dx)}\nΔy = ${_format(y2!)} − ${_format(y1!)} = ${_format(dy)}',
        ),
        StepSection(
          title: 'Square the Differences',
          content: '(x)² = ${_format(dx)}² = ${_format(dxSquared)}\n(y)² = ${_format(dy)}² = ${_format(dySquared)}',
          isFormula: true,
        ),
        StepSection(
          title: 'Sum the Squares',
          content: '${_format(dxSquared)} + ${_format(dySquared)} = ${_format(sum)}',
          isFormula: true,
        ),
        StepSection(
          title: 'Simplify the Square Root',
          content: _buildRadicalExplanation(sum, radical),
          isFormula: true,
          isResult: true,
        ),
      ];
    } else {
      final double diff = (x2 - x1);
      final double absDiff = diff.abs();
      
      return [
        StepSection(
          title: 'Identify Points',
          content: 'Point 1: x₁ = ${_format(x1)}\nPoint 2: x₂ = ${_format(x2)}',
        ),
        StepSection(
          title: 'Calculate Difference',
          content: 'x₂ − x₁ = ${_format(x2)} − ${_format(x1)} = ${_format(diff)}',
        ),
        StepSection(
          title: 'Apply Absolute Value',
          content: '|${_format(diff)}| = ${_format(absDiff)}',
          isFormula: true,
        ),
        StepSection(
          title: 'Final Distance',
          content: 'd = ${_format(absDiff)}',
          isResult: true,
        ),
      ];
    }
  }

  String _buildRadicalExplanation(double original, RadicalResult radical) {
    final buffer = StringBuffer();
    
    buffer.writeln('d = √${_format(original)}');
    
    if (radical.isPerfectSquare) {
      buffer.writeln('\nSince ${_format(original)} is a perfect square:');
      buffer.write('d = ${radical.coefficient}');
    } else if (radical.coefficient == 1) {
      buffer.writeln('\n${_format(original)} has no perfect square factors');
      buffer.write('d = √${_format(original)} ≈ ${radical.toDecimalString()}');
    } else {
      final int square = radical.coefficient * radical.coefficient;
      buffer.writeln('\nFactor out perfect square:');
      buffer.writeln('√${_format(original)} = √($square × ${radical.radicand})');
      buffer.writeln('= √$square × √${radical.radicand}');
      buffer.write('= ${radical.coefficient}√${radical.radicand}');
      
      if (radical.radicand > 1) {
        buffer.write(' ≈ ${radical.toDecimalString()}');
      }
    }
    
    return buffer.toString();
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
            color: DistanceTheme.accent.withValues(alpha :0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: DistanceTheme.accent15),
          ),
          child: Row(
            children: [
            const  Icon(
                Icons.format_list_numbered_rounded,
                color: DistanceTheme.accent,
                size: 18,
              ),
              const SizedBox(width: 8),
           const   Text(
                'Solution Steps',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: DistanceTheme.accent,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                '${steps.length} steps',
                style: TextStyle(
                  fontSize: 11,
                  color: DistanceTheme.text40(context),
                ),
              ),
            ],
          ),
        ),

        ...List.generate(steps.length, (index) {
          final step = steps[index];
          final isLast = index == steps.length - 1;

          return _StepItem(
            index: index + 1,
            step: step,
            isLast: isLast,
          );
        }),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  final int index;
  final StepSection step;
  final bool isLast;

  const _StepItem({
    required this.index,
    required this.step,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: step.isResult 
                      ? DistanceTheme.accent 
                      : DistanceTheme.accent.withValues(alpha :0.15),
                  shape: BoxShape.circle,
                  border: step.isResult 
                      ? null 
                      : Border.all(color: DistanceTheme.accent30),
                ),
                child: Center(
                  child: step.isResult
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : Text(
                          '$index',
                          style:const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: DistanceTheme.accent,
                          ),
                        ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: DistanceTheme.accent.withValues(alpha :0.15),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: step.isResult 
                    ? DistanceTheme.accent.withValues(alpha :0.08)
                    : DistanceTheme.card(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: step.isResult 
                      ? DistanceTheme.accent30 
                      : DistanceTheme.accent.withValues(alpha :0.08),
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
                      color: step.isResult ? DistanceTheme.accent : DistanceTheme.text70(context),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: step.isFormula 
                        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
                        : EdgeInsets.zero,
                    decoration: step.isFormula 
                        ? BoxDecoration(
                            color: Colors.black.withValues(alpha :0.2),
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                    child: Text(
                      step.content,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: step.isResult ? DistanceTheme.text(context) : DistanceTheme.text55(context),
                        fontWeight: step.isResult ? FontWeight.w600 : FontWeight.w500,
                        fontFamily: step.isFormula ? 'monospace' : null,
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