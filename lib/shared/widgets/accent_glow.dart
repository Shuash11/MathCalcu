import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';

class AccentGlow {
  static BoxShadow soft(BuildContext context) {
    final accent = context.watch<ThemeProvider>().accentColor;
    final isLight = context.watch<ThemeProvider>().isLight;
    return BoxShadow(
      color: accent.withValues(alpha: isLight ? 0.10 : 0.18),
      blurRadius: isLight ? 16 : 22,
      offset: const Offset(0, 0),
    );
  }

  static BoxShadow halo(BuildContext context) {
    final accent = context.watch<ThemeProvider>().accentColor;
    final isLight = context.watch<ThemeProvider>().isLight;
    return BoxShadow(
      color: accent.withValues(alpha: isLight ? 0.18 : 0.26),
      blurRadius: isLight ? 24 : 30,
      offset: const Offset(0, 0),
    );
  }

  static List<BoxShadow> stack(BuildContext context) => [soft(context)];

  /// Renders the same accent halo behind an existing IconButton without
  /// adding padding or shifting the child — the wrapped icon stays its
  /// default 48px tap target while the halo sits only slightly outside it.
  static Widget iconHalo(BuildContext context, {required Widget child}) {
    final accent = context.watch<ThemeProvider>().accentColor;
    final isLight = context.watch<ThemeProvider>().isLight;
    return Stack(
      alignment: Alignment.center,
      children: [
        IgnorePointer(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: isLight ? 0.14 : 0.22),
                  blurRadius: isLight ? 18 : 26,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
