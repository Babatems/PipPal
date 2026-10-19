import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/surfaces.dart';
import '../../../domain/journal/journal_providers.dart';

/// Below this many trades Analytics shows its empty state (decision D14);
/// from here to 29 trades numbers carry a "Provisional" tag.
const analyticsMinimumTrades = 5;

/// S13 — Analytics.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(tradeCountProvider);
    return TabScaffold(
      appBar: const PipAppBar(title: 'Analytics'),
      body: count < analyticsMinimumTrades
          ? EmptyState(
              title: 'Not enough data yet',
              body:
                  'Log at least $analyticsMinimumTrades trades to see your win '
                  'rate, profit factor and average R.',
              footer: _TradeProgress(count: count),
            )
          : const SizedBox.shrink(),
    );
  }
}

/// "2 / 5 trades logged" with a segmented progress track.
class _TradeProgress extends StatelessWidget {
  const _TradeProgress({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: '$count of $analyticsMinimumTrades trades logged',
      excludeSemantics: true,
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < analyticsMinimumTrades; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Container(
                  width: 28,
                  height: 4,
                  decoration: BoxDecoration(
                    color: i < count ? c.crimson : c.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$count / $analyticsMinimumTrades trades logged',
            style: AppTypography.bodySmall.copyWith(color: c.textMuted),
          ),
        ],
      ),
    );
  }
}
