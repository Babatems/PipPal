import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/pip_icons.dart';
import 'destinations.dart';
import 'glass_tab_bar.dart';

/// Tablet navigation. [expanded] = the drawn 248pt sidebar (≥1024 wide);
/// otherwise the icon-only 72pt rail (600–1023).
class SideNavigation extends StatelessWidget {
  const SideNavigation({
    super.key,
    required this.expanded,
    required this.currentIndex,
    required this.onSelect,
    required this.onCreate,
  });

  final bool expanded;
  final int? currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: expanded ? 248 : 72,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(right: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        right: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: expanded ? Space.m : Space.sm,
            vertical: Space.l,
          ),
          child: Column(
            crossAxisAlignment: expanded
                ? CrossAxisAlignment.stretch
                : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(left: expanded ? Space.s : 0),
                child: Row(
                  mainAxisAlignment: expanded
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    PipLogo(ink: c.logoInk, candle: c.logoCandle, height: 28),
                    if (expanded) ...[
                      const SizedBox(width: Space.s + 2),
                      Text('PipPal', style: context.text.headlineSmall),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: Space.l),
              if (expanded)
                PrimaryButton(label: 'Log Trade', onPressed: onCreate)
              else
                CreateButton(onTap: onCreate, size: 44),
              const SizedBox(height: Space.l),
              for (final (i, d) in AppDestination.values.indexed)
                _SideItem(
                  destination: d,
                  active: currentIndex == i,
                  expanded: expanded,
                  onTap: () => onSelect(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideItem extends StatelessWidget {
  const _SideItem({
    required this.destination,
    required this.active,
    required this.expanded,
    required this.onTap,
  });

  final AppDestination destination;
  final bool active;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ink = active ? c.navActive : c.navIdle;
    final icon = PipGlyphIcon(
      destination.glyph,
      color: ink,
      filled: active,
      knockout: c.surface,
      size: 22,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.xs),
      child: Semantics(
        selected: active,
        button: true,
        label: destination.label,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 44,
            width: expanded ? null : 48,
            padding: EdgeInsets.symmetric(horizontal: expanded ? Space.sm : 0),
            decoration: BoxDecoration(
              color: active
                  ? c.crimson.withValues(alpha: 0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(Radii.chip + 2),
            ),
            child: expanded
                ? Row(
                    children: [
                      icon,
                      const SizedBox(width: Space.sm),
                      Text(
                        destination.label,
                        style: context.text.titleMedium?.copyWith(
                          color: active ? c.navActive : c.textPrimary,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : Center(child: icon),
          ),
        ),
      ),
    );
  }
}
