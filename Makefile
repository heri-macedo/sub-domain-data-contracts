.PHONY: setup install lint format validate-contracts validate-contract dry-run-contract apply-contract deploy trigger trigger-contract publish-purview publish-purview-contract help

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

validate-contract:
	@echo "🔍 Validating contract $(CONTRACT)..."
	databricks-contracts validate contract $(CONTRACT)

dry-run-contract:
	@echo "📋 Generating DDL preview for contract $(CONTRACT)..."
	databricks-contracts apply contract $(CONTRACT) --dry-run

apply-contract:
	@echo "🚀 Applying contract $(CONTRACT) to $(ENVIRONMENT)..."
	databricks-contracts apply contract $(CONTRACT) --env $(ENVIRONMENT)
	@echo "✅ Contract $(CONTRACT) applied!"

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
	databricks-contracts trigger modified

trigger-all:
	databricks-contracts trigger all

trigger-contract:
	@echo "🔄 Triggering job for contract $(CONTRACT)..."
	databricks-contracts trigger contract $(CONTRACT)

trigger-all-dry:
	databricks-contracts trigger all --dry-run

trigger-dry:
	databricks-contracts trigger modified --dry-run

# =============================================================================
# Purview
# =============================================================================

publish-purview:
	@echo "📤 Publishing contract $(CONTRACT) to Purview ($(ENVIRONMENT))..."
	databricks-contracts publish purview $(CONTRACT) --env $(ENVIRONMENT)
	@echo "✅ Contract $(CONTRACT) published to Purview!"

# =============================================================================
# Help
# =============================================================================

help:
	@echo "Available commands:"
	@echo ""
	@echo "  Setup:"
	@echo "    make setup              - Install dependencies"
	@echo "    make install-dev        - Install dev dependencies"
	@echo ""
	@echo "  Linting:"
	@echo "    make lint               - Check code style"
	@echo "    make format             - Auto-format code"
	@echo ""
	@echo "  Contracts:"
	@echo "    make validate-contracts - Validate all contracts"
	@echo "    make validate-contract CONTRACT=name - Validate a specific contract"
	@echo "    make dry-run-contract CONTRACT=name  - Preview DDL for a specific contract"
	@echo "    make apply-contract CONTRACT=name    - Apply a specific contract"
	@echo ""
	@echo "  Bundle:"
	@echo "    make validate-bundle    - Validate bundle"
	@echo "    make deploy             - Deploy bundle"
	@echo ""
	@echo "  Trigger:"
	@echo "    make trigger            - Trigger modified contracts"
	@echo "    make trigger-all        - Trigger all contracts"
	@echo "    make trigger-contract CONTRACT=name - Trigger job for a specific contract"
	@echo "    make trigger-dry        - Dry run modified"
	@echo ""
	@echo "  Purview:"
	@echo "    make publish-purview CONTRACT=name - Publish a contract to Purview (uses ENVIRONMENT)"
	@echo ""
	@echo "  Override environment: make apply-contract CONTRACT=table_name_1 ENVIRONMENT=prod"

