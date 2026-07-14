# Plan: Add Solve Button to Auto-Solve Screens

## Summary
Remove auto-solve behavior from 4 midterm screens and add explicit Solve buttons. Users must click Solve before seeing results. All other screens (12+) already have Solve buttons — no changes needed.

## Screens That Need Changes (4)

| # | File | Current Behavior | Change Needed |
|---|------|-----------------|---------------|
| 1 | `slope_intercept_scr.dart` | Auto-solve on text change (500ms debounce) | Remove auto-solve listeners, add Solve button |
| 2 | `parallel_perpendicular_screen.dart` | Auto-solve on text change (400ms debounce) | Remove auto-solve listeners, add Solve button |
| 3 | `pointslopescreen.dart` | Auto-solve on text change (400ms debounce) | Remove auto-solve listeners, add Solve button |
| 4 | `base_inequality_screen.dart` | Auto-solve + existing arrow button | Remove auto-solve only (keep existing button) |

## Screens Already Correct (12 — NO changes needed)
- Slope, Two-Point Slope, Midpoint, Distance, Circles (center-radius) — all have Solve buttons
- Slope Using Derivatives, Limits at Infinity, Evaluating Limits (4 types), Derivatives — all have Solve buttons

## Subtask Breakdown

### Task 1: slope_intercept_scr.dart — Remove auto-solve, add Solve button
- Remove `addListener(_onChanged)` on `_mCtrl`, `_bCtrl`, `_sfCtrl` (lines 49-51)
- Remove `_onChanged()` method and debounce timer (lines 70-82)
- Remove `Timer? _debounce` field
- Add Solve button below input fields, above result area
- Button style: Midpoint-style (slate/ice theme colors from `MidpointTheme`)
- On tap: call `_compute()` directly
- Result area: show empty initially (remove result from initial build)
- Keep old result visible after solving until Solve clicked again

### Task 2: parallel_perpendicular_screen.dart — Remove auto-solve, add Solve button
- Remove `addListener(_onChanged)` on `_line1Ctrl`, `_line2Ctrl` (lines 46-47)
- Remove `_onChanged()` method and debounce timer (lines 73-85)
- Remove `Timer? _debounce` field
- Add Solve button below input fields, above result area
- Button style: Midpoint-style (slate/ice theme)
- On tap: call `_compute()` directly
- Result area: show empty initially
- Keep old result visible after solving

### Task 3: pointslopescreen.dart — Remove auto-solve, add Solve button
- Remove `addListener(_onTextChanged)` on `_mCtrl`, `_x1Ctrl`, `_y1Ctrl` (lines 56-58)
- Remove `_onTextChanged()` method and debounce timer (lines 84-104)
- Remove `Timer? _debounce` field
- Add Solve button below input fields, above result area
- Button style: Midpoint-style (slate/ice theme)
- On tap: call `_computeResult()` directly
- Result area: show empty initially
- Keep old result visible after solving

### Task 4: base_inequality_screen.dart — Remove auto-solve only
- Remove `onChanged: _onInputChanged` from `MathInputField` (line 242)
- Remove `_onInputChanged()` method and debounce timer (lines 51-66)
- Remove `Timer? _debounce` field
- Keep existing arrow solve button in `MathInputField` (already has `onSolve: _solve`)
- Result area: show empty initially (if not already)
- Keep old result visible after solving

### Task 5: Run flutter analyze + flutter test
- Verify no errors introduced
- All tests pass

## Files Touched
- `lib/topics/calculus/midterm/screens/yintercept_screen/slope_intercept_scr.dart`
- `lib/topics/calculus/midterm/screens/yintercept_screen/parallel_perpendicular_screen.dart`
- `lib/topics/calculus/midterm/screens/pointslope_screen/pointslopescreen.dart`
- `lib/topics/calculus/midterm/screens/inequalities_screen/base_inequality_screen.dart`

## Button Style Reference
- Midpoint theme colors: Slate 800 (`#334155`) for light mode, Light Ice (`#E9ECEF`) for dark mode
- Use `MidpointTheme.accent(context)` for background
- Use `MidpointTheme.accentLight(context)` for text
- Rounded corners, padding, centered text "Solve"

## Approach
1. For each auto-solve screen, remove the text change listeners and debounce timers
2. Add a Solve button widget below the input section
3. Wire the button to call the existing compute/solve method
4. Ensure result area starts empty and persists after solving

## Risks
- Some screens may have complex layout (e.g., tabs in slope_intercept_scr.dart) — button placement needs care
- The inequality screen's MathInputField already has an embedded solve button — need to verify it still works after removing auto-solve

## Non-Goals
- Screens that already have Solve buttons (12 screens) — no changes
- Changing button styles on existing Solve buttons
- Adding Solve button to the calculator (already has = button)
