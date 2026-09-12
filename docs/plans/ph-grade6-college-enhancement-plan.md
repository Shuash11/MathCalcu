# PH Grade 6 to College Enhancement Plan — MathCalcu

**Date:** 2026-09-12
**Status:** Draft
**Repo:** `C:\projects\mathcalcu`
**Output file:** `docs/plans/ph-grade6-college-enhancement-plan.md`

## Overview

MathCalcu is a Flutter offline-first calculator-tutor app. Current app has Calculus, Finals (Derivatives/Integrals/Limits), and Modern Math (ModMat) pickers with step-by-step solvers (`BaseEquation` / `SolveResult` / `StepModel`), `GoRouter` navigation, `ThemeProvider` + `AppDesign` styling, and offline solvers (no network required).

This plan is build-ready and combines validated findings into one document:

- Fix weak/missing input placeholders + validation + empty states (quick win).
- Add PH Curriculum Grade 6 (G6-1..G6-10, DepEd-aligned) with graphs.
- Outline Grade 7 → College roadmap.
- Add global search (reuse ModMat pattern).
- Architecture + task plan for frontend / middle-end / backend / reviewer agents.

All paths are `lib/`-relative unless marked `C:\...` absolute.

---

## Section A — Validated Current State

Verified 2026-09-12 via direct file read (no assumptions):

**Entry / routing / topics:**
- `lib/main.dart` — app entry, `ThemeProvider`, `GoRouter` bootstrap, offline init.
- `lib/app_router.dart` — `GoRouter` routes for calculus / finals / modmat pickers + solver screens. No curriculum/grade routes yet.
- `lib/topics/topics_screen.dart` — top-level topic hub. No search field.
- `lib/core/module_registry.dart` — `ModuleRegistry` base contract for topic modules.
- `lib/topics/calculus/finals/finals_module_registry.dart` (`FinalsModuleRegistry`) — registers Derivatives/Integrals/Limits solvers.
- `lib/topics/modmat/modmat_module_registry.dart` (`ModmatModuleRegistry`) — registers Modern Math topics, only registry with `search()` at line 137.
- No grade/DepEd/year-level logic anywhere in `lib/` (grep `grade|DepEd|curriculum|G6|K-12` = 0 hits outside this plan).

**Search — only in ModMat:**
- `lib/topics/modmat/modmat_picker_screen.dart:291` — only search UI in app: `hintText: 'Search Modern Math topics'`.
- `lib/topics/modmat/modmat_module_registry.dart:137` — only `search(query)` implementation (filters title/tags).
- No search in `calculus_picker_screen.dart`, `finals_picker_screen.dart`, `category_picker_screen.dart`. No global search.

**Placeholders / inputs — inconsistent:**
- `lib/topics/calculus/widgets/math_input_field.dart:66` —Parameterized hint (caller passes `hintText`), good pattern but not uniformly used; no `helperText`/validator standard.
- `lib/topics/calculus/widgets/slope_input_field.dart:100` — `hintText: 'e.g. 3'` — good example, keep as template.
- `lib/topics/calculus/screens/distance_screen.dart:209` (`DistanceScreen`) — `hintText: '0'` — weak, no example format, no helper.
- `lib/topics/calculus/finals/screens/derivatives_screen/derivatives_input_field.dart:65` — actual path has strong hint: `'e.g. x² + 3x + ln(x)'` — use as gold standard.
- `lib/topics/calculus/screens/calculator_screen.dart:152` — no `hintText`, uses `'0'` fallback text — weak, users don't know valid syntax.
- Common gaps: silent `return` on empty submit (no error), no `helperText`, no regex validation message, no uniform `No topics / No graph` empty states, Notes stub screen has no CTA.

**Reusable engines/widgets:**
- `lib/core/calculator_engine.dart` — expression evaluator, reuse for G6 arithmetic/percent/ratio.
- `lib/core/fraction.dart` (`Fraction`) — exact fraction add/sub/mul/div + mixed numbers, reuse for G6-1.
- `lib/widgets/graph_widget.dart` + `lib/core/base_graph.dart` — base graph painter; extend for number-line / bar / shape / 3D-wireframe / pie.

