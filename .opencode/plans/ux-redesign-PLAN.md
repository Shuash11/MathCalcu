# UX Redesign — Unified Theme System

## Summary
Redesign MathCalcu with two unified themes:
- **App theme** (homepage, topics, settings): Deep Maroon `#7F1D1D`
- **Calculus theme** (midterm, finals, solution modals): Deep Blue `#1E3A5F`
All screens share the same widget styles (cards, modals, headers, step cards).

## Design Tokens

### App Theme (Homepage/Topics)
- Primary accent: `#7F1D1D` (deep maroon)
- Accent light: `#9F2333` (lighter maroon for gradients)
- Header gradient: `#7F1D1D` → `#4A0E1A` (maroon → dark maroon)
- Card gradient: maroon at 10% → maroon at 4%

### Calculus Theme (Midterm/Finals)
- Primary accent: `#1E3A5F` (deep blue)
- Accent light: `#2D5A8E` (lighter blue for gradients)
- Header gradient: `#1E3A5F` → `#0F1F33` (blue → dark blue)
- Card gradient: blue at 10% → blue at 4%

### Shared Constants
- Card radius: 20px
- Border width: 1.5px
- Shadow blur: 12px
- Icon circle: 52px
- Step circle: 28px

## Subtasks

### Task 1: Create AppDesign token class
- Create `lib/theme/app_design.dart` with accent, gradients, shared constants
- Two presets: `AppDesign.app` (maroon) and `AppDesign.calculus` (blue)

### Task 2: Update Homepage with maroon theme
- Update `home_card.dart` to use AppDesign tokens
- Update `home_screen.dart` header to use maroon gradient

### Task 3: Update Topics dashboard with maroon theme
- Update `topics_screen.dart` to use AppDesign.app tokens
- Update calculus picker to use AppDesign.calculus tokens

### Task 4: Update Midterm screens with shared blue theme
- Update midterm theme files to use `#1E3A5F` accent
- Ensure all midterm cards/modals use shared widget styles

### Task 5: Update Finals screens with shared blue theme
- Update `finals_theme.dart` to use `#1E3A5F` accent
- Update finals header gradient to blue

### Task 6: Update SolutionStepCard with shared style
- Ensure step card uses topic's accent color
- Update circle, divider, title styles

### Task 7: Update SolutionStepsModal with shared style
- Update modal header to use topic's accent
- Update drag handle, close button, icon

### Task 8: Run flutter analyze + flutter test

## Files to Change
- `C:\projects\mathcalcu\lib\theme\app_design.dart` (NEW)
- `C:\projects\mathcalcu\lib\home\home_card.dart`
- `C:\projects\mathcalcu\lib\home\home_screen.dart`
- `C:\projects\mathcalcu\lib\topics\topics_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\calculus_picker_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\*\*_theme.dart` (slope, inequality, radius)
- `C:\projects\mathcalcu\lib\topics\calculus\finals\finals_theme.dart`
- `C:\projects\mathcalcu\lib\shared\widgets\solution_step_card.dart`
- `C:\projects\mathcalcu\lib\shared\widgets\solution_steps_modal.dart`

## Risks
- Midterm theme files use hardcoded colors (radius_theme.dart)
- Some screens may need ThemeProvider integration
- Dark mode must still work with new themes

## Non-Goals
- Changing layouts or navigation
- Changing math logic
- Adding new screens
