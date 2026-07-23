import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/shared/widgets/accent_glow.dart';

class FinalsSolverButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const FinalsSolverButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [AccentGlow.halo(context)],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.accentColor,
          disabledBackgroundColor: theme.accentColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: isLoading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    color: theme.surface, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calculate_rounded, size: 18, color: theme.surface),
                  const SizedBox(width: 8),
                  Text(
                    'Solver',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: theme.surface,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class FinalsVariableChip extends StatelessWidget {
  final String variable;
  final VoidCallback onTap;

  const FinalsVariableChip({
    super.key,
    required this.variable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Semantics(
      label: 'Insert variable $variable',
      button: true,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        excludeFromSemantics: true,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.accentColor.withValues(alpha: 0.3)),
            boxShadow: [AccentGlow.soft(context)],
          ),
          child: Text(
            variable,
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: theme.accentColor,
            ),
          ),
        ),
      ),
    );
  }
}
