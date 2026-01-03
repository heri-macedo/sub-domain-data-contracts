.PHONY: setup install lint format validate-contracts dry-run deploy trigger help

# Load .env file if exists
ifneq (,$(wildcard .env))
    include .env
    export
endif

ENVIRONMENT ?= dev

# =============================================================================
# Setup
# =============================================================================

setup: install
	@echo "✅ Setup complete!"

install:
	pip install -r requirements.txt
	@echo "✅ Dependencies installed"

install-dev: install
	pip install -r requirements.dev.txt
	@echo "✅ Dev dependencies installed"

# =============================================================================
# Linting
# =============================================================================

lint:
	ruff check resources/
	ruff format --check resources/

format:
	ruff check --fix resources/
	ruff format resources/

# =============================================================================
# Contracts
# =============================================================================

validate-contracts:
	@echo "🔍 Validating all contracts..."
	databricks-contracts validate all

dry-run:
	@echo "📋 Generating DDL preview..."
	databricks-contracts apply all --dry-run

# =============================================================================
# Bundle
# =============================================================================

validate-bundle:
	databricks bundle validate -t $(ENVIRONMENT)

deploy:
	databricks bundle deploy -t $(ENVIRONMENT)
	@echo "✅ Bundle deployed to $(ENVIRONMENT)"

# =============================================================================
# Trigger
# =============================================================================

trigger:
	databricks-contracts trigger modified --env $(ENVIRONMENT)

trigger-all:
	databricks-contracts trigger all --env $(ENVIRONMENT)

trigger-dry:
	databricks-contracts trigger modified --env $(ENVIRONMENT) --dry-run

# =============================================================================
# Help
# =============================================================================

help:
	@echo "Available commands:"
	@echo ""
	@echo "  Setup:"
	@echo "    make setup          - Install dependencies"
	@echo "    make install-dev    - Install dev dependencies"
	@echo ""
	@echo "  Linting:"
	@echo "    make lint           - Check code style"
	@echo "    make format         - Auto-format code"
	@echo ""
	@echo "  Contracts:"
	@echo "    make validate-contracts  - Validate all contracts"
	@echo "    make dry-run             - Preview DDL"
	@echo ""
	@echo "  Bundle:"
	@echo "    make validate-bundle     - Validate bundle"
	@echo "    make deploy              - Deploy bundle"
	@echo ""
	@echo "  Trigger:"
	@echo "    make trigger             - Trigger modified contracts"
	@echo "    make trigger-all         - Trigger all contracts"
	@echo "    make trigger-dry         - Dry run"
	@echo ""
	@echo "  Override environment: make deploy ENVIRONMENT=prod"

