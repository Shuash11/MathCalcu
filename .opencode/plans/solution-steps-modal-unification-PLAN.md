# Plan: Convert All Solution Steps to Modal Bottom Sheet

## Summary
Unify ALL solution step displays across the MathCalcu app to use the shared `showSolutionStepsModal` + `SolutionStepCard` pattern. Currently, 8 screens use the modal (finals + two-point slope), while 11+ screens use inline toggles, dialogs, or custom modals. This plan converts the remaining screens for full consistency.

## Subtask Breakdown

### Task 1: Verify shared widgets are ready
- Read `lib/shared/widgets/solution_steps_modal.dart` and `lib/shared/widgets/solution_step_card.dart`
- Confirm they support the patterns needed (custom child content, math rendering)
- No code changes expected

### Task 2: Convert Slope screen
- Files: `slope_step_dialog.dart`, `slope_steps.dart`, `slope_step.dart`
- Replace `showDialog()` with `showSolutionStepsModal()`
- Migrate `SlopeSteps` content into `SolutionStepCard` instances
- Convert both single-line slope AND comparison steps (parallel/perpendicular/neither)
- Replace trigger with `OutlinedButton.icon`

### Task 3: Convert Y-Intercept screen
- File: `slope_intercept.dart`
- Replace inline toggle (`_showStepsNotifier`) with `showSolutionStepsModal()`
- Migrate `PointSlopeSteps` content into `SolutionStepCard` instances
- Replace toggle chip with `OutlinedButton.icon`

### Task 4: Convert Parallel/Perpendicular screen
- Files: `parallel_perpendicular_screen.dart`, `pp_stepblock_widget.dart`
- Replace custom `showModalBottomSheet` + `_SolutionStepsSheet` with shared `showSolutionStepsModal()`
- Migrate `PPStepBlock` content into `SolutionStepCard` instances
- Remove custom `_SolutionStepsSheet` widget

### Task 5: Convert Point-Slope screen
- Files: `pointslopescreen.dart`, `pointslopesteps.dart`
- Replace inline toggle with `showSolutionStepsModal()`
- Migrate `PointSlopeSteps` content into `SolutionStepCard` instances
- Remove `_showStepsNotifier` toggle pattern

### Task 6: Convert Distance screen
- File: `distancesteps.dart`
- Replace inline toggle with `showSolutionStepsModal()`
- Migrate `_StepItem` content into `SolutionStepCard` instances
- Remove `DistanceTheme` dependency (use FinalsTheme.primary)

### Task 7: Convert Midpoint screen (wrap only, no design changes)
- File: `midpointsteps.dart`
- Wrap existing `MidpointSteps` widget in `showSolutionStepsModal()`
- DO NOT change the step design — keep existing timeline/dots/layout
- Replace inline toggle with `OutlinedButton.icon` + modal

### Task 8: Convert Circles screens
- Files: `center_radius_form/solution_steps.dart`, `center_radius_form/step_tile.dart`, `radius/radius_steps.dart`, `center/step_section.dart`
- Replace inline display with `showSolutionStepsModal()`
- Migrate step content into `SolutionStepCard` instances
- Replace plain monospace text with proper math rendering

### Task 9: Unify Substitution steps to SolutionStepCard
- File: `by_substitution/substitution_steps_view.dart`
- Replace custom `_StepTile` timeline with `SolutionStepCard`
- Keep the modal wrapper (already uses `showSolutionStepsModal`)
- Match LCD/Conjugate style

### Task 10: Unify Factoring steps to SolutionStepCard
- File: `by_factoring/factoring_steps_view.dart`
- Replace custom `_StepTile` timeline with `SolutionStepCard`
- Keep the modal wrapper (already uses `showSolutionStepsModal`)
- Match LCD/Conjugate style

### Task 11: Full verification
- Run `flutter analyze` — zero errors
- Run `flutter test` — all passing
- Verify all screens compile and render correctly

## Files Touched

### Shared widgets (read-only, no changes expected):
- `lib/shared/widgets/solution_steps_modal.dart`
- `lib/shared/widgets/solution_step_card.dart`

### Midterm screens:
- `lib/topics/calculus/midterm/screens/slope_screen/slope_step_dialog.dart`
- `lib/topics/calculus/midterm/screens/slope_screen/slope_steps.dart`
- `lib/topics/calculus/midterm/screens/slope_screen/slope_step.dart`
- `lib/topics/calculus/midterm/screens/yintercept_screen/slope_intercept.dart`
- `lib/topics/calculus/midterm/screens/yintercept_screen/parallel_perpendicular_screen.dart`
- `lib/topics/calculus/midterm/screens/yintercept_screen/pp_stepblock_widget.dart`
- `lib/topics/calculus/midterm/screens/pointslope_screen/pointslopescreen.dart`
- `lib/topics/calculus/midterm/screens/pointslope_screen/pointslopesteps.dart`
- `lib/topics/calculus/midterm/screens/distance_screen/distancesteps.dart`
- `lib/topics/calculus/midterm/screens/midpoint_screen/midpointsteps.dart`
- `lib/topics/calculus/midterm/screens/circles_screen/center_radius_form/solution_steps.dart`
- `lib/topics/calculus/midterm/screens/circles_screen/center_radius_form/step_tile.dart`
- `lib/topics/calculus/midterm/screens/circles_screen/radius/radius_steps.dart`
- `lib/topics/calculus/midterm/screens/circles_screen/center/step_section.dart`

### Finals screens:
- `lib/topics/calculus/finals/screens/evaluating_limits_screen/by_substitution/substitution_steps_view.dart`
- `lib/topics/calculus/finals/screens/evaluating_limits_screen/by_factoring/factoring_steps_view.dart`

## Approach
1. Each screen: replace existing step display mechanism with `showSolutionStepsModal()`
2. Steps rendered with `SolutionStepCard` (numbered amber circle, bold title, description, math card)
3. "Show Steps" trigger becomes `OutlinedButton.icon` (consistent with finals screens)
4. For midpoint: keep existing `MidpointSteps` widget, just wrap in modal
5. Remove dead code (old step widgets, unused imports) after migration

## Risks
- Some step widgets have complex custom rendering (dual-panel, color-coded blocks) — may need adaptation
- Midpoint's "wrap only" approach means it won't visually match others — acceptable per user request
- Removing `DistanceTheme`/`SlopeTheme`/`PSTheme` dependencies may affect other parts of the screen

## Non-Goals
- Do NOT touch inequalities screens (quadratic, absolute)
- Do NOT redesign midpoint steps — only wrap in modal
- Do NOT touch legacy/unused step widgets (derivatives_steptile.dart, limits_step_tile.dart, limits_step_guide.dart, steps_screen.dart)
- Do NOT change the underlying step data/building logic
