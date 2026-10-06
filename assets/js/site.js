// Flippin website: reveal-on-scroll, header menus, language picker memory, analytics events and
// WebMCP tools for agents. Everything works without it; this only adds polish.
(function () {
  document.documentElement.classList.add("js");

  // Reveal on scroll (skipped entirely with Reduce Motion: the CSS shows everything).
  var items = document.querySelectorAll(".reveal");
  var reduce = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  if ("IntersectionObserver" in window && !reduce) {
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add("in");
          observer.unobserve(entry.target);
        }
      });
    }, { rootMargin: "0px 0px -8% 0px", threshold: 0.08 });
    items.forEach(function (item) { observer.observe(item); });
  } else {
    items.forEach(function (item) { item.classList.add("in"); });
  }

  // Header dropdowns (<details>): close on outside click, Escape, or following a link.
  var menus = document.querySelectorAll("details.menu, details.lang");
  document.addEventListener("click", function (event) {
    menus.forEach(function (menu) {
      if (menu.open && !menu.contains(event.target)) menu.open = false;
    });
  });
  document.addEventListener("keydown", function (event) {
    if (event.key !== "Escape") return;
    menus.forEach(function (menu) {
      if (menu.open) {
        menu.open = false;
        menu.querySelector("summary").focus();
      }
    });
  });
  menus.forEach(function (menu) {
    menu.querySelectorAll("a").forEach(function (link) {
      link.addEventListener("click", function () { menu.open = false; });
    });
  });

  // Language picker: remember the choice; the English pages' first-visit redirect follows it.
  document.querySelectorAll("details.lang a[hreflang]").forEach(function (link) {
    link.addEventListener("click", function () {
      try { localStorage.setItem("flippin.lang", link.getAttribute("hreflang").toLowerCase()); } catch (e) {}
    });
  });

  // Analytics events (Google Analytics, when it loaded).
  function track(name, params) {
    if (typeof window.gtag === "function") window.gtag("event", name, params || {});
  }
  document.querySelectorAll("[data-track]").forEach(function (el) {
    el.addEventListener("click", function () {
      track(el.getAttribute("data-track"), {
        placement: el.getAttribute("data-placement") || undefined,
        page_path: window.location.pathname
      });
    });
  });
  document.querySelectorAll("[data-faq]").forEach(function (details) {
    details.addEventListener("toggle", function () {
      if (details.open) track("faq_expand", { page_path: window.location.pathname });
    });
  });

  // WebMCP: let browser agents open the App Store listing, support and languages pages.
  var modelContext = navigator.modelContext;
  if (modelContext && typeof modelContext.registerTool === "function") {
    var appStore = (document.querySelector("[data-placement='nav']") || {}).href ||
      "https://apps.apple.com/us/app/flippin/id6748499528";
    var empty = { type: "object", properties: {}, additionalProperties: false };
    try {
      modelContext.registerTool({
        name: "open_app_store", title: "Open App Store",
        description: "Opens the Flippin listing on the Apple App Store in a new tab.",
        inputSchema: empty, annotations: { readOnlyHint: true },
        execute: function () {
          window.open(appStore, "_blank", "noopener,noreferrer");
          return Promise.resolve({ opened: true, url: appStore });
        }
      });
      modelContext.registerTool({
        name: "open_support", title: "Open support page",
        description: "Navigates to the Flippin support page (FAQ and contact options).",
        inputSchema: empty,
        execute: function () { window.location.assign("/support.html"); return Promise.resolve({ path: "/support.html" }); }
      });
      modelContext.registerTool({
        name: "open_languages", title: "Open languages page",
        description: "Navigates to the page listing supported learning languages.",
        inputSchema: empty,
        execute: function () { window.location.assign("/languages.html"); return Promise.resolve({ path: "/languages.html" }); }
      });
    } catch (e) {}
  }
})();
