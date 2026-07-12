# Distance Formula Corrupted UTF Fix

## Summary
Fix corrupted UTF characters in the distance formula display. The solver and screen hint use `??` instead of `−` (minus sign) and `?` instead of `²` (superscript 2).

## Files to Fix
1. `lib/topics/calculus/midterm/solvers/distance_solver/distancesolver.dart` — lines 106-107
2. `lib/topics/calculus/midterm/screens/distance_screen/distancescreen.dart` — line 326

## Subtask Breakdown
1. Fix corrupted UTF in `distancesolver.dart` — replace `??` with `−` and `?` with `²`
2. Fix corrupted UTF in `distancescreen.dart` — replace `??` with `−` and `?` with `²`

## Approach
- Replace `??` with `−` (Unicode U+2212, minus sign)
- Replace `?` with `²` (Unicode U+00B2, superscript 2)

## Files NOT affected (verified clean)
- `distance_graph.dart` — already uses correct Unicode characters
- `distancesteps.dart` — uses proper LaTeX rendering
- `distancetheme.dart` — no formulas
- `distancecard.dart` — no formulas

## Non-goals
- Do not change the formula logic, only the display characters
- Do not touch other screens

## Verification
- `flutter analyze` on changed files
- Visual check that formulas render correctly
