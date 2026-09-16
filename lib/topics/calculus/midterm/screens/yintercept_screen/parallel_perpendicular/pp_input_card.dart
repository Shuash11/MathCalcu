// lib/topics/calculus/midterm/screens/yintercept_screen/parallel_perpendicular/pp_input_card.dart

import 'package:calculus_system/shared/widgets/accent_glow.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Input card for the Parallel & Perpendicular screen: two equation
/// fields, a swap button, and the reset/solve button row.
class PPInputCard extends StatelessWidget {
  final TextEditingController line1Ctrl;
  final TextEditingController line2Ctrl;
  final FocusNode line1Focus;
  final FocusNode line2Focus;
  final bool hasSolved;
  final VoidCallback onSwap;
  final VoidCallback onSolve;
  final VoidCallback onReset;

  const PPInputCard({
    super.key,
    required this.line1Ctrl,
    required this.line2Ctrl,
    required this.line1Focus,
    required this.line2Focus,
    required this.hasSolved,
    required this.onSwap,
    required this.onSolve,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.watch<ThemeProvider>().card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context
              .watch<ThemeProvider>()
              .accentColor
              .withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
                alpha: context.watch<ThemeProvider>().isLight ? 0.05 : 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          ResponsiveText(
            'ENTER EQUATIONS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context
                  .watch<ThemeProvider>()
                  .textSecondary
                  .withValues(alpha: 0.7),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),

          // Line 1
          _PointLabel(
            label: 'Line 1',
            color: context.watch<ThemeProvider>().accentColor,
          ),
          const SizedBox(height: 10),
          _CoordField(
            controller: line1Ctrl,
            focusNode: line1Focus,
            label: 'Equation',
            hint: 'e.g. 2x + 3y = 6',
            textInputAction: TextInputAction.next,
            onEditingComplete: () => line2Focus.requestFocus(),
          ),

          const SizedBox(height: 16),

          // Swap button
          Center(
            child: GestureDetector(
              onTap: onSwap,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.watch<ThemeProvider>().surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context
                        .watch<ThemeProvider>()
                        .accentColor
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  Icons.swap_vert_rounded,
                  color: context.watch<ThemeProvider>().textSecondary,
                  size: 18,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Line 2
          _PointLabel(
            label: 'Line 2',
            color: context.watch<ThemeProvider>().accentColor,
          ),
          const SizedBox(height: 10),
          _CoordField(
            controller: line2Ctrl,
            focusNode: line2Focus,
            label: 'Equation',
            hint: 'e.g. 4x - 6y + 1 = 0',
            textInputAction: TextInputAction.done,
            onEditingComplete: () => line2Focus.unfocus(),
          ),

          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              // Reset
              if (hasSolved)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: onReset,
                    child: Container(
                      width: 48,
                      height: 52,
                      decoration: BoxDecoration(
                        color: context.watch<ThemeProvider>().surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: context
                              .watch<ThemeProvider>()
                              .accentColor
                              .withValues(alpha: 0.15),
                        ),
                      ),
                      child: Icon(
                        Icons.refresh_rounded,
                        color: context.watch<ThemeProvider>().textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ),

              Expanded(
                child: _SolveButton(
                  onTap: onSolve,
                  accent: context.watch<ThemeProvider>().accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PointLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _PointLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          ResponsiveText(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      );
}

class _CoordField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;

  const _CoordField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    this.textInputAction,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.text,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      style: TextStyle(
        color: context.watch<ThemeProvider>().textPrimary,
        fontSize: 16,
        fontFamily: 'monospace',
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: context.watch<ThemeProvider>().textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: context
              .watch<ThemeProvider>()
              .textSecondary
              .withValues(alpha: 0.6),
          fontSize: 14,
        ),
        filled: true,
        fillColor: context.watch<ThemeProvider>().surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: context
                .watch<ThemeProvider>()
                .accentColor
                .withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: context
                .watch<ThemeProvider>()
                .accentColor
                .withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}

class _SolveButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color accent;
  const _SolveButton({required this.onTap, required this.accent});

  @override
  State<_SolveButton> createState() => _SolveButtonState();
}

class _SolveButtonState extends State<_SolveButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.accent,
                  widget.accent,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [AccentGlow.halo(context)],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calculate_rounded,
                      color: FinalsTheme.onPrimaryFor(context), size: 18),
                  const SizedBox(width: 8),
                  ResponsiveText(
                    'Solve',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: FinalsTheme.onPrimaryFor(context),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
