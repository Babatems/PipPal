"""Render logo 5a into the app-icon master PNGs in assets/icon/.

Drawn from the exact vector in docs/06-assets.md (viewBox 30 -1 83 118),
4x supersampled. Re-run after changing the candle colour (decision D6), then
`dart run flutter_launcher_icons`.

    python3 tool/generate_icon_masters.py   (needs Pillow: pip3 install pillow)
"""

from pathlib import Path

from PIL import Image, ImageDraw

INK = (0x2D, 0x2D, 0x2A)
CANDLE = (0x2A, 0x9D, 0x5C)  # D6: keep in sync with BrandMark in tokens.dart
INK_DARK = (0xE5, 0xDC, 0xC5)
CANDLE_DARK = (0x4D, 0xBF, 0x7F)
WHITE = (0xFF, 0xFF, 0xFF)

SIZE = 1024
SS = 4  # supersampling factor
OUT = Path(__file__).resolve().parent.parent / "assets" / "icon"


def mark(height_ratio, ink, candle, background=None):
    """Mark centred on a SIZE canvas, its height = height_ratio of the canvas."""
    big = SIZE * SS
    img = Image.new("RGBA", (big, big), background + (255,) if background else (0, 0, 0, 0))
    s = big * height_ratio / 118  # viewBox units -> pixels
    ox = (big - 83 * s) / 2
    oy = (big - 118 * s) / 2

    def p(x, y):
        return (ox + (x - 30) * s, oy + (y + 1) * s)

    def paint(colour, draw_fn):
        mask = Image.new("L", (big, big), 0)
        draw_fn(ImageDraw.Draw(mask))
        img.paste(colour + (255,), (0, 0), mask)

    # stem: M32 2 H52 V100 L32 116 Z
    paint(ink, lambda d: d.polygon([p(32, 2), p(52, 2), p(52, 100), p(32, 116)], fill=255))

    # bowl: right half-annulus centred (52,49), outer r35, inner r15
    def bowl(d):
        cx, cy = p(52, 49)
        ro, ri = 35 * s, 15 * s
        d.pieslice([cx - ro, cy - ro, cx + ro, cy + ro], -90, 90, fill=255)
        d.pieslice([cx - ri, cy - ri, cx + ri, cy + ri], -90, 90, fill=0)

    paint(ink, bowl)

    # candle: wick x98 y22 w4 h54, body x89 y34 w22 h30
    def candle_rects(d):
        d.rectangle([p(98, 22), p(102, 76)], fill=255)
        d.rectangle([p(89, 34), p(111, 64)], fill=255)

    paint(candle, candle_rects)
    return img.resize((SIZE, SIZE), Image.LANCZOS)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    # iOS / legacy Android: white ground, mark at 62% (iOS keyline, docs/03).
    mark(0.62, INK, CANDLE, WHITE).convert("RGB").save(OUT / "app_icon.png")
    # Android adaptive foreground: transparent, sized so the mark's diagonal
    # stays inside the 66/108 safe-zone circle on every launcher mask.
    mark(0.46, INK, CANDLE).save(OUT / "android_foreground.png")
    # Android 13+ themed icon: single colour on transparent.
    mark(0.46, INK, INK).save(OUT / "android_monochrome.png")
    # iOS 18 dark: transparent, dark-mode ink and candle.
    mark(0.62, INK_DARK, CANDLE_DARK).save(OUT / "ios_dark.png")
    # iOS 18 tinted: greyscale on transparent; the system applies the tint.
    mark(0.62, WHITE, (0xC8, 0xC8, 0xC8)).save(OUT / "ios_tinted.png")
    print("wrote", sorted(p.name for p in OUT.glob("*.png")))


if __name__ == "__main__":
    main()
