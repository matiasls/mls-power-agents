# <PROJECT_NAME>

> Mobile app built with React Native + Expo.

## What it does

[2-3 sentences]

## Quick start

```bash
make setup           # First-time
make dev             # Start Metro bundler
make ios             # Run on iOS simulator
make android         # Run on Android emulator
```

See [docs/EXECUTION.md](docs/EXECUTION.md) for full guide.

## Stack

- **Framework**: React Native + Expo (managed workflow)
- **Language**: TypeScript (strict)
- **Routing**: Expo Router
- **State**: React Query (server) + Zustand (client)
- **Styling**: NativeWind (Tailwind for RN)
- **Storage**: Expo SecureStore (tokens) + AsyncStorage (cache)
- **Build**: EAS Build (dev/preview/production channels)

## Project structure

```
app/                    # Expo Router file-based routing
src/
  features/             # Feature folders
  shared/               # Reusable code
  theme/                # Design tokens
assets/                 # Images, fonts, etc.
app.config.ts           # Expo config (dynamic)
eas.json                # EAS Build config
```

## Development

| Command | What it does |
|---|---|
| `make setup` | First-time install + iOS pods + .env |
| `make dev` | Start Metro bundler |
| `make ios` | Build & run on iOS sim |
| `make android` | Build & run on Android emulator |
| `make test` | Run Jest tests |
| `make lint` | ESLint + TS check |
| `make build:preview` | EAS Build preview channel |
| `make build:prod` | EAS Build production |
| `make submit:ios` | Submit to App Store |
| `make submit:android` | Submit to Play Store |

## Docs

- [docs/EXECUTION.md](docs/EXECUTION.md)
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- [docs/adr/](docs/adr/) - Architecture Decision Records

## License

[TBD]
