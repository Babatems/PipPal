# Handoff: PipPal — Trading Journal Mobile App (iOS, Android, iPad)

## Overview
PipPal is a **manual trading journal**. Traders log forex, crypto and stock trades by hand (no broker sync) and review their performance through a dashboard, a P&L calendar, a journal list and analytics. The target user is a disciplined retail or prop-firm-challenge trader who wants a clear record of their progress.

The original product spec is `reference/PipPal UI_X Design Specification.pdf` (its text is in `reference/spec.txt`). Where this README and the HTML designs differ from the spec, **the designs and this README win**, because they include decisions made after the spec was written (listed under "Decisions that override the spec").

## About the design files
The files in this bundle are **design references built in HTML**. They are prototypes that show the intended look and behaviour. They are **not production code to copy**.

Your task is to **recreate these designs in the real app's codebase**. The spec names **Flutter / Dart** for iOS and Android, so use Flutter and its normal patterns (Material 3 theme extensions, `ThemeData`, go_router or similar). If the team has already chosen another stack, use that instead.

To view a design file, open it in a browser. The `.dc.html` files load `support.js` from the same folder, so keep the folder structure intact.

## Fidelity
**High fidelity.** Colours, type, spacing, radii, copy and states are final. Recreate them pixel-accurately using Flutter widgets. Sample data (EUR/USD trades, July 2026 figures) is illustrative only.

---

## Design tokens

### Colour (light mode is primary)
| Token | Light | Dark | Use |
|---|---|---|---|
| background | `#F5F1E8` | `#1E1E1B` | App ground |
| surface | `#FFFFFF` | `#2D2D2A` | Cards, sheets, bars |
| surface2 | `#E5DCC5` | `#3A3A36` | Chips, inactive segments, avatar fill |
| border | `#E0D9C5` | `#3D3D39` | 1px card and field borders |
| divider (inner) | `#F0EBDD` | — | Row separators inside cards |
| textPrimary | `#2D2D2A` | `#E5DCC5` | Headings, values |
| textSecondary | `#4C4C47` | `#B5AE99` | Body, descriptions |
| textMuted | `#848FA5` | `#A0ADBE` | Captions ≤13px only (3.9:1 — fails AA for body) |
| navIdle | `#5E5E57` | — | Tab bar idle icons and labels (solid, never alpha) |
| brandCrimson | `#C14953` | `#E5717A` | Primary CTA, FAB, loss |
| crimsonText | `#A03B44` | — | Crimson text on tints and glass (base crimson is only 3.71:1 there) |
| profit | `#2A9D5C` | `#4DBF7F` | Profit values, BUY, logo candle |
| profitText | `#1F7A46` | — | Profit text on green tints |
| warning / break-even | `#D4854A` | `#E8A06B` | Break-even, "Incomplete" |
| warningText | `#A9622F` | — | Amber text on tints |
| destructive | `#9B2226` | — | Delete only |

Tints: profit/loss/amber backgrounds are the base colour at **10–12%** (cards, tags) or **25–30%** (calendar cells). Scrim behind sheets: `rgba(45,45,42,.35)`.

Users can override the profit and loss colours in Settings (spec §3.4), so read P&L colour from a theme extension, not constants.

### Typography — Inter, **tabular figures on every number**
| Style | Size/Line | Weight | Use |
|---|---|---|---|
| displayLarge | 32/38 | 700, −2% tracking | Hero equity figure |
| displayMedium | 26/32 | 600 | Metric card values, screen titles in auth |
| headlineLarge | 22/28 | 600 | Screen titles |
| headlineMedium | 20/26 | 600 | Section headers |
| headlineSmall | 18/24 | 500 | Sheet titles |
| titleMedium | 16/22 | 500 | List primaries (instrument) |
| bodyLarge | 15/22 | 400 | Notes, field values |
| bodyMedium | 14/20 | 400 | Secondary body |
| bodySmall | 13/18 | 400 | Helper, labels |
| labelLarge | 12/16 | 500 | Tags |
| labelSmall | 11/14 | 400 | Timestamps, caps labels (+6–12% tracking) |
| tabLabel | 10/12 | 500 idle / 600 active | Bottom tab bar |

