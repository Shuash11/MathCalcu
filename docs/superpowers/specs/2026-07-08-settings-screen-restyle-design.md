# Settings Screen Restyle

## Goal
Restyle the Settings screen to match the Home screen header's visual design language (circular icon containers, card backgrounds, purple accent) while keeping the existing structure and functionality. Add a Website link to the About section.

## Visual Design

### Design Source
The Home screen header has circular icon buttons with:
- Background: `theme.card`
- Shape: `BoxShape.circle`
- Padding: 8 all around
- Icon size: 20, Color: `accent` (#6C63FF purple)

These exact visual properties are reused for every settings row.

### Layout
- Same `ListView` structure with section grouping
- Each row: [circular icon] + [label + subtitle] + [trailing control/arrow]
- Section headers restyled to purple accent (matching Home screen's accent bar feel)
- Cards removed — each row is a direct child of the ListView with padding
- Circular icon containers match Home header exactly (48x48, card background, rounded)

### Sections

#### 1. Theme
- Icon: `dark_mode_rounded` / `light_mode_rounded` (depends on current mode)
- Label: "Dark Mode"
- Trailing: `Switch.adaptive` bound to `ThemeProvider.toggle()`

#### 2. Support
- Icon: `coffee_rounded`
- Label: "Donate"
- Subtitle: "Support the developer"
- Trailing: `arrow_forward_ios_rounded` (60% opacity accent)
- Tap: opens `showDonateSheet(context)`

#### 3. GitHub
- Icon: `code_rounded`
- Label: "Shuash11"
- Subtitle: "View developer profile & repos"
- Trailing: `open_in_new_rounded` (small, accent)
- Tap: opens `https://github.com/Shuash11` via `url_launcher`

#### 4. About (4 rows)

1. **MathCalcu** — icon: `info_outline_rounded`, version as subtitle
2. **Developer** — icon: `person_rounded`, "Joashua Marl Barimbao" as subtitle
3. **Contact** — icon: `email_outlined`, "joashuabarimbao10@gmail.com" as subtitle, tappable → `mailto:` launch
4. **Website** — icon: `language_rounded`, "mathcalc-calculus.netlify.app" as subtitle, tappable → opens `https://mathcalc-calculus.netlify.app/` via `url_launcher`

### Section Headers
- Text in purple accent (#6C63FF)
- Font: 13px, w600, 0.5 letter-spacing
- Aligned with row content

### Color Palette
| Token | Light Mode | Dark Mode |
|-------|-----------|-----------|
| Background (Scaffold) | `theme.surface` | `theme.surface` |
| Row background | `theme.card` | `theme.card` |
| Icon container | `theme.card` | `theme.card` |
| Icon color | `accent` (#6C63FF) | `accent` (#6C63FF) |
| Label | `theme.textPrimary` | `theme.textPrimary` |
| Subtitle | `theme.textSecondary` | `theme.textSecondary` |
| Section header | `accent` | `accent` |

## Files Changed
- `lib/screens/settings_screen.dart` — complete visual restyle, add Website row

## Open Questions
None.
