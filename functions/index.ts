type PagesFunction = (context: {
  request: Request;
  next: () => Promise<Response>;
}) => Response | Promise<Response>;

/**
 * Single RFC 8288 `Link` field value (comma-separated link-values). Keep in sync with `_headers`
 * and `netlify.toml` / `vercel.json`.
 */
const HOME_LINK_VALUE =
  '</.well-known/api-catalog>; rel="api-catalog", ' +
  '</.well-known/openapi.json>; rel="service-desc", ' +
  '</features.html>; rel="service-doc", ' +
  '</.well-known/health.json>; rel="status", ' +
  '</.well-known/agent-skills/index.json>; rel="describedby"';

/**
 * Serves `index.md` when clients request `/` or `/index.html` with
 * `Accept: text/markdown` (Markdown for Agents–friendly behavior on Cloudflare Pages).
 * Requires deploying the `Website` folder with Pages Functions enabled.
 */
export const onRequestGet: PagesFunction = async ({ request, next }) => {
  const url = new URL(request.url);
  if (url.pathname !== "/" && url.pathname !== "/index.html") {
    return next();
  }

  const accept = request.headers.get("Accept") ?? "";
  if (!accept.toLowerCase().includes("text/markdown")) {
    return next();
  }

  const mdURL = new URL("/index.md", url.origin);
  const mdRequest = new Request(mdURL.toString(), {
    method: "GET",
    headers: request.headers,
  });

  const mdResponse = await fetch(mdRequest);
  if (!mdResponse.ok) {
    return next();
  }

  const body = await mdResponse.text();
  const headers = new Headers();
  headers.set("Content-Type", "text/markdown; charset=utf-8");
  headers.set("Vary", "Accept");
  headers.set("Link", HOME_LINK_VALUE);
  headers.set(
    "x-markdown-tokens",
    String(Math.max(1, Math.ceil(new TextEncoder().encode(body).length / 4))),
  );

  return new Response(body, { status: 200, headers });
};