Set `FontFeature.tabularFigures()` for every price, P&L, pip, count, date and time.

### Spacing — 4pt base
4, 8, 12, **16** (screen padding and card padding on phone), 20, **24** (between sections; auth screen side padding), 32 (iPad padding), 40, 48, 64.

### Radius
Tags 6 · chips 8 · segmented 10 (inner 8) · cards, fields, buttons **12** · sheets 16 top corners · onboarding art stage 28 · tab bar pill 32 · FAB fully round.

### Elevation
No shadows on cards; a **1px border** does the job. Shadows only on: modals/sheets `0 -4px 24px rgba(0,0,0,.10)`, FAB/primary `0 6px 16px -8px rgba(193,73,83,.6)`, glass tab bar (below).

---

## Brand mark (logo 5a)
A geometric "P" whose bowl is followed by a green candlestick. Exact vector, viewBox `30 -1 83 118` (aspect 83:118):

```
stem   path  M32 2 H52 V100 L32 116 Z                         fill #2D2D2A
bowl   path  M52 14 A35 35 0 0 1 52 84 L52 64 A15 15 0 0 0 52 34 Z   fill #2D2D2A
wick   rect  x=98 y=22 w=4 h=54                                fill #2A9D5C
body   rect  x=89 y=34 w=22 h=30                               fill #2A9D5C
```
Dark mode: ink → `#E5DCC5`, candle → `#4DBF7F`. One-colour: everything in ink. Export as SVG and use `flutter_svg`. Full exploration and construction notes are in `PipPal Logo.dc.html` (turn 5, option 5a).

### Splash animation (S01) — 2.0s total, plays once
`Motion Steps.dc.html` / `motion-steps-piece.jsx`. Three scenes, offsets in a 1080 frame:
1. **Stem** (0–0.7s): rises from +172px below to rest. easeOutExpo, 0.04→0.66s.
2. **Bowl** (0.7–1.4s): slides in from +138px right. easeOutQuart, starts 0.1s early, overlaps the stem's settle.
3. **Candle** (1.4–2.0s): opacity 0→1 (easeOutCubic, 0.42s) and rises 10px→0 (0.5s).
Then route to Welcome (signed out) or Dashboard (signed in). A Lottie or Rive file, or Flutter's `AnimationController` with these curves, both work.

---

## Navigation

### Phone — floating glass tab bar (all tab screens)
- Pill **64pt tall**, inset **16pt** left/right, **40pt** above the bottom edge (clears the home indicator). Radius 32. Inner padding 6.
- Glass: `BackdropFilter` blur **24** with saturation 1.8, gradient `rgba(255,255,255,.74)` → `rgba(250,247,240,.56)` top to bottom, 0.5px white border, outer ring `rgba(45,45,42,.08)`, shadow `0 14px 34px -10px rgba(45,45,42,.28)` + `0 2px 6px rgba(45,45,42,.06)`, inner top highlight `rgba(255,255,255,.95)`.
- Five slots: **Dashboard · Journal · [＋] · Calendar · Analytics**. The centre button is a 46pt crimson circle (gradient `#CF5A63`→`#B8404A`) that opens Log Trade.
- Each tab: 24pt icon over a 10pt label. Active tab = **filled version of its own icon** in `#A03B44` inside a 52pt-tall capsule (crimson 14%→8% gradient, 0.5px crimson-18% inner ring). Idle = outline icon + label in solid `#5E5E57`.
- Icons are a custom set on a 24pt grid, 1.75 stroke, round caps/joins: house, notebook (with two text lines), calendar with a "today" dot, three rounded bars. SVG paths are in `PipPal Screens.dc.html`.
- Content **scrolls under** the bar. Give scroll views ≥120pt bottom padding; standalone bottom CTAs sit **70pt** above the bar's top.

### iPad (1366×1024 landscape)
A permanent 248pt left **sidebar** replaces the tab bar: logo, a full-width "Log Trade" primary button, the four destinations (22pt icons, same glyphs, active item filled in `#A03B44` on a crimson-10% row), saved filters, and the user row at the bottom. Journal uses a **two-pane** layout: 420pt list + trade detail filling the rest. Padding 32.

---

