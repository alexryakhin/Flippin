#!/usr/bin/env python3
"""Build every page of www.flippin.app in every site language.

Languages are the files in src/locales/: <site>.json, where <site> is the folder the language is
published in: English (en) at the site root, every other language at /<site>/ (e.g. /de/,
/pt-br/). A locale file holds the landing page strings and the shared strings (header, footer,
call to action) plus "lang" (BCP 47), "dir", "languageName" (shown in the language picker),
"appStore" and the App Store badge. A missing string falls back to English with a warning.

Pages:
- the landing page: src/landing.html + the locale strings → index.html, <site>/index.html
- inner pages: src/page.html (shell) + a body in src/pages/<name>.html (English) or
  src/pages/<site>/<name>.html (a translation; a missing one falls back to the English body,
  marked lang="en"). <name> can contain a folder (learn/flashcards). The body starts with a
  <!-- {json} --> comment: title, description, eyebrow, heading, lead, illustration, layout
  ("doc" = text on a paper card, "wide" = the body brings its own sections), priority (sitemap).

Templates use {{key}} for strings and values, {{>partial}} for src/partials/<partial>.html, and
image macros that write <picture> markup with light/dark and 1x/2x sources:

    {{@phone study|altKey|class}}    phone-study-*.webp (localized under assets/img/<site>/)
    {{@cut nice-banner|altKey|class}} a floating UI card cut out of a capture (localized)
    {{@ill trophy|class}}            decorative 3D illustration
    {{@flag es|size|class}}          round flag, size in CSS px (decorative)

altKey is a string key, or literal text when no such key exists. Every language also gets a
1200 x 630 share image (assets/img/og-<site>.png), and sitemap.xml lists every page with its
hreflang alternates.

    python3 tools/build_site.py            # everything
    python3 tools/build_site.py --no-og    # skip the share images (needs Google Chrome)
"""
import hashlib
import html
import json
import re
import subprocess
import sys
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
from make_assets import FLAGS  # noqa: E402  language → flag asset, shared with the image builder

SITE = Path(__file__).resolve().parent.parent
SRC = SITE / "src"
IMG = SITE / "assets/img"
ORIGIN = "https://www.flippin.app/"
DEFAULT = "en"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
PARTIALS = {path.stem: path.read_text() for path in (SRC / "partials").glob("*.html")}
STORAGE_KEY = "flippin.lang"


# ---------------------------------------------------------------------------------------------
# Locales and pages

def load_locales() -> dict:
    locales = {path.stem: json.loads(path.read_text()) for path in (SRC / "locales").glob("*.json")}
    english = locales[DEFAULT]
    for site, strings in locales.items():
        missing = [key for key in english if key not in strings]
        if missing:
            print(f"warning: {site} is missing {len(missing)} strings, using English: {', '.join(missing[:6])}…")
            locales[site] = {**english, **strings}
    # English first, then the other languages alphabetically by folder.
    return dict(sorted(locales.items(), key=lambda item: (item[0] != DEFAULT, item[0])))


def english_pages(locales: dict) -> list:
    """Inner page names (e.g. "features", "learn/flashcards") from src/pages, translations excluded."""
    names = []
    for path in sorted((SRC / "pages").rglob("*.html")):
        relative = path.relative_to(SRC / "pages")
        if relative.parts[0] in locales:
            continue
        names.append(str(relative.with_suffix("")))
    return names


def folder(site: str) -> str:
    return "" if site == DEFAULT else f"{site}/"


def page_file(name: str) -> str:
    return "" if name == "index" else f"{name}.html"


def page_url(site: str, name: str) -> str:
    return f"{ORIGIN}{folder(site)}{page_file(name)}"


def read_page(site: str, name: str):
    """(metadata, body, is_translated) for an inner page, falling back to English."""
    translated = SRC / "pages" / site / f"{name}.html"
    source = translated if site != DEFAULT and translated.exists() else SRC / "pages" / f"{name}.html"
    text = source.read_text()
    meta = re.match(r"<!--\s*(\{.*?\})\s*-->\n", text, re.S)
    if not meta:
        raise ValueError(f"{source}: the first line must be a <!-- {{json}} --> metadata comment")
    return json.loads(meta.group(1)), text[meta.end():].rstrip(), site == DEFAULT or source == translated


# ---------------------------------------------------------------------------------------------
# Head links, language picker

def alternates(locales: dict, name: str) -> str:
    lines = [
        f'  <link rel="alternate" hreflang="{code}" href="{page_url(site, name)}">'
        for site, strings in locales.items()
        for code in strings.get("hreflangs", [strings["lang"]])
    ]
    lines.append(f'  <link rel="alternate" hreflang="x-default" href="{page_url(DEFAULT, name)}">')
    return "\n".join(lines)


