# Solution Steps Modal Overlay — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace inline step-by-step solutions with a bottom-sheet modal overlay across 5 screens (two-point slope + 4 limits screens).

**Architecture:** Create a single shared `SolutionStepsModal` widget that wraps any child widget in a `showModalBottomSheet` + `DraggableScrollableSheet`. Each screen swaps its `_showSteps` toggle from inline rendering to calling `showSolutionStepsModal()`. No data model changes — the modal accepts the existing step widgets as-is.

**Tech Stack:** Flutter, `showModalBottomSheet`, `DraggableScrollableSheet`, existing theme system (`TwoPointSlopeTheme`, `FinalsTheme`).

---

## File Structure

| File | Action | Purpose |
|------|--------|---------|
| `lib/shared/widgets/solution_steps_modal.dart` | **Create** | Shared modal overlay widget |
| `lib/topics/calculus/midterm/screens/two_point_slope_screen/twopointslopescreen.dart` | **Modify** | Replace inline steps with modal |
| `lib/topics/calculus/finals/screens/evaluating_limits_screen/by_substitution/substitution_limit_screen.dart` | **Modify** | Replace inline steps with modal |
| `lib/topics/calculus/finals/screens/evaluating_limits_screen/by_factoring/factoring_limit_screen.dart` | **Modify** | Replace inline steps with modal |
| `lib/topics/calculus/finals/screens/evaluating_limits_screen/by_conjugate/conjugate_limit_screen.dart` | **Modify** | Replace inline steps with modal |
| `lib/topics/calculus/finals/screens/evaluating_limits_screen/by_lcd/lcd_limit_screen.dart` | **Modify** | Replace inline steps with modal |

---

## Task 1: Create shared `SolutionStepsModal` widget

**Files:**
- Create: `lib/shared/widgets/solution_steps_modal.dart`

- [ ] **Step 1: Create the shared modal widget**

```dart
import 'package:flutter/material.dart';

/// Shows a modal bottom sheet containing [child] (typically a steps widget).
///
/// The modal features:
/// - Rounded top corners (28px radius)
/// - Semi-transparent backdrop (tap to dismiss)
/// - Drag handle indicator at top
/// - Header with "Solution Steps" title and close (X) button
/// - Scrollable content area
/// - Swipe-down dismiss via DraggableScrollableSheet
Future<void> showSolutionStepsModal({
  required BuildContext context,
  required Widget child,
  String title = 'Solution Steps',
  Color? accentColor,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SolutionStepsModal(
      title: title,
      accentColor: accentColor,
      child: child,
    ),
  );
}

class _SolutionStepsModal extends StatelessWidget {
  final String title;
  final Color? accentColor;
  final Widget child;

  const _SolutionStepsModal({
    required this.title,
    this.accentColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).brightness == Brightness.dark;
    final bgColor = theme ? const Color(0xFF1E1E2E) : Colors.white;
    final handleColor = theme ? Colors.white24 : Colors.black26;
    final textColor = theme ? Colors.white : const Color(0xFF1E1E2E);
    final borderColor = (accentColor ?? Colors.amber).withValues(alpha: 0.2);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) {
          return Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  children: [
                    if (accentColor != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: accentColor!.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.list_alt_rounded, color: accentColor, size: 16),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: (accentColor ?? Colors.amber).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: accentColor ?? Colors.amber,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Divider(height: 1, color: handleColor),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: child,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Verify the file compiles**

Run from project root:
```
flutter analyze lib/shared/widgets/solution_steps_modal.dart
```
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/shared/widgets/solution_steps_modal.dart
git commit -m "feat: add shared SolutionStepsModal bottom sheet widget"
```

---

## Task 2: Update Two-Point Slope Screen

**Files:**
- Modify: `lib/topics/calculus/midterm/screens/two_point_slope_screen/twopointslopescreen.dart:59` (toggle method)
- Modify: `lib/topics/calculus/midterm/screens/two_point_slope_screen/twopointslopescreen.dart:438-448` (inline steps block)

- [ ] **Step 1: Add import for the modal**

At the top of the file, add after line 4 (`import 'two_point_slope_steps.dart';`):

```dart
import 'package:calculus_system/shared/widgets/solution_steps_modal.dart';
```

- [ ] **Step 2: Replace the `_toggleSteps` method (line 59)**

Replace:
```dart
void _toggleSteps() => setState(() => _showSteps = !_showSteps);
```

With:
```dart
void _showStepsModal() {
  showSolutionStepsModal(
    context: context,
    title: 'Solution Steps',
    accentColor: TwoPointSlopeTheme.primary,
    child: TwoPointSlopeSteps(result: _controller.result!),
  );
}
```

- [ ] **Step 3: Update the "Show steps" chip tap handler (line 355)**

In `_buildResultCard()`, find the `GestureDetector` that calls `_toggleSteps` (line 355):
```dart
GestureDetector(
  onTap: _toggleSteps,
  child: _buildShowStepsChip(),
),
```

Replace `onTap: _toggleSteps` with `onTap: _showStepsModal`.

