import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/clock.dart';

/// Layout of one month: Monday-first (decision D31), leading blanks only.
@immutable
class MonthGrid {
  const MonthGrid._(this.month, this.leadingBlanks, this.days);

  factory MonthGrid.of(DateTime month) {
    final first = DateTime(month.year, month.month);
    return MonthGrid._(
      first,
      first.weekday - DateTime.monday,
      DateUtils.getDaysInMonth(first.year, first.month),
    );
  }

  /// First day of the month.
  final DateTime month;
  final int leadingBlanks;
  final int days;

  int get cellCount => leadingBlanks + days;
  int get rows => (cellCount / 7).ceil();
}

/// The month shown on the Calendar tab. Survives tab switches (spec §7.1)
/// and never moves past the current month, since future months have no
/// results to show.
class CalendarMonthController extends Notifier<DateTime> {
  DateTime get _current {
    final now = ref.read(clockProvider)();
    return DateTime(now.year, now.month);
  }

  @override
  DateTime build() => _current;

  bool get canGoForward => state.isBefore(_current);

  void previous() => state = DateTime(state.year, state.month - 1);

  void next() {
    if (canGoForward) state = DateTime(state.year, state.month + 1);
  }
}

final calendarMonthProvider =
    NotifierProvider<CalendarMonthController, DateTime>(
      CalendarMonthController.new,
    );
