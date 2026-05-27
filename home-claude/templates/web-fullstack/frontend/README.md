# Frontend (React + TypeScript + Vite)

## Structure

```
frontend/
├── src/
│   ├── main.tsx                 # Entry point
│   ├── App.tsx                  # Root component
│   ├── routes/                  # React Router routes (or pages/ if using file-based)
│   ├── features/                # Feature modules (mirror backend domain modules)
│   │   └── <feature>/
│   │       ├── api/             # API client functions
│   │       ├── components/      # Feature-specific components
│   │       ├── hooks/           # Feature-specific hooks
│   │       └── types.ts         # Feature types
│   ├── shared/
│   │   ├── components/          # Reusable UI components
│   │   ├── hooks/               # Reusable hooks
│   │   ├── lib/                 # Utilities
│   │   └── api/                 # HTTP client setup (auth interceptors, etc.)
│   ├── styles/                  # Tailwind config, global CSS
│   └── env.d.ts                 # Vite env types
├── public/
├── index.html
├── package.json
├── tsconfig.json
├── vite.config.ts
├── tailwind.config.js
├── Dockerfile
├── Dockerfile.dev
└── .eslintrc.cjs
```

## Conventions

- **Feature folders mirror backend modules** for cognitive consistency.
- **Shared components** are truly reusable across features. If a component is used by only one feature, it stays in that feature.
- **API calls** centralized per feature in `api/` subfolder, using shared HTTP client.
- **State management**: React Query for server state, Context/Zustand for client state (decide in Fase 3A/3B).
- **Styling**: Tailwind utility classes. Avoid custom CSS unless reusable.

## Testing

- **Unit/component**: Vitest + React Testing Library
- **E2E**: Playwright

```bash
npm test            # Vitest watch mode
npm test -- --run   # CI / single run
npm run test:e2e    # Playwright
```

Coverage target: ≥85% on business logic components.

## Linting

```bash
npm run lint
```

ESLint config in `.eslintrc.cjs`.

## Environment variables

Frontend env vars MUST be prefixed with `VITE_` to be available in client code.

```env
VITE_API_URL=http://localhost:8080
```

NEVER put secrets in frontend env vars. Anything in `VITE_*` is bundled into client code and visible to users.
