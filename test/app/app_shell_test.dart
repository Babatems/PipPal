import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pippal/app/app.dart';
import 'package:pippal/app/shell/glass_tab_bar.dart';
import 'package:pippal/app/shell/side_navigation.dart';
import 'package:pippal/core/utils/clock.dart';

const dashboardText = 'Your journal starts here';
const journalText = 'Ready to log your first trade?';
const analyticsText = 'Not enough data yet';

Future<void> pumpApp(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [clockProvider.overrideWithValue(() => DateTime(2026, 7, 14))],
      child: const PipPalApp(),
    ),
  );
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  group('phone (402×874)', () {
    const phone = Size(402, 874);

    testWidgets('starts on Dashboard with the glass tab bar', (tester) async {
      await pumpApp(tester, phone);
      expect(find.byType(GlassTabBar), findsOneWidget);
      expect(find.byType(SideNavigation), findsNothing);
      expect(find.text(dashboardText), findsOneWidget);
      // No developer tooling is reachable from the UI.
      expect(find.bySemanticsLabel('Design system preview'), findsNothing);
      expect(find.text('Foundations'), findsNothing);
    });

    testWidgets('tapping a tab switches branch', (tester) async {
      await pumpApp(tester, phone);
      final journalTab = find.descendant(
        of: find.byType(GlassTabBar),
        matching: find.text('Journal'),
      );
      await tester.tap(journalTab);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(journalText), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(GlassTabBar),
          matching: find.text('Analytics'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(analyticsText), findsOneWidget);
      expect(find.text('0 / 5 trades logged'), findsOneWidget);
    });

    testWidgets('the previous tab actually fades out (regression)', (
      tester,
    ) async {
      await pumpApp(tester, phone);
      Finder tab(String l) =>
          find.descendant(of: find.byType(GlassTabBar), matching: find.text(l));
      // The opacity actually rendered by the shell's per-branch fade.
      double renderedOpacity(String text) {
        double? value;
        FadeTransition? nearest;
        find
            .text(text, skipOffstage: false)
            .evaluate()
            .first
            .visitAncestorElements((e) {
              final w = e.widget;
              if (w is FadeTransition) nearest = w;
              if (w is AnimatedOpacity) {
                value = nearest!.opacity.value;
                return false;
              }
              return true;
            });
        return value!;
      }

      // One frame starts each fade, the next lets the 200ms fade complete.
      await tester.tap(tab('Journal'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(tab('Dashboard'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(renderedOpacity(journalText), 0);
      expect(renderedOpacity(dashboardText), 1);
    });

    testWidgets('empty-state CTA opens the Quick log sheet', (tester) async {
      await pumpApp(tester, phone);
      await tester.tap(find.text('Log your first trade'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Quick log'), findsOneWidget);
    });

    testWidgets('centre + opens the Quick log sheet', (tester) async {
      await pumpApp(tester, phone);
      await tester.tap(find.bySemanticsLabel('Log trade'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Quick log'), findsOneWidget);
      expect(find.text('Save trade'), findsOneWidget);
    });
  });

  testWidgets('every tab and the Quick log hold up at 1.5× text (spec §11.4)', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpApp(tester, const Size(402, 874));
    for (final tab in ['Journal', 'Calendar', 'Analytics', 'Dashboard']) {
      await tester.tap(
        find.descendant(of: find.byType(GlassTabBar), matching: find.text(tab)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.tap(find.bySemanticsLabel('Log trade'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Quick log'), findsOneWidget);
    // Any RenderFlex overflow surfaces as an exception and fails the test.
  });

  testWidgets('600–1023 wide uses the icon-only rail', (tester) async {
    await pumpApp(tester, const Size(820, 1180));
    expect(find.byType(GlassTabBar), findsNothing);
    final nav = tester.widget<SideNavigation>(find.byType(SideNavigation));
    expect(nav.expanded, isFalse);
    expect(find.text('Log Trade'), findsNothing);
  });

  testWidgets('≥1024 wide uses the 248pt sidebar', (tester) async {
    await pumpApp(tester, const Size(1366, 1024));
    final nav = tester.widget<SideNavigation>(find.byType(SideNavigation));
    expect(nav.expanded, isTrue);
    expect(tester.getSize(find.byType(SideNavigation)).width, 248);
    expect(find.text('Log Trade'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(SideNavigation),
        matching: find.text('Calendar'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('July 2026'), findsOneWidget);
  });
}
