#!/usr/bin/env python3
"""Check every translation of www.flippin.app against English, and the built pages' SEO basics.

Sources (src/):
- each locale file has exactly English's keys (and languageNames keys);
- each translated page body exists, its metadata comment parses with English's keys, and it keeps
  English's template tokens ({{…}}), ids, links and tag counts (legal pages: one extra note <p>);
- no attribute-bound string (titles, descriptions, alt texts) holds an ASCII double quote;
- strings identical to English (likely untranslated) are listed as warnings.

Built pages (after tools/build_site.py):
- every JSON-LD block parses; <title> and meta description lengths are in range;
- <html lang> matches the locale; canonical and hreflang links are present.

    python3 tools/audit_i18n.py        # exit code 1 on errors; warnings don't fail
"""
import json
import re
import sys
from collections import Counter
from pathlib import Path

SITE = Path(__file__).resolve().parent.parent
SRC = SITE / "src"
DEFAULT = "en"
LEGAL = {"privacy-policy", "terms-of-use"}
TAGS = ("<li", "<p", "<h2", "<h3", "<section", '<span class="pill', "<table", "<tr", "<details")
ATTR_KEYS = re.compile(r"(Alt|^metaTitle|^metaDescription|^ogTitle|^navLanguage|^statsLabel|^langFlagsLabel)$")
WIDE = re.compile(r"[぀-ヿ㐀-鿿가-힯豈-﫿]")  # CJK and Hangul

errors, warnings = [], []


def meta_and_body(path: Path):
    text = path.read_text()
    match = re.match(r"<!--\s*(\{.*?\})\s*-->\n", text, re.S)
    if not match:
        raise ValueError("missing metadata comment")
    return json.loads(match.group(1)), text[match.end():]


def fingerprint(body: str) -> dict:
    tokens = Counter(re.sub(r"^(@\w+ [^|}]*).*", r"\1", token) for token in re.findall(r"\{\{([^{}]*)\}\}", body))
    return {
        "tokens": tokens,
        "ids": Counter(re.findall(r'\bid="([^"]+)"', body)),
        "hrefs": Counter(re.findall(r'href="([^"]+)"', body)),
        "tags": Counter({tag: body.count(tag) for tag in TAGS}),
    }


def check_sources(locales: dict, pages: list):
    english = locales[DEFAULT]
    for site, strings in locales.items():
        if site == DEFAULT:
            continue
        missing, extra = english.keys() - strings.keys(), strings.keys() - english.keys() - {"hreflangs"}
        if missing or extra:
            errors.append(f"{site}.json: missing {sorted(missing)} extra {sorted(extra)}")
        if strings.get("languageNames", {}).keys() != english["languageNames"].keys():
            errors.append(f"{site}.json: languageNames keys differ from English")
        for key, value in strings.items():
            if isinstance(value, str) and ATTR_KEYS.search(key) and '"' in value:
                errors.append(f"{site}.json: {key} contains a double quote")
            if (isinstance(value, str) and value == english.get(key) and len(re.sub(r"<[^>]+>", "", value)) > 24
                    and key not in ("appStore", "appStoreBadge")):
                warnings.append(f"{site}.json: {key} is identical to English")
        for key, tokens in ((key, re.findall(r"\{\{[^}]*\}\}|<span class=\"pill[^\"]*\">", value))
                            for key, value in english.items() if isinstance(value, str)):
            theirs = re.findall(r"\{\{[^}]*\}\}|<span class=\"pill[^\"]*\">", str(strings.get(key, "")))
            if Counter(tokens) != Counter(theirs):
                errors.append(f"{site}.json: {key} tokens/pills differ: {tokens} vs {theirs}")

        for name in pages:
            path = SRC / "pages" / site / f"{name}.html"
            if not path.exists():
                errors.append(f"{site}/{name}: not translated")
                continue
            en_meta, en_body = meta_and_body(SRC / "pages" / f"{name}.html")
            try:
                meta, body = meta_and_body(path)
            except (ValueError, json.JSONDecodeError) as error:
                errors.append(f"{site}/{name}: metadata comment: {error}")
                continue
            if meta.keys() != en_meta.keys():
                errors.append(f"{site}/{name}: metadata keys {sorted(meta)} vs {sorted(en_meta)}")
            for key in ("illustration", "layout", "priority"):
                if meta.get(key) != en_meta.get(key):
                    errors.append(f"{site}/{name}: metadata {key} changed")
            for key in ("title", "description"):
                if '"' in str(meta.get(key, "")):
                    errors.append(f"{site}/{name}: {key} contains a double quote")
                if meta.get(key) == en_meta.get(key):
                    warnings.append(f"{site}/{name}: {key} is identical to English")
            ours, theirs = fingerprint(en_body), fingerprint(body)
            if name in LEGAL:
                note = f"{{{{base}}}}{name}.html"
                theirs["hrefs"][note] -= 1
                theirs["tokens"]["base"] -= 1
                theirs["tags"]["<p"] -= 1
                for counter in theirs.values():
                    for key in [key for key, count in counter.items() if count == 0]:
                        del counter[key]
            for part in ("tokens", "ids", "hrefs", "tags"):
                if +ours[part] != +theirs[part]:
                    diff = (ours[part] - theirs[part]) + (theirs[part] - ours[part])
                    errors.append(f"{site}/{name}: {part} differ: {dict(diff)}")


def check_built(locales: dict, pages: list):
    for site, strings in locales.items():
        folder = "" if site == DEFAULT else f"{site}/"
        for name in ["index"] + pages:
            path = SITE / folder / ("index.html" if name == "index" else f"{name}.html")
            if not path.exists():
                errors.append(f"{folder}{name}: not built")
                continue
            html = path.read_text()
            where = f"{folder}{path.relative_to(SITE / folder) if folder else path.relative_to(SITE)}"
            for block in re.findall(r'<script type="application/ld\+json">(.*?)</script>', html, re.S):
                try:
                    json.loads(block)
                except json.JSONDecodeError as error:
                    errors.append(f"{where}: JSON-LD doesn't parse: {error}")
            if f'<html lang="{strings["lang"]}"' not in html:
                errors.append(f"{where}: <html lang> isn't {strings['lang']}")
            title = re.search(r"<title>(.*?)</title>", html, re.S).group(1)
            description = re.search(r'<meta name="description" content="([^"]*)"', html).group(1)
            wide = bool(WIDE.search(title + description))
            title_max, desc_range = (34, (50, 110)) if wide else (65, (100, 170))
            if len(title) > title_max:
                warnings.append(f"{where}: title {len(title)} chars: {title}")
            if not desc_range[0] <= len(description) <= desc_range[1]:
                warnings.append(f"{where}: description {len(description)} chars")
            if 'rel="canonical"' not in html or 'hreflang="x-default"' not in html:
                errors.append(f"{where}: canonical or hreflang missing")


def main():
    locales = {path.stem: json.loads(path.read_text()) for path in sorted((SRC / "locales").glob("*.json"))}
    pages = sorted(
        str(path.relative_to(SRC / "pages").with_suffix(""))
        for path in (SRC / "pages").rglob("*.html")
        if path.relative_to(SRC / "pages").parts[0] not in locales
    )
    check_sources(locales, pages)
    if "--sources" not in sys.argv:
        check_built(locales, pages)
    for line in warnings:
        print(f"warning: {line}")
    for line in errors:
        print(f"error: {line}")
    print(f"{len(locales)} languages, {len(pages) + 1} pages each: {len(errors)} errors, {len(warnings)} warnings")
    sys.exit(1 if errors else 0)


if __name__ == "__main__":
    main()
