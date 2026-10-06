# Flippin Website

The public website for **Flippin** (https://www.flippin.app), served by GitHub Pages from this
repository (`CNAME`). It is the `Website` submodule of the Flippin app repository.

The site is static HTML generated from templates. It follows the app's 2.0 look and the App
Store screenshots: alternating **sky** sections (blue gradient with clouds; a starry night in dark
mode) and **grid paper** sections, Nunito Black headlines with one keyword in a tilted gold pill,
chunky buttons, paper cards, real app captures in an iPhone frame, the app's 3D illustrations and
round flags. Light and dark mode follow the system (`prefers-color-scheme`).

## Pages

The App Store listing and search engines link to these paths; keep them stable.

| Path | Source |
|---|---|
| `/` (`index.html`) | `src/landing.html` + `src/locales/en.json` |
| `/features.html` | `src/pages/features.html` |
| `/languages.html` | `src/pages/languages.html` |
| `/support.html` | `src/pages/support.html` (FAQ, common issues, support@flippin.app) |
| `/privacy-policy.html` | `src/pages/privacy-policy.html` (legal text; change only deliberately) |
| `/terms-of-use.html` | `src/pages/terms-of-use.html` (legal text; change only deliberately) |
| `/learn/flashcards.html`, `/learn/pronunciation.html`, `/learn/analytics.html` | `src/pages/learn/` |
| `/compare/anki.html` | `src/pages/compare/anki.html` |

Content must match `Documentation/AppCapabilities.md` in the app repository (the source of truth
for features, limits and prices). Don't add numbers, ratings, user counts or testimonials that
aren't there.

## Layout

```
src/landing.html               landing page template
src/page.html                  shell for every inner page (sky header, body, CTA, footer)
src/partials/                  head, header (+ language picker), footer, CTA band, autolang script
src/locales/<site>.json        strings for one language: landing page, header, footer, CTA,
                               language names, App Store link and badge
src/pages/<name>.html          English page bodies; <name> may contain a folder (learn/flashcards)
src/pages/<site>/<name>.html   translated page bodies (optional; missing ones fall back to English)
assets/css/site.css            all styles (tokens on :root, dark mode, components)
assets/js/site.js              reveal-on-scroll, header menus, language memory, analytics events,
                               WebMCP tools for browser agents
assets/fonts/                  Nunito 700/800/900 WOFF2 subsets + Nunito-OFL.txt (SIL OFL 1.1)
assets/img/                    generated images (see below) and og-<site>.png share images
assets/img/<site>/             a language's localized phone captures and cut-outs (optional)
favicons/                      favicons, apple-touch-icon, web manifest
tools/make_assets.py           builds images and fonts from the app repository
tools/build_site.py            builds every page in every language, share images, sitemap.xml
tools/check_links.py           checks that every internal link, image and #anchor resolves
```

Generated files (`index.html`, `features.html`, …, `learn/`, `compare/`, `sitemap.xml`,
`assets/img/og-*.png`) are committed, because GitHub Pages serves the repository as is. Edit the
sources in `src/`, then rebuild.

### Templates

- `{{key}}` inserts a string from the locale file or a value from the build (`root`, `base`,
  `img`, `appStore`, `canonical`, …). Locale strings may contain HTML;
  `<span class="pill">Word</span>` is the gold keyword pill (`pill r` tilts it the other way).
- `{{>name}}` includes `src/partials/name.html`.
- Image macros write responsive `<picture>` markup with 1x/2x sources and a dark-mode variant:
  `{{@phone study|altKey|classes}}`, `{{@cut nice-banner|altKey|classes}}`,
  `{{@ill trophy|classes}}`, `{{@flag es|48|classes}}`. `altKey` is a locale key or literal text.
  Add `eager` to the classes of an above-the-fold image.
- A page body starts with a JSON comment:
  `<!-- {"title": …, "description": …, "eyebrow": …, "heading": …, "lead": …, "illustration": "bell", "layout": "doc" | "wide", "priority": "0.6"} -->`.
  `doc` wraps the body in a paper card; `wide` bodies bring their own `<section>`s.
  Links to other pages use `{{root}}` (e.g. `{{root}}support.html`).

## Build

```bash
pip install fonttools brotli                   # once, only for the fonts step
python3 tools/make_assets.py                   # images + fonts (after new app captures)
python3 tools/make_assets.py phones cutouts    # just some groups: phones cutouts ills flags icon fonts
python3 tools/build_site.py                    # all pages, share images, sitemap.xml
python3 tools/build_site.py --no-og            # skip share images (they need Google Chrome)
python3 tools/check_links.py                   # broken internal links → exit code 1
python3 -m http.server 8765                    # preview at http://localhost:8765
```

`make_assets.py` reads the app repository next to this folder:
`Documentation/ASO/screenshots/source/captures-en/` and `captures-en-dark/` (git-ignored in the
app repo; produce them with its capture scripts), the iPhone 17 frame in `source/app/`, the 3D
illustrations in `Flippin/Resources/Assets.xcassets/Illustration` (IconScout licence, see the app's
`Documentation/Illustrations-LICENSE.md`), the round flags in `Assets.xcassets/flags` (rasterized
with headless Chrome) and Nunito from `Flippin/Resources/Fonts`. Phones are WebP at 380 and 760 px
wide, cut-outs at 1x/2x, illustrations at 200/400 px; PNG only where it's required (favicons,
apple-touch-icon, share images).

