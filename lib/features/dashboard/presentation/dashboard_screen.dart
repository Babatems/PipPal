import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/pip_icons.dart';
import '../../../core/widgets/surfaces.dart';
import '../../../domain/journal/journal_providers.dart';
import '../../log_trade/log_trade_sheet.dart';

/// S07 — Dashboard. The populated layout (equity curve, metric cards, recent
/// trades) lands with journal data; an empty journal shows the drawn
/// "no trades ever" state.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final count = ref.watch(tradeCountProvider);
    return TabScaffold(
      appBar: PipAppBar(
        leading: PipLogo(ink: c.logoInk, candle: c.logoCandle, height: 26),
      ),
      body: count == 0
          ? EmptyState(
              title: 'Your journal starts here',
              body:
                  'Log one trade and the calendar, equity curve and win rate '
                  'all begin filling in.',
              action: PrimaryButton(
                label: 'Log your first trade',
                expand: false,
                onPressed: () => showLogTradeSheet(context),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
