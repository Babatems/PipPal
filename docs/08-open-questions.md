# 08 · Decisions log & open questions

These answers came from design on 18 Oct 2026. Items marked **⚑ OWNER** still need the product owner to confirm. Everything else is a design decision, so build to it.
When something new is answered, add it here and update the affected doc.

## ⚑ Awaiting product-owner confirmation
| # | Item | Working assumption until confirmed |
|---|---|---|
| 1 | Backend & auth = **Supabase** | Build against Supabase |
| 5 | Bundle ID, format `com.<company>.pippal` | Keep `com.example.pippal`, but **never ship with it** |
| 6 | Logo candle colour | Design recommends **crimson `#C14953`**; the in-app header currently uses green `#2A9D5C`. Keep the colour in a single constant/asset so one change flips it everywhere, and update `claude/README.md` + `docs/06-assets.md` once decided |

## Decisions: blocking architecture
1. **Supabase** (⚑). It covers Sign in with Apple, Google, **6-digit email OTP** (S03a), email + password, password-reset links (S04a/b), and Postgres for trades. Firebase was rejected because it only offers email *links*, not codes.
2. **Offline-first with sync.** Every write goes to local SQLite (**drift**) first, then syncs to Supabase in the background when signed in. Sync is part of v1, so the "Cloud Backup · Coming soon" row is **removed** from Settings.
3. **Riverpod** for state management.
4. **iOS + Android only, iPad supported.** Delete the `web/`, `macos/`, `linux/` and `windows/` folders.
5. Bundle ID: ⚑ (above).

## Decisions: product & domain
6. Logo candle colour: ⚑ (above).
7. **"Followed my plan"** is an optional Yes/No that's **never required**.
   - Quick log: a compact "Followed plan?" Yes / No row under Result, unset by default.
   - Full form: on step 2, above Notes.
   - If **No**: optional reason chips (*Chased entry · Moved stop · Oversized · Exited early · No setup · Revenge trade*) plus the free-text note.
   - Unset trades show **no plan mark** in lists.
8. **Partial exits** live on full-form step 1: an "+ Add partial exit" link under Exit. Each row has a price and a % of position, and the rows must total **100%** before saving. A single exit is the default. Quick log has no partials.
9. The Dashboard card becomes **"Avg R" (realised)**. Full-form step 1 gains an **optional Take profit** field. When it's filled in, Trade Detail shows planned R:R next to realised. The Dashboard card stays realised-only.
10. **No rates API in v1.** Calculate $ automatically only when the instrument's quote currency equals the account currency. Otherwise, calculate pips and **ask the user for the $ result** (via the Result field). Store both.
11. **Pips only for forex and metals.** Crypto shows price change and $ (sized in units). Stocks show shares and $. Hide the pip readout and pip metrics for those asset classes.
12. **Break-even is neither a win nor a loss.** Win rate = wins ÷ (wins + losses). A trade is break-even when its net P&L is exactly 0 after costs. Calendar treats it as a trading day but not a win day.
13. **Exclude trades that lack the data.** Avg R uses only trades with an R (entered, or derived from entry/stop/exit). Profit factor uses only trades with a $ result. Show **"Based on N of M trades"** under any metric that excludes trades.
14. **Analytics thresholds:** with fewer than 5 trades, show the empty state. From 5 to 29, show numbers with a **"Provisional"** tag. From 30 on, show them normally. Drop every mention of "100".
15. **No CSV import in v1.** Remove "or import a CSV from your broker" from the empty Dashboard. There's no Import row.
16. **Device time zone only.** Store timestamps in **UTC** and group by day in the device's time zone. There's no time zone setting (Settings shows "Device", read-only).
17. **Weekly Review entry points:**
    - (a) A "Your week in review" card at the top of the Dashboard, shown from **Sunday 18:00** until the review is saved or Monday ends.
    - (b) A Sunday 18:00 local notification, controlled by the **Weekly Performance Summary** toggle (Settings › Notifications).
18. **Apple/Google sign-ups** see the same Onboarding and Profile setup, with Display name pre-filled. They **never set a password** and always sign in with Apple or Google.

