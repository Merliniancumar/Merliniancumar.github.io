/* ==========================================================================
   MERLÍN IAN CUMAR VINCI — PORTFOLIO
   Interacciones: matriz, terminal, navegación, reveal, contadores y copiar
   ========================================================================== */

(() => {
  "use strict";

  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  const finePointer = window.matchMedia("(hover: hover) and (pointer: fine)").matches;

  /* ---------- Matrix rain ---------- */
  const initMatrix = () => {
    const canvas = document.getElementById("matrix");
    if (!canvas || reducedMotion) {
      if (canvas) canvas.style.display = "none";
      return;
    }

    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    const chars = "アカサタナハマヤラワ0123456789ABCDEF<>{}[]/\\=+*#$%&";
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    let width = 0;
    let height = 0;
    let columns = 0;
    let drops = [];
    let fontSize = 16;
    let frameId = 0;
    let lastTime = 0;
    let inView = true;

    const resize = () => {
      const rect = canvas.getBoundingClientRect();
      width = Math.max(1, rect.width);
      height = Math.max(1, rect.height);
      canvas.width = Math.floor(width * dpr);
      canvas.height = Math.floor(height * dpr);
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);

      fontSize = width < 640 ? 13 : 16;
      columns = Math.ceil(width / fontSize);
      drops = Array.from({ length: columns }, () => Math.random() * (-height / fontSize));

      ctx.fillStyle = "#040807";
      ctx.fillRect(0, 0, width, height);
    };

    const draw = (time) => {
      frameId = window.requestAnimationFrame(draw);

      if (!inView || document.hidden) return;
      if (time - lastTime < 44) return;
      lastTime = time;

      ctx.fillStyle = "rgba(4, 8, 7, 0.09)";
      ctx.fillRect(0, 0, width, height);
      ctx.font = `${fontSize}px "JetBrains Mono", monospace`;

      for (let i = 0; i < columns; i += 1) {
        const char = chars[Math.floor(Math.random() * chars.length)];
        const x = i * fontSize;
        const y = drops[i] * fontSize;

        if (y > 0) {
          const bright = Math.random() > 0.975;
          ctx.fillStyle = bright
            ? "rgba(230, 255, 245, 0.92)"
            : `rgba(0, 255, 156, ${0.22 + Math.random() * 0.48})`;
          ctx.fillText(char, x, y);
        }

        if (y > height && Math.random() > 0.975) drops[i] = 0;
        drops[i] += 1;
      }
    };

    resize();
    frameId = window.requestAnimationFrame(draw);

    if (document.fonts && document.fonts.ready) {
      document.fonts.ready.then(resize).catch(() => {});
    }

    if ("ResizeObserver" in window) {
      const resizeObserver = new ResizeObserver(() => resize());
      resizeObserver.observe(canvas);
    }

    window.addEventListener("resize", () => {
      window.clearTimeout(resize._timer);
      resize._timer = window.setTimeout(resize, 180);
    });

    if ("IntersectionObserver" in window) {
      const observer = new IntersectionObserver(
        (entries) => {
          inView = entries[0] ? entries[0].isIntersecting : true;
        },
        { threshold: 0 }
      );
      observer.observe(canvas);
    }

    document.addEventListener("visibilitychange", () => {
      if (!document.hidden) lastTime = 0;
    });
  };

  /* ---------- Terminal typing ---------- */
  const initTerminal = () => {
    const body = document.getElementById("terminalBody");
    if (!body || reducedMotion) return;

    const lines = Array.from(body.querySelectorAll(".term-line"));
    if (!lines.length) return;

    const contents = lines.map((line) => line.querySelector(".term-content"));
    const texts = lines.map((line) => line.dataset.text || "");
    contents.forEach((content) => {
      if (content) content.textContent = "";
    });

    const cursor = document.createElement("span");
    cursor.className = "cursor";
    cursor.setAttribute("aria-hidden", "true");

    let lineIndex = 0;
    let charIndex = 0;

    const type = () => {
      if (lineIndex >= lines.length) {
        const lastLine = document.createElement("div");
        lastLine.className = "term-line";
        lastLine.innerHTML = '<span class="prompt">$</span><span class="term-content"></span>';
        const lastContent = lastLine.querySelector(".term-content");
        lastContent.appendChild(cursor);
        body.appendChild(lastLine);
        return;
      }

      const line = lines[lineIndex];
      const content = contents[lineIndex];
      if (!content) return;

      if (cursor.parentNode !== content) content.appendChild(cursor);

      const text = texts[lineIndex];
      if (charIndex < text.length) {
        content.insertBefore(document.createTextNode(text[charIndex]), cursor);
        charIndex += 1;
        window.setTimeout(type, line.dataset.kind === "cmd" ? 40 : 15);
      } else {
        cursor.remove();
        lineIndex += 1;
        charIndex = 0;
        window.setTimeout(type, 200);
      }
    };

    window.setTimeout(type, 650);
  };

  /* ---------- Header, progress & active nav ---------- */
  const initNavigation = () => {
    const header = document.getElementById("header");
    const progress = document.getElementById("scrollProgress");
    const nav = document.getElementById("nav");
    const toggle = document.getElementById("navToggle");
    const links = Array.from(document.querySelectorAll(".nav-link"));
    const sections = links
      .map((link) => document.querySelector(link.getAttribute("href")))
      .filter(Boolean);

    const closeMenu = () => {
      if (!nav || !toggle) return;
      nav.classList.remove("is-open");
      toggle.setAttribute("aria-expanded", "false");
      toggle.setAttribute("aria-label", "Abrir menú");
      document.body.classList.remove("nav-open");
    };

    if (toggle && nav) {
      toggle.addEventListener("click", () => {
        const isOpen = nav.classList.toggle("is-open");
        toggle.setAttribute("aria-expanded", String(isOpen));
        toggle.setAttribute("aria-label", isOpen ? "Cerrar menú" : "Abrir menú");
        document.body.classList.toggle("nav-open", isOpen);
      });

      nav.querySelectorAll("a").forEach((link) => {
        link.addEventListener("click", closeMenu);
      });

      document.addEventListener("keydown", (event) => {
        if (event.key === "Escape") closeMenu();
      });

      window.addEventListener("resize", () => {
        if (window.innerWidth > 980) closeMenu();
      });
    }

    let ticking = false;

    const update = () => {
      ticking = false;
      const scrollY = window.scrollY || window.pageYOffset;
      const maxScroll = document.documentElement.scrollHeight - window.innerHeight;

      if (header) header.classList.toggle("is-scrolled", scrollY > 18);
      if (progress) {
        const percent = maxScroll > 0 ? (scrollY / maxScroll) * 100 : 0;
        progress.style.width = `${Math.min(100, Math.max(0, percent))}%`;
      }

      const marker = scrollY + 150;
      let current = null;
      sections.forEach((section) => {
        const top = section.getBoundingClientRect().top + scrollY;
        if (top <= marker) current = section;
      });

      links.forEach((link) => {
        const active = current && link.getAttribute("href") === `#${current.id}`;
        link.classList.toggle("is-active", Boolean(active));
      });
    };

    const onScroll = () => {
      if (!ticking) {
        ticking = true;
        window.requestAnimationFrame(update);
      }
    };

    window.addEventListener("scroll", onScroll, { passive: true });
    window.addEventListener("resize", onScroll);
    update();
  };

  /* ---------- Reveal on scroll ---------- */
  const initReveal = () => {
    const elements = Array.from(document.querySelectorAll("[data-reveal]"));
    if (!elements.length) return;

    if (reducedMotion || !("IntersectionObserver" in window)) {
      elements.forEach((element) => element.classList.add("is-visible"));
      return;
    }

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (!entry.isIntersecting) return;
          entry.target.classList.add("is-visible");
          observer.unobserve(entry.target);
        });
      },
      { threshold: 0.12, rootMargin: "0px 0px -8% 0px" }
    );

    elements.forEach((element) => observer.observe(element));
  };

  /* ---------- Cursor glow ---------- */
  const initCursorGlow = () => {
    const glow = document.getElementById("cursorGlow");
    if (!glow || reducedMotion || !finePointer) return;

    let targetX = window.innerWidth / 2;
    let targetY = window.innerHeight / 2;
    let x = targetX;
    let y = targetY;

    window.addEventListener(
      "pointermove",
      (event) => {
        targetX = event.clientX;
        targetY = event.clientY;
        glow.classList.add("is-active");
      },
      { passive: true }
    );

    document.addEventListener("pointerleave", () => glow.classList.remove("is-active"));

    const loop = () => {
      x += (targetX - x) * 0.12;
      y += (targetY - y) * 0.12;
      glow.style.transform = `translate3d(${x}px, ${y}px, 0) translate(-50%, -50%)`;
      window.requestAnimationFrame(loop);
    };

    loop();
  };

  /* ---------- Card glow follow ---------- */
  const initCardGlow = () => {
    if (!finePointer) return;
    document.querySelectorAll(".glow-card").forEach((card) => {
      card.addEventListener(
        "pointermove",
        (event) => {
          const rect = card.getBoundingClientRect();
          card.style.setProperty("--mx", `${event.clientX - rect.left}px`);
          card.style.setProperty("--my", `${event.clientY - rect.top}px`);
        },
        { passive: true }
      );
    });
  };

  /* ---------- Animated counters ---------- */
  const initCounters = () => {
    const counters = Array.from(document.querySelectorAll("[data-count]"));
    if (!counters.length) return;

    const animate = (element) => {
      const target = Number(element.dataset.count) || 0;
      if (reducedMotion) {
        element.textContent = String(target);
        return;
      }

      const duration = 1200;
      let start = null;

      const step = (time) => {
        if (start === null) start = time;
        const progress = Math.min((time - start) / duration, 1);
        const eased = 1 - Math.pow(1 - progress, 3);
        element.textContent = String(Math.round(target * eased));
        if (progress < 1) window.requestAnimationFrame(step);
      };

      element.textContent = "0";
      window.requestAnimationFrame(step);
    };

    if (!("IntersectionObserver" in window)) {
      counters.forEach(animate);
      return;
    }

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (!entry.isIntersecting) return;
          animate(entry.target);
          observer.unobserve(entry.target);
        });
      },
      { threshold: 0.7 }
    );

    counters.forEach((counter) => observer.observe(counter));
  };

  /* ---------- Copy email & toast ---------- */
  const initCopy = () => {
    const button = document.querySelector("[data-copy]");
    const toast = document.getElementById("toast");
    if (!button) return;

    let toastTimer = 0;

    const showToast = (message) => {
      if (!toast) return;
      toast.textContent = message;
      toast.classList.add("is-visible");
      window.clearTimeout(toastTimer);
      toastTimer = window.setTimeout(() => toast.classList.remove("is-visible"), 2400);
    };

    const fallbackCopy = (text) => {
      const area = document.createElement("textarea");
      area.value = text;
      area.setAttribute("readonly", "");
      area.style.position = "fixed";
      area.style.opacity = "0";
      document.body.appendChild(area);
      area.select();
      let copied = false;
      try {
        copied = document.execCommand("copy");
      } catch (error) {
        copied = false;
      }
      area.remove();
      return copied;
    };

    button.addEventListener("click", async () => {
      const text = button.dataset.copy || "";
      let copied = false;

      if (navigator.clipboard && window.isSecureContext) {
        try {
          await navigator.clipboard.writeText(text);
          copied = true;
        } catch (error) {
          copied = false;
        }
      }

      if (!copied) copied = fallbackCopy(text);
      showToast(copied ? "Email copiado ✓" : "No se pudo copiar. Usá el enlace.");
    });
  };

  /* ---------- Init ---------- */
  const init = () => {
    initMatrix();
    initTerminal();
    initNavigation();
    initReveal();
    initCursorGlow();
    initCardGlow();
    initCounters();
    initCopy();
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init, { once: true });
  } else {
    init();
  }
})();
