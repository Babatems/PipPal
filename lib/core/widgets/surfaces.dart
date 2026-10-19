import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'buttons.dart';
import 'pip_icons.dart';

/// White card on a 1px warm border — never a shadow.
class PipCard extends StatelessWidget {
  const PipCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Space.m),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(Radii.card),
      ),
      child: Padding(padding: padding, child: child),
    );
    return onTap == null ? card : Pressable(onTap: onTap, child: card);
  }
}

enum TagTone { buy, sell, neutral, outline, incomplete }

/// 24dp tag, radius 6, 12/500 (BUY / SELL / Incomplete / setup tags).
class PipTag extends StatelessWidget {
  const PipTag(this.label, {super.key, this.tone = TagTone.neutral});

  final String label;
  final TagTone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final p = context.pnl;
    final (bg, fg) = switch (tone) {
      TagTone.buy => (p.profit.withValues(alpha: 0.12), p.profitText),
      TagTone.sell => (p.loss.withValues(alpha: 0.12), p.lossText),
      TagTone.incomplete => (
        p.breakEven.withValues(alpha: 0.14),
        p.breakEvenText,
      ),
      TagTone.neutral => (c.surface2, c.textSecondary),
      TagTone.outline => (Colors.transparent, c.textSecondary),
    };
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Radii.tag),
        border: tone == TagTone.outline ? Border.all(color: c.border) : null,
      ),
      // widthFactor 1 shrink-wraps the label instead of filling the row.
      child: Center(
        widthFactor: 1,
        child: Text(label, style: AppTypography.tag.copyWith(color: fg)),
      ),
    );
  }
}

/// 32dp filter chip, radius 8, 13/500 (date ranges, journal filters).
class PipChip extends StatelessWidget {
  const PipChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      selected: selected,
      child: Pressable(
        onTap: onTap,
        semanticLabel: label,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: Space.sm),
          decoration: BoxDecoration(
            color: selected ? c.crimson.withValues(alpha: 0.12) : c.surface2,
            borderRadius: BorderRadius.circular(Radii.chip),
          ),
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: AppTypography.chip.copyWith(
                color: selected ? c.crimson : c.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// CAPS field label above a control ("INSTRUMENT", "DIRECTION").
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text.toUpperCase(),
      style: AppTypography.labelSmall.copyWith(color: context.colors.textMuted),
    ),
  );
}

/// Helper line under a control (11/14 slate).
class FieldHelper extends StatelessWidget {
  const FieldHelper(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text(
      text,
      style: AppTypography.labelSmall.copyWith(color: context.colors.textMuted),
    ),
  );
}

/// One option of a [PipSegmented] control.
class Segment<T> {
  const Segment(this.value, this.label, {this.activeFill, this.activeInk});

  final T value;
  final String label;

  /// Fill/ink when selected. Defaults to a white thumb with ink text.
  final Color? activeFill;
  final Color? activeInk;
}

/// Cream track (radius 10, padding 3) holding equal-width segments
/// (radius 8). [selected] may be null for an unset choice.
class PipSegmented<T> extends StatelessWidget {
  const PipSegmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.height = 44,
    this.expand = true,
    this.semanticLabel,
  });

  final List<Segment<T>> segments;
  final T? selected;
  final ValueChanged<T> onChanged;
  final double height;
  final bool expand;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final compact = height < 40;
    Widget seg(Segment<T> s) {
      final active = s.value == selected;
      final fill = active ? (s.activeFill ?? c.surface) : Colors.transparent;
      final ink = active ? (s.activeInk ?? c.textPrimary) : c.textSecondary;
      final child = Semantics(
        selected: active,
        button: true,
        label: s.label,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(s.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: height,
            padding: EdgeInsets.symmetric(horizontal: compact ? 11 : 12),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(
                compact ? 6 : Radii.segmentedInner,
              ),
            ),
            child: Center(
              widthFactor: expand ? null : 1,
              child: Text(
                s.label,
                style: (compact ? AppTypography.chip : AppTypography.button)
                    .copyWith(
                      color: ink,
                      fontWeight: active && !compact
                          ? FontWeight.w600
                          : FontWeight.w500,
                      letterSpacing: compact ? 0 : 0.6,
                    ),
              ),
            ),
          ),
        ),
      );
      return expand ? Expanded(child: child) : child;
    }

    return Semantics(
      label: semanticLabel,
      container: semanticLabel != null,
      child: Container(
        padding: EdgeInsets.all(compact ? 2 : 3),
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: BorderRadius.circular(
            compact ? Radii.chip : Radii.segmented,
          ),
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          children: [for (final s in segments) seg(s)],
        ),
      ),
    );
  }
}

/// Soft inline note with an info icon (e.g. the Quick log footnote).
class InfoNote extends StatelessWidget {
  const InfoNote({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: c.note,
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(Radii.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(
              Icons.info_outline_rounded,
              size: 15,
              color: c.textMuted,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: DefaultTextStyle.merge(
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w400,
                height: 17 / 12,
                color: c.textSecondary,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Centred empty state: faded brand mark (artwork placeholder), title, body
/// and an optional CTA. Matches the drawn "Dashboard, no trades ever" state.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.body,
    this.action,
    this.footer,
  });

  final String title;
  final String body;
  final Widget? action;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Space.xl, Space.l, Space.xl, 70),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Opacity(
                opacity: 0.22,
                child: PipLogo(ink: c.logoInk, candle: c.logoInk, height: 132),
              ),
            ),
            const SizedBox(height: Space.ml),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.text.headlineMedium,
            ),
            const SizedBox(height: Space.s),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                body,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium,
              ),
            ),
            if (action != null) ...[const SizedBox(height: Space.ml), action!],
            if (footer != null) ...[const SizedBox(height: Space.ml), footer!],
          ],
        ),
      ),
    );
  }
}

/// "Recent Trades ........ See all"
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(child: Text(title, style: context.text.headlineMedium)),
          if (action != null)
            Pressable(
              onTap: onAction,
              semanticLabel: action,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Space.s),
                child: Text(
                  action!,
                  style: AppTypography.labelLarge.copyWith(color: c.textMuted),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Modal bottom sheet: grab handle, scrim, top radius 16, soft shadow,
/// drag-to-dismiss. Content is sized to fit unless [heightFactor] is given.
Future<T?> showPipSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  double? heightFactor,
}) {
  final c = context.colors;
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: c.scrim,
    elevation: 0,
    sheetAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 380),
      reverseDuration: Duration(milliseconds: 280),
    ),
    builder: (context) {
      final sheet = DecoratedBox(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Radii.sheet),
          ),
          boxShadow: Elevations.sheet,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 12),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.handle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Flexible(
                fit: heightFactor == null ? FlexFit.loose : FlexFit.tight,
                child: builder(context),
              ),
            ],
          ),
        ),
      );
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: heightFactor == null
            ? sheet
            : FractionallySizedBox(heightFactor: heightFactor, child: sheet),
      );
    },
  );
}
