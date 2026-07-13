# Solution Steps Modal Safe Area Fix

## Summary
All `showSolutionStepsModal` modals have their content overlapped by the phone's system navigation bar. The `DraggableScrollableSheet` doesn't respect the safe area inset.

## Root Cause
`solution_steps_modal.dart:125` — hardcoded `padding: EdgeInsets.fromLTRB(20, 16, 20, 32)` ignores `MediaQuery.of(context).viewPadding.bottom` (the system nav bar height on Android).

## Fix
Add bottom safe area padding to the scrollable content area so it stops above the system navigation bar.

### Files touched
- `lib/shared/widgets/solution_steps_modal.dart` — add `viewPadding.bottom` to bottom padding

### Approach
- Read `MediaQuery.of(context).viewPadding.bottom` inside the builder
- Add it to the existing 32px bottom padding: `EdgeInsets.fromLTRB(20, 16, 20, 32 + bottomInset)`
- This ensures the scrollable content never extends behind the nav bar

## Acceptance Criteria
- Modal content stops above the system navigation bar on Android
- No visual regression on iOS (iOS has a home indicator, not a nav bar — padding is typically 0 or minimal)
- `flutter analyze` passes with 0 errors
- `flutter test` passes

## Non-goals
- No changes to the modal's visual design
- No changes to the DraggableScrollableSheet sizing logic
- No changes to individual step screens
