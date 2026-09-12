// -------------------------------------------------------------
// EMPTY STATES
// Uniform no-topics / no-graph placeholders (§B.1.4).
// Pattern reused from modmat_picker_screen (search_off + Clear).
// Styling via ThemeProvider — no hardcoded colors.
// -------------------------------------------------------------

import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// "No topics / no search results" card with a Clear action.
class NoTopicsEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onClear;
  final String clearLabel;

  const NoTopicsEmptyState({
    super.key,
    this.title = 'No topics found',
    this.subtitle = 'Try another keyword',
    this.onClear,
    this.clearLabel = 'Clear search',
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            color: theme.textSecondary,
            size: 36,
            semanticLabel: 'No results',
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.textSecondary, height: 1.4),
          ),
          if (onClear != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onClear,
              icon: Icon(
                Icons.close_rounded,
                color: theme.accentColor,
              ),
              label: Text(
                clearLabel,
                style: TextStyle(color: theme.accentColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// "No graph for this input" placeholder with a reason line.
class NoGraphPlaceholder extends StatelessWidget {
  final String reason;

  const NoGraphPlaceholder({
    super.key,
    this.reason = 'Solve first to see the graph.',
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: theme.cardSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.12),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.show_chart_rounded,
              color: theme.textSecondary,
              size: 36,
              semanticLabel: 'No graph',
            ),
            const SizedBox(height: 12),
            Text(
              'No graph for this input',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                reason,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.textSecondary, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
