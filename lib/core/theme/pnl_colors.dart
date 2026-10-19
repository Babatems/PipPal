import 'package:flutter/material.dart';

/// Profit / loss / break-even colours. Users can override profit and loss from
/// a preset palette (decision D20), so every P&L widget reads this extension.
@immutable
class PnlColors extends ThemeExtension<PnlColors> {
  const PnlColors({
    required this.profit,
    required this.loss,
    required this.breakEven,
    required this.profitText,
    required this.lossText,
    required this.breakEvenText,
  });

  /// Base colours: values on white, fills, chart strokes.
  final Color profit;
  final Color loss;
  final Color breakEven;

  /// Text on a tint of the base colour (calendar cells, tags).
  final Color profitText;
  final Color lossText;
  final Color breakEvenText;

  static const defaultProfit = Color(0xFF2A9D5C);
  static const defaultLoss = Color(0xFFC14953);

  static const profitPresets = [
    Color(0xFF2A9D5C),
    Color(0xFF1F7A46),
    Color(0xFF3B8EA5),
    Color(0xFF2D7D6E),
  ];
  static const lossPresets = [
    Color(0xFFC14953),
    Color(0xFF9B2226),
    Color(0xFFB4553F),
    Color(0xFF8E4B6B),
  ];

  static const light = PnlColors(
    profit: defaultProfit,
    loss: defaultLoss,
    breakEven: Color(0xFFD4854A),
    profitText: Color(0xFF1F7A46),
    lossText: Color(0xFFA03B44),
    breakEvenText: Color(0xFFA9622F),
  );

  static const dark = PnlColors(
    profit: Color(0xFF4DBF7F),
    loss: Color(0xFFE5717A),
    breakEven: Color(0xFFE8A06B),
    profitText: Color(0xFF4DBF7F),
    lossText: Color(0xFFE5717A),
    breakEvenText: Color(0xFFE8A06B),
  );

  /// Applies a user's preset choice. Defaults keep their hand-tuned text
  /// colours; other presets derive one (darker on light, lighter on dark).
  PnlColors withOverrides({
    Color? profit,
    Color? loss,
    required Brightness brightness,
  }) {
    final base = brightness == Brightness.dark ? dark : light;
    Color adapt(Color c) {
      final hsl = HSLColor.fromColor(c);
      return brightness == Brightness.dark
          ? hsl.withLightness((hsl.lightness + 0.15).clamp(0, 0.85)).toColor()
          : c;
    }

    Color textOn(Color c) {
      final hsl = HSLColor.fromColor(c);
      return brightness == Brightness.dark
          ? c
          : hsl.withLightness((hsl.lightness - 0.08).clamp(0, 1)).toColor();
    }

    final p = profit == null || profit == defaultProfit ? null : adapt(profit);
    final l = loss == null || loss == defaultLoss ? null : adapt(loss);
    return PnlColors(
      profit: p ?? base.profit,
      loss: l ?? base.loss,
      breakEven: base.breakEven,
      profitText: p == null ? base.profitText : textOn(p),
      lossText: l == null ? base.lossText : textOn(l),
      breakEvenText: base.breakEvenText,
    );
  }

  /// Colour for a signed value: > 0 profit, < 0 loss, 0 break-even.
  Color forValue(num value) =>
      value > 0 ? profit : (value < 0 ? loss : breakEven);

  Color textForValue(num value) =>
      value > 0 ? profitText : (value < 0 ? lossText : breakEvenText);

  /// Card/tag tint (10–12%) or calendar-cell tint (25%).
  Color tint(num value, {double alpha = 0.10}) =>
      forValue(value).withValues(alpha: value == 0 ? alpha * 0.8 : alpha);

  @override
  PnlColors copyWith({Color? profit, Color? loss}) => PnlColors(
    profit: profit ?? this.profit,
    loss: loss ?? this.loss,
    breakEven: breakEven,
    profitText: profitText,
    lossText: lossText,
    breakEvenText: breakEvenText,
  );

  @override
  PnlColors lerp(PnlColors? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return PnlColors(
      profit: c(profit, other.profit),
      loss: c(loss, other.loss),
      breakEven: c(breakEven, other.breakEven),
      profitText: c(profitText, other.profitText),
      lossText: c(lossText, other.lossText),
      breakEvenText: c(breakEvenText, other.breakEvenText),
    );
  }
}
