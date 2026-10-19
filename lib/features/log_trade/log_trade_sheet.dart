import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/surfaces.dart';
import '../../domain/instruments/instrument.dart';

/// Opens Log Trade on its default path, Quick log (variant B).
Future<void> showLogTradeSheet(BuildContext context) =>
    showPipSheet<void>(context, builder: (context) => const QuickLogSheet());

enum Direction { buy, sell }

enum ResultUnit {
  dollars(r'$'),
  pips('pips'),
  r('R');

  const ResultUnit(this.label);
  final String label;
}

/// Reasons offered when a trade was not to plan (decision D7).
const offPlanReasons = [
  'Chased entry',
  'Moved stop',
  'Oversized',
  'Exited early',
  'No setup',
  'Revenge trade',
];

/// What the user has entered so far.
@immutable
class QuickLogDraft {
  const QuickLogDraft({
    this.instrument,
    this.direction,
    this.result,
    this.unit = ResultUnit.dollars,
    this.followedPlan,
    this.reasons = const {},
  });

  final String? instrument;
  final Direction? direction;

  /// Signed result in [unit]; null until a number is entered.
  final double? result;
  final ResultUnit unit;
  final bool? followedPlan;
  final Set<String> reasons;

  bool get isComplete =>
      instrument != null && direction != null && result != null;
}

/// Quick log: instrument, direction, result — about eight seconds. Prices,
/// notes and tags can be added later. [onSave] is null until trades can be
/// stored (build step 2), which keeps Save disabled rather than pretending.
class QuickLogSheet extends StatefulWidget {
  const QuickLogSheet({super.key, this.onSave});

  final ValueChanged<QuickLogDraft>? onSave;

  @override
  State<QuickLogSheet> createState() => _QuickLogSheetState();
}

class _QuickLogSheetState extends State<QuickLogSheet> {
  final _result = TextEditingController();
  final _resultFocus = FocusNode();
  final _other = TextEditingController();
  final _otherFocus = FocusNode();

  String? _instrument;
  bool _typingOther = false;
  Direction? _direction;
  ResultUnit _unit = ResultUnit.dollars;
  bool _negative = false;
  bool? _followedPlan;
  final Set<String> _reasons = {};

