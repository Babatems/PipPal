import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/layout/breakpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/clock.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/pip_icons.dart';
import '../application/calendar_controller.dart';

/// S11 — monthly P&L heatmap. Day results arrive with the journal data in
/// step 2; with no trades every elapsed day reads "No trades", which is the
/// true state of an empty journal.
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(calendarMonthProvider);
    final ctl = ref.read(calendarMonthProvider.notifier);
    final today = DateUtils.dateOnly(ref.watch(clockProvider)());
    final pad = LayoutSize.of(context).screenPadding;

    void go(bool forward) {
      final before = ref.read(calendarMonthProvider);
      forward ? ctl.next() : ctl.previous();
      if (ref.read(calendarMonthProvider) != before) {
        HapticFeedback.lightImpact();
      }
    }

    return TabScaffold(
      appBar: PipAppBar(
        title: 'Calendar',
        bottom: Column(
          children: [
            _MonthNav(
              month: month,
              canGoForward: ctl.canGoForward,
              onPrevious: () => go(false),
              onNext: () => go(true),
            ),
            const _SummaryStrip(tradingDays: 0, winDays: 0, bestDay: null),
          ],
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (d) {
          final v = d.primaryVelocity ?? 0;
          if (v.abs() < 250) return;
          go(v < 0); // swipe left = next month
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            pad,
            14,
            pad,
            TabScaffold.bottomClearance(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _WeekdayHeader(),
              const SizedBox(height: Space.s),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _MonthGridView(
                  key: ValueKey(month),
                  grid: MonthGrid.of(month),
                  today: today,
                ),
              ),
              const SizedBox(height: 14),
              const _Legend(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthNav extends StatelessWidget {
  const _MonthNav({
    required this.month,
    required this.canGoForward,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final bool canGoForward;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pad = LayoutSize.of(context).screenPadding;
    final label = DateFormat.yMMMM().format(month);
    return Container(
      height: 52,
      padding: EdgeInsets.symmetric(horizontal: pad - Space.s),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          PipIconButton(
            icon: ChevronGlyph(left: true, color: c.textSecondary),
            semanticLabel: 'Previous month',
            onPressed: onPrevious,
          ),
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: context.text.headlineMedium,
              ),
            ),
          ),
          PipIconButton(
            icon: ChevronGlyph(left: false, color: c.textSecondary),
            semanticLabel: 'Next month',
            onPressed: canGoForward ? onNext : null,
          ),
        ],
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.tradingDays,
    required this.winDays,
    required this.bestDay,
  });

  final int tradingDays;
  final int winDays;

  /// Best day's P&L, or null when there are no winning days.
  final String? bestDay;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pad = LayoutSize.of(context).screenPadding;
    final winRate = tradingDays == 0
        ? null
        : (winDays / tradingDays * 100).round();

    Widget cell(
      String label,
      String value, {
      Color? color,
      bool last = false,
    }) => Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(
          label == 'TRADING DAYS' ? pad : 14,
          Space.s,
          Space.xs,
          Space.s,
        ),
        decoration: BoxDecoration(
          border: last ? null : Border(right: BorderSide(color: c.border)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(color: c.textMuted),
            ),
            Text(
              value,
              style: AppTypography.bodyLarge.copyWith(
                height: 20 / 15,
                fontWeight: FontWeight.w500,
                color: color ?? c.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );

    // 60pt minimum (as drawn) that grows with large text sizes.
    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            cell('TRADING DAYS', '$tradingDays'),
            cell(
              'WIN DAYS',
              winRate == null ? '$winDays' : '$winDays · $winRate%',
            ),
            cell(
              'BEST DAY',
              bestDay ?? '—',
              color: bestDay == null ? c.textMuted : context.pnl.profit,
              last: true,
            ),
          ],
        ),
      ),
    );
  }
}

const double _gap = 5;

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // 1 Jan 2024 is a Monday; the week always starts Monday (D31).
    final monday = DateTime(2024);
    final narrow = DateFormat.EEEEE();
    final full = DateFormat.EEEE();
    return Row(
      children: [
        for (var i = 0; i < 7; i++) ...[
          if (i > 0) const SizedBox(width: _gap),
          Expanded(
            child: Semantics(
              label: full.format(monday.add(Duration(days: i))),
              excludeSemantics: true,
              child: Text(
                narrow.format(monday.add(Duration(days: i))),
                textAlign: TextAlign.center,
                style: AppTypography.labelSmall.copyWith(color: c.textMuted),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _MonthGridView extends StatelessWidget {
  const _MonthGridView({super.key, required this.grid, required this.today});

  final MonthGrid grid;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var r = 0; r < grid.rows; r++) {
      final cells = <Widget>[];
      for (var col = 0; col < 7; col++) {
        final index = r * 7 + col;
        final day = index - grid.leadingBlanks + 1;
        if (col > 0) cells.add(const SizedBox(width: _gap));
        cells.add(
          Expanded(
            child: index < grid.leadingBlanks
                ? const _DayCell.blank()
                : day <= grid.days
                ? _DayCell(
                    date: DateTime(grid.month.year, grid.month.month, day),
                    today: today,
                  )
                : const SizedBox(height: 52),
          ),
        );
      }
      if (r > 0) rows.add(const SizedBox(height: _gap));
      rows.add(Row(children: cells));
    }
    return Column(children: rows);
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required DateTime this.date, required DateTime this.today});

  const _DayCell.blank() : date = null, today = null;

  final DateTime? date;
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final d = date;
    if (d == null) {
      return Container(
        height: 52,
        decoration: BoxDecoration(
          color: c.calendarBlank,
          borderRadius: BorderRadius.circular(Radii.chip),
        ),
      );
    }
    final isToday = d == today;
    final isFuture = d.isAfter(today!);
    return Semantics(
      label:
          '${DateFormat.MMMMEEEEd().format(d)}, '
          '${isFuture ? 'upcoming' : 'no trades'}${isToday ? ', today' : ''}',
      excludeSemantics: true,
      child: Container(
        height: 52,
        padding: EdgeInsets.all(isToday ? 4 : 5),
        decoration: BoxDecoration(
          color: isFuture ? c.calendarBlank : c.surface2,
          borderRadius: BorderRadius.circular(Radii.chip),
          border: isToday ? Border.all(color: c.textMuted, width: 1.5) : null,
        ),
        alignment: Alignment.topLeft,
        child: Text(
          '${d.day}',
          style: AppTypography.labelSmall.copyWith(
            height: 13 / 11,
            fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
            color: isFuture ? c.calendarBlankText : c.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final p = context.pnl;
    Widget item(Color swatch, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: swatch,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: c.textSecondary),
        ),
      ],
    );
    return Wrap(
      spacing: Space.sm,
      runSpacing: Space.xs,
      children: [
        item(p.profit.withValues(alpha: 0.25), 'Profit day'),
        item(p.loss.withValues(alpha: 0.25), 'Loss day'),
        item(c.surface2, 'No trades'),
      ],
    );
  }
}
