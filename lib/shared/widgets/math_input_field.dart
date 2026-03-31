import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────
// MATH INPUT FIELD
// StatefulWidget — owns its own FocusNode so it never loses
// focus when the parent screen rebuilds after solve() is called.
// ─────────────────────────────────────────────────────────────

class MathInputField extends StatefulWidget {
  final TextEditingController controller;
  final Color accentColor;
  final String hint;
  final VoidCallback onSolve;
  final ValueChanged<String>? onChanged;
  const MathInputField({
    super.key,
    required this.controller,
    required this.accentColor,
    required this.hint,
    required this.onSolve,
    this.onChanged,
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
    return Container(
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.2),
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
                color: widget.accentColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
