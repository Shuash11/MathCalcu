import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';

/// Topic-first filter chips (E-1/E-3): filter by subject, not grade label.
///
/// 48dp-high Material chips, horizontally scrollable, keyboard-focusable
/// with Semantics. Single-select: [selected] is the active subject or
/// null/'All' for no filter. Callers AND this with their text query.
class SubjectFilterChips extends StatelessWidget {
  final List<String> subjects;
  final String selected;
  final ValueChanged<String> onSelected;

  const SubjectFilterChips({
    super.key,
    required this.subjects,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final accent = theme.accentColor;
    final items = <String>['All', ...subjects];
    return Semantics(
      label: 'Filter by topic',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              _Chip(
                label: items[i],
                selected: selected == items[i] ||
                    (selected.isEmpty && items[i] == 'All'),
                accent: accent,
                theme: theme,
                onTap: () => onSelected(items[i]),
              ),
              if (i < items.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final ThemeProvider theme;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.accent,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Filter by $label',
      button: true,
      selected: selected,
      child: Tooltip(
        message: 'Filter by $label',
        child: Material(
          color: selected ? accent.withValues(alpha: 0.16) : theme.card,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? accent.withValues(alpha: 0.6)
                      : theme.textSecondary.withValues(alpha: 0.25),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected ? accent : theme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
