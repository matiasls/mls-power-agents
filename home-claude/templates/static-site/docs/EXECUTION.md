# Execution Guide (Static Site)

> How to build and deploy this static site.

## Overview

Astro static site. Built locally / in CI, deployed to CDN.

---

## Local Development

### Prerequisites
- Node 20+
- Make

### Setup

```bash
git clone <repo-url>
cd <project>
make setup
```

### Daily

```bash
make dev      # http://localhost:4321
```

### Commands

| Command | What it does |
|---|---|
| `make dev` | Dev server |
| `make build` | Production build to `dist/` |
| `make preview` | Serve `dist/` locally |
| `make lint` | Lint + Astro check |
| `make lighthouse` | Lighthouse audit on local build |

### Testing pre-deploy

Before any deploy, run:
```bash
make build && make preview
# Open in browser, click through
make lighthouse
```

Target: Performance ≥90, Accessibility ≥95, SEO ≥95.

---

## Staging

> ⚠️ **STATUS**: [Not yet configured | Configured]

Typically configured with branch deploys: every PR gets a preview URL.

### Provider
[Cloudflare Pages / Vercel / Netlify — TBD]

### How to access
Preview URLs auto-generated per PR.

---

## Production

### Deploy

Auto-deploys on push to `main` via provider's GitHub integration.

Manual deploy (if needed):
```bash
# Cloudflare Pages
wrangler pages deploy dist

# Vercel
vercel --prod

# Netlify
netlify deploy --prod --dir=dist
```

### Verify

- [ ] URL pública resuelve
- [ ] Lighthouse en prod cumple targets
- [ ] Sitemap.xml accesible
- [ ] robots.txt accesible
- [ ] OG tags muestran preview correcto en Twitter/LinkedIn
- [ ] Forms (si hay) funcionan end-to-end

### Rollback

#### Cloudflare Pages / Vercel / Netlify
Cualquiera permite promote previous deploy con un click en su dashboard.

---

## Environment Variables Reference

Variables prefijadas `PUBLIC_*` se exponen al cliente. **NUNCA secrets**.

| Variable | Local | Staging | Prod | Notas |
|---|---|---|---|---|
| `SITE_URL` | localhost | staging.x.com | x.com | Para canonical URLs y sitemap |
| `PUBLIC_PLAUSIBLE_DOMAIN` | — | staging.x.com | x.com | Analytics |

---

## SEO checklist

- [ ] `<title>` único por página
- [ ] `<meta description>` único por página
- [ ] OpenGraph tags (og:title, og:description, og:image, og:url)
- [ ] Twitter Card tags
- [ ] Canonical URLs
- [ ] sitemap.xml generado y referenciado en robots.txt
- [ ] robots.txt configurado
- [ ] hreflang si multi-idioma
- [ ] structured data (JSON-LD) donde aplique

## Accessibility checklist

- [ ] Lighthouse Accessibility ≥95
- [ ] Navegable solo con teclado
- [ ] Contraste de color WCAG AA
- [ ] Alt en todas las imágenes
- [ ] Headings jerárquicos (h1 → h2 → h3, sin saltos)
- [ ] Forms con labels

## Performance checklist

- [ ] Lighthouse Performance ≥90 (mobile)
- [ ] Imágenes optimizadas (WebP/AVIF)
- [ ] Lazy loading en imágenes below-the-fold
- [ ] Critical CSS inlined
- [ ] Fonts con `font-display: swap`
- [ ] Sin JS innecesario (Astro islands solo donde necesario)
