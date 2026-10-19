# 05 · Domain & data

Sources: `claude/README.md` ("State to model", Log Trade), the Design Brief (insight 04), the Screens sample data, spec §8, and the design decisions in `08-open-questions.md` (numbers in brackets, e.g. [D7], point to them).

## Storage model [D2, D16]
- **Offline-first.** Every write goes to local SQLite (drift) first, then syncs to Supabase Postgres in the background when signed in.
- Every synced row carries `id` (client-generated UUID), `userId`, `createdAt`, `updatedAt`, `deletedAt` (soft delete, a tombstone for sync), and a local `syncState` (pending/synced).
- **Conflicts: last write wins by server-set `updatedAt`** (a Postgres trigger), never the device clock [D28].
- **No data before sign-in.** Sign out = sync first → wipe the local DB and cached files. Warn if unsynced changes remain [D33].
- Files (screenshots, avatars) go in Supabase Storage with a local cache. Compress to ≈500 KB / ≈100 KB and strip EXIF before upload [D29].
- All timestamps are stored in **UTC**. Grouping by day/week uses the **device time zone**.

## Entities
### User / profile
`id, email (read-only), displayName, avatar (url|null → initials), currency (default USD), accountType (demo|real), markets: {forex, crypto, stocks}, authProvider (apple|google|email)`.
Apple/Google users never have a password [D18]. There's no time zone field [D16].

### Trade
| Field | Notes |
|---|---|
| `instrument` | e.g. `EUR/USD`, `XAU/USD`, `BTC/USD`, `AAPL` |
| `assetClass` | forex · metals · crypto · stocks (metals behave like forex for pips) |
| `direction` | buy · sell |
| `entry`, `exit`, `stop`, `takeProfit` | all nullable (quick log). `takeProfit` is optional, full form step 1 only [D9] |
| `partialExits[]` | `{price, percent}`, full form only, must total 100% [D8]. Average exit is %-weighted (60% @1.08880 + 40% @1.08930 = 1.08900). A single exit is the default |
| `size` + unit | lots (forex/metals), units (crypto), shares (stocks) |
| `openedAt`, `closedAt` | UTC; duration is derived |
| `resultValue` + `resultUnit` | quick-log input: `$`, `pips` or `R` |
| `pnl` | $ in the account currency. Auto-calculated only when the quote currency equals the account currency; otherwise **entered by the user** [D10] |
| `pips` | forex/metals only [D11]; derived from prices or entered |
| `r` | entered, or derived from entry/stop/exit |
| `commission` | optional; included in net P&L |
| `followedPlan` | `true / false / null`, optional and **never required**; `null` shows no mark [D7] |
| `offPlanReasons[]` | only when `followedPlan == false`: Chased entry · Moved stop · Oversized · Exited early · No setup · Revenge trade [D7] |
| `emotion` | confident · neutral · anxious · frustrated · focused (nullable) |
| `tags[]` | presets: Trend Following, Breakout, Reversal, News, Scalp, plus user-defined |
| `notes` | max 500 chars |
| `screenshot` | Supabase Storage path + local cached file; ≈500 KB, EXIF stripped [D29] |
| `isIncomplete` | true for a quick log until prices are added (amber **Incomplete** tag) |

### Weekly review
`weekStart (Monday, local), answer text, savedAt`. The week **always starts Monday**, as in the Calendar [D31]. Prompt: "What would you do differently next week?". Week = Mon–Sun. "The three you broke your rules on" lists trades with `followedPlan == false`, with their reasons.

### Settings (per device, user-level preferences synced as needed)
`theme (light|dark|system)`, `profitColor`, `lossColor` (from the 8 presets in [D20]), `dailyReminder {enabled, time (default 21:00)}`, `weeklySummary` (enables the Sunday 18:00 notification) [D17].

## Instrument maths
| Asset class | Pip size | Shows |
|---|---|---|
| Forex (most pairs) | 0.0001 | pips + $ |
| Forex JPY pairs | 0.01 | pips + $ |
| Gold XAU | 0.01 | pips + $ |
| Silver XAG | 0.001 | pips + $ |
| Crypto | — | price change + $ (units); **no pips** [D11] |
| Stocks | — | shares + $; **no pips** [D11] |
| Unknown | — | "Not a recognised instrument." state; allow saving with $/R |

