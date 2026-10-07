#!/usr/bin/env python3
"""Build the website's images and fonts from the app repository.

The site is the `Website` submodule of the Flippin app repository; this script reads the app's
sources next to it and writes optimized web files to assets/:

- phones   real app captures (Documentation/ASO/screenshots/source/captures-en/ and
           captures-en-dark/) inside the iPhone 17 frame, WebP at 1x and 2x, light and dark
- cutouts  floating UI cards cropped from the same captures (light and dark)
- ills     the app's 3D illustrations (Flippin/Resources/Assets.xcassets/Illustration)
- flags    round flags of the 32 learnable languages (flags/*.svg, rasterized with Chrome)
- icon     app icon, favicons, apple-touch-icon and the web manifest icons (PNG where needed)
- fonts    Nunito Bold / ExtraBold / Black as WOFF2, split into latin, latin-ext and cyrillic
           subsets (needs fontTools + brotli: `pip install fonttools brotli`)

    python3 tools/make_assets.py                  # everything for English
    python3 tools/make_assets.py phones cutouts   # only some groups
    python3 tools/make_assets.py --localized      # phones + cutouts for every other site
                                                  # language in src/locales/ that has captures

English images go to assets/img/; a language's localized captures go to assets/img/<site>/ and
are picked up by tools/build_site.py automatically.
"""
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image, ImageDraw

SITE = Path(__file__).resolve().parent.parent
APP = SITE.parent
SHOTS = APP / "Documentation/ASO/screenshots/source"
XCASSETS = APP / "Flippin/Resources/Assets.xcassets"
FONTS = APP / "Flippin/Resources/Fonts"
IMG = SITE / "assets/img"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# Site language folder (src/locales/<site>.json) → app capture language
# (Documentation/ASO/screenshots/source/captures-<lang>/ and captures-<lang>-dark/).
SITE_CAPTURES = {
    "en": "en", "ar": "ar", "ca": "ca", "cs": "cs", "da": "da", "de": "de", "el": "el", "es": "es",
    "fi": "fi", "fr": "fr", "he": "he", "hi": "hi", "hr": "hr", "hu": "hu", "id": "id", "it": "it",
    "ja": "ja", "ko": "ko", "ms": "ms", "nb": "nb", "nl": "nl", "pl": "pl", "pt-br": "pt-BR",
    "pt": "pt-PT", "ro": "ro", "ru": "ru", "sk": "sk", "sv": "sv", "th": "th", "tr": "tr",
    "uk": "uk", "vi": "vi", "zh-hans": "zh-Hans", "zh-hant": "zh-Hant",
}

# Web name → capture file. Each becomes phone-<name>-{380,760}.webp (+ -dark-).
PHONES = {
    "study": "01-study.png",
    "study-flipped": "02-study-flipped.png",
    "add-card": "03-add-card.png",
    "practice": "04-practice.png",
    "choice": "05-choice-correct.png",
    "speak": "06-speak-correct.png",
    "streak": "10-streak.png",
    "analytics": "11-analytics.png",
    "collections": "12-collections.png",
    "ai-result": "33-ai-result.png",
    "voices": "34-voices.png",
}
PHONE_WIDTHS = (380, 760)

# Web name → (capture, crop box in capture pixels (1320 x 2868), corner radius, 1x width).
# Same boxes as the App Store screenshots (Documentation/ASO/screenshots/make_cutouts.py).
CUTOUTS = {
    "nice-banner": ("05-choice-correct.png", (0, 2268, 1320, 2800), 72, 360),
    "speak-banner": ("06-speak-correct.png", (0, 2268, 1320, 2800), 72, 360),
    "phrase-panel": ("03-add-card.png", (54, 756, 1266, 1500), 72, 360),
    "match-tile": ("07-match.png", (51, 1056, 639, 1290), 48, 200),
    "streak-chip": ("01-study.png", (274, 212, 468, 310), 49, 120),
    "goal-chip": ("01-study.png", (500, 212, 798, 310), 49, 160),
    "ai-header": ("33-ai-result.png", (48, 405, 1272, 1000), 72, 340),
    "travel-card": ("12-collections.png", (678, 970, 1272, 1810), 60, 200),
}