---

## Section B — Placeholder Enhancement Spec

Goal: every input self-explanatory offline, no silent failures, uniform empty states.

### B.1 Global rules (apply to all)

1. Every `TextField` gets explicit `hintText` with `e.g.` example + `helperText` with format/syntax.
2. Empty-submit fix: never silent `return`. Show `SnackBar` or inline `errorText`: `"Enter a value to solve — e.g. ..."`.
3. Validators return user-readable strings, not exceptions. Show inline under field.
4. Uniform empty states:
   - No topics/search result: icon `search_off`, title `"No topics found"`, subtitle `"Try another keyword"`, action `Clear search` button.
   - No graph: icon `show_chart`, title `"No graph for this input"`, subtitle with reason.
5. Notes stub CTA: `"Notes coming soon for this topic"` + button `"Open examples"` scrolling to examples.
6. Styling via `ThemeProvider` + `AppDesign` (no hardcoded colors), keep `math_input_field.dart` wrapper as single source.

### B.2 File-by-file table

| File | Current | Proposed `hintText` / `helperText` / validation / empty-state |
|---|---|---|
| `lib/topics/calculus/widgets/math_input_field.dart:66` | Parameterized hint, no standard helper/validator | Keep as base. Add optional `helperText`, `validator`, `errorText` params. Default empty-submit error: `"Enter an expression — e.g. x^2+3*x"`. All other fields migrate to this widget. |
| `lib/topics/calculus/widgets/slope_input_field.dart:100` | `'e.g. 3'` good | Keep. Add `helperText: 'Enter slope m or two points (x1,y1)'`. Validation: numeric regex `^-?\d+(\.\d+)?$` or point-pair parser. Empty: inline error, not silent. |
| `lib/topics/calculus/screens/distance_screen.dart:209` | `'0'` weak | Change to `hintText: 'e.g. (1,2), (4,6)'`, `helperText: 'Format: (x1,y1), (x2,y2) — numbers only'`. Regex: `^\(\s*-?\d+(\.\d+)?\s*,\s*-?\d+(\.\d+)?\s*\)\s*,\s*\(.*\)$` or two-field split. Error: `"Use (x1,y1), (x2,y2)"`. |
| `lib/topics/calculus/finals/screens/derivatives_screen/derivatives_input_field.dart:65` | `'e.g. x² + 3x + ln(x)'` strong | Promote as gold standard. Add `helperText: 'Use x, ^, sin/cos/ln/sqrt — e.g. x^2+3*x'`. Validation: `calculator_engine` parse try/catch → `"Could not parse — check ^ and parentheses"`. |
| `lib/topics/calculus/screens/calculator_screen.dart:152` | No hint, `'0'` fallback | Add `hintText: 'e.g. (2+3)*4 - sqrt(16)'`, `helperText: 'Supports + - * / ^ ( ) sqrt() %'`. Empty submit → keep last result + `SnackBar`. Invalid → inline `"Invalid expression"`. |
| `calculus_picker / finals_picker / category_picker` screens | No search, generic list, no empty state | Add search bar reusing ModMat pattern (see §E). Empty state: `search_off` + `Clear` button. Each tile gets subtitle example. |
| Notes stub screens (all `*_notes_screen.dart`) | Static lorem/empty | Add CTA block: `"Worked examples below"` + button. Standardize title `"Notes — <Topic>"`. |
| All solver result screens | No uniform no-graph state | Add `NoGraphPlaceholder` widget: icon + reason. Reuse for G6 graphs (§C). |

### B.3 Acceptance

- No `TextField` with bare `'0'` or missing `hintText` remains (grep `hintText.*'0'` = 0).
- Empty Solve pressed with empty input shows visible error 100% of time.
- Evaluator: contrast + spacing pass on input screens.

---

## Section C — Grade 6 (G6-1 to G6-10, DepEd-Aligned)

Codes use DepEd MELC `M6NS / M6AL / M6ME / M6SP / M6GE` shorthand. G6-1..G6-9 must-have, G6-10 pie must-have + probability nice-to-have.

