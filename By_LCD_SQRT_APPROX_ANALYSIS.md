# By_LCD Square Root Approximation Analysis

This note explains the new behavior seen in the debug logs when square roots are involved:

1. why the result sometimes stays as a decimal with no approximation label
2. why another case simplifies to a clean fraction like `-1/18`
3. what rule the next agent should implement for exact-vs-approximate output

## Debug patterns observed

### Case A: square root in the algebra

Observed output:

```text
LCD_DEBUG step 2:
$$\frac{3 - \sqrt{3}}{(\sqrt{3} \cdot 3)(x - 5)}$$

LCD_DEBUG step 3:
$$-0.0814$$
```

### Case B: no square root, rational result

Observed output:

```text
LCD_DEBUG step 2:
$$\frac{3 - x}{(x \cdot 3)(x - 5)}$$

LCD_DEBUG step 3:
$$-\frac{1}{18}$$
```

These two cases behave differently because the solver can recover a rational result in Case B, but not in Case A.

## What is happening

## 1. The square-root case is not rational

For a result involving `\sqrt{3}`, the final exact value is generally irrational.

That means:

- it cannot be simplified into a fraction like `-2/15`
- it cannot be represented exactly as a terminating or repeating rational decimal
- any decimal shown for it is automatically an approximation

So if the solver shows:

```text
-0.0814
```

that should be labeled as approximate, because it is not exact.

## 2. The current formatter does not distinguish rational from irrational

File:

- `lib/Finals/Joashua/Evaluating_limits/By_LCD/library/src/steps.dart`

Current path:

```dart
final ans = _calculateNumericalLimit(ast, varName, val);
final ansTex = _formatResult(ans);
```

Problem:

- `_calculateNumericalLimit()` returns only a `double`
- `_formatResult(double)` tries to decide whether that value can be displayed as a fraction or decimal
- it has no metadata saying whether the original exact result contained `sqrt(...)`

So the formatter cannot know whether the decimal is:

1. an exact terminating decimal, or
2. just a numeric approximation of an irrational value

That is why there is no `approx.` label for the square-root result right now.

## 3. The rational case simplifies because it can be reconstructed

In the non-square-root example:

```text
\frac{\frac{1}{x} - \frac{1}{3}}{x - 5}, \quad x \to 2
```

the exact result is rational.

After substitution:

```text
\frac{\frac{1}{2} - \frac{1}{3}}{2 - 5}
= \frac{\frac{1}{6}}{-3}
= -\frac{1}{18}
```

This is a rational value, so `_formatResult()` is able to recover a fraction and simplify it.

That is why this case becomes:

```text
-\frac{1}{18}
```

instead of a decimal.

## Why the sqrt case should not behave the same way

If the result contains `\sqrt{3}`, then it is not in the same category as `-1/18`.

The next agent should treat them differently:

### Rational result

- simplify exactly
- if denominator is `1`, show whole number
- if terminating decimal, show exact decimal
- otherwise show simplified fraction

### Irrational result

- keep exact radical form if the exact symbolic form is known
- otherwise show a decimal approximation
- if decimal approximation is shown, label it clearly as approximate

## Root cause for “no approximate showing”

## 4. The solver loses the exact symbolic form before formatting

This is the key issue.

By the time the final answer is formatted, the solver has already collapsed everything into a `double`.

That means the formatting layer no longer knows:

- whether the original result involved `sqrt`
- whether it was rational or irrational
- whether the decimal is exact or approximate

So the current code cannot apply the correct label.

## Why the answer “simplified”

## 5. The answer simplified in the rational case because simplification is allowed there

For:

```text
\frac{\frac{1}{x} - \frac{1}{3}}{x - 5}, \quad x \to 2
```

the result is rational, so simplification to:

```text
-\frac{1}{18}
```

is correct and desirable.

That is not a bug.

The real bug is inconsistency:

- rational results may simplify correctly
- irrational results are shown as plain decimals with no approximation indicator

## What the next agent should implement

## Fix 1: Track result type explicitly

The next agent should add a result classification model such as:

```dart
class FormattedResult {
  final String primaryLatex;
  final String? approximateDecimal;
  final bool isWholeNumber;
  final bool isFraction;
  final bool isExactDecimal;
  final bool isIrrational;
}
```

This lets the UI and steps know whether the decimal is exact or approximate.

## Fix 2: Distinguish rational and irrational outputs

The solver should decide:

1. is the final exact form rational?
2. does the final exact form contain `sqrt(...)` or another irrational expression?

If irrational:

- do not treat the decimal as exact
- show either the exact radical form or an `approx.` decimal

## Fix 3: Prefer exact radical form when available

For a case like:

```text
\frac{3 - \sqrt{3}}{(\sqrt{3} \cdot 3)(2 - 5)}
```

the next agent should keep the symbolic result if it can.

For example, the final step could be:

```text
$$
\frac{3 - \sqrt{3}}{(\sqrt{3} \cdot 3)(2 - 5)}
= \text{exact form here}
$$
```

Then optionally:

```text
$$\approx -0.0814$$
```

That would be much more mathematically honest than showing only `-0.0814`.

## Fix 4: If exact radical form is not available, label the decimal

If the agent cannot preserve the symbolic radical form, then the output should still say:

```text
\approx -0.0814
```

not:

```text
-0.0814
```

because the latter incorrectly looks exact.

## Fix 5: Update the step wording

Current step:

```text
Substitute x = 2 and simplify.
$$-0.0814$$
```

Better:

```text
Substitute x = 2 and evaluate the expression.
$$\approx -0.0814$$
```

Or, if exact form is preserved:

```text
Substitute x = 2 and simplify.
$$\text{exact radical form}$$
$$\approx -0.0814$$
```

## Suggested decision rule

The next agent should implement this:

### If final result is rational

- simplify fully
- if denominator is `1`, show whole number
- if terminating decimal, show exact decimal
- otherwise show simplified fraction

### If final result is irrational

- show exact radical/symbolic form when possible
- also show decimal approximation optionally
- if only decimal is available, prefix it with `\approx`

## Bottom line

Why no approximation is showing for the square-root case:

1. the solver reduces the answer to a raw `double`
2. the formatting code no longer knows the result came from a square-root expression
3. the decimal is printed as if it were exact

Why the non-square-root case simplifies:

1. that answer is rational
2. the formatter can reconstruct and reduce the fraction
3. `-\frac{1}{18}` is the correct exact simplified result

So the next agent should not remove simplification. The real fix is to add result-type awareness and show approximation markers for irrational outputs.
