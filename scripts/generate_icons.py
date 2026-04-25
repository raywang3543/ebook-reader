"""
Generate app icons for the ebook reader across all platforms.
Design: deep ink #1E1B2E background · coral book · cream pages · sun bookmark
Usage: python3 scripts/generate_icons.py
"""
from PIL import Image, ImageDraw
import os
import math

# ── Design tokens ─────────────────────────────────────────────────────────────
CORAL      = (255, 90, 78,  255)
CORAL_DEEP = (232, 54, 42,  255)
SUN        = (255, 210, 63, 255)
VIOLET     = (124, 92, 255, 255)
INK        = (30, 27, 46,   255)
CREAM      = (255, 246, 236,255)
MINT       = (61, 220, 151, 255)

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def make_rounded_mask(size, radius):
    """Return an 'L' (greyscale) mask with rounded corners."""
    mask = Image.new('L', (size, size), 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=255)
    return mask


def draw_master(size=1024):
    """Draw the icon at *size* × *size* pixels (full bleed, no OS rounding)."""
    s = size
    img = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # ── Background: deep ink ───────────────────────────────────────────────
    draw.rectangle([0, 0, s, s], fill=INK)

    # ── Warm coral glow (bottom-right radial) ─────────────────────────────
    glow_cx = int(s * 0.80)
    glow_cy = int(s * 0.82)
    glow_r  = int(s * 0.52)
    step    = max(1, s // 400)
    for r in range(glow_r, 0, -step):
        alpha = int(30 * (1 - r / glow_r))
        draw.ellipse(
            [glow_cx - r, glow_cy - r, glow_cx + r, glow_cy + r],
            fill=CORAL[:3] + (alpha,)
        )

    # ── Violet accent glow (top-left) ─────────────────────────────────────
    vx, vy = int(s * 0.18), int(s * 0.18)
    vr = int(s * 0.36)
    for r in range(vr, 0, -step):
        alpha = int(18 * (1 - r / vr))
        draw.ellipse(
            [vx - r, vy - r, vx + r, vy + r],
            fill=VIOLET[:3] + (alpha,)
        )

    # ── Book geometry ──────────────────────────────────────────────────────
    bw = int(s * 0.54)          # book width
    bh = int(s * 0.66)          # book height
    bx = (s - bw) // 2          # top-left x
    by = (s - bh) // 2 - int(s * 0.01)  # top-left y (slightly above center)
    br = max(3, int(s * 0.050)) # corner radius
    spine_w = int(bw * 0.25)    # spine/cover width

    # Drop shadow
    sh = max(3, int(s * 0.022))
    draw.rounded_rectangle(
        [bx + sh, by + sh, bx + bw + sh, by + bh + sh],
        radius=br,
        fill=(0, 0, 0, 70)
    )

    # Pages (cream)
    draw.rounded_rectangle([bx, by, bx + bw, by + bh], radius=br, fill=CREAM)

    # Very subtle page-edge detail (thin right edge slightly darker)
    edge_w = max(1, int(s * 0.008))
    draw.rectangle(
        [bx + bw - edge_w, by + br, bx + bw, by + bh - br],
        fill=(200, 190, 175, 160)
    )

    # Cover / spine (coral)
    draw.rounded_rectangle([bx, by, bx + spine_w, by + bh], radius=br, fill=CORAL)
    # Seal the right edge of spine (no rounded corner on right side)
    draw.rectangle([bx + spine_w - br, by, bx + spine_w, by + bh], fill=CORAL)

    # Spine highlight (thin lighter stripe)
    hl_w = max(1, int(s * 0.007))
    hl_x = bx + int(spine_w * 0.18)
    for offset in range(hl_w):
        draw.line(
            [(hl_x + offset, by + br), (hl_x + offset, by + bh - br)],
            fill=(255, 255, 255, 45)
        )

    # ── Text lines on pages ────────────────────────────────────────────────
    lx1 = bx + spine_w + max(3, int(s * 0.030))
    lx2 = bx + bw      - max(3, int(s * 0.030))
    line_h   = max(1, int(s * 0.013))
    line_gap = max(2, int(s * 0.040))
    widths = [0.82, 0.62, 0.76, 0.50, 0.70, 0.56]
    n_lines = 5 if s >= 64 else 3

    for i in range(n_lines):
        ly = by + int(s * 0.100) + i * (line_h + line_gap)
        if ly + line_h > by + bh - int(s * 0.06):
            break
        w = widths[i % len(widths)]
        draw.rounded_rectangle(
            [lx1, ly, lx1 + int((lx2 - lx1) * w), ly + line_h],
            radius=line_h // 2,
            fill=INK[:3] + (50,)
        )

    # ── Sunshine-yellow bookmark ribbon ───────────────────────────────────
    bm_w = max(4, int(spine_w * 0.54))
    bm_h = max(8, int(s * 0.145))
    bm_x = bx + (spine_w - bm_w) // 2
    bm_y = by - max(2, int(s * 0.010))
    bm_notch = max(3, bm_w // 3)

    ribbon = [
        (bm_x,           bm_y),
        (bm_x + bm_w,    bm_y),
        (bm_x + bm_w,    bm_y + bm_h),
        (bm_x + bm_w//2, bm_y + bm_h - bm_notch),
        (bm_x,           bm_y + bm_h),
    ]
    draw.polygon(ribbon, fill=SUN)

    # ── Mint accent dot (bottom-right of canvas) ───────────────────────────
    if s >= 64:
        dot_r = max(4, int(s * 0.048))
        dot_x = int(s * 0.795)
        dot_y = int(s * 0.210)
        draw.ellipse(
            [dot_x - dot_r, dot_y - dot_r, dot_x + dot_r, dot_y + dot_r],
            fill=SUN
        )
        # Inner highlight
        inner_r = max(2, int(dot_r * 0.45))
        draw.ellipse(
            [dot_x - inner_r, dot_y - inner_r, dot_x + inner_r, dot_y + inner_r],
            fill=(255, 255, 255, 120)
        )

    return img


def save(img, path, size):
    """Resize and save as PNG."""
    out = img.resize((size, size), Image.LANCZOS)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    out.save(path, 'PNG')
    print(f"  ✓  {size:4d}px  →  {os.path.relpath(path, BASE)}")


def save_maskable(img, path, size):
    """Save a maskable icon: icon scaled to 72 % to stay within the safe zone."""
    canvas = Image.new('RGBA', (size, size), INK)
    icon_size = int(size * 0.72)
    icon = img.resize((icon_size, icon_size), Image.LANCZOS)
    offset = (size - icon_size) // 2
    canvas.paste(icon, (offset, offset), icon)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    canvas.save(path, 'PNG')
    print(f"  ✓  {size:4d}px  →  {os.path.relpath(path, BASE)}  (maskable)")


def main():
    print("Drawing master icon at 1024 × 1024 …")
    master = draw_master(1024)

    # ── iOS ───────────────────────────────────────────────────────────────
    print("\niOS")
    ios = os.path.join(BASE, 'ios/Runner/Assets.xcassets/AppIcon.appiconset')
    ios_specs = [
        ('Icon-App-20x20@1x.png',    20),
        ('Icon-App-20x20@2x.png',    40),
        ('Icon-App-20x20@3x.png',    60),
        ('Icon-App-29x29@1x.png',    29),
        ('Icon-App-29x29@2x.png',    58),
        ('Icon-App-29x29@3x.png',    87),
        ('Icon-App-40x40@1x.png',    40),
        ('Icon-App-40x40@2x.png',    80),
        ('Icon-App-40x40@3x.png',   120),
        ('Icon-App-60x60@2x.png',   120),
        ('Icon-App-60x60@3x.png',   180),
        ('Icon-App-76x76@1x.png',    76),
        ('Icon-App-76x76@2x.png',   152),
        ('Icon-App-83.5x83.5@2x.png',167),
        ('Icon-App-1024x1024@1x.png',1024),
    ]
    for fname, px in ios_specs:
        save(master, os.path.join(ios, fname), px)

    # ── macOS ─────────────────────────────────────────────────────────────
    print("\nmacOS")
    macos = os.path.join(BASE, 'macos/Runner/Assets.xcassets/AppIcon.appiconset')
    macos_specs = [
        ('app_icon_16.png',    16),
        ('app_icon_32.png',    32),
        ('app_icon_64.png',    64),
        ('app_icon_128.png',  128),
        ('app_icon_256.png',  256),
        ('app_icon_512.png',  512),
        ('app_icon_1024.png',1024),
    ]
    for fname, px in macos_specs:
        save(master, os.path.join(macos, fname), px)

    # ── Android ───────────────────────────────────────────────────────────
    print("\nAndroid")
    android = os.path.join(BASE, 'android/app/src/main/res')
    android_specs = [
        ('mipmap-mdpi/ic_launcher.png',    48),
        ('mipmap-hdpi/ic_launcher.png',    72),
        ('mipmap-xhdpi/ic_launcher.png',   96),
        ('mipmap-xxhdpi/ic_launcher.png', 144),
        ('mipmap-xxxhdpi/ic_launcher.png',192),
    ]
    for fname, px in android_specs:
        save(master, os.path.join(android, fname), px)

    # ── Web ────────────────────────────────────────────────────────────────
    print("\nWeb")
    web = os.path.join(BASE, 'web')
    save(master, os.path.join(web, 'favicon.png'), 32)
    save(master, os.path.join(web, 'icons/Icon-192.png'),  192)
    save(master, os.path.join(web, 'icons/Icon-512.png'),  512)
    save_maskable(master, os.path.join(web, 'icons/Icon-maskable-192.png'), 192)
    save_maskable(master, os.path.join(web, 'icons/Icon-maskable-512.png'), 512)

    # ── Windows ICO ────────────────────────────────────────────────────────
    print("\nWindows")
    ico_path = os.path.join(BASE, 'windows/runner/resources/app_icon.ico')
    ico_images = [master.resize((sz, sz), Image.LANCZOS).convert('RGBA')
                  for sz in (16, 24, 32, 48, 64, 128, 256)]
    ico_images[0].save(
        ico_path,
        format='ICO',
        sizes=[(i.width, i.height) for i in ico_images],
        append_images=ico_images[1:],
    )
    print(f"  ✓  multi-size  →  {os.path.relpath(ico_path, BASE)}")

    print("\nDone! All icons generated.")


if __name__ == '__main__':
    main()
