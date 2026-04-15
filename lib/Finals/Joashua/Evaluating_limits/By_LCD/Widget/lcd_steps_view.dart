import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class LCDStepsView extends StatelessWidget {
  final List<String> steps;

  const LCDStepsView({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        return _StepTile(
          step: steps[index],
          index: index,
          isLast: index == steps.length - 1,
        );
      },
    );
  }
}

class _StepTile extends StatelessWidget {
  final String step;
  final int index;
  final bool isLast;

  const _StepTile({
    required this.step,
    required this.index,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = FinalsTheme.danger;

    return Stack(
      children: [
        // Timeline line
        if (!isLast)
          Positioned(
            left: 15.25, // 32/2 - 1.5/2
            top: 28, // 24 height + 4 margin
            bottom: 4, // 4 margin
            child: Container(
              width: 1.5,
              color: accentColor.withValues(alpha: 0.15),
            ),
          ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            SizedBox(
              width: 32,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: accentColor.withValues(alpha: 0.4), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    (index + 1).toString(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Step content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FormattedStepText(text: step),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FormattedStepText extends StatelessWidget {
  final String text;

  const _FormattedStepText({required this.text});

  @override
  Widget build(BuildContext context) {
    if (!text.contains('\$\$')) {
      return Text(
        text.trim(),
        style: FinalsTheme.subtitleStyle(context).copyWith(
          fontSize: 14,
          color: FinalsTheme.textPrimary(context).withValues(alpha: 0.9),
          height: 1.5,
        ),
      );
    }

    final parts = text.split('\$\$');
    final children = <Widget>[];

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].trim().isEmpty) continue;

      if (i % 2 == 1) {
        // Math block
        children.add(Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: FinalsTheme.cardSecondary(context),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: FinalsTheme.danger.withValues(alpha: 0.1)),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Math.tex(
              parts[i].trim(),
              textStyle: FinalsTheme.titleStyle(context).copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              onErrorFallback: (err) => Text(parts[i].trim()),
            ),
          ),
        ));
      } else {
        // Text block
        children.add(Text(
          parts[i].trim(),
          style: FinalsTheme.subtitleStyle(context).copyWith(
            fontSize: 14,
            color: FinalsTheme.textPrimary(context).withValues(alpha: 0.9),
            height: 1.5,
          ),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
