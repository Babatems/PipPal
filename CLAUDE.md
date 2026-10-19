# PipPal — project guide for Claude

PipPal is a **manual trading journal** mobile app (Flutter/Dart) for **iOS and Android only**, with iPad/tablet layouts. Traders log forex, crypto and stock trades by hand (no broker sync). They review performance through a Dashboard, a Journal list, a P&L Calendar and Analytics. The target user is a disciplined retail trader or prop-firm-challenge trader.

**Build status:** steps 0–1 and a quality pass are done: foundations, the responsive nav shell, empty states for every tab, a working Calendar grid, the Quick log form (Save is disabled until storage exists) and the launcher icon. Next is step 2 (domain maths, drift schema, seed data). See `docs/07-architecture.md` › Build progress and `docs/09-repo-map.md`.

Stack: **Riverpod** · **drift** (offline-first SQLite) · **Supabase** (auth + Postgres sync; ⚑ awaiting owner sign-off).

## Source-of-truth order (highest wins)
1. Design decisions D1–D34 in `docs/08-open-questions.md` and any later answers. These override the drawings where they conflict (e.g. "Avg R" card, removed CSV line, new plan/TP/partial-exit fields).
2. `claude/README.md`, the design handoff, together with the HTML designs in `claude/` (`PipPal Screens.dc.html` is the main one).
3. `claude/reference/spec.txt`, the original 33-page spec (the PDF is the same content).

Where the designs and the spec disagree, **the designs win**. The known overrides are listed in `docs/01-product-overview.md`.

## Docs index
| File | Read it when… |
|---|---|
| `docs/01-product-overview.md` | You need the what/why: users, principles, scope, overrides of the spec |
| `docs/02-design-system.md` | You're touching colours, type, spacing, radii, shadows, motion, or theme code |
| `docs/03-screens.md` | You're building or changing any screen (S01–S16, sheets, edge states, tablet layouts) |
| `docs/04-navigation-and-flows.md` | Routing, auth flow, tab bar, sheets, transitions, back behaviour |
| `docs/05-domain-and-data.md` | Trade model, pip/P&L/R maths, metrics, app state |
| `docs/06-assets.md` | Logo, custom icon SVG paths, emotion icons, splash animation, fonts |
| `docs/07-architecture.md` | Stack, folder layout, packages and coding conventions (core stack decided; some package picks proposed) |
| `docs/08-open-questions.md` | **Decisions log (D1–D34)**, ⚑ owner items, and follow-up questions |
| `docs/09-repo-map.md` | What's in the repo and in `claude/` today |

## Non-negotiables (quick reference)
- Light mode is primary. Use the warm off-white ground `#F5F1E8`, white cards and **1px borders instead of shadows**.
- Font is **Inter**. Use `FontFeature.tabularFigures()` on **every** number (prices, P&L, pips, %, counts, dates, times).
- Read profit/loss colours from a **theme extension**, never from constants, because users can override them in Settings.
- Crimson `#C14953` is both the brand/CTA colour and the loss colour. Crimson *text* on tints or glass uses `#A03B44`.
- Slate `#848FA5` is only for captions of 13px or smaller. It fails AA for body text.
- Loading states use a staggered shimmer skeleton, **never a bare spinner** (except inside a button while submitting).
- The phone nav is a floating glass pill: Dashboard · Journal · [＋] · Calendar · Analytics. Content scrolls under it, so scroll views need ≥120pt bottom padding.
- Quick log (variant B) is the default way to log a trade.
- Pips appear only for forex and metals. Break-even trades are excluded from win rate. Metrics that skip trades show "Based on N of M trades".
- Dates follow the device locale (`intl`), but **weeks always start Monday**. Timestamps are stored in UTC and grouped by the device time zone.
- Offline-first: the UI reads drift only. Sync is last-write-wins using a **server-set** `updatedAt`. Nothing works signed out; sign-out syncs, then wipes the device.
- **Never put developer tooling, screen codes, placeholder copy or fake actions in the UI.** Unbuilt features are absent or honestly disabled.
- ⚑ Don't ship with bundle ID `com.example.pippal`. Keep the logo candle colour in one place until the owner decides.
- Pixel fidelity is high. Colours, type, spacing, radii and copy in the designs are final. The sample data (EUR/USD, July 2026) is only illustrative.

## Working rules
- Viewing designs: open the `claude/*.dc.html` files in a browser. They need `support.js` beside them, so don't move files around in `claude/`.
- `claude/ios-frame.jsx`, `claude/support.js` and `claude/animations-v3.jsx` are viewer/prototype support code. **Do not port them** into the app.
- Before building a screen, re-read its row in `docs/03-screens.md` and inspect the matching section of `claude/PipPal Screens.dc.html`.
- When a question in `docs/08-open-questions.md` is answered (⚑ owner items, or anything new), record it there with the date and update any affected doc.
- Keep these docs current. When code establishes a convention, update `docs/07-architecture.md`.

## Commands
```bash
flutter pub get
flutter run                 # pick a device; iPhone 16 Pro sim matches the 402×874 design frame
flutter analyze
flutter test
```
Toolchain at time of writing: Flutter 3.38.5 stable, Dart SDK constraint `^3.10.4`. The template already uses Dart dot-shorthands such as `.fromSeed`.
