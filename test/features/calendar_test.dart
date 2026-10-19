import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pippal/core/theme/app_theme.dart';
import 'package:pippal/core/utils/clock.dart';
import 'package:pippal/features/calendar/application/calendar_controller.dart';
import 'package:pippal/features/calendar/presentation/calendar_screen.dart';

void main() {
  group('MonthGrid (Monday-first, D31)', () {
    test('July 2026 starts on a Wednesday: two leading blanks', () {
      final g = MonthGrid.of(DateTime(2026, 7));
      expect(g.leadingBlanks, 2);
      expect(g.days, 31);
      expect(g.rows, 5);
    });

    test('a month starting on Monday has no blanks', () {
      expect(MonthGrid.of(DateTime(2026, 6)).leadingBlanks, 0);
    });

    test('a month starting on Sunday has six blanks', () {
      final g = MonthGrid.of(DateTime(2026, 2)); // 1 Feb 2026 is a Sunday
      expect(g.leadingBlanks, 6);
      expect(g.days, 28);
      expect(g.rows, 5);
    });

    test('leap February', () {
      expect(MonthGrid.of(DateTime(2028, 2)).days, 29);
    });
  });

  group('CalendarScreen', () {
    Future<ProviderContainer> pump(WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(402, 874);
      addTearDown(tester.view.reset);
      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(() => DateTime(2026, 7, 14, 9)),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(body: CalendarScreen()),
          ),
        ),
      );
      return container;
    }

    testWidgets('shows the current month with an honest empty summary', (
      tester,
    ) async {
      await pump(tester);
      expect(find.text('July 2026'), findsOneWidget);
      expect(find.text('TRADING DAYS'), findsOneWidget);
      expect(find.text('—'), findsOneWidget); // no best day yet
      expect(find.text('31'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp(r'Tuesday, July 14.*today')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'Wednesday, July 15, upcoming')),
        findsOneWidget,
      );
    });

    testWidgets('cannot move past the current month; can go back', (
      tester,
    ) async {
      final container = await pump(tester);
      await tester.tap(find.bySemanticsLabel('Next month'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(container.read(calendarMonthProvider), DateTime(2026, 7));

      await tester.tap(find.bySemanticsLabel('Previous month'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('June 2026'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Next month'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('July 2026'), findsOneWidget);
    });
  });
}
