---
name: mockup-generation
description: Generate navigable HTML+Tailwind mockups of an app's main screens before the Frontend Developer implements the real frontend. Use by the UI Designer in Fase 3A. Auto-invoke when user says "mockup", "mock", "wireframe HTML", "ver pantallas antes de codear", "/mockup".
---

# Mockup Generation

Skill operativo del UI Designer para generar mockups visuales navegables antes de la fase de development. La filosofía: **ver la app antes de codearla cuesta minutos; cambiarla después de codearla cuesta horas**.

## Cuándo aplicar este skill

- En Fase 3A, después de que el UX Designer cerró `03-ux-spec.md` y vos cerraste `03-ui-spec.md`.
- Antes de cerrar Gate 3A.
- Cuando el usuario pide "ver" la app o "un mockup".

## Cuándo NO aplicar

- Proyectos sin UI (servicios ML puros, APIs sin frontend).
- Cuando hay un Figma/Sketch existente que el usuario considera la fuente de verdad.
- Cuando el `ui-spec` está incompleto (volver a hacer UI spec antes).

## Templates de recursos

Los templates HTML/CSS/JS viven en `resources/` junto a este SKILL.md. Leer el archivo de recurso cuando lo necesites en el paso correspondiente:

| Recurso | Qué es | Se usa en |
|---|---|---|
| `resources/tokens.css` | Template de CSS variables del design system | Paso 4 |
| `resources/screen-shell.html` | Esqueleto base de cada pantalla (Tailwind CDN + tokens + banner MOCKUP) | Paso 5 |
| `resources/index.html` | Template del índice navegable | Paso 7 |
| `resources/mocks-readme.md` | Template del `mocks/README.md` | Paso 8 |
| `resources/state.js` | Estado del prototipo en localStorage (modo interactivo) | Modo interactivo |
| `resources/interactive-screen.html` | Ejemplo completo de pantalla interactiva con Alpine.js | Modo interactivo |
| `resources/feedback-template.md` | Template de `mocks/feedback.md` | Iteración |

## Procedimiento

### Paso 0: Decidir modo (estático vs interactivo)

Antes de empezar, decidir con el usuario:

- **Modo estático**: solo navegación entre pantallas, datos hard-coded en HTML.
- **Modo interactivo**: estado JS, persistencia en localStorage, forms que "guardan", listas que se actualizan.

**Activar modo interactivo si**:
- El proyecto tiene flujos de creación/edición/borrado significativos (CRUD-heavy)
- El usuario quiere validar interacciones, no solo layout
- Hay forms con validación, condicionalidad, o cálculos en vivo
- El UX spec define estados que dependen de acciones del usuario (ej: agregar un item y ver cómo cambia un total)

**Quedarse en modo estático si**:
- El proyecto es mayormente lectura (dashboards, reports)
- Las interacciones son triviales (un botón = una página nueva)
- El usuario solo quiere ver el look-and-feel

¿En duda? Preguntar. Esta decisión se documenta en `mocks/README.md`.

### Paso 1: Pre-condiciones

Verificá que existan:
- `docs/context/03-ux-spec.md` con flows y pantallas listadas
- `docs/context/03-ui-spec.md` con tokens definidos (colors, typography, spacing)

Si falta alguno, frenás y pedís que se completen primero.

### Paso 2: Identificar pantallas a mockear

Del UX spec, listar las pantallas principales. Priorizar:

1. **Pantallas de los happy paths** de los flows principales (no edge cases todavía)
2. **5-10 pantallas máximo en primera iteración**
3. Si el spec tiene >15 pantallas, elegir las del **flujo crítico** y las que tienen componentes únicos

NO mockees todavía:
- Edge cases visuales menores (eso después)
- Variantes de la misma pantalla con micro-diferencias
- Loading/empty/error states de cada pantalla (esos van como mocks separados de las pantallas críticas, no de todas)

### Paso 3: Crear estructura

```
mocks/
├── README.md                    # Cómo abrir, qué representa cada uno
├── index.html                   # Índice navegable con links a todos los mocks
├── tokens.css                   # CSS variables con los tokens del design system
├── components/                  # Componentes reutilizables (snippets)
│   ├── button.html
│   ├── card.html
│   └── ...
└── screens/                     # Pantallas
    ├── login.html
    ├── dashboard.html
    ├── states/                  # Estados específicos
    │   ├── dashboard-empty.html
    │   ├── dashboard-loading.html
    │   └── dashboard-error.html
    └── ...
```

