import 'package:calculus_system/modules/slope/theme/slope_theme.dart';
import 'package:flutter/material.dart';

/// A labelled text field used for coordinate inputs.
/// Uses [TextInputType.text] so the full keyboard (including `/`) is available.
class SlopeInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const SlopeInputField({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: SlopeTheme.labelStyle(context)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: SlopeTheme.cardColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: SlopeTheme.accentColor.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: controller,
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
        ],
      ),
    );
  }
}
