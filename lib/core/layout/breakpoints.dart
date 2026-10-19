import 'package:flutter/widgets.dart';

/// Width-based layouts (decision D25), identical on iPad and Android tablets.
enum LayoutSize {
  /// < 600: phone, floating glass tab bar.
  compact,

  /// 600–1023: icon-only 72pt sidebar, single pane.
  medium,

  /// ≥ 1024: 248pt sidebar, two panes.
  expanded;

  static LayoutSize forWidth(double width) => width >= 1024
      ? expanded
      : width >= 600
      ? medium
      : compact;

  static LayoutSize of(BuildContext context) =>
      forWidth(MediaQuery.sizeOf(context).width);

  double get screenPadding => this == compact ? 16 : 32;
}
