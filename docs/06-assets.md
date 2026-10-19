# 06 · Assets

Sources: `claude/README.md` (Brand mark, Assets), `claude/PipPal Logo.dc.html` (exploration, turns 1–6; chosen mark **5a**), `claude/PipPal Screens.dc.html` (icons), `claude/motion-steps-piece.jsx` + `claude/Motion Steps.dc.html` (splash).

Suggested location: `assets/svg/…`, rendered with `flutter_svg`. Swap colours at runtime through `ColorFilter` or `SvgTheme`/`colorMapper` so dark mode and the user's P&L colours apply.

## Logo 5a: geometric "P" + candlestick
viewBox `30 -1 83 118` (aspect 83:118).
```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="30 -1 83 118">
  <path d="M32 2 H52 V100 L32 116 Z" fill="#2D2D2A"/>                               <!-- stem -->
  <path d="M52 14 A35 35 0 0 1 52 84 L52 64 A15 15 0 0 0 52 34 Z" fill="#2D2D2A"/> <!-- bowl -->
  <rect x="98" y="22" width="4" height="54" fill="#2A9D5C"/>                         <!-- wick -->
  <rect x="89" y="34" width="22" height="30" fill="#2A9D5C"/>                        <!-- body -->
</svg>
```
- Dark mode: ink → `#E5DCC5`, candle → `#4DBF7F`. One-colour: everything in ink.
- In-app header size ≈ 18.3×26.
- ⚑ **Candle colour awaits the owner [D6].** Design recommends **crimson `#C14953`** (dark `#E5717A`?); the README/in-app header currently use green `#2A9D5C`. Define the candle colour **once** (one constant + the SVG asset) and use it everywhere: header, splash, app icon, share card. Update this section and `claude/README.md` when decided.

## Splash animation (S01): 2.0s, plays once
Scenes (`window.OM_SCENES`): **Stem** 0.7s · **Bowl** 0.7s · **Candle** 0.6s → cues at 0.0 / 0.7 / 1.4s.
Offsets are in **mark units** (the 1080 stage scales the mark ×6, so the README's "px" means mark units):
| Part | Property | From → To | Window (s) | Curve |
|---|---|---|---|---|
| Stem | translateY | +172 → 0 | 0.04 → 0.66 | easeOutExpo |
| Bowl | translateX | +138 → 0 | 0.60 → 1.26 (starts 0.1s early, overlapping the stem settle) | easeOutQuart |
| Candle | opacity | 0 → 1 | 1.42 → 1.84 | easeOutCubic |
| Candle | translateY | +10 → 0 | 1.42 → 1.92 | easeOutCubic |
Background `#F5F1E8`. Show the "TRADING JOURNAL" caption and a thin crimson progress line. Implement with an `AnimationController` (2000ms) and `Interval` curves (Flutter has `Curves.easeOutExpo`, `easeOutQuart` and `easeOutCubic`), or with Lottie/Rive. Clip the stage so the stem rises from the edge of the frame. Then route: signed out → Welcome, signed in → Dashboard. Also configure the native splash (`flutter_native_splash`) to match `#F5F1E8` so there's no flash.

## Tab-bar icons: custom, 24×24 grid, stroke 1.75, round caps and joins
Idle: stroke `#5E5E57`, no fill. Active: stroke and fill `#A03B44`, interior details in white.
```text
Dashboard (house)   path  M3.5 10.2 12 3.5l8.5 6.7V19a1.5 1.5 0 0 1-1.5 1.5h-4v-6h-6v6H5A1.5 1.5 0 0 1 3.5 19z
                    active: same path, fill #A03B44

Journal (notebook)  path  M5 19.5V4.5A1.5 1.5 0 0 1 6.5 3H19v15H6.5A1.5 1.5 0 0 0 5 19.5a1.5 1.5 0 0 0 1.5 1.5H19
                    path  M9 7.5h6M9 11h4                     (text lines)
                    active: first path filled #A03B44, text lines stroke #fff

Calendar            rect  x=3.5 y=5 w=17 h=15.5 rx=3
                    path  M8 3v4M16 3v4                       (rings)
                    path  M3.5 10h17                          (header rule)
                    circle cx=12 cy=15 r=1.3, fill, no stroke  ("today" dot)
                    active: rect filled #A03B44, rule stroke #fff, dot fill #fff

Analytics (bars)    rect  x=4  y=12  w=4 h=8.5  rx=1.4
                    rect  x=10 y=4   w=4 h=16.5 rx=1.4
                    rect  x=16 y=8.5 w=4 h=12   rx=1.4
                    active: all rects filled #A03B44

Centre ＋            path M12 5v14 · M5 12h14, stroke #fff 2.4, 22px, on the crimson gradient circle
```
iPad sidebar uses the same glyphs at 22pt.

## Emotion icons: drawn line set (chosen over emoji)
24 viewBox, stroke 1.8, round caps. Unselected `#4C4C47`; selected shown in crimson `#C14953` (Confident in the sample).
```text
Confident   M5 15h14 · M9 9h.01M15 9h.01 · M4 19V9a8 8 0 0 1 16 0v10
Neutral     M6 15h12 · M9 9h.01M15 9h.01 · rect x4 y4 w16 h16 rx4
Anxious     M7 17c1.5-2 3-3 5-3s3.5 1 5 3 · M8 8l3 2M16 8l-3 2 · M4 20V10a8 8 0 0 1 16 0v10
Frustrated  M8 16h8 · M7 9l3 1M17 9l-3 1 · M4 19V11a8 8 0 0 1 16 0v8
Focused     circle r9 · circle r5 · circle r1.4 filled   (all at 12,12; no round caps)
```

## Other UI icons
Lucide-style strokes; the **Lucide** set is an acceptable source (e.g. the `lucide_icons_flutter` package, or exported SVGs). Seen in the designs: settings gear, search, filter, chevrons, back arrow, edit pencil, more/ellipsis, eye/eye-off, mail, check, alert, camera/image, trend arrows.

## Third-party marks
Apple and Google sign-in buttons must use the **official brand assets** and follow their button guidelines.

## Fonts
**Inter**, weights 400/500/600/700. Bundle it (preferred, so it works offline and avoids runtime fetches) or use `google_fonts`. Make sure the tabular-figure (`tnum`) feature is available in the bundled files.

## Illustrations
There's **no photography**. Hero and empty-state illustrations are dashed placeholders waiting for artwork ("Illustration placeholder — awaiting brand asset"). Onboarding art is built from real app widgets with sample data, not images.

## App icon
The share card [D21] also uses the logo.

Logo 5a centred on a white ground at 62% of the 1024px canvas (iOS keyline). There are light, dark and tinted variants (iOS 18+).

✅ **Done (18 Oct 2026).** The pipeline:
1. `python3 tool/generate_icon_masters.py` (needs Pillow) draws the exact vector into `assets/icon/`:
   - `app_icon.png`: white, 62%
   - `android_foreground.png`: transparent, 46% so it fits the adaptive safe zone
   - `android_monochrome.png`: Android 13 themed icon
   - `ios_dark.png` and `ios_tinted.png`
2. `dart run flutter_launcher_icons` writes every Android mipmap/adaptive icon and the iOS `AppIcon.appiconset`. The config is in `pubspec.yaml`. The foreground inset is 0 because the master is pre-sized.
3. **If the candle colour changes (D6):** update `CANDLE` in the script and `BrandMark` in `tokens.dart`, then re-run steps 1–2.

The app's display name is **PipPal** on both platforms (Android `android:label`, iOS `CFBundleDisplayName`/`CFBundleName`).
