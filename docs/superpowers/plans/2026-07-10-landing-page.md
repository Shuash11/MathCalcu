# Landing Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a modern responsive landing page with grid cards (Topics, Notes, Calculator) and restructure the app's navigation so Midterm/Finals live under a Topics module.

**Architecture:** New `home/` module with a responsive grid screen, new `topics/` module as parent for Midterm/Finals, placeholder modules for Notes and Calculator. Router restructured to use Home as root with Topics as a sub-route. Bottom nav simplified to Home + Settings.

**Tech Stack:** Flutter, go_router, Provider (theme), existing ThemeProvider

---

## File Structure

```
lib/
├── home/                              ← NEW
│   ├── home_screen.dart               ← Landing page with grid
│   └── widgets/
│       └── home_card.dart             ← Reusable card widget
├── topics/                            ← NEW
│   ├── topics_screen.dart             ← Midterm / Finals cards
│   ├── midterm/                       ← MOVED from lib/midterm/
│   └── finals/                        ← MOVED from lib/Finals/
├── notes/                             ← NEW (placeholder)
│   └── notes_screen.dart
├── calculator/                        ← NEW (placeholder)
│   └── calculator_screen.dart
├── app_router.dart                    ← MODIFY
├── widgets/app_shell.dart             ← MODIFY
└── ...existing...
```

---

### Task 1: Create HomeCard widget

**Files:**
- Create: `lib/home/widgets/home_card.dart`

- [ ] **Step 1: Create the home_card.dart file**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';

class HomeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const HomeCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: theme.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 36,
                    color: theme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify no analysis errors**

Run: `cd C:\projects\mathcalcu && flutter analyze lib/home/widgets/home_card.dart`
Expected: No errors (info warnings are fine)

- [ ] **Step 3: Commit**

```bash
cd C:\projects\mathcalcu
git add lib/home/widgets/home_card.dart
git commit -m "feat: add HomeCard widget for landing page grid"
```

---

### Task 2: Create HomeScreen

**Files:**
- Create: `lib/home/home_screen.dart`