Build waves (validated):
- **Wave 1:** G6-1, G6-2, G6-3 (fractions/decimals/percent) — reuse `Fraction` + `calculator_engine`, no new graphs.
- **Wave 2:** G6-4, G6-5, G6-6 (ratio / whole-number order-of-ops / simple algebra) — add bar-strip graph.
- **Wave 3:** G6-7, G6-8, G6-9 (integers number-line / geometry shapes / volume wireframe) — graph-heavy.
- **Wave 4:** G6-10 (pie + stats) + global search + placeholder polish + history.

Reuse vs new legend: `REUSE` = extend existing; `NEW` = new `lib/topics/grade6/...` solver + screen.

### G6-1 Fractions (add/sub/mixed) — MUST

- **DepEd:** `M6NS-Ia-86` (add/sub fractions, mixed).
- **Examples:** (1) `1/2 + 3/4` → `1 1/4`; (2) `2 1/3 - 1 5/6` → `1/2`.
- **Output:** `SolveResult` with exact `Fraction` + decimal + steps.
- **Steps (4):** 1) Convert mixed→improper 2) LCD 3) Add/sub numerators 4) Simplify + mixed.
- **Graph:** No.
- **hintText:** `'e.g. 2 1/3 + 1 1/2'` / `helperText: 'Formats: a/b, mixed a b/c, + - × ÷'`.
- **Validation:** regex `^\s*\d*\s*\d+\/\d+\s*[\+\-\*\/]\s*\d*\s*\d+\/\d+\s*$` + denominator ≠ 0 + simplify check.
- **Reuse/NEW:** `REUSE lib/core/fraction.dart`, `REUSE calculator_engine.dart` for decimal check. `NEW G6FractionEquation : BaseEquation`.

### G6-2 Decimals (operations + rounding) — MUST

- **DepEd:** `M6NS-Ib-106` (multiply/divide decimals).
- **Examples:** (1) `3.25 × 1.2` → `3.900`; (2) `7.5 ÷ 0.25` → `30`.
- **Output:** decimal + place-value breakdown.
- **Steps (4):** 1) Align/ignore decimals 2) Multiply/divide as whole 3) Place decimal 4) Round if asked.
- **Graph:** No (optional place-value strip).
- **hintText:** `'e.g. 3.25 × 1.2'` / `helper: 'Use . for decimal, × ÷ or * /'`.
- **Validation:** `^-?\d+\.\d+\s*[\+\-\*\/×÷]\s*-?\d+(\.\d+)?$`; divisor ≠ 0.
- **Reuse:** `REUSE calculator_engine.dart`. `NEW G6DecimalEquation`.

### G6-3 Percent (of number, increase/discount) — MUST

- **DepEd:** `M6NS-Ic-131` (percent of quantity, discount).
- **Examples:** (1) `25% of 200` → `50`; (2) `₱500 less 20%` → `₱400`.
- **Output:** value + formula `P = R × B`.
- **Steps (3):** 1) Rate→decimal 2) Multiply 3) Peso/% label.
- **Graph:** No (Wave 4 pie preview optional).
- **hintText:** `'e.g. 25% of 200'` / `helper: 'Formats: 25% of 200, 500 -20%'`.
- **Validation:** `^\d+(\.\d+)?%\s*(of\s*)?\d+(\.\d+)?$`; rate 0–1000% clamp warning if >100%.
- **Reuse:** `REUSE calculator_engine.dart`.

### G6-4 Ratio & Proportion — MUST

- **DepEd:** `M6NS-Id-140` (ratio, proportion, missing term).
- **Examples:** (1) `Simplify 12:18` → `2:3`; (2) `3/4 = x/20` → `x=15`.
- **Output:** simplified ratio + missing term + cross-product check.
- **Steps (4):** 1) Write as fraction 2) GCD simplify 3) Cross-multiply if proportion 4) Verify.
- **Graph:** Yes — bar strips (two horizontal bars proportional lengths).
- **hintText:** `'e.g. 12:18 or 3/4 = x/20'` / `helper: 'Use : or / and x for unknown'`.
- **Validation:** `^(\d+\s*:\s*\d+|\d+\/\d+\s*=\s*\w+\/\d+)$`; terms > 0.
- **Reuse:** `REUSE graph_widget.dart` → `NEW RatioBarPainter : base_graph.dart`. `NEW G6RatioEquation`.

