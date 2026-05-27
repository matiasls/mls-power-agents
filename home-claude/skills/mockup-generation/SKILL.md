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

## Procedimiento

### Paso 0: Decidir modo (estático vs interactivo)

Antes de empezar, decidir con el usuario:

- **Modo estático**: solo navegación entre pantallas, datos hard-coded. Default para apps mayormente lectura (dashboards, reports).
- **Modo interactivo**: persistencia en localStorage, forms funcionales, reactividad. Default para apps CRUD-heavy o donde validar interacciones importa.

Si el usuario no especifica:
- ¿La app tiene flujos significativos de crear/editar/eliminar? → interactivo.
- ¿Las interacciones son triviales (clic → próxima pantalla)? → estático.
- ¿En duda? Preguntar.

Esta decisión se documenta en `mocks/README.md`.

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
    ├── productor-detail.html
    ├── states/                  # Estados específicos
    │   ├── dashboard-empty.html
    │   ├── dashboard-loading.html
    │   └── dashboard-error.html
    └── ...
```

### Paso 4: Generar `tokens.css` con CSS variables

```css
/* tokens.css — generated from 03-ui-spec.md */
:root {
  /* Color: Primary */
  --primary-50: #...;
  --primary-100: #...;
  /* ... toda la ramp */
  
  /* Color: Neutral */
  --neutral-0: #ffffff;
  /* ... */
  
  /* Color: Semantic */
  --success: #...;
  --warning: #...;
  --error: #...;
  --info: #...;
  
  /* Typography */
  --font-sans: 'Inter', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
  
  /* Spacing (8-point grid) */
  --space-1: 4px;
  --space-2: 8px;
  /* ... */
  
  /* Radius */
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
}

/* Dark mode (si aplica) */
[data-theme="dark"] {
  --neutral-0: #0a0a0a;
  /* ... */
}
```

### Paso 5: Template base por pantalla

Cada `screens/*.html` sigue este esqueleto:

```html
<!DOCTYPE html>
<html lang="es" data-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><Nombre pantalla> · <Project></title>
  
  <!-- Tailwind via CDN: sin build step -->
  <script src="https://cdn.tailwindcss.com"></script>
  
  <!-- Tokens del design system -->
  <link rel="stylesheet" href="../tokens.css">
  
  <!-- Configuración de Tailwind para que use los tokens -->
  <script>
    tailwind.config = {
      theme: {
        extend: {
          colors: {
            primary: {
              50: 'var(--primary-50)',
              /* ... */
              600: 'var(--primary-600)',
              700: 'var(--primary-700)',
            },
            neutral: { /* ... */ },
            success: 'var(--success)',
            error: 'var(--error)',
          },
          fontFamily: {
            sans: ['Inter', 'system-ui', 'sans-serif'],
          },
        }
      }
    }
  </script>
  
  <style>
    body { font-family: var(--font-sans); }
  </style>
</head>
<body class="bg-neutral-50 text-neutral-900 min-h-screen">
  
  <!-- Banner identificando que es mockup, NO producción -->
  <div class="bg-amber-100 border-b border-amber-300 px-4 py-2 text-sm text-amber-900">
    <strong>MOCKUP</strong> · Pantalla: <code><Nombre pantalla></code> · 
    <a href="../index.html" class="underline">Volver al índice</a>
  </div>
  
  <!-- Contenido real de la pantalla acá -->
  <main class="max-w-5xl mx-auto p-6">
    <!-- ... -->
  </main>
  
