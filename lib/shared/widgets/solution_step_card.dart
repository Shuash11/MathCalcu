import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:flutter/material.dart';

/// A reusable step card matching the unified solution steps style:
/// - Numbered circle indicator (amber fill + border, white bold number)
/// - Bold white title
/// - Lighter description text below title
/// - Math content in a dark card with amber math text
class SolutionStepCard extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String? description;
  final Widget mathContent;

  const SolutionStepCard({
    super.key,
    required this.stepNumber,
    required this.title,
    this.description,
    required this.mathContent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Number Circle
        SizedBox(
          width: 28,
          height: 28,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: FinalsTheme.primary,
              border: Border.all(
                color: FinalsTheme.primary,
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
                // Title
                Text(
                  title,
                  style: FinalsTheme.titleStyle(context).copyWith(fontSize: 15),
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
