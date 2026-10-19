import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/pip_icons.dart';
import 'destinations.dart';

/// Floating translucent pill: Dashboard · Journal · [+] · Calendar · Analytics.
/// 64pt tall, inset 16pt, lifted 40pt off the bottom edge; content scrolls
/// beneath it. [currentIndex] is null on pushed screens (no capsule shown).
class GlassTabBar extends StatelessWidget {
  const GlassTabBar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    required this.onCreate,
  });

  static const double height = 64;
  static const double inset = 16;
  static const double lift = 40;

  final int? currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onCreate;

  /// Saturation matrix for the backdrop (1.8).
  static List<double> _saturate(double s) {
    const r = 0.2126, g = 0.7152, b = 0.0722;
    final i = 1 - s;
    return [
      r * i + s, g * i, b * i, 0, 0, //
      r * i, g * i + s, b * i, 0, 0,
      r * i, g * i, b * i + s, 0, 0,
      0, 0, 0, 1, 0,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final glass = context.colors.glass;
    const radius = BorderRadius.all(Radius.circular(Radii.tabBar));
    final tabs = AppDestination.values;

    Widget tab(int i) => Expanded(
      child: _TabItem(
        destination: tabs[i],
        active: currentIndex == i,
        onTap: () => onSelect(i),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          ...glass.shadows,
          BoxShadow(color: glass.ring, spreadRadius: 0.5),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ui.ImageFilter.compose(
            outer: ui.ImageFilter.blur(
              sigmaX: GlassStyle.blur / 2,
              sigmaY: GlassStyle.blur / 2,
            ),
            inner: ui.ColorFilter.matrix(_saturate(GlassStyle.saturation)),
          ),
          child: Container(
            height: height,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [glass.top, glass.bottom],
              ),
              border: Border.all(color: glass.border, width: 0.5),
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: radius,
              border: Border(top: BorderSide(color: glass.highlight)),
            ),
            child: Row(
              children: [
                tab(0),
                tab(1),
                SizedBox(
                  width: 60,
                  child: Center(child: CreateButton(onTap: onCreate)),
                ),
                tab(2),
                tab(3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.destination,
    required this.active,
    required this.onTap,
  });

  final AppDestination destination;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final glass = c.glass;
    final ink = active ? c.navActive : c.navIdle;
    return Semantics(
      selected: active,
      button: true,
      label: destination.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: active
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [glass.capsuleTop, glass.capsuleBottom],
                  )
                : null,
            border: active
                ? Border.all(color: glass.capsuleRing, width: 0.5)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PipGlyphIcon(
                destination.glyph,
                color: ink,
                filled: active,
                knockout: c.surface,
              ),
              const SizedBox(height: 3),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                textScaler: TextScaler.noScaling,
                style: AppTypography.tabLabel.copyWith(
                  color: ink,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 46pt crimson circle with a white plus; opens Log Trade.
class CreateButton extends StatelessWidget {
  const CreateButton({super.key, required this.onTap, this.size = 46});

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    semanticLabel: 'Log trade',
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFCF5A63), Color(0xFFB8404A)],
        ),
        border: Border.all(color: const Color(0x33FFFFFF), width: 0.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x8CC14953), // .55
            offset: Offset(0, 6),
            blurRadius: 14,
            spreadRadius: -4,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const PlusGlyph(),
    ),
  );
}
