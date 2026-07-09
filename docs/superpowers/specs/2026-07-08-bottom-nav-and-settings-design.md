# Bottom Navigation & Settings Screen

## Overview
Add a bottom navigation bar with two tabs (Home, Settings) and a new Settings screen. The activation gate was already removed — this restructures the app shell.

## Bottom Navigation
- **Two tabs:** Home (current category grid), Settings
- **Bar hides** when navigating into topic screens (Midterms, Finals, etc.) — only visible at root level
- Uses `IndexedStack` to preserve tab state across switches

## Settings Screen
Four distinct sections, visually separated:

### 1. Theme
- Dark/Light mode toggle switch
- Persists to `SharedPreferences`

### 2. Support
- "Donate" button — opens the existing donate sheet modal (GCash QR + number)

### 3. GitHub
- Opens `https://github.com/Shuash11` in system browser via `url_launcher`
- Shows a "View on GitHub" row with the GitHub icon and developer username

### 4. About
- App version (from `package_info_plus`)
- Developer name/credits
- Contact info

## Architecture
- New `AppShell` widget: `Scaffold` + `BottomNavigationBar` + `IndexedStack`
- GoRouter root route `/` renders `AppShell` instead of `CategoryPickerScreen`
- `AppShell` has two children: `CategoryPickerScreen` (Home tab), `SettingsScreen` (Settings tab)
- Existing topic routes push on top of the shell and hide the bottom bar
- `BottomNavigationBar` visibility controlled via `GoRouter` location or `Scaffold` state

## Files
| File | Action |
|------|--------|
| `lib/widgets/app_shell.dart` | **New** — Scaffold + BottomNav + IndexedStack |
| `lib/screens/settings_screen.dart` | **New** — Settings with 4 sections |
| `lib/app_router.dart` | **Modify** — root route points to AppShell, remove ActivationGate remnants |

## Testing
- `widget_test.dart` — update to verify BottomNav renders instead of activation screen
