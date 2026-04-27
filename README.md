# MathCalcu — AI-Powered Math System

A Flutter math solver for calculus and analytic geometry topics, built with offline-first AI-powered step generation.

---

## Features

- **Derivatives** — Symbolic differentiation with step-by-step solutions
- **Slope Using Derivatives** — Find slope at a point for explicit, implicit, and parametric equations
- **Evaluating Limits** — By substitution, factoring, LCD, and conjugate
- **Limits at Infinity** — Rational, radical, and trigonometric forms
- **Inequalities** — Linear, quadratic, rational, radical, absolute value
- **Circles** — Center, radius, standard/general form
- **Distance & Midpoint** — With graphing support
- **Slope & Intercept** — Point-slope, two-point, parallel/perpendicular lines

---

## Architecture

```
lib/
├── Finals/                      # Calculus modules (Derivatives, Limits, Slope)
│   └── Joashua/
│       ├── Derivatives/
│       │   ├── solvers/         # Symbolic engine + step generator
│       │   ├── UI/              # Screen
│       │   └── Widgets/         # StepTile, AnswerCard, InputField
│       ├── Slope_Using_derivatives/
│       │   ├── Solver/          # Math engine, parser, step narrator
│       │   ├── UI/
│       │   └── Widget/
│       └── Evaluating_limits/
│           ├── By_Substitution/
│           ├── By_Factoring/
│           ├── By_LCD/
│           └── By_conjugate/
└── modules/                     # Analytic geometry modules
    ├── slope/
    ├── inequalities/
    ├── circles/
    ├── Distance/
    ├── midpoint/
    └── y-intercept/
```

---

## Derivatives Solver

### Input Format

| Expression | Example |
|---|---|
| Polynomial | `x^3 - 2x + 5` |
| Trigonometric | `sin(x)*cos(x)` |
| Exponential | `e^(2x)` or `exp(2*x)` |
| Logarithmic | `ln(x^2 + 1)` |
| Composite | `sin(x^2) + ln(cos(x))` |
| Product | `x^2 * sin(x)` |
| Quotient | `(x+1)/(x-1)` |

### Rules Supported

Power, Sum/Difference, Product, Quotient, Chain, Exponential (any base), Natural Log, Logarithm (any base), all 6 trig functions, all 6 inverse trig functions, all 6 hyperbolic functions, Square Root, Absolute Value.

### Step Structure

Each solution produces steps in this order:

1. **Problem Statement** — displays `f(x) = ...`
2. **Identify the Rule(s)** — names the rule with its formula in LaTeX
3. **Apply Differentiation** — shows the derivative expression
4. **Simplify** *(if needed)* — algebraic simplification
5. **Final Answer** — `f'(x) = ...`

### AI Prompt (for the agent)

```
You are a calculus step solver. When given a derivative problem, respond ONLY with the solution steps. Do NOT add introductory sentences, commentary, or conclusions. Use only these section headers:

- Problem Statement
- Identify the Rule
- Apply Differentiation
- Simplify (only if needed)
- Final Answer

Each step must show the LaTeX expression. No extra words.
```

---

## Slope Using Derivatives

### Input Format

| Type | Example |
|---|---|
| Explicit | `y = x^3 - 2x + 1`, `x = 2` |
| Implicit | `x^2 + y^2 = 25`, `x = 3` |
| Parametric | `x = cos(t), y = sin(t)`, `t = 1.5708` |

### Step Structure

1. **Given** — the equation and point
2. **Rule Statement** — which differentiation rule applies
3. **Algebra** — derivative computation line by line
4. **Substitution** — plugging in the x-value
5. **Result** — slope value, tangent line, normal line

### AI Prompt (for the agent)

```
You are a slope solver using derivatives. Show only the solution steps with these headers:

- Given
- Differentiate
- Substitute
- Slope Result
- Tangent Line (if requested)

No introductions. No summaries. Each step shows only the formula and result.
```

---

## Equation Solver (Basic to Intermediate)

The solver accepts and solves the following equation types:

### Supported Types

| Category | Examples |
|---|---|
| Linear | `2x + 3 = 7`, `5x - 1 = 14` |
| Quadratic | `x^2 - 5x + 6 = 0`, `2x^2 + 3x = 0` |
| Rational | `(x+1)/(x-2) = 3` |
| Radical | `sqrt(x+4) = 3` |
| Absolute value | `abs(x - 2) = 5` |
| Systems (2-var) | `2x + y = 5, x - y = 1` |
| Polynomial (degree ≤ 4) | `x^3 - x = 0` |

### Solve Steps Structure

1. **Identify type** — linear, quadratic, etc.
2. **Rearrange** — move all terms to one side
3. **Apply method** — factoring, quadratic formula, etc.
4. **Simplify** — reduce the expression
5. **Solution** — `x = ...`

---

## LaTeX Rendering

The app uses `flutter_math_fork` for all math rendering. Expressions from solvers are converted to LaTeX before display.

### Conversion Rules (in `_toLatex`)

| Plain text | LaTeX output |
|---|---|
| `x^2` | `x^{2}` |
| `sqrt(x)` | `\sqrt{x}` |
| `sin(x)` | `\sin{x}` |
| `ln(x)` | `\ln{x}` |
| `a/b` | `\frac{a}{b}` |

---

## Dependencies

```yaml
dependencies:
  flutter_math_fork: ^0.7.2     # LaTeX rendering
  equations: ^6.0.0             # Equation solving
  math_expressions: ^2.6.0      # Expression parsing and differentiation
  fn_express: ^1.0.0            # Symbolic derivatives
  provider: ^6.1.1              # State management
  shared_preferences: ^2.2.2    # Local storage
```

---

## Running the Project

```bash
flutter pub get
flutter run
```

Supports Android, iOS, Web, and Desktop. All math computations run **offline** — no internet required after install.

---

## Contributing

Branch naming: `feature/YourName_feature_name`

All solver logic lives in the `solvers/` subfolder of each module. UI is separated from logic.