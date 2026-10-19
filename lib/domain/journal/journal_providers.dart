import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Number of trades in the journal. Every screen derives its empty /
/// provisional state from this. Step 2 backs it with the drift database;
/// until then the journal is genuinely empty.
final tradeCountProvider = Provider<int>((ref) => 0);
