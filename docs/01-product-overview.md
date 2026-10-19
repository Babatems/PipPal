# 01 · Product overview

Sources: `claude/README.md`, `claude/PipPal Design Brief.dc.html`, `claude/reference/spec.txt` §1–2.

## What PipPal is
A digital **trading journal** for Forex, Crypto and Stock traders. Trades are logged **manually**, with no broker connection; the Welcome screen copy says "No broker connection required. 100% manual journalling." Performance shows up in:
- **Dashboard**: equity curve, 4 metric cards, recent trades
- **Journal**: searchable/filterable trade list grouped by day
- **Calendar**: monthly P&L heatmap with a day drawer
- **Analytics**: three hero metrics (win rate, profit factor, avg R) with the rest nested below
- **Weekly Review**: a Sunday ritual with one reflective prompt
- **Profile**: account details, sign out, delete account
- Everything is stored **offline-first** and synced to the user's account (Supabase)

Platforms: **iOS and Android only** (phones primary), with tablet/iPad layouts chosen by width [D4, D25]. There's no web or desktop.

## Target user
A disciplined retail trader or prop-firm-challenge trader who wants a clear record of progress. Design for beginners first; experienced traders find depth through progressive disclosure.

## Design direction
"A beautifully organised **Notion** workspace purpose-built to track trades." The aesthetic borrows from Notion: warm off-white ground, soft 1px borders, generous whitespace, muted palette. Data patterns come from **TraderSync / TradeZella** (metric cards, P&L calendar, trade rows). Personality sits at 5/10 between serious and playful: "a well-designed personal notebook". It should be neither a Bloomberg terminal nor a gaming app.

Core principles (spec §1.4):
- Clarity first: each screen's purpose should be clear in under 3 seconds.
- Warm, not cold.
- Data without overwhelm: key metrics up front, the rest via progressive disclosure.
- Consistent rhythm in spacing, type and cards.
- Trust through typography: legible, tabular numbers matter most.
- Accessible for everyone.

## Product insights from the design brief (why the designs look the way they do)
1. **Friction is the main product risk.** Traders abandon manual journals within weeks. That's why **Quick log** (3 fields, about 8 seconds) is the default, with details deferred.
2. **Three numbers, not nine.** Win rate, average R and profit factor lead Analytics.
3. **Statistics need about 30–50 trades.** Analytics shows an empty state below 5 trades and a **Provisional** tag from 5 to 29 [D14]. Drop the "around 100" wording from the design copy.
4. **Pip maths depends on the instrument.** Pip size and pip value vary, and unknown instruments need a graceful state.
5. **The calendar is the hook.** A day cell that does nothing on tap is the most-cited competitor gap, so the day drawer is built early.
6. **Execution over outcome.** Every trade carries a **"Followed my plan"** mark (Plan / Off-plan), so discipline is judged separately from P&L. The Weekly Review highlights rule-breaking trades: "Two of them still won. That is the trap worth naming."

## Decisions that override the spec (designs win)
1. Sign-up is **passwordless first** (Apple, Google, or email + 6-digit code). The password is set afterwards. The spec's Full Name field is removed.
2. **Sign in with Apple and Google** are added (App Store rules require Apple whenever Google is offered).
3. Profile setup keeps only avatar, display name, currency, Demo/Real and markets traded (Forex/Crypto/Stocks). The spec's Time Zone and Trading Style fields are gone.
4. The bottom nav is a **floating glass pill** with the create action in the centre slot. The spec had a flat bar with a separate FAB.
5. Analytics leads with **three hero metrics** instead of nine cards.
6. **Quick log** is the default way to log a trade.
7. The brand mark is **logo 5a** (geometric P plus candlestick), which replaces the spec's candlestick character.
8. The emotion picker uses **drawn line icons**, not emoji.

Further deltas found in the designs (also override the spec):
- The splash is a **2.0s** three-scene logo build with a "TRADING JOURNAL" caption. The spec had a 2.5s spring pop with a "Your Trading, Journalled." tagline.
- Phone design frame is **iPhone 16 Pro / 17, 402×874pt**. The spec used 390×844.
- Primary buttons are **52pt** tall with a left-aligned label and a trailing arrow. The spec had 48dp with centred text.
- Journal filter chips are **All · Wins · Losses · Off-plan · Tagged**.
- Analytics periods are **This Month · 90 Days · All Time**.
- The **Calendar week always starts Monday**, overriding the spec's US Sun–Sat rule [D31].
- **S15 is Weekly Review** in the designs. The spec's S15 was the Theme sub-screen, which isn't drawn.
- The Dashboard metric card "AVG PLANNED RR" is renamed **"AVG R"** (realised) [D9].

## Scope status
| Area | Status |
|---|---|
| Splash, Welcome, Sign up (+ error), Verify email, Set password, Sign in (typing/loading/error), Forgot password, Check inbox | ✅ Drawn |
| Onboarding 1–3, Profile setup | ✅ Drawn |
| Dashboard (populated, empty, loading), Journal, Trade Detail, Calendar + day drawer, Analytics hero, Weekly Review | ✅ Drawn |
| Log Trade A (full step 1), B (quick log, default), C (step 2) | ✅ Drawn, with additions from D7–D9 |
| Settings (main), iPad landscape two-pane, app icon | ✅ Drawn |
| Profile screen, Theme sub-screen, colour/period/sort sheets, Trade Detail edit mode, Share card, Weekly Review Dashboard card, Analytics extras, icon-only tablet sidebar, dark mode for all screens | 🟡 Not drawn. Build from the spec + Foundations per design decisions D17–D25 |
| Backend | ✅ Decided: Supabase (⚑ owner to confirm), offline-first drift + sync |
| **Out of v1** | CSV import, rates API for currency conversion, time zone setting, Accent colour (*Coming soon*), web/desktop platforms |
