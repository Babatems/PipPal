# 02 · Design system

Sources: `claude/README.md` (Design tokens), `claude/PipPal Foundations.dc.html` (live component sheet, every state), spec §3–6, §9–11.
Values here are final and high-fidelity. If something isn't listed, inspect the Foundations or Screens HTML.

## Colour tokens
| Token | Light | Dark | Use |
|---|---|---|---|
| background | `#F5F1E8` | `#1E1E1B` | App ground (never pure black in dark mode) |
| surface | `#FFFFFF` | `#2D2D2A` | Cards, sheets, bars, inputs |
| surface2 | `#E5DCC5` | `#3A3A36` | Chips, inactive segments, avatar fill, empty calendar cells |
| border | `#E0D9C5` | `#3D3D39` | 1px card/field borders |
| divider (inner) | `#F0EBDD` | `#353531` | Row separators inside cards |
| textPrimary | `#2D2D2A` | `#E5DCC5` | Headings, values |
| textSecondary | `#4C4C47` | `#B5AE99` | Body, descriptions |
| textMuted / accent (Slate) | `#848FA5` | `#A0ADBE` | Captions **≤13px only** (3.9:1, fails AA for body); focus ring; today ring |
| navIdle | `#5E5E57` | `#A9A390` | Tab-bar idle icon and label (solid, never alpha) |
| brandCrimson | `#C14953` | `#E5717A` | Primary CTA, FAB, loss |
| crimsonText | `#A03B44` | `#E5717A` | Crimson text on tints/glass, active tab ink, error text |
| profit | `#2A9D5C` | `#4DBF7F` | Profit values, BUY, logo candle |
| profitText | `#1F7A46` | `#4DBF7F` | Green text on green tints (calendar cells, tags) |
| warning / break-even | `#D4854A` | `#E8A06B` | Break-even, "Incomplete", pending |
| warningText | `#A9622F` | `#E8A06B` | Amber text on tints |
| destructive | `#9B2226` | — | Delete only, always paired with Cancel |
| skeleton | `#D4CDB9` | `#2D2D2A` → shimmer `#3A3A36` | Shimmer base (spec §6.5) |
| calendar future/blank | `#EDE7D6` bg, `#B8B0A0` text | — | Lead-in blanks and future days |

Dark values for divider, navIdle and the *Text tokens come from design decision D22 (`08-open-questions.md`).

**Tints:** profit/loss/amber backgrounds use the base colour at **10–12%** for cards and tags, or **25%** for calendar cells (break-even cell: amber 20%). Sheet scrim: `rgba(45,45,42,.35)`.

**P&L colour rules:** profit = emerald, loss = crimson, break-even (0.00) = amber. **Never use colour alone.** Always pair it with a sign (+/−), an arrow or a label.

**User-overridable:** profit and loss colours are customisable in Settings (live preview, "Reset to defaults", no custom hex). There are 8 presets [D20]: Profit `#2A9D5C` (default) `#1F7A46` `#3B8EA5` `#2D7D6E`; Loss `#C14953` (default) `#9B2226` `#B4553F` `#8E4B6B`. Implement them as a `ThemeExtension` (e.g. `PnlColors`) so every P&L widget reads from the theme.

## Typography: Inter, tabular figures on every number
| Style | Size/Line | Weight | Use |
|---|---|---|---|
| displayLarge | 32/38 | 700, −2% tracking | Hero equity figure, Trade Detail net P&L |
| displayMedium | 26/32 | 600 | Metric card values; auth screen titles |
| headlineLarge | 22/28 | 600 | Screen titles |
| headlineMedium | 20/26 | 600 | Section headers, month label |
| headlineSmall | 18/24 | 500 | Sheet titles |
| titleMedium | 16/22 | 500 | List primaries (instrument) |
| bodyLarge | 15/22 | 400 | Notes, field values |
| bodyMedium | 14/20 | 400 | Secondary body |
| bodySmall | 13/18 | 400 | Helper, labels |
| labelLarge | 12/16 | 500 | Tags |
| labelSmall | 11/14 | 400 | Timestamps, CAPS labels (+6–12% tracking) |
| tabLabel | 10/12 | 500 idle / 600 active | Bottom tab bar only |

