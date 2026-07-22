# MathCalcu Modern Math Section Navigation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: use `subagent-driven-development` (recommended) or `executing-plans` to execute this plan task-by-task. Use `using-git-worktrees` before implementation. This document does not authorize implementation, staging, commits, pushes, pull requests, workflow dispatches, merges, or releases by the Planning Agent.

**Goal:** Correct Modern Math search so catalogue results navigate only to the two existing section screens, while making section topic cards truthful, static catalogue entries rather than links to nonexistent leaf routes.

**Architecture:** Replace Modern Math's use of routable `ModuleEntry` objects with a local, non-routable `ModmatCatalogueItem` and a closed `ModmatSection` enum that alone maps Foundations and Advanced to their existing production section routes. Search remains a derived projection over both catalogue lists; each result exposes one explicit `Open Foundations` or `Open Advanced` action. The existing `AppRouter` is consumed by tests and is not modified.

**Tech stack:** Flutter/Dart, Material, Provider, `go_router`, `flutter_test`, Git worktrees, GitHub CLI (`gh`).

---

## 1. Status, authority, and supersession boundary

This is the canonical correction plan for the user-approved **section navigation** decision. Historical context remains:

- `.opencode/specs/mathcalcu-release-polish-modern-math-search-and-59898fa48cf7-SPEC-v01.md`
- `.opencode/plans/mathcalcu-release-polish-modern-math-search-and-59898fa48cf7-PLAN-v03.md`
- the Product Analyst handoff summarized in the planning request;
- the Solution Architect handoff summarized in the planning request.

Repository inspection confirms that `lib/app_router.dart` defines only these Modern Math destinations:

- `/topics/modmat`
- `/topics/modmat/foundations`
- `/topics/modmat/advanced`

There are no leaf topic screens or leaf topic routes. Therefore this plan supersedes **only** historical clauses that assume a search result can open a topic-specific route:

| Historical clause | Corrected authority in this plan |
|---|---|
| SPEC v01 Scope 1: nonempty search provides “direct topic results” and each result opens an “existing route” | Results still match individual catalogue topics, but their only action opens the topic's owning section. |
| SPEC v01 Data and State: registry owns a route per topic | `ModmatCatalogueItem` has no route. `ModmatSection` is the sole Modern Math route map. |
| SPEC v01 Acceptance 4 and 12: result navigation uses each module route | Navigation assertions use the production `AppRouter` and verify Foundations/Advanced section destinations. |
| SPEC v01 Assumption: existing per-topic routes are desired targets | No such routes exist; only the two existing section routes are valid targets. |
| PLAN v03 Task 05, Task 09, coverage matrix, and route-risk text requiring `hit.module.route`, exact leaf-route taps, or synthetic leaf routes | Replace with section enum routing, explicit section actions, production-router tests, and a no-leaf-route source check. |

Everything else remains approved and is not reopened by this correction. In particular:

- search matching, trim/case behavior, registry-derived future-entry behavior, no-results/clear behavior, themes, responsive behavior, and accessibility remain required;
- all approved update-service, startup, Settings, package-version `1.12.8+8`, stale-version-source removal, lifecycle, failure, and shipping-gate work remains intact;
- existing update/version changes in the dirty root are preserved but are not owned, edited, staged, or reviewed by this Modern Math workstream;
- no `.opencode/**` state or historical artifact is mutated;
- no local/manual `flutter build` is permitted. Build verification is through a safe GitHub Actions check observed with `gh` only.

## 2. Current architecture and diagnosed defect

### Relevant current paths

- `lib/topics/modmat/modmat_module_registry.dart` currently imports the shared routable `ModuleEntry` and assigns 14 nonexistent leaf route strings.
- `lib/topics/modmat/modmat_picker_screen.dart` currently calls `context.push(hit.module.route)` from a fully interactive result card.
- `lib/topics/modmat/midterm/modmat_foundations_screen.dart` currently turns every catalogue item into a tappable card that pushes `module.route`.
- `lib/topics/modmat/midterm/modmat_advanced_screen.dart` has the same invalid leaf navigation.
- `test/topics/modmat/modmat_picker_screen_test.dart` currently manufactures a synthetic `GoRouter` route for every registry entry, so its route tests can pass even though production cannot navigate to those routes.
- `lib/app_router.dart` already maps the picker and both section screens correctly and must stay byte-for-byte unchanged by this contribution.

### Root cause

Modern Math reused the shared `ModuleEntry` type, whose required `route` field implies that every catalogue record has a destination. The UI and synthetic tests then treated those invented values as valid routes. The data model must make the impossible state unrepresentable: a topic catalogue item cannot carry a route.

## 3. Scope and exact file ownership

### Single frontend workstream

One **Frontend Implementer** owns all product and test edits, sequentially, in one isolated implementation worktree. No other workstream or task may edit these files while the task is active:

1. `lib/topics/modmat/modmat_module_registry.dart`
2. `lib/topics/modmat/modmat_picker_screen.dart`
3. `lib/topics/modmat/midterm/modmat_foundations_screen.dart`
4. `lib/topics/modmat/midterm/modmat_advanced_screen.dart`
5. `test/topics/modmat/modmat_picker_screen_test.dart`

Tester, Code Reviewer, Security Reviewer, PR Coordinator, and Git Steward are read-only with respect to product files. The Git Steward may stage the five approved paths after all precommit gates pass.

### Explicitly forbidden paths and changes