### G6-5 Order of Operations (GEMDAS) — MUST

- **DepEd:** `M6NS-IIa-148` (GEMDAS whole numbers).
- **Examples:** (1) `8 + 2 × 5` → `18`; (2) `(10 - 2)² ÷ 4` → `16`.
- **Output:** numeric + per-step evaluation.
- **Steps (4):** 1) Grouping 2) Exponents 3) ×/÷ L→R 4) +/− L→R.
- **Graph:** No.
- **hintText:** `'e.g. 8 + 2 × (5-3)^2'` / `helper: 'G E M D A S — use ( ) ^ * / + -'`.
- **Validation:** balanced parens + allowed chars `^[0-9+\-*/^()×÷\s]+$`.
- **Reuse:** `REUSE calculator_engine.dart` with step trace.

### G6-6 Simple Algebra (x + one step) — MUST

- **DepEd:** `M6AL-IIIa-28` (one-step equations).
- **Examples:** (1) `x + 7 = 15` → `x=8`; (2) `3n = 21` → `n=7`.
- **Output:** variable value + inverse-op check.
- **Steps (3):** 1) Identify op 2) Inverse both sides 3) Check substitute.
- **Graph:** No (optional balance scale in Wave 3).
- **hintText:** `'e.g. x + 7 = 15'` / `helper: 'One variable, one = sign'`.
- **Validation:** `^[a-zA-Z]\s*[\+\-\*\/]\s*-?\d+\s*=\s*-?\d+$` extended for `3n=21`.
- **Reuse:** `REUSE calculator_engine.dart`. `NEW G6AlgebraEquation`.

### G6-7 Integers (compare/add/sub, number line) — MUST

- **DepEd:** `M6NS-IIIb-150` (integers, number line).
- **Examples:** (1) `-5 + 8` → `3`; (2) `Compare -3 _ 2` → `-3 < 2`.
- **Output:** integer + position description.
- **Steps (4):** 1) Locate on line 2) Direction (left−/right+) 3) Count steps 4) Sign rule.
- **Graph:** Yes — number-line (`-10..10` ticks, arrows, jump animation static).
- **hintText:** `'e.g. -5 + 8'` / `helper: 'Integers only — use - sign, + - < >'`.
- **Validation:** `^-?\d+\s*[\+\-<>=]\s*-?\d+$`; integers only (reject decimals with message).
- **Reuse:** `REUSE base_graph.dart` → `NEW NumberLinePainter`. `NEW G6IntegerEquation`.

### G6-8 Geometry (perimeter/area/angles) — MUST

- **DepEd:** `M6GE-IIIc-37` (perimeter/area, angle measure).
- **Examples:** (1) `Rectangle 6×4` → `P=20, A=24`; (2) `Triangle base 8 height 5` → `A=20`.
- **Output:** labeled `P/A` with units (cm, cm²) + shape diagram with dimensions.
- **Steps (5):** 1) Identify shape 2) Formula 3) Substitute 4) Compute 5) Units.
- **Graph:** Yes — shape diagram (rect/triangle/circle with dimension labels).
- **hintText:** `'e.g. rect 6x4'` / `helper: 'Pick shape first, then L W or b h r'`. Prefer dropdown + numeric fields over free text.
- **Validation:** positive numbers only `>0`, triangle inequality if 3 sides given.
- **Reuse:** `REUSE graph_widget.dart` → `NEW ShapeDiagramPainter`. `NEW G6GeometryEquation`.

### G6-9 Volume (prisms/cube, 3D wireframe) — MUST

