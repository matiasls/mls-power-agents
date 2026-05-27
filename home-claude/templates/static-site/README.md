# <PROJECT_NAME>

> Static site built with Astro.

## What it does

[One-liner about the site purpose]

## Quick start

```bash
make setup      # Install deps
make dev        # Start dev server on :4321
```

See [docs/EXECUTION.md](docs/EXECUTION.md) for full guide.

## Stack

- **Astro** (static site generator)
- **TypeScript**
- **TailwindCSS**
- **MDX** for content
- **Hosting**: Cloudflare Pages (or Vercel / Netlify)

## Structure

```
src/
├── pages/              # Routes (file-based)
│   ├── index.astro     # Home
│   └── ...
├── components/         # Astro / React components
├── layouts/            # Page layouts
├── content/            # MDX content (blog, docs)
└── styles/             # Global CSS / Tailwind config
public/                 # Static assets
astro.config.mjs
```

## Commands

| Command | What it does |
|---|---|
| `make setup` | Install deps |
| `make dev` | Start dev server (:4321) |
| `make build` | Production build |
| `make preview` | Preview production build locally |
| `make lint` | ESLint + Astro check |
| `make lighthouse` | Run Lighthouse against local build |

## Performance targets

- Lighthouse Performance ≥90 (mobile)
- Lighthouse Accessibility ≥95
- Lighthouse SEO ≥95
- First Contentful Paint < 1.5s

## License

[TBD]
