# Task 1 Debug Report: Hardcoded Colors in parallel_perpendicular_screen.dart

## Bug Summary

21 hardcoded `Color(0xFF334155)` references remain in `parallel_perpendicular_screen.dart`. These were supposed to be replaced with `ThemeProvider.accentColor` during the theme migration, but they were missed.

## Root Cause

`ThemeProvider.accentColor` is defined as:
```dart
Color get accentColor => _isDark ? const Color(0xFFE9ECEF) : const Color(0xFF334155);
```

In **light mode** the hardcoded color matches the theme token — so the bug is invisible. In **dark mode**, `Color(0xFF334155)` is a dark slate gray sitting on a dark background (`#232340`), causing:

- **Text/labels**: nearly invisible (dark-on-dark)
- **Borders**: acceptable contrast but inconsistent with the design system
- **Shadows**: no functional difference but still wrong

Every other widget in this file already uses `context.watch<ThemeProvider>().accentColor` (see lines 167, 186, 192, 199, 314, 360, 373, 456, 628, 1109, 1156, 1263). The 21 remaining hardcoded references are stragglers.

## ALL Lines Requiring Fix

### Category A: Semantic accent color (must be `accentColor`)

These are **Line 1 vs Line 2 differentiation**, equation tiles, and result tiles — they use color to distinguish content. Line 2 already uses `accentColor` (line 314); Line 1 should too.

| Line | Current | Replacement |
|------|---------|-------------|
| 267 | `color: const Color(0xFF334155)` | `color: context.watch<ThemeProvider>().accentColor` (for Line 1 label, to match Line 2 at 314) |
| 466 | `color: const Color(0xFF334155)` | `color: context.watch<ThemeProvider>().accentColor` (Slope 2 tile — currently hardcoded vs Slope 1 which uses accentColor at 456) |
| 480 | `color: const Color(0xFF334155)` | `color: context.watch<ThemeProvider>().accentColor` (Line 1 Slope-Intercept equation) |
| 481 | `tagColor: const Color(0xFF334155)` | `tagColor: context.watch<ThemeProvider>().accentColor` (Line 1 Slope-Intercept tag) |
| 490 | `color: const Color(0xFF334155)` | `color: context.watch<ThemeProvider>().accentColor` (Line 1 Standard Form equation) |
| 491 | `tagColor: const Color(0xFF334155)` | `tagColor: context.watch<ThemeProvider>().accentColor` (Line 1 Standard Form tag) |
| 511 | `color: const Color(0xFF334155)` | `color: context.watch<ThemeProvider>().accentColor` (Line 2 Slope-Intercept equation) |
| 512 | `tagColor: const Color(0xFF334155)` | `tagColor: context.watch<ThemeProvider>().accentColor` (Line 2 Slope-Intercept tag) |
| 521 | `color: const Color(0xFF334155)` | `color: context.watch<ThemeProvider>().accentColor` (Line 2 Standard Form equation) |
| 522 | `tagColor: const Color(0xFF334155)` | `tagColor: context.watch<ThemeProvider>().accentColor` (Line 2 Standard Form tag) |

### Category B: Chip/interactive element colors (must be `accentColor`)

The "Show steps" chip should use `accentColor` to match the "Show graph" chip (lines 587-612) which already uses `accent`.

| Line | Current | Replacement |
|------|---------|-------------|
| 565 | `color: const Color(0xFF334155).withValues(alpha: 0.1)` | `color: context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.1)` |
| 576 | `color: const Color(0xFF334155)` | `color: context.watch<ThemeProvider>().accentColor` |
| 581 | `color: const Color(0xFF334155), size: 16` | `color: context.watch<ThemeProvider>().accentColor, size: 16` |

### Category C: Border/shadow colors (should be `accentColor` for consistency)

Borders use `Color(0xFF334155).withValues(alpha: N)` which is functionally `accentColor.withValues(alpha: N)` in light mode. Replace for dark-mode correctness. There is no dedicated border token in ThemeProvider — using `accentColor` with alpha is the established pattern (see app bar lines 165-168, 189-193).

| Line | Current | Replacement |
|------|---------|-------------|
| 233 | `color: const Color(0xFF334155).withValues(alpha: 0.15)` | `color: context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.15)` |
| 297 | `color: const Color(0xFF334155).withValues(alpha: 0.2)` | `color: context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.2)` |
| 345 | `const Color(0xFF334155).withValues(alpha: 0.15)` | `context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.15)` |
| 395 | `color: const Color(0xFF334155).withValues(alpha: 0.35)` | `color: context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.35)` |
| 400 | `color: const Color(0xFF334155).withValues(alpha: 0.15)` | `color: context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.15)` |
| 621 | `Border.all(color: const Color(0xFF334155).withValues(alpha: 0.2))` | `Border.all(color: context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.2))` |
| 719 | `color: const Color(0xFF334155).withValues(alpha: 0.15)` | `color: context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.15)` |
| 725 | `color: const Color(0xFF334155).withValues(alpha: 0.5)` | `color: context.watch<ThemeProvider>().accentColor.withValues(alpha: 0.5)` |

### Category D: Intentionally different — keep as-is

| Line | Current | Reason |
|------|---------|--------|
| 385 | `const Color(0xFF64748B)` | This is `PPRelationship.neither` verdict — a muted gray accent, intentionally distinct from the primary accent. Not part of this bug. |

## Suggested Fix

**Total replacements: 21 lines** (10 Category A + 3 Category B + 8 Category C).

The fix is mechanical — replace `const Color(0xFF334155)` with `context.watch<ThemeProvider>().accentColor` at each location, preserving existing `.withValues(alpha: N)` modifiers.

**Note:** `_PointLabel` at line 265-268 is passed `color` as a `const` parameter — but the caller site must supply a runtime value. The `_PointLabel` widget itself doesn't need changes, only the call site at line 267.

**Note:** `_EquationTile` receives `color` and `tagColor` as constructor params — again, only the call sites (lines 480-481, 490-491, 511-512, 521-522) need updating. The widget's internal usage of those params is fine.

**Note:** The "Show steps" chip (lines 561-585) is self-contained — all three lines (565, 576, 581) need updating within `_buildShowStepsChip()`.

## Regression Risk

- **Low.** In light mode, `accentColor == Color(0xFF334155)`, so the visual output is identical — zero pixel change.
- In dark mode, the fix changes behavior: elements will now use `Color(0xFFE9ECEF)` (light) instead of `Color(0xFF334155)` (dark slate). This is the **correct** behavior — elements become visible/readable in dark mode.
- No functional logic changes. No new imports needed (`ThemeProvider` is already imported at line 12).
- The `_CoordField` widget (lines 667-739) is reused — fixing lines 719/725 benefits all `_CoordField` usages.
- The `FinalsTheme.primary` usage in `_MiniStepColumn` (line 1130) and `_MiniStepColumn` (line 1138) is a separate concern — `FinalsTheme` is a different theme system and was not flagged by the Tester.
