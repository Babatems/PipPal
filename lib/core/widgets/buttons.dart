import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

/// Scales its child to 0.97 while pressed (80ms easeOut), per spec §9.1.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.semanticLabel,
    this.builder,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;

  /// Optional: rebuild the child with the pressed state (to darken a step).
  final Widget Function(BuildContext context, bool pressed, Widget child)?
  builder;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _set(bool v) {
    if (widget.onTap == null || _pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final child =
        widget.builder?.call(context, _pressed, widget.child) ?? widget.child;
    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOut,
          child: child,
        ),
      ),
    );
  }
}

/// Fill used while a filled button is pressed: the design's explicit
/// "one step darker" values, or a derived step for other fills.
Color _pressedFill(Color c) => switch (c.toARGB32()) {
  0xFFC14953 => const Color(0xFFAE414A),
  0xFF9B2226 => const Color(0xFF851C20),
  _ => () {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - 0.06).clamp(0, 1)).toColor();
  }(),
};

enum ButtonSize {
  /// 48pt, 15/500, label only (Foundations: every regular button).
  regular,

  /// 52pt, 16/600, trailing arrow (auth and form submit CTAs).
  large,
}

/// Filled CTA (crimson by default). The label sits left-aligned when the
/// button spans its parent; with [expand] false it hugs its label (empty-state
/// CTAs). Disabled is 40% opacity; [loading] shows a spinner in place of the
/// arrow and blocks taps.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = ButtonSize.regular,
    this.expand = true,
    this.loading = false,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final bool expand;
  final bool loading;

  /// Override the fill, e.g. `context.colors.destructive`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fill = color ?? context.colors.crimson;
    final large = size == ButtonSize.large;
    final style = (large ? AppTypography.buttonLarge : AppTypography.button)
        .copyWith(color: Colors.white);
    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );

    return Opacity(
      opacity: onPressed == null && !loading ? 0.4 : 1,
      child: Pressable(
        onTap: loading ? null : onPressed,
        semanticLabel: label,
        builder: (context, pressed, child) => AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          height: large ? 52 : 48,
          padding: EdgeInsets.fromLTRB(
            expand ? 20 : 24,
            0,
            expand ? (large ? 18 : 20) : 24,
            0,
          ),
          decoration: BoxDecoration(
            color: pressed ? _pressedFill(fill) : fill,
            borderRadius: BorderRadius.circular(Radii.card),
          ),
          child: child,
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          children: [
            // Flexible so long labels / large text sizes ellipsize, never overflow.
            if (expand) Expanded(child: text) else Flexible(child: text),
            if (loading) ...[
              const SizedBox(width: Space.sm),
              const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ] else if (large)
              const Icon(
                Icons.arrow_forward_rounded,
                size: 20,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }
}

/// Outline button: 1.5pt crimson border, crimson label, surface fill;
/// pressed = crimson 8%.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.button.copyWith(color: c.crimson),
    );
    return Opacity(
      opacity: onPressed == null ? 0.4 : 1,
      child: Pressable(
        onTap: onPressed,
        semanticLabel: label,
        builder: (context, pressed, child) => AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: expand ? 20 : 18),
          decoration: BoxDecoration(
            color: pressed
                ? Color.alphaBlend(c.crimson.withValues(alpha: 0.08), c.surface)
                : c.surface,
            border: Border.all(color: c.crimson, width: 1.5),
            borderRadius: BorderRadius.circular(Radii.card),
          ),
          child: child,
        ),
        child: expand
            ? Align(alignment: Alignment.centerLeft, child: text)
            : Center(widthFactor: 1, child: text),
      ),
    );
  }
}

/// Text-only tertiary action ("Skip for now", "Forgot password?").
///
/// The design draws these in Slate #848FA5, but Slate fails WCAG AA below
/// 18pt (spec §11.1), so the label uses textSecondary instead.
class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: onPressed,
      semanticLabel: label,
      builder: (context, pressed, child) => AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: Space.m),
        decoration: BoxDecoration(
          color: pressed
              ? c.textMuted.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(Radii.card),
        ),
        child: child,
      ),
      child: Center(
        widthFactor: 1,
        child: Text(
          label,
          style: AppTypography.button.copyWith(color: color ?? c.textSecondary),
        ),
      ),
    );
  }
}

/// 40×40 circular icon button; cream fill on press.
class PipIconButton extends StatelessWidget {
  const PipIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Opacity(
      opacity: onPressed == null ? 0.35 : 1,
      child: Pressable(
        onTap: onPressed,
        semanticLabel: semanticLabel,
        builder: (context, pressed, child) => AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: pressed ? c.surface2 : Colors.transparent,
          ),
          child: child,
        ),
        child: IconTheme(
          data: IconThemeData(size: 22, color: c.textSecondary),
          child: icon,
        ),
      ),
    );
  }
}
