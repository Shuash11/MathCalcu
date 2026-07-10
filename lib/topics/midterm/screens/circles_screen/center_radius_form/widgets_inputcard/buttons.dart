import 'package:flutter/material.dart';

class QuickKeyButton extends StatelessWidget {
  final String char;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onTapDown;

  const QuickKeyButton({
    super.key,
    required this.char,
    required this.color,
    required this.onTap,
    this.onTapDown,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onTapDown != null ? (_) => onTapDown!() : null,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Text(
          char,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