# Only what the pages use (the app has more: Flippin/Resources/Assets.xcassets/Illustration).
ILLUSTRATIONS = [
    "welcome", "globe", "target", "bell", "flame", "rocket", "emptyCards", "crown", "sparkles",
    "trophy", "star", "modeListen", "modeSpeak", "modeType", "unlocked", "noResults", "locked",
    "offline", "timeMaster",
]
ILL_WIDTHS = (200, 400)

# The 32 learnable languages → flag asset (same mapping as Language.flagAssetName in the app).
FLAGS = {
    "english": "us", "spanish": "es", "french": "fr", "german": "de", "italian": "it",
    "portuguese": "pt", "dutch": "nl", "swedish": "se", "chinese": "cn", "japanese": "jp",
    "korean": "kr", "vietnamese": "vn", "russian": "ru", "arabic": "sa", "hindi": "in",
    "croatian": "hr", "ukrainian": "ua", "catalan": "catalan", "czech": "cz", "danish": "dk",
    "greek": "gr", "finnish": "fi", "hebrew": "il", "hungarian": "hu", "indonesian": "id",
    "malay": "my", "norwegian": "no", "polish": "pl", "romanian": "ro", "slovak": "sk",
    "thai": "th", "turkish": "tr",
}
FLAG_SIZES = (64, 128, 256)

FONT_WEIGHTS = {700: "Bold", 800: "ExtraBold", 900: "Black"}
# Same ranges as Google Fonts' subsets; the CSS @font-face unicode-range lines must match.
FONT_SUBSETS = {
    "latin": "U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+0304,U+0308,"
             "U+0329,U+2000-206F,U+20AC,U+2122,U+2191,U+2193,U+2212,U+2215,U+FEFF,U+FFFD",
    "latin-ext": "U+0100-02BA,U+02BD-02C5,U+02C7-02CC,U+02CE-02D7,U+02DD-02FF,U+0304,U+0308,"
                 "U+0329,U+1D00-1DBF,U+1E00-1E9F,U+1EF2-1EFF,U+2020,U+20A0-20AB,U+20AD-20C0,"
                 "U+2113,U+2C60-2C7F,U+A720-A7FF",
    "cyrillic": "U+0301,U+0400-045F,U+0490-0491,U+04B0-04B1,U+2116",
    "vietnamese": "U+0102-0103,U+0110-0111,U+0128-0129,U+0168-0169,U+01A0-01A1,U+01AF-01B0,U+0300-0301,"
                  "U+0303-0304,U+0308-0309,U+0323,U+0329,U+1EA0-1EF9,U+20AB",
}


def save_webp(image: Image.Image, path: Path, width: int, quality: int = 80):
    if image.width != width:
        image = image.resize((width, round(image.height * width / image.width)), Image.LANCZOS)
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, "WEBP", quality=quality, method=6)
    print(f"  {path.relative_to(SITE)} {image.width}x{image.height} {path.stat().st_size // 1024} KB")


def rounded_mask(size, radius, scale=4):
    w, h = size
    mask = Image.new("L", (w * scale, h * scale), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, w * scale - 1, h * scale - 1), radius * scale, fill=255)
    return mask.resize(size, Image.LANCZOS)


def phone_image(capture: Path) -> Image.Image:
    """iPhone 17 frame (978 x 2000, screen opening x 54-923, y 51-1948) around a capture."""
    frame = Image.open(SHOTS / "app/iphone-17-frame.png").convert("RGBA")
    box = (54, 51, 923, 1948)
    size = (box[2] - box[0], box[3] - box[1])
    shot = Image.open(capture).convert("RGBA")
    scale = max(size[0] / shot.width, size[1] / shot.height)
    shot = shot.resize((round(shot.width * scale), round(shot.height * scale)), Image.LANCZOS)
    left, top = (shot.width - size[0]) // 2, (shot.height - size[1]) // 2
    shot = shot.crop((left, top, left + size[0], top + size[1]))
    canvas = Image.new("RGBA", frame.size, (0, 0, 0, 0))
    canvas.paste(Image.new("RGBA", size, (0, 0, 0, 255)), box[:2], rounded_mask(size, 120))
    canvas.paste(shot, box[:2], rounded_mask(size, 110))
    canvas.alpha_composite(frame)
    return canvas


