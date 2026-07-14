# Responsive Text Plan — MathCalcu

## Summary

Make all text in MathCalcu shrink-to-fit rather than wrap to new lines. Create a shared `ResponsiveText` widget that auto-scales font size based on available width, with a minimum of ~10px. Apply it across all 40+ screens, including plain text labels, titles, step headers, math formulas, and tab bar labels.

---

## Current State

- **Text rendering**: Raw `Text` widgets with hardcoded `fontSize` throughout
- **Math rendering**: `Math.tex()` / `SelectableMath.tex()` from `flutter_math_fork`
- **Existing scaling**: `FittedBox(fit: BoxFit.scaleDown)` already wraps math in `answer_card.dart`, `two_point_slope_steps.dart`, and several step views
- **Tab bar**: `NavigationBar` in `app_shell.dart` with `labelTextStyle` at fixed 12px; custom tab bars in `center_radiusui.dart` and elsewhere
- **Existing helper**: `ResponsiveCardMixin` in `midterm/core/` — scales padding/layout by screen width, but NOT text

---

## Approach

### 1. Create `ResponsiveText` widget (`lib/shared/widgets/responsive_text.dart`)

```dart
/// Auto-scales font size to fit available width. Never wraps.
/// - Starts at [style.fontSize], shrinks until text fits or hits [minFontSize]
/// - Uses LayoutBuilder + RichText + TextPainter for measurement
/// - Wraps in FittedBox(fit: BoxFit.scaleDown) internally
/// - Supports all Text widget properties (overflow, textAlign, maxLines=1)
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double minFontSize;        // default 10
  final int maxLines;              // default 1
  final TextAlign textAlign;
  final TextOverflow overflow;
  final double? width;             // override available width (optional)

  const ResponsiveText({
    required this.text,
    required this.style,
    this.minFontSize = 10,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
    this.overflow = TextOverflow.visible,
    this.width,
  });
}
```

**Implementation strategy:**
- Wrap content in `LayoutBuilder` to get available width
- Use `FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft)` wrapping a `Text` widget
- `FittedBox` already handles the "shrink to fit" behavior — it scales down the entire widget when the child exceeds the constraint
- For `maxLines: 1`, the natural constraint of `Expanded`/`SizedBox` width prevents wrapping
- No need for manual TextPainter measurement — `FittedBox` + `BoxFit.scaleDown` already does exactly what we want

### 2. Create `ResponsiveMath` widget (`lib/shared/widgets/responsive_math.dart`)

```dart
/// Wraps Math.tex / SelectableMath.tex in FittedBox for auto-scaling.
/// Drop-in replacement for raw Math.tex usage.
class ResponsiveMath extends StatelessWidget {
  final String tex;
  final TextStyle? textStyle;
  final MathStyle mathStyle;
  final bool selectable;           // use SelectableMath.tex if true

  const ResponsiveMath({
    required this.tex,
    this.textStyle,
    this.mathStyle = MathStyle.text,
    this.selectable = false,
  });
}
```

### 3. Update theme helpers to support responsive scaling

- `FinalsTheme.titleStyle()` — add optional `responsive` parameter
- `FinalsTheme.subtitleStyle()` — add optional `responsive` parameter
- `FinalsTheme.labelStyle()` — add optional `responsive` parameter
- Each module theme (`SlopeTheme`, `YITheme`, `InequalityTheme`, etc.) — update their `titleStyle`/`subtitleStyle`/`labelStyle` methods

---

## Subtask Breakdown

### Subtask 1: Create shared widgets
**Files:**
- `C:\projects\mathcalcu\lib\shared\widgets\responsive_text.dart` (NEW)
- `C:\projects\mathcalcu\lib\shared\widgets\responsive_math.dart` (NEW)

### Subtask 2: Update FinalsTheme typography helpers
**Files:**
- `C:\projects\mathcalcu\lib\topics\calculus\finals\finals_theme.dart`

### Subtask 3: Update all module themes
**Files:**
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\theme\slope_theme\slope_theme.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\theme\yintercept_theme\theme.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\theme\two_point_slope_theme\two_point_slope_theme.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\theme\pointslope_theme\pointslopetheme.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\theme\midpoint_theme\midpointtheme.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\theme\distance_theme\distancetheme.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\theme\inequalities_theme\inequality_theme.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\theme\circles_theme\centertheme.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\theme\circles_theme\center_radius_theme.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\theme\circles_theme\radiustheme.dart`

### Subtask 4: Update navigation & tab bar labels
**Files:**
- `C:\projects\mathcalcu\lib\widgets\app_shell.dart` — NavigationBar `labelTextStyle`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\circles_screen\center_radius_form\center_radiusui.dart` — custom tab bar

