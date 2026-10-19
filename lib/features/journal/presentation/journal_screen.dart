import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/surfaces.dart';
import '../../../domain/journal/journal_providers.dart';
import '../../log_trade/log_trade_sheet.dart';

/// S09 — Journal. First-time empty state per spec §8 Screen 10.
class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(tradeCountProvider);
    return TabScaffold(
      appBar: const PipAppBar(title: 'Journal'),
      body: count == 0
          ? EmptyState(
              title: 'Ready to log your first trade?',
              body:
                  'Every trade you log lands here, grouped by day with that '
                  "day's P&L.",
              action: PrimaryButton(
                label: 'Log a trade',
                expand: false,
                onPressed: () => showLogTradeSheet(context),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