- `lib/app_router.dart` — no route addition, redirect, page, alias, fallback, or import edit.
- `.opencode/**` — never copy, edit, stage, remove, normalize, or use as new workflow state.
- `.github/workflows/**` — no workflow mutation in this scope.
- update/version paths such as `lib/main.dart`, `lib/screens/settings_screen.dart`, `lib/services/update_service.dart`, `pubspec.yaml`, `lib/version.dart`, `web/version.json`, and their tests.
- `pubspec.lock`, dependencies, generated files, build output, release metadata, tags, releases, deployments, or installer files.
- any new Modern Math page, leaf route, redirect, placeholder destination, toast pretending navigation succeeded, or dynamic route construction.

## 4. Frozen component and control-flow design

### 4.1 Non-routable catalogue model

Implement this shape in `lib/topics/modmat/modmat_module_registry.dart` (field names are contractual for this plan):

```dart
enum ModmatSection {
  foundations(
    label: 'Foundations',
    route: '/topics/modmat/foundations',
  ),
  advanced(
    label: 'Advanced',
    route: '/topics/modmat/advanced',
  );

  const ModmatSection({required this.label, required this.route});

  final String label;
  final String route;
}

class ModmatCatalogueItem {
  const ModmatCatalogueItem({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color accent;
}

class ModmatSearchHit {
  const ModmatSearchHit({required this.section, required this.item});

  final ModmatSection section;
  final ModmatCatalogueItem item;
}
```

Registry requirements:

- remove the import of `core/module_registry.dart`;
- retain every existing topic label, subtitle, icon, accent, section membership, and order;
- rename the typed lists to `foundationsCatalogue` and `advancedCatalogue`;
- expose `catalogueFor(ModmatSection section)` with an exhaustive enum switch;
- make `search(String query)` derive hits at call time from both lists, in Foundations-then-Advanced registry order;
- preserve trim plus case-insensitive partial matching over title and subtitle;
- do not add `route`, `path`, URI, callback, widget builder, or destination data to `ModmatCatalogueItem`;
- do not add an open-ended string-to-route lookup.

### 4.2 Picker behavior

Control flow must be:

```text
query -> ModmatModuleRegistry.search -> ModmatSearchHit
      -> render catalogue metadata and owning section
      -> explicit “Open <Section>” button
      -> context.push(hit.section.route)
      -> existing production section screen
```

The result card itself is informational, not a disguised topic link. It must:

- show the topic title, subtitle, and section context;
- contain one visible `Open Foundations` or `Open Advanced` button;
- navigate only from that explicit button using `hit.section.route`;
- expose an action semantic label that includes both topic and destination, for example `Open Foundations section for Propositional Logic`;
- retain keyboard focus/activation, pointer hover/focus feedback on the actual action, and a minimum 48-by-48 logical-pixel action target;
- retain search clear, intentional no-results, local transient state, and controller/focus/animation disposal behavior;
- retain interactive top-level Foundations/Advanced section cards, but implement them as keyboard-operable Material actions with button semantics rather than bare gesture-only controls.

### 4.3 Section screen behavior

Both section screens consume their `List<ModmatCatalogueItem>` and render static cards. Each screen must:

- replace “topics available” language with truthful catalogue language;
- display a visible banner with the exact title `Topic catalogue` and message `Topic content is not available yet.`;
- render each topic card without `GestureDetector`, `InkWell`, `onTap`, hover/pressed navigation animation, trailing navigation arrow, or button/link semantics;
- display a visible `Catalogue only` status on each card;
- expose each card to assistive technology as informational content, including title, subtitle, and unavailable status;
- keep the existing section visual identity, theming, scroll behavior, and entrance animation where it does not imply interactivity;
- replace the gesture-only back control with a keyboard-operable button, tooltip, semantic label, and at least a 48-by-48 logical-pixel target.

### 4.4 Production router test strategy

`test/topics/modmat/modmat_picker_screen_test.dart` must import `app_router.dart` and use `AppRouter.router`. Delete the synthetic `_buildRouter`, generated leaf `GoRoute` list, “Navigated to …” scaffolds, and all synthetic leaf-route expectations.

The production router is a static singleton. Tests must not dispose it. Every widget test must isolate state as follows:

1. before pumping, call `AppRouter.router.go('/topics/modmat')`;
2. pump `MaterialApp.router(routerConfig: AppRouter.router)` under a fresh `ThemeProvider`;
3. after each navigation assertion, unmount with `tester.pumpWidget(const SizedBox.shrink())` and pump once;
4. reset the singleton with `AppRouter.router.go('/')` in `addTearDown`;
5. never call `AppRouter.router.dispose()`;
6. when one test loops through viewport/theme cases, unmount and reset to `/topics/modmat` before each case so shell branch and navigation-stack state cannot leak.

## 5. Acceptance criteria

