import 'package:flutter/material.dart';

import '../layout/breakpoints.dart';
import '../theme/app_theme.dart';

/// White 56pt bar with a 1px bottom border; never an elevation shadow.
/// The status-bar area above it shows the app ground, as drawn.
class PipAppBar extends StatelessWidget {
  const PipAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions = const [],
    this.bottom,
  });

  /// Screen title (headlineLarge). Ignored when [leading] is given.
  final String? title;
  final Widget? leading;
  final List<Widget> actions;

  /// Optional white sub-bar under the title row (filter chips, month nav).
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pad = LayoutSize.of(context).screenPadding;
    final border = BorderSide(color: c.border);
    return ColoredBox(
      color: c.background,
      child: SafeArea(
        bottom: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: c.surface,
            border: Border(bottom: border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 56,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child:
                              leading ??
                              Semantics(
                                header: true,
                                child: Text(
                                  title ?? '',
                                  style: context.text.headlineLarge,
                                ),
                              ),
                        ),
                      ),
                      ...actions,
                    ],
                  ),
                ),
              ),
              ?bottom,
            ],
          ),
        ),
      ),
    );
  }
}

/// A tab screen: app bar on top, body filling the rest. Bodies that scroll
/// should pad their bottom with [bottomClearance] so content clears the
/// floating glass tab bar on phones.
class TabScaffold extends StatelessWidget {
  const TabScaffold({super.key, required this.appBar, required this.body});

  final PipAppBar appBar;
  final Widget body;

  static double bottomClearance(BuildContext context) =>
      LayoutSize.of(context) == LayoutSize.compact ? 120 : 32;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.colors.background,
    child: Column(
      children: [
        appBar,
        // No bottom padding here: content scrolls beneath the glass bar.
        Expanded(child: body),
      ],
    ),
  );
}