## Screens

Phone frame used: **iPhone 16 Pro / 17, 402×874pt**. Screen codes match the spec.

### Sign-up & first run (in flow order)
| Code | Screen | Key details |
|---|---|---|
| S01 | Splash | Animated mark (above), "TRADING JOURNAL" caption, thin crimson progress line |
| S02 | Welcome | Hero, headline "Journal every trade. Trade every insight.", **Create free account** (primary) + **Sign in** (secondary outline) |
| S03 | Sign up | **Continue with Apple** (black) and **Continue with Google** (white, bordered) above "or continue with email"; one Email field; Continue (disabled until valid); terms line; "Already have an account? Sign in". States: default, inline error ("Enter a full email address, like name@example.com.") |
| S03a | Verify email | Six 60pt code boxes; focused box has ink border + 4px soft ring + crimson caret; "Resend code in 0:42"; "Change email"; iOS one-time-code autofill (`AutofillHints.oneTimeCode`) |
| S03b | Set password | Shown **after** the code is verified. Show/hide toggle; 4-segment strength meter; live checklist (8+ chars, number, symbol). Stages: Weak (red) · Fair (amber) · Good (green) · Strong (green) |
| S04 | Sign in | Apple/Google, Email, Password, "Forgot password?", Sign in. States: typing, **loading** (spinner inside button, social buttons dimmed), **wrong credentials** = one banner "Incorrect email or password. Try again." that never highlights a specific field |
| S04a | Forgot password | Email field + "Send reset link" |
| S04b | Check your inbox | Mail icon tile, "expires in 30 minutes", **Open email app**, **Resend link**, "try another email" |
| S05 | Onboarding 1–3 | Skippable. Art is built from real app components on a 392pt rounded stage: (1) a Quick-log card + "Saved to journal · 8s" toast, (2) the July P&L calendar, (3) the equity curve with win rate / avg RR / trades. 3-dot pager (active dot 24pt wide). CTA "Next", last slide "Get started" |
| S06 | Profile setup | Shown once, skippable. Avatar (initials until a photo is added), Display name (pre-filled from Apple/Google), Currency, Demo/Real segmented, Markets traded chips (Forex/Crypto/Stocks, multi-select). "Save & Start Journalling" + "Skip for now" |

Auth field anatomy: 13pt/500 label above, 52pt field, radius 12, 1px border; focused = 1.5px ink + `0 0 0 4px rgba(45,45,42,.07)`; error = 1.5px crimson + 4px crimson-10% ring + an error line with icon in `#A03B44`. Primary button 52pt, radius 12, **label left-aligned with a trailing arrow**, disabled = 40% opacity.

### Core tabs
| Code | Screen | Key details |
|---|---|---|
| S07 | Dashboard | Wordmark header, date-range chips (This Month active), equity curve card with hero P&L, 2×2 metric cards (Total pips, Win rate, Avg RR, Total trades) with deltas, Recent trades |
| S09 | Journal | Search, filters, trades grouped by day with a day P&L header; every row shows a plan-followed mark |
| S10 | Trade Detail | Numbers first (net P&L, pips, RR, duration), execution table, partial exits, emotion, tags, notes, screenshot |
| S11 | Calendar | Month header with arrows, summary strip (trading days, win days, best day), 7-column grid of 52pt cells tinted by result, legend |
| S11b | Day drawer | Tap a day → 40% bottom sheet with that day's trades and total |
| S13 | Analytics | **Three hero metrics** (win rate, profit factor, average R) with the rest nested below. Show results as provisional until ~30 trades |
| S15 | Weekly review | One reflective prompt, saved weekly |

### Log Trade (opened from the ＋ button)
Three variants are drawn for comparison; **B (Quick log) is the chosen default**:
- **B — Quick log**: bottom sheet sized to content. Five most-used instruments as chips + "Other…", BUY/SELL segmented, one Result field that accepts **$, pips or R**, "Save trade" + "+ Details". Quick-logged trades get an **Incomplete** tag (amber) until prices are added, and still count toward win rate.
- A — full sheet step 1 (instrument, BUY/SELL, entry, exit, lot, stop, open/close time, live pip/$ /RR readout).
- C — step 2 (notes with 500-char counter, emotion picker, setup tags, chart screenshot).