## Languages

English is the only language today. English pages live at the site root; every other language is
published in its own folder (`/de/`, `/pt-br/`, …) with the same file names. Every page lists all
its language versions as `hreflang` alternates (and in `sitemap.xml`).

While there is only one language, the header language picker and the automatic redirect are not
rendered at all. As soon as a second locale file exists:

- the header shows a language picker that links to the same page in every language and remembers
  the choice in `localStorage` (`flippin.lang`);
- on a first visit to an English page, `src/partials/autolang.html` sends visitors to their browser
  language's version when the site has one. A remembered choice wins; English speakers, crawlers
  and same-site navigation are never redirected, and translated pages never redirect.

### Adding a language

1. **Strings:** copy `src/locales/en.json` to `src/locales/<site>.json` (e.g. `de.json`,
   `pt-br.json`, `zh-hans.json`) and translate the values. Set `lang` (BCP 47, e.g. `pt-BR`),
   `dir` (`rtl` for Arabic/Hebrew), `locale` (`pt_BR`), `languageName` (the language's own name,
   e.g. `Deutsch`), the localized `appStore` URL (e.g. `https://apps.apple.com/de/app/flippin/id6748499528`)
   and `appStoreBadge` (Apple's badge URL for that language). Prices in `premiumPrice` / `premiumNote`
   / `pricingFine` should stay generic or match that storefront. Missing keys fall back to English
   with a warning.
2. **Pages (optional):** add translated bodies as `src/pages/<site>/<name>.html` (same JSON comment
   first line). Pages without a translation are published in English inside the localized shell.
   For privacy and terms, start the translation with a note that the English version applies.
3. **Captures (optional):** capture the app in that language (app repo:
   `Documentation/ASO/screenshots/`, folders `source/captures-<lang>/` and `-dark/`), map the site
   folder to the capture language in `SITE_CAPTURES` in `tools/make_assets.py` if the names differ,
   then run `python3 tools/make_assets.py --localized`. Images land in `assets/img/<site>/` and are
   picked up automatically; without them the English images are used.
4. Run `python3 tools/build_site.py` and `python3 tools/check_links.py`, preview, commit.
   Languages outside Nunito's Latin/Cyrillic coverage (Greek, Arabic, Hebrew, Hindi, Thai, CJK)
   fall back to the system rounded/sans font; add a font there if needed.

## Hosting, headers and agents

- **GitHub Pages** serves `www.flippin.app` today. It ignores `_headers`, `netlify.toml` and
  `vercel.json` and can't run `functions/`; those mirror the same `Link` / `Vary` headers for
  Cloudflare Pages, Netlify and Vercel. Keep the `Link` value in sync across `_headers`,
  `netlify.toml`, `vercel.json` and `functions/index.ts`.
- `functions/index.ts` (Cloudflare Pages) answers `Accept: text/markdown` on `/` with `index.md`.
  Keep `index.md` in step with the landing page.
- `/.well-known/*`: API catalog (RFC 9727 linkset), OpenAPI stub, health JSON, MCP server card and
  the agent skills index. The landing page also links them with `<link rel>`. This is a static
  marketing site: don't publish OAuth / OpenID discovery documents.
- `assets/js/site.js` registers WebMCP tools (`open_app_store`, `open_support`,
  `open_languages`) when the browser exposes `navigator.modelContext`.
- Analytics: Google Analytics `G-TT6GZ2QPB6`; App Store clicks send `cta_appstore_click` /
  `cta_pricing_click` with a `placement`, opened FAQ items send `faq_expand`.

## Contact

Support: `support@flippin.app`