### Subtask 5: Update shared widgets (highest impact — touches all screens)
**Files:**
- `C:\projects\mathcalcu\lib\shared\widgets\answer_card.dart` — already uses FittedBox, verify/standardize
- `C:\projects\mathcalcu\lib\shared\widgets\solution_step_card.dart` — title, description, step label
- `C:\projects\mathcalcu\lib\shared\widgets\steps_drawer.dart` — step text, hints, details
- `C:\projects\mathcalcu\lib\shared\widgets\solution_steps_modal.dart` — header title
- `C:\projects\mathcalcu\lib\home\widgets\home_card.dart` — card label text

### Subtask 6: Update home & top-level screens
**Files:**
- `C:\projects\mathcalcu\lib\home\home_screen.dart` — "MathCalcu", "Your math companion"
- `C:\projects\mathcalcu\lib\topics\topics_screen.dart` — AppBar title
- `C:\projects\mathcalcu\lib\notes\notes_screen.dart` — AppBar title, body text
- `C:\projects\mathcalcu\lib\calculator\calculator_screen.dart` — "Calculator" title, button labels, display text
- `C:\projects\mathcalcu\lib\screens\settings_screen.dart` — settings labels
- `C:\projects\mathcalcu\lib\screens\developers_screen.dart` — developer list text
- `C:\projects\mathcalcu\lib\screens\category_picker_screen.dart` — card labels
- `C:\projects\mathcalcu\lib\topics\calculus\calculus_picker_screen.dart` — section labels
- `C:\projects\mathcalcu\lib\main.dart` — dialog text, error text

### Subtask 7: Update calculator topic cards
**Files:**
- `C:\projects\mathcalcu\lib\screens\slopecard.dart`
- `C:\projects\mathcalcu\lib\screens\twopointslopecard.dart`
- `C:\projects\mathcalcu\lib\screens\pointslopecard.dart`
- `C:\projects\mathcalcu\lib\screens\y-interceptcard.dart`
- `C:\projects\mathcalcu\lib\screens\parallelperpendicularcard.dart`
- `C:\projects\mathcalcu\lib\screens\midpointcard.dart`
- `C:\projects\mathcalcu\lib\screens\distancecard.dart`
- `C:\projects\mathcalcu\lib\screens\inequality.dart`
- `C:\projects\mathcalcu\lib\screens\circlecard.dart`

### Subtask 8: Update slope screen family
**Files:**
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\slope_screen\slopescreen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\slope_screen\slope_result.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\slope_screen\slope_step.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\slope_screen\slope_steps.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\slope_screen\slope_comparison.dart`

### Subtask 9: Update two-point slope screen
**Files:**
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\two_point_slope_screen\twopointslopescreen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\two_point_slope_screen\two_point_slope_steps.dart`

### Subtask 10: Update y-intercept screen family
**Files:**
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\yintercept_screen\slope_intercept.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\yintercept_screen\slope_intercept_scr.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\yintercept_screen\slope_intercept_steps.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\yintercept_screen\parallel_perpendicular_screen.dart`

### Subtask 11: Update point-slope screen
**Files:**
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\pointslope_screen\pointslopescreen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\pointslope_screen\pointslopesteps.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\pointslope_screen\pointslopesubwidget.dart`

### Subtask 12: Update midpoint screen
**Files:**
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\midpoint_screen\midpointscreen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\midpoint_screen\midpointsteps.dart`

### Subtask 13: Update distance screen
**Files:**
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\distance_screen\distancescreen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\distance_screen\distancesteps.dart`

### Subtask 14: Update inequalities screen family
**Files:**
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\inequalities_screen\base_inequality_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\inequalities_screen\simple_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\inequalities_screen\strict_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\inequalities_screen\non_strict_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\inequalities_screen\quadratic_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\inequalities_screen\rational_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\inequalities_screen\radical_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\inequalities_screen\absolute_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\inequalities_screen\continued_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\inequalities_screen\card_picker_screen.dart`

### Subtask 15: Update circles screen family
**Files:**
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\circles_screen\center_radius_form\center_radiusui.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\circles_screen\center_radius_form\input_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\circles_screen\center_radius_form\step_tile.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\circles_screen\center_radius_form\solution_steps.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\circles_screen\center_radius_form\widgets_inputcard\equation_input_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\circles_screen\center\centerui.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\circles_screen\center\formula_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\circles_screen\center\header_bar.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\circles_screen\center\input_section.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\circles_screen\center\result_section.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\circles_screen\center\step_section.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\circles_screen\radius\radiusui.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\circles_screen\radius\radius_formula_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\circles_screen\radius\radius_header.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\circles_screen\radius\radius_input_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\circles_screen\radius\radius_result.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\circles_screen\radius\radius_steps.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\cards\circles\card_picker_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\cards\circles\finding_center_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\cards\circles\finding_center_radius_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\cards\circles\finding_radius_card.dart`

