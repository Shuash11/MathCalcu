# Glow Polish and Keyboard Parser Fixes Plan

## Summary

Complete the neutral bottom-navigation visual system by applying the existing accent glow to solver actions and page-header icon treatments that still render flat. Repair the inequality input pipeline so expressions emitted by the on-screen math keyboard are normalized and parsed consistently, with regression tests covering Unicode inequality operators, fractions, trailing decimals, and adjacent linear factors.

## Tasks

1. Add regression tests for keyboard-compatible inequality expressions and verify they fail before implementation.
2. Centralize inequality normalization/numeric parsing in `InequalityCoreSolver`, pass canonical input through `InequalitySolverRouter`, and reject unsupported powers instead of silently coercing them.
3. Add a shared accent-glow helper using `ThemeProvider.accentColor` and apply it to missing solver/compute actions.
4. Apply the shared glow to page-header/back-button/icon containers while preserving current layout and interactions.
5. Run targeted tests, full tests, analyzer error gate, source/color scans, and an end-to-end readiness audit.

## Files

- `C:\projects\mathcalcu\test\inequality_keyboard_parser_test.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\solvers\inequalities_solver\inequality_core_solver.dart`
- `C:\projects\mathcalcu\lib\topics\calculus\midterm\solvers\inequalities_solver\inequality_solver_router.dart`
- Generated inequality solver files only where shared normalization cannot cover numeric extraction.
- `C:\projects\mathcalcu\lib\shared\widgets\accent_glow.dart`
- Solver-button files identified during exploration: point-slope, slope-intercept, parallel/perpendicular, slope, and calculator.
- Header-icon files identified during exploration: inequality, circle center/radius/center-radius, midpoint, two-point slope, and slope screens.

## Approach

- Preserve the keyboard's displayed glyphs. Normalize `≤`/`≥` at the solver boundary rather than changing what users see.
- Normalize once before dispatch so detection, solving, and step generation consume the same expression.
- Parse numeric constants with a shared helper supporting decimals, trailing decimal points, and simple fractions.
- Expand adjacent products of two linear factors into a quadratic expression; reject powers above 2 with a clear error.
- Use one shared glow helper with a restrained light-mode halo and slightly stronger dark-mode halo.
- Do not glow title text itself; glow the accompanying icon container to preserve readability and match existing card treatment.

## Risks

- Generated solvers duplicate parser logic; keep changes minimal and shared where possible.
- Continued inequalities use multiple operators and require existing routing behavior to remain intact.
- Decorative headers vary structurally, so glow changes must not change sizing or hit targets.

## Non-Goals

- No redesign of solver layouts or typography.
- No new solver families beyond quadratic inequalities.
- No support for arbitrary symbolic constants such as `π` in inequality solving this round.
- No changes to Python-generated solver sources.