- [ ] **Step 4: Remove the inline steps conditional (lines 438-448)**

Delete the entire `if (_showSteps)` block inside `_buildResultCard()`:
```dart
if (_showSteps) ...[
  const SizedBox(height: 20),
  Container(
    width: double.infinity,
    height: 1,
    margin: const EdgeInsets.only(bottom: 20),
    color: TwoPointSlopeTheme.primary.withValues(alpha: 0.2),
  ),
  TwoPointSlopeSteps(result: _controller.result!),
  const SizedBox(height: 20),
],
```

- [ ] **Step 5: Remove unused `_showSteps` state variable**

Remove `bool _showSteps = false;` (line 28) and the `_showSteps = false;` line inside the solve button handler (line 313).

- [ ] **Step 6: Update `_buildShowStepsChip` (line 454)**

The chip currently shows "Hide steps" / "Show steps" based on `_showSteps`. Since we no longer toggle inline, simplify it to always show "Show steps":

Replace the `_buildShowStepsChip()` method body to always show the non-expanded state (remove the `_showSteps` conditional logic).

- [ ] **Step 7: Verify**

Run: `flutter analyze lib/topics/calculus/midterm/screens/two_point_slope_screen/twopointslopescreen.dart`
Expected: No errors.

- [ ] **Step 8: Commit**

```bash
git add lib/topics/calculus/midterm/screens/two_point_slope_screen/twopointslopescreen.dart
git commit -m "feat(two-point-slope): replace inline steps with modal overlay"
```

---

## Task 3: Update Substitution Limits Screen

**Files:**
- Modify: `lib/topics/calculus/finals/screens/evaluating_limits_screen/by_substitution/substitution_limit_screen.dart`

- [ ] **Step 1: Add import**

Add after line 3 (`import 'substitution_steps_view.dart';`):
```dart
import 'package:calculus_system/shared/widgets/solution_steps_modal.dart';
```

- [ ] **Step 2: Replace the steps toggle in `SubstitutionAnswerCard` onTap (line 185)**

Find:
```dart
onTap: () => setState(() => _showSteps = !_showSteps),
```

Replace with:
```dart
onTap: () => showSolutionStepsModal(
  context: context,
  title: 'Solution Steps',
  accentColor: FinalsTheme.primary,
  child: SubstitutionStepsView(steps: _steps),
),
```

- [ ] **Step 3: Remove the inline `AnimatedSize` steps block (lines 190-218)**

Delete the entire `AnimatedSize` widget that conditionally shows `SubstitutionStepsView`:
```dart
AnimatedSize(
  duration: const Duration(milliseconds: 400),
  curve: Curves.fastOutSlowIn,
  child: _showSteps
      ? Padding(
          ...
          child: SubstitutionStepsView(steps: _steps),
        )
      : const SizedBox.shrink(),
),
```

- [ ] **Step 4: Remove unused `_showSteps` state**

Remove `bool _showSteps = false;` (line 28) and `_showSteps = false;` in the solve method (line 95).

- [ ] **Step 5: Verify**

Run: `flutter analyze lib/topics/calculus/finals/screens/evaluating_limits_screen/by_substitution/substitution_limit_screen.dart`
Expected: No errors.

- [ ] **Step 6: Commit**

```bash
git add lib/topics/calculus/finals/screens/evaluating_limits_screen/by_substitution/substitution_limit_screen.dart
git commit -m "feat(substitution-limits): replace inline steps with modal overlay"
```

---

## Task 4: Update Factoring Limits Screen

**Files:**
- Modify: `lib/topics/calculus/finals/screens/evaluating_limits_screen/by_factoring/factoring_limit_screen.dart`

- [ ] **Step 1: Add import**

Add after line 3 (`import 'factoring_steps_view.dart';`):
```dart
import 'package:calculus_system/shared/widgets/solution_steps_modal.dart';
```

- [ ] **Step 2: Replace the steps toggle in `FactoringAnswerCard` onTap (line 217)**

Find:
```dart
onTap: () => setState(() => _showSteps = !_showSteps),
```

Replace with:
```dart
onTap: () => showSolutionStepsModal(
  context: context,
  title: 'Solution Steps',
  accentColor: FinalsTheme.primary,
  child: FactoringStepsView(steps: _steps),
),
```

- [ ] **Step 3: Remove the inline `AnimatedSize` steps block (lines 220-254)**

Delete the entire `AnimatedSize` widget that conditionally shows `FactoringStepsView`.

- [ ] **Step 4: Remove unused `_showSteps` state**

Remove `bool _showSteps = false;` (line 55) and `_showSteps = false;` in the solve method (line 122).

- [ ] **Step 5: Verify**

Run: `flutter analyze lib/topics/calculus/finals/screens/evaluating_limits_screen/by_factoring/factoring_limit_screen.dart`
Expected: No errors.

- [ ] **Step 6: Commit**

```bash
git add lib/topics/calculus/finals/screens/evaluating_limits_screen/by_factoring/factoring_limit_screen.dart
git commit -m "feat(factoring-limits): replace inline steps with modal overlay"
```

---

## Task 5: Update Conjugate Limits Screen

