.PHONY: help setup dev test lint format train predict clean

PYTHON ?= python3.11

help:
	@echo "Available commands:"
	@echo "  make setup     Create venv, install deps via uv"
	@echo "  make dev       Start FastAPI dev server on :8001"
	@echo "  make test      Run pytest with coverage"
	@echo "  make lint      ruff + mypy"
	@echo "  make format    Auto-format with ruff"
	@echo "  make train     Run training pipeline"
	@echo "  make predict   CLI smoke test prediction"
	@echo "  make clean     Remove venv + caches"

setup:
	@command -v uv >/dev/null 2>&1 || { echo "Installing uv..."; pip install uv; }
	uv venv
	uv pip install -r requirements.txt
	uv pip install -r requirements-dev.txt
	@test -f .env || cp .env.example .env
	@echo "✓ Setup complete. Activate with: source .venv/bin/activate"

dev:
	uv run uvicorn src.api.main:app --reload --port 8001

test:
	uv run pytest --cov=src --cov-report=term-missing --cov-report=html

lint:
	uv run ruff check src tests
	uv run mypy src

format:
	uv run ruff format src tests
	uv run ruff check --fix src tests

train:
	uv run python -m src.batch.train

predict:
	uv run python -m src.cli.predict

clean:
	rm -rf .venv .pytest_cache .ruff_cache .mypy_cache htmlcov
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
