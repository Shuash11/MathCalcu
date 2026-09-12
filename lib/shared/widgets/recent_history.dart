// ─────────────────────────────────────────────────────────────
// RECENT HISTORY WIDGETS — shared "Recent" chips + "Recently
// opened" sections for /search, Grade 6 picker, and Topics.
//
// Styling via ThemeProvider only. Offline (HistoryService /
// shared_preferences). Empty searches show the Task 7
// placeholder: "No recent searches yet — try ratio".
// ─────────────────────────────────────────────────────────────

import 'package:calculus_system/services/history_service.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Horizontal wrap of recent search chips with a Clear action.
///
/// Loads via [HistoryService.getRecentSearches]. Tapping a chip
/// calls [onPick] so the host screen can refill its search field.
class RecentSearchesSection extends StatelessWidget {
  final List<String> searches;
  final ValueChanged<String> onPick;
  final VoidCallback onClear;

  const RecentSearchesSection({
    super.key,
    required this.searches,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final accent = theme.accentColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (searches.isNotEmpty)
              TextButton(
                onPressed: onClear,
                child: Text(
                  'Clear',
                  style: TextStyle(color: accent, fontSize: 13),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (searches.isEmpty)
          Text(
            'No recent searches yet — try ratio',
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final query in searches)
                ActionChip(
                  label: Text(
                    query,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                  ),
                  backgroundColor: theme.card,
                  side: BorderSide(
                    color: accent.withValues(alpha: 0.3),
                  ),
                  onPressed: () => onPick(query),
                ),
            ],
          ),
      ],
    );
  }
}

/// "Recently opened" solver list (label + timestamp, taps push
/// the stored route). Hidden entirely when [entries] is empty.
class RecentlySolvedSection extends StatelessWidget {
  final List<SolvedHistoryEntry> entries;
  final VoidCallback onClear;

  const RecentlySolvedSection({
    super.key,
    required this.entries,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    final theme = context.watch<ThemeProvider>();
    final accent = theme.accentColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recently opened',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: onClear,
              child: Text(
                'Clear',
                style: TextStyle(color: accent, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final entry in entries) ...[
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push(entry.route),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 16,
                      color: theme.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.label,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: accent.withValues(alpha: 0.85),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