### Subtask 16: Update finals screens — evaluating limits
**Files:**
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\evaluating_limits_picker.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_substitution\substitution_limit_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_substitution\substitution_steps_view.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_substitution\substitution_answer_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_substitution\substitution_input_field.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_lcd\lcd_limit_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_lcd\lcd_steps_view.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_lcd\lcd_answer_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_lcd\lcd_input_field.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_factoring\factoring_limit_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_factoring\factoring_steps_view.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_factoring\factoring_answer_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_factoring\factoring_input_field.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_conjugate\conjugate_limit_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_conjugate\conjugate_steps_view.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_conjugate\conjugate_answer_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_conjugate\conjugate_input_field.dart`

### Subtask 17: Update finals screens — limits at infinity
**Files:**
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\limits_infinity_screen\limits_infinity_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\limits_infinity_screen\limits_math_display.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\limits_infinity_screen\limits_step_tile.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\limits_infinity_screen\limits_step_guide.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\limits_infinity_screen\limits_answer_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\limits_infinity_screen\limits_input_field.dart`

### Subtask 18: Update finals screens — derivatives
**Files:**
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\derivatives_screen\derivatives_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\derivatives_screen\derivatives_steptile.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\derivatives_screen\derivatives_answer_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\derivatives_screen\derivatives_input_field.dart`

### Subtask 19: Update finals screens — slope using derivatives
**Files:**
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\slope_using_derivatives_screen\slope_solver_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\slope_using_derivatives_screen\steps_items_widget.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\slope_using_derivatives_screen\steps_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\slope_using_derivatives_screen\answer_card.dart`

### Subtask 20: Update finals topic cards
**Files:**
- `C:\projects\mathcalcu\lib\topics\calculus\finals\cards\evaluating_limits\evaluationg_limits.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\cards\evaluating_limits\substitution_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\cards\evaluating_limits\lcd_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\cards\evaluating_limits\factoring_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\cards\evaluating_limits\conjugate_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\cards\limits_infinity\limits_and_infinity_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\cards\slope_using_derivatives\finding_slope_derevatives_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\cards\derivatives\derevatives_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\finals_picker_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\widgetsScreens\finals_about_sheets.dart`

### Subtask 21: Update inequality topic cards
**Files:**
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\cards\inequalities\animated_inequality_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\cards\inequalities\simple_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\cards\inequalities\strict_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\cards\inequalities\non_strict_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\cards\inequalities\quadratic_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\cards\inequalities\rational_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\cards\inequalities\radical_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\cards\inequalities\absolute_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\cards\inequalities\continued_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\cards\inequalities\linear_card.dart`

### Subtask 22: Update widget/dialog files
**Files:**
- `C:\projects\mathcalcu\lib\widgets\update_dialog.dart`
- `C:\projects\mathcalcu\lib\widgets\web_update_dialog.dart`
- `C:\projects\mathcalcu\lib\widgets\donate_sheet.dart`
- `C:\projects\mathcalcu\lib\widgets\developer_tile.dart`
- `C:\projects\mathcalcu\lib\screens\about_sheets.dart`
- `C:\projects\mathcalcu\lib\shared\widgets\math_input_field.dart`
- `C:\projects\mathcalcu\lib\shared\widgets\full_screen_graph_screen.dart`
- `C:\projects\mathcalcu\lib\shared\widgets\graph_widget.dart`
- `C:\projects\mathcalcu\lib\shared\widgets\math_keyboard.dart`

### Subtask 23: Run analyzer & verify
**Action:** Run `flutter analyze` and fix any issues. Test on multiple screen sizes.

---

## Risks

1. **Math.tex inside FittedBox**: `Math.tex` renders as a Widget, not text — FittedBox should work but needs verification that the rendered math scales cleanly without artifacts
2. **Performance**: FittedBox measures on every layout pass. For screens with many text elements (inequality cards, step lists), this could cause jank. Mitigation: the measurement is lightweight (just text layout)
3. **SelectableMath.tex**: Wrapping `SelectableMath.tex` in `FittedBox` may conflict with selection behavior. May need to keep raw `SelectableMath.tex` in places where user selection is important (steps drawer)
4. **Tab bar labels**: Flutter's `NavigationBar` applies its own text scaling to `labelTextStyle`. The `ResponsiveText` approach may not work directly inside it — may need to use `textScaler` on the `TextScaler.linear` approach or keep fixed 12px for tab labels (they're short and constrained)
5. **Breaking layout**: Some screens rely on text having a specific rendered size for alignment. Auto-shrinking could shift visual alignment. Need visual QA pass

## Non-Goals

- **No changes to font families** — keep existing typography
- **No changes to math rendering engine** — keep `flutter_math_fork`
- **No new dependencies** — use only Flutter built-ins (`FittedBox`, `LayoutBuilder`)
- **No changes to graph widgets** — axis labels are painted on Canvas, not Text widgets
- **No changes to code logic/solvers** — only UI text rendering
