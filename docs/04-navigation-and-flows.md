# 04 · Navigation & flows

Sources: `claude/README.md` (Navigation, Interactions), `claude/PipPal Screens.dc.html` (tab bar prose and iPad section), spec §7.

## Auth & first-run flow
```
Splash (S01, 2.0s)
 ├─ signed in ───────────────────────────────► Dashboard
 └─ signed out ─► Welcome (S02)
      ├─ Create free account ─► Sign up (S03)
      │     ├─ Apple / Google ───────────────► [new user] Onboarding
      │     └─ Email ─► Verify code (S03a) ─► Set password (S03b)
      │                                         └─► Onboarding 1–3 (S05, skippable)
      │                                              └─► Profile setup (S06, skippable)
      │                                                   └─► Dashboard (+ "Welcome, {name}!" toast)
      └─ Sign in ─► Sign in (S04) ── Apple / Google / email+password ─► Dashboard
                      └─ Forgot password? ─► S04a ─► Check inbox (S04b)
```
`authState`: `signedOut → verifyingEmail → settingPassword → onboarding → ready`.
- Back navigation works between auth screens, but never back to Splash.
- Validate email on blur and on submit. **Continue** stays disabled until the email is valid. The code auto-submits on the 6th digit. Password rules update live.
- Apple/Google sign-ups go through Onboarding and Profile setup (name pre-filled), **never set a password**, and always sign in with Apple/Google [D18].
- Auth is **Supabase** (⚑ owner to confirm): Apple, Google, 6-digit email OTP, email+password, reset link. Use a deep link for the reset email back into the app.

## App shell (phone)
Four tabs plus a centre create action, in a **floating glass pill**:

`Dashboard · Journal · [＋ Log Trade] · Calendar · Analytics`

Pill geometry and style:
- 64pt tall, inset 16pt left and right, sits **40pt above the bottom edge** (clears the home indicator). Radius 32, inner padding 6.
- Glass: `BackdropFilter` blur 24 with saturation 1.8. Gradient `rgba(255,255,255,.74)` → `rgba(250,247,240,.56)` (top→bottom). 0.5px white border, outer ring `rgba(45,45,42,.08)`.
- Shadows: `0 14px 34px -10px rgba(45,45,42,.28)` + `0 2px 6px rgba(45,45,42,.06)`. Inner top highlight `rgba(255,255,255,.95)`.
- Centre button: a 46pt circle, gradient `#CF5A63`→`#B8404A`, white plus (22px, stroke 2.4). Shadow `0 6px 14px -4px rgba(193,73,83,.55)` with inset highlights. Opens the **Quick log** sheet.
- Each tab: 24pt icon over a 10pt label (500 idle / 600 active).
  - **Active**: the *filled* version of its own icon in `#A03B44`, inside a 52pt-tall capsule (crimson 14%→8% gradient, 0.5px crimson-18% inner ring).
  - **Idle**: outline icon + label in solid `#5E5E57`.
- Content **scrolls beneath** the pill. Scroll views need ≥120pt bottom padding. Standalone bottom CTAs sit 70pt above the pill's top.
- Pushed screens (Trade Detail, Weekly Review) keep the pill visible with **no capsule highlighted**.
- Tab switch: 200ms fade-through plus a light haptic. Per-tab state preservation (spec §7.1): Dashboard resets scroll; Journal keeps its scroll; Calendar keeps the selected month; Analytics keeps its filter. Use a `StatefulShellRoute` (go_router) or an `IndexedStack`.
- **Dark-mode glass [D22]:** gradient `rgba(45,45,42,.78)` → `rgba(30,30,27,.66)`, blur 24 / saturation 1.8, border `rgba(255,255,255,.08)`, inner top highlight `rgba(255,255,255,.06)`, shadow `0 14px 34px -10px rgba(0,0,0,.6)`, active capsule `#E5717A` 16%→10%, idle ink `#A9A390`, active ink `#E5717A`.

## Route map (proposed)
| Route | Screen | Presentation |
|---|---|---|
| `/splash` | S01 | root |
| `/welcome`, `/sign-up`, `/sign-up/verify`, `/sign-up/password`, `/sign-in`, `/forgot-password`, `/forgot-password/sent` | Auth | push |
| `/onboarding`, `/profile-setup` | S05, S06 | replace |
| `/dashboard`, `/journal`, `/calendar`, `/analytics` | tabs | shell branches |
| `/trades/:id` | S10 Trade Detail | push over the shell (pill visible) |
| `/review/:weekStart` | S15 Weekly Review | push |
| `/settings`, `/settings/theme` | S14, S14a | push (from the Dashboard gear) |
| `/profile` | S16 Profile | push (from the Dashboard avatar) |
| Share card | Trade share image | system share sheet |
| Period / sort / colour pickers | radio-row sheets | modal bottom sheet |
| Log Trade | Quick log / full form | modal bottom sheet |
| Day drawer | S11b | modal bottom sheet (40%) |

## Sheets & dialogs
- Modal bottom sheets have a grab handle, a scrim `rgba(45,45,42,.35)`, top radius 16, and drag-to-dismiss.
- Log Trade with unsaved fields asks "Discard this trade?" (Discard is destructive; Keep editing).
- Day drawer: "See all N trades in Journal" opens the Journal filtered to that date.

## Gestures
- Trade rows: swipe **right = edit** (slate), swipe **left = delete** (`#9B2226`) with confirmation and a heavy haptic.
- Calendar: swipe left or right to change month (300ms slide, light haptic). Future days aren't tappable.
- Onboarding: horizontal swipe between slides.
- Press states: scale 0.97 and darken one step. Focus ring 2px `#848FA5` at offset 2.

## iPad
- The tab bar is replaced by a **248pt permanent sidebar**; see `03-screens.md`. The centre ＋ becomes a labelled **Log Trade** button.
- Journal uses a master–detail layout (420pt list + detail).
- Switch layouts by **width**, not platform [D25]: < 600 phone pill · 600–1023 icon-only 72pt sidebar, single pane · ≥ 1024 248pt sidebar, two panes. The same rules apply to Android tablets.

## Sign out & delete account
- **Sign out** [D33]: flush the sync queue → wipe the local DB and cached files → go to Welcome. If changes are still unsynced (offline or failed), warn first.
- **Delete account** [D30]: offer a CSV export → confirm → Edge Function deletes everything immediately → go to Welcome.
- No screen past Welcome or auth is reachable while signed out.

## Notifications
- **Daily Reminder** at the chosen time (default 21:00).
- **Weekly Performance Summary**: Sunday 18:00 local; tapping it opens the Weekly Review [D17].
