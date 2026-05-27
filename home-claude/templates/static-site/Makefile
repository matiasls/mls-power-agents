.PHONY: help setup dev build preview lint lighthouse clean

help:
	@echo "Available commands:"
	@echo "  make setup       Install deps"
	@echo "  make dev         Start dev server on :4321"
	@echo "  make build       Production build"
	@echo "  make preview     Preview production build locally"
	@echo "  make lint        ESLint + Astro check"
	@echo "  make lighthouse  Run Lighthouse against local build"
	@echo "  make clean       Remove node_modules + dist"

setup:
	npm ci
	@test -f .env || cp .env.example .env

dev:
	npm run dev

build:
	npm run build

preview:
	npm run preview

lint:
	npm run lint
	npx astro check

lighthouse: build
	npx http-server dist -p 4322 &
	@sleep 2
	npx lighthouse http://localhost:4322 --view --preset=desktop
	@pkill -f "http-server dist" || true

clean:
	rm -rf node_modules dist .astro