## Decisions: design gaps
19. **Profile screen: yes**, opened from the Dashboard avatar. It shows the avatar, display name, email (read-only), account type, currency, **Sign out** (with confirmation) and **Delete account** (an Apple requirement). It uses the Settings list styling.
20. **Theme sub-screen and pickers follow the spec**, built from Foundations components.
    - P&L colour presets: Profit `#2A9D5C` `#1F7A46` `#3B8EA5` `#2D7D6E`; Loss `#C14953` `#9B2226` `#B4553F` `#8E4B6B`.
    - The Analytics period sheet and Journal sort sheet are standard bottom sheets with radio rows.
21. **Edit mode** puts the full-form fields inline on Trade Detail, with **Save changes** (primary) and **Cancel**.
    - The **More** menu has Edit / Share / Delete.
    - **Share** generates a branded image card for the system share sheet: logo, instrument, direction, R and pips, date, and an optional $ amount (**off** by default).
22. **Dark-mode values:**
    - divider `#353531`, navIdle `#A9A390`, crimsonText `#E5717A`, profitText `#4DBF7F`, warningText `#E8A06B`, skeleton `#2D2D2A` → shimmer `#3A3A36`.
    - **Glass tab bar:** gradient `rgba(45,45,42,.78)` → `rgba(30,30,27,.66)`, blur 24 / saturation 1.8, border `rgba(255,255,255,.08)`, inner top highlight `rgba(255,255,255,.06)`, shadow `0 14px 34px -10px rgba(0,0,0,.6)`, active capsule `#E5717A` 16%→10%.
23. **Settings adds the spec's rows:**
    - Account: Default currency, Account type, Time zone ("Device", read-only).
    - Support: About, Privacy, Terms, Rate PipPal.
    - Notifications: Weekly Performance Summary.
    - Import Trades is left out.
24. **Analytics extras go below the hero three**, in this order: **P&L by session → day-of-week bars → win/loss donut**. The frequency heatmap is dropped (the Calendar covers it).
25. **Breakpoints by width** (the same on iPad and Android tablets):
    - **< 600**: phone layout with the floating tab bar.
    - **600–1023**: icon-only 72pt sidebar, single pane.
    - **≥ 1024**: the drawn 248pt sidebar with two panes.
26. **Dialog radius = 16** (Foundations wins).
27. **Dates and times follow the device locale** (`intl`), including 12h/24h. The designs show en-GB only as an example.

## Decisions: follow-ups (answered 18 Oct 2026)
28. **Sync conflicts: last write wins** in v1, judged by a **server-set `updatedAt`** (a Postgres trigger), never the phone clock. A device with a wrong clock can't overwrite newer changes.
29. **Screenshots and avatars** live in **Supabase Storage**, synced, with a local cached copy. Before upload, compress screenshots to **≈500 KB** and avatars to **≈100 KB**, and **strip EXIF/location data**.
30. **Delete account is immediate and hard** (no grace period): trades, reviews, profile, storage files and the auth user. The confirmation first **offers a CSV export**.
31. **The week always starts Monday**, in both the Calendar grid and Weekly Review. This overrides the spec's locale-based Sun–Sat rule.
32. **"On plan" counts only marked trades:** "8/11" = 8 Yes out of 11 trades marked Yes or No. Unset trades are excluded. The **Off-plan** filter shows only trades marked **No**.
33. **No logging before sign-in.** **Sign out** = sync first, then wipe the local database and cached files. If there are unsynced changes (offline, or a sync failure), **warn before signing out**.
34. **Sessions use fixed UTC hours by open time.** In overlaps, the later session wins: **Tokyo 00–07 · London 07–12 · New York 12–21 · Sydney 21–24** (UTC, start inclusive, end exclusive).

## Open
None right now apart from the ⚑ owner items above. Two working assumptions can still be overruled:
- A trade without a $ result is judged a win or loss from its R, or from its pips if there's no R.
- The "Provisional" tag uses the amber tag style.

## Resolved before the design answers
- Designs + `claude/README.md` override the spec.
- Quick log (B) is the default.
- Drawn emotion icons are used, not emoji.
- Logo is mark 5a.
- Sign-up is passwordless first, with Apple + Google.
