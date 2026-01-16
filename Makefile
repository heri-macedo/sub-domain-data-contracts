.PHONY: setup install lint format validate-contracts validate-contract dry-run-contract apply-contract deploy trigger trigger-all trigger-contracts trigger-dry trigger-all-dry publish-purview publish-purview-modified publish-purview-all help

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

trigger-contracts:
	@echo "🔄 Triggering jobs for contracts: $(CONTRACTS)..."
	databricks-contracts trigger contracts $(CONTRACTS)

trigger-dry:
	databricks-contracts trigger modified --dry-run

trigger-all-dry:
	databricks-contracts trigger all --dry-run

trigger-contracts-dry:
	@echo "🔍 Dry-run: Triggering jobs for contracts: $(CONTRACTS)..."
	databricks-contracts trigger contracts $(CONTRACTS) --dry-run

# =============================================================================
# Purview
# =============================================================================

publish-purview:
	@echo "📤 Publishing contracts to Purview ($(ENVIRONMENT))..."
	databricks-contracts publish purview $(CONTRACTS) --env $(ENVIRONMENT)
	@echo "✅ Contracts published to Purview!"

publish-purview-modified:
	@echo "📤 Publishing modified contracts to Purview ($(ENVIRONMENT))..."
	databricks-contracts publish purview-modified --env $(ENVIRONMENT)
	@echo "✅ Modified contracts published to Purview!"

publish-purview-all:
	@echo "📤 Publishing all contracts to Purview ($(ENVIRONMENT))..."
	databricks-contracts publish purview-all --env $(ENVIRONMENT)
	@echo "✅ All contracts published to Purview!"

publish-purview-dry:
	@echo "🔍 Dry-run: Publishing contracts to Purview ($(ENVIRONMENT))..."
	databricks-contracts publish purview $(CONTRACTS) --env $(ENVIRONMENT) --dry-run

publish-purview-modified-dry:
	@echo "🔍 Dry-run: Publishing modified contracts to Purview ($(ENVIRONMENT))..."
	databricks-contracts publish purview-modified --env $(ENVIRONMENT) --dry-run

publish-purview-all-dry:
	@echo "🔍 Dry-run: Publishing all contracts to Purview ($(ENVIRONMENT))..."
	databricks-contracts publish purview-all --env $(ENVIRONMENT) --dry-run

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
	@echo "    make validate-contracts                - Validate all contracts"
	@echo "    make validate-contract CONTRACT=name   - Validate a specific contract"
	@echo "    make dry-run-contract CONTRACT=name    - Preview DDL for a contract"
	@echo "    make apply-contract CONTRACT=name      - Apply a contract"
	@echo ""
	@echo "  Bundle:"
	@echo "    make validate-bundle    - Validate bundle"
	@echo "    make deploy             - Deploy bundle"
	@echo ""
	@echo "  Trigger:"
	@echo "    make trigger                           - Trigger modified contracts"
	@echo "    make trigger-all                       - Trigger all contracts"
	@echo "    make trigger-contracts CONTRACTS='a b' - Trigger specific contracts"
	@echo "    make trigger-dry                       - Dry-run modified"
	@echo "    make trigger-all-dry                   - Dry-run all"
	@echo "    make trigger-contracts-dry CONTRACTS='a b' - Dry-run specific"
	@echo ""
	@echo "  Purview:"
	@echo "    make publish-purview CONTRACTS='a b'   - Publish specific contracts"
	@echo "    make publish-purview-modified          - Publish modified contracts"
	@echo "    make publish-purview-all               - Publish all contracts"
	@echo "    make publish-purview-dry CONTRACTS='a' - Dry-run publish specific"
	@echo "    make publish-purview-modified-dry      - Dry-run publish modified"
	@echo "    make publish-purview-all-dry           - Dry-run publish all"
	@echo ""
	@echo "  Override environment: make apply-contract CONTRACT=table_name_1 ENVIRONMENT=prod"

