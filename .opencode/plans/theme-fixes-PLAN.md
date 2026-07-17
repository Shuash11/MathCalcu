# Theme Fixes & Modern Math Placeholder Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix hardcoded theme colors in parallel_perpendicular_screen.dart, investigate Calc tab routing, and add a Modern Math placeholder screen.

**Architecture:** Replace all `FinalsTheme.primary` and hardcoded `Color(0xFF334155)` references with dynamic `ThemeProvider.accentColor` lookups via `context.watch<ThemeProvider>()`. Add `AccentGlow.halo(context)` to the Solve button. Investigate Calc tab routing issue. Add new "Modern Math" Coming Soon screen.

**Tech Stack:** Flutter, Provider (state management), GoRouter (routing)

---

## Files Touched

| File | Action | Purpose |
|------|--------|---------|
| `lib/topics/calculus/midterm/screens/yintercept_screen/parallel_perpendicular_screen.dart` | Modify | Fix hardcoded theme colors |
| `lib/widgets/app_shell.dart` | Inspect | Verify Calc tab routing |
| `lib/app_router.dart` | Modify | Add Modern Math route |
| `lib/topics/topics_screen.dart` | Modify | Add Modern Math card |
| `lib/screens/modern_math_coming_soon.dart` | Create | New placeholder screen |

---

## Task 1: Fix parallel_perpendicular_screen.dart theme colors

**Files:**
- Modify: `C:\projects\mathcalcu\lib\topics\calculus\midterm\screens\yintercept_screen\parallel_perpendicular_screen.dart`

- [ ] **Step 1: Remove the hardcoded `_accent` const (line 17)**

Delete line 17:
```dart
const _accent = FinalsTheme.primary;
```

This constant is used throughout the file in `_StepBlocks` (lines 712-717, 821-823, 868-875). After removal, all references to `_accent` must be replaced with dynamic lookups.

- [ ] **Step 2: Fix `emerald` color in build() method (line 108)**

Replace:
```dart
final emerald = const Color(0xFF334155);
```
With:
```dart
final theme = context.watch<ThemeProvider>();
final emerald = theme.accentColor;
```

Note: `theme` is already read on line 110 for `theme.surface`. Move the `final theme = context.watch<ThemeProvider>();` to before line 108 so it can be used for both `emerald` and line 110.

- [ ] **Step 3: Fix Solve button color (line 183)**

Replace:
```dart
color: const Color(0xFF334155),
```
With:
```dart
color: context.watch<ThemeProvider>().accentColor,
```

- [ ] **Step 4: Add AccentGlow.halo to Solve button boxShadow (around line 178-185)**

The Solve button currently has no boxShadow. Add it to the `BoxDecoration`:
```dart
boxShadow: [AccentGlow.halo(context)],
```

Add the import at the top of the file:
```dart
import 'package:calculus_system/shared/widgets/accent_glow.dart';
```

- [ ] **Step 5: Fix `_MiniStepColumn` step number circle (line 662)**

Replace:
```dart
color: FinalsTheme.primary,
```
With:
```dart
color: context.watch<ThemeProvider>().accentColor,
```

This is inside `_MiniStepColumn.build()` which already has a `BuildContext context` parameter.

- [ ] **Step 6: Fix `_borderColors` map in `_StepBlocks` (lines 712-717)**

The static map uses `_accent` which no longer exists. Replace the static const map with a method that reads from context:

Replace:
```dart
static const _borderColors = {
  PPBlockType.formula: _accent,
  PPBlockType.substitution: Color(0xFF64748B),
  PPBlockType.working: _accent,
  PPBlockType.result: _accent,
};
```

With a method:
```dart
static Map<PPBlockType, Color> _borderColors(BuildContext context) {
  final accent = context.watch<ThemeProvider>().accentColor;
  return {
    PPBlockType.formula: accent,
    PPBlockType.substitution: const Color(0xFF64748B),
    PPBlockType.working: accent,
    PPBlockType.result: accent,
  };
}
```

Then update all references to `_borderColors[block.type]!` to `_borderColors(context)[block.type]!`.

- [ ] **Step 7: Fix `_renderResult` method (lines 816-828)**

Replace `_accent` references with context-based lookups:
```dart
Widget _renderResult(BuildContext context, String? latex, String fallback) {
  final accent = context.watch<ThemeProvider>().accentColor;
  return Container(
    width: double.infinity,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      color: accent.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: accent.withValues(alpha: 0.5), width: 1.2),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: Center(child: _renderMath(latex, fallback, fontSize: 14)),
  );
}
```

- [ ] **Step 8: Fix `_mathLine` method (lines 861-880)**

Replace `_accent` references:
```dart
Widget _mathLine(String tex, double fontSize, {required Color accent}) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    physics: const BouncingScrollPhysics(),
    child: RepaintBoundary(
      child: Math.tex(
        tex,
        textStyle: TextStyle(fontSize: fontSize, color: accent),
        onErrorFallback: (err) => Text(
          tex,
          style: TextStyle(
            fontSize: fontSize,
            color: accent,
            fontFamily: 'monospace',
          ),
        ),
      ),
    ),
  );
}
```