- **DepEd:** `M6ME-IVa-95` (volume of cube/prism).
- **Examples:** (1) `Cube s=4` → `V=64`; (2) `Prism 5×3×2` → `V=30`.
- **Output:** volume in units³ + wireframe + formula `V=l×w×h`.
- **Steps (4):** 1) Formula 2) Substitute 3) Multiply 4) Cubic units.
- **Graph:** Yes — 3D wireframe (isometric box, dashed hidden edges).
- **hintText:** `'e.g. 5 x 3 x 2'` / `helper: 'L x W x H in same units'`.
- **Validation:** three positives; reject 0/negative.
- **Reuse:** `REUSE base_graph.dart` → `NEW WireframeBoxPainter`. `NEW G6VolumeEquation`.

### G6-10 Data: Pie Chart + Probability (intro) — PIE MUST, PROB NICE

- **DepEd:** `M6SP-IVe-1` (pie graph) + `M6SP-IVg-2` (simple probability, nice-to-have).
- **Examples:** (1) `Data 40%,30%,30%` → pie with labels; (2) `P(red) in 3R+2B` → `3/5`.
- **Output:** pie slices + % + probability fraction/decimal/% triple.
- **Steps (5):** 1) Total 2) %→degrees (`%×3.6°`) 3) Draw slices 4) Label 5) (Prob) favorable/total + simplify.
- **Graph:** Yes — pie chart (must) + optional bar fallback.
- **hintText:** `'e.g. Math 40, Science 30, English 30'` / `helper: 'Comma values or label:value, must sum >0'`.
- **Validation:** values ≥0, sum >0, auto-normalize to 100%; prob denominator ≠0.
- **Reuse:** `REUSE graph_widget.dart` → `NEW PieChartPainter`. `NEW G6PieEquation`, `NEW G6ProbabilityEquation` (prob nice-to-have, may ship Wave 4+).

---

## Section D — Grade 7 to College Overview