  @override
  void initState() {
    super.initState();
    _resultFocus.addListener(() {
      // On blur, show the amount at spec precision: $ and R 2 dp, pips 1 dp.
      final v = double.tryParse(_result.text);
      if (!_resultFocus.hasFocus && v != null) {
        _result.text = v.toStringAsFixed(_unit == ResultUnit.pips ? 1 : 2);
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _result.dispose();
    _resultFocus.dispose();
    _other.dispose();
    _otherFocus.dispose();
    super.dispose();
  }

  bool get _usesPips =>
      _instrument == null || Instruments.classify(_instrument!).usesPips;

  double? get _value {
    final v = double.tryParse(_result.text);
    if (v == null) return null;
    return _negative ? -v : v;
  }

  QuickLogDraft get _draft => QuickLogDraft(
    instrument: _instrument,
    direction: _direction,
    result: _value,
    unit: _unit,
    followedPlan: _followedPlan,
    reasons: Set.unmodifiable(_reasons),
  );

  void _pickInstrument(String symbol) {
    HapticFeedback.selectionClick();
    setState(() {
      _instrument = symbol;
      _typingOther = false;
      // Pips are hidden for crypto and stocks (D11).
      if (!_usesPips && _unit == ResultUnit.pips) _unit = ResultUnit.dollars;
    });
  }

  void _commitOther() {
    final symbol = Instruments.normalise(_other.text);
    if (symbol.isEmpty) {
      setState(() => _typingOther = false);
      return;
    }
    _pickInstrument(symbol);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final canSave = widget.onSave != null && _draft.isComplete;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(Space.m, 0, Space.m, Space.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text('Quick log', style: t.headlineSmall),
          ),
          const SizedBox(height: Space.xs),
          Text(
            'Three fields now. Add prices, notes and tags whenever you like.',
            style: t.bodySmall,
          ),
          const SizedBox(height: 18),
          _instrumentField(c),
          const SizedBox(height: 14),
          const FieldLabel('Direction'),
          PipSegmented<Direction>(
            semanticLabel: 'Direction',
            selected: _direction,
            onChanged: (d) {
              HapticFeedback.selectionClick();
              setState(() => _direction = d);
            },
            segments: [
              Segment(
                Direction.buy,
                'BUY',
                activeFill: context.pnl.profit,
                activeInk: Colors.white,
              ),
              Segment(
                Direction.sell,
                'SELL',
                activeFill: context.pnl.loss,
                activeInk: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _resultField(context),
          const SizedBox(height: 14),
          _planField(c),
          const SizedBox(height: 14),
          InfoNote(
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Quick-logged trades appear in your journal with an ',
                  ),
                  TextSpan(
                    text: 'Incomplete',
                    style: TextStyle(
                      color: context.pnl.breakEvenText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const TextSpan(
                    text:
                        ' tag until you add prices. They still count toward '
                        'win rate.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Space.sm),
          PrimaryButton(
            label: 'Save trade',
            onPressed: canSave ? () => widget.onSave!(_draft) : null,
          ),
        ],
      ),
    );
  }

  Widget _instrumentField(PipColors c) {
    final custom =
        _instrument != null && !Instruments.starters.contains(_instrument);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel('Instrument'),
        Wrap(
          spacing: Space.s,
          runSpacing: Space.s,
          children: [
            for (final s in Instruments.starters)
              _InstrumentChip(
                label: s,
                selected: _instrument == s,
                onTap: () => _pickInstrument(s),
              ),
            if (custom)
              _InstrumentChip(
                label: _instrument!,
                selected: true,
                onTap: () {},
              ),
            if (_typingOther)
              SizedBox(
                width: 140,
                height: 36,
                child: TextField(
                  controller: _other,
                  focusNode: _otherFocus,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _commitOther(),
                  onTapOutside: (_) => _commitOther(),
                  style: AppTypography.button.copyWith(
                    fontSize: 14,
                    color: c.textPrimary,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'e.g. AAPL',
                    hintStyle: AppTypography.button.copyWith(
                      fontSize: 14,
                      color: c.hint,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 9,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Radii.chip),
                      borderSide: BorderSide(color: c.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Radii.chip),
                      borderSide: BorderSide(color: c.textPrimary, width: 1.5),
                    ),
                  ),
                ),
              )
            else
              _OtherChip(
                onTap: () {
                  _other.clear();
                  setState(() => _typingOther = true);
                },
              ),
          ],
        ),
        const FieldHelper(
          'Popular to start. Your five most-used will appear here as you log.',
        ),
      ],
    );
  }

  Widget _resultField(BuildContext context) {
    final c = context.colors;
    final value = _value;
    final ink = value == null ? c.textPrimary : context.pnl.forValue(value);
    final big = AppTypography.displayLarge.copyWith(color: ink);
    final units = [
      for (final u in ResultUnit.values)
        if (u != ResultUnit.pips || _usesPips) u,
    ];
    final prefix =
        '${_negative ? '−' : '+'}${_unit == ResultUnit.dollars ? r'$' : ''}';
    final suffix = switch (_unit) {
      ResultUnit.dollars => '',
      ResultUnit.pips => ' pips',
      ResultUnit.r => 'R',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel('Result'),
        GestureDetector(
          onTap: _resultFocus.requestFocus,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(Radii.card),
              border: Border.all(
                color: _resultFocus.hasFocus ? c.textMuted : c.border,
                width: _resultFocus.hasFocus ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Semantics(
                  button: true,
                  label: _negative
                      ? 'Loss. Switch to profit'
                      : 'Profit. Switch to loss',
                  excludeSemantics: true,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _negative = !_negative);
                    },
                    child: Text(
                      prefix,
                      // Matches the placeholder until a number is entered.
                      style: value == null ? big.copyWith(color: c.hint) : big,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _result,
                    focusNode: _resultFocus,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    inputFormatters: [_SignedAmountFormatter(_onSignTyped)],
                    onChanged: (_) => setState(() {}),
                    style: big,
                    cursorColor: c.crimson,
                    decoration: InputDecoration.collapsed(
                      hintText: '0.00',
                      hintStyle: big.copyWith(color: c.hint),
                    ),
                  ),
                ),
                if (suffix.isNotEmpty)
                  Text(suffix.trim(), style: big.copyWith(fontSize: 20)),
                const SizedBox(width: Space.s),
                PipSegmented<ResultUnit>(
                  semanticLabel: 'Result unit',
                  height: 30,
                  expand: false,
                  selected: _unit,
                  onChanged: (u) => setState(() => _unit = u),
                  segments: [for (final u in units) Segment(u, u.label)],
                ),
              ],
            ),
          ),
        ),
        const FieldHelper(
          'Enter whichever you know. PipPal back-fills the rest once you add '
          'prices.',
        ),
      ],
    );
  }

  void _onSignTyped(bool negative) => setState(() => _negative = negative);

  Widget _planField(PipColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: FieldLabel('Followed plan?')),
            PipSegmented<bool>(
              semanticLabel: 'Followed plan',
              height: 30,
              expand: false,
              selected: _followedPlan,
              // Tapping the selected answer again clears it: the field is
              // optional and unset by default.
              onChanged: (v) => setState(() {
                _followedPlan = _followedPlan == v ? null : v;
                if (_followedPlan != false) _reasons.clear();
              }),
              segments: const [Segment(true, 'Yes'), Segment(false, 'No')],
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _followedPlan == false
              ? Padding(
                  padding: const EdgeInsets.only(top: Space.s),
                  child: Wrap(
                    spacing: Space.s,
                    runSpacing: Space.s,
                    children: [
                      for (final r in offPlanReasons)
                        PipChip(
                          label: r,
                          selected: _reasons.contains(r),
                          onTap: () => setState(
                            () => _reasons.contains(r)
                                ? _reasons.remove(r)
                                : _reasons.add(r),
                          ),
                        ),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

/// Accepts an unsigned amount (2 dp). A typed leading "-" or "+" flips the
/// sign shown in the prefix instead of entering the field.
class _SignedAmountFormatter extends TextInputFormatter {
  _SignedAmountFormatter(this.onSign);

  final ValueChanged<bool> onSign;
  static final _valid = RegExp(r'^\d*\.?\d{0,2}$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(',', '.');
    if (text.startsWith('-') || text.startsWith('−')) {
      onSign(true);
      text = text.substring(1);
    } else if (text.startsWith('+')) {
      onSign(false);
      text = text.substring(1);
    }
    if (!_valid.hasMatch(text)) return oldValue;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// 36pt instrument chip: crimson when selected (Quick log spec).
class _InstrumentChip extends StatelessWidget {
  const _InstrumentChip({
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
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: selected ? c.crimson : c.surface2,
            borderRadius: BorderRadius.circular(Radii.chip),
          ),
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: AppTypography.button.copyWith(
                fontSize: 14,
                color: selected ? Colors.white : c.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dashed "Other…" chip that opens a free-text instrument entry.
class _OtherChip extends StatelessWidget {
  const _OtherChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: onTap,
      semanticLabel: 'Other instrument',
      child: CustomPaint(
        painter: _DashedBorder(color: c.handle, radius: Radii.chip),
        child: SizedBox(
          height: 36,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Center(
              widthFactor: 1,
              child: Text(
                'Other…',
                style: AppTypography.button.copyWith(
                  fontSize: 14,
                  color: c.textMuted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  _DashedBorder({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(0.5),
          Radius.circular(radius),
        ),
      );
    for (final ui.PathMetric m in path.computeMetrics()) {
      for (double d = 0; d < m.length; d += 7) {
        canvas.drawPath(m.extractPath(d, d + 4), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder old) => old.color != color;
}
