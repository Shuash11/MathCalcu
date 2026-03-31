import 'package:flutter/material.dart';
import '../../Theme/radiustheme.dart';

class RadiusActionButtons extends StatelessWidget {
  const RadiusActionButtons({
    super.key,
    required this.onClear,
    required this.onCalculate,
  });

  final VoidCallback onClear;
  final VoidCallback onCalculate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Clear button
        Expanded(
          child: GestureDetector(
            onTap: onClear,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: FindingRadiusTheme.cyan.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: FindingRadiusTheme.cyan.withValues(alpha: 0.3),
                ),
              ),
              child: const Center(
                child: Text(
                  'Clear',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: FindingRadiusTheme.cyan,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Calculate button
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: onCalculate,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [FindingRadiusTheme.cyan, FindingRadiusTheme.indigo],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: FindingRadiusTheme.cyan.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Calculate Radius',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}