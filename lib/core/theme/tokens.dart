import 'package:flutter/material.dart';

/// Spacing scale, 4pt base (docs/02-design-system.md).
abstract final class Space {
  static const double xxs = 2;
  static const double xs = 4;
  static const double s = 8;
  static const double sm = 12;
  static const double m = 16; // phone screen + card padding
  static const double ml = 20;
  static const double l = 24; // between sections, auth side padding
  static const double xl = 32; // iPad screen padding
  static const double xxl = 40;
  static const double xxxl = 48;
  static const double huge = 64;

  /// Scroll views on tab screens clear the floating glass tab bar.
  static const double tabBarClearance = 120;
}

abstract final class Radii {
  static const double tag = 6;
  static const double chip = 8;
  static const double segmented = 10;
  static const double segmentedInner = 8;
  static const double card = 12; // cards, fields, buttons
  static const double sheet = 16; // top corners
  static const double dialog = 16;
  static const double artStage = 28;
  static const double tabBar = 32;
}

/// Brand mark colours. The candle colour is awaiting the product owner
/// (decision D6: green per the handoff README vs. crimson per the logo file).
/// Change it here only — every logo, splash and share card reads this.
abstract final class BrandMark {
  static const Color candleLight = Color(0xFF2A9D5C);
  static const Color candleDark = Color(0xFF4DBF7F);
}

/// Semantic colour tokens. Widgets read these via `context.colors`, never
/// as constants, so light/dark (and later user overrides) apply everywhere.
@immutable
class PipColors extends ThemeExtension<PipColors> {
  const PipColors({
    required this.background,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.navIdle,
    required this.navActive,
    required this.crimson,
    required this.crimsonText,
    required this.destructive,
    required this.skeleton,
    required this.skeletonHighlight,
    required this.calendarBlank,
    required this.calendarBlankText,
    required this.scrim,
    required this.note,
    required this.handle,
    required this.hint,
    required this.toast,
    required this.onToast,
    required this.logoInk,
    required this.logoCandle,
    required this.glass,
  });

  final Color background;
  final Color surface;
  final Color surface2;
  final Color border;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;

  /// Slate. Captions ≤13px only — fails AA for body text.
  final Color textMuted;
  final Color navIdle;
  final Color navActive;

  /// Brand / CTA / FAB. Also the default loss colour (see PnlColors).
  final Color crimson;

  /// Crimson text on tints and glass (base crimson is only 3.71:1 there).
  final Color crimsonText;
  final Color destructive;
  final Color skeleton;
  final Color skeletonHighlight;
  final Color calendarBlank;
  final Color calendarBlankText;
  final Color scrim;

  /// Inline info note background (Quick log footnote).
  final Color note;

  /// Bottom-sheet grab handle.
  final Color handle;

  /// Input placeholder text.
  final Color hint;
  final Color toast;
  final Color onToast;
  final Color logoInk;
  final Color logoCandle;
  final GlassStyle glass;

