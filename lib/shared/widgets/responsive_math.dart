import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// Wraps [Math.tex] or [SelectableMath.tex] in a [FittedBox] so the
/// rendered LaTeX auto-scales down to fit the available width.
class ResponsiveMath extends StatelessWidget {
  final String tex;
  final TextStyle? textStyle;
  final MathStyle mathStyle;
  final bool selectable;

  const ResponsiveMath(
    this.tex, {
    super.key,
    this.textStyle,
    this.mathStyle = MathStyle.display,
    this.selectable = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = selectable
        ? SelectableMath.tex(
            tex,
            mathStyle: mathStyle,
            textStyle: textStyle,
          )
        : Math.tex(
            tex,
            mathStyle: mathStyle,
            textStyle: textStyle,
          );

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: child,
    );
  }
}
