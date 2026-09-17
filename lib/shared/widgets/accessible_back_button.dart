import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Accessible 48x48 back button shared by all pickers.
///
/// P1-1: replaces 36x36 / 44x44 GestureDetector back chevrons with a
/// 48dp Material target that is keyboard-focusable, tooltip-labelled,
/// and announced by screen readers.
class AccessibleBackButton extends StatelessWidget {
  final String semanticLabel;
  final VoidCallback? onPressed;

  const AccessibleBackButton({
    super.key,
    this.semanticLabel = 'Back',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Semantics(
      label: semanticLabel,
      button: true,
      child: Tooltip(
        message: semanticLabel,
        child: Material(
          color: theme.card,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onPressed ?? () => context.pop(),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.textSecondary.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: theme.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
