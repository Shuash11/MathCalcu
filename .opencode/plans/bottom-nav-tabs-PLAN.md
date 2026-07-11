# Plan: Add Topics, Notes, Calculator to Bottom Navigation Bar

## Summary
Expand the bottom navigation bar from 2 tabs (Home, Settings) to 5 tabs
(Home, Topics, Notes, Calculator, Settings). Users can navigate via bottom
nav OR home screen cards — both reach the same destination.

## Confirmed Spec
- 5 tabs: Home | Topics | Notes | Calculator | Settings
- Bottom nav tabs link to same screens as home cards
- Amber gold active state (FinalsTheme.primary)
- Tapping active tab resets to root of that tab
- Lazy-load tabs on first visit, keep state after
- Shows on all platforms (mobile, desktop, web)

## Subtask Breakdown

| # | Task | Description |
|---|------|-------------|
| 1 | Update AppShell | Replace 2-tab bottom nav with 5-tab layout (Home, Topics, Notes, Calculator, Settings) |
| 2 | Add icons | Pick and assign icons for each tab (home, book, sticky-note, calculator, gear) |
| 3 | Active state styling | Apply FinalsTheme amber gold to selected tab |
| 4 | Navigation routing | Wire each tab to its corresponding screen (TopicsScreen, NotesScreen, CalculatorScreen) |
| 5 | StatefulShellRoute | Use go_router's StatefulShellRoute for proper tab state preservation |
| 6 | Tap-to-reset | Tapping active tab resets to root of that tab's navigation stack |
| 7 | Verify | flutter analyze + flutter test |

## Files / Modules Touched
- `lib/widgets/app_shell.dart` — bottom nav bar (main change)
- `lib/app_router.dart` — may need route updates for new tabs
- `lib/home/home_screen.dart` — verify cards still work alongside nav
- `lib/topics/topics_screen.dart` — verify navigation from both entry points
- `lib/notes/notes_screen.dart` — verify navigation
- `lib/calculator/calculator_screen.dart` — verify navigation

## Approach
- Use `StatefulShellRoute.indexedStack` from go_router for tab state preservation
- Each tab gets its own Navigator with nested routes
- Bottom nav items map to shell branches
- Cards on Home screen use `context.go()` to same routes as nav tabs

## Risks / Open Questions
- Notes screen is currently a placeholder — no content to navigate to yet
- Calculator screen route already exists at `/calculator` — need to integrate into shell
- Ensuring existing midterm/finals routes still work under Topics tab

## Non-Goals
- Changing the content of any screen (Topics, Notes, Calculator)
- Adding new features to the screens themselves
- Changing the home screen card layout or design
