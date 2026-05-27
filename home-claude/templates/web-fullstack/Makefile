.PHONY: help setup dev test test-backend test-frontend lint lint-backend lint-frontend \
        migrate-up migrate-down seed logs logs-api logs-frontend psql down clean build

# Default target
help:
	@echo "Available commands:"
	@echo ""
	@echo "  Setup & Development"
	@echo "    make setup         First-time setup (copies .env, pulls images, builds)"
	@echo "    make dev           Start all services for local development"
	@echo "    make down          Stop all services"
	@echo "    make clean         Stop and remove volumes (DESTRUCTIVE)"
	@echo ""
	@echo "  Testing & Linting"
	@echo "    make test          Run all tests"
	@echo "    make test-backend  Backend tests only"
	@echo "    make test-frontend Frontend tests only"
	@echo "    make lint          Run all linters"
	@echo ""
	@echo "  Database"
	@echo "    make migrate-up    Apply pending migrations"
	@echo "    make migrate-down  Rollback last migration"
	@echo "    make seed          Load seed data"
	@echo "    make psql          Open psql session"
	@echo ""
	@echo "  Logs"
	@echo "    make logs          Tail all service logs"
	@echo "    make logs-api      Tail backend logs"
	@echo "    make logs-frontend Tail frontend logs"
	@echo ""
	@echo "See docs/EXECUTION.md for detailed instructions."

# ============================================================
# Setup
# ============================================================

setup:
	@test -f .env || cp .env.example .env
	@echo "✓ .env file ready"
	docker compose pull
	docker compose build
	@echo ""
	@echo "✓ Setup complete. Run 'make dev' to start."

# ============================================================
# Development
# ============================================================

dev:
	docker compose up

down:
	docker compose down

clean:
	docker compose down -v
	@echo "⚠ All local volumes destroyed"

build:
	docker compose build

# ============================================================
# Testing
# ============================================================

test: test-backend test-frontend

test-backend:
	docker compose run --rm api go test ./... -cover

test-frontend:
	docker compose run --rm frontend npm test -- --run

# ============================================================
# Linting
# ============================================================

lint: lint-backend lint-frontend

lint-backend:
	docker compose run --rm api golangci-lint run ./...

lint-frontend:
	docker compose run --rm frontend npm run lint

# ============================================================
# Database
# ============================================================

migrate-up:
	docker compose run --rm api migrate -path /app/migrations -database "$$DATABASE_URL" up

migrate-down:
	docker compose run --rm api migrate -path /app/migrations -database "$$DATABASE_URL" down 1

seed:
	docker compose run --rm api go run ./cmd/seed

psql:
	docker compose exec db psql -U $$POSTGRES_USER -d $$POSTGRES_DB

# ============================================================
# Logs
# ============================================================

logs:
	docker compose logs -f

logs-api:
	docker compose logs -f api

logs-frontend:
	docker compose logs -f frontend