GLOBE = (
    '<svg width="18" height="18" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9.5" '
    'fill="none" stroke="currentColor" stroke-width="2"/><path d="M2.5 12h19M12 2.5c2.6 2.8 3.9 6 3.9 9.5s'
    '-1.3 6.7-3.9 9.5c-2.6-2.8-3.9-6-3.9-9.5s1.3-6.7 3.9-9.5z" fill="none" stroke="currentColor" '
    'stroke-width="2"/></svg>'
)


def language_picker(locales: dict, current: str, name: str, base: str) -> str:
    """Header dropdown linking to the same page in every language. Hidden with one language."""
    if len(locales) < 2:
        return ""
    items = []
    for site, strings in locales.items():
        href = f"{base}{folder(site)}{page_file(name)}" or "./"
        current_attr = ' aria-current="page"' if site == current else ""
        items.append(
            f'          <li><a href="{href}" hreflang="{strings["lang"]}" lang="{strings["lang"]}"{current_attr}>'
            f'{strings["languageName"]}</a></li>'
        )
    strings = locales[current]
    code = strings["lang"].split("-")[0].upper()
    return (
        '      <details class="lang">\n'
        f'        <summary aria-label="{html.escape(strings["navLanguage"])}">{GLOBE}'
        f'<span class="lang-code">{code}</span></summary>\n'
        '        <ul>\n' + "\n".join(items) + "\n        </ul>\n      </details>"
    )


# ---------------------------------------------------------------------------------------------
# Image macros

_sizes: dict = {}


def image_size(path: Path):
    if path not in _sizes:
        with Image.open(path) as image:
            _sizes[path] = image.size
    return _sizes[path]


def variants(prefix: str, directory: Path):
    """Widths available for <prefix>-<width>.webp in a directory, smallest first."""
    widths = sorted(
        int(match.group(1))
        for path in directory.glob(f"{prefix}-*.webp")
        if (match := re.fullmatch(re.escape(prefix) + r"-(\d+)\.webp", path.name))
    )
    if not widths:
        raise FileNotFoundError(f"no {prefix}-<width>.webp in {directory} (run tools/make_assets.py)")
    return widths


def picture(kind: str, name: str, alt: str, css: str, values: dict, sizes: str) -> str:
    """<picture> with a dark-mode source (when made) and 1x/2x srcsets."""
    localized = values["shotsDir"]
    directory = localized if (localized / f"{kind}-{name}-{variants(f'{kind}-{name}', IMG)[0]}.webp").exists() else IMG
    prefix = values["shots"] if directory == localized else values["img"]
    widths = variants(f"{kind}-{name}", directory)
    srcset = lambda suffix: ", ".join(f"{prefix}{kind}-{name}{suffix}-{w}.webp {w}w" for w in widths)
    width, height = image_size(directory / f"{kind}-{name}-{widths[0]}.webp")
    eager = "eager" in css.split()
    loading = 'fetchpriority="high"' if eager else 'loading="lazy"'
    dark = ""
    if (directory / f"{kind}-{name}-dark-{widths[0]}.webp").exists():
        dark = f'<source media="(prefers-color-scheme: dark)" srcset="{srcset("-dark")}" sizes="{sizes}">'
    classes = " ".join(part for part in (kind, css) if part)
    return (
        f'<picture class="{classes}">{dark}'
        f'<img src="{prefix}{kind}-{name}-{widths[0]}.webp" srcset="{srcset("")}" sizes="{sizes}" '
        f'width="{width}" height="{height}" alt="{alt.replace(chr(34), "&quot;")}" {loading} decoding="async"></picture>'
    )


def macro(match: re.Match, values: dict) -> str:
    kind, args = match.group(1), match.group(2).split("|")
    arg = lambda i, default="": args[i].strip() if len(args) > i else default
    text = lambda key: values.get(key, key)
    if kind == "phone":
        return picture("phone", arg(0), text(arg(1)), arg(2), values, "(min-width: 960px) 320px, 62vw")
    if kind == "cut":
        return picture("cut", arg(0), text(arg(1)), arg(2), values, "(min-width: 960px) 360px, 70vw")
    if kind == "ill":
        widths = variants(f"ill-{arg(0)}", IMG)
        srcset = ", ".join(f'{values["img"]}ill-{arg(0)}-{w}.webp {w}w' for w in widths)
        return (f'<img class="ill {arg(1)}" src="{values["img"]}ill-{arg(0)}-{widths[0]}.webp" srcset="{srcset}" '
                f'sizes="200px" width="{widths[0]}" height="{widths[0]}" alt="" loading="lazy" decoding="async">')
    if kind == "flag":
        size = int(arg(1, "48"))
        widths = variants(f"flag-{arg(0)}", IMG)
        src1 = next((w for w in widths if w >= size), widths[-1])
        src2 = next((w for w in widths if w >= size * 2), widths[-1])
        return (f'<img class="flag {arg(2)}" src="{values["img"]}flag-{arg(0)}-{src1}.webp" '
                f'srcset="{values["img"]}flag-{arg(0)}-{src2}.webp 2x" width="{size}" height="{size}" alt="" '
                f'loading="lazy" decoding="async">')
    raise KeyError(f"unknown macro {kind}")


