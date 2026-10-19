import 'package:flutter/material.dart';

/// Inter type scale (docs/02-design-system.md).
///
/// Tabular figures are applied to *every* style so no number can ever render
/// proportionally — Inter's `tnum` only changes digits, so prose is unaffected.
abstract final class AppTypography {
  static const family = 'Inter';
  static const _tnum = [FontFeature.tabularFigures()];

  static TextStyle _s(
    double size,
    double line,
    FontWeight weight, {
    double tracking = 0,
  }) => TextStyle(
    fontFamily: family,
    fontSize: size,
    height: line / size,
    fontWeight: weight,
    letterSpacing: tracking * size,
    fontFeatures: _tnum,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static final displayLarge = _s(32, 38, FontWeight.w700, tracking: -0.02);
  static final displayMedium = _s(26, 32, FontWeight.w600);
  static final headlineLarge = _s(22, 28, FontWeight.w600);
  static final headlineMedium = _s(20, 26, FontWeight.w600);
  static final headlineSmall = _s(18, 24, FontWeight.w500);
  static final titleMedium = _s(16, 22, FontWeight.w500);
  static final bodyLarge = _s(15, 22, FontWeight.w400);
  static final bodyMedium = _s(14, 20, FontWeight.w400);
  static final bodySmall = _s(13, 18, FontWeight.w400);
  static final labelLarge = _s(12, 16, FontWeight.w500);
  static final labelSmall = _s(11, 14, FontWeight.w400);

  /// CAPS labels ("TOTAL PIPS", "TODAY · TUE 14 JUL"): labelSmall + tracking.
  static final capsLabel = _s(11, 14, FontWeight.w400, tracking: 0.08);

  /// Auth field labels: 13/500.
  static final fieldLabel = _s(13, 18, FontWeight.w500);

  /// Buttons: 15/500 (regular), 16/600 (large form CTAs).
  static final button = _s(15, 18, FontWeight.w500);
  static final buttonLarge = _s(16, 20, FontWeight.w600);

  /// Chips 13/500, tags 12/500.
  static final chip = _s(13, 18, FontWeight.w500);
  static final tag = _s(12, 16, FontWeight.w500);

  /// Bottom tab bar only: 10/12, 500 idle / 600 active.
  static final tabLabel = _s(10, 12, FontWeight.w500, tracking: 0.01);

  static TextTheme textTheme({
    required Color primary,
    required Color secondary,
  }) => TextTheme(
    displayLarge: displayLarge.copyWith(color: primary),
    displayMedium: displayMedium.copyWith(color: primary),
    headlineLarge: headlineLarge.copyWith(color: primary),
    headlineMedium: headlineMedium.copyWith(color: primary),
    headlineSmall: headlineSmall.copyWith(color: primary),
    titleMedium: titleMedium.copyWith(color: primary),
    titleSmall: fieldLabel.copyWith(color: primary),
    bodyLarge: bodyLarge.copyWith(color: primary),
    bodyMedium: bodyMedium.copyWith(color: secondary),
    bodySmall: bodySmall.copyWith(color: secondary),
    labelLarge: labelLarge.copyWith(color: primary),
    labelMedium: capsLabel.copyWith(color: secondary),
    labelSmall: labelSmall.copyWith(color: secondary),
  );
}
