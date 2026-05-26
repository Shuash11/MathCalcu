import 'package:calculus_system/midterm/theme/slope_theme/slope_theme.dart';
import 'package:flutter/material.dart';

class SlopeInputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;

  const SlopeInputField({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  State<SlopeInputField> createState() => _SlopeInputFieldState();
}

class _SlopeInputFieldState extends State<SlopeInputField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isFocused
                  ? SlopeTheme.accentColor
                  : SlopeTheme.textSecondary(context),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: SlopeTheme.cardColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFocused
                    ? SlopeTheme.accentColor
                    : SlopeTheme.accentColor.withValues(alpha: 0.2),
                width: isFocused ? 2 : 1.5,
              ),
            ),
            child: GestureDetector(
              onTap: () => _focusNode.requestFocus(),
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.text,
                style: TextStyle(
                  color: SlopeTheme.textPrimary(context),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                cursorColor: SlopeTheme.accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