**Files:**
- Modify: `lib/topics/calculus/finals/screens/evaluating_limits_screen/by_conjugate/conjugate_limit_screen.dart`

- [ ] **Step 1: Add import**

Add after line 5 (`import 'conjugate_steps_view.dart';`):
```dart
import 'package:calculus_system/shared/widgets/solution_steps_modal.dart';
```

- [ ] **Step 2: Replace the steps toggle in `ConjugateAnswerCard` onTap (line 230)**

Find:
```dart
onTap: () => setState(() => _showSteps = !_showSteps),
```

Replace with:
```dart
onTap: () => showSolutionStepsModal(
  context: context,
  title: 'Solution Steps',
  accentColor: FinalsTheme.secondary,
  child: ConjugateStepsView(steps: _steps),
),
```

- [ ] **Step 3: Remove the inline `AnimatedSize` steps block (lines 232-266)**

Delete the entire `AnimatedSize` widget that conditionally shows `ConjugateStepsView`.

- [ ] **Step 4: Remove unused `_showSteps` state**

Remove `bool _showSteps = false;` (line 56) and `_showSteps = false;` in the solve method (line 127).

- [ ] **Step 5: Verify**

Run: `flutter analyze lib/topics/calculus/finals/screens/evaluating_limits_screen/by_conjugate/conjugate_limit_screen.dart`
Expected: No errors.

- [ ] **Step 6: Commit**

```bash
git add lib/topics/calculus/finals/screens/evaluating_limits_screen/by_conjugate/conjugate_limit_screen.dart
git commit -m "feat(conjugate-limits): replace inline steps with modal overlay"
```

---

## Task 6: Update LCD Limits Screen

**Files:**
- Modify: `lib/topics/calculus/finals/screens/evaluating_limits_screen/by_lcd/lcd_limit_screen.dart`

- [ ] **Step 1: Add import**

Add after line 3 (`import 'lcd_steps_view.dart';`):
```dart
import 'package:calculus_system/shared/widgets/solution_steps_modal.dart';
```

- [ ] **Step 2: Replace the steps toggle in `LCDAnswerCard` onTap (line 209)**

Find:
```dart
onTap: () => setState(() => _showSteps = !_showSteps),
```

Replace with:
```dart
onTap: () => showSolutionStepsModal(
  context: context,
  title: 'Solution Steps',
  accentColor: FinalsTheme.danger,
  child: LCDStepsView(steps: _solution!.steps),
),
```

- [ ] **Step 3: Remove the inline `AnimatedSize` steps block (lines 212-241)**

Delete the entire `AnimatedSize` widget that conditionally shows `LCDStepsView`.

- [ ] **Step 4: Remove unused `_showSteps` state**

Remove `bool _showSteps = false;` (line 27) and `_showSteps = false;` in the solve method (line 93).

- [ ] **Step 5: Verify**

Run: `flutter analyze lib/topics/calculus/finals/screens/evaluating_limits_screen/by_lcd/lcd_limit_screen.dart`
Expected: No errors.

- [ ] **Step 6: Commit**

```bash
git add lib/topics/calculus/finals/screens/evaluating_limits_screen/by_lcd/lcd_limit_screen.dart
git commit -m "feat(lcd-limits): replace inline steps with modal overlay"
```

---

## Task 7: Full Verification

- [ ] **Step 1: Run full project analysis**

Run: `flutter analyze`
Expected: No new errors introduced.

- [ ] **Step 2: Manual smoke test checklist**

Verify each screen:
1. Two-point slope — tap "Show steps" → modal slides up with steps, scrollable, X closes, backdrop tap closes, swipe down closes
2. Substitution limits — tap answer card → same modal behavior
3. Factoring limits — tap answer card → same modal behavior
4. Conjugate limits — tap answer card → same modal behavior
5. LCD limits — tap answer card → same modal behavior

- [ ] **Step 3: Final commit (if any fixes needed)**

```bash
git add -A
git commit -m "fix: address review findings for steps modal overlay"
```

---

## Risks

1. **Keyboard interference on limits screens**: The `MathKeyboard` widget sits at the bottom of the screen. `showModalBottomSheet` may conflict with it. Mitigation: The modal uses `isScrollControlled: true` which handles this correctly. If issues arise, add `resizeToAvoidBottomInset: false` to the modal's scaffold.

2. **Step widgets using `NeverScrollableScrollPhysics`**: The limits steps views (`SubstitutionStepsView`, etc.) use `ListView.builder` with `NeverScrollableScrollPhysics`. This is correct — they're embedded inside the modal's `SingleChildScrollView`. No conflict expected.

3. **Two-point slope steps animations**: `TwoPointSlopeSteps` has its own fade/slide animations that trigger on `initState`. These will replay each time the modal opens, which is the desired UX.

## Non-Goals

- Redesigning the step widgets themselves (keeping existing step card designs)
- Changing the `StepModel` or solver data structures
- Modifying the existing `StepsDrawer` shared widget (it serves other modules)
- Adding new dependencies (using only Flutter built-ins)
- Changing how steps are generated/calculated
