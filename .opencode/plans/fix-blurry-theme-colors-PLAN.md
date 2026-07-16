# Plan: Fix Blurry Equation Text + Unify Theme Colors

## Feature Summary
Multiple solver screens have blurry equation text (fuchsia shadow with 10px blur) and use non-theme colors (fuchsia, purple, gold, green, cyan, teal, red) instead of the app's theme accent (#334155 light / #E9ECEF dark). Fix all blurriness and replace all non-theme colors with the theme accent.

## Subtask Breakdown

### Task 1: Fix point-slope formula banner blur + colors
File: `lib/topics/calculus/midterm/screens/pointslope_screen/pointslopesubwidget.dart`
- Lines 171, 173, 175: Replace `Shadow(color: 0x66E879F9, blurRadius: 10)` with `Shadow(color: theme.accentColor.withOpacity(0.3), blurRadius: 3)` on y1, m, x1
- Line 420: Replace green `0x10B981` standard form text with theme accent

### Task 2: Fix point-slope graph colors
File: `lib/topics/calculus/midterm/screens/pointslope_screen/pointslopesubwidget.dart`
- Lines 524-547: Replace purple grid/axis colors with theme accent at appropriate alpha
- Lines 568-585: Replace fuchsia line glow + line + purple dot with theme accent
- Lines 591-593: Replace light purple coordinate label with theme accent

### Task 3: Fix point-slope full-screen graph accent
File: `lib/topics/calculus/midterm/screens/pointslope_screen/pointslopescreen.dart`
- Lines 275-284: Replace purple `0xA855F7` accentColor + info items with theme accent

### Task 4: Fix y-intercept graph colors
File: `lib/topics/calculus/midterm/graph/yintercept_graph/graph.dart`
- Lines 26, 29: Replace dark green background/border with theme
- Lines 98, 121: Replace green grid/axes with theme accent
- Lines 142-169: Replace gold line glow + line + green x-intercept dot with theme accent
- Reduce blur radius from 8 to 3

### Task 5: Fix y-intercept full-screen info items
File: `lib/topics/calculus/midterm/screens/yintercept_screen/slope_intercept.dart`
- Lines 211-226: Replace gold/green FullScreenInfoItem colors with theme accent

### Task 6: Fix parallel/perpendicular screen colors
File: `lib/topics/calculus/midterm/screens/yintercept_screen/parallel_perpendicular_screen.dart`
- Line 17: Replace cyan `_cyan` with theme accent
- Lines 126-133: Fix back button styling
- Lines 379-380: Replace purple/amber verdict colors with theme accent

### Task 7: Fix parallel/perpendicular graph colors
File: `lib/topics/calculus/midterm/graph/yintercept_graph/perpenparallel_graph.dart`
- Lines 341, 374: Replace teal/green line colors with theme accent
- Lines 394, 405: Replace orange intersection dot with theme accent

### Task 8: Fix two-point slope screen colors
File: `lib/topics/calculus/midterm/screens/two_point_slope_screen/twopointslopescreen.dart`
- Lines 255, 390, 428-429, 445-446, 484-500: Replace green/purple accents with theme accent

### Task 9: Fix two-point slope graph colors
File: `lib/topics/calculus/midterm/graph/two_point_slope_graph/two_point_slope_graph.dart`
- Lines 71, 115, 171, 322: Replace green Point 2 color with theme accent

### Task 10: Fix slope graph colors
File: `lib/topics/calculus/midterm/graph/slope_graph/slopegraph.dart`
- Lines 182, 189: Replace hardcoded dark backgrounds with theme
- Lines 508-509: Replace red/teal line colors with theme accent

### Task 11: Fix slope result card colors
File: `lib/topics/calculus/midterm/screens/slope_screen/slope_result.dart`
- Lines 137-141: Replace teal/orange comparison colors with theme accent

## Files to Touch (11 files)
1. `lib/topics/calculus/midterm/screens/pointslope_screen/pointslopesubwidget.dart`
2. `lib/topics/calculus/midterm/screens/pointslope_screen/pointslopescreen.dart`
3. `lib/topics/calculus/midterm/graph/yintercept_graph/graph.dart`
4. `lib/topics/calculus/midterm/screens/yintercept_screen/slope_intercept.dart`
5. `lib/topics/calculus/midterm/screens/yintercept_screen/parallel_perpendicular_screen.dart`
6. `lib/topics/calculus/midterm/graph/yintercept_graph/perpenparallel_graph.dart`
7. `lib/topics/calculus/midterm/screens/two_point_slope_screen/twopointslopescreen.dart`
8. `lib/topics/calculus/midterm/graph/two_point_slope_graph/two_point_slope_graph.dart`
9. `lib/topics/calculus/midterm/graph/slope_graph/slopegraph.dart`
10. `lib/topics/calculus/midterm/screens/slope_screen/slope_result.dart`
11. `lib/topics/calculus/midterm/screens/yintercept_screen/parallel_perpendicular_screen.dart`

## Approach
- All colors replaced with `ThemeProvider.accentColor` (accessed via `context.watch<ThemeProvider>().accentColor`)
- Graph paints use the accent color with appropriate alpha for grid/axes
- Shadow blur radii reduced from 8-10px to 2-3px to eliminate blurriness
- Error states (red) kept as-is — semantically correct
- Graph line glow effects use accent color with reduced blur

## Risks / Open Questions
- Some graphs may lose visual distinction between two lines if both use same accent — acceptable per user request
- Need to verify ThemeProvider is accessible in CustomPainter contexts (may need to pass color as parameter)

## Non-Goals
- No new screens or features
- No route changes
- No test changes (existing tests don't cover visual styling)

## Acceptance Criteria
- No blurry text anywhere in the app
- All equation/formula text uses theme accent color
- All graph elements (lines, dots, grid, glow) use theme accent
- `flutter analyze` zero new errors
- `flutter test` all pass
