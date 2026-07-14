# MathCalcu UI Redesign — Minimal Design System

## Overview
Apply the Open Design **Minimal** design system to MathCalcu as a theme + tokens-only redesign. No layout changes — only color, typography, and spacing values are replaced across the app.

**Design system source:** Open Design `minimal` (Modern & Minimal category)
**Scope:** Theme + tokens only — same layouts, same widgets, same navigation

---

## Minimal Design System (from Open Design)

### Colors
| Token | Hex | Usage |
|---|---|---|
| **Primary** | `#0C0C09` | CTA buttons, strong emphasis |
| **Secondary** | `#312C85` | Accent, interactive elements, highlights |
| **Surface** | `#F4F4F1` | Page backgrounds, cards |
| **Text** | `#0C0C09` | Body copy, labels |
| **Success** | `#16A34A` | Positive states |
| **Warning** | `#D97706` | Caution states |
| **Danger** | `#DC2626` | Errors, destructive actions |
| **Neutral** | `#F4F4F1` | Borders, subtle dividers |

### Typography
- **Primary:** Open Sans (body, UI)
- **Display:** Inter (headings)
- **Mono:** Inconsolata (code/math)
- **Weights:** 400, 500, 600, 700

### Spacing
- Scale: `4, 8, 12, 16, 24, 32`

---

## Current → New Color Mapping

| Current Token | Current Hex | New Hex | Notes |
|---|---|---|---|
| FinalsTheme.primary | `#FFB020` (amber) | `#312C85` (indigo) | Accent color for buttons, highlights |
| FinalsTheme.secondary | `#FF6B35` (orange) | `#0C0C09` (charcoal) | Secondary actions, CTA emphasis |
| FinalsTheme.tertiary | `#FFD166` (yellow) | `#16A34A` (green) | Success/positive states |
| FinalsTheme.danger | `#EF476F` (rose) | `#DC2626` (red) | Destructive/error states |
| ThemeProvider.surface (dark) | `#0A0A0F` | `#F4F4F1` | Background — **light mode only** |
| ThemeProvider.surface (light) | `#F7F7FA` | `#F4F4F1` | Same |
| ThemeProvider.card (dark) | `#12121A` | `#FFFFFF` | Card backgrounds |
| ThemeProvider.card (light) | `#FFFFFF` | `#FFFFFF` | Same |
| ThemeProvider.cardSecondary (dark) | `#0D0D14` | `#E8E6E2` | Secondary card surfaces |
| ThemeProvider.cardSecondary (light) | `#F0F0F5` | `#E8E6E2` | Same |
| ThemeProvider.textPrimary (dark) | `#E8E8F0` | `#0C0C09` | **Text flips to dark** |
| ThemeProvider.textPrimary (light) | `#1E1E28` | `#0C0C09` | Same |
| ThemeProvider.textSecondary (dark) | `#E8E8F0 @ 40%` | `#0C0C09 @ 60%` | **Text flips to dark** |
| ThemeProvider.textSecondary (light) | `#1E1E28 @ 60%` | `#0C0C09 @ 60%` | Same |

### Key change: Dark mode removed
Minimal is a light-first design system. The dark mode toggle will be **removed** — the app will be light-only (surface `#F4F4F1` with dark text `#0C0C09`). The ThemeProvider will simplify to a single mode.

---

## Implementation Phases

### Phase 1: Core Theme Files (3 files)

**File 1: `lib/theme/theme_provider.dart`**
- Remove `isLight` toggle logic (Minimal = light-only)
- Remove `SharedPreferences` theme persistence
- Update all color getters to Minimal tokens
- Surface: `#F4F4F1`
- Card: `#FFFFFF`
- CardSecondary: `#E8E6E2`
- TextPrimary: `#0C0C09`
- TextSecondary: `#0C0C09` at 60% opacity
- ShadowColor: `#0C0C09` at 8% opacity
- AccentColor: `#312C85`

**File 2: `lib/topics/calculus/finals/finals_theme.dart`**
- Primary: `#312C85` (indigo)
- Secondary: `#0C0C09` (charcoal)
- Tertiary: `#16A34A` (green)
- Danger: `#DC2626` (red)
- HeaderGradient: indigo → charcoal
- Update typography: Inter for headings, Open Sans for body
- Remove `isLight` references

**File 3: `lib/main.dart`**
- Remove dark-mode SystemUiOverlayStyle (no more `Brightness.light` for dark mode)
- Set status bar to light background + dark icons: `SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark)`

### Phase 2: Screen Color Updates (59 files)

All 59 files that reference `FinalsTheme.*` will have their color values automatically updated via the theme constants. However, files with **hardcoded colors** need manual updates:

Files with hardcoded colors to audit:
- `lib/calculator/calculator_screen.dart` — check for hardcoded `Color(0xFF...)` values
- `lib/home/home_screen.dart` — check for hardcoded colors
- `lib/notes/notes_screen.dart` — check for hardcoded colors
- `lib/widgets/app_shell.dart` — check for hardcoded colors
- `lib/topics/topics_screen.dart` — check for hardcoded colors

### Phase 3: Remove Dark Mode Toggle

**Files to update:**
- `lib/settings/settings_screen.dart` — remove theme toggle switch
- `lib/main.dart` — simplify SystemUiOverlayStyle
- `lib/widgets/app_shell.dart` — remove any theme-dependent styling

### Phase 4: Typography Update

**Files to update:**
- `lib/topics/calculus/finals/finals_theme.dart` — change font families
- Add Google Fonts dependency if not already present (Inter, Open Sans, Inconsolata)
- Update `pubspec.yaml` if fonts need to be bundled

### Phase 5: Verification

1. Run `flutter analyze` — no new errors
2. Run `flutter test` — all tests pass
3. Manual review: All screens should show:
   - Off-white background (`#F4F4F1`)
   - Dark text (`#0C0C09`)
   - Indigo accents (`#312C85`)
   - No more gold/amber colors
   - No more dark mode toggle

---

## Risk Assessment

| Risk | Impact | Mitigation |
|---|---|---|
| Dark mode removal breaks UX expectation | Medium | User confirmed "follow design system" — Minimal is light-only |
| Hardcoded colors bypass theme | Medium | Audit all files for hardcoded Color values |
| Font loading fails on some platforms | Low | Google Fonts are well-supported; fallback to system fonts |
| 59+ files need color updates | Low | FinalsTheme constants propagate automatically — most changes are in 3 core files |

---

## Out of Scope (explicitly NOT changing)
- Screen layouts (card arrangements, spacing, padding)
- Widget structures (same components, same hierarchy)
- Navigation flow (same routes, same bottom nav)
- Math logic (solvers, calculators, parsers)
- Solution steps UI structure
- Calculator keyboard layout
- Graph rendering

---

## Success Criteria
1. No gold/amber (`#FFB020`, `#FF6B35`, `#FFD166`) colors anywhere in the app
2. Surface is always off-white (`#F4F4F1`)
3. Accent color is indigo (`#312C85`) for all interactive elements
4. Text is dark (`#0C0C09`) on light backgrounds
5. No dark mode toggle in settings
6. `flutter analyze` passes
7. `flutter test` passes
