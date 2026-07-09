# Settings Screen Professional Polish

## Goal
Enhance the Settings screen with a professional feel: staggered entrance animations, card-based rows with tap feedback, gradient section dividers, and a dedicated full-screen Developers page featuring all 6 contributors.

## Architecture

### Files Changed
- `lib/screens/settings_screen.dart` — enhanced with animations and card containers
- `lib/app_router.dart` — add `/developers` route

### Files Created
- `lib/screens/developers_screen.dart` — full-page developer cards screen
- `lib/models/developer.dart` — shared `Developer` data class (extracted from `about_sheets.dart`)
- `lib/widgets/developer_tile.dart` — shared expandable developer tile widget (extracted from `about_sheets.dart`)

### Refactoring
- Extract `_Developer` class from `about_sheets.dart` into `lib/models/developer.dart` as public `Developer`
- Extract `_DeveloperTile` and `_InfoRow` widgets from `about_sheets.dart` into `lib/widgets/developer_tile.dart`
- Update `about_sheets.dart` to import from shared files instead

## Design

### Settings Screen Polish
- Each row wrapped in a subtle card container (rounded 16, `theme.card`, soft shadow using accent at 8% opacity)
- Staggered fade-in + slide-up animation on page entry (matching Home screen's `AnimationController` pattern)
- Tap scale animation (0.97) on rows with `onTap`
- Section headers get a small accent-colored line beneath the text
- Gradient dividers between sections (replacing SizedBox with a thin gradient line)

### Developers Page
- Scaffold with AppBar (title: "Developers", centerTitle: true, bg: `theme.surface`)
- ListView of expandable developer cards with staggered entrance animation
- Each card: colored avatar initials circle, name, program, role pill
- Expand to show: email, Facebook, contribution, phone, group members
- Card design identical to current `about_sheets.dart` expandable tiles
- Back navigation via GoRouter pop

### Routing
- New path: `/developers` → `DevelopersScreen`
- Settings About section adds a "Developers" row → navigates to `/developers`

### Data
- `Developer` model: name, program, role, email, facebook, contribution, phone, groups (same fields as current `_Developer`)
- `developers` list constant moved to shared model file

## Verification
- `flutter analyze` — zero errors
- `flutter test` — all tests pass
- All 6 developer cards render with correct data
- Navigation from Settings → Developers and back works
