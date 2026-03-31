import 'package:flutter/material.dart';
import '../Theme/midpointtheme.dart';
import '../Solver/midpointsolver.dart';

enum StepMode { midpoint, endpoint }

class StepSection {
  final String title;
  final String content;
  final bool isFormula;

  const StepSection({
    required this.title,
    required this.content,
    this.isFormula = false,
  });
}

class MidpointSteps extends StatelessWidget {
  final StepMode mode;

  /// Raw string inputs (may be fractions like "3/4" or decimals)
  final String rawAX;
  final String rawAY;
  final String rawBX;
  final String rawBY;

  /// Computed result fractions
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

  List<StepSection> get _steps {
    if (mode == StepMode.endpoint) {
      return [
        StepSection(
          title: 'Identify Given',
          content: 'Midpoint: (${_display(rawAX)}, ${_display(rawAY)})\n'
              'Known Point: (${_display(rawBX)}, ${_display(rawBY)})',
        ),
        StepSection(
          title: 'Find X Coordinate',
          content: 'x₂ = 2(${_display(rawAX)}) − ${_display(rawBX)} = $resX',
          isFormula: true,
        ),
        StepSection(
          title: 'Find Y Coordinate',
          content: 'y₂ = 2(${_display(rawAY)}) − ${_display(rawBY)} = $resY',
          isFormula: true,
        ),
        StepSection(
          title: 'Final Endpoint',
          content: '($resX, $resY)',
          isFormula: true,
        ),
      ];
    }

    return [
      StepSection(
        title: 'Identify Coordinates',
        content: 'Point A: (${_display(rawAX)}, ${_display(rawAY)})\n'
            'Point B: (${_display(rawBX)}, ${_display(rawBY)})',
      ),
      StepSection(
        title: 'Calculate X Midpoint',
        content: '(${_display(rawAX)} + ${_display(rawBX)}) / 2 = $resX',
        isFormula: true,
      ),
      StepSection(
        title: 'Calculate Y Midpoint',
        content: '(${_display(rawAY)} + ${_display(rawBY)}) / 2 = $resY',
        isFormula: true,
      ),
      StepSection(
        title: 'Final Midpoint',
        content: 'M = ($resX, $resY)',
        isFormula: true,
      ),
    ];
  }

  String _display(String raw) {
    final t = raw.trim();
    if (t.contains('/')) return t;
    final d = double.tryParse(t);
    if (d == null) return t;
    if (d == d.toInt()) return d.toInt().toString();
    return d
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
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
            color: MidpointTheme.accent(context).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: MidpointTheme.accent15(context)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.format_list_numbered_rounded,
                color: MidpointTheme.accent(context),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Solution Steps',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: MidpointTheme.accent(context),
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                '${steps.length} steps',
                style: TextStyle(
                  fontSize: 11,
                  color: MidpointTheme.text40(context),
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
                  color: step.title.contains('Final')
                      ? MidpointTheme.accent(context)
                      : MidpointTheme.accent(context).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: step.title.contains('Final')
                      ? null
                      : Border.all(color: MidpointTheme.accent30(context)),
                ),
                child: Center(
                  child: step.title.contains('Final')
                      ? Icon(Icons.check,
                          color: MidpointTheme.surface(context), size: 14)
                      : Text(
                          '$index',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: MidpointTheme.accent(context),
                          ),
                        ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: MidpointTheme.accent(context).withValues(alpha: 0.15),
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
                color: step.title.contains('Final')
                    ? MidpointTheme.accent(context).withValues(alpha: 0.08)
                    : MidpointTheme.card(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: step.title.contains('Final')
                      ? MidpointTheme.accent30(context)
                      : MidpointTheme.accent(context).withValues(alpha: 0.08),
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
                      color: step.title.contains('Final')
                          ? MidpointTheme.accent(context)
                          : MidpointTheme.text70(context),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: step.isFormula
                        ? const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10)
                        : EdgeInsets.zero,
                    decoration: step.isFormula
                        ? BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                    child: Text(
                      step.content,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: step.title.contains('Final')
                            ? MidpointTheme.text(context)
                            : MidpointTheme.text50(context),
                        fontWeight: step.title.contains('Final')
                            ? FontWeight.w600
                            : FontWeight.w500,
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