Rules:
- Use `fontFeatures: [FontFeature.tabularFigures()]` on every price, P&L, pip, %, R, count, date and time. Consider a `num` text-style helper so this can't be forgotten.
- Never use bold below 13px.
- Always set line heights explicitly (`height = line / size`).
- Right- or centre-align numbers in tables; never left-align them.
- Keep descriptive text to a max line length of about 60 characters.
- Use the minus sign `−` (U+2212), not a hyphen, for negative amounts (as in the designs: `−$48.00`).
- Support Dynamic Type and font scaling up to 1.5×. Never truncate primary financial values.

## Spacing: 4pt base
`4, 8, 12, 16, 20, 24, 32, 40, 48, 64` (spec also has a 2px micro step).
- **16**: phone screen padding and card padding
- **24**: between sections; auth screen side padding
- **32**: iPad screen padding
- **12**: card gutter in grids

## Radius
Tags 6 · chips 8 · segmented 10 (inner 8) · **cards, fields, buttons 12** · sheets 16 (top corners) · dialogs **16** [D26] · onboarding art stage 28 · tab-bar pill 32 · FAB and avatars fully round.

## Elevation
No shadows on cards; a **1px border** carries elevation. Shadows appear only on:
- Sheets/modals: `0 -4px 24px rgba(0,0,0,.10)`
- FAB/primary centre button: `0 6px 16px -8px rgba(193,73,83,.6)`
- Glass tab bar: see `04-navigation-and-flows.md`

