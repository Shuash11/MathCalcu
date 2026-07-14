import 'package:calculus_system/theme/app_design.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:flutter/material.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';

/// A reusable step card matching the unified solution steps style:
/// - Numbered circle indicator (dark fill + white border, white bold number)
/// - "Step N" label in gray with horizontal divider
/// - Bold white title after divider
/// - Math content in a dark card with amber math text
class SolutionStepCard extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String? description;
  final Widget mathContent;
  final AppDesign design;

  const SolutionStepCard({
    super.key,
    required this.stepNumber,
    required this.title,
    this.description,
    required this.mathContent,
    required this.design,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Number Circle — dark background with white border
        SizedBox(
          width: 28,
          height: 28,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: design.accent,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                stepNumber.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Step N" label
                Text(
                  'Step $stepNumber',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.45),
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 6),

                // Thin divider line
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.12),
                ),

                const SizedBox(height: 10),

                // Title — bold white
                ResponsiveText(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),

                // Description (optional)
                if (description != null && description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: FinalsTheme.subtitleStyle(context),
                  ),
                ],

                const SizedBox(height: 12),

                // Math content in a dark card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: FinalsTheme.cardSecondary(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: mathContent,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
