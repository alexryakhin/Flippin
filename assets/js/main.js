(() => {
  const nav = document.querySelector("[data-site-nav]");
  const toggle = document.querySelector("[data-nav-toggle]");

  const safeTrackEvent = (name, params = {}) => {
    if (typeof window.gtag === "function") {
      window.gtag("event", name, params);
    }
  };

  const setNavOpen = (open) => {
    if (!nav) return;
    nav.dataset.open = open ? "true" : "false";
    if (toggle) toggle.setAttribute("aria-expanded", open ? "true" : "false");
  };

  if (toggle && nav) {
    toggle.addEventListener("click", () => {
      const open = nav.dataset.open === "true";
      setNavOpen(!open);
    });

    document.addEventListener("click", (event) => {
      if (!nav.dataset.open || nav.dataset.open !== "true") return;
      if (nav.contains(event.target)) return;
      setNavOpen(false);
    });

    document.addEventListener("keydown", (event) => {
      if (event.key !== "Escape") return;
      setNavOpen(false);
    });
  }

  document.querySelectorAll("[data-track]").forEach((el) => {
    el.addEventListener("click", () => {
      const name = el.getAttribute("data-track");
      if (!name) return;
      safeTrackEvent(name, {
        placement: el.getAttribute("data-placement") || undefined,
        page_path: window.location.pathname,
      });
    });
  });

  document.querySelectorAll("[data-faq]").forEach((details) => {
    details.addEventListener("toggle", () => {
      if (!details.open) return;
      safeTrackEvent("faq_expand", {
        page_path: window.location.pathname,
      });
    });
  });

  const modelContext = navigator.modelContext;
  if (modelContext && typeof modelContext.registerTool === "function") {
    const appStoreURL =
      "https://apps.apple.com/us/app/flippin/id6748499528";

    modelContext.registerTool(
      {
        name: "open_app_store",
        title: "Open App Store",
        description:
          "Opens the Flippin listing on the Apple App Store in a new tab.",
        inputSchema: {
          type: "object",
          properties: {},
          additionalProperties: false,
        },
        async execute() {
          window.open(appStoreURL, "_blank", "noopener,noreferrer");
          return { opened: true, url: appStoreURL };
        },
        annotations: { readOnlyHint: true },
      },
    );

    modelContext.registerTool(
      {
        name: "open_support",
        title: "Open support page",
        description:
          "Navigates to the Flippin support page (FAQ and contact options).",
        inputSchema: {
          type: "object",
          properties: {},
          additionalProperties: false,
        },
        async execute() {
          window.location.assign("/support.html");
          return { path: "/support.html" };
        },
      },
    );

    modelContext.registerTool(
      {
        name: "open_languages",
        title: "Open languages page",
        description:
          "Navigates to the page listing supported learning languages.",
        inputSchema: {
          type: "object",
          properties: {},
          additionalProperties: false,
        },
        async execute() {
          window.location.assign("/languages.html");
          return { path: "/languages.html" };
        },
      },
    );
  }
})();

