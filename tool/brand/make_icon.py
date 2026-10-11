"""Draws the app logo and writes the Android launcher icons.

    python3 tool/brand/make_icon.py

A white map pin holding a blue local-train front, on a deep-blue gradient
with a marigold route line. Writes:
  android/app/src/main/res/mipmap-*/ic_launcher.png        (legacy, rounded)
  android/app/src/main/res/mipmap-*/ic_launcher_foreground.png (adaptive)
  android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
  android/app/src/main/res/mipmap-*/ic_launcher_background.png (adaptive)
  assets/brand/logo.png (used in the app's header)
"""
import os

from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
RES = os.path.join(ROOT, 'android/app/src/main/res')
S = 1024  # drawing size; everything is scaled down with antialiasing

DEEP = (8, 47, 107)
BRAND = (11, 79, 163)
BRIGHT = (30, 136, 229)
MARIGOLD = (242, 159, 5)
WHITE = (255, 255, 255)


def gradient(size):
    img = Image.new('RGB', (size, size))
    px = img.load()
    for y in range(size):
        for x in range(size):
            t = (x + y) / (2 * (size - 1))
            if t < 0.5:
                a, b, u = DEEP, BRAND, t / 0.5
            else:
                a, b, u = BRAND, BRIGHT, (t - 0.5) / 0.5
            px[x, y] = tuple(round(a[i] + (b[i] - a[i]) * u) for i in range(3))
    return img


def glyph(size, scale=1.0):
    """The pin, train and route line on a transparent square."""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    k = size / 1024 * scale
    off = size * (1 - scale) / 2

    def p(x, y):
        return (off + x * k, off + y * k)

    # Marigold route line sweeping behind the pin.
    d.line([p(150, 800), p(330, 760), p(520, 840), p(700, 790), p(880, 720)],
           fill=MARIGOLD, width=round(46 * k), joint='curve')
    for x, y in [(150, 800), (880, 720)]:
        r = 34 * k
        cx, cy = p(x, y)
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=MARIGOLD)

    # Soft shadow under the pin.
    shadow = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    cx, cy = p(512, 405)
    r = 285 * k
    sd.ellipse([cx - r, cy - r + 18 * k, cx + r, cy + r + 18 * k], fill=(0, 0, 0, 90))
    sd.polygon([p(300, 560), p(724, 560), p(512, 840)], fill=(0, 0, 0, 90))
    shadow = shadow.filter(ImageFilter.GaussianBlur(22 * k))
    img.alpha_composite(shadow)
    d = ImageDraw.Draw(img)

    # White pin: circle plus point.
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=WHITE)
    d.polygon([p(292, 540), p(732, 540), p(512, 820)], fill=WHITE)

    # Train front inside the pin.
    d.rounded_rectangle([p(372, 230), p(652, 560)], radius=70 * k, fill=BRAND)
    d.rounded_rectangle([p(410, 280), p(614, 400)], radius=26 * k, fill=WHITE)
    d.line([p(512, 280), p(512, 400)], fill=BRAND, width=round(16 * k))
    for x in (440, 584):
        hx, hy = p(x, 470)
        hr = 30 * k
        d.ellipse([hx - hr, hy - hr, hx + hr, hy + hr], fill=MARIGOLD)
    d.rounded_rectangle([p(470, 455), p(554, 485)], radius=12 * k, fill=WHITE)
    # Rails under the train.
    d.line([p(420, 560), p(380, 640)], fill=BRAND, width=round(26 * k))
    d.line([p(604, 560), p(644, 640)], fill=BRAND, width=round(26 * k))
    d.line([p(395, 610), p(629, 610)], fill=BRAND, width=round(20 * k))
    return img


def rounded(img, radius_frac=0.23):
    mask = Image.new('L', img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, img.size[0] - 1, img.size[1] - 1],
        radius=round(img.size[0] * radius_frac), fill=255)
    out = Image.new('RGBA', img.size, (0, 0, 0, 0))
    out.paste(img, (0, 0), mask)
    return out


def full_logo():
    bg = gradient(S).convert('RGBA')
    bg.alpha_composite(glyph(S, 0.86))
    return rounded(bg)


def main():
    logo = full_logo()
    os.makedirs(os.path.join(ROOT, 'assets/brand'), exist_ok=True)
    logo.resize((512, 512), Image.LANCZOS).save(os.path.join(ROOT, 'assets/brand/logo.png'))

    # Legacy launcher icons.
    for folder, px in [('mdpi', 48), ('hdpi', 72), ('xhdpi', 96), ('xxhdpi', 144), ('xxxhdpi', 192)]:
        logo.resize((px, px), Image.LANCZOS).save(
            os.path.join(RES, f'mipmap-{folder}', 'ic_launcher.png'))

    # Adaptive icon: 108 dp layers, artwork inside the central 66 dp.
    fg = glyph(S, 0.62)
    for folder, px in [('mdpi', 108), ('hdpi', 162), ('xhdpi', 216), ('xxhdpi', 324), ('xxxhdpi', 432)]:
        fg.resize((px, px), Image.LANCZOS).save(
            os.path.join(RES, f'mipmap-{folder}', 'ic_launcher_foreground.png'))
        gradient(px).save(os.path.join(RES, f'mipmap-{folder}', 'ic_launcher_background.png'))
    os.makedirs(os.path.join(RES, 'mipmap-anydpi-v26'), exist_ok=True)
    with open(os.path.join(RES, 'mipmap-anydpi-v26', 'ic_launcher.xml'), 'w') as f:
        f.write('<?xml version="1.0" encoding="utf-8"?>\n'
                '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
                '    <background android:drawable="@mipmap/ic_launcher_background"/>\n'
                '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
                '</adaptive-icon>\n')
    print('icons written')


if __name__ == '__main__':
    main()
