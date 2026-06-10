<!-- Template de mocks/README.md. Reemplazar <Project> y completar las listas. -->

# Mockups · <Project>

Mockups HTML+Tailwind navegables de las pantallas principales.
Generados en Fase 3A por el UI Designer.

## Cómo abrirlos

Abrí `index.html` en cualquier navegador moderno. No requiere servidor.

```bash
open mocks/index.html       # macOS
xdg-open mocks/index.html   # Linux
```

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