| ID | Verifiable acceptance criterion |
|---|---|
| AC1 | No `ModmatCatalogueItem` has route/destination data, and no Modern Math leaf route string exists under `lib/` or `test/`. |
| AC2 | `ModmatSection.values` is closed to Foundations and Advanced and maps exactly to `/topics/modmat/foundations` and `/topics/modmat/advanced`. |
| AC3 | Search still trims input, treats whitespace as empty, matches title/subtitle case-insensitively across both lists, preserves deterministic order, includes future list entries, supports clear, and shows an intentional no-results state. |
| AC4 | Every search result shows section context and exactly one visible `Open Foundations` or `Open Advanced` action; no result attempts a leaf route. |
| AC5 | Tests using the production `AppRouter` prove a Foundations result opens `ModmatFoundationsScreen` and an Advanced result opens `ModmatAdvancedScreen`; no synthetic route is built. |
| AC6 | Both section screens show `Topic catalogue`, `Topic content is not available yet.`, and static `Catalogue only` cards with no tap callback, navigation affordance, or button semantics. |
| AC7 | Search, clear, back, section, and result controls are keyboard operable, semantically labelled, visibly focusable, and at least 48-by-48 logical pixels; static catalogue cards are not announced as actions. |
| AC8 | Picker, search results, and both section screens have no Flutter overflow/exception at 320 and 1280 logical pixels, in light and dark themes, including a larger text scale. |
| AC9 | `lib/app_router.dart`, `.opencode/**`, `.github/workflows/**`, and unrelated update/version work are unchanged and unstaged by this contribution. |
| AC10 | Changed-scope format, focused test, changed-scope analysis, diff, and source checks pass; residual repository-wide debt is not misattributed. |
| AC11 | A safe GitHub Actions build check for the exact PR head succeeds and is verified through `gh`; no local/manual `flutter build` is run. |

## 6. Dependency graph and owners

```text
P0 Plan PR approved/merged
  -> W0 isolated contribution worktree + dirty-work transfer
    -> F1 one frontend TDD implementation task (all five owned paths)
      -> T1 independent focused/precommit verification
        -> G1 Git Steward stages exact allowlist and creates contribution commit
          -> R1 code review at exact commit
            -> S1 explicit security gate at exact commit
              -> P1 implementation PR push/open
                -> C1 safe GitHub Actions build check through gh
                  -> E1 readiness handoff (no merge/release without approval)
```

| Task | Owner | Writes | Depends on | Exit condition |
|---|---|---|---|---|
| P0 | PR Coordinator | Plan contribution only | User approval of this document | Plan PR approved and merged; no product paths included. |
| W0 | PR Manager | Worktree/branch metadata only | P0 | Isolated worktree contains only the approved imported Modern Math dirt; source root remains untouched. |
| F1 | Frontend Implementer | Exactly the five owned paths | W0 | RED evidence recorded, minimal GREEN implementation complete, focused checks pass. |
| T1 | Precommit Tester | None | F1 | All local non-build checks pass; findings identify expected/actual/path. |
| G1 | Git Steward | Git index and one normal commit | T1 | Exact allowlist staged, exclusions proven, commit created without amend. |
| R1 | Code Reviewer | None | G1 | Code review approves the exact tested commit SHA. |
| S1 | Security Reviewer | None | R1 | Security review approves the same commit or reports a scope-triggered finding. |
| P1 | PR Coordinator | Remote branch/PR metadata | S1 | Exact reviewed commit pushed and implementation PR opened. |
| C1 | PR Coordinator | None | P1 | Safe Actions build succeeds for exact PR head and is verified using `gh`. |
| E1 | Readiness Auditor | None | C1 | Acceptance matrix complete; merge/release remains a separate user gate. |

No two writing tasks run in parallel. F1 is intentionally one workstream because registry, picker, both section screens, and the single test file must evolve together without incompatible intermediate ownership.

## 7. Entry gates and isolated worktrees

### 7.1 Preserve the dirty root

`C:\projects\mathcalcu` is the main checkout on `main` at the inspected base commit and contains valuable combined implementation plus unrelated `.opencode` and update/version dirt. No role may reset, clean, stash, restore, switch, broadly format, or commit that checkout.

Use one external worktree per contribution, not one per role. Because `.worktrees/` is not currently ignored, use an external path rather than editing `.gitignore`:

- Plan PR worktree: `C:\Users\joashua\AppData\Local\Temp\opencode\mathcalcu-plan-modern-math-section-navigation`
- Implementation worktree: `C:\Users\joashua\AppData\Local\Temp\opencode\mathcalcu-modern-math-section-navigation`

Before creating either worktree, detect whether the executor is already isolated with `git rev-parse --git-dir`, `git rev-parse --git-common-dir`, and `git rev-parse --show-superproject-working-tree`. Reuse a valid existing contribution worktree; do not nest worktrees.

### 7.2 Plan PR contribution

The PR Coordinator, not the Planning Agent, later creates/reuses the Plan PR worktree from current `origin/main`, copies only this plan document into it, and proves that the staged set is exactly:

```text
docs/plans/mathcalcu-modern-math-section-navigation.md
```

The Plan PR must not contain product code, `.opencode/**`, update/version dirt, generated files, or workflow changes. Implementation entry requires explicit Plan PR approval and merge (or an explicitly approved stacked-PR base); do not silently choose a stacked base.

### 7.3 Implementation contribution

After P0, create/reuse branch `feat/modern-math-section-navigation` in the external implementation worktree from the exact approved base. Record the base SHA using native Git output, not a custom proof file.

Transfer the current combined Modern Math work from the dirty root by copying **only** the five owned paths listed in Section 3. Create only the missing destination parent directory for the test file. Do not copy `.opencode`, update/version paths, the whole `lib` tree, or the whole `test` tree.

Immediately inspect:

```powershell
git status --short --untracked-files=all
git diff -- lib/topics/modmat/modmat_module_registry.dart lib/topics/modmat/modmat_picker_screen.dart lib/topics/modmat/midterm/modmat_foundations_screen.dart lib/topics/modmat/midterm/modmat_advanced_screen.dart
```