## Component specs (summary; full states in Foundations)
| Component | Spec |
|---|---|
| Primary button (regular) | Crimson fill, white **15/500** label, **48pt**, radius 12, label left-aligned (padding 0 20), **no arrow**. Pressed: scale 0.97 + `#AE414A` (destructive `#851C20`). Disabled: 40% opacity. Hug-width variant (empty-state CTAs) centres the label with padding 0 24. Source: Foundations › Buttons |
| Primary button (large) | Auth/form submit CTAs only (Continue, Sign in, Create account): **52pt**, **16/600**, trailing arrow, padding 0 18 0 20. Loading: spinner in place of the arrow, label e.g. "Signing in" |
| Secondary button | 48pt, **1.5pt** crimson border, crimson 15/500 label, surface fill, left-aligned. Pressed: crimson 8% fill |
| Ghost button | Text only, 48pt, 15/500. Pressed: slate 8% tint. The design uses Slate text; we use textSecondary because Slate fails AA at 15px |
| Destructive | `#9B2226` fill, only inside a confirmation and always paired with Cancel |
| Icon button | 40×40 circle, 20px icon; cream bg on press |
| Focus ring | 2px `#848FA5`, offset 2 |
| Auth field | 13pt/500 label above, **52pt** field, radius 12, 1px border. Focused: 1.5px ink + `0 0 0 4px rgba(45,45,42,.07)`. Error: 1.5px crimson + 4px crimson-10% ring + error line with icon in `#A03B44` |
| Number input | Right-aligned, tabular, numeric keyboard. Prices to instrument precision; pips to 1 dp |
| Textarea (notes) | Min 100dp, grows, `n / 500` counter |
| Search bar | Off-white bg, radius 12, search icon left, clear icon right. Placeholder "Search instrument, notes…" |
| Toggle | iOS style. Off: border-colour track. On: crimson track |
| Segmented | Radius 10, inner 8. BUY active = emerald, SELL active = crimson |
| Tag | 24dp tall, radius 6, **12/500**, padding 0 10. BUY = emerald 12% + `profitText`, SELL = crimson 12% + `crimsonText`, neutral = cream + textSecondary, outline = 1px border, Incomplete/pending = amber 14% + `warningText` |
| Date-range / filter chip | 32dp tall, radius 8, **13/500**, padding 0 12. Active: crimson 12% + crimson text. Inactive: cream + textSecondary |
| Instrument chip (Quick log) | 36dp, radius 8, 14/500, padding 0 13. Selected: crimson fill + white. "Other…" = 1px dashed `#D8CFB8` border + slate text |
| App bar | **White 56pt bar with a 1px bottom border**, 16pt side padding, title 22/600; the status-bar area above shows the ground colour. Sub-bars (filter chips, month nav, summary strip) are further white rows, each with a 1px top divider |
| Segmented | Cream track radius 10 / padding 3, segments radius 8 (44pt tall in forms; 30pt compact variant radius 8/6 for units). BUY active = emerald fill + white, SELL = crimson fill + white, neutral active = white thumb |
| Metric card | 2-col grid, ~88dp tall. CAPS label (labelSmall, slate), value (displayMedium), delta row (arrow + %) |
| Trade list card | Full width, ~80dp. Instrument + BUY/SELL tag; P&L on the right (coloured); entry → exit; pips/shares; plan mark · time · R. Swipe right = edit (slate), swipe left = delete (`#9B2226`, confirm). Reveal areas ≥60dp |
| Calendar cell | Equal width × 52dp. Day number top-left, P&L rounded. Today: 1.5px slate ring and weight 600 |
| Toast | Dark `#2D2D2A` bar, 48pt, radius 12, white text, optional action (e.g. "View") |
| Dialog | White, radius 16, title + body + Cancel/Primary. E.g. "Discard this trade?" / "Your entry has unsaved details. This cannot be undone." / Discard · Keep editing |
| Error banner | Inline, crimson text + warning icon |
| Skeleton | Shimmer that matches the card shapes, staggered |
| Empty state | Illustration placeholder (dashed box, awaiting art), 1–2 lines, optional CTA |
| Sheet handle | 36×4 grey pill, 8dp top margin |
| Settings rows | Grouped iOS-style cards, CAPS slate section label. "Coming soon" rows at 45% opacity |
| Provisional tag | Shown on analytics metrics while the trade count is 5–29 [D14]; amber-tag style (working assumption) |
| Coverage note | "Based on N of M trades", labelSmall muted, under any metric that excluded trades [D13] |

## Motion (spec §9; still applies unless designs say otherwise)
| Animation | Duration | Curve |
|---|---|---|
| Screen push / pop | 300 / 280ms | easeInOutCubic |
| Tab switch | 200ms | Material fade-through |
| Bottom sheet up / dismiss | 380ms spring (mass 0.8, stiffness 300) / 280ms easeInCubic | |
| Toast / overlay fade | 200 in / 150 out | easeOut |
| Button press | 80ms to 0.97× | easeOut |
| Equity curve draw-in | 1200ms left→right, fill fades in alongside | easeOut |
| Metric count-up | 800ms, cards staggered 80ms | |
| Dashboard skeleton stagger | chart 200ms, metric cards 50ms each, then list | |
| Calendar month change | 300ms slide, cells fade with 20ms stagger | spring |
| Donut / bars (analytics) | 1000ms clockwise from 12 o'clock / 800ms grow, staggered | |
| Onboarding illustration entrance | 0.92→1.0 scale, 300ms | |
| Splash | see `06-assets.md` | |

All animation should guide focus or confirm an action, never show off. Respect reduce-motion.

## Haptics (spec §9.3)
Tab tap: light · trade saved: success · trade deleted: heavy · swipe reveal: selection · validation error: error · calendar month swipe: light · toggle: selection.

## Accessibility
- Touch targets: 48dp minimum (tab icons get 48dp hit areas even when smaller).
- P&L semantics labels need full context, e.g. "Profit: 96 dollars. EUR/USD trade, July 14".
- Icon-only buttons need labels ("Filter trades").
- Announce form errors to screen readers immediately.
- Check contrast against the actual surface. That's why crimsonText, profitText, warningText and navIdle exist.
