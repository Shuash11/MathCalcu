import 'package:flutter/material.dart';

/// Auto-scales font size to fit available width. Never wraps.
///
/// Uses [FittedBox] internally with [BoxFit.scaleDown] so the text
/// shrinks when it exceeds the parent width but never grows beyond
/// the given [style.fontSize].
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double minFontSize;
  final int maxLines;
  final TextAlign? textAlign;
  final TextOverflow overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.minFontSize = 10,
    this.maxLines = 1,
    this.textAlign,
    this.overflow = TextOverflow.visible,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: _alignmentFor(textAlign),
      child: Text(
        text,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
        style: (style ?? const TextStyle()).copyWith(
          fontSize: style?.fontSize ?? 14,
        ),
      ),
    );
  }

  static Alignment _alignmentFor(TextAlign? align) {
    switch (align) {
      case TextAlign.left:
      case TextAlign.start:
        return Alignment.centerLeft;
      case TextAlign.right:
      case TextAlign.end:
        return Alignment.centerRight;
      case TextAlign.center:
        return Alignment.center;
      default:
        return Alignment.centerLeft;
    }
  }
}
