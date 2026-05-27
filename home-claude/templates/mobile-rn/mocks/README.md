# Mocks

> Placeholder. el UI Designer genera el contenido real en Fase 3A.

## Qué va a haber acá

Cuando el UI Designer ejecute el skill `mockup-generation` en Fase 3A, va a poblar este directorio con:

```
mocks/
├── index.html         # Punto de entrada navegable
├── tokens.css         # CSS variables del design system
├── components/        # Componentes reutilizables (snippets HTML)
└── screens/           # Pantallas mockeadas
    └── states/        # Estados loading/empty/error
```

## Cómo abrir los mocks (una vez generados)

```bash
open mocks/index.html       # macOS
xdg-open mocks/index.html   # Linux
```

No requiere servidor ni build step. Tailwind se carga via CDN.

## Cuándo se generan

- Después de cerrar `docs/context/03-ux-spec.md` (el UX Designer) y `03-ui-spec.md` (el UI Designer)
- Antes de cerrar Gate 3A
- Son requisito para que el Frontend Developer empiece implementación real en Fase 5
