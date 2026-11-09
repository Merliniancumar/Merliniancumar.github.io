/* ============================================================
   FORJA — Gimnasio
   Interactividad del sitio
   ============================================================ */
(function () {
  "use strict";

  document.documentElement.classList.add("has-js");

  var prefersReduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  /* ---------- Header con fondo al scrollear ---------- */
  var header = document.querySelector(".site-header");
  var onScroll = function () {
    if (header) header.classList.toggle("is-scrolled", window.scrollY > 10);
  };
  onScroll();
  window.addEventListener("scroll", onScroll, { passive: true });

  /* ---------- Menú móvil ---------- */
  var navToggle = document.getElementById("navToggle");
  var navLinks = document.getElementById("navLinks");

  var closeNav = function () {
    if (!navLinks || !navToggle) return;
    navLinks.classList.remove("is-open");
    navToggle.setAttribute("aria-expanded", "false");
    navToggle.setAttribute("aria-label", "Abrir menú");
    document.body.classList.remove("nav-open");
  };

  if (navToggle && navLinks) {
    navToggle.addEventListener("click", function () {
      var isOpen = navLinks.classList.toggle("is-open");
      navToggle.setAttribute("aria-expanded", String(isOpen));
      navToggle.setAttribute("aria-label", isOpen ? "Cerrar menú" : "Abrir menú");
      document.body.classList.toggle("nav-open", isOpen);
    });

    navLinks.querySelectorAll("a").forEach(function (link) {
      link.addEventListener("click", closeNav);
    });

    document.addEventListener("keydown", function (event) {
      if (event.key === "Escape") closeNav();
    });

    window.addEventListener("resize", function () {
      if (window.innerWidth > 1000) closeNav();
    });
  }

  /* ---------- Aparición de elementos ---------- */
  var reveals = document.querySelectorAll(".reveal");

  if ("IntersectionObserver" in window && !prefersReduced) {
    var revealObserver = new IntersectionObserver(
      function (entries, observer) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            entry.target.classList.add("is-visible");
            observer.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.1, rootMargin: "0px 0px -40px 0px" }
    );

    reveals.forEach(function (el) {
      revealObserver.observe(el);
    });
  } else {
    reveals.forEach(function (el) {
      el.classList.add("is-visible");
    });
  }

  /* ---------- Contadores del hero ---------- */
  var counters = document.querySelectorAll("[data-count]");

  var runCounter = function (el) {
    var target = parseInt(el.getAttribute("data-count"), 10) || 0;

    if (prefersReduced) {
      el.textContent = target.toLocaleString("es-AR");
      return;
    }

    var duration = 1100;
    var start = performance.now();

    var tick = function (now) {
      var progress = Math.min((now - start) / duration, 1);
      var eased = 1 - Math.pow(1 - progress, 3);
      el.textContent = Math.round(target * eased).toLocaleString("es-AR");
      if (progress < 1) window.requestAnimationFrame(tick);
    };

    window.requestAnimationFrame(tick);
  };

  if (counters.length) {
    if ("IntersectionObserver" in window && !prefersReduced) {
      counters.forEach(function (el) {
        el.textContent = "0";
      });

      var counterObserver = new IntersectionObserver(
        function (entries, observer) {
          entries.forEach(function (entry) {
            if (entry.isIntersecting) {
              runCounter(entry.target);
              observer.unobserve(entry.target);
            }
          });
        },
        { threshold: 0.6 }
      );

      counters.forEach(function (el) {
        counterObserver.observe(el);
      });
    } else {
      counters.forEach(runCounter);
    }
  }

  /* ---------- Filtros de planes ---------- */
  var chips = Array.prototype.slice.call(document.querySelectorAll(".chip"));
  var planCards = Array.prototype.slice.call(document.querySelectorAll(".plan-card"));

  chips.forEach(function (chip) {
    chip.addEventListener("click", function () {
      var filter = chip.getAttribute("data-filter") || "all";

      chips.forEach(function (other) {
        var active = other === chip;
        other.classList.toggle("is-active", active);
        other.setAttribute("aria-pressed", String(active));
      });

      planCards.forEach(function (card) {
        var show = filter === "all" || card.getAttribute("data-cat") === filter;
        card.hidden = !show;
        if (show) card.classList.add("is-visible");
      });
    });
  });

  /* ---------- Buscador de socios ---------- */
  var searchInput = document.getElementById("memberSearch");
  var memberRows = Array.prototype.slice.call(
    document.querySelectorAll("#membersBody tr")
  );
  var emptyMessage = document.getElementById("membersEmpty");

  var normalize = function (text) {
    return text
      .toLowerCase()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "");
  };

  if (searchInput) {
    searchInput.addEventListener("input", function () {
      var query = normalize(searchInput.value.trim());
      var visible = 0;

      memberRows.forEach(function (row) {
        var match = !query || normalize(row.textContent).includes(query);
        row.hidden = !match;
        if (match) visible += 1;
      });

      if (emptyMessage) emptyMessage.hidden = visible !== 0;
    });
  }

  /* ---------- Preseleccionar plan desde las tarjetas ---------- */
  var planSelect = document.getElementById("planSelect");

  document.querySelectorAll("[data-plan]").forEach(function (button) {
    button.addEventListener("click", function () {
      if (!planSelect) return;
      var value = button.getAttribute("data-plan");
      var exists = Array.prototype.some.call(planSelect.options, function (option) {
        return option.value === value;
      });
      if (exists) planSelect.value = value;
    });
  });

  /* ---------- Formulario de contacto (demo) ---------- */
  var form = document.getElementById("joinForm");
  var success = document.getElementById("formSuccess");

  var escapeHtml = function (value) {
    return value.replace(/[&<>"']/g, function (character) {
      return {
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': "&quot;",
        "'": "&#39;",
      }[character];
    });
  };

  if (form) {
    form.addEventListener("submit", function (event) {
      event.preventDefault();

      var data = new FormData(form);
      var name = String(data.get("nombre") || "").trim();
      var plan = String(data.get("plan") || "").trim();

      if (!name || !plan) return;

      if (success) {
        var message = success.querySelector("p");
        var planText =
          plan === "Todavía no sé"
            ? "para recibir asesoramiento"
            : "para el plan <strong>" + escapeHtml(plan) + "</strong>";

        if (message) {
          message.innerHTML =
            "¡Listo, <strong>" +
            escapeHtml(name) +
            "</strong>! Recibimos tu solicitud " +
            planText +
            ". Te contactamos dentro de las 24 h.";
        }

        success.hidden = false;
        success.scrollIntoView({
          behavior: prefersReduced ? "auto" : "smooth",
          block: "nearest",
        });
      }

      form.reset();
    });
  }

  /* ---------- Link activo en la navegación ---------- */
  var sections = Array.prototype.slice.call(
    document.querySelectorAll("main section[id]")
  );
  var navAnchors = Array.prototype.slice.call(
    document.querySelectorAll(".nav-links a")
  );

  if ("IntersectionObserver" in window && sections.length) {
    var sectionObserver = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (entry) {
          if (!entry.isIntersecting) return;

          var id = entry.target.getAttribute("id");

          navAnchors.forEach(function (link) {
            link.classList.toggle(
              "is-active",
              link.getAttribute("href") === "#" + id
            );
          });
        });
      },
      { rootMargin: "-45% 0px -50% 0px", threshold: 0 }
    );

    sections.forEach(function (section) {
      sectionObserver.observe(section);
    });
  }
})();
