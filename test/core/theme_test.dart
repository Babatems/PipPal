import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pippal/core/layout/breakpoints.dart';
import 'package:pippal/core/theme/app_theme.dart';
import 'package:pippal/core/theme/pnl_colors.dart';
import 'package:pippal/core/theme/tokens.dart';

void main() {
  group('PnlColors', () {
    const p = PnlColors.light;

    test('colour follows the sign of the value', () {
      expect(p.forValue(96), const Color(0xFF2A9D5C));
      expect(p.forValue(-42.5), const Color(0xFFC14953));
      expect(p.forValue(0), const Color(0xFFD4854A));
      expect(p.textForValue(1), const Color(0xFF1F7A46));
      expect(p.textForValue(-1), const Color(0xFFA03B44));
    });

    test('default presets keep the hand-tuned text colours', () {
      final o = p.withOverrides(
        profit: PnlColors.defaultProfit,
        loss: PnlColors.defaultLoss,
        brightness: Brightness.light,
      );
      expect(o.profitText, p.profitText);
      expect(o.lossText, p.lossText);
    });

    test('a custom preset replaces the base and derives a text colour', () {
      final o = p.withOverrides(
        profit: const Color(0xFF3B8EA5),
        brightness: Brightness.light,
      );
      expect(o.profit, const Color(0xFF3B8EA5));
      expect(o.profitText, isNot(p.profitText));
      expect(o.loss, p.loss);
    });

    test('there are four presets per side, defaults first', () {
      expect(PnlColors.profitPresets, hasLength(4));
      expect(PnlColors.lossPresets, hasLength(4));
      expect(PnlColors.profitPresets.first, PnlColors.defaultProfit);
      expect(PnlColors.lossPresets.first, PnlColors.defaultLoss);
    });
  });

  group('AppTheme', () {
    test('exposes the token extensions in both brightnesses', () {
      for (final t in [AppTheme.light(), AppTheme.dark()]) {
        expect(t.extension<PipColors>(), isNotNull);
        expect(t.extension<PnlColors>(), isNotNull);
        expect(t.scaffoldBackgroundColor, t.extension<PipColors>()!.background);
      }
      expect(AppTheme.light().scaffoldBackgroundColor, const Color(0xFFF5F1E8));
      expect(AppTheme.dark().scaffoldBackgroundColor, const Color(0xFF1E1E1B));
    });

    test('every text style uses Inter with tabular figures', () {
      final styles = AppTheme.light().textTheme;
      for (final s in [
        styles.displayLarge,
        styles.displayMedium,
        styles.headlineLarge,
        styles.titleMedium,
        styles.bodyLarge,
        styles.bodySmall,
        styles.labelSmall,
      ]) {
        expect(s!.fontFamily, 'Inter');
        expect(s.fontFeatures, contains(const FontFeature.tabularFigures()));
      }
      expect(styles.displayLarge!.fontSize, 32);
      expect(
        styles.displayLarge!.fontSize! * styles.displayLarge!.height!,
        closeTo(38, 0.001),
      );
    });
  });

  test('layout breakpoints (D25)', () {
    expect(LayoutSize.forWidth(402), LayoutSize.compact);
    expect(LayoutSize.forWidth(599), LayoutSize.compact);
    expect(LayoutSize.forWidth(600), LayoutSize.medium);
    expect(LayoutSize.forWidth(1023), LayoutSize.medium);
    expect(LayoutSize.forWidth(1024), LayoutSize.expanded);
    expect(LayoutSize.forWidth(1366), LayoutSize.expanded);
  });
}
