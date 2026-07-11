# Readiness Report: Bottom Nav Tabs Feature

**Date:** Sat Jul 11, 2026  
**Auditor:** opencode (Readiness Auditor)  
**Feature:** Add Topics, Notes, Calculator to bottom navigation bar  
**Status:** ❌ NOT READY — 1 Critical issue found

---

## Spec

| # | Requirement | Verdict |
|---|-------------|---------|
| 1 | 5 tabs: Home / Topics / Notes / Calculator / Settings | ✅ PASS |
| 2 | Bottom nav tabs link to same screens as home cards | ✅ PASS |
| 3 | Amber gold active state (FinalsTheme.primary) | ✅ PASS |
| 4 | Tapping active tab resets to root of that tab | ✅ PASS |
| 5 | Lazy-load tabs on first visit, keep state after | ✅ PASS (via StatefulShellBranch) |
| 6 | Shows on all platforms | ✅ PASS (always rendered, no Platform checks) |

---

## File-by-File Findings

### `app_shell.dart` — Bottom Navigation Bar (78 lines)

| Check | Status | Detail |
|-------|--------|--------|
| 5 NavigationDestination widgets | ✅ | Home, Topics, Notes, Calculator, Settings (lines 47–73) |
| Icons use `_outlined` / `_rounded` pairs | ✅ | e.g. `Icons.home_outlined` / `Icons.home_rounded` |
| Active color = FinalsTheme.primary | ✅ | Line 20: `IconThemeData(color: FinalsTheme.primary)` |
| Indicator uses primary with alpha | ✅ | Line 17: `indicatorColor: FinalsTheme.primary.withValues(alpha: 0.20)` |
| `selectedIndex` wired to `navigationShell.currentIndex` | ✅ | Line 40 |
| `onDestinationSelected` calls `goBranch` | ✅ | Line 42 |
| Reset-to-root: `initialLocation: index == navigationShell.currentIndex` | ✅ | Line 44 — correct pattern |
| Background uses theme card color | ✅ | Line 16: `background: FinalsTheme.card(context)` |
| Label text uses bold for selected | ✅ | Line 27: `fontWeight: FontWeight.w700` for selected |
| No bracket mismatches | ✅ | `{` 8 / `}` 8, `(` 39 / `)` 39 |

**Verdict: CLEAN**

---

### `app_router.dart` — Router / StatefulShellBranches (306 lines)

| Check | Status | Detail |
|-------|--------|--------|
| StatefulShellRoute.indexedStack | ✅ | Line 62 |
| 5 branches defined | ✅ | Lines 67–165 |
| Branch 0 → `/` → HomeScreen | ✅ | Lines 67–74 |
| Branch 1 → `/topics` → TopicsScreen | ✅ | Lines 76–137 (with nested calculus routes) |
| Branch 2 → `/notes` → NotesScreen | ✅ | Lines 139–147 |
| Branch 3 → `/calculator` → CalculatorScreen | ✅ | Lines 149–155 |
| Branch 4 → `/settings` → SettingsScreen | ✅ | Lines 157–165 |
| AppShell wraps navigationShell | ✅ | Line 64 |
| All screen imports present | ✅ | `topics_screen.dart`, `notes_screen.dart`, `calculator_screen.dart`, `settings_screen.dart` all exist |
| Nested routes (topics/calculus/\*) preserved | ✅ | Lines 81–134 |
| Non-shell routes (inequalities, slope, etc.) preserved | ✅ | Lines 169–304 |
| No bracket mismatches | ✅ | `{` 3 / `}` 3 at file level (inner braces are in route definitions) |
| Parentheses balanced | ✅ | `(` 138 / `)` 138 |

**Verdict: CLEAN**

---

### `home_screen.dart` — Home Cards (101 lines)

| Check | Status | Detail |
|-------|--------|--------|
| 3 HomeCard widgets | ✅ | Topics, Notes, Calculator (lines 72–89) |
| Topics card → `context.go('/topics')` | ✅ | Line 76 |
| Notes card → `context.go('/notes')` | ✅ | Line 82 |
| Calculator card → `context.go('/calculator')` | ✅ | Line 88 |
| Uses `context.go()` (not `context.push()`) | ✅ | Correct for shell navigation |
| No bracket mismatches | ✅ | `{` 5 / `}` 5, `(` 35 / `)` 35 |

**Verdict: CLEAN**

---

## Screen Implementations

| Screen | File | Real UI? | Notes |
|--------|------|----------|-------|
| HomeScreen | `lib/home/home_screen.dart` | ✅ Yes | Grid of cards, logo, title |
| TopicsScreen | `lib/topics/topics_screen.dart` | ✅ Yes | Real screen (exists) |
| NotesScreen | `lib/notes/notes_screen.dart` | ❌ STUB | Shows "Coming soon!" placeholder |
| CalculatorScreen | `lib/calculator/calculator_screen.dart` | ✅ Yes | Full calculator with engine |
| SettingsScreen | `lib/screens/settings_screen.dart` | ✅ Yes | Real screen (exists) |

---

## Critical Issue

### [CRITICAL] NotesScreen is a "Coming soon!" placeholder

**File:** `lib/notes/notes_screen.dart:36`  
**Problem:** The Notes tab shows a centered "Coming soon!" text with a note icon. This is a stub, not a real screen. Users tapping the Notes tab will see an empty placeholder with no functionality.

**Impact:** This directly contradicts the spec. The bottom nav creates the expectation that Notes is a first-class tab with real content. A "Coming soon!" stub undermines the entire feature.

**Secondary issue:** The NotesScreen has an AppBar with a back button (`Navigator.of(context).pop()` at line 19). Since Notes is a root-level tab in the bottom nav, there's nothing to "go back" to — this back button is confusing UX. The screen should not have a back button when accessed via the bottom nav.

**Fix required:** Either:
- (A) Implement a real Notes screen with list/create/edit functionality, or
- (B) If Notes is genuinely not ready, remove it from the bottom nav and home cards entirely. The spec says "5 tabs" — shipping 4 real tabs + 1 stub is worse than shipping 4 tabs.

---

## Summary

| Category | Count |
|----------|-------|
| Critical | 1 |
| Important | 0 |
| Low | 0 |
| Passed | 14 |

**Bottom line:** The nav bar implementation, router wiring, theme styling, reset-to-root behavior, and home card navigation are all correct and production-ready. The one blocker is the Notes screen being a stub. Fix that and the feature is ready to ship.