# ---------------------------------------------------------------------------------------------
# Templating

def expand(template: str) -> str:
    for _ in range(3):
        template = re.sub(r"\{\{>(\w+)\}\}\n?", lambda m: PARTIALS[m.group(1)], template)
    return template


def fill(template: str, values: dict, where: str) -> str:
    def value(match: re.Match) -> str:
        key = match.group(1)
        if key not in values:
            raise KeyError(f"{where}: missing string {key!r}")
        return str(values[key])

    page = template
    for _ in range(4):  # strings may hold {{root}} links or image macros
        page = re.sub(r"\{\{(\w+)\}\}", value, page)
        page = re.sub(r"\{\{@(\w+) ([^}]*)\}\}", lambda m: macro(m, values), page)
        if "{{" not in page:
            break
    # Attributes can't carry markup: strip tags inside alt="…", content="…" and aria-label="…".
    return re.sub(
        r'((?:alt|content|aria-label)=")([^"]*)(")',
        lambda m: m.group(1) + re.sub(r"<[^>]+>", "", m.group(2)) + m.group(3),
        page,
    )


def asset_version(*paths: str) -> str:
    digest = hashlib.sha1()
    for path in paths:
        digest.update((SITE / path).read_bytes())
    return digest.hexdigest()[:8]


def language_lists(strings: dict) -> dict:
    """Flag row (landing) and flag tiles (languages page) from the locale's languageNames."""
    names = strings["languageNames"]
    ordered = sorted(names.items(), key=lambda item: item[1])
    row = "\n".join(
        f'<li title="{name}">{{{{@flag {FLAGS[key]}|40}}}}<span class="sr">{name}</span></li>'
        for key, name in names.items()
    )
    tiles = "\n".join(
        f'<li class="paper lang-tile">{{{{@flag {FLAGS[key]}|48}}}}<span>{name}</span></li>' for key, name in ordered
    )
    return {"langFlags": row, "languageTiles": tiles}


def common_values(site: str, locales: dict, name: str) -> dict:
    depth = name.count("/") + (0 if site == DEFAULT else 1)
    base = "../" * depth                  # to the site root (assets, favicons)
    root = "../" * name.count("/")        # to this language's root (its pages)
    values = dict(locales[site])
    values.update(language_lists(values))
    values.update(
        site=site,
        base=base,
        root=root,
        home=root or "./",
        img=f"{base}assets/img/",
        shots=f"{base}assets/img/{site}/",
        shotsDir=IMG / site,
        assetVersion=asset_version("assets/css/site.css", "assets/js/site.js"),
        canonical=page_url(site, name),
        ogImage=f"{ORIGIN}assets/img/og-{site}.png",
        alternates=alternates(locales, name),
        languagePicker=language_picker(locales, site, name, base),
        # Only English pages pick the visitor's language, and only when there is another one.
        autoLanguage=PARTIALS["autolang"] if site == DEFAULT and len(locales) > 1 else "",
        year="2026",
    )
    return values


def render_landing(site: str, locales: dict) -> str:
    values = common_values(site, locales, "index")
    values.update(navBase="", pageClass="home")
    return fill(expand((SRC / "landing.html").read_text()), values, f"{site}/index")


def render_page(site: str, name: str, locales: dict) -> str:
    meta, body, translated = read_page(site, name)
    values = common_values(site, locales, name)
    values.update({f"page{key[0].upper()}{key[1:]}": value for key, value in meta.items()})
    values.setdefault("pageIllustration", "welcome")
    values.setdefault("pageLayout", "doc")
    values.setdefault("pageEyebrow", "")
    values.update(navBase=values["home"], pageClass=f"page-{name.replace('/', '-')}")
    body = fill(body, values, f"{site}/{name} body")
    if not translated:
        body = f'<div lang="en" dir="ltr">\n{body}\n</div>'
    if values["pageLayout"] == "doc":
        body = f'<section class="section grid-paper doc-section">\n  <div class="wrap narrow">\n    <article class="paper doc">\n{body}\n    </article>\n  </div>\n</section>'
    values["content"] = body
    return fill(expand((SRC / "page.html").read_text()), values, f"{site}/{name}")