The worktree may show only approved imported Modern Math differences. Any unrelated path is removed from the isolated contribution without touching the dirty root. If the source files have materially drifted from the architecture in this plan, stop for plan review rather than guessing.

## 8. Task F1 — One frontend TDD workstream

**Owner:** Frontend Implementer
**Files:** exactly the five owned paths in Section 3
**Depends on:** W0
**Parallelism:** none

### 8.1 Baseline observation (no product edit)

- [ ] Read all five owned files and `lib/app_router.dart` completely.
- [ ] Run the existing focused test and changed-scope analyzer only to establish the imported baseline; do not run a build.
- [ ] Record the known baseline: historical focused analysis had zero errors/warnings and 16 `prefer_const_constructors` info diagnostics in Modern Math, plus a non-failing LF/CRLF Git warning. Fresh output controls if it differs.

Commands:

```powershell
flutter test test/topics/modmat/modmat_picker_screen_test.dart
flutter analyze --no-fatal-infos lib/topics/modmat/modmat_module_registry.dart lib/topics/modmat/modmat_picker_screen.dart lib/topics/modmat/midterm/modmat_foundations_screen.dart lib/topics/modmat/midterm/modmat_advanced_screen.dart test/topics/modmat/modmat_picker_screen_test.dart
git diff --check
```

Expected baseline: the imported synthetic-router test may pass; that pass is historical behavior, not acceptance of its false route model.

### 8.2 RED A — encode the data contract first

- [ ] Replace test imports/usages of shared `ModuleEntry` with the planned local types.
- [ ] Add a `Modmat catalogue registry` group that asserts the exact enum values/routes, preserved item counts/order/content, search behavior, section enum on each hit, and future entries from both mutable catalogue lists.
- [ ] The future-entry test must add a route-free `ModmatCatalogueItem`, register cleanup with `addTearDown`, and assert that its hit inherits only the owning `ModmatSection`.

Representative required assertions:

```dart
expect(ModmatSection.values, [
  ModmatSection.foundations,
  ModmatSection.advanced,
]);
expect(
  ModmatSection.values.map((section) => section.route),
  [
    '/topics/modmat/foundations',
    '/topics/modmat/advanced',
  ],
);

const futureItem = ModmatCatalogueItem(
  label: 'Future Foundation',
  subtitle: 'Temporary registry coverage',
  icon: Icons.add_rounded,
  accent: Colors.teal,
);
ModmatModuleRegistry.foundationsCatalogue.add(futureItem);
addTearDown(
  () => ModmatModuleRegistry.foundationsCatalogue.remove(futureItem),
);
final hit = ModmatModuleRegistry.search('temporary registry coverage').single;
expect(hit.item, same(futureItem));
expect(hit.section, ModmatSection.foundations);
```

- [ ] Run RED A:

```powershell
flutter test test/topics/modmat/modmat_picker_screen_test.dart --plain-name "Modmat catalogue registry"
```

Expected RED: compilation/test failure because `ModmatSection`, `ModmatCatalogueItem`, and the route-free catalogue API do not yet exist. A pass means the test does not distinguish the invalid model and must be corrected before production edits.

### 8.3 GREEN A — make invalid leaf route data unrepresentable

- [ ] Implement the exact types and API from Section 4.1.
- [ ] Convert all 14 entries without changing catalogue copy/order/visual metadata.
- [ ] Remove obsolete string section APIs if no owned caller needs them; all owned callers use `ModmatSection`.
- [ ] Run RED A's command until it passes.
- [ ] Run the no-leaf-route check immediately:

```powershell
rg -n "/(?:topics/)?modmat/(?:foundations|advanced)/\S+" lib test
```

Expected: exit `1` and no output. Exit `0` means a leaf-style route remains and GREEN A is not complete.

### 8.4 RED B — replace synthetic navigation with production behavior

- [ ] Delete `_buildRouter`, all generated `GoRoute` fixtures, and all `module.route` expectations.
- [ ] Add the production singleton reset strategy from Section 4.4.
- [ ] Add separate tests that search a unique Foundations item and Advanced item, verify the visible action copy, activate it, and assert the corresponding production section screen/disclosure.
- [ ] Add semantics tests for the search field, clear button, top-level section controls, result action, back controls, and static catalogue cards.
- [ ] Add static-card tests proving there is no action semantic or tappable widget associated with catalogue item titles.
- [ ] Parameterize 320 and 1280 logical-pixel checks over light/dark themes for picker results and both section screens; include a larger text scale and require `tester.takeException()` to be null.

Representative production navigation assertions:

```dart
await tester.enterText(
  find.byKey(const Key('modmat-search-field')),
  'Propositional Logic',
);
await tester.pump();
expect(find.text('Open Foundations'), findsOneWidget);
await tester.tap(find.text('Open Foundations'));
await tester.pumpAndSettle();
expect(find.text('Foundations'), findsWidgets);
expect(find.text('Topic content is not available yet.'), findsOneWidget);
```

Repeat with a unique Advanced item and `Open Advanced`. The test harness must use `AppRouter.router`, not another `GoRouter`.

- [ ] Run RED B:

```powershell
flutter test test/topics/modmat/modmat_picker_screen_test.dart
```

Expected RED: failures for explicit section action copy, production navigation, truthful disclosures, and noninteractive section cards. Unexpected crashes or state leakage must be diagnosed before proceeding.

### 8.5 GREEN B — picker and both section screens

