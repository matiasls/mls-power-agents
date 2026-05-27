# CLAUDE.md — <PROJECT_NAME> (Mobile)

> Mobile-only project. Extends `~/.claude/CLAUDE.md` global.

## Project context

- **Name**: <PROJECT_NAME>
- **Type**: Mobile app (React Native + Expo)
- **Platforms**: iOS + Android
- **Nature**: [Personal / MVP / Commercial]


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

## Phase tracking

See `docs/context/STATE.md` for current phase.

## Stack

- React Native + Expo (managed workflow)
- TypeScript strict
- Expo Router (file-based routing)
- React Query (server state)
- Zustand (client state)
- React Hook Form + Zod (forms)
- NativeWind (Tailwind for RN)
- Expo SecureStore (tokens)
- EAS Build + EAS Submit

## Stack overrides (vs global default)

- Frontend stack reemplazado por RN + Expo
- Backend usado: <reference al backend si es separado, o "este proyecto consume API X">

## Mobile-specific concerns

- **Offline-first**: ¿el caso de uso lo requiere?
- **Push notifications**: ¿necesarias en MVP?
- **Deep links**: dominios soportados
- **App store submission**: timeline + reviews
- **Code push / OTA updates**: estrategia para hotfixes

## Project-specific overrides

[Justificá cualquier desvío del setup global]

## References

- Global setup: `~/.claude/CLAUDE.md`
- Mobile agent: el Mobile Developer (`~/.claude/agents/bruno-mobile.md`)