# ---------------------------------------------------------------------------------------------
# Share images and sitemap

def share_image(site: str, locales: dict):
    """1200 x 630 share card: the hero headline on the sky, the study phone and flags."""
    values = common_values(site, locales, "index")
    values.update(img="", shots=f"{site}/", base="../../")
    page = IMG / f"_og-{site}.html"
    page.write_text(fill(f"""<!doctype html><html lang="{{{{lang}}}}" dir="{{{{dir}}}}"><head><meta charset="utf-8">
<link rel="stylesheet" href="../css/site.css">
<style>
html, body {{ margin: 0; width: 1200px; height: 630px; overflow: hidden; }}
.og {{ position: relative; width: 1200px; height: 630px; overflow: hidden; display: flex; align-items: center; }}
.og-copy {{ position: relative; z-index: 3; padding-inline-start: 72px; width: 690px; }}
.og-copy .headline {{ font-size: 84px; margin: 0; }}
.og-brand {{ display: flex; gap: 16px; align-items: center; margin-top: 34px; }}
.og-brand img {{ width: 72px; height: 72px; }}
.og-brand span {{ font: 900 44px/1 Nunito, sans-serif; color: #fff; text-shadow: 0 4px 0 #07588F; }}
.og .phone {{ position: absolute; z-index: 2; width: 330px; inset-inline-end: 110px; top: 40px; transform: rotate(-4deg); }}
.og .phone img {{ width: 100%; height: auto; }}
.og .flag {{ position: absolute; z-index: 1; filter: drop-shadow(0 10px 14px rgba(0,40,90,.3)); }}
</style></head><body><div class="og sky" style="color-scheme: light">
<div class="og-copy"><h1 class="headline">{{{{heroTitle}}}}</h1>
<div class="og-brand"><img src="app-icon-256.webp" alt=""><span>Flippin</span></div></div>
{{{{@phone study|heroPhoneAlt|eager}}}}
{{{{@flag es|120|og-f1}}}}{{{{@flag fr|96|og-f2}}}}{{{{@flag jp|90|og-f3}}}}{{{{@flag de|100|og-f4}}}}
<style>.og-f1{{left:680px;top:120px;transform:rotate(-8deg)}}.og-f2{{left:1080px;top:150px}}.og-f3{{left:1070px;top:430px}}.og-f4{{left:745px;top:440px;transform:rotate(6deg)}}</style>
</div></body></html>""", values, f"og-{site}").replace('loading="lazy"', ""))
    # The page is light-only: drop dark sources so a dark-mode machine renders the same card.
    page.write_text(re.sub(r'<source media="\(prefers-color-scheme: dark\)"[^>]*>', "", page.read_text()))
    out = IMG / f"og-{site}.png"
    subprocess.run([
        CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--force-device-scale-factor=1",
        "--window-size=1200,630", "--virtual-time-budget=5000", f"--screenshot={out}", f"file://{page}",
    ], check=True, capture_output=True)
    page.unlink()
    print(f"  assets/img/og-{site}.png")


def sitemap(locales: dict, pages: list):
    entries = [("index", "1.0")] + [(name, read_page(DEFAULT, name)[0].get("priority", "0.6")) for name in pages]
    lines = []
    for site in locales:
        for name, priority in entries:
            links = "".join(
                f'\n    <xhtml:link rel="alternate" hreflang="{code}" href="{page_url(other, name)}"/>'
                for other, strings in locales.items()
                for code in strings.get("hreflangs", [strings["lang"]])
            )
            links += f'\n    <xhtml:link rel="alternate" hreflang="x-default" href="{page_url(DEFAULT, name)}"/>'
            lines.append(f"  <url>\n    <loc>{page_url(site, name)}</loc>{links}\n    <priority>{priority}</priority>\n  </url>")
    (SITE / "sitemap.xml").write_text(
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">\n'
        + "\n".join(lines) + "\n</urlset>\n"
    )


def main():
    locales = load_locales()
    pages = english_pages(locales)
    for site in locales:
        out_dir = SITE / folder(site)
        out_dir.mkdir(parents=True, exist_ok=True)
        (out_dir / "index.html").write_text(render_landing(site, locales))
        for name in pages:
            target = out_dir / f"{name}.html"
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(render_page(site, name, locales))
        print(f"{site}: index + {len(pages)} pages")
        if "--no-og" not in sys.argv:
            share_image(site, locales)
    sitemap(locales, pages)
    print("sitemap.xml")


if __name__ == "__main__":
    main()
