# Two-Point Slope Steps Redesign — PLAN

## Summary

Redesign the step-by-step solution UI in the Two-Point Slope screen to use a clean minimal typography style (circled numbers, no boxes/borders), ensure fractions render as LaTeX, display results inline with substitutions, add a graph toggle button, and fix a TokenizerError bug in the limits-by-substitution tokenizer. The answer card is untouched.

## Subtask Breakdown

1. **Redesign `_StepCard` in `two_point_slope_steps.dart`** — Replace the current box/border-based step cards with the minimal circled-number timeline style from `substitution_steps_view.dart`. Each step shows: circled number on left, bold title beside it, content text below. No Container with border, no colored left bar, no divider between formula/substitution/result.

2. **Consolidate step content into single LaTeX block** — Instead of separate `_LatexValue` widgets for formula, substitution, and result (each in its own colored box), render them as a single clean flow: title on top, then the math content (formula + substitution + result) as one unified LaTeX expression below. The result should be inline with the substitution (e.g., `= \frac{3}{2}` appended to the substitution line), not in a separate styled box.

3. **Remove `_LatexValue` widget** — The current `_LatexValue` wraps each math expression in a `Container` with background color and padding. This "box" style is being removed. Replace with a simpler `_LatexInline` widget that renders LaTeX without any background container — just the `Math.tex` widget directly.

4. **Add graph toggle button in `twopointslopescreen.dart`** — Move the graph from being inline below the steps (current behavior: `TwoPointSlopeGraph` is inside `_buildResultCard` when `_showSteps` is true) to a standalone toggle. Add a small toggle button (e.g., icon button or chip) near the result card header that shows/hides the graph independently from steps. The graph should appear between the result card and the steps, not nested inside the steps section.

5. **Fix TokenizerError bug in `tokenizer.dart`** — In `SmartTokenizer._preprocess()` (line 74), the superscript-2 character normalization (`²` → `^2`) appears to have a corrupted search character. When input contains `²`, the replaceAll doesn't match, so the raw `²` reaches `_SimpleTokenizer` which throws `TokenizerException('Unexpected character "²"')`. Fix by ensuring the correct Unicode character `²` (U+00B2) is used in the replaceAll. Verify all other superscript normalizations (lines 72-81) are also using correct Unicode characters.

6. **Update solver step generation if needed** — Review `two_point_slope_solver.dart` to ensure the step data (`formula`, `substitution`, `result` fields) is compatible with the new minimal display format. The solver currently generates steps with separate formula/substitution/result strings — the new UI may need them merged or reformatted. Adjust if the current step structure doesn't fit the consolidated display.

## Files / Modules to Touch

- `lib/topics/calculus/midterm/screens/two_point_slope_screen/two_point_slope_steps.dart` — Major rewrite: replace `_StepCard` with minimal timeline style, replace `_LatexValue` with `_LatexInline`, consolidate step content display
- `lib/topics/calculus/midterm/screens/two_point_slope_screen/twopointslopescreen.dart` — Add graph toggle button, move graph out of steps section into its own togglable area
- `lib/topics/calculus/finals/solvers/evaluating_limits_solver/by_substitution/tokenizer.dart` — Fix line 74 superscript-2 Unicode character in `_preprocess()`
- `lib/topics/calculus/midterm/solvers/two_point_slope_solver/two_point_slope_solver.dart` — Minor: review step data format for compatibility with new display (may not need changes)

## Approach

### Step Card Redesign (Subtasks 1-3)

The reference style is in `substitution_steps_view.dart:28-111` — the `_StepTile` widget:

- Uses a `Stack` with a timeline line on the left (thin vertical connector between steps)
- Circled number indicator: 24x24 circle with border, step number centered inside, accent color
- Bold title text next to the circle
- Content below the title: explanation text + optional math expression in a simple container (no heavy borders)

The new `_StepCard` should:
- Drop the 48px wide colored left bar with number (current: lines 146-171)
- Drop the `Container` with `BoxDecoration` border (current: lines 136-140)
- Drop the divider between formula/substitution/result (current: lines 222-227)
- Drop the explanation row with info icon (current: lines 230-252)
- Instead: use the timeline circle style from the reference, show title bold, show a single consolidated LaTeX block below

The `_LatexInline` replacement should:
- Render `Math.tex` directly without wrapping `Container`
- Keep the `onErrorFallback` for graceful degradation
- Use the theme's `textPrimary` color, no background

### Graph Toggle (Subtask 4)

Currently in `twopointslopescreen.dart:424-435`:
```dart
if (_showSteps) ...[
  TwoPointSlopeSteps(result: _controller.result!),
  TwoPointSlopeGraph(result: _controller.result!),
],
```

The graph and steps are both gated by `_showSteps`. The redesign should:
- Keep `_showSteps` for the step-by-step solution
- Add a separate `_showGraph` boolean for the graph
- Place a small toggle button (icon: `Icons.show_chart_rounded` or similar) in the result card header row, next to the existing "Show steps" chip
- Render `TwoPointSlopeGraph` in its own `if (_showGraph)` block, positioned between the result card and the steps section

### Tokenizer Bug Fix (Subtask 5)

In `tokenizer.dart:74`:
```dart
result = result.replaceAll('?', '^2');
```

The `?` character is likely a corrupted `²` (U+00B2). The fix:
1. Replace with the correct Unicode: `result = result.replaceAll('\u00B2', '^2');`
2. Audit all other superscript lines (72-81) for similar corruption
3. Add a test case: tokenize an expression containing `²` and verify it produces the correct tokens

## Risks / Open Questions

- **LaTeX rendering of merged content**: When combining formula + substitution + result into a single LaTeX string, ensure the `flutter_math_fork` package can render it without layout issues. Test with fractions like `\frac{3}{2}` and inline expressions like `m = \frac{3}{2}`.
- **Unicode corruption scope**: The superscript characters in `tokenizer.dart` may all be corrupted, not just `²`. Need to verify lines 72-81 by examining the raw file bytes or comparing against expected Unicode code points.
- **Step data format compatibility**: The solver generates `formula`, `substitution`, and `result` as separate strings. The new UI merges them visually. No solver changes should be needed, but if the strings contain LaTeX that doesn't combine cleanly, minor formatting adjustments in the solver may be required.

## Non-Goals

- **Answer card changes**: The result card (slope display, equation tiles, slope type) is explicitly out of scope
- **Solver logic changes**: The mathematical computation in `two_point_slope_solver.dart` is not changing — only the display of steps
- **Graph rendering changes**: The `TwoPointSlopeGraph` widget itself is not being modified, only its visibility toggle behavior
- **Animation changes**: The existing fade/slide entrance animations for steps can remain as-is or be simplified to match the reference style