- [ ] Update the picker to use `hit.item` and `hit.section` and to route only from the explicit section action.
- [ ] Keep search/clear/no-result behavior and make the top-level section cards proper keyboard/semantic actions.
- [ ] Convert both section screens to route-free catalogue lists and static cards with the exact disclosure copy.
- [ ] Remove false affordances and add accessible back controls.
- [ ] Preserve themes, scrolling, visual hierarchy, and safe disposal.
- [ ] Run focused tests until GREEN.

```powershell
flutter test test/topics/modmat/modmat_picker_screen_test.dart
```

Expected: all tests pass, both production section destinations are exercised, and no test creates or disposes a router.

### 8.6 Refactor only while GREEN

- [ ] Remove unused imports, route-based helpers, duplicated section labels/routes, and obsolete interactive-card state.
- [ ] Do not extract a new shared file; the expected path allowlist is frozen.
- [ ] Run the complete Task F1 verification in Section 9 after every behavior-changing refactor.

## 9. Task T1 — precommit verification and changed-scope debt policy

**Owner:** Precommit Tester
**Writes:** none
**Depends on:** F1

Run from the isolated implementation worktree. No local/manual `flutter build` command is permitted.

### Required commands

```powershell
dart format --output=none --set-exit-if-changed lib/topics/modmat/modmat_module_registry.dart lib/topics/modmat/modmat_picker_screen.dart lib/topics/modmat/midterm/modmat_foundations_screen.dart lib/topics/modmat/midterm/modmat_advanced_screen.dart test/topics/modmat/modmat_picker_screen_test.dart

flutter test test/topics/modmat/modmat_picker_screen_test.dart

flutter analyze --no-fatal-infos lib/topics/modmat/modmat_module_registry.dart lib/topics/modmat/modmat_picker_screen.dart lib/topics/modmat/midterm/modmat_foundations_screen.dart lib/topics/modmat/midterm/modmat_advanced_screen.dart test/topics/modmat/modmat_picker_screen_test.dart

rg -n "/(?:topics/)?modmat/(?:foundations|advanced)/\S+" lib test

git diff --check

$baseSha = git merge-base HEAD origin/main
git diff --exit-code $baseSha -- lib/app_router.dart

git status --short --untracked-files=all
git diff --name-status $baseSha
```

Expected outcomes:

- formatter: exit `0`, zero changed files;
- focused test: exit `0`, all tests pass;
- analyzer: exit `0`, zero errors and zero warnings;
- no-leaf grep: exit `1`, no matches (this is success);
- diff check: exit `0`; an unchanged line-ending notice may be documented but not silently converted across unrelated files;
- AppRouter diff: exit `0`, no output;
- status/diff: only the five owned paths differ.

### Residual baseline formatter/analyzer debt

Repository-wide format/analyzer debt is not part of this correction and must not be “fixed” by broad formatting or unrelated edits.

- The five owned paths are changed scope and must pass the exact formatter check.
- Any analyzer error or warning in changed scope fails the gate.
- Existing info-level diagnostics are compared to the baseline observation. The change must not increase the count or add an info diagnostic on a newly added/modified line. Prefer resolving owned-path `prefer_const_constructors` findings when the minimal correct code permits it.
- A repository-wide `flutter analyze` may be run only as a read-only observation if the parent requires it. Pre-existing diagnostics outside the five paths are recorded as baseline debt and do not authorize edits. New diagnostics attributable to this contribution fail.
- Do not run repository-wide `dart format`, which could mutate unrelated work if invoked incorrectly.

On failure, report command, exit, expected behavior, actual behavior, and implicated owned path. A clear failure routes directly to F1; a non-obvious failure routes to Debugger before F1. All required commands rerun after any fix.

## 10. Task G1 — strict staging and commit gate

**Owner:** Git Steward
**Depends on:** T1 PASS
**Planning-Agent authorization:** none; this is an execution-phase task only.

Stage only with the explicit allowlist:

```powershell
git add -- lib/topics/modmat/modmat_module_registry.dart lib/topics/modmat/modmat_picker_screen.dart lib/topics/modmat/midterm/modmat_foundations_screen.dart lib/topics/modmat/midterm/modmat_advanced_screen.dart test/topics/modmat/modmat_picker_screen_test.dart
git diff --cached --name-only
git diff --cached --check
git diff --cached
```

The staged path list must be exactly the five paths. Prove exclusions before commit:

```powershell
git diff --cached --name-only -- .opencode
git diff --cached --name-only -- .github/workflows lib/app_router.dart lib/main.dart lib/screens/settings_screen.dart lib/services/update_service.dart pubspec.yaml lib/version.dart web/version.json
```

Both exclusion commands must return no paths. Do not use `git add .`, `git add -A`, wildcard staging, or staging from the dirty source root. Never stage `.opencode/**`, plan-worktree residue, unrelated baseline dirt, build output, or update/version work.

After a normal non-amended contribution commit, record `git rev-parse HEAD`. Rerun the focused test, changed-scope analysis, no-leaf check, and diff check against that exact SHA before review. Any corrective edit uses a new normal commit and invalidates prior test/review results; never amend, rebase, reset, or force-push without explicit authorization.

## 11. Tasks R1/S1 — review and security gates

### Task R1 — code review gate

The Code Reviewer examines the exact committed diff and confirms:

- only the five owned paths changed;
- the enum is the only route map and has exactly two production routes;
- catalogue items are structurally non-routable;
- search behavior preserved without duplicate lists/indexes;
- visible result actions are truthful section navigation;
- section cards are static and visibly disclose unavailable content;
- tests use and reset `AppRouter.router` without disposal or synthetic routes;
- accessibility, responsive/theme, and lifecycle requirements are covered;
- no update/version work was reverted or staged;
- all AC1-AC10 evidence refers to the reviewed commit SHA.

