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
})();