- [ ] **Step 1: Create the home_screen.dart file**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calculus_system/home/widgets/home_card.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final width = MediaQuery.of(context).size.width;

    // Responsive columns
    int crossAxisCount;
    if (width < 600) {
      crossAxisCount = 2;
    } else if (width < 900) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 3;
    }

    return Scaffold(
      backgroundColor: theme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Logo
                  Icon(
                    Icons.calculate_rounded,
                    size: 64,
                    color: theme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'MathCalcu',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your math companion',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Grid
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.0,
                      children: [
                        HomeCard(
                          icon: Icons.school_rounded,
                          label: 'Topics',
                          onTap: () => context.push('/topics'),
                        ),
                        HomeCard(
                          icon: Icons.note_alt_rounded,
                          label: 'Notes',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Coming soon!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        HomeCard(
                          icon: Icons.calculate_rounded,
                          label: 'Calculator',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Coming soon!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify no analysis errors**

Run: `cd C:\projects\mathcalcu && flutter analyze lib/home/home_screen.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
cd C:\projects\mathcalcu
git add lib/home/home_screen.dart
git commit -m "feat: add HomeScreen with responsive grid layout"
```

---

### Task 3: Create TopicsScreen

**Files:**
- Create: `lib/topics/topics_screen.dart`

- [ ] **Step 1: Create the topics_screen.dart file**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calculus_system/home/widgets/home_card.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class TopicsScreen extends StatelessWidget {
  const TopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final width = MediaQuery.of(context).size.width;

    int crossAxisCount;
    if (width < 600) {
      crossAxisCount = 2;
    } else if (width < 900) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 3;
    }

    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Topics',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: theme.textPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
          children: [
            HomeCard(
              icon: Icons.functions_rounded,
              label: 'Midterm',
              onTap: () => context.push('/topics/midterm'),
            ),
            HomeCard(
              icon: Icons.timeline_rounded,
              label: 'Finals',
              onTap: () => context.push('/topics/finals'),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify no analysis errors**

Run: `cd C:\projects\mathcalcu && flutter analyze lib/topics/topics_screen.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
cd C:\projects\mathcalcu
git add lib/topics/topics_screen.dart
git commit -m "feat: add TopicsScreen with Midterm/Finals cards"
```

---

### Task 4: Create placeholder screens

**Files:**
- Create: `lib/notes/notes_screen.dart`
- Create: `lib/calculator/calculator_screen.dart`

- [ ] **Step 1: Create notes_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notes',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: theme.textPrimary,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_alt_rounded, size: 64, color: theme.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Coming soon!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Create calculator_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Calculator',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: theme.textPrimary,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calculate_rounded, size: 64, color: theme.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Coming soon!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Verify no analysis errors**

Run: `cd C:\projects\mathcalcu && flutter analyze lib/notes/ lib/calculator/`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
cd C:\projects\mathcalcu
git add lib/notes/ lib/calculator/
git commit -m "feat: add placeholder screens for Notes and Calculator"
```

---

### Task 5: Move midterm and finals into topics module

**Files:**
- Move: `lib/midterm/` → `lib/topics/midterm/`
- Move: `lib/Finals/` → `lib/topics/finals/`

- [ ] **Step 1: Move midterm directory**

```bash
cd C:\projects\mathcalcu
xcopy /E /I /Y lib\midterm lib\topics\midterm
rmdir /S /Q lib\midterm
```

- [ ] **Step 2: Move Finals directory**

```bash
cd C:\projects\mathcalcu
xcopy /E /I /Y lib\Finalls lib\topics\finals
rmdir /S /Q lib\Finalls
```

Wait — the directory is `lib/Finals/` (capital F). Let me use the correct command:

```bash
cd C:\projects\mathcalcu
xcopy /E /I /Y lib\Finals lib\topics\finals
rmdir /S /Q lib\Finals
```

- [ ] **Step 3: Update all imports in app_router.dart**

Replace all `midterm/` imports with `topics/midterm/` and all `Finals/` imports with `topics/finals/`.

File: `lib/app_router.dart`

Replace these imports (lines 1-36):
```dart
import 'topics/midterm/screens/circles_screen/center/center_screen.dart';
import 'topics/midterm/screens/circles_screen/radius/radiusui.dart';
import 'package:calculus_system/topics/midterm/screens/yintercept_screen/slope_intercept_scr.dart';
import 'package:calculus_system/topics/midterm/screens/yintercept_screen/parallel_perpendicular_screen.dart';
import 'package:flutter/material.dart';
import 'package:calculus_system/topics/midterm/screens/distance_screen/distancescreen.dart';
import 'package:go_router/go_router.dart';
import 'package:calculus_system/widgets/app_shell.dart';
import 'package:calculus_system/screens/developers_screen.dart';
import 'package:calculus_system/screens/category_picker_screen.dart';
import 'package:calculus_system/screens/settings_screen.dart';

import 'topics/midterm/screens/inequalities_screen/card_picker_screen.dart';
import 'topics/midterm/screens/inequalities_screen/strict_screen.dart';
import 'topics/midterm/screens/inequalities_screen/non_strict_screen.dart';
import 'topics/midterm/screens/inequalities_screen/absolute_screen.dart';
import 'topics/midterm/screens/inequalities_screen/continued_screen.dart';
import 'topics/midterm/screens/inequalities_screen/simple_screen.dart';
import 'topics/midterm/screens/inequalities_screen/rational_screen.dart';
import 'topics/midterm/screens/inequalities_screen/quadratic_screen.dart';
import 'topics/midterm/screens/inequalities_screen/radical_screen.dart';
import 'topics/midterm/screens/slope_screen/slopescreen.dart';
import 'topics/midterm/screens/midpoint_screen/midpointscreen.dart';
import 'topics/midterm/screens/pointslope_screen/pointslopescreen.dart';
import 'topics/midterm/screens/two_point_slope_screen/twopointslopescreen.dart';
import 'topics/midterm/cards/circles/card_picker_screen.dart';
import 'topics/midterm/screens/circles_screen/center_radius_form/center_radiusui.dart';
import 'package:calculus_system/topics/finals/finals_picker_screen.dart';
import 'package:calculus_system/topics/finals/screens/derivatives_screen/derivatives_screen.dart';
import 'package:calculus_system/topics/finals/screens/slope_using_derivatives_screen/slope_solver_screen.dart';
import 'package:calculus_system/topics/finals/screens/limits_infinity_screen/limits_infinity_screen.dart';
import 'package:calculus_system/topics/finals/screens/evaluating_limits_screen/evaluating_limits_picker.dart';
import 'package:calculus_system/topics/finals/screens/evaluating_limits_screen/by_substitution/substitution_limit_screen.dart';
import 'package:calculus_system/topics/finals/screens/evaluating_limits_screen/by_conjugate/conjugate_limit_screen.dart';
import 'package:calculus_system/topics/finals/screens/evaluating_limits_screen/by_factoring/factoring_limit_screen.dart';
import 'package:calculus_system/topics/finals/screens/evaluating_limits_screen/by_lcd/lcd_limit_screen.dart';
```

- [ ] **Step 4: Update imports in any other files that reference midterm/ or Finals/**

Run grep to find all files importing from midterm/ or Finals/:
```bash
cd C:\projects\mathcalcu
rg "import.*midterm/" lib/ --files-with-matches
rg "import.*Finals/" lib/ --files-with-matches
```

Update each file's imports to use `topics/midterm/` or `topics/finals/` paths.

- [ ] **Step 5: Verify no analysis errors**

Run: `cd C:\projects\mathcalcu && flutter analyze`
Expected: No errors (info warnings fine)

- [ ] **Step 6: Commit**

```bash
cd C:\projects\mathcalcu
git add -A
git commit -m "refactor: move midterm and finals into topics module"
```

---

### Task 6: Update AppShell — simplify bottom nav

**Files:**
- Modify: `lib/widgets/app_shell.dart`

- [ ] **Step 1: Update app_shell.dart**

Replace the entire file with:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calculus_system/Finals/finals_theme.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: FinalsTheme.card(context),
          indicatorColor: FinalsTheme.primary.withValues(alpha: 0.20),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: FinalsTheme.primary);
            }
            return IconThemeData(color: FinalsTheme.textSecondary(context));
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: FinalsTheme.primary,
              );
            }
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: FinalsTheme.textSecondary(context),
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            navigationShell.goBranch(index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify no analysis errors**

Run: `cd C:\projects\mathcalcu && flutter analyze lib/widgets/app_shell.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
cd C:\projects\mathcalcu
git add lib/widgets/app_shell.dart
git commit -m "feat: simplify bottom nav to Home + Settings"
```

---

### Task 7: Update router — restructure routes

**Files:**
- Modify: `lib/app_router.dart`

- [ ] **Step 1: Add new imports**

Add these imports at the top of `lib/app_router.dart`:

```dart
import 'package:calculus_system/home/home_screen.dart';
import 'package:calculus_system/topics/topics_screen.dart';
```

- [ ] **Step 2: Restructure the StatefulShellRoute**

Replace the entire `StatefulShellRoute.indexedStack` block (lines 57-127) with:

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) =>
      AppShell(navigationShell: navigationShell),
  branches: [
    // Branch 0 — Home
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'topics',
              builder: (context, state) => const TopicsScreen(),
              routes: [
                GoRoute(
                  path: 'midterm',
                  builder: (context, state) => const CategoryPickerScreen(),
                ),
                GoRoute(
                  path: 'finals',
                  builder: (context, state) => const FinalsPickerScreen(),
                  routes: [
                    GoRoute(
                      path: 'derivatives',
                      builder: (context, state) => const DerivativeScreen(),
                    ),
                    GoRoute(
                      path: 'slope-derivative',
                      builder: (context, state) => const SlopeSolverScreen(),
                    ),
                    GoRoute(
                      path: 'infinity',
                      builder: (context, state) => const LimitsInfinityScreen(),
                    ),
                    GoRoute(
                      path: 'limits',
                      builder: (context, state) => const EvaluatingLimitsPicker(),
                      routes: [
                        GoRoute(
                          path: 'substitution',
                          builder: (context, state) =>
                              const SubstitutionLimitScreen(),
                        ),
                        GoRoute(
                          path: 'conjugate',
                          builder: (context, state) =>
                              const ConjugateLimitScreen(),
                        ),
                        GoRoute(
                          path: 'factoring',
                          builder: (context, state) =>
                              const FactoringLimitScreen(),
                        ),
                        GoRoute(
                          path: 'lcd',
                          builder: (context, state) => const LCDLimitScreen(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    // Branch 1 — Settings
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
),
```

- [ ] **Step 3: Update the CategoryPickerScreen navigation**

The existing `CategoryPickerScreen` uses `context.push('/...')` for sub-routes. These routes are now under `/topics/midterm/...`. Update the push calls in `lib/screens/category_picker_screen.dart` to use the new paths.

Run grep to find all push calls:
```bash
cd C:\projects\mathcalcu
rg "context\.push\(" lib/screens/category_picker_screen.dart
```

Update each path to prepend `/topics/midterm` (e.g., `/inequalities` → `/topics/midterm/inequalities`).

- [ ] **Step 4: Update FinalsPickerScreen navigation**

Same for `lib/topics/finals/finals_picker_screen.dart` — update push calls to use `/topics/finals/...` paths.

- [ ] **Step 5: Verify no analysis errors**

Run: `cd C:\projects\mathcalcu && flutter analyze`
Expected: No errors

- [ ] **Step 6: Run the app and verify**

Run: `cd C:\projects\mathcalcu && flutter run`
Verify:
- Home screen shows grid with 3 cards (Topics, Notes, Calculator)
- Topics card navigates to TopicsScreen with Midterm/Finals
- Midterm navigates to existing CategoryPickerScreen
- Finals navigates to existing FinalsPickerScreen
- Notes and Calculator show "Coming soon" snackbar
- Bottom nav has only Home + Settings
- Back buttons work correctly

- [ ] **Step 7: Commit**

```bash
cd C:\projects\mathcalcu
git add -A
git commit -m "feat: restructure router with Home as root, Topics as sub-route"
```

---

### Task 8: Final verification and cleanup

- [ ] **Step 1: Run full analysis**

Run: `cd C:\projects\mathcalcu && flutter analyze`
Expected: No errors

- [ ] **Step 2: Run tests**

Run: `cd C:\projects\mathcalcu && flutter test`
Expected: All tests pass

- [ ] **Step 3: Final commit if any cleanup needed**

```bash
cd C:\projects\mathcalcu
git add -A
git commit -m "chore: final cleanup for landing page feature"
```
