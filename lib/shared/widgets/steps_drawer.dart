import 'package:calculus_system/core/step_model.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────
// STEPS DRAWER — shared modal bottom sheet
// Call showStepsDrawer() from any module screen.
// Receives the steps list from the equation's getSteps().
// ─────────────────────────────────────────────────────────────

Future<void> showStepsDrawer({
  required BuildContext context,
  required List<StepModel> steps,
  required Color accentColor,
  required String title,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => StepsDrawer(
      steps: steps,
      accentColor: accentColor,
      title: title,
    ),
  );
}

class StepsDrawer extends StatelessWidget {
  final List<StepModel> steps;
  final Color accentColor;
  final String title;

  const StepsDrawer({
    super.key,
    required this.steps,
    required this.accentColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        final theme = context.watch<ThemeProvider>();
        return Container(
          decoration: BoxDecoration(
            color: theme.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.watch<ThemeProvider>().textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${steps.length} steps',
                        style: TextStyle(
                          fontSize: 12,
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: context.watch<ThemeProvider>().textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close_rounded,
                        color: context.watch<ThemeProvider>().textSecondary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Divider(
                height: 1,
                color: context
                    .watch<ThemeProvider>()
                    .textSecondary
                    .withValues(alpha: 0.1),
              ),

              // Steps list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  itemCount: steps.length,
                  itemBuilder: (context, index) {
                    return _StepTile(
                      step: steps[index],
                      accentColor: accentColor,
                      isLast: index == steps.length - 1,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StepTile extends StatelessWidget {
  final StepModel step;
  final Color accentColor;
  final bool isLast;

  const _StepTile({
    required this.step,
    required this.accentColor,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 36,
            child: Column(
              children: [
                // Step number circle
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${step.stepNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
                // Connecting line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: accentColor.withValues(alpha: 0.12),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.watch<ThemeProvider>().textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    step.explanation,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.watch<ThemeProvider>().textSecondary,
                      height: 1.55,
                    ),
                  ),
                  // Optional LaTeX hint (replace with flutter_math_fork)
                  if (step.latex != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: context.watch<ThemeProvider>().surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Text(
                        // TODO: replace with Math.tex(step.latex!) from flutter_math_fork
                        step.latex!,
                        style: TextStyle(
                          fontSize: 14,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