def capture_dirs(lang: str):
    """(suffix, folder) for the light and dark captures of an app language."""
    return [("", SHOTS / f"captures-{lang}"), ("-dark", SHOTS / f"captures-{lang}-dark")]


def make_phones(lang: str = "en", out: Path = IMG):
    print(f"phones ({lang})")
    for suffix, folder in capture_dirs(lang):
        for name, capture in PHONES.items():
            source = folder / capture
            if not source.exists():
                print(f"  skip {name}{suffix}: {source} missing")
                continue
            image = phone_image(source)
            for width in PHONE_WIDTHS:
                save_webp(image, out / f"phone-{name}{suffix}-{width}.webp", width)


# Capture languages laid out right to left: their screens are mirrored, so are the crop boxes.
RTL_CAPTURES = {"ar", "he"}
# The top-bar chips change width with the digits, so in RTL they are found, not mirrored:
# chip index counted from the trailing (right) edge — 0 is the language chip.
RTL_CHIPS = {"streak-chip": 1, "goal-chip": 2}


def rtl_chip_box(lang: str, index: int, fallback):
    """Box around the index-th white top-bar chip from the right in the light 01-study capture."""
    image = Image.open(SHOTS / f"captures-{lang}" / "01-study.png").convert("RGB")
    y, runs, start = 300, [], None
    for x in range(image.width + 1):
        bright = x < image.width and sum(image.getpixel((x, y))) / 3 > 200
        if bright and start is None:
            start = x
        elif not bright and start is not None:
            if x - start > 80:
                runs.append((start, x))
            start = None
    runs.sort(key=lambda run: -run[0])
    if len(runs) <= index:
        return fallback
    left, right = runs[index]
    return (left - 10, fallback[1], right + 10, fallback[3])


def make_cutouts(lang: str = "en", out: Path = IMG):
    print(f"cutouts ({lang})")
    for suffix, folder in capture_dirs(lang):
        for name, (capture, box, radius, width) in CUTOUTS.items():
            source = folder / capture
            if not source.exists():
                print(f"  skip {name}{suffix}: {source} missing")
                continue
            image = Image.open(source).convert("RGBA")
            if lang in RTL_CAPTURES:
                left, top, right, bottom = box
                box = (image.width - right, top, image.width - left, bottom)
                if name in RTL_CHIPS:
                    box = rtl_chip_box(lang, RTL_CHIPS[name], box)
            crop = image.crop(box)
            crop.putalpha(rounded_mask(crop.size, radius))
            for scale in (1, 2):
                save_webp(crop, out / f"cut-{name}{suffix}-{width * scale}.webp", width * scale, 86)


def make_illustrations():
    print("illustrations")
    for name in ILLUSTRATIONS:
        image = Image.open(XCASSETS / f"Illustration/{name}.imageset/{name}.png").convert("RGBA")
        for width in ILL_WIDTHS:
            save_webp(image, IMG / f"ill-{name}-{width}.webp", width, 84)


