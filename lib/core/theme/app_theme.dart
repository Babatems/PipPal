import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pnl_colors.dart';
import 'tokens.dart';
import 'typography.dart';

abstract final class AppTheme {
  static ThemeData light({PnlColors? pnl}) =>
      _build(Brightness.light, PipColors.light, pnl ?? PnlColors.light);

  static ThemeData dark({PnlColors? pnl}) =>
      _build(Brightness.dark, PipColors.dark, pnl ?? PnlColors.dark);

  static ThemeData _build(Brightness brightness, PipColors c, PnlColors pnl) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.crimson,
      onPrimary: Colors.white,
      secondary: c.textMuted,
      onSecondary: Colors.white,
      error: c.crimson,
      onError: Colors.white,
      surface: c.surface,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      surfaceContainerHighest: c.surface2,
      outline: c.border,
      outlineVariant: c.divider,
      scrim: c.scrim,
    );
    final text = AppTypography.textTheme(
      primary: c.textPrimary,
      secondary: c.textSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: AppTypography.family,
      textTheme: text,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      dividerColor: c.divider,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      extensions: [c, pnl],
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.headlineLarge,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      dividerTheme: DividerThemeData(color: c.divider, thickness: 1, space: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        modalBarrierColor: c.scrim,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Radii.sheet),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.dialog),
        ),
        titleTextStyle: text.headlineSmall,
        contentTextStyle: text.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.toast,
        contentTextStyle: text.bodyMedium?.copyWith(color: c.onToast),
        actionTextColor: isDark ? c.crimsonText : const Color(0xFFE5717A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.crimson,
        selectionColor: c.crimson.withValues(alpha: 0.2),
        selectionHandleColor: c.crimson,
      ),
    );
  }
}

extension ThemeContext on BuildContext {
  PipColors get colors => Theme.of(this).extension<PipColors>()!;
  PnlColors get pnl => Theme.of(this).extension<PnlColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
}