### Paso 4: Generar `tokens.css` con CSS variables

Usar `resources/tokens.css` como base, completando los valores reales del `03-ui-spec.md` (ramps de primary/neutral, semantic colors, typography, spacing en 8-point grid, radius, dark mode si aplica).

### Paso 5: Generar cada pantalla

Cada `screens/*.html` sigue el esqueleto de `resources/screen-shell.html`: Tailwind via CDN (sin build step), link a `../tokens.css`, config de Tailwind mapeando colores a las CSS variables, y el banner MOCKUP con link de vuelta al índice. Reemplazar los placeholders `<Nombre pantalla>` y `<Project>`.

### Paso 6: Datos de ejemplo realistas

NO usés Lorem Ipsum. Usá datos plausibles del dominio:

- Para una app de gastos: nombres reales ("Juan", "María"), montos plausibles ($1,250, $4,800), monedas correctas
- Para un dashboard de productores: nombres de productores reales del dominio, CUITs con formato válido (aunque inventados)
- Para fechas: usá fechas relativas ("Hace 2 días") o cercanas a la fecha actual

Los datos plausibles hacen que el usuario VEA cómo se siente la app real, no un wireframe genérico.

### Paso 7: Index navegable

Generar `mocks/index.html` a partir de `resources/index.html`, con secciones: pantallas principales (happy path), estados, y componentes reutilizables. Ajustar los links a las pantallas reales del proyecto.

### Paso 8: README de los mocks

Generar `mocks/README.md` a partir de `resources/mocks-readme.md`. Debe cubrir: cómo abrirlos, qué SON, qué NO son, pantallas incluidas, estados ilustrados, limitaciones conocidas y cómo iterar.

## Reglas duras del mockup

1. **Banner "MOCKUP" visible**: en cada pantalla, queda explícito que NO es producción.
2. **Sin build step**: Tailwind via CDN. El usuario puede abrir el archivo y listo, sin npm.
3. **CSS variables, no hardcoded**: los colores y spacing vienen de `tokens.css`. Si cambia el design system, cambia un archivo, propagan todos.
4. **Datos plausibles, no Lorem Ipsum**: ya cubierto.
5. **Banner de "Volver al índice" en cada pantalla**: permite navegar sin perderse.
6. **Mobile primero si la app es mobile-first**: empezá los mocks en 375px.
7. **Accesibilidad mínima**: alt en imágenes, labels en inputs, contraste OK (aunque sea mock).

## Anti-patterns a evitar

- **Mockear todas las pantallas**: empezá con 5-10. Las menos críticas pueden esperar a iteración 2.
- **Pixel-perfect**: estos son mocks, no specs visuales finales. el Frontend Developer puede hacer ajustes finos.
- **JavaScript de producción**: NO uses libs de framework (React, Vue), NO conectes con APIs reales, NO uses build steps. **El JS de simulación SÍ está permitido** (ver "Modo interactivo").
- **Reinventar componentes en cada pantalla**: usá los snippets de `components/`.
- **Olvidar dark mode si está en el ui-spec**: si el UI Designer dijo dark mode v1, los mocks tienen dark mode.

## Modo interactivo (desde Sesión 7)

Aplica solo si en el Paso 0 se decidió modo interactivo (los criterios de decisión están ahí).

### Reglas duras del modo interactivo

1. **NO uses frameworks** (React, Vue, Angular, Svelte). HTML + JS vanilla + Tailwind.
2. **NO conectes a APIs reales**. Todo el estado vive en `localStorage` o variables JS en memoria.
3. **NO repliques lógica de negocio del backend**. Validaciones básicas sí (campos vacíos, formato email); cálculos complejos NO (eso lo hace el Backend Developer en backend real).
4. **SÍ persistí en localStorage entre páginas** para que el usuario pueda agregar un gasto en una pantalla y verlo en otra.
5. **SÍ usá Alpine.js o petite-vue via CDN** si necesitás reactividad ligera (ambos <10KB, sin build).
6. **Botón "Reset prototipo"** visible en cada pantalla: limpia el localStorage y vuelve al estado inicial. Imprescindible para iterar y demo.

