# 07 · Architecture & conventions

> **Status:** the core stack is decided (D1–D4 in `08-open-questions.md`); Supabase still needs owner sign-off (⚑). Package picks marked *proposed* aren't confirmed yet.

## Stack
| Concern | Choice | Why |
|---|---|---|
| Platforms | ✅ iOS + Android only (iPad/tablet layouts by width) | D4 |
| UI | Flutter, Material 3 with a custom `ThemeData` + `ThemeExtension`s | README asks for M3 theme extensions |
| Routing | ✅ `go_router` 17, `StatefulShellRoute` with a custom fade-through container (`AppShell`) | Per-tab state preservation; redirect on `authState` comes in step 5 |
| State | ✅ **Riverpod 3** (`flutter_riverpod`, plain `Notifier`s, no codegen yet) | D3 |
| Local persistence | ✅ **drift** (SQLite), the source of truth for the UI | D2 offline-first |
| Backend | ✅ **Supabase** ⚑ (`supabase_flutter`): Auth (Apple, Google, email OTP, password, reset), Postgres (trades, reviews, profile), Storage (screenshots ≈500 KB / avatars ≈100 KB, EXIF stripped, local cache) [D29], Edge Function for **immediate hard** account deletion (rows + storage + auth user) | D1, D19, D30 |
| Sync | Background push/pull between drift and Supabase; outbox of pending rows; **last write wins by server-set `updatedAt`** (DB trigger) with soft-delete tombstones; sign-out = flush, then wipe local | D2, D28, D33 |
| Charts | `fl_chart` or custom `CustomPainter` | Equity curve with draw-in and crosshair |
| SVG | ✅ `flutter_svg`. Glyphs are built as SVG strings in `core/widgets/pip_icons.dart` so they can be recoloured at runtime | Logo, custom icons |
| Fonts | ✅ bundled Inter 4.1 (400/500/600/700) in `assets/fonts/` | Tabular figures |
| Others (when needed) | `image_picker` + `flutter_image_compress` (resize/EXIF strip), `share_plus` (CSV export + share card image), `flutter_local_notifications` (daily reminder, Sunday 18:00 weekly summary), `flutter_native_splash`, `flutter_launcher_icons`, `sign_in_with_apple`, `google_sign_in`, `intl` (locale dates, 12/24h), `connectivity_plus` (sync trigger) | |

## Folder layout (proposed, feature-first)
```
lib/
  main.dart
  app/                 # App widget, router, bootstrap
  core/
    theme/             # tokens.dart (colours/spacing/radii), typography.dart, pnl_colors.dart (ThemeExtension), app_theme.dart
    widgets/           # PrimaryButton, PipField, MetricCard, TradeRow, Tag, Chip, GlassTabBar, Skeleton, Toast, Sheet…
    utils/             # formatting (money, pips, R, dates), haptics
  data/
    local/             # drift database, tables, DAOs
    remote/            # Supabase client, DTOs
    sync/              # outbox + sync engine
  domain/
    instruments/       # pip size, precision, contract size, asset class lookup
    calc/              # pips, pnl, R, metrics (pure Dart, unit-tested)
  features/
    splash/  auth/  onboarding/  profile_setup/  profile/
    dashboard/  journal/  trade_detail/  log_trade/
    calendar/  analytics/  weekly_review/  settings/
      └─ each: data/ (repos), application/ (providers/controllers), presentation/ (screens, widgets)
assets/
  svg/  fonts/  images/
```

