# Solution Steps Design Unification Plan

## Summary
Unify ALL solution steps screens to match the exact design shown in the user's screenshot. Update the shared `SolutionStepCard` and `SolutionStepsModal` widgets, then ensure all consuming screens use the updated design.

## Design Changes (from screenshot)
1. **Step circles**: Dark circle with white border + white number (replacing amber filled circles)
2. **Step labels**: Add "Step N" text in gray, followed by a horizontal divider line
3. **Titles**: Bold white text after the divider
4. **Header**: Updated styling to match screenshot (dark icon container, yellow list icon, X button)
5. **Accent color**: FinalsTheme.primary (amber/gold) used consistently
6. **Math cards**: Dark cards with standardized math styling

## Subtask Breakdown

### Task 1: Update `SolutionStepCard` widget
- Change step circle from amber filled to dark with white border
- Add "Step N" label text in gray
- Add horizontal divider line between step number and title
- Keep bold white title styling
- File: `lib/shared/widgets/solution_step_card.dart`

### Task 2: Update `SolutionStepsModal` header
- Update header styling to match screenshot
- Ensure icon container, title, and X button match design
- File: `lib/shared/widgets/solution_steps_modal.dart`

### Task 3: Verify all screens compile
- Run `flutter analyze` to ensure no errors
- Run `flutter test` to ensure tests pass

## Files to Modify
- `lib/shared/widgets/solution_step_card.dart` — core widget
- `lib/shared/widgets/solution_steps_modal.dart` — header

## Files Using These Widgets (verify after changes)
- `lib/topics/calculus/midterm/screens/yintercept_screen/slope_intercept_steps.dart`
- `lib/topics/calculus/midterm/screens/yintercept_screen/slope_intercept_scr.dart`
- `lib/topics/calculus/midterm/screens/yintercept_screen/parallel_perpendicular_screen.dart`
- `lib/topics/calculus/midterm/screens/two_point_slope_screen/two_point_slope_steps.dart`
- `lib/topics/calculus/midterm/screens/two_point_slope_screen/twopointslopescreen.dart`
- `lib/topics/calculus/midterm/screens/pointslope_screen/pointslopesteps.dart`
- `lib/topics/calculus/midterm/screens/pointslope_screen/pointslopescreen.dart`
- `lib/topics/calculus/midterm/screens/midpoint_screen/midpointscreen.dart`
- `lib/topics/calculus/midterm/screens/slope_screen/slope_comparison.dart`
- `lib/topics/calculus/midterm/screens/distance_screen/distancesteps.dart`
- `lib/topics/calculus/midterm/screens/distance_screen/distancescreen.dart`
- `lib/topics/calculus/midterm/screens/slope_screen/slope_step_dialog.dart`
- `lib/topics/calculus/midterm/screens/slope_screen/slope_steps.dart`
- `lib/topics/calculus/finals/screens/evaluating_limits_screen/by_substitution/substitution_steps_view.dart`
- `lib/topics/calculus/finals/screens/evaluating_limits_screen/by_substitution/substitution_limit_screen.dart`
- `lib/topics/calculus/finals/screens/limits_infinity_screen/limits_infinity_screen.dart`
- `lib/topics/calculus/finals/screens/evaluating_limits_screen/by_lcd/lcd_steps_view.dart`
- `lib/topics/calculus/finals/screens/slope_using_derivatives_screen/answer_card.dart`
- `lib/topics/calculus/finals/screens/evaluating_limits_screen/by_lcd/lcd_limit_screen.dart`
- `lib/topics/calculus/finals/screens/evaluating_limits_screen/by_factoring/factoring_steps_view.dart`
- `lib/topics/calculus/finals/screens/evaluating_limits_screen/by_factoring/factoring_limit_screen.dart`
- `lib/topics/calculus/midterm/screens/circles_screen/radius/radiusui.dart`
- `lib/topics/calculus/finals/screens/evaluating_limits_screen/by_conjugate/conjugate_steps_view.dart`
- `lib/topics/calculus/finals/screens/evaluating_limits_screen/by_conjugate/conjugate_limit_screen.dart`
- `lib/topics/calculus/midterm/screens/circles_screen/center_radius_form/center_radiusui.dart`
- `lib/topics/calculus/finals/screens/derivatives_screen/derivatives_screen.dart`
- `lib/topics/calculus/midterm/screens/circles_screen/center/center_screen.dart`

## Risks
- Screens that pass custom `mathContent` widgets may need adjustments if the new math styling changes spacing
- Some screens may have inline styling that conflicts with the new design

## Non-Goals
- Changing the modal behavior (drag-to-dismiss, scroll, etc.)
- Changing the underlying math logic or step calculations
- Adding new features or functionality

## Acceptance Criteria
- All solution steps screens have identical visual design
- `flutter analyze` passes with 0 errors
- `flutter test` passes
