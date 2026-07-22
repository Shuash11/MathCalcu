# Modern Math Section Navigation — UX Contract

**Authority:** approved parent Plan PR [#58](https://github.com/Shuash11/MathCalcu/pull/58). This contract freezes visual and interaction requirements only; it does not authorize new topic pages, leaf routes, or unrelated UI changes.

## Intent and scope

Modern Math is a two-section catalogue. A search result identifies a catalogue topic but can open only its owning existing **Foundations** or **Advanced** screen. The destination screens truthfully present unavailable topic content as static catalogue entries.

Retain the existing MODMAT visual language: teal section identity, rounded outlined cards, current iconography, typography scale, scroll layout, and staggered fade/slide entrance. Do not introduce a new page layout, grid, filter, result count, destination, toast, modal, or “coming soon” workflow.

## Picker contract

### Search field

- Keep the existing search location, search icon, clear icon, placeholder **“Search Modern Math topics”**, and local filtering behavior.
- The control is always visible, including when there are no matches.
- Whitespace-only input is a valid empty query: it displays the default Foundations and Advanced section cards, not an error or empty state.
- A non-empty query shows **“Search results”** and the matching cards in existing Foundations-then-Advanced registry order.
- Clear is visible only for a non-empty trimmed query. Its accessible name and tooltip are **“Clear search”**. Clearing restores the default section cards and returns focus to the search field.
- Search is local and synchronous. Do not introduce a loading spinner/skeleton, success toast, query-validation error, network/offline error, or asynchronous retry state.

### Actionable search-result card

Each result is an informational catalogue summary plus exactly one explicit section action:

1. topic icon, title, and subtitle;
2. visible section context pill: **“Foundations”** or **“Advanced”**;
3. one visible text action: **“Open Foundations”** or **“Open Advanced”**.

The action, rather than the card body, is the only navigation affordance. Remove the trailing chevron from search results. A result must never imply that it opens a topic page.

| State | Required treatment |
| --- | --- |
| Default | The card uses the existing card surface, outline, icon treatment, title/subtitle hierarchy, and section accent. The explicit action is clearly legible and has a 48 × 48 logical-pixel minimum hit target. |
| Hover (pointer) | Only the explicit action receives the existing restrained accent-tint/outline feedback; its pointer is clickable. The informational card body does not behave as a link. |
| Focus-visible | Keyboard focus lands on the explicit action, with a clearly visible accent focus outline/ring that is not communicated by colour alone. It must remain visible in light and dark themes. |
| Pressed | Only the explicit action may use the established short pressed feedback (subtle tint and/or scale); it must not move surrounding content or reduce legibility. |
| Disabled/error | There is no disabled or error variant in this local route flow. If the owning section is represented in the closed section map, the action is available; do not render a dead control or fabricate a navigation-failure message. |

The action has button semantics. Its semantic label includes the item and destination, for example: **“Open Foundations section for Propositional Logic”**. Enter and Space activate it. Card title/subtitle/context remain readable as static result content and are not a second button/link target.

### Default section-navigation cards

The picker’s two top-level Foundations/Advanced cards remain section-navigation controls. Convert their interaction to a keyboard-operable Material button/action with a visible focus treatment, button semantics, tooltip/semantic destination label, and a 48 × 48 logical-pixel target. Their existing chevron remains appropriate because these two cards do navigate. Preserve their existing hover/pressed animation and route only to their existing section screen.

## Foundations and Advanced catalogue contract

Both section screens must disclose, before the list:

- title: **“Topic catalogue”**
- message: **“Topic content is not available yet.”**

Replace the header count phrasing **“topics available”** with truthful catalogue phrasing, e.g. **“8 catalogue topics”** / **“6 catalogue topics”**. Keep the MODMAT banner, section icon, section-specific teal accent, header hierarchy, scroll position behavior, and list entrance animation.

### Static catalogue card

Every topic card remains visually aligned with the current card system but is inert content:

- Keep the topic icon, title, subtitle, section-specific accent, 20 px outer card radius, and fade/slide entrance animation.
- Add a visible status pill: **“Catalogue only”**.
- Remove the chevron, tap callback, click cursor, hover state, pressed scale, hover glow, focus target, button/link semantics, and any hidden tap semantics.
- Assistive technology reads the title, subtitle, and **“Catalogue only”** as informational content; it must not announce the card as a button, link, or actionable item.
- Pointer hover leaves the card unchanged. Tab navigation skips it. Enter/Space does nothing when the reading cursor is on its informational content.

The back affordance is separate from catalogue cards: it is a labelled, tooltip-supported, keyboard-operable button with a 48 × 48 logical-pixel target. Keep its familiar icon treatment and route back to the picker.

## Responsive and theme requirements

| Context | Frozen behaviour |
| --- | --- |
| **320 logical px** | Preserve the one-column scroll layout and the existing 20 px list/search gutters. Avoid header overflow: title text may use the available width beside/below the icon rather than clip. Search-result metadata stays legible; place the explicit Open action on its own full-width row beneath topic information when a horizontal layout would crowd, wrap, or reduce its 48 px target. Static catalogue cards retain icon/title/subtitle/status without a trailing affordance. |
| **1280 logical px** | Preserve the existing single-column, full-width scroll hierarchy; do not introduce a grid or redesign the page. Search result information and the explicit Open action may share one row when comfortably available; the action remains visually subordinate to topic title and cannot compress essential copy. |
| **Large text** | Text must wrap or reflow inside cards and banners without clipping, overlap, or Flutter overflow. Never solve large-text pressure by reducing the user’s text scale, truncating the required disclosure, or shrinking controls below 48 px. |
| **Light theme** | Use existing `ThemeProvider` surface/card/text tokens plus the established teal accents and alpha treatments. Preserve existing contrast and outlined-card hierarchy. |
| **Dark theme** | Use the same semantic surface/card/text tokens rather than a hard-coded white card surface. Retain the section accent distinction and provide a visible non-colour-only focus indicator. Do not add a second accent palette. |

### Preserved visual measurements

Use existing values rather than introducing a new scale:

- outer content gutter: 20 px for banner, search, and list; header keeps its existing 28 px alignment;
- card separation: 16 px for catalogue/section cards and 12 px for search results;
- search field: 12 px radius; banners: 14 px radius; primary cards: 20 px radius; icon tiles: 14–16 px radius; status/context pills: existing pill radius (12 px or full pill treatment);
- card padding and icon sizing retain the current responsive proportions (22 px and 56 px at the 400 px reference width), except where the 320 px reflow needs the result action beneath the metadata;
- retain existing title/subtitle weights, letter spacing, and restrained teal shadows. Do not add gradients, alternate typefaces, badges beyond section context / Catalogue only, or new decorative animation.

## Empty, validation, success, and error states

| State | Required experience |
| --- | --- |
| Initial / cleared / whitespace-only query | Search is empty; show the two interactive section-navigation cards and no results heading. |
| Matching query | Show the matching result cards and explicit section actions. No result is a direct topic destination. |
| No results | Keep the query and search control visible. Announce the change through a live region and show: icon, **“No topics found”**, **“Try another title or subtitle.”**, and **“Clear search”** action. Clear restores the default cards and focuses search. |
| Search validation | None. Any text is acceptable local search input; whitespace is treated as empty rather than invalid. |
| Successful navigation | Activating Open Foundations/Open Advanced replaces the picker with the corresponding existing section screen and its catalogue disclosure. Do not show a success message. |
| Navigation/content error | No separate error UI is in scope because the closed two-value section map only exposes production routes. Do not add a fake topic screen, fallback route, unavailable-content dialog, or error toast. The truthful section disclosure is the product state. |

## UX acceptance checks

1. Searching a unique Foundations item exposes only one **Open Foundations** action; keyboard Enter/Space on that action opens the existing Foundations screen.
2. Searching a unique Advanced item exposes only one **Open Advanced** action; it opens the existing Advanced screen.
3. Result cards show title, subtitle, section context, and explicit action. They contain no chevron, whole-card link, leaf-route affordance, or duplicate action semantics.
4. The result action has an accessible label containing both its destination and item name, is visibly focusable in light/dark themes, accepts pointer/keyboard activation, and meets 48 × 48 logical-pixel minimum size.
5. Picker section cards remain the only whole-card navigation controls; they support keyboard focus/activation and preserve their current motion language.
6. Foundations and Advanced each display the exact disclosure strings **“Topic catalogue”** and **“Topic content is not available yet.”**, plus truthful catalogue-count wording.
7. Every section topic card visibly says **“Catalogue only”**, has no chevron/click cursor/hover or pressed response/focus stop, and is not exposed as a button or link in semantics.
8. Search clears via icon or no-results action, restores default cards, and returns focus to the search input. Whitespace-only search behaves identically to cleared search.
9. No-results state remains announced as a live update and retains the exact title, supporting copy, and clear action.
10. At 320 and 1280 logical px, light and dark themes, and larger text scale, picker results and both catalogue screens show no clipping, overlap, unreadable contrast, or exception/overflow; controls remain usable and disclosures remain visible.
11. The only scope-visible visual changes are explicit section actions, truthful catalogue disclosure/status, removal of false topic-navigation affordances, and necessary accessibility/responsive refinements. Existing MODMAT branding, typography, animation, card hierarchy, and scroll layout remain recognizably intact.