Pip size depends on instrument: 0.0001 for most FX, 0.01 for JPY pairs and gold, 0.001 for silver. Stocks use shares; crypto uses units. Show a graceful state for unknown instruments.

### Edge states & settings
Empty Dashboard (one CTA: "Log your first trade"), Dashboard loading skeleton (staggered shimmer, **never a bare spinner**), S14 Settings (grouped list: theme, profit/loss colours with live preview, CSV export, reminders; "Coming soon" rows at 45% opacity).

---

## Interactions & behaviour
- **Auth flow**: Welcome → Sign up (Apple / Google / email) → email code → set password → Onboarding 1–3 → Profile setup → Dashboard. Returning users: Sign in with Apple, Google or email + password. Forgot password → reset link email → check-inbox screen.
- **Validation**: email checked on blur and on submit; Continue stays disabled until the email is valid; the code auto-submits on the 6th digit; the password rules update as the user types.
- **Sheets**: Log Trade and the day drawer are modal bottom sheets with a grab handle, scrim, drag-to-dismiss; ask "Discard this trade?" if there are unsaved fields.
- **Swipe on trade rows**: right = edit (slate), left = delete (`#9B2226`) with confirmation.
- **Press states**: buttons scale to 0.97 and darken one step; focus ring is 2px `#848FA5`, offset 2.
- **Tab bar**: stays fixed; content scrolls beneath the glass.
- **Toasts**: dark `#2D2D2A` bar, 48pt, e.g. "Trade saved to your journal." with a "View" action.

## State to model
`authState` (signedOut / verifyingEmail / settingPassword / onboarding / ready), `user` (displayName, avatar, currency, accountType, markets[]), `trades[]` (instrument, assetClass, direction, entry, exit, lot/size, stop, openedAt, closedAt, resultValue + resultUnit, pips, pnl, rr, emotion, tags[], notes, screenshot, isIncomplete, partialExits[]), `dateRange` filter, `selectedDay` (calendar), `theme` + custom P&L colours, `reminder` settings. Derived metrics (win rate, profit factor, avg R, equity series, per-day P&L) are computed client-side.

## Decisions that override the spec
1. Sign-up is **passwordless first** (Apple, Google, or email + 6-digit code); the password is set afterwards. The spec's Full Name field is gone; the name comes from Apple/Google or Profile setup.
2. Apple + Google sign-in added (App Store rules require Sign in with Apple if Google is offered).
3. Profile setup keeps only avatar, display name, currency, Demo/Real and markets traded.
4. The bottom nav is a floating glass pill with the create action in the centre slot (the spec had a flat bar + separate FAB).
5. Analytics leads with three hero metrics instead of nine cards.
6. A **Quick log** path is the default way to log a trade.
7. The brand mark is logo 5a (above), which replaces the spec's candlestick character.
8. The emotion picker uses the drawn line icons, not emoji.

## Assets
- Logo: vector above; source in `PipPal Logo.dc.html`.
- Icons: custom tab icons (paths in `PipPal Screens.dc.html`); other UI icons follow Lucide-style strokes, and the Lucide set is a fine source.
- Apple and Google marks: use the official brand assets and follow their button guidelines.
- No photography. Hero/empty-state illustrations are dashed placeholders waiting for artwork.
- Font: Inter (Google Fonts), weights 400–700.

## Files
| File | What it is |
|---|---|
| `PipPal Screens.dc.html` | **Main reference.** Every phone screen, the Log Trade variants and the iPad layout |
| `PipPal Foundations.dc.html` | Token and component sheet: colours, type, buttons in every state, inputs, tags, cards, nav, feedback, dark mode |
| `PipPal Logo.dc.html` | Logo exploration; the chosen mark is **5a** |
| `Motion Steps.dc.html` + `motion-steps-piece.jsx` + `animations-v3.jsx` | The 2s splash animation, scene by scene |
| `PipPal Design Brief.dc.html` | The research brief and the reasoning behind the main decisions |
| `ios-frame.jsx`, `support.js` | Viewer support files only. They are not part of the app |
| `reference/` | Original spec PDF and its extracted text |
