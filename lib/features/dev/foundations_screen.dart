import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/pnl_colors.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/pip_icons.dart';
import '../../core/widgets/skeleton.dart';
import '../../core/widgets/surfaces.dart';
import '../settings/application/appearance_controller.dart';

/// Living version of claude/PipPal Foundations.dc.html, for checking tokens
/// and components on device in both themes. Developer-only.
class FoundationsScreen extends ConsumerWidget {
  const FoundationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final p = context.pnl;
    final t = context.text;
    final appearance = ref.watch(appearanceProvider);
    final ctl = ref.read(appearanceProvider.notifier);

    Widget label(String s) => Padding(
      padding: const EdgeInsets.only(top: Space.l, bottom: Space.s),
      child: Text(
        s.toUpperCase(),
        style: t.labelMedium?.copyWith(color: c.textMuted),
      ),
    );

    Widget swatch(String name, Color color) => Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(Radii.chip),
            border: Border.all(color: c.border),
          ),
        ),
        const SizedBox(height: Space.xs),
        SizedBox(
          width: 64,
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: t.labelSmall,
            maxLines: 2,
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foundations'),
        shape: Border(bottom: BorderSide(color: c.border)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.m, 0, Space.m, Space.huge),
        children: [
          label('Theme'),
          Wrap(
            spacing: Space.s,
            children: [
              for (final m in ThemeMode.values)
                PipChip(
                  label: m.name[0].toUpperCase() + m.name.substring(1),
                  selected: appearance.mode == m,
                  onTap: () => ctl.setMode(m),
                ),
            ],
          ),
          label('Colour tokens'),
          Wrap(
            spacing: Space.s,
            runSpacing: Space.sm,
            children: [
              swatch('background', c.background),
              swatch('surface', c.surface),
              swatch('surface2', c.surface2),
              swatch('border', c.border),
              swatch('text primary', c.textPrimary),
              swatch('text secondary', c.textSecondary),
              swatch('muted', c.textMuted),
              swatch('crimson', c.crimson),
              swatch('profit', p.profit),
              swatch('break-even', p.breakEven),
              swatch('destructive', c.destructive),
            ],
          ),
          label('P&L colours (Settings presets)'),
          Wrap(
            spacing: Space.s,
            runSpacing: Space.s,
            children: [
              for (final color in PnlColors.profitPresets)
                _PresetDot(
                  color: color,
                  selected:
                      (appearance.profit ?? PnlColors.defaultProfit) == color,
                  onTap: () => ctl.setProfit(color),
                ),
              const SizedBox(width: Space.m),
              for (final color in PnlColors.lossPresets)
                _PresetDot(
                  color: color,
                  selected: (appearance.loss ?? PnlColors.defaultLoss) == color,
                  onTap: () => ctl.setLoss(color),
                ),
            ],
          ),
          const SizedBox(height: Space.sm),
          PipCard(
            child: Row(
              children: [
                Text('EUR/USD', style: t.titleMedium),
                const SizedBox(width: Space.s),
                const PipTag('BUY', tone: TagTone.buy),
                const Spacer(),
                Text(
                  '+\$96.00',
                  style: t.titleMedium?.copyWith(color: p.profit),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.s),
          PipCard(
            child: Row(
              children: [
                Text('GBP/JPY', style: t.titleMedium),
                const SizedBox(width: Space.s),
                const PipTag('SELL', tone: TagTone.sell),
                const Spacer(),
                Text('−\$42.50', style: t.titleMedium?.copyWith(color: p.loss)),
              ],
            ),
          ),
          label('Type scale · tabular figures'),
          Text('+\$1,240.50', style: t.displayLarge),
          Text('64.3%', style: t.displayMedium),
          Text('Journal', style: t.headlineLarge),
          Text('Recent Trades', style: t.headlineMedium),
          Text('Log a Trade', style: t.headlineSmall),
          Text('XAU/USD', style: t.titleMedium),
          Text('Waited for the retest instead of chasing.', style: t.bodyLarge),
          Text('Secondary descriptions and subtitles.', style: t.bodyMedium),
          Text('Helper text and form labels.', style: t.bodySmall),
          Text('TREND FOLLOWING', style: t.labelLarge),
          Text('14 Jul 2026 · 09:32', style: t.labelSmall),
          const SizedBox(height: Space.s),
          Text('1,111.11\n+\$96.00\n−\$42.50', style: t.titleMedium),
          label('Buttons'),
          PrimaryButton(label: 'Log Trade', onPressed: () {}),
          const SizedBox(height: Space.sm),
          const PrimaryButton(label: 'Log Trade', onPressed: null),
          const SizedBox(height: Space.sm),
          PrimaryButton(
            label: 'Continue',
            size: ButtonSize.large,
            onPressed: () {},
          ),
          const SizedBox(height: Space.sm),
          PrimaryButton(
            label: 'Signing in',
            size: ButtonSize.large,
            loading: true,
            onPressed: () {},
          ),
          const SizedBox(height: Space.sm),
          SecondaryButton(label: 'Cancel', onPressed: () {}),
          const SizedBox(height: Space.sm),
          PrimaryButton(
            label: 'Delete trade',
            color: c.destructive,
            onPressed: () {},
          ),
          const SizedBox(height: Space.xs),
          Row(
            children: [
              GhostButton(label: 'Skip for now', onPressed: () {}),
              const Spacer(),
              PipIconButton(
                icon: const Icon(Icons.tune_rounded),
                semanticLabel: 'Filter trades',
                onPressed: () {},
              ),
            ],
          ),
          label('Tags & chips'),
          const Wrap(
            spacing: Space.s,
            runSpacing: Space.s,
            children: [
              PipTag('BUY', tone: TagTone.buy),
              PipTag('SELL', tone: TagTone.sell),
              PipTag('Incomplete', tone: TagTone.incomplete),
              PipTag('Breakout'),
              PipTag('Trend Following'),
            ],
          ),
          const SizedBox(height: Space.sm),
          Wrap(
            spacing: Space.s,
            children: [
              PipChip(label: 'This Month', selected: true, onTap: () {}),
              PipChip(label: 'Today', selected: false, onTap: () {}),
              PipChip(label: 'All Time', selected: false, onTap: () {}),
            ],
          ),
          label('Brand & icons'),
          Row(
            children: [
              PipLogo(ink: c.logoInk, candle: c.logoCandle, height: 56),
              const SizedBox(width: Space.l),
              for (final g in PipGlyph.values) ...[
                PipGlyphIcon(g, color: c.navIdle),
                const SizedBox(width: Space.sm),
                PipGlyphIcon(
                  g,
                  color: c.navActive,
                  filled: true,
                  knockout: c.surface,
                ),
                const SizedBox(width: Space.m),
              ],
            ],
          ),
          label('Loading'),
          const Row(
            children: [
              Expanded(child: Skeleton(height: 88)),
              SizedBox(width: Space.sm),
              Expanded(
                child: Skeleton(height: 88, delay: Duration(milliseconds: 50)),
              ),
            ],
          ),
          label('Feedback'),
          Builder(
            builder: (context) => SecondaryButton(
              label: 'Show toast',
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Trade saved to your journal.'),
                  action: SnackBarAction(label: 'View', onPressed: () {}),
                ),
              ),
            ),
          ),
          const SizedBox(height: Space.sm),
          SecondaryButton(
            label: 'Show sheet',
            onPressed: () => showPipSheet<void>(
              context,
              builder: (context) => Padding(
                padding: const EdgeInsets.all(Space.l),
                child: Text('Sheet content', style: t.headlineSmall),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetDot extends StatelessWidget {
  const _PresetDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    child: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? context.colors.textPrimary : Colors.transparent,
          width: 2,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
    ),
  );
}
