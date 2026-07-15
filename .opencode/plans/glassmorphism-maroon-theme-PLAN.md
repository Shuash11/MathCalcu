# Glassmorphism Maroon Theme — Implementation Plan

## Summary
Refactor MathCalcu to use a professional glassmorphism design with maroon accent colors throughout. Apply frosted glass card effects, subtle blur, gradient accents, and soft shadows. Use the 60-30-10 rule: 60% dark surface (#1A1A2E), 30% card/surface (#232340), 10% maroon accent (#7F1D1D).

---

## Design System

### Colors (60-30-10 Rule)
| Role | Hex | Usage |
|---|---|---|
| **Surface (60%)** | `#1A1A2E` | Page backgrounds, scaffold |
| **Card (30%)** | `#232340` | Card surfaces, nav bar, inputs |
| **Maroon Accent (10%)** | `#7F1D1D` | CTA buttons, highlights, interactive |
| **Maroon Light** | `#9F2333` | Hover states, gradients |
| **Danger** | `#DC2626` | Errors only (keep existing) |
| **Text Primary** | `#F4F4F1` | Body text |
| **Text Secondary** | `#F4F4F1 @ 60%` | Labels, hints |

### Glassmorphism Card Style
- Background: card color with 85% opacity
- Border: 1px accent at 15% opacity
- Shadow: accent at 10% opacity, 20px blur, offset (0,8)
- Backdrop blur: not available in Flutter, approximate with semi-transparent bg
- Border radius: 20px (existing convention)

---

## Subtask Breakdown

### Task 1: Update FinalsTheme — maroon accent
**File:** `C:\projects\mathcalcu\lib\topics\calculus\finals\finals_theme.dart`
- Change `primary` from `#312C85` (indigo) → `#7F1D1D` (maroon)
- Change `secondary` from `#0C0C09` → `#0C0C09` (keep as-is)
- Change `headerGradient` from indigo→charcoal → maroon→dark-maroon (`#7F1D1D` → `#4A0E1A`)
- Update `cardGlow()` gradient to use maroon tints
- Update `labelStyle()` to use `primary` with 0.8 alpha
- Keep `tertiary` (`#16A34A`) and `danger` (`#DC2626`) unchanged

### Task 2: Update ThemeProvider — maroon accent color
**File:** `C:\projects\mathcalcu\lib\theme\theme_provider.dart`
- Change `accentColor` (dark) from `#6366F1` (indigo) → `#7F1D1D` (maroon)
- Change `accentColor` (light) from `#312C85` → `#7F1D1D`
- Keep surface, card, cardSecondary, textPrimary, textSecondary unchanged (already correct)

### Task 3: Update AppTheme in main.dart — maroon primary
**File:** `C:\projects\mathcalcu\lib\main.dart`
- `AppTheme.light()` colorScheme.primary → `#7F1D1D` (already correct)
- `AppTheme.dark()` colorScheme.primary → `#9F2333` (already correct)
- Verify `AppTheme.dark().scaffoldBackgroundColor` → `#1A1A2E` (already correct)
- Verify `AppTheme.dark().colorScheme.surface` → `#232340` (already correct)

### Task 4: Update AppDesign — glassmorphism tokens
**File:** `C:\projects\mathcalcu\lib\theme\app_design.dart`
- `AppDesign.app.accent` → `#7F1D1D` (already correct)
- `AppDesign.app.headerGradient` → maroon gradient (already correct)
- Add glassmorphism constants:
  - `glassBorderRadius = 20.0`
  - `glassBorderOpacity = 0.15`
  - `glassShadowOpacity = 0.10`
  - `glassShadowBlur = 20.0`

### Task 5: Update AppShell — glassmorphism bottom nav
**File:** `C:\projects\mathcalcu\lib\widgets\app_shell.dart`
- `NavigationBarTheme.backgroundColor` → use `FinalsTheme.card(context)` (already correct)
- `indicatorColor` → maroon at 20% alpha (already uses FinalsTheme.primary)
- Add glassmorphism border/shadow to the NavigationBar container:
  - Wrap NavigationBar in Container with glassmorphism decoration
  - Add top border: 1px maroon at 10% opacity
  - Add shadow: maroon at 5% opacity, 12px blur

### Task 6: Update HomeScreen — glassmorphism cards
**File:** `C:\projects\mathcalcu\lib\home\home_screen.dart`
- No direct color changes needed (uses HomeCard with accent param)
- HomeCard already receives accent color from parent

### Task 7: Update HomeCard — glassmorphism card style
**File:** `C:\projects\mathcalcu\lib\home\widgets\home_card.dart`
- Update card decoration to glassmorphism:
  - Background: LinearGradient with card color at 85% opacity
  - Border: 1px accent at 15% opacity
  - Shadow: accent at 10% opacity, 20px blur
- Keep existing hover/press animations

### Task 8: Update TopicsScreen — glassmorphism
**File:** `C:\projects\mathcalcu\lib\topics\topics_screen.dart`
- Already uses `theme.surface` and `FinalsTheme.primary` — no changes needed

### Task 9: Update CalculatorScreen — glassmorphism display
**File:** `C:\projects\mathcalcu\lib\calculator\calculator_screen.dart`
- Update display container decoration to glassmorphism:
  - Background: card color with subtle maroon gradient overlay
  - Border: 1px maroon at 15% opacity
- Button styling already uses FinalsTheme.primary — verify maroon appears

### Task 10: Update FinalsPickerScreen — glassmorphism banner
**File:** `C:\projects\mathcalcu\lib\topics\calculus\finals\finals_picker_screen.dart`
- Banner container already uses `FinalsTheme.primary` with alpha — will update automatically
- Header gradient uses `FinalsTheme.headerGradient` — will update automatically
- No manual changes needed

### Task 11: Update FinalsModuleCard (default card) — glassmorphism
**File:** `C:\projects\mathcalcu\lib\topics\calculus\finals\finals_picker_screen.dart`
- `_FinalsDefaultCard` already uses `theme.card` and accent-based decorations
- Will update automatically when FinalsTheme.primary changes to maroon

### Task 12: Update all finals module cards — glassmorphism
**Files:**
- `C:\projects\mathcalcu\lib\topics\calculus\finals\cards\derivatives\derevatives_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\cards\limits_infinity\limits_and_infinity_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\cards\evaluating_limits\evaluationg_limits.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\cards\evaluating_limits\substitution_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\cards\evaluating_limits\conjugate_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\cards\evaluating_limits\factoring_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\cards\evaluating_limits\lcd_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\cards\slope_using_derivatives\finding_slope_derevatives_card.dart`

These cards use `FinalsTheme.primary`, `FinalsTheme.secondary`, `FinalsTheme.tertiary`, `FinalsTheme.danger` — colors propagate automatically. Cards that use `FinalsTheme.danger` for slope-derivative card keep red accent (appropriate for that card's identity).

### Task 13: Update slope solver screen — glassmorphism inputs
**File:** `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\slope_using_derivatives_screen\slope_solver_screen.dart`
- SOLVE button already uses `AppDesign.app.accent` — will show maroon
- Input fields already use `FinalsTheme.card(context)` — will show card color
- `FinalsTheme.labelStyle` will use maroon — updates automatically

### Task 14: Update slope answer card — glassmorphism
**File:** `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\slope_using_derivatives_screen\answer_card.dart`
- Uses `FinalsTheme.danger` for accent — keep red (slope/derivative identity)
- No changes needed

### Task 15: Update limits infinity screen — glassmorphism
**File:** `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\limits_infinity_screen\limits_infinity_screen.dart`
- Uses `FinalsTheme.primary` throughout — will update to maroon automatically
- No manual changes needed

### Task 16: Update limits input field — glassmorphism
**File:** `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\limits_infinity_screen\limits_input_field.dart`
- Uses `FinalsTheme.card(context)` and `FinalsTheme.primary` — updates automatically

### Task 17: Update limits answer card — glassmorphism
**File:** `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\limits_infinity_screen\limits_answer_card.dart`
- Uses `FinalsTheme.primary` and `FinalsTheme.cardGlow()` — updates automatically

### Task 18: Update derivatives screen — glassmorphism
**File:** `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\derivatives_screen\derivatives_screen.dart`
- Uses `FinalsTheme.primary` throughout — updates automatically

### Task 19: Update evaluating limits picker — glassmorphism
**File:** `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\evaluating_limits_picker.dart`
- Uses `FinalsTheme.primary` — updates automatically

### Task 20: Update all evaluating limits sub-screens — glassmorphism
**Files:**
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_substitution\substitution_limit_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_substitution\substitution_answer_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_substitution\substitution_input_field.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_conjugate\conjugate_limit_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_conjugate\conjugate_answer_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_conjugate\conjugate_input_field.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_factoring\factoring_limit_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_factoring\factoring_answer_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_factoring\factoring_input_field.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_lcd\lcd_limit_screen.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_lcd\lcd_answer_card.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\finals\screens\evaluating_limits_screen\by_lcd\lcd_input_field.dart`

All use `FinalsTheme.primary` — updates automatically.

### Task 21: Update main.dart dialog — maroon accent
**File:** `C:\projects\mathcalcu\lib\main.dart`
- `_requestInstallPermission()` dialog uses hardcoded `Color(0xFF7F1D1D)` — already maroon, no changes needed

### Task 22: Run flutter analyze
- Execute `flutter analyze` and fix any new warnings/errors

### Task 23: Run flutter test
- Execute `flutter test` and fix any failures

---

## Files to Change (Manual Edits Required)

| # | File | Change |
|---|---|---|
| 1 | `C:\projects\mathcalcu\lib\topics\calculus\finals\finals_theme.dart` | primary → maroon, headerGradient → maroon gradient, cardGlow → maroon tints |
| 2 | `C:\projects\mathcalcu\lib\theme\theme_provider.dart` | accentColor → maroon |
| 3 | `C:\projects\mathcalcu\lib\theme\app_design.dart` | Add glassmorphism constants |
| 4 | `C:\projects\mathcalcu\lib\widgets\app_shell.dart` | Glassmorphism nav bar decoration |
| 5 | `C:\projects\mathcalcu\lib\home\widgets\home_card.dart` | Glassmorphism card decoration |
| 6 | `C:\projects\mathcalcu\lib\calculator\calculator_screen.dart` | Glassmorphism display container |

**Auto-propagated (no manual edit):** All finals screens, cards, and sub-screens that reference `FinalsTheme.*` constants will update automatically.

---

## Approach
1. Update core theme files first (FinalsTheme, ThemeProvider, AppDesign)
2. Update shell/navigation (AppShell)
3. Update card components (HomeCard)
4. Update calculator display
5. Verify all finals screens propagate correctly
6. Run flutter analyze + flutter test

---

## Risks

| Risk | Impact | Mitigation |
|---|---|---|
| FinalsTheme color change propagates to 40+ files | Low | Constants propagate automatically — most files don't need manual edits |
| Glassmorphism approximation (no real blur in Flutter) | Low | Semi-transparent backgrounds + shadows approximate the effect well |
| Slope-derivative card uses `danger` (red) accent | None | Intentional — different module identity, keep red |
| Hardcoded colors in some screens | Medium | Audit all files for `Color(0xFF...)` values; most use FinalsTheme constants |

---

## Non-Goals
- Changing screen layouts or navigation flow
- Adding real backdrop blur (not supported in Flutter without packages)
- Changing math logic, solvers, or parsers
- Modifying the calculator keyboard layout
- Changing graph rendering
- Adding new dependencies

---

## Acceptance Criteria
- [ ] All screens use maroon accent (#7F1D1D) consistently for interactive elements
- [ ] Glassmorphism card style with semi-transparent backgrounds, subtle borders, soft shadows
- [ ] 60-30-10 rule: 60% dark surface, 30% card, 10% maroon accent
- [ ] `flutter analyze` passes with no new errors
- [ ] `flutter test` passes
- [ ] Professional, cohesive look across all screens
