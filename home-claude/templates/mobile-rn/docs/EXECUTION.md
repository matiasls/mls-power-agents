# Execution Guide (Mobile)

> How to run this mobile app in every environment.

## Overview

React Native + Expo (managed workflow). Builds via EAS Build, distribution via EAS Submit + TestFlight / Internal App Sharing.

---

## Local Development

### Prerequisites

- macOS (for iOS) or Linux/Windows (Android only)
- Node 20+
- Xcode (latest) for iOS
- Android Studio for Android
- Expo CLI: installed via `npx expo`
- EAS CLI: `npm install -g eas-cli`
- Apple Developer account (for iOS builds)
- Google Play Console account (for Android builds)

### First-time setup

```bash
git clone <repo-url>
cd <project>
make setup
```

### Daily development

```bash
make dev          # Start Metro bundler
# Then in another terminal:
make ios          # Open on iOS simulator
make android      # Open on Android emulator
```

Or scan the QR code in the Metro UI from Expo Go app on physical device.

### Available commands

| Command | What it does |
|---|---|
| `make dev` | Start Metro bundler |
| `make ios` | Run on iOS simulator |
| `make android` | Run on Android emulator |
| `make test` | Run Jest tests |
| `make lint` | ESLint + TS check |
| `make build-preview` | EAS Build, preview channel |
| `make build-prod` | EAS Build, production |
| `make submit-ios` | Submit to App Store |
| `make submit-android` | Submit to Play Store |
| `make clean` | Clean native builds |

### Troubleshooting

**Metro bundler stuck**
```bash
npx expo start --clear
```

**iOS build fails**
```bash
cd ios && pod install && cd ..
```

**Android build fails**
- Check `android/local.properties` has `sdk.dir`
- Try `cd android && ./gradlew clean && cd ..`

---

## Staging / Preview Builds

> ⚠️ **STATUS**: [Not yet configured | Configured]

### Build preview

```bash
eas build --profile preview --platform all
```

### Distribution

- **iOS**: TestFlight (internal testers)
- **Android**: EAS Internal Distribution or Play Console Internal Testing

### How testers install

1. iOS: TestFlight invite via email
2. Android: link de EAS internal sharing o Play internal testing

---

## Production

### Pre-submission checklist

- [ ] App icon set (all sizes)
- [ ] Splash screen set
- [ ] App Store / Play Store metadata ready (descriptions, screenshots, keywords)
- [ ] Privacy policy URL ready
- [ ] Terms of service URL ready
- [ ] Permisos justificados en `app.config.ts` con razones claras
- [ ] Versionado: `version` y `iosBuildNumber` / `androidVersionCode` incrementados
- [ ] Internal testing OK en TestFlight + Internal Sharing
- [ ] CHANGELOG.md actualizado
- [ ] Tag firmado: `git tag -s vX.Y.Z`

### Build production

```bash
make build-prod
```

EAS Build subirá a su dashboard. Esperar build (~20-40 min).

### Submit

```bash
make submit-ios
make submit-android
```

### Review times

- **iOS**: típicamente 24-72 hs después de submit
- **Android**: típicamente 1-3 días para review inicial; updates más rápidos

### Code push / OTA updates

Para fixes que NO requieren binario nuevo (JS-only changes):

```bash
eas update --branch production --message "Hotfix: X"
```

NO usar OTA para:
- Cambios en permisos
- Nuevas dependencias nativas
- Cambios visuales mayores (review esperado por stores)

### Rollback

#### Rollback OTA
```bash
eas update --branch production --message "Rollback to previous version" \
    --republish <previous-update-id>
```

#### Rollback binary
- iOS: imposible rollback en App Store. Submit nueva versión con fix.
- Android: posible promover previous build a production track.

---

## Environment Variables Reference

Variables prefijadas `EXPO_PUBLIC_*` se bundlean en el app y son visibles a usuarios.
**NUNCA poner secrets aquí**.

| Variable | Local | Preview | Prod | Notas |
|---|---|---|---|---|
| `EXPO_PUBLIC_API_URL` | localhost | staging API | prod API | Sin trailing slash |
| `EXPO_PUBLIC_ENV` | development | preview | production | |

Secrets se manejan via `eas secret:create` o fetched runtime desde tu backend.

---

## Observability

- **Crash reporting**: Sentry (`@sentry/react-native`)
- **Analytics**: Amplitude / PostHog (configurar en `app.config.ts`)
- **Logs en remoto**: a través de Sentry breadcrumbs

---

## App Store / Play Store

- **App Store Connect**: <URL>
- **Play Console**: <URL>
- **TestFlight**: <URL>
- **App Identifier (Bundle ID)**: <com.example.app>

## Disaster recovery

### Si pierdo acceso a la cuenta Apple
- Asegurate de tener 2FA + recovery codes guardados
- App Store Connect tiene admins multi-user; configurar al menos 2

### Si pierdo la signing key Android
- Imposible re-publicar updates. Migración a nueva app = signed by Play.
- Backup de keystore obligatorio. Store en password manager + secondary location.