## Conventions
- **Never hard-code colours in widgets.** Read them from `Theme.of(context)` or the extensions (`context.pnl.profit`, `context.tokens.border`…).
- **Tabular figures are applied globally:** every style in `AppTypography` carries `FontFeature.tabularFigures()`. Inter's `tnum` only affects digits. Always derive styles from `context.text.*` (via `copyWith`) so the feature isn't lost; never build a bare `TextStyle` for numbers.
- Access tokens with `context.colors` (`PipColors`), `context.pnl` (`PnlColors`) and `context.text` (from `core/theme/app_theme.dart`). Spacing and radii come from `Space` and `Radii` in `core/theme/tokens.dart`.
- Use `PnlColors.forValue` / `textForValue` / `tint` for anything signed.
- The logo candle colour lives only in `BrandMark` (tokens.dart) and `assets/svg/logo_5a.svg` (⚑ D6).
- Tab screens use `TabScaffold` + `PipAppBar` (`core/widgets/app_bar.dart`). Scroll bodies pad their bottom with `TabScaffold.bottomClearance(context)` (120pt on phones) so content scrolls *under* the glass bar. Modal sheets use `showPipSheet`.
- **Nothing developer-facing ships in the UI.** There are no debug buttons, screen codes, "built in step N" copy or fake actions. Unbuilt features are either absent or honestly disabled; Quick log's Save stays disabled (`onSave == null`) until trades can be stored. The Foundations sheet is a debug-only route (`flutter run --route /dev/foundations`) that isn't registered in release builds.
- With no data, every screen shows its designed **empty state** (`EmptyState`), not a skeleton. Skeletons are only for real loading.
- Fixed heights must never clip at large text sizes. Use `minHeight` constraints. A test visits every tab at 1.5× text scale and fails on any overflow.
- Date/time UI must be testable: read "now" from `clockProvider`, never `DateTime.now()` directly.
- `LayoutSize.of(context)` (`core/layout/breakpoints.dart`) is the only place breakpoints are decided.
- Tests: never `pumpAndSettle` on screens that contain a `Skeleton`, because its shimmer repeats forever. Pump fixed durations instead.
- Never put an implicit animation (e.g. `AnimatedOpacity`) *inside* a `TickerMode(enabled: false)` that it needs to animate out of. The muted ticker freezes it. This caused the "previous tab stays visible" bug in `FadeThroughStack`; a regression test guards it.
- A `Container` with `alignment` expands to fill its constraints. For pill-shaped widgets in a `Wrap`/`Row`, use `Center(widthFactor: 1)` instead.
- Visual check: no iOS simulator runtime is installed on this machine. Use the `Pixel_6` Android emulator (`flutter emulators --launch Pixel_6`).
- Domain calculations (`pips`, `pnl`, `R`, win rate, profit factor, equity series, per-day buckets) are pure Dart functions with unit tests. The designs' sample figures are good test fixtures (see `05-domain-and-data.md`).
- Use the minus `−` for negatives through a single money/number formatter.
- Every screen ships with its states: default, loading (skeleton), empty, error.
- Responsive by width [D25]: `< 600` phone + glass pill · `600–1023` icon-only 72pt sidebar, single pane · `≥ 1024` 248pt sidebar, two panes. Centralise this in one `Breakpoints` helper.
- **UI reads only from drift.** Repositories write locally, then enqueue a sync. Never block the UI on the network.
- Store timestamps in UTC; convert to the device zone only for display and day grouping [D16].
- Format dates through `intl` with the device locale [D27]. Never hard-code `en_GB` or 24h.
- Secrets: Supabase URL/anon key go in `--dart-define` / env config, never committed.
- Accessibility: `Semantics` labels on P&L values and icon buttons; test at 1.3× and 1.5× text scale.
- Follow `flutter_lints` (configured in `analysis_options.yaml`).
- Match Dart 3.10 idioms already in the template (dot shorthands, `super.key`).

## Build progress
- ✅ **Step 0 (18 Oct 2026):** removed web/macos/linux/windows; replaced the template app and test.
- ✅ **Step 1 (18 Oct 2026):** theme (`core/theme/`), core widgets (`core/widgets/`: buttons, card, tag, chip, section header, sheet helper, skeleton, icons/logo), responsive shell (`app/shell/`: glass tab bar < 600, 72pt rail 600–1023, 248pt sidebar ≥ 1024), router, appearance controller (in-memory), and tests in `test/`. (The placeholder tabs and the Dashboard link to the dev screen were removed in the quality pass below.)
- ✅ **Quality pass (18 Oct 2026):** removed developer artifacts from the UI. Rebuilt the buttons, chips and tags to the Foundations spec, and added the white app bar. Real screens:
  - Dashboard, Journal and Analytics empty states.
  - A working Calendar month grid (Monday-first, month nav and swipe, today ring, future days greyed, no navigating past the current month).
  - The Quick log sheet to design B plus D7 (instrument chips + Other…, BUY/SELL, signed result with $/pips/R, pips hidden for crypto/stocks, optional plan Yes/No with reasons).
  - Launcher icon and PipPal app name.
  - 1.5× text-scale test.
- ⏭ **Step 2:** domain maths + tests, drift schema, seed data. Wire `tradeCountProvider` and Quick log `onSave` to the database.

## Build order (from the design brief, adapted)
0. Housekeeping: delete `web/ macos/ linux/ windows/` [D4]; replace the template `main.dart`/test
1. Foundations: tokens, theme, typography, core widgets, glass tab bar shell, routing skeleton
2. Domain: instrument table + calculations + tests; drift schema; seed data
3. Core tabs: Dashboard, Journal, Calendar + day drawer, Analytics
4. Log Trade: Quick log (default), then full form steps 1–2; Trade Detail (+ edit)
5. Supabase: auth + onboarding + profile setup, then sync, Profile screen and delete account
6. Edges: Settings (+ theme sub-screen), P&L colour presets, Weekly Review + Dashboard card + notifications, share card, analytics extras, empty/loading/provisional states, dark mode, tablet layouts, splash animation, app icon