def make_flags():
    """Rasterize the round SVG flags with headless Chrome (PIL can't read SVG)."""
    print("flags")
    cell = max(FLAG_SIZES)
    codes = sorted(set(FLAGS.values()))
    columns = 8
    rows = -(-len(codes) // columns)
    with tempfile.TemporaryDirectory() as tmp:
        page = Path(tmp) / "flags.html"
        cells = "".join(
            f'<img src="file://{XCASSETS}/flags/{code}.imageset/{code}.svg" '
            f'style="position:absolute;left:{(i % columns) * cell}px;top:{(i // columns) * cell}px;'
            f'width:{cell}px;height:{cell}px">'
            for i, code in enumerate(codes)
        )
        page.write_text(f"<!doctype html><html><body style='margin:0;background:transparent'>{cells}</body></html>")
        shot = Path(tmp) / "flags.png"
        subprocess.run([
            CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--force-device-scale-factor=1",
            "--default-background-color=00000000", f"--window-size={columns * cell},{rows * cell}",
            f"--screenshot={shot}", f"file://{page}",
        ], check=True, capture_output=True)
        sheet = Image.open(shot).convert("RGBA")
        for i, code in enumerate(codes):
            x, y = (i % columns) * cell, (i // columns) * cell
            flag = sheet.crop((x, y, x + cell, y + cell))
            for size in FLAG_SIZES:
                save_webp(flag, IMG / f"flag-{code}-{size}.webp", size, 86)


def make_icon():
    print("icon")
    icon = Image.open(XCASSETS / "iconRoundedBlue.imageset/IconBlue-iOS-Default-1024x1024@1x 2.png").convert("RGBA")
    for width in (64, 128, 256):
        save_webp(icon, IMG / f"app-icon-{width}.webp", width, 90)
    icon.resize((512, 512), Image.LANCZOS).save(IMG / "app-icon.png", optimize=True)
    # Square icons (no transparent corners) for iOS home screen and Android: the icon on a sky
    # gradient sampled from its own top and bottom edges.
    top, bottom = icon.getpixel((256, 40))[:3], icon.getpixel((256, 470))[:3]
    square = Image.new("RGBA", icon.size)
    draw = ImageDraw.Draw(square)
    for y in range(icon.height):
        t = y / (icon.height - 1)
        draw.line([(0, y), (icon.width, y)], fill=tuple(round(a + (b - a) * t) for a, b in zip(top, bottom)) + (255,))
    square.alpha_composite(icon)
    fav = SITE / "favicons"
    fav.mkdir(exist_ok=True)
    for name, size, image in [
        ("apple-touch-icon.png", 180, square), ("android-chrome-192x192.png", 192, square),
        ("android-chrome-512x512.png", 512, square), ("favicon-32x32.png", 32, icon),
        ("favicon-16x16.png", 16, icon), ("favicon-96x96.png", 96, icon),
    ]:
        image.resize((size, size), Image.LANCZOS).save(fav / name, optimize=True)
        print(f"  favicons/{name}")
    icon.resize((48, 48), Image.LANCZOS).save(fav / "favicon.ico", sizes=[(16, 16), (32, 32), (48, 48)])
    (fav / "site.webmanifest").write_text(json.dumps({
        "name": "Flippin", "short_name": "Flippin",
        "icons": [
            {"src": "android-chrome-192x192.png", "sizes": "192x192", "type": "image/png"},
            {"src": "android-chrome-512x512.png", "sizes": "512x512", "type": "image/png"},
        ],
        "theme_color": "#0A7AC0", "background_color": "#F2F8FE", "display": "browser",
    }, indent=2) + "\n")


def make_fonts():
    print("fonts")
    try:
        from fontTools import subset
    except ImportError:
        sys.exit("fonts need fontTools and brotli: pip install fonttools brotli")
    out = SITE / "assets/fonts"
    out.mkdir(parents=True, exist_ok=True)
    for weight, style in FONT_WEIGHTS.items():
        for name, ranges in FONT_SUBSETS.items():
            target = out / f"nunito-{weight}-{name}.woff2"
            subset.main([
                str(FONTS / f"Nunito-{style}.ttf"), f"--unicodes={ranges}", "--flavor=woff2",
                "--layout-features=*", "--no-hinting", "--desubroutinize", f"--output-file={target}",
            ])
            print(f"  assets/fonts/{target.name} {target.stat().st_size // 1024} KB")
    shutil.copy(FONTS / "Nunito-OFL.txt", out / "Nunito-OFL.txt")


def localized_sites():
    return [path.stem for path in sorted((SITE / "src/locales").glob("*.json")) if path.stem != "en"]


def main():
    args = [arg for arg in sys.argv[1:] if not arg.startswith("--")]
    if "--localized" in sys.argv:
        for site in localized_sites():
            lang = SITE_CAPTURES.get(site)
            if not lang or not (SHOTS / f"captures-{lang}").exists():
                print(f"{site}: no captures, the site uses the English images")
                continue
            make_phones(lang, IMG / site)
            make_cutouts(lang, IMG / site)
        return
    groups = {
        "phones": make_phones, "cutouts": make_cutouts, "ills": make_illustrations,
        "flags": make_flags, "icon": make_icon, "fonts": make_fonts,
    }
    for name in args or groups:
        groups[name]()


if __name__ == "__main__":
    main()