Concise; each level 5–8 topics. Source: prior research (Algebra, Quadratics, Trig, Logs, Interest/Annuity, Integrals, L'Hôpital, Stats, Multivariable). Full solver specs deferred to Phase 2 plan; here example + output + graph need only.

| Level | Topics (example → output / graph) |
|---|---|
| **G7** | 1. Signed numbers `−8−(−3)` → int / number-line. 2. Algebraic eval `2x+3, x=4` → 11 / no. 3. Linear eq `2x−5=9` → x=7 / balance-scale optional. 4. Inequalities `3x<12` → `x<4` / number-line shading. 5. Angles/pairs `complement 35°` → 55° / shape. 6. Basic stats mean/median `4,7,9` → 6.67 / bar. 7. Simple probability `die 6` → 1/6 / no. |
| **G8** | 1. Factoring `x²+5x+6` → (x+2)(x+3) / parabola. 2. Linear systems `x+y=5,x−y=1` → (3,2) / two lines intersect. 3. Slope/intercept `m=2,b=−1` → y=2x−1 / line graph. 4. Radicals `√50` → 5√2 / no. 5. Exponents laws `x³·x⁴` → x⁷ / no. 6. Functions/domain `f(x)=1/(x−2)` → x≠2 / curve w/ asymptote. |
| **G9** | 1. Quadratics formula `x²−5x+6=0` → 2,3 / parabola + roots. 2. Completing square `x²+6x+5` → (x+3)²−4 / parabola. 3. Rational eq `1/x+1/2=3/4` → x=4 / no. 4. Variation `y=kx, y=10,x=2` → k=5 / line. 5. Similarity/proof setup / shape. 6. Basic trig ratio `SOH sin30°` → 0.5 / right-triangle. |
| **G10** | 1. Sequences `aₙ=3n+1` → 4,7,10… / dot plot. 2. Polynomial div `÷(x−1)` → quotient+remainder / no. 3. Circle eq `(x−1)²+(y+2)²=9` → C(1,−2)r=3 / circle. 4. Perm/comb `C(5,2)` → 10 / no. 5. Normal/stats intro `z=(85−75)/10` → 1.0 / bell curve. 6. Trig graphs `sin` amplitude/period / sine wave. |
| **G11 SHS GenMath / PreCalc** | 1. Functions/composition `f∘g` → expr / curve. 2. Logs/exponents `log₂32` → 5 / log curve. 3. Simple/compound interest `P=10k,r=5%,t=2` → ₱11,025 / bar growth. 4. Annuity `R=1k,i=1%,n=12` → FV / growth curve. 5. Conics `ellipse/parabola` / conic graph. 6. Limits intro `lim x→2 (x²−4)/(x−2)` → 4 / curve w/ hole. 7. Series `Σ` → sum / no. |
| **G12 Basic Calculus** | 1. Limits + continuity / curve. 2. Derivatives power/chain/product (reuse FinalsModule) / tangent line. 3. Applications max/min, related rates / graph + diagram. 4. Antiderivatives/indefinite `∫2x dx` → x²+C / area shade. 5. Definite + FTC `∫₀² x²dx` → 8/3 / shaded area. 6. Differential eq intro (optional) / slope field. |
| **College** | 1. L'Hôpital `0/0` → limit / curve. 2. Integration techniques (parts/partial) / area. 3. Multivariable partials/gradient `f=x²+xy` → fx,fy / 3D surface or contour. 4. Matrices/determinants `2×2` → det/inverse / no. 5. Stats: hypothesis z/t, regression `y=mx+b` / scatter+line, bell. 6. DiffEq `dy/dx=ky` → Ceᵏˣ / slope field. 7. Vectors/complex (nice) / arrow/Argand. |

Graph rule: function topics need Cartesian plot; stats need bar/bell/scatter; geometry needs shape; volume/solids need wireframe/surface. All via `graph_widget.dart` extensions.

---

## Section E — Architecture

### E.1 `CurriculumRegistry` design (new)

New file: `lib/core/curriculum_registry.dart`.

```dart
class CurriculumTopic {
  final String id;          // e.g. 'g6-4-ratio'
  final String gradeLevel;  // 'G6' | 'G7' ... 'G12' | 'College'
  final String subject;     // 'Fractions' | 'Algebra' | 'Calculus' ...
  final List<String> tags;  // search keywords: ['ratio','proportion','M6NS']
  final String difficulty;  // 'intro' | 'standard' | 'challenge'
  final String route;       // GoRouter path e.g. '/grade6/ratio'
  final String icon;        // lucide/material name e.g. 'scale'
  final String depeCode;    // e.g. 'M6NS-Id-140'
}
```

- `CurriculumRegistry` merges `ModuleRegistry` + `FinalsModuleRegistry` + `ModmatModuleRegistry` + new `Grade6ModuleRegistry` (later `Grade7..College`).
- Each topic extends `BaseEquation` (parse + validate), returns `SolveResult` with `List<StepModel>`.
- Registry exposes `allTopics()`, `byGrade('G6')`, `search(query)` — search reuses ModMat logic (lowercase title+tags contains, see §E.3).
- Offline-first: no network; all solvers pure Dart. Search is in-memory filter.
- Styling: all screens consume `ThemeProvider` + `AppDesign` tokens; graphs use theme colors (no hardcoded hex).

### E.2 `GoRouter` additions (`lib/app_router.dart`)

- `/grade6` → `Grade6PickerScreen` (grid of G6-1..G6-10 cards).
- `/grade6/:id` → per-topic solver screen (e.g. `/grade6/ratio`, `/grade6/volume`).
- `/search` → `GlobalSearchScreen` (all grades, Phase 2; Wave 4 ships G6 + ModMat + Finals index).
- Keep existing `/calculus`, `/finals/*`, `/modmat` routes untouched; add `redirect` guard for unknown `:id` → `/grade6`.

### E.3 Search reuse pattern (from ModMat)

Copy from `lib/topics/modmat/modmat_picker_screen.dart:291` + `modmat_module_registry.dart:137`:

1. `TextField(searchController)` with `hintText: 'Search topics, e.g. ratio, pie, derivative'`.
2. `onChanged` → `registry.search(q)` filtering `title + tags + depeCode`.
3. Uniform empty state (§B.1) + `Clear` resets.
4. Extend to `calculus_picker`, `finals_picker`, `category_picker`, then `GlobalSearchScreen` aggregating all registries via `CurriculumRegistry.search()`.

### E.4 Models / theming

- Solvers: `extends BaseEquation`, `SolveResult(steps: List<StepModel>, graphSpec?)`, `graphSpec` drives `graph_widget.dart`.
- Graphs: `extends base_graph.dart` painters (`NumberLine`, `RatioBar`, `Shape`, `WireframeBox`, `Pie`).
- History/persistence (Phase 2): shared `HistoryStore` (SharedPreferences/Hive offline), reused by all grades.

---

## Section F — Task Plan (agents + dependencies)

Agents: `frontend` (screens/widgets), `middle-end` (registries/routing/search), `backend` (solvers/engines/graph painters), `reviewer` (tests + review gate).

| # | Task | Agent | Dependencies | Expected result |
|---|---|---|---|---|
| 1 | Placeholders + validation + empty states (§B) | frontend | none | All weak hints fixed, empty-submit shows error, uniform `No topics/graph` widgets, Notes CTA; grep `hintText.*'0'` = 0. |
| 2 | `CurriculumRegistry` + `Grade6ModuleRegistry` skeleton + GoRouter `/grade6` | middle-end | Task 1 (patterns) | `lib/core/curriculum_registry.dart` with fields §E.1, picker grid, routes compile, no solver logic yet. |
| 3 | Global search (reuse ModMat) across pickers + `/search` | middle-end | Task 2 | Search bar in all pickers, `CurriculumRegistry.search()` covers ModMat+Finals+G6 skeleton, empty state + clear works offline. |
| 4 | Phase-1 solvers G6-1..G6-6 (Fractions→Algebra) | backend | Task 2 | 6 `*Equation` classes extent `BaseEquation`, unit-tested exact outputs §C, reuse `fraction.dart`/`calculator_engine.dart`. |
| 5 | Phase-1 UI G6-1..G6-6 + bar-strip graph | frontend | Tasks 2,4 | 6 solver screens with hint/validation §C, ratio bar painter, ThemeProvider styling, screenshot pass. |
| 6 | Phase-2 solvers + graphs G6-7..G6-10 (number-line/shape/wireframe/pie) | backend | Tasks 4,5 | 4 solvers + 4 painters (`NumberLine/Shape/Wireframe/Pie`), prob nice-to-have flagged, step lists match §C. |
| 7 | Persistence/history + Notes examples for G6 | frontend + middle-end | Tasks 5,6 | Offline history (Hive/prefs), Notes CTA wired, history survives restart. |
| 8 | Tests + reviewer PASS gate | reviewer | Tasks 1–7 | `flutter test` green, widget golden for G6 pickers/graphs, review checklist (placeholders, DepEd codes, offline, contrast) PASS before merge. |

Parallelism: 1+2 can start together; 3 after 2; 4+5 overlap by topic; 6 after 5 (painters build on widget patterns); 7 after 6; 8 last.

---

## Assumptions + Open Questions + Next Step

**Assumptions:**
- Offline-first non-negotiable (no API for solvers/search).
- DepEd codes are MELC shorthand; exact division numbering may shift — registry `depeCode` field makes remap trivial.
- `math_input_field.dart` becomes shared input; `graph_widget.dart`/`base_graph.dart` become shared graph host.
- Pie must-have, probability nice-to-have per validation (ships only if Wave 4 capacity allows).

**Open questions:**
1. Exact DepEd order for G6-5 vs G6-6 (GEMDAS before algebra?) — confirm against current MELC PDF before Wave 2.
2. History store: SharedPreferences vs Hive — decide in Task 7 (Hive preferred if images/graph cache needed).
3. Global `/search` scope Wave 4: G6+ModMat+Finals only, or include G7+ stubs? Recommend former to avoid dead links.
4. Filipino/English toggle for hints? Default English, add `tags` in Filipino for search recall.

**Next step:** Start with Tasks 1–3 (placeholders, registry skeleton, search) — unlocks Waves 1–2 without blocking solver work. Then Wave 1 (G6-1..G6-3).

---

*Generated for build agents. Keep file paths `lib/`-relative. Update status to `In Progress` when Tasks 1–3 start.*
