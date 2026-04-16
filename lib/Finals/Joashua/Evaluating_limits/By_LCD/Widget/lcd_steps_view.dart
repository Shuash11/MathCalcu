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

  static const _doubleDollar = r'$$';
  static const _singleDollar = r'$';

  @override
  Widget build(BuildContext context) {
    final normalizedText = text
        .replaceAll(_doubleDollar, _doubleDollar)
        .replaceAll(_singleDollar, _singleDollar);

    if (!normalizedText.contains(_doubleDollar)) {
      return Text(
        normalizedText.trim(),
        style: FinalsTheme.subtitleStyle(context).copyWith(
          fontSize: 14,
          color: FinalsTheme.textPrimary(context).withValues(alpha: 0.9),
          height: 1.5,
        ),
      );
    }
    final List<String> blockParts = normalizedText.split(_doubleDollar);
    final List<Widget> children = [];

    for (int i = 0; i < blockParts.length; i++) {
      final part = blockParts[i].trim();
      if (part.isEmpty) continue;

      if (i % 2 == 1) {
        // == BLOCK MATH ($$) ==
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
              part,
              textStyle: FinalsTheme.titleStyle(context).copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              onErrorFallback: (err) => Text(part),
            ),
          ),
        ));
      } else {
        // == TEXT BLOCK (May contain inline math $ and bolding **) ==
        final List<String> inlineParts = part.split(r'$');
        final List<InlineSpan> spans = [];

        for (int j = 0; j < inlineParts.length; j++) {
          final inlinePart = inlineParts[j];
          if (inlinePart.isEmpty) continue;

          if (j % 2 == 1) {
            // -- INLINE MATH ($) --
            spans.add(WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Math.tex(
                inlinePart,
                textStyle: FinalsTheme.subtitleStyle(context).copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: FinalsTheme.textPrimary(context),
                ),
                onErrorFallback: (err) => Text(inlinePart),
              ),
            ));
          } else {
            // -- PLAIN TEXT with optional ** bolding --
            final regex = RegExp(r'\*\*(.*?)\*\*');
            int lastIndex = 0;

            for (final match in regex.allMatches(inlinePart)) {
              if (match.start > lastIndex) {
                spans.add(TextSpan(
                    text: inlinePart.substring(lastIndex, match.start)));
              }
              spans.add(TextSpan(
                text: match.group(1),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ));
              lastIndex = match.end;
            }
            if (lastIndex < inlinePart.length) {
              spans.add(TextSpan(text: inlinePart.substring(lastIndex)));
            }
          }
        }

        children.add(RichText(
          text: TextSpan(
            style: FinalsTheme.subtitleStyle(context).copyWith(
              fontSize: 14,
              color: FinalsTheme.textPrimary(context).withValues(alpha: 0.9),
              height: 1.5,
            ),
            children: spans,
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
