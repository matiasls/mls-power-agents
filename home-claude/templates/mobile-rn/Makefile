.PHONY: help setup dev ios android test lint build-preview build-prod submit-ios submit-android clean

help:
	@echo "Available commands:"
	@echo ""
	@echo "  Setup & Development"
	@echo "    make setup            First-time setup"
	@echo "    make dev              Start Metro bundler"
	@echo "    make ios              Build & run on iOS sim"
	@echo "    make android          Build & run on Android emulator"
	@echo ""
	@echo "  Testing & Linting"
	@echo "    make test             Run tests"
	@echo "    make lint             ESLint + TypeScript check"
	@echo ""
	@echo "  Builds"
	@echo "    make build-preview    EAS Build preview channel"
	@echo "    make build-prod       EAS Build production"
	@echo ""
	@echo "  Submission"
	@echo "    make submit-ios       Submit to App Store"
	@echo "    make submit-android   Submit to Play Store"

setup:
	@test -f .env || cp .env.example .env
	npm ci
	cd ios && pod install 2>/dev/null || echo "iOS not configured yet (skip if Android-only)"
	@echo ""
	@echo "✓ Setup complete. Run 'make dev' to start."

dev:
	npx expo start

ios:
	npx expo run:ios

android:
	npx expo run:android

test:
	npm test

lint:
	npm run lint
	npx tsc --noEmit

build-preview:
	eas build --profile preview --platform all

build-prod:
	eas build --profile production --platform all

submit-ios:
	eas submit --platform ios --profile production

submit-android:
	eas submit --platform android --profile production

clean:
	rm -rf node_modules ios/Pods android/build
	npx expo prebuild --clean
