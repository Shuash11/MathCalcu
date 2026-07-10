# Landing Page Design — MathCalcu

## Overview

Replace the current `CategoryPickerScreen` (midterm topics list) as the app's home screen with a modern, responsive landing page. This establishes MathCalcu as a multi-purpose math app, not just a calculus solver.

## Goals

- Clean, professional first impression with app branding
- Responsive grid that works on mobile, tablet, and desktop
- Clear navigation to Topics (Midterm/Finals), Notes, and Calculator
- Extensible structure for future features
- Modular architecture — each feature in its own directory

## Layout

### Header
- Centered app logo (icon or image) + "MathCalcu" title
- Clean, no back button (this is the root screen)

### Body — Responsive Grid
- **Mobile (<600px):** 2 columns
- **Tablet (600–900px):** 3 columns
- **Desktop (>900px):** 3 columns, max-width 600px centered
- Cards arranged vertically with even spacing

### Card Design
- Rounded corners (16px radius)
- Subtle shadow (elevation 2)
- Centered icon (32px, primary color)
- Label below icon (14px, medium weight)
- Tap feedback: ripple + slight scale animation
- Background: card color from theme

### Cards

| Card | Icon | Destination | Notes |
|------|------|-------------|-------|
| Topics | `Icons.school_rounded` | Topics sub-page | Leads to Midterm / Finals picker |
| Notes | `Icons.note_alt_rounded` | N/A | Placeholder — shows "Coming soon" snackbar |
| Calculator | `Icons.calculate_rounded` | N/A | Placeholder — shows "Coming soon" snackbar |

## Architecture — Modular File Structure

Each feature lives in its own directory under `lib/` with a clear parent-child relationship. Midterm and Finals are sub-modules inside `topics/`.

```
lib/
├── home/                              ← Home module (new)
│   ├── home_screen.dart               ← Landing page with grid
│   └── widgets/
│       └── home_card.dart             ← Reusable card widget
│
├── topics/                            ← Topics module (new)
│   ├── topics_screen.dart             ← Sub-page: Midterm / Finals cards
│   ├── midterm/                       ← Midterm sub-module (moved from lib/midterm/)
│   │   ├── category_picker_screen.dart
│   │   ├── cards/
│   │   ├── screens/
│   │   └── ...
│   └── finals/                        ← Finals sub-module (moved from lib/Finals/)
│       ├── finals_picker_screen.dart
│       ├── screens/
│       └── ...
│
├── notes/                             ← Notes module (placeholder, new)
│   └── notes_screen.dart              ← "Coming soon" placeholder
│
├── calculator/                        ← Calculator module (placeholder, new)
│   └── calculator_screen.dart         ← "Coming soon" placeholder
│
├── settings/                          ← EXISTING settings
│   └── settings_screen.dart
│
├── shared/                            ← EXISTING shared widgets/services
│   └── ...
│
├── theme/                             ← EXISTING theme
│   └── ...
│
├── app_router.dart
├── main.dart
└── ...
```

### What Changes

| Action | Path | Description |
|--------|------|-------------|
| **Create** | `lib/home/home_screen.dart` | Landing page with responsive grid |
| **Create** | `lib/home/widgets/home_card.dart` | Reusable card component |
| **Create** | `lib/topics/topics_screen.dart` | Topics sub-page (Midterm/Finals cards) |
| **Create** | `lib/notes/notes_screen.dart` | Placeholder screen |
| **Create** | `lib/calculator/calculator_screen.dart` | Placeholder screen |
| **Move** | `lib/midterm/` → `lib/topics/midterm/` | Relocate into topics module |
| **Move** | `lib/Finals/` → `lib/topics/finals/` | Relocate into topics module |
| **Modify** | `lib/app_router.dart` | Restructure routes, update imports |
| **Modify** | `lib/widgets/app_shell.dart` | Simplify bottom nav (Home + Settings) |
| **Delete** | `lib/midterm/` | After move is complete |
| **Delete** | `lib/Finals/` | After move is complete |

## Navigation Structure

```
Home (Branch 0)
└── /topics
    ├── /topics/midterm → CategoryPickerScreen
    └── /topics/finals  → FinalsPickerScreen
```

Bottom nav:
1. **Home** — `Icons.home_rounded` → `/` (HomeScreen)
2. **Settings** — `Icons.settings_rounded` → `/settings`

Note: The old "Finals" tab (Branch 1) is removed. Finals is now accessed via Home → Topics → Finals.

## Router Changes (`app_router.dart`)

**Before:**
```
StatefulShellRoute
├── Branch 0: / → CategoryPickerScreen
└── Branch 1: /second-sem → FinalsPickerScreen
```

**After:**
```
StatefulShellRoute
├── Branch 0: / → HomeScreen
│   └── /topics → TopicsScreen
│       ├── /topics/midterm → CategoryPickerScreen
│       └── /topics/finals → FinalsPickerScreen
└── Branch 1: /settings → SettingsScreen
```

## Behavior

- **Topics card tap** → navigates to `/topics` (TopicsScreen)
- **Notes card tap** → shows snackbar "Coming soon!"
- **Calculator card tap** → shows snackbar "Coming soon!"
- TopicsScreen has back button → returns to home
- TopicsScreen has 2 cards: Midterm, Finals (same grid style)

## Visual Style

- Follows existing theme (dark/light via ThemeProvider)
- Primary color accent on icons
- Card background uses `theme.card`
- Text uses `theme.textPrimary`
- Logo uses primary color or app icon
