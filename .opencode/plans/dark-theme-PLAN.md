# Dark Theme — Implementation Plan

## Summary
Add dark mode support to MathCalcu for nighttime studying. User toggles between light/dark in Settings. Persisted via SharedPreferences.

## Dark Palette (Minimal-inspired)
- Surface: `#1A1A2E` (deep navy)
- Card: `#232340` (slightly lighter)
- CardSecondary: `#2A2A4A`
- TextPrimary: `#F4F4F1` (off-white)
- TextSecondary: `#F4F4F1` at 60% opacity
- Shadow: `Colors.black` at 0.2 opacity
- Accent: `#6366F1` (brighter indigo for dark bg contrast)

## Subtasks

### Task 1: Update ThemeProvider with dark mode support
- Add `_isDark` field, `isDark` getter, `toggleTheme()` method
- Add dark token getters (surface, card, cardSecondary, textPrimary, textSecondary, shadowColor, accentColor)
- Persist with SharedPreferences (`dark_mode` key)
- Add `loadTheme()` async method

### Task 2: Update main.dart
- Call `themeProvider.loadTheme()` in `main()` before `runApp()`
- Pass `isDark` to `SystemUiOverlayStyle` (Brightness.light vs Brightness.dark)
- Update `AppTheme` to use dynamic colors from ThemeProvider

### Task 3: Restore dark mode toggle in settings_screen.dart
- Add Settings toggle row with `Switch.adaptive`
- Wire to `theme.toggleTheme()`
- Show current state (light/dark icon)

### Task 4: Audit hardcoded colors in key screens
- Verify all screens using `ThemeProvider` (not `Theme.of(context)`)
- Fix any remaining hardcoded colors that don't adapt to dark mode
- Key files: home_screen, calculator_screen, app_shell, notes_screen, topics_screen

### Task 5: Run flutter analyze + flutter test
- Final verification

## Files to Change
- `C:\projects\mathcalcu\lib\theme\theme_provider.dart`
- `C:\projects\mathcalcu\lib\main.dart`
- `C:\projects\mathcalcu\lib\screens\settings_screen.dart`
- `C:\projects\mathcalcu\lib\home\home_screen.dart` (if needed)
- `C:\projects\mathcalcu\lib\calculator\calculator_screen.dart` (if needed)
- `C:\projects\mathcalcu\lib\widgets\app_shell.dart` (if needed)

## Risks
- Screens using `Theme.of(context)` instead of `ThemeProvider` won't adapt
- FinalsTheme constants are fixed — finals screens use those colors regardless of theme

## Non-Goals
- Changing FinalsTheme constants (they're for finals-specific branding)
- Adding automatic system theme detection (future enhancement)
- Changing layouts or navigation