Update `_renderMath` to pass the accent color through to `_mathLine`.

- [ ] **Step 9: Run `flutter analyze` to verify no errors**

Run: `flutter analyze`
Expected: No errors related to undefined `_accent` or `FinalsTheme.primary` usage in this file.

- [ ] **Step 10: Visual verification**

Run the app, navigate to Parallel & Perpendicular screen, verify:
- Colors change when toggling light/dark mode
- Solve button has glow effect
- Step number circles use accent color
- Math rendering uses accent color

---

## Task 2: Investigate Calc tab routing

**Files:**
- Inspect: `C:\projects\mathcalcu\lib\widgets\app_shell.dart`
- Inspect: `C:\projects\mathcalcu\lib\app_router.dart`
- Inspect: `C:\projects\mathcalcu\lib\calculator\calculator_screen.dart`

- [ ] **Step 1: Verify branch index mapping**

In `app_shell.dart`, the Calc tab is at index 3 (0-based: Home=0, Topics=1, Notes=2, Calc=3, Settings=4).

In `app_router.dart`, Branch 3 (index 3) has path `/calculator` → `CalculatorScreen()`.

The mapping appears correct. Run the app and confirm which screen actually appears when tapping Calc.

- [ ] **Step 2: Check for route conflicts**

Search for any other `/calculator` route definitions or redirects that might intercept the navigation:
```bash
grep -r "/calculator" lib/
```

- [ ] **Step 3: Check CalculatorScreen implementation**

Verify `CalculatorScreen` at `lib/calculator/calculator_screen.dart` is the correct calculator UI (not a placeholder or different screen).

- [ ] **Step 4: Document findings and fix if needed**

If a bug is found, document it and apply the fix. If the routing is correct, note that in the plan as "investigated, no issue found."

---

## Task 3: Add Modern Math placeholder

**Files:**
- Create: `C:\projects\mathcalcu\lib\screens\modern_math_coming_soon.dart`
- Modify: `C:\projects\mathcalcu\lib\app_router.dart`
- Modify: `C:\projects\mathcalcu\lib\topics\topics_screen.dart`

- [ ] **Step 1: Create the Coming Soon screen**

Create `C:\projects\mathcalcu\lib\screens\modern_math_coming_soon.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';

class ModernMathComingSoonScreen extends StatelessWidget {
  const ModernMathComingSoonScreen({super.key});

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
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: ResponsiveText(
          'Modern Math',
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
            Icon(
              Icons.construction_rounded,
              size: 64,
              color: theme.accentColor.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            ResponsiveText(
              'Coming Soon',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ResponsiveText(
              'Modern Math topics are under development.',
              style: TextStyle(
                fontSize: 14,
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

- [ ] **Step 2: Add route in app_router.dart**

Add import at top of `app_router.dart`:
```dart
import 'package:calculus_system/screens/modern_math_coming_soon.dart';
```

Add route inside the `routes` list (after the existing routes, before the closing bracket):
```dart
GoRoute(
  path: '/modern-math',
  name: 'modern-math',
  builder: (context, state) => const ModernMathComingSoonScreen(),
),
```

- [ ] **Step 3: Add Modern Math card in topics_screen.dart**

Add a second `HomeCard` in the GridView children list:
```dart
HomeCard(
  icon: Icons.science_rounded,
  label: 'Modern Math',
  accent: const Color(0xFF6366F1),
  onTap: () => context.push('/modern-math'),
),
```

Also increase `childAspectRatio` if needed to accommodate two cards, or adjust the grid layout. Currently it's `1.0` which works for a single card but may need adjustment for two.

- [ ] **Step 4: Run `flutter analyze` to verify**

Run: `flutter analyze`
Expected: No errors.

- [ ] **Step 5: Visual verification**

Run the app, navigate to Topics, verify:
- "Modern Math" card appears alongside "Calculus"
- Tapping it navigates to the Coming Soon screen
- Back button returns to Topics

---

## Risks

1. **Static map conversion (Task 1, Step 6):** Converting `_borderColors` from static const to a method changes it from a compile-time constant to a runtime lookup. This is safe since the colors are theme-dependent, but verify no performance regression in the steps rendering.

2. **Calc tab routing (Task 2):** If the issue is a GoRouter state management bug (e.g., `StatefulNavigationShell` not preserving state correctly), the fix may be more involved than a simple route change. The investigation step should clarify this.

3. **Grid layout (Task 3):** Adding a second card to the GridView may require adjusting `childAspectRatio` or the grid structure. The current `childAspectRatio: 1.0` assumes square cards.

## Non-Goals

- Refactoring the entire theme system
- Changing `FinalsTheme` itself (only removing its usage in this file)
- Adding real Modern Math content (placeholder only)
- Modifying other screens' theme handling
