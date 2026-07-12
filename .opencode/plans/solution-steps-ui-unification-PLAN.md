# Solution Steps UI Unification

## Feature Summary

Unify all solution steps UI across the MathCalcu app to match a consistent style: numbered golden circles with bold titles, descriptions, and math in dark cards. All screens must use the modal bottom sheet (`solution_steps_modal.dart`). Don't touch inequalities or midpoint screens.

---

## Confirmed Spec

1. All solution steps screens use modal bottom sheet (`showSolutionStepsModal`)
2. All screens use `FinalsTheme.primary` (golden/amber) as accent color
3. Style: numbered circles (amber with border), bold white titles, lighter description text, math in dark cards with amber math text
4. Don't touch: inequalities screens (quadratic, absolute), midpoint screen

---

## Screens to Update

| # | Screen | File | What Needs to Change |
|---|--------|------|---------------------|
| 1 | LCD steps view | `lcd_steps_view.dart` | Needs titles added + style update |
| 2 | Conjugate steps view | `conjugate_steps_view.dart` | Style update (remove cards, use numbered circles) |
| 3 | Two-point slope steps | `two_point_slope_steps.dart` | Style update (use FinalsTheme.primary) |
| 4 | Slope Using Derivatives | `steps_items_widget.dart` / `answer_card.dart` | Switch from StepsScreen navigation to modal |
| 5 | Derivatives screen | `derivatives_screen.dart` / `derivatives_steptile.dart` | Switch from inline steps to modal |
| 6 | Limits Infinity screen | `limits_infinity_screen.dart` / `limits_step_guide.dart` | Switch from inline steps to modal |

---

## Files to Touch

```
lib/topics/calculus/finals/screens/evaluating_limits_screen/by_lcd/lcd_steps_view.dart
lib/topics/calculus/finals/screens/evaluating_limits_screen/by_conjugate/conjugate_steps_view.dart
lib/topics/calculus/midterm/screens/two_point_slope_screen/two_point_slope_steps.dart
lib/topics/calculus/finals/screens/slope_using_derivatives_screen/steps_items_widget.dart
lib/topics/calculus/finals/screens/slope_using_derivatives_screen/answer_card.dart
lib/topics/calculus/finals/screens/derivatives_screen/derivatives_screen.dart
lib/topics/calculus/finals/screens/derivatives_screen/derivatives_steptile.dart
lib/topics/calculus/finals/screens/limits_infinity_screen/limits_infinity_screen.dart
lib/topics/calculus/finals/screens/limits_infinity_screen/limits_step_guide.dart
```

---

## Approach

### Option A: Shared Step Widget (Recommended)

Create a reusable `SolutionStepCard` widget in the shared location (near `solution_steps_modal.dart`) that encapsulates the unified style:

```dart
class SolutionStepCard extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String? description;
  final Widget mathContent;

  const SolutionStepCard({
    required this.stepNumber,
    required this.title,
    this.description,
    required this.mathContent,
  });
}
```

**Widget layout:**
- Row: numbered circle (amber fill + amber border, white bold number) + Column (bold white title + lighter description)
- Below: dark card with amber math text

### Option B: Update Each Screen Individually

Update each screen's step rendering to match the style without a shared widget. Less DRY but avoids a refactor dependency.

**Recommendation:** Option A — fewer touch points per screen, easier to maintain consistency.

### Modal Integration

For screens currently using inline steps or `StepsScreen` navigation:
1. Replace the call to `StepsScreen` or inline widget with `showSolutionStepsModal(context, ...)`
2. Pass the same steps data to the modal

---

## Implementation Steps

### Phase 1: Create Shared Widget

1. Read `solution_steps_modal.dart` to understand existing modal structure
2. Create `SolutionStepCard` widget near the modal file
3. Style the widget to match the confirmed spec

### Phase 2: Update Style-Only Screens

4. Update `lcd_steps_view.dart` — add titles + apply new style
5. Update `conjugate_steps_view.dart` — remove cards, apply numbered circles
6. Update `two_point_slope_steps.dart` — switch to FinalsTheme.primary

### Phase 3: Switch to Modal

7. Update `slope_using_derivatives_screen` — replace StepsScreen navigation with modal
8. Update `derivatives_screen.dart` — replace inline steps with modal
9. Update `limits_infinity_screen.dart` — replace inline steps with modal

### Phase 4: Verify

10. Test each screen to confirm consistent appearance
11. Ensure inequalities and midpoint screens are untouched

---

## Risks

| Risk | Mitigation |
|------|-----------|
| LCD steps don't have titles | Add descriptive titles derived from step content |
| Derivatives screen has complex inline steps with rule formulas | Ensure mathContent widget handles formula display |
| Slope Using Derivatives navigates to a separate screen | Replace navigation with modal call, pass same data |

---

## Non-Goals

- Do not touch inequalities screens (quadratic, absolute)
- Do not touch midpoint screen
- Do not change the modal's fundamental behavior (only its content rendering)
