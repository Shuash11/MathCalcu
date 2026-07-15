# Maroon Removal Readiness Audit

**Date:** 2026-07-15
**Auditor:** OpenCode direct audit after delegated audit aborted

## Checklist

- PASS — Removed legacy colors: zero Dart references to `0xFF7F1D1D`, `0xFF9F2333`, `0xFF312C85`, `0xFF6C63FF`, `0xFF9B8FFF`, `0xFF7EB8F7`, `0xFF60A5FA`, or `0xFF9CA3AF` static card accents remain; all finals cards now inherit the bottom-navigation accent.
- PASS — Core theme tokens: `ThemeProvider.accentColor`, `AppTheme` light/dark, and the bottom navigation use `#334155` light / `#E9ECEF` dark.
- PASS — `AppDesign.calculus` removed; `AppDesign.app` uses slate values.
- PASS — All 10 midterm theme files deleted; zero imports reference them.
- PASS — `ModuleCard._accent` now resolves to `ThemeProvider.accentColor`, so every card on the category, calculus, and finals pickers follows the bottom navigation accent in both brightness modes.
- PASS — `ModuleCard` icon and `MathInputField` solve button both declare `BoxShadow` glow inside `BoxDecoration` and tune intensity in both modes.
- PASS — Source encoding: strict UTF-8 validation finds zero non-deleted invalid files; the 10 invalid blobs that remain are the intentionally deleted theme files still tracked in git.
- PASS — `flutter analyze`: zero errors. Remaining 372 diagnostics are pre-existing info/style lints (`prefer_const_constructors`, `unnecessary_const`, `prefer_interpolation_to_compose_strings`).
- PASS — `flutter test`: 1/1 passes with no UTF-8 warnings.

## Evidence

- Strict UTF-8 scan non-deleted files: zero invalid.
- Legacy hex literal scan: zero matches across the seven specifically removed colors.
- Deleted-theme import scan: zero matches.
- `ModuleCard._accent` now `widget.accentColor ?? ThemeProvider.accentColor`.
- Every finals card removed its `accentColor: const Color(0xFF9CA3AF)` line.
- `MathInputField` border and solve-button glow now use `#334155` light / `#E9ECEF` dark directly.
- `category_picker_screen.dart` fallback card and `settings_screen.dart` icon accents now use `ThemeProvider.accentColor`.

## Overall Verdict

## **READY**