</body>
</html>
```

### Paso 6: Datos de ejemplo realistas

NO usés Lorem Ipsum. Usá datos plausibles del dominio:

- Para una app de gastos: nombres reales ("Juan", "María"), montos plausibles ($1,250, $4,800), monedas correctas
- Para un dashboard de productores: nombres de productores reales del dominio, CUITs con formato válido (aunque inventados)
- Para fechas: usá fechas relativas ("Hace 2 días") o cercanas a la fecha actual

Los datos plausibles hacen que el usuario VEA cómo se siente la app real, no un wireframe genérico.

### Paso 7: Index navegable

`mocks/index.html`:

```html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Mockups · <Project></title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-neutral-50 p-8">
  <div class="max-w-4xl mx-auto">
    <h1 class="text-3xl font-bold mb-2">Mockups: <Project></h1>
    <p class="text-neutral-600 mb-8">
      Generado por el UI Designer · Fase 3A · <fecha>
    </p>
    
    <section class="mb-12">
      <h2 class="text-xl font-semibold mb-4">Pantallas principales (happy path)</h2>
      <ul class="space-y-2">
        <li><a href="screens/login.html" class="text-primary-600 underline">Login</a> — punto de entrada</li>
        <li><a href="screens/dashboard.html" class="text-primary-600 underline">Dashboard</a> — vista principal post-login</li>
        <li><a href="screens/productor-detail.html" class="text-primary-600 underline">Productor detail</a> — ficha con score</li>
        <!-- ... -->
      </ul>
    </section>
    
    <section class="mb-12">
      <h2 class="text-xl font-semibold mb-4">Estados</h2>
      <ul class="space-y-2">
        <li><a href="screens/states/dashboard-empty.html">Dashboard sin datos</a></li>
        <li><a href="screens/states/dashboard-loading.html">Dashboard cargando</a></li>
        <li><a href="screens/states/dashboard-error.html">Dashboard con error</a></li>
      </ul>
    </section>
    
    <section>
      <h2 class="text-xl font-semibold mb-4">Componentes reutilizables</h2>
      <p class="text-sm text-neutral-600 mb-2">Para referencia del Frontend Developer al implementar:</p>
      <ul class="space-y-2">
        <li><a href="components/button.html">Button (todas las variantes)</a></li>
        <li><a href="components/card.html">Card</a></li>
      </ul>
    </section>
  </div>
</body>
</html>
```

### Paso 8: README de los mocks

`mocks/README.md`:

```markdown
# Mockups · <Project>

Mockups HTML+Tailwind navegables de las pantallas principales. 
Generados en Fase 3A por el UI Designer.

## Cómo abrirlos

Abrí `index.html` en cualquier navegador moderno. No requiere servidor.

\`\`\`bash
open mocks/index.html       # macOS
xdg-open mocks/index.html   # Linux
\`\`\`

## Qué SON estos mockups

- Visualización del look-and-feel y la estructura de las pantallas
- Datos de ejemplo realistas
- Referencia visual para el Frontend Developer al implementar el frontend real
- Base para iteración rápida del diseño (cambiar mock < cambiar React)

## Qué NO son

- Código a deployar
- Pixel-perfect spec final (eso es responsabilidad del Frontend Developer al implementar)
- Funcionalidad interactiva real (no hay JS de negocio acá)
- Versión final del diseño (van a iterar)

## Pantallas incluidas

[lista con descripciones cortas]

## Estados ilustrados

[lista de estados como empty, loading, error]

## Limitaciones conocidas

- Tailwind via CDN: en producción se usará build process
- Iconos: usamos lucide via CDN; en producción se decidirá librería final
- Responsive: probado en mobile (375px) y desktop (1280px), no en breakpoints intermedios

## Cómo iterar

Si querés cambios, abrí un issue o decímelo en chat. Yo (el UI Designer) regenero.
```

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
- **JavaScript de producción**: NO uses libs de framework (React, Vue), NO conectes con APIs reales, NO uses build steps. **El JS de simulación SÍ está permitido** (ver sección "Modo interactivo" más abajo).
- **Reinventar componentes en cada pantalla**: usá los snippets de `components/`.
- **Olvidar dark mode si está en el ui-spec**: si el UI Designer dijo dark mode v1, los mocks tienen dark mode.

## Modo interactivo (desde Sesión 7)

Los mockups pueden ser **estáticos** (solo navegación entre pantallas, datos hard-coded en HTML) o **interactivos** (estado JS, forms que "guardan" en memoria, listas que se actualizan).

### Cuándo usar modo interactivo

**Activar modo interactivo si**:
- El proyecto tiene flujos de creación/edición/borrado significativos (CRUD-heavy)
- El usuario quiere validar interacciones, no solo layout
- Hay forms con validación, condicionalidad, o cálculos en vivo
- El UX spec define estados que dependen de acciones del usuario (ej: agregar un item y ver cómo cambia un total)

**Quedarse en modo estático si**:
- El proyecto es mayormente lectura (dashboards, reports)
- Las interacciones son triviales (un botón = una página nueva)
- El usuario solo quiere ver el look-and-feel

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

```
mocks/
├── README.md
├── index.html
├── tokens.css
├── prototype/                    # ← Carpeta nueva para JS de simulación
│   ├── state.js                  # Estado global (localStorage wrappers)
│   ├── seed-data.js              # Datos iniciales realistas
│   └── reset.js                  # Botón reset
├── components/
└── screens/
```

### Template `prototype/state.js`

