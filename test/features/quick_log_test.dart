import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pippal/core/theme/app_theme.dart';
import 'package:pippal/core/widgets/buttons.dart';
import 'package:pippal/domain/instruments/instrument.dart';
import 'package:pippal/features/log_trade/log_trade_sheet.dart';

void main() {
  group('Instruments', () {
    test('classifies asset classes (pips only for forex and metals)', () {
      expect(Instruments.classify('EUR/USD'), AssetClass.forex);
      expect(Instruments.classify('XAU/USD'), AssetClass.metals);
      expect(Instruments.classify('BTC/USD'), AssetClass.crypto);
      expect(Instruments.classify('AAPL'), AssetClass.stocks);
      expect(AssetClass.crypto.usesPips, isFalse);
      expect(AssetClass.metals.usesPips, isTrue);
    });

    test('normalises typed symbols', () {
      expect(Instruments.normalise(' eurusd '), 'EUR/USD');
      expect(Instruments.normalise('aapl'), 'AAPL');
      expect(Instruments.normalise('btc/usd'), 'BTC/USD');
    });
  });

  group('QuickLogSheet', () {
    QuickLogDraft? saved;

    Future<void> pump(WidgetTester tester, {bool canSave = false}) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(402, 1000);
      addTearDown(tester.view.reset);
      saved = null;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: QuickLogSheet(onSave: canSave ? (d) => saved = d : null),
          ),
        ),
      );
    }

    PrimaryButton save(WidgetTester tester) =>
        tester.widget<PrimaryButton>(find.byType(PrimaryButton));

    testWidgets('Save is disabled when trades cannot be stored', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(find.text('EUR/USD'));
      await tester.tap(find.text('BUY'));
      await tester.enterText(find.byType(TextField), '96');
      await tester.pump();
      expect(save(tester).onPressed, isNull);
    });

    testWidgets('Save enables once instrument, direction and result are set', (
      tester,
    ) async {
      await pump(tester, canSave: true);
      expect(save(tester).onPressed, isNull);
      await tester.tap(find.text('EUR/USD'));
      await tester.tap(find.text('SELL'));
      await tester.pump();
      expect(save(tester).onPressed, isNull);
      await tester.enterText(find.byType(TextField), '-42.5');
      await tester.pump();
      save(tester).onPressed!();
      expect(saved!.instrument, 'EUR/USD');
      expect(saved!.direction, Direction.sell);
      expect(saved!.result, -42.5); // typed "-" flips the sign
      expect(saved!.unit, ResultUnit.dollars);
      expect(saved!.followedPlan, isNull); // optional, unset by default
    });

    testWidgets('amount is shown at 2 dp once the field loses focus', (
      tester,
    ) async {
      await pump(tester);
      await tester.enterText(find.byType(TextField), '42.5');
      await tester.pump();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      expect(find.text('42.50'), findsOneWidget);
    });

    testWidgets('pips unit is hidden for crypto', (tester) async {
      await pump(tester);
      expect(find.text('pips'), findsOneWidget);
      await tester.tap(find.text('BTC/USD'));
      await tester.pump();
      expect(find.text('pips'), findsNothing);
    });

    testWidgets('answering No reveals reason chips; tapping again clears', (
      tester,
    ) async {
      await pump(tester);
      expect(find.text('Chased entry'), findsNothing);
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();
      expect(find.text('Chased entry'), findsOneWidget);
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();
      expect(find.text('Chased entry'), findsNothing);
    });
  });
}