- `pips = (exit − entry) / pipSize` for BUY, `(entry − exit) / pipSize` for SELL. Show 1 dp (`+48.0 pips`). Prices show at instrument precision (EUR/USD 5 dp, JPY 3 dp, XAU 2 dp).
- **$ for forex/metals:** `pnl = pips × pipSize × contractSize × lots`, computed **only when quote currency == account currency**. Otherwise prompt for the $ result [D10]. Contract sizes: FX 100,000; XAU 100 oz.
  - Check: EUR/USD at 0.20 lots → $2.00/pip × 48 = **$96.00** ✔.
- **R:** `R = (exit − entry) / (entry − stop)` for BUY (sign-flipped for SELL). Check: (1.08900−1.08420)/(1.08420−1.08180) = **2.0R** ✔.
- **Planned R:R** (Trade Detail only, when TP is set): `|takeProfit − entry| / |entry − stop|`, shown as `1:2.0` [D9].

## Derived metrics (computed client-side)
| Metric | Definition |
|---|---|
| Outcome | win: net P&L > 0 · loss: < 0 · **break-even: exactly 0 after costs** [D12]. Where $ is missing, use R, then pips (working assumption) |
| Win rate | wins ÷ (wins + losses). Break-even is excluded; Incomplete trades **count** |
| Profit factor | gross won ÷ gross lost, only over trades with a $ result [D13] |
| Avg R | mean R (incl. losses), only over trades with an R [D13] |
| Coverage note | "Based on N of M trades" whenever a metric excluded any trades [D13] |
| Data threshold | < 5 trades → empty state; 5–29 → **Provisional** tag; ≥ 30 → normal [D14] |
| Net P&L, total pips | period sums (pips over forex/metals only) |
| Equity series | cumulative P&L by close time |
| Per-day P&L | sum per local day → calendar cell (profit/loss/break-even amber) |
| Trading / Win days / Best day | days with ≥ 1 trade / days with P&L > 0 (+ % of trading days) / max day P&L |
| Streaks, best/worst trade | longest W/L runs ("6 W · 3 L"); max/min P&L |
| Metric-card deltas | % change vs the previous equivalent period |
| On-plan count | Yes ÷ (Yes + No); unset trades are excluded ("8/11") [D32]. Off-plan filter = `followedPlan == false` only |
| P&L by session | by **open time in UTC**: Tokyo 00–07 · London 07–12 · New York 12–21 · Sydney 21–24 (start inclusive) [D34] |
| Day-of-week | trade count / P&L by weekday |
| Quick-log chips | the user's five most-used instruments by frequency |

## Formatting
- Every number goes through one formatter: `+$96.00` / `−$48.00` (U+2212 minus, 2 dp), `+2.0R`, `1:2.0`, `64.3%`, `+48.0 pips`. Calendar cells round (`+233`).
- **Dates and times follow the device locale** via `intl`, including 12h/24h [D27]. The designs' "Tue 14 Jul", "14 Jul 2026 · 09:32" are only en-GB examples.
- Durations: `2h 14m`, `41m`.

## App state (Riverpod)
`authState` (`signedOut / verifyingEmail / settingPassword / onboarding / ready`), `user`, trades stream (from drift), `dateRange`, journal filters/search/sort, calendar month + `selectedDay`, analytics period, theme + P&L colours, reminder settings, weekly review status, and sync status.

## Sample data (designs only; useful as test fixtures and a demo seed)
- **July 2026, today = Tue 14 Jul.** Day P&L: `{1:62, 2:-28, 3:140, 6:34, 7:-96, 8:0, 9:88, 10:52, 13:233.5, 14:80}` → net +$565.50, 10 trading days, 7 win days (70%), best day +$233.50.
- **14 Jul:**
  - EUR/USD BUY 1.08420→1.08900, stop 1.08180, 0.20 lots, +48.0 pips, +$96.00, +2.0R, 09:32→11:46, Confident, Breakout, Plan
  - XAU/USD SELL 2412.40→2412.88, −48.0 pips, −$48.00, −1.0R, 13:05, Off-plan
  - BTC/USD BUY quick log +$32.00, Incomplete, 16:48
- **13 Jul:**
  - GBP/JPY SELL 191.240→191.410, −17.0 pips, −$42.50, −0.9R (non-USD quote, so the $ is user-entered)
  - USD/CAD BUY 1.36140→1.36460, +32.0 pips, +$64.00, +1.6R
  - AAPL BUY 228.40→230.52, 100 shares, +$212.00, +2.4R
