import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pippal/core/theme/app_theme.dart';
import 'package:pippal/core/widgets/surfaces.dart';

void main() {
  testWidgets('chips and tags shrink-wrap inside a Wrap', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: Wrap(
              children: [
                PipChip(label: 'EUR/USD', selected: true, onTap: () {}),
                const PipTag('BUY'),
              ],
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(PipChip)).width, lessThan(200));
    expect(tester.getSize(find.byType(PipChip)).height, 32);
    expect(tester.getSize(find.byType(PipTag)).width, lessThan(100));
    expect(tester.getSize(find.byType(PipTag)).height, 24);
  });
}
