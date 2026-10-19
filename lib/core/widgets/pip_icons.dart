import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

/// Custom tab glyphs on a 24pt grid, 1.75 stroke, round caps/joins
/// (paths from claude/PipPal Screens.dc.html, see docs/06-assets.md).
/// Active = the filled version of the same glyph with interior details
/// knocked out in [knockout].
enum PipGlyph {
  dashboard,
  journal,
  calendar,
  analytics;

  String svg(Color ink, {required bool filled, Color knockout = Colors.white}) {
    final i = _hex(ink);
    final k = _hex(knockout);
    final fill = filled ? i : 'none';
    final body = switch (this) {
      PipGlyph.dashboard =>
        '<path d="M3.5 10.2 12 3.5l8.5 6.7V19a1.5 1.5 0 0 1-1.5 1.5h-4v-6h-6v6H5A1.5 1.5 0 0 1 3.5 19z" fill="$fill"/>',
      PipGlyph.journal =>
        '<path d="M5 19.5V4.5A1.5 1.5 0 0 1 6.5 3H19v15H6.5A1.5 1.5 0 0 0 5 19.5a1.5 1.5 0 0 0 1.5 1.5H19" fill="$fill"/>'
            '<path d="M9 7.5h6M9 11h4" stroke="${filled ? k : i}"/>',
      PipGlyph.calendar =>
        '<rect x="3.5" y="5" width="17" height="15.5" rx="3" fill="$fill"/>'
            '<path d="M8 3v4M16 3v4"/>'
            '<path d="M3.5 10h17" stroke="${filled ? k : i}"/>'
            '<circle cx="12" cy="15" r="1.3" fill="${filled ? k : i}" stroke="none"/>',
      PipGlyph.analytics =>
        '<rect x="4" y="12" width="4" height="8.5" rx="1.4" fill="$fill"/>'
            '<rect x="10" y="4" width="4" height="16.5" rx="1.4" fill="$fill"/>'
            '<rect x="16" y="8.5" width="4" height="12" rx="1.4" fill="$fill"/>',
    };
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
        'stroke="$i" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">'
        '$body</svg>';
  }
}

class PipGlyphIcon extends StatelessWidget {
  const PipGlyphIcon(
    this.glyph, {
    super.key,
    required this.color,
    this.filled = false,
    this.knockout = Colors.white,
    this.size = 24,
  });

  final PipGlyph glyph;
  final Color color;
  final bool filled;
  final Color knockout;
  final double size;

  @override
  Widget build(BuildContext context) => SvgPicture.string(
    glyph.svg(color, filled: filled, knockout: knockout),
    width: size,
    height: size,
  );
}

/// Logo 5a: geometric "P" whose bowl is followed by a candlestick.
/// viewBox 30 -1 83 118 (aspect 83:118).
class PipLogo extends StatelessWidget {
  const PipLogo({
    super.key,
    required this.ink,
    required this.candle,
    this.height = 26,
  });

  final Color ink;
  final Color candle;
  final double height;

  static const aspect = 83 / 118;

  static String svg(Color ink, Color candle) {
    final i = _hex(ink);
    final c = _hex(candle);
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="30 -1 83 118">'
        '<path d="M32 2 H52 V100 L32 116 Z" fill="$i"/>'
        '<path d="M52 14 A35 35 0 0 1 52 84 L52 64 A15 15 0 0 0 52 34 Z" fill="$i"/>'
        '<rect x="98" y="22" width="4" height="54" fill="$c"/>'
        '<rect x="89" y="34" width="22" height="30" fill="$c"/>'
        '</svg>';
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'PipPal',
    child: SvgPicture.string(
      svg(ink, candle),
      height: height,
      width: height * aspect,
    ),
  );
}

/// Centre "+" of the tab bar.
class PlusGlyph extends StatelessWidget {
  const PlusGlyph({super.key, this.size = 22, this.color = Colors.white});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => SvgPicture.string(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
    'stroke="${_hex(color)}" stroke-width="2.4" stroke-linecap="round">'
    '<path d="M12 5v14"/><path d="M5 12h14"/></svg>',
    width: size,
    height: size,
  );
}

/// Month-navigation chevrons (stroke 2, round caps), as drawn.
class ChevronGlyph extends StatelessWidget {
  const ChevronGlyph({
    super.key,
    required this.left,
    required this.color,
    this.size = 22,
  });

  final bool left;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SvgPicture.string(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
    'stroke="${_hex(color)}" stroke-width="2" stroke-linecap="round" '
    'stroke-linejoin="round"><path d="${left ? 'm15 18-6-6 6-6' : 'm9 18 6-6-6-6'}"/></svg>',
    width: size,
    height: size,
  );
}