Findings return to F1 and invalidate T1/G1/R1/S1 evidence until the full chain reruns.

### Task S1 — security gate

This is a local catalogue/navigation correction with no expected authentication, secrets, network, persistence, dependency, process, file-deserialization, payment, update-integrity, CI/CD, or privileged boundary change. The explicit security gate nevertheless confirms at the exact commit that:

- search text is used only for local string matching and never interpolated into a route;
- navigation uses a closed enum, not user-controlled or registry-controlled path strings;
- no external URL, dynamic URI, redirect, dependency, permission, update, CI, or release behavior changed;
- static cards cannot invoke hidden callbacks.

If the diff remains within the five paths and these statements hold, Security Reviewer returns `APPROVED`/“no sensitive boundary introduced.” Any scope drift to dependencies, router configuration, redirects, external URLs, update logic, CI, or permissions stops the plan for architecture review; it is not repaired under this path allowlist.

## 12. Tasks P1/C1 — implementation PR and GitHub Actions build gate

After T1/G1/R1/S1 pass for one exact commit, the PR Coordinator may push that commit and open the implementation PR. Push/PR creation are not authorized to the Planning Agent and must follow the parent workflow's approval rules.

### User override: no local/manual build

Do **not** run any local `flutter build` command. Build verification must be a safe GitHub Actions check associated with the exact implementation PR head and observed using `gh`:

```powershell
$headSha = git rev-parse HEAD
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($headSha)) {
  throw 'Unable to resolve the reviewed local HEAD SHA; stop before checking Actions.'
}

$prNumber = $env:MATHCALCU_IMPLEMENTATION_PR_NUMBER
if ([string]::IsNullOrWhiteSpace($prNumber) -or $prNumber -notmatch '^\d+$') {
  throw 'MATHCALCU_IMPLEMENTATION_PR_NUMBER must contain the opened implementation PR number; do not guess one.'
}

$pr = gh pr view $prNumber --json number,headRefName,headRefOid,url | ConvertFrom-Json
if ($LASTEXITCODE -ne 0 -or $null -eq $pr) {
  throw "Unable to read implementation PR #$prNumber; stop before checking Actions."
}
if ($pr.headRefName -ne 'feat/modern-math-section-navigation' -or $pr.headRefOid -ne $headSha) {
  throw "Implementation PR #$($pr.number) does not point to the reviewed local HEAD $headSha; stop."
}

gh pr checks $pr.number --watch --interval 10
if ($LASTEXITCODE -ne 0) {
  throw "PR checks for #$($pr.number) did not succeed; inspect only safe PR-check logs before deciding whether C1 is blocked."
}

gh run list --branch feat/modern-math-section-navigation --commit $headSha --event pull_request --limit 20 --json databaseId,workflowName,status,conclusion,url

$safeBuildRunId = $env:MATHCALCU_SAFE_BUILD_RUN_ID
if ([string]::IsNullOrWhiteSpace($safeBuildRunId) -or $safeBuildRunId -notmatch '^\d+$') {
  throw 'MATHCALCU_SAFE_BUILD_RUN_ID must identify an already-observed safe PR-only build run for this exact HEAD; do not guess or dispatch a workflow.'
}

$safeBuildRun = gh run view $safeBuildRunId --json databaseId,headSha,event,status,conclusion,jobs,url,workflowName | ConvertFrom-Json
if ($LASTEXITCODE -ne 0 -or $null -eq $safeBuildRun) {
  throw "Unable to read safe build run $safeBuildRunId; stop before accepting C1."
}
if ($safeBuildRun.event -ne 'pull_request' -or $safeBuildRun.headSha -ne $headSha) {
  throw "Run $safeBuildRunId is not a pull-request run for reviewed HEAD $headSha; do not use it for C1."
}
if ($safeBuildRun.status -ne 'completed' -or $safeBuildRun.conclusion -ne 'success') {
  throw "Safe PR build run $safeBuildRunId has not succeeded; C1 cannot pass."
}

$verifiedPr = gh pr view $pr.number --json headRefOid | ConvertFrom-Json
if ($LASTEXITCODE -ne 0 -or $null -eq $verifiedPr -or $verifiedPr.headRefOid -ne $headSha) {
  throw "Implementation PR head changed after verification; C1 must be repeated for the new head."
}
```

Acceptance requires `headSha` to equal the local reviewed `$headSha`, a build job to conclude `success`, and no later PR-head change. After the safe-run validation above, use `gh run view $safeBuildRunId --log-failed` only when diagnosis is needed.

Current repository workflows require special caution:

- `android-build.yml` runs on push to `main` and force-updates a tag/releases an APK;
- `web-deploy.yml` runs on push to `main` and deploys Pages;
- `windows-build.yml` runs on release creation or manual dispatch and uploads a release asset.

These are release/deploy workflows, not safe pre-merge PR build checks. Never invoke them merely to satisfy C1. If the PR receives no safe build-only Actions check from repository/organization policy, C1 is `BLOCKED`: do not substitute a local build, dispatch a release workflow, edit workflows in this contribution, merge unverified, or waive the user override. The next action is a separately approved CI-only capability change or another user-approved safe remote build mechanism.

