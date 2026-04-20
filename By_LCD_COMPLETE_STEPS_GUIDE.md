# By_LCD Complete Steps Guide

This note tells the next agent how the `By_LCD` feature should generate complete student-style solution steps.

## Main rule

If the topic is `By_LCD` in evaluating limits, the app should show the full algebraic solution, not just short headers.

That means every solution should guide the student through:

1. the original limit
2. finding the LCD
3. rewriting the numerator as one fraction
4. rewriting the whole complex fraction
5. simplifying
6. using conjugate steps if needed
7. substitution
8. the exact final answer
9. the decimal approximation when applicable

## What the next agent should fix

Primary file:

- `lib/Finals/Joashua/Evaluating_limits/By_LCD/library/src/steps.dart`

Supporting files:

- `lib/Finals/Joashua/Evaluating_limits/By_LCD/library/src/lcd_math_engine.dart`
- `lib/Finals/Joashua/Evaluating_limits/By_LCD/Widget/lcd_steps_view.dart`
- `lib/Finals/Joashua/Evaluating_limits/By_LCD/Widget/lcd_answer_card.dart`

## Current problem

Right now many steps are too shallow, for example:

- `Identify the complex fraction`
- `Combine numerator terms using the LCD`
- `Simplify and cancel common factors`
- `Substitute x = ... and simplify`

These are only guide headers. They do not fully show the student solution.

The next agent should make each step contain the actual algebra, not just the step title.

## Required step structure

Every generated step should contain:

1. a short teaching sentence
2. the actual math expression for that step

Example:

```text
Step 2: Find the LCD of the fractions in the numerator.
$$\text{LCD} = 3x$$
```

Not just:

```text
Find the LCD.
```

## Dynamic step rules

The steps must be generated dynamically based on the expression type.

### Case 1: Plain LCD-only problem

Show these steps:

1. Write the given limit.
2. Identify the fractions in the numerator.
3. Find the LCD.
4. Rewrite the numerator as a single fraction.
5. Rewrite the whole expression.
6. Simplify and cancel common factors if possible.
7. Substitute the approach value.
8. Show the exact answer.
9. Show the decimal approximation when useful.

### Case 2: LCD plus conjugate

Show all LCD steps first, then add:

1. Identify that a radical expression remains.
2. Write the conjugate.
3. Multiply by the conjugate over itself.
4. Apply difference of squares.
5. Simplify.
6. Substitute the approach value.
7. Show the exact answer.
8. Show the decimal approximation.

The app should not skip conjugate steps just because the final numeric answer is already known.

## Exact answer and approximation

This is required in both:

- step-by-step solution
- answer card

### Rational final answer

Example:

```text
Exact answer: -\frac{2}{15}
Approximation: \approx -0.1333
```

### Irrational final answer

Example:

```text
Exact answer: \text{expression with }\sqrt{3}
Approximation: \approx -0.0814
```

The exact answer must be the primary result. The approximation must be secondary.

## Recommended full step flow

### Example A: LCD-only

For:

```text
\lim_{x \to 5}\frac{\frac{1}{x}-\frac{1}{3}}{x-4}
```

The step sequence should look like this:

```text
Step 1: Write the given limit.
$$\lim_{x \to 5}\frac{\frac{1}{x}-\frac{1}{3}}{x-4}$$

Step 2: Find the LCD of the fractions in the numerator.
$$\text{LCD} = 3x$$

Step 3: Rewrite the numerator as a single fraction.
$$\frac{1}{x}-\frac{1}{3}=\frac{3-x}{3x}$$

Step 4: Rewrite the entire complex fraction.
$$\frac{\frac{3-x}{3x}}{x-4}=\frac{3-x}{3x(x-4)}$$

Step 5: Substitute x = 5.
$$\frac{3-5}{3(5)(5-4)}=-\frac{2}{15}$$

Step 6: State the final answers.
$$\text{Exact answer: }-\frac{2}{15}$$
$$\text{Approximation: }\approx -0.1333$$
```

### Example B: LCD plus conjugate

For a problem where LCD leaves a radical expression, the steps should look like this:

```text
Step 1: Write the given limit.
Step 2: Find the LCD of the numerator fractions.
Step 3: Combine the fractions into one numerator.
Step 4: Rewrite the whole complex fraction.
Step 5: Notice that a radical expression remains.
Step 6: Multiply by the conjugate.
Step 7: Apply difference of squares.
Step 8: Simplify the expression.
Step 9: Substitute the approach value.
Step 10: State the exact answer.
Step 11: State the approximation.
```

Each one should include actual algebra, not just the sentence.

## Where to tweak the code

## In `steps.dart`

The next agent should update:

- `solveByLCD()`
- `_buildSqrtRationalizationSolution()`
- `solveByConjugate()`

### In `solveByLCD()`

Change it so it builds richer steps, not just:

- header
- one combined expression
- final answer

It should explicitly show:

- LCD
- numerator combination
- full fraction rewrite
- simplification
- substitution
- exact answer
- approximation

### In `_buildSqrtRationalizationSolution()`

Make sure this path includes:

- why conjugate is needed
- what the conjugate is
- multiplication by the conjugate
- difference of squares
- simplified result
- exact answer
- approximation

### In `solveByConjugate()`

Do not leave it as a shallow summary. It should also act like a full student solution path.

## In `lcd_math_engine.dart`

Make sure the engine preserves enough structure so `steps.dart` knows:

- whether the problem is plain LCD
- whether conjugate is also needed
- whether the final result is rational or irrational

This is important because the steps should depend on the structure, not just on the final numeric value.

## In `lcd_steps_view.dart`

Make sure it can render:

- more steps
- exact-answer step
- approximation step
- multiple block equations in one step

It should not collapse or hide later steps.

## In `lcd_answer_card.dart`

Make sure it shows:

1. the exact answer as the main value
2. the approximation as a second value when applicable

It should not show only the approximation.

## Recommended data-model improvement

The current `LimitSolution` model is too limited.

The next agent should consider adding:

```dart
final String? exactAnswerLatex;
final String? approximateAnswerLatex;
final bool showApproximation;
```

Or a structured result model shared by both the steps and the answer card.

## Definition of done

This is fixed when:

1. the steps read like a student solution, not just headers
2. LCD-only problems show all needed algebra
3. LCD + conjugate problems show both method parts completely
4. the exact answer appears in the steps
5. the approximation appears in the steps when applicable
6. the exact answer appears in the answer card
7. the approximation appears in the answer card when applicable
