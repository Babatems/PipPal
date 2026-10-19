import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Theme mode + user P&L colour overrides (Settings › Appearance).
/// In-memory for now; persisted once the drift database lands (step 2).
@immutable
class Appearance {
  const Appearance({this.mode = ThemeMode.system, this.profit, this.loss});

  final ThemeMode mode;

  /// Null = default emerald / crimson.
  final Color? profit;
  final Color? loss;

  Appearance copyWith({ThemeMode? mode, Color? profit, Color? loss}) =>
      Appearance(
        mode: mode ?? this.mode,
        profit: profit ?? this.profit,
        loss: loss ?? this.loss,
      );
}

class AppearanceController extends Notifier<Appearance> {
  @override
  Appearance build() => const Appearance();

  void setMode(ThemeMode mode) => state = state.copyWith(mode: mode);

  void setProfit(Color color) => state = state.copyWith(profit: color);

  void setLoss(Color color) => state = state.copyWith(loss: color);

  void resetColours() => state = Appearance(mode: state.mode);
}

final appearanceProvider = NotifierProvider<AppearanceController, Appearance>(
  AppearanceController.new,
);
