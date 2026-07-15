# Maroon Removal & Color Unification Plan

## Feature Summary

Remove ALL maroon (`#7F1D1D`, `#9F2333`) and calculus blue (`#312C85`) color references from the MathCalcu app and unify the accent color system to use the bottom navigation bar's existing colors: `Color(0xFF334155)` (light mode) and `Color(0xFFE9ECEF)` (dark mode). Additionally, add glowing icon effects on cards and a glowing solve button in `MathInputField` in both light and dark mode.

---

## Subtask Breakdown

### Phase 1: Core Theme Changes

1. **Update `ThemeProvider.accentColor`** — `lib/theme/theme_provider.dart:26`
   - Replace both `Color(0xFF7F1D1D)` with light=`Color(0xFF334155)`, dark=`Color(0xFFE9ECEF)`

2. **Update `AppTheme` color schemes** — `lib/main.dart:259-288`
   - `AppTheme.light()` `primary`: `Color(0xFF7F1D1D)` → `Color(0xFF334155)`
   - `AppTheme.dark()` `primary`: `Color(0xFF9F2333)` → `Color(0xFFE9ECEF)`

3. **Update `AppDesign.app` theme** — `lib/theme/app_design.dart:31-49`
   - Replace `accent: Color(0xFF7F1D1D)` → `Color(0xFF334155)`
   - Replace `accentLight: Color(0xFF9F2333)` → `Color(0xFF3D4F6A)` (slightly lighter slate)
   - Update `headerGradient`, `cardGradient`, `cardGradientHover` to use new slate values

4. **Update `AppDesign.calculus` theme** — `lib/theme/app_design.dart:52-71`
   - Keep constants only (cardRadius, borderWidth, etc.) — remove the `calculus` instance entirely OR repurpose it with nav bar gray

### Phase 2: Module Registries

5. **Update `ModuleRegistry`** — `lib/core/module_registry.dart`
   - Replace all 9 `accent: Color(0xFF7F1D1D)` → `Color(0xFF334155)`

6. **Update `FinalsModuleRegistry`** — `lib/topics/calculus/finals/finals_module_registry.dart`
   - Replace all 4 `accent: Color(0xFF7F1D1D)` → `Color(0xFF334155)`

### Phase 3: Screen Files

7. **Update `CategoryPickerScreen` header** — `lib/screens/category_picker_screen.dart:152`
   - Replace `const accent = Color(0xFF7F1D1D)` → `Color(0xFF334155)`

8. **Update `CalculusPickerScreen`** — `lib/topics/calculus/calculus_picker_screen.dart`
   - `_buildHeader` line 76: Replace `Color(0xFF312C85)` → `Color(0xFF334155)`
   - `_buildBanner` line 175: Replace `Color(0xFF312C85)` → `Color(0xFF334155)`
    - `_buildList` line 264: Finals section color `Color(0xFF312C85)` → `Color(0xFF334155)`

9. **Update `ParallelPerpendicularModuleCard`** — `lib/screens/parallelperpendicularcard.dart:26`
   - Replace `_indigo = Color(0xFF312C85)` → `Color(0xFF334155)`

10. **Update `CircleCardPickerScreen`** — `lib/topics/calculus/midterm/cards/circles/card_picker_screen.dart`
    - Replace all `Color(0xFF7F1D1D)` references (lines 12, 100, 212, 215, 216, 220, 242, 251, 252)
    - Also replace `Color(0x4D7F1D1D)` and `Color(0x337F1D1D)` in the divider (lines 87-88)

### Phase 4: Widget Files

11. **Update `UpdateDialog`** — `lib/widgets/update_dialog.dart:29`
    - Replace `static const _accent = Color(0xFF7F1D1D)` → `Color(0xFF334155)`

12. **Update `WebUpdateDialog`** — `lib/widgets/web_update_dialog.dart:18`
    - Replace `static const _accent = Color(0xFF312C85)` → `Color(0xFF334155)`

