import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/breakpoints.dart';
import '../../features/log_trade/log_trade_sheet.dart';
import 'glass_tab_bar.dart';
import 'side_navigation.dart';

/// Hosts the four tab branches and picks the navigation chrome by width.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell, required this.children});

  final StatefulNavigationShell shell;
  final List<Widget> children;

  void _select(int index) {
    HapticFeedback.lightImpact();
    // Re-tapping the active tab returns that branch to its root.
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }

  void _create(BuildContext context) => showLogTradeSheet(context);

  @override
  Widget build(BuildContext context) {
    final size = LayoutSize.of(context);
    final body = FadeThroughStack(
      index: shell.currentIndex,
      children: children,
    );

    if (size == LayoutSize.compact) {
      return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: body),
            Positioned(
              left: GlassTabBar.inset,
              right: GlassTabBar.inset,
              bottom: GlassTabBar.lift,
              child: GlassTabBar(
                currentIndex: shell.currentIndex,
                onSelect: _select,
                onCreate: () => _create(context),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          SideNavigation(
            expanded: size == LayoutSize.expanded,
            currentIndex: shell.currentIndex,
            onSelect: _select,
            onCreate: () => _create(context),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// Keeps every branch alive (scroll/month/filter state survives tab
/// switches) and cross-fades the active one in over 200ms.
class FadeThroughStack extends StatelessWidget {
  const FadeThroughStack({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      for (final (i, child) in children.indexed)
        IgnorePointer(
          ignoring: i != index,
          child: ExcludeSemantics(
            excluding: i != index,
            // The fade must sit *outside* TickerMode: a muted ticker would
            // freeze the outgoing branch's fade-out at full opacity.
            child: AnimatedOpacity(
              opacity: i == index ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              curve: i == index
                  ? const Interval(0.35, 1, curve: Curves.easeOut)
                  : const Interval(0, 0.35, curve: Curves.easeIn),
              child: TickerMode(enabled: i == index, child: child),
            ),
          ),
        ),
    ],
  );
}
