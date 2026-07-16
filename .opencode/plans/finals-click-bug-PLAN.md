# Plan: Finals Section Click Bug Fix

## Feature Summary
All finals topic cards are unclickable — no visual response when tapped, should navigate to solver. Root cause: 4 evaluating-limits subtopic cards use `Navigator.pushNamed()` instead of GoRouter's `context.push()`, plus the default card has navigation commented out.

## Subtask Breakdown

### Task 1: Fix 4 evaluating-limits subtopic cards
Replace `Navigator.of(context).pushNamed(...)` with `context.push(...)` + add GoRouter import in:
- `lib/topics/calculus/finals/cards/evaluating_limits/conjugate_card.dart`
- `lib/topics/calculus/finals/cards/evaluating_limits/substitution_card.dart`
- `lib/topics/calculus/finals/cards/evaluating_limits/factoring_card.dart`
- `lib/topics/calculus/finals/cards/evaluating_limits/lcd_card.dart`

### Task 2: Fix default finals card
Uncomment `context.push(widget.module.route)` in `_FinalsDefaultCard` in `lib/topics/calculus/finals/finals_picker_screen.dart`

### Task 3: Verify main topic cards
Confirm the 4 main finals cards (limits, infinity, derivatives, slope-derivative) use GoRouter `context.go()` — they do, so no fix needed.

## Files to Touch
- `lib/topics/calculus/finals/cards/evaluating_limits/conjugate_card.dart`
- `lib/topics/calculus/finals/cards/evaluating_limits/substitution_card.dart`
- `lib/topics/calculus/finals/cards/evaluating_limits/factoring_card.dart`
- `lib/topics/calculus/finals/cards/evaluating_limits/lcd_card.dart`
- `lib/topics/calculus/finals/finals_picker_screen.dart`

## Approach
- Change `Navigator.of(context).pushNamed('...')` → `context.push('...')`
- Add `import 'package:go_router/go_router.dart';` to each file
- Uncomment default card navigation
- Run `flutter analyze` to verify zero new errors
- Run `flutter test` to verify no regressions

## Risks / Open Questions
- Main topic cards (limits, infinity, derivatives, slope-derivative) use `context.go()` inside `StatefulShellRoute.indexedStack` — may also fail if Go route resolution doesn't work in nested shell branches. If user confirms these are also broken, change to `context.push()`.

## Non-Goals
- No new features, no theme changes, no new screens
- No release (bugfix only, will be included in next release)

## Acceptance Criteria
- Tapping conjugate/substitution/factoring/LCD cards navigates to correct solver screen
- Default card tap also navigates (for future modules)
- `flutter analyze` zero new errors
- `flutter test` all pass