13. **Update `DonateSheet`** — `lib/widgets/donate_sheet.dart:18`
    - Replace `static const _accent = Color(0xFF312C85)` → `Color(0xFF334155)`

14. **Update `AboutSheet`** — `lib/screens/about_sheets.dart:29`
    - Replace `const accent = Color(0xFF312C85)` → `Color(0xFF334155)`

15. **Update `DeveloperTile`** — `lib/widgets/developer_tile.dart`
    - Default accent line 15: `Color(0xFF312C85)` → `Color(0xFF334155)`
    - Avatar colors lines 26, 31: `Color(0xFF312C85)` → `Color(0xFF334155)`

16. **Update `FullScreenGraphScreen`** — `lib/shared/widgets/full_screen_graph_screen.dart:24`
    - Default `accentColor`: `Color(0xFF312C85)` → `Color(0xFF334155)`

17. **Update `main.dart` install permission dialog** — `lib/main.dart:88,91,126`
    - Replace `Color(0xFF7F1D1D)` with `Color(0xFF334155)`

### Phase 5: Glowing Effects

18. **Add glowing icon effect to `ModuleCard`** — `lib/shared/widgets/module_card.dart`
    - In the icon container `BoxDecoration`, add a `BoxShadow` with the accent color at low opacity to create a subtle halo/glow around card icons (both light and dark mode, intensity may vary)

19. **Add glowing solve button to `MathInputField`** — `lib/shared/widgets/math_input_field.dart`
    - Change solve button color from `widget.accentColor` to nav bar color (`Color(0xFF334155)` light / `Color(0xFFE9ECEF)` dark)
    - Add a `BoxShadow` glow effect on the button container in both light and dark mode (accent color with alpha ~0.25-0.30, blur ~10-15)

### Phase 6: Delete Midterm Theme Files

20. **Delete all 10 midterm theme files:**
    - `lib/topics/calculus/midterm/theme/slope_theme/slope_theme.dart`
    - `lib/topics/calculus/midterm/theme/distance_theme/distancetheme.dart`
    - `lib/topics/calculus/midterm/theme/midpoint_theme/midpointtheme.dart`
    - `lib/topics/calculus/midterm/theme/pointslope_theme/pointslopetheme.dart`
    - `lib/topics/calculus/midterm/theme/yintercept_theme/theme.dart`
    - `lib/topics/calculus/midterm/theme/two_point_slope_theme/two_point_slope_theme.dart`
    - `lib/topics/calculus/midterm/theme/circles_theme/centertheme.dart`
    - `lib/topics/calculus/midterm/theme/circles_theme/center_radius_theme.dart`
    - `lib/topics/calculus/midterm/theme/circles_theme/radiustheme.dart`
    - `lib/topics/calculus/midterm/theme/inequalities_theme/inequality_theme.dart`

21. **Fix broken imports** after deleting theme files — grep for any `import` referencing the deleted files and remove/update them

### Phase 7: Verification

22. **Run full grep for remaining maroon references** — search for `0xFF7F1D1D`, `0xFF9F2333`, and `maroon` in all `.dart` files
23. **Run full grep for remaining `0xFF312C85` references** — verify only the Finals section banner retains it
24. **Run `flutter analyze`** to verify no broken imports or compilation errors

---

## Files/Modules Expected to be Touched

### Modified (17 files):
| File | Change |
|------|--------|
| `lib/theme/theme_provider.dart` | accentColor getter |
| `lib/main.dart` | AppTheme color schemes + install dialog |
| `lib/theme/app_design.dart` | AppDesign.app theme + remove/repurpose calculus |
| `lib/core/module_registry.dart` | All module accent colors |
| `lib/topics/calculus/finals/finals_module_registry.dart` | All finals accent colors |
| `lib/screens/category_picker_screen.dart` | Header accent bar |
| `lib/topics/calculus/calculus_picker_screen.dart` | Header + banner accent (keep Finals color) |
| `lib/screens/parallelperpendicularcard.dart` | _indigo constant |
| `lib/topics/calculus/midterm/cards/circles/card_picker_screen.dart` | All maroon refs |
| `lib/widgets/update_dialog.dart` | _accent |
| `lib/widgets/web_update_dialog.dart` | _accent |
| `lib/widgets/donate_sheet.dart` | _accent |
| `lib/screens/about_sheets.dart` | accent |
| `lib/widgets/developer_tile.dart` | Default accent + avatar colors |
| `lib/shared/widgets/full_screen_graph_screen.dart` | Default accentColor |
| `lib/shared/widgets/module_card.dart` | Dark mode glow effect |
| `lib/shared/widgets/math_input_field.dart` | Glowing solve button |

