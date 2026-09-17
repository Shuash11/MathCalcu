import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// 1D/2D mode toggle button for the distance screen.
///
/// Verbatim extraction of `_DistancescreenState._buildModeButton`
/// (Cycle 5 F6): one responsibility — render one toggle segment.
/// No visual or behavioral change; the screen delegates to this widget.
class DistanceModeButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const DistanceModeButton({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            color: active
                ? context.watch<ThemeProvider>().accentColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: ResponsiveText(
            label,
            textAlign: TextAlign.center,
            style: active
                ? TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.surface)
                : TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context
                        .watch<ThemeProvider>()
                        .textPrimary
                        .withValues(alpha: 0.35)),
          ),
        ),
      ),
    );
  }
}
