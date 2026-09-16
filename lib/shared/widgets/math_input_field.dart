import 'package:calculus_system/shared/widgets/accent_glow.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// -------------------------------------------------------------
// MATH INPUT FIELD
// StatefulWidget — owns its own FocusNode so it never loses
// focus when the parent screen rebuilds after solve() is called.
// -------------------------------------------------------------

class MathInputField extends StatefulWidget {
  final TextEditingController controller;
  final Color accentColor;
  final String hint;
  final VoidCallback onSolve;
  final ValueChanged<String>? onChanged;
  final String? helperText;
  final String? errorText;
  final String? Function(String)? validator;
  const MathInputField({
    super.key,
    required this.controller,
    required this.accentColor,
    required this.hint,
    required this.onSolve,
    this.onChanged,
    this.helperText,
    this.errorText,
    this.validator,
  });

  @override
  State<MathInputField> createState() => _MathInputFieldState();
}

class _MathInputFieldState extends State<MathInputField> {
  // FocusNode lives here — survives parent rebuilds
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.errorText != null
                  ? theme.accentColor.withValues(alpha: 0.6)
                  : (theme.isDark
                          ? const Color(0xFFE9ECEF)
                          : const Color(0xFF334155))
                      .withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode, // stable focus — no more pausing
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: theme.textPrimary,
                    letterSpacing: 0.2,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                  onChanged: widget.onChanged,
                  // onSubmitted: user presses Enter key on keyboard
                  onSubmitted: (_) {
                    widget.onSolve();
                    // Keep focus after submitting so user can retype
                    _focusNode.requestFocus();
                  },
                ),
              ),
              GestureDetector(
                onTap: () {
                  widget.onSolve();
                  // Keep focus after tapping the button
                  _focusNode.requestFocus();
                },
                child: Container(
                  margin: const EdgeInsets.all(6),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.accentColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [AccentGlow.halo(context)],
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color:
                        theme.isDark ? const Color(0xFF1A1A2E) : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: TextStyle(
              color: theme.accentColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ] else if (widget.helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.helperText!,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