### Deleted (10 files):
| File | Reason |
|------|--------|
| `lib/topics/calculus/midterm/theme/slope_theme/slope_theme.dart` | Maroon theme removal |
| `lib/topics/calculus/midterm/theme/distance_theme/distancetheme.dart` | Maroon theme removal |
| `lib/topics/calculus/midterm/theme/midpoint_theme/midpointtheme.dart` | Maroon theme removal |
| `lib/topics/calculus/midterm/theme/pointslope_theme/pointslopetheme.dart` | Maroon theme removal |
| `lib/topics/calculus/midterm/theme/yintercept_theme/theme.dart` | Maroon theme removal |
| `lib/topics/calculus/midterm/theme/two_point_slope_theme/two_point_slope_theme.dart` | Maroon theme removal |
| `lib/topics/calculus/midterm/theme/circles_theme/centertheme.dart` | Maroon theme removal |
| `lib/topics/calculus/midterm/theme/circles_theme/center_radius_theme.dart` | Maroon theme removal |
| `lib/topics/calculus/midterm/theme/circles_theme/radiustheme.dart` | Maroon theme removal |
| `lib/topics/calculus/midterm/theme/inequalities_theme/inequality_theme.dart` | Maroon theme removal |

---

## Approach Notes

- **Bottom nav bar as single source of truth**: The `AppShell` already defines `Color(0xFF334155)` (light) and `Color(0xFFE9ECEF)` (dark) as its accent. We propagate these exact values everywhere else.
- **ThemeProvider is the central getter**: `theme_provider.dart:26` `accentColor` is already used by many widgets. Updating it here cascades to most consumers automatically.
- **Glowing icons**: Use `BoxShadow` with the accent color at ~10-15% opacity and ~8-12px blur on the icon container, in both light and dark mode (slightly more intense in dark mode).
- **Glowing solve button**: Apply a `BoxShadow` with accent color at ~25-30% opacity and ~10-15px blur around the solve button container.
- **Midterm theme files are dead code**: These files define color constants that are already hardcoded to `0xFF7F1D1D`. They are not imported anywhere functional (all module screens inline their colors). Safe to delete.
- **All blue removed**: The `Color(0xFF312C85)` in the Finals section banner is also replaced with nav bar gray per updated spec.

---

## Risks / Open Questions

1. **Midterm theme file imports**: Need to verify no other files import the deleted theme files. If any do, those imports must be removed or the references updated.
2. **`AppDesign.calculus` usage**: Need to check if `AppDesign.calculus` is referenced anywhere beyond `app_design.dart`. If it is, those references need updating.
4. **Color contrast in dark mode**: `Color(0xFFE9ECEF)` on dark backgrounds is very light — verify it has sufficient contrast for accessibility.
5. **`parallelperpendicularcard.dart`**: This card has a complex multi-color system (`_indigo`, `_cyan`, `_sky`). Only `_indigo` changes; verify the other colors still look cohesive.

---

## Non-Goals

- Changing the bottom navigation bar itself (colors, layout, destinations)
- Changing any functional logic (only color constants)
- Updating the app icon or splash screen
- Changing the `AppTheme.light()` scaffold background (`Color(0xFFF4F4F1)`) or `AppTheme.dark()` scaffold background (`Color(0xFF1A1A2E)`)
