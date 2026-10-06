#!/usr/bin/env python3
"""Check that every internal link, image and #anchor in the built site resolves.

    python3 tools/check_links.py        # exit code 1 when something is broken
"""
import re
import sys
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlparse

SITE = Path(__file__).resolve().parent.parent
SKIP = {"src", "tools", ".git", "node_modules", "functions"}


class Collector(HTMLParser):
    def __init__(self):
        super().__init__()
        self.refs, self.ids = [], set()

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if "id" in attrs:
            self.ids.add(attrs["id"])
        for name in ("href", "src"):
            if attrs.get(name):
                self.refs.append(attrs[name])
        for name in ("srcset",):
            if attrs.get(name):
                self.refs += [part.strip().split(" ")[0] for part in attrs[name].split(",")]


def pages():
    for path in SITE.rglob("*.html"):
        if not SKIP.intersection(path.relative_to(SITE).parts) and not path.name.startswith("_"):
            yield path


def main():
    parsed = {}
    for path in pages():
        collector = Collector()
        collector.feed(path.read_text())
        parsed[path] = collector
    broken = []
    for path, collector in parsed.items():
        for ref in collector.refs:
            url = urlparse(ref)
            if url.scheme or ref.startswith("//") or ref.startswith("mailto:"):
                continue
            target = path if not url.path else (SITE / url.path.lstrip("/") if url.path.startswith("/") else path.parent / unquote(url.path))
            if target.is_dir():
                target = target / "index.html"
            if not target.exists():
                broken.append(f"{path.relative_to(SITE)}: {ref} (missing file)")
                continue
            if url.fragment and target.suffix == ".html":
                ids = parsed[target.resolve()].ids if target.resolve() in parsed else set()
                if url.fragment not in ids:
                    broken.append(f"{path.relative_to(SITE)}: {ref} (missing #{url.fragment})")
    print(f"{len(parsed)} pages checked")
    for line in broken:
        print("BROKEN", line)
    sys.exit(1 if broken else 0)


if __name__ == "__main__":
    main()