```javascript
// state.js — Estado del prototipo persistido en localStorage
// IMPORTANTE: esto es prototipo. La lógica real la implementa el Backend Developer.

const STORAGE_KEY = 'prototype_state_v1';

function loadState() {
  const raw = localStorage.getItem(STORAGE_KEY);
  if (!raw) return getSeedState();
  try {
    return JSON.parse(raw);
  } catch {
    return getSeedState();
  }
}

function saveState(state) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

function getSeedState() {
  // Lee desde seed-data.js
  return window.SEED_DATA || { items: [], users: [] };
}

function resetPrototype() {
  localStorage.removeItem(STORAGE_KEY);
  location.reload();
}

// API simple para usar desde las pantallas
window.proto = {
  load: loadState,
  save: saveState,
  reset: resetPrototype,
  
  // Ejemplos de operaciones de dominio
  addItem(item) {
    const state = loadState();
    state.items.push({ ...item, id: crypto.randomUUID(), createdAt: new Date().toISOString() });
    saveState(state);
    return state;
  },
  
  removeItem(id) {
    const state = loadState();
    state.items = state.items.filter(i => i.id !== id);
    saveState(state);
    return state;
  },
};
```

### Template de pantalla interactiva (con Alpine.js)

```html
<!DOCTYPE html>
<html lang="es" data-theme="light">
<head>
  <meta charset="UTF-8">
  <title>Lista de gastos · Prototipo</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <script src="https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js" defer></script>
  <link rel="stylesheet" href="../tokens.css">
  <script src="../prototype/seed-data.js"></script>
  <script src="../prototype/state.js"></script>
</head>
<body class="bg-neutral-50 text-neutral-900 min-h-screen">
  
  <!-- Banner prototipo -->
  <div class="bg-amber-100 border-b border-amber-300 px-4 py-2 text-sm text-amber-900 flex justify-between">
    <span><strong>PROTOTIPO INTERACTIVO</strong> · Datos en tu navegador, no en servidor</span>
    <button onclick="proto.reset()" class="underline">Reset prototipo</button>
  </div>
  
  <main class="max-w-3xl mx-auto p-6"
        x-data="{ 
          items: proto.load().items,
          newDescription: '',
          newAmount: '',
          addItem() {
            if (!this.newDescription || !this.newAmount) return;
            const state = proto.addItem({
              description: this.newDescription,
              amount: parseFloat(this.newAmount),
            });
            this.items = state.items;
            this.newDescription = '';
            this.newAmount = '';
          },
          removeItem(id) {
            const state = proto.removeItem(id);
            this.items = state.items;
          },
          get total() {
            return this.items.reduce((sum, i) => sum + i.amount, 0);
          }
        }">
    
    <h1 class="text-2xl font-bold mb-6">Mis gastos</h1>
    
    <!-- Lista reactiva -->
    <div class="space-y-2 mb-6">
      <template x-for="item in items" :key="item.id">
        <div class="flex justify-between items-center p-3 bg-white rounded border">
          <span x-text="item.description"></span>
          <div class="flex items-center gap-3">
            <span class="font-semibold" x-text="'$' + item.amount.toFixed(2)"></span>
            <button @click="removeItem(item.id)" class="text-error text-sm">Eliminar</button>
          </div>
        </div>
      </template>
      <div x-show="items.length === 0" class="text-center py-8 text-neutral-500">
        Sin gastos todavía. Agregá uno abajo.
      </div>
    </div>
    
    <!-- Total reactivo -->
    <div class="text-xl font-bold mb-6 text-right">
      Total: <span x-text="'$' + total.toFixed(2)"></span>
    </div>
    
    <!-- Form de agregar -->
    <div class="bg-white p-4 rounded border space-y-3">
      <input type="text" x-model="newDescription" placeholder="Descripción"
             class="w-full px-3 py-2 border rounded">
      <input type="number" x-model="newAmount" placeholder="Monto" step="0.01"
             class="w-full px-3 py-2 border rounded">
      <button @click="addItem()" 
              class="w-full bg-primary-600 text-white py-2 rounded hover:bg-primary-700">
        Agregar gasto
      </button>
    </div>
  </main>
</body>
</html>
```

### Iteración del prototipo

Una vez generado:
1. El usuario abre `mocks/index.html`, hace clic, prueba flujos.
2. Anota qué funciona y qué no en `mocks/feedback.md` (template abajo).
3. Vos (el UI Designer) iterás los archivos afectados.
4. **NUNCA dejes el prototipo en estado "roto"**: cada commit del mock debe estar funcionando.

Template `mocks/feedback.md` (creado al primer feedback):

```markdown
# Feedback del prototipo · iteración N

**Fecha**: YYYY-MM-DD
**Probado por**: <nombre>

## Funciona como esperaba
- ...

## No funciona / poco intuitivo
- ...

## Falta
- ...

## Decisiones tomadas en esta iteración
- ...
```

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
