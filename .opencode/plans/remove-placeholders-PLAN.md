# Plan: Remove Placeholder UI Elements

## Summary
Remove empty-state placeholder UI that shows instructional text like "Enter two equations above" and "Results will appear here automatically." These waste space and aren't needed — users understand the flow from context.

## Scope
**Remove:**
1. `parallel_perpendicular_screen.dart` — `_EmptyState` class (lines 357-386) with "Enter two equations above" + "Press Solve to see results."
2. `slope_intercept.dart` — `_buildEmptyCard` method (lines 750-759) with "Enter values above to see the solution"
3. `pointslopesubwidget.dart` — "Enter values above" text (line 424) + its placeholderStyle

**Keep:**
- `finals_picker_screen.dart` — "Topics coming soon" placeholder (user confirmed keep)

## Files Touched
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\yintercept_screen\parallel_perpendicular_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\yintercept_screen\slope_intercept.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\pointslope_screen\pointslopesubwidget.dart`

## Approach
1. **parallel_perpendicular_screen.dart**: Remove `_EmptyState` class entirely. Update the reference at line 217 to return `const SizedBox.shrink()` instead.
2. **slope_intercept.dart**: Remove `_buildEmptyCard` method. Update the reference at line 633 to return `const SizedBox.shrink()`.
3. **pointslopesubwidget.dart**: Remove the `else` block with "Enter values above" text (lines 423-426). Replace with `const SizedBox.shrink()`.

## Risks
- Minimal — these are pure UI removals with no logic changes
- No test coverage expected for placeholder widgets

## Non-goals
- Not changing the Solve button behavior
- Not changing result display logic
- Not touching finals_picker_screen placeholder
