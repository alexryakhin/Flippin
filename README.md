# Flippin Website

This folder contains the public website for **Flippin** (`www.flippin.app`).

## What this website is for

- Explain what Flippin is and why it’s useful
- Send people to the **App Store** to download the app
- Provide **support** and **legal** pages (Privacy Policy, Terms)
- Publish a few helpful pages that can show up in Google search (SEO pages)

## Main pages

- `index.html`: Main landing page (download-focused)
- `features.html`: Overview of key features
- `languages.html`: Supported languages list
- `support.html`: FAQs + support contact
- `privacy-policy.html`: Privacy policy
- `terms-of-use.html`: Terms of use

## Helpful learning pages (SEO)

- `learn/flashcards.html`: Tips for making great flashcards
- `learn/pronunciation.html`: Pronunciation / text-to-speech (TTS)
- `learn/analytics.html`: Progress analytics
- `compare/anki.html`: Flippin vs Anki (high-level comparison)

## Contact

- Support email: `support@flippin.app`

## Notes

- The site supports **dark mode** automatically (matches the device setting).
- On iOS Safari, a Smart App Banner can appear at the top to **Open** or **View** the app.
- `sitemap.xml` and `robots.txt` help search engines discover pages.

### Agent discovery (automation)

- **`isitagentready-skills/`**: Reference copies of [isitagentready.com](https://isitagentready.com) SKILL.md files (requirements for link headers, API catalog, markdown negotiation, etc.).
- **`_headers`**: Cloudflare Pages applies RFC 8288 `Link` on `/` and `/index.html` (single comma-separated `Link` field). **`netlify.toml`** and **`vercel.json`** mirror the same headers for those platforms.
- **GitHub Pages**: The live site at `www.flippin.app` is currently served by **GitHub Pages**, which **does not** read `_headers`, `netlify.toml`, or `vercel.json`, and **cannot** set custom `Link` / `Vary` or run `functions/`. Automated checks that require HTTP `Link` or `Accept: text/markdown` negotiation on `/` will **not pass** until DNS/build targets a host that supports them (below).
- **`functions/index.ts`**: On **Cloudflare Pages** (with Functions enabled), `GET /` or `GET /index.html` with `Accept: text/markdown` returns `index.md` as `text/markdown` with `Vary: Accept`, `x-markdown-tokens`, and the same `Link` header. On any static host, clients can still fetch **`/index.md`** directly.
- **Cloudflare “Markdown for Agents”**: If the zone uses Cloudflare in front of the origin, enable *Markdown for Agents* (zone setting / AI Crawl Control) so the edge can serve markdown for **`Accept: text/markdown`** on HTML routes beyond what `functions/index.ts` handles.
- **`/.well-known/*`**: API catalog (RFC 9727 linkset), OpenAPI stub, health JSON, MCP server card (informational), and agent skills index.

#### Passing isitagentready-style checks (ranked)

1. **Best:** Deploy this folder with **Cloudflare Pages** so `_headers` and `functions/index.ts` apply; optionally enable Markdown for Agents on the zone.
2. **Good:** Deploy with **Netlify** or **Vercel** using the included **`netlify.toml`** / **`vercel.json`** (project root = `Website/`).
3. **Worse:** **GitHub Pages only** — no custom response headers or Functions; discovery checks that depend on HTTP headers for `/` will fail even though `index.html` already includes `<link rel="api-catalog">` and related relations for HTML clients.
4. **OAuth / protected-resource metadata:** This domain is a **static marketing site** with **no** OAuth authorization server or token-protected HTTP API. Per [RFC 8414](https://www.rfc-editor.org/rfc/rfc8414) / [isitagentready oauth-discovery skill](https://isitagentready.com/.well-known/agent-skills/oauth-discovery/SKILL.md), **do not** publish `/.well-known/openid-configuration`, `/.well-known/oauth-authorization-server`, or `/.well-known/oauth-protected-resource` with fabricated endpoints — that misleads agents. Add those files only when a real issuer and resource server exist.