### Stack permitido del modo interactivo

| Tool | Uso | CDN |
|---|---|---|
| Tailwind | Styling | `https://cdn.tailwindcss.com` |
| Alpine.js | Reactividad ligera (preferido) | `https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js` |
| petite-vue | Alternativa a Alpine, sintaxis Vue-like | `https://unpkg.com/petite-vue` |
| Lucide icons | Iconos | `https://unpkg.com/lucide@latest` |
| HTML5 `<dialog>` | Modales nativos | nativo |
| `localStorage` | Persistencia | nativo |

**NO permitido**: React, Vue completo, Svelte, jQuery, webpack/vite/parcel, server-side rendering, llamados a APIs externas reales.

### Estructura adicional en modo interactivo

Agregar a `mocks/` la carpeta `prototype/` con: `state.js` (estado global, wrappers de localStorage — partir de `resources/state.js` y adaptar las operaciones de dominio), `seed-data.js` (datos iniciales realistas) y `reset.js` (botón reset).

Para las pantallas interactivas, usar `resources/interactive-screen.html` como ejemplo completo (lista CRUD con Alpine.js, total reactivo, banner PROTOTIPO con botón reset).

### Iteración del prototipo

Una vez generado:
1. El usuario abre `mocks/index.html`, hace clic, prueba flujos.
2. Anota qué funciona y qué no en `mocks/feedback.md` (crear desde `resources/feedback-template.md` al primer feedback).
3. Vos (el UI Designer) iterás los archivos afectados.
4. **NUNCA dejes el prototipo en estado "roto"**: cada commit del mock debe estar funcionando.

### Tradeoffs explícitos a comunicar al usuario

Cuando entregás el prototipo interactivo, comunicar explícitamente:

> "El prototipo persiste en localStorage de TU navegador. Si limpiás cookies o usás incógnito, perdés los datos. Esto es esperado — es un prototipo, no tu app. El backend real lo va a implementar el Backend Developer en Fase 5."

> "Validaciones complejas, autenticación real, cálculos de negocio: NO están en el prototipo. Solo lo que el usuario puede VER y SENTIR está acá. La lógica de verdad la implementa el Backend Developer / Frontend Developer después."

> "Si encontrás un bug visual o de flujo, decímelo. Si encontrás algo que no funciona como debería: probablemente esa lógica no está mockeada y se va a implementar real en Fase 5."

### Cuándo el prototipo está listo

- [ ] Los flujos críticos del UX spec son ejercitables end-to-end
- [ ] El estado persiste entre pantallas (ej: agregar item en pantalla A → aparece en pantalla B)
- [ ] El botón "Reset" funciona y limpia el estado
- [ ] No hay errores de consola al cargar ni al interactuar
- [ ] El usuario pudo completar al menos 1 flujo crítico sin tu ayuda
- [ ] El feedback del usuario fue capturado en `mocks/feedback.md`

## Checklist antes de cerrar Fase 3A

Antes de cerrar Fase 3A, vos misma revisás:

- [ ] Las pantallas se abren sin errores de consola
- [ ] El index linkea correctamente a cada una
- [ ] Los colores cumplen contraste WCAG AA (chequear con DevTools)
- [ ] Las pantallas son responsive (testear en 375px y 1280px)
- [ ] Los estados loading/empty/error existen para las pantallas críticas
- [ ] El banner MOCKUP está visible
- [ ] El usuario puede entender qué hace la app abriendo el index

Si pasa todo: invitás al usuario a abrir `mocks/index.html` y darte feedback.

## Devil's Advocate sobre mocks

Una vez generados, Devil's Advocate los puede atacar concretamente:

- "La CTA principal compite visualmente con la navegación"
- "El estado error es indistinguible del empty"
- "La pantalla critica X tiene demasiada densidad de info"
- "No hay affordance visual para la acción Y"

Esto es **mucho más valioso** que atacar UX en texto, porque los problemas visuales son visibles.

## Output esperado

- `mocks/` directorio completo, navegable abriendo `index.html`
- Mención en `docs/context/03-ui-spec.md` agregando sección "## Mocks" con link
- Mención en `docs/context/STATE.md` que los mocks están generados y disponibles
