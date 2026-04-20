import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class LCDStepsView extends StatelessWidget {
  final List<String> steps;

  const LCDStepsView({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    // This widget is already inside a parent scroll view.
    // Using Column avoids nested scrolling/render edge cases.
    final visibleSteps =
        steps.where((step) => step.trim().isNotEmpty).toList(growable: false);

    return Column(
      children: List.generate(
        visibleSteps.length,
        (index) => _StepTile(
          step: visibleSteps[index],
          index: index,
          isLast: index == visibleSteps.length - 1,
        ),
      ),
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
        if (!isLast)
          Positioned(
            left: 15.25,
            top: 28,
            bottom: 4,
            child: Container(
              width: 1.5,
              color: accentColor.withValues(alpha: 0.15),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 32,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _FormattedStepText(text: step),
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

  @override
  Widget build(BuildContext context) {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) {
      return const SizedBox.shrink();
    }

    if (!normalizedText.contains(_doubleDollar)) {
      return _InlineMathText(text: normalizedText);
    }

    final blockParts = normalizedText.split(_doubleDollar);
    final children = <Widget>[];

    for (int i = 0; i < blockParts.length; i++) {
      final part = blockParts[i].trim();
      if (part.isEmpty) continue;

      if (i % 2 == 1) {
        children.add(
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: FinalsTheme.cardSecondary(context),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: FinalsTheme.danger.withValues(alpha: 0.1)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(
                part,
                textStyle: FinalsTheme.titleStyle(context).copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                onErrorFallback: (err) {
                  return Text(
                    part,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: FinalsTheme.danger.withValues(alpha: 0.8),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      } else {
        children.add(_InlineMathText(text: part));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _InlineMathText extends StatelessWidget {
  final String text;

  const _InlineMathText({required this.text});

  @override
  Widget build(BuildContext context) {
    final inlineParts = text.split(r'$');
    final spans = <InlineSpan>[];

    for (int i = 0; i < inlineParts.length; i++) {
      final part = inlineParts[i];
      if (part.isEmpty) continue;

      if (i % 2 == 1) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Math.tex(
              part,
              textStyle: FinalsTheme.subtitleStyle(context).copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: FinalsTheme.textPrimary(context),
              ),
              onErrorFallback: (err) {
                return Text(
                  part,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: FinalsTheme.danger.withValues(alpha: 0.7),
                  ),
                );
              },
            ),
          ),
        );
      } else {
        spans.addAll(_buildBoldSpans(part));
      }
    }

    if (spans.isEmpty) return const SizedBox.shrink();

    return RichText(
      text: TextSpan(
        style: FinalsTheme.subtitleStyle(context).copyWith(
          fontSize: 14,
          color: FinalsTheme.textPrimary(context).withValues(alpha: 0.9),
          height: 1.5,
        ),
        children: spans,
      ),
    );
  }

  List<InlineSpan> _buildBoldSpans(String source) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in regex.allMatches(source)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: source.substring(lastIndex, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      lastIndex = match.end;
    }

    if (lastIndex < source.length) {
      spans.add(TextSpan(text: source.substring(lastIndex)));
    }

    return spans;
  }
}