For a transient failure on an already-safe PR-only build run, inspect logs through `gh` and retry only the failed safe run once:

```powershell
$headSha = git rev-parse HEAD
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($headSha)) {
  throw 'Unable to resolve the reviewed local HEAD SHA; do not retry a run.'
}

$safeBuildRunId = $env:MATHCALCU_SAFE_BUILD_RUN_ID
if ([string]::IsNullOrWhiteSpace($safeBuildRunId) -or $safeBuildRunId -notmatch '^\d+$') {
  throw 'MATHCALCU_SAFE_BUILD_RUN_ID must identify the failed safe PR-only build run; do not guess or dispatch a workflow.'
}

$safeBuildRun = gh run view $safeBuildRunId --json headSha,event,status,conclusion,workflowName,url | ConvertFrom-Json
if ($LASTEXITCODE -ne 0 -or $null -eq $safeBuildRun) {
  throw "Unable to read safe build run $safeBuildRunId; do not retry it."
}
if ($safeBuildRun.event -ne 'pull_request' -or $safeBuildRun.headSha -ne $headSha -or $safeBuildRun.status -ne 'completed' -or $safeBuildRun.conclusion -ne 'failure') {
  throw "Run $safeBuildRunId is not a failed pull-request build run for reviewed HEAD $headSha; do not retry it."
}

gh run rerun $safeBuildRunId --failed
if ($LASTEXITCODE -ne 0) {
  throw "Unable to rerun failed safe PR build run $safeBuildRunId; report C1 as RETRY or BLOCKED."
}
gh run watch $safeBuildRunId --exit-status
if ($LASTEXITCODE -ne 0) {
  throw "Retried safe PR build run $safeBuildRunId did not succeed; report C1 as failed or BLOCKED."
}
```

Do not retry release/deploy runs and do not use `gh workflow run` on the three current release/deploy workflows.

## 13. Retry, rollback, and risk controls

| Risk | Control / rollback |
|---|---|
| Dirty combined root loses approved update/version work | Never mutate or Git-operate destructively on the root. Copy only five owned files into an external worktree. Verify root status after handoff. |
| Synthetic test keeps validating fiction | Delete the custom router entirely; import the production `AppRouter`; source review rejects any `GoRouter(` construction in the focused test. |
| Static router leaks state between tests | Reset before each pump, unmount after each case, return to `/`, and never dispose the singleton. Retry once after correcting test isolation, not by random pumping delays. |
| New leaf route appears as a shortcut | No-leaf `rg` source scan, AppRouter no-diff check, exact path allowlist, and reviewer rejection. Stop and replan if a real leaf page is later requested. |
| Catalogue UI still implies content exists | Exact disclosure copy, `Catalogue only` visible status, no action semantics/callback/arrow, and semantics tests. |
| Responsive or theme regression | 320/1280, light/dark, larger-text widget matrix; any exception returns to F1. |
| Existing info/line-ending debt obscures regression | Capture baseline, gate changed scope, forbid broad formatting/line-ending churn, and compare new diagnostics to baseline. |
| Unexpected test/analyzer tool failure | Retry the same nonmutating command once if clearly transient. Dependency/cache/infrastructure failures are `RETRY`/`BLOCKED`, not permission to edit product behavior. |
| A post-commit fix invalidates evidence | Add a normal corrective commit; rerun T1, exact-SHA review/security, and C1. No amend/reset/force-push. |
| Need to abandon an uncommitted experiment | In the isolated worktree only, inspect/save the owned diff, then restore only the specifically approved owned file. The dirty root remains the preservation copy. Never clean/stash/reset the root. |
| GitHub build capability is absent | Stop at C1 and request a separate CI-only decision. Never run a local build or trigger release/deploy workflows. |

## 14. Acceptance mapping

| Acceptance | Implementation evidence | Test/check evidence | Gate |
|---|---|---|---|
| AC1 | Route-free `ModmatCatalogueItem` | Type-based tests + no-leaf `rg` source scan | F1, T1, R1 |
| AC2 | Closed `ModmatSection` route map | Exact enum/value/route assertions | F1, T1 |
| AC3 | Derived search over both catalogue lists | Registry unit matrix and future-entry cleanup tests | F1, T1 |
| AC4 | Explicit section button per result | Widget copy, semantics, tap, keyboard tests | F1, T1, R1 |
| AC5 | Existing section destinations only | Production `AppRouter` Foundations/Advanced navigation tests | F1, T1 |
| AC6 | Static truthful catalogue screens | Disclosure/card/absence-of-action tests | F1, T1, R1 |
| AC7 | Accessible controls and informational cards | Semantics flags/labels, keyboard, target-size assertions | F1, T1 |
| AC8 | Responsive and themed UI | 320/1280 × light/dark × larger-text matrix | F1, T1 |
| AC9 | Strict scope preservation | AppRouter no-diff, status/name-status, staging exclusions | W0, T1, G1, R1 |
| AC10 | Changed-scope engineering quality | formatter, focused test, analyzer, diff/source checks | T1 |
| AC11 | Remote build for exact SHA | `gh pr checks`, `gh run view` exact head/success | C1 |

## 15. Exit gates

The implementation is ready for a merge decision only when all are true:

