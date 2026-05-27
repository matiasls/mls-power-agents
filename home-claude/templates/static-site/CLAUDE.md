# CLAUDE.md — <PROJECT_NAME> (Static Site)

> Static site / marketing page / landing. Extends `~/.claude/CLAUDE.md` global.

## Project context

- **Name**: <PROJECT_NAME>
- **Type**: Static site (marketing, landing, docs site)
- **Nature**: [Personal / Marketing / Commercial]


## Project profile (CRITICAL — los agentes modulan su rigor según esto)

```yaml
project_profile:
  type: personal | mvp | commercial               # default si no se especifica: commercial
  stakeholders: solo | small_team | external_parties
  timeline: flexible | soft_deadline | hard_external
  regulatory: none | medium | high
  data_sensitivity: none | personal | sensitive | regulated
  primary_goal: validate_problem | build_solution | both
```

**Llená esto al inicio del proyecto.** Define cuánta fricción aplican los agentes. Ver `~/.claude/CLAUDE.md` sección 1.1 para detalles.

## When to use this template

Para:
- Landing pages
- Sitios de marketing
- Documentación pública
- Blogs personales
- Sitios institucionales

**NO usar para**:
- Apps con auth y CRUD → `web-fullstack`
- Sitios con dashboards complejos → `web-fullstack`

## Stack

- **Astro** (default, mejor para sitios mayormente estáticos con interactividad puntual)
- Alternativa: **Next.js static export** si el equipo ya conoce Next
- Alternativa: **Hugo** si es solo contenido (blog/docs) sin componentes interactivos

- TypeScript
- TailwindCSS
- MDX para contenido (si aplica)

## Stack overrides (vs global default)

- Sin backend (es estático). El "backend" para forms es un servicio externo (Formspree, Web3Forms, o un endpoint propio si ya tenés backend)
- Hosting: Cloudflare Pages / Vercel / Netlify (todos free tier suficiente)

## Fases que SÍ aplican

- 0 Discovery: para qué es el sitio, audiencia
- 1 Problem Definition: contenido y secciones
- 2 Product Decisions: scope (qué páginas entran)
- 3A UX/UI: diseño visual (importantísimo aquí)
- 4 DevOps: build + deploy + CDN
- 6 Release: contenido publicado

## Fases que NO aplican (o son mínimas)

- 3B Architecture: trivial (no hay backend)
- 5 Development: minimal coding

## Reglas duras específicas

1. **Performance**: Lighthouse score ≥90 en mobile.
2. **SEO**: meta tags, OG tags, sitemap.xml, robots.txt obligatorios.
3. **Accesibilidad**: WCAG AA, no negociable.
4. **Privacy-first**: sin analytics que rastreen (o explícitamente declarar GA con consentimiento cookie).
5. **Sin JavaScript innecesario**: Astro permite islands; usá solo donde necesario.
6. **Imágenes optimizadas**: WebP/AVIF + responsive srcset + lazy loading.

## References

- Global setup: `~/.claude/CLAUDE.md`
- UI agent: el UI Designer
- UX agent: el UX Designer
