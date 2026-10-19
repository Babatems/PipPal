import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Injectable "now" so date-driven UI (calendar, weekly review) is testable.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