  static const light = PipColors(
    background: Color(0xFFF5F1E8),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFE5DCC5),
    border: Color(0xFFE0D9C5),
    divider: Color(0xFFF0EBDD),
    textPrimary: Color(0xFF2D2D2A),
    textSecondary: Color(0xFF4C4C47),
    textMuted: Color(0xFF848FA5),
    navIdle: Color(0xFF5E5E57),
    navActive: Color(0xFFA03B44),
    crimson: Color(0xFFC14953),
    crimsonText: Color(0xFFA03B44),
    destructive: Color(0xFF9B2226),
    skeleton: Color(0xFFD4CDB9),
    skeletonHighlight: Color(0xFFE5DFD0),
    calendarBlank: Color(0xFFEDE7D6),
    calendarBlankText: Color(0xFFB8B0A0),
    scrim: Color(0x592D2D2A), // rgba(45,45,42,.35)
    note: Color(0xFFFBF9F3),
    handle: Color(0xFFD8CFB8),
    hint: Color(0xFF9A968B),
    toast: Color(0xFF2D2D2A),
    onToast: Color(0xFFFFFFFF),
    logoInk: Color(0xFF2D2D2A),
    logoCandle: BrandMark.candleLight,
    glass: GlassStyle.light,
  );

  static const dark = PipColors(
    background: Color(0xFF1E1E1B),
    surface: Color(0xFF2D2D2A),
    surface2: Color(0xFF3A3A36),
    border: Color(0xFF3D3D39),
    divider: Color(0xFF353531),
    textPrimary: Color(0xFFE5DCC5),
    textSecondary: Color(0xFFB5AE99),
    textMuted: Color(0xFFA0ADBE),
    navIdle: Color(0xFFA9A390),
    navActive: Color(0xFFE5717A),
    crimson: Color(0xFFE5717A),
    crimsonText: Color(0xFFE5717A),
    destructive: Color(0xFF9B2226),
    skeleton: Color(0xFF2D2D2A),
    skeletonHighlight: Color(0xFF3A3A36),
    calendarBlank: Color(0xFF262623),
    calendarBlankText: Color(0xFF6E6A5E),
    scrim: Color(0x99000000),
    note: Color(0xFF33332F),
    handle: Color(0xFF4A4A44),
    hint: Color(0xFF8A8576),
    toast: Color(0xFFE5DCC5),
    onToast: Color(0xFF1E1E1B),
    logoInk: Color(0xFFE5DCC5),
    logoCandle: BrandMark.candleDark,
    glass: GlassStyle.dark,
  );

  @override
  PipColors copyWith({Color? logoCandle}) => PipColors(
    background: background,
    surface: surface,
    surface2: surface2,
    border: border,
    divider: divider,
    textPrimary: textPrimary,
    textSecondary: textSecondary,
    textMuted: textMuted,
    navIdle: navIdle,
    navActive: navActive,
    crimson: crimson,
    crimsonText: crimsonText,
    destructive: destructive,
    skeleton: skeleton,
    skeletonHighlight: skeletonHighlight,
    calendarBlank: calendarBlank,
    calendarBlankText: calendarBlankText,
    scrim: scrim,
    note: note,
    handle: handle,
    hint: hint,
    toast: toast,
    onToast: onToast,
    logoInk: logoInk,
    logoCandle: logoCandle ?? this.logoCandle,
    glass: glass,
  );

  @override
  PipColors lerp(PipColors? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return PipColors(
      background: c(background, other.background),
      surface: c(surface, other.surface),
      surface2: c(surface2, other.surface2),
      border: c(border, other.border),
      divider: c(divider, other.divider),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textMuted: c(textMuted, other.textMuted),
      navIdle: c(navIdle, other.navIdle),
      navActive: c(navActive, other.navActive),
      crimson: c(crimson, other.crimson),
      crimsonText: c(crimsonText, other.crimsonText),
      destructive: c(destructive, other.destructive),
      skeleton: c(skeleton, other.skeleton),
      skeletonHighlight: c(skeletonHighlight, other.skeletonHighlight),
      calendarBlank: c(calendarBlank, other.calendarBlank),
      calendarBlankText: c(calendarBlankText, other.calendarBlankText),
      scrim: c(scrim, other.scrim),
      note: c(note, other.note),
      handle: c(handle, other.handle),
      hint: c(hint, other.hint),
      toast: c(toast, other.toast),
      onToast: c(onToast, other.onToast),
      logoInk: c(logoInk, other.logoInk),
      logoCandle: c(logoCandle, other.logoCandle),
      glass: t < 0.5 ? glass : other.glass,
    );
  }
}

/// Floating glass tab bar recipe (docs/04-navigation-and-flows.md).
@immutable
class GlassStyle {
  const GlassStyle({
    required this.top,
    required this.bottom,
    required this.border,
    required this.ring,
    required this.highlight,
    required this.shadows,
    required this.capsuleTop,
    required this.capsuleBottom,
    required this.capsuleRing,
  });

  final Color top;
  final Color bottom;
  final Color border;
  final Color ring;
  final Color highlight;
  final List<BoxShadow> shadows;
  final Color capsuleTop;
  final Color capsuleBottom;
  final Color capsuleRing;

  static const double blur = 24;
  static const double saturation = 1.8;

  static const light = GlassStyle(
    top: Color(0xBDFFFFFF), // .74
    bottom: Color(0x8FFAF7F0), // .56
    border: Color(0xE6FFFFFF), // .9
    ring: Color(0x142D2D2A), // .08, drawn as a 0.5pt outline
    highlight: Color(0xF2FFFFFF), // .95
    shadows: [
      BoxShadow(
        color: Color(0x472D2D2A), // .28
        offset: Offset(0, 14),
        blurRadius: 34,
        spreadRadius: -10,
      ),
      BoxShadow(
        color: Color(0x0F2D2D2A), // .06
        offset: Offset(0, 2),
        blurRadius: 6,
      ),
    ],
    capsuleTop: Color(0x24C14953), // 14%
    capsuleBottom: Color(0x14C14953), // 8%
    capsuleRing: Color(0x2EC14953), // 18%
  );

  static const dark = GlassStyle(
    top: Color(0xC72D2D2A), // .78
    bottom: Color(0xA81E1E1B), // .66
    border: Color(0x14FFFFFF), // .08
    ring: Color(0x14FFFFFF),
    highlight: Color(0x0FFFFFFF), // .06
    shadows: [
      BoxShadow(
        color: Color(0x99000000), // .6
        offset: Offset(0, 14),
        blurRadius: 34,
        spreadRadius: -10,
      ),
    ],
    capsuleTop: Color(0x29E5717A), // 16%
    capsuleBottom: Color(0x1AE5717A), // 10%
    capsuleRing: Color(0x2EE5717A),
  );
}

/// Shadows are reserved for these three surfaces; cards use a 1px border.
abstract final class Elevations {
  static const sheet = [
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, -4), blurRadius: 24),
  ];
  static const primary = [
    BoxShadow(
      color: Color(0x99C14953),
      offset: Offset(0, 6),
      blurRadius: 16,
      spreadRadius: -8,
    ),
  ];
}