- [ ] Plan PR is approved/merged or the user explicitly approved a stacked base.
- [ ] Dirty source checkout remains preserved.
- [ ] One frontend workstream changed exactly the five owned paths.
- [ ] TDD RED A and RED B were observed before corresponding production GREEN work.
- [ ] Focused tests pass using production `AppRouter` with singleton reset.
- [ ] Changed-scope formatter/analyzer and diff checks pass.
- [ ] No leaf route string exists and `lib/app_router.dart` is unchanged.
- [ ] Staged diff contains exactly the five owned paths and excludes `.opencode/**` and unrelated baseline work.
- [ ] Code review and security gate approve the exact committed SHA.
- [ ] A safe GitHub Actions build succeeds for the exact PR head and is verified only with `gh`.
- [ ] Readiness Auditor maps evidence to AC1-AC11.
- [ ] No merge, tag, release, deployment, or release-workflow dispatch occurred without its separate explicit user gate.

## 16. Plan PR body draft

```markdown
## Summary

- make Modern Math catalogue items structurally non-routable
- map search results to the existing Foundations/Advanced section routes only
- require explicit section actions, static catalogue cards, truthful unavailable-content disclosure, and production-router tests

## Why

The current registry invents leaf topic routes and the focused tests manufacture matching synthetic routes, but production `AppRouter` has only the picker plus Foundations and Advanced section routes. The approved product decision is section navigation; no new topic pages or routes are part of this change.

## Supersession boundary

This plan supersedes only SPEC v01 / PLAN v03 clauses that require direct topic-route navigation. All approved update-status, startup/Settings, version `1.12.8+8`, stale-version-source removal, failure, lifecycle, and shipping-gate work remains unchanged.

## Implementation scope

- `lib/topics/modmat/modmat_module_registry.dart`
- `lib/topics/modmat/modmat_picker_screen.dart`
- `lib/topics/modmat/midterm/modmat_foundations_screen.dart`
- `lib/topics/modmat/midterm/modmat_advanced_screen.dart`
- `test/topics/modmat/modmat_picker_screen_test.dart`

`lib/app_router.dart`, `.opencode/**`, `.github/workflows/**`, and unrelated dirty update/version work are excluded.

## Workstream checklist

- [ ] Plan approval/merge gate
- [ ] External isolated implementation worktree created
- [ ] Five-path dirty Modern Math snapshot transferred; root preserved
- [ ] RED registry contract tests
- [ ] GREEN route-free catalogue model
- [ ] RED production-router/disclosure/accessibility tests
- [ ] GREEN picker and static section screens
- [ ] Focused format/test/analyze/no-leaf/AppRouter checks
- [ ] Exact allowlist staging; `.opencode/**` and unrelated baseline excluded
- [ ] Exact-SHA code review and security gate
- [ ] Implementation PR
- [ ] Safe GitHub Actions build verified with `gh` only
- [ ] Readiness handoff; separate merge/release approval retained

## Verification policy

No local/manual `flutter build` is permitted. Local gates are changed-scope format, focused Flutter tests, changed-scope analysis, source/diff checks, and review. Build verification must come from a safe GitHub Actions check for the exact PR head and be inspected with `gh`. Existing main/release workflows must not be dispatched as pre-merge checks.

## Risks

- current main checkout is intentionally dirty and must not be cleaned, stashed, reset, or broadly staged
- current repository workflows build and then release/deploy; absence of a safe PR build check blocks the build gate rather than authorizing a local build or release workflow
- any need for a new page, route, redirect, dependency, or CI edit requires a new architecture decision
```

## 17. Workstream execution checklist

### Plan contribution

- [ ] Copy only this document into the Plan PR worktree.
- [ ] Stage/inspect only `docs/plans/mathcalcu-modern-math-section-navigation.md`.
- [ ] Obtain Plan PR approval and merge authorization.

### Contribution setup

- [ ] Detect existing isolation; create one external implementation worktree if needed.
- [ ] Record base SHA and branch.
- [ ] Copy only the five owned files from the dirty root.
- [ ] Confirm no `.opencode`, update/version, workflow, or other path entered the worktree diff.

### Frontend TDD

- [ ] Observe baseline focused test/analyzer output.
- [ ] RED A: route-free model and exact section map tests fail for the right reason.
- [ ] GREEN A: local catalogue model and derived search pass; no leaf source remains.
- [ ] RED B: production-router/action/disclosure/semantics/responsive tests fail for the right reason.
- [ ] GREEN B: picker and both static section screens pass.
- [ ] Refactor only while GREEN and within the five paths.

### Gates

- [ ] T1 changed-scope format/test/analyze/source/diff checks pass.
- [ ] G1 exact five-path staging and exclusions pass.
- [ ] Post-commit checks bind to exact SHA.
- [ ] R1 code review and S1 security gate approve exact SHA.
- [ ] P1 opens implementation PR from exact reviewed commit.
- [ ] C1 safe Actions build succeeds for exact PR head through `gh`; otherwise report `BLOCKED`.
- [ ] E1 acceptance mapping is complete.
- [ ] Await explicit merge/release choice.

## 18. Planning self-review

- **Requirements coverage:** AC1-AC11 map every frozen architecture, navigation, truthfulness, test, accessibility, responsive/theme, scope, build, and preservation requirement to an owner and gate.
- **File consistency:** all implementation edits are confined to the same five paths; `AppRouter` is referenced by tests but never owned or modified.
- **Dependency consistency:** one frontend writer completes all mutually coupled edits before independent test/review/staging/CI gates.
- **No placeholders:** route values, UI disclosure copy, actions, commands, expected exits, failure routing, and CI absence behavior are explicit.
- **Historical preservation:** only invalid direct-topic-route clauses are superseded; update/version work and shipping gates remain approved and untouched.
