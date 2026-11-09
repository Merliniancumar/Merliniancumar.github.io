# Portfolio — Merlín Ian Cumar Vinci

Sitio personal de **Merlín Ian Cumar Vinci**, Full Stack Developer en formación.
Temática *Matrix*, animaciones sutiles y diseño responsive, construido con HTML,
CSS y JavaScript sin frameworks ni build.

**Sitio online:** <https://merliniancumar.github.io>

## Secciones

- **Inicio:** presentación, terminal animada y lluvia de caracteres.
- **Sobre mí:** perfil, enfoque y ficha en formato código.
- **Stack:** frontend, backend, datos y herramientas.
- **Proyectos:** FORJA, sitio para un gimnasio construido a partir de una base
  de datos PostgreSQL. Incluye demo online en `/forja-gym/`.
- **Formación:** tecnicatura, proyecto integrador y aprendizaje continuo.
- **Contacto:** email, LinkedIn y GitHub.

## Estructura

```text
.
├── index.html              Página principal
├── 404.html                Página de error personalizada
├── css/
│   └── styles.css          Diseño, animaciones y responsive
├── js/
│   └── app.js              Matrix, terminal, navegación y contadores
├── assets/
│   ├── favicon.svg
│   ├── forja-preview.webp  Captura del proyecto FORJA
│   ├── og-image.jpg        Imagen para redes sociales
│   └── profile-banner.jpg  Banner del perfil de GitHub
├── forja-gym/              Demo estática del proyecto FORJA
├── robots.txt
└── sitemap.xml
```

## Cómo verlo localmente

```bash
python3 -m http.server 8000
```

Después abrir <http://localhost:8000>.

## Detalles técnicos

- HTML semántico, CSS moderno y JavaScript vanilla.
- Animaciones con `IntersectionObserver`, `requestAnimationFrame` y Canvas.
- Respeta `prefers-reduced-motion`.
- Sin dependencias de build: se publica directo desde la rama `main` con
  GitHub Pages.

## Proyecto incluido

**FORJA — Gimnasio** · [Código](https://github.com/Merliniancumar/forja-gym) ·
[Demo](https://merliniancumar.github.io/forja-gym/)

Sitio temático para un gimnasio basado en el modelo de datos de `GYM.sql`:
planes, clases, profesores, socios y pagos.

---

Diseñado y desarrollado por Merlín Ian Cumar Vinci · 2026
