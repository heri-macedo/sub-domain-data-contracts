# Examples


This folder contains example files for reference and testing.

## Contents

```
examples/
├── contracts/                  # Sample contract files
│   ├── table_name_1.yaml
│   ├── table_name_2.yaml
│   └── table_name_3.yaml
├── templates/                  # Contract templates
│   ├── contract.minimal.yaml   # Minimum required fields
│   └── contract.full.yaml      # All fields including optional
├── resources/                  # DAB Python resources
│   ├── __init__.py             # load_resources() entry point
│   └── scripts/
│       └── main.py             # Job runtime entry point
├── databricks.yaml             # Bundle configuration example
└── datacontract.config.yaml    # Domain configuration (REQUIRED)
```

## datacontract.config.yaml

This file is **required** in the repository root. It defines:

- **domain.name**: Catalog base name (e.g., `b3_tests`)
- **domain.sub_domain**: Schema name (e.g., `canais_digitais`)
- **environments.{env}.catalog_suffix**: Suffix per environment

Example catalog resolution:
- `--env dev` → `b3_tests.canais_digitais.table_name`
- `--env prod` → `b3_tests_prod.canais_digitais.table_name`

## Testing Locally

To test the CLI with these examples, run from **inside this folder**:

```bash
cd examples

# Dry-run for dev environment
CONTRACTS_PATH=contracts python -m databricks_contracts apply all --dry-run --env dev

# Dry-run for prod environment (adds _prod suffix)
CONTRACTS_PATH=contracts python -m databricks_contracts apply all --dry-run --env prod
```

## Using as Reference

Copy files from this folder to set up a new team repository:

1. Copy `datacontract.config.yaml` and customize for your domain (**required**)
2. Copy `contracts/` and add your table contracts
3. Copy `templates/` for contract templates
4. Copy `resources/` for DAB Python support
5. Copy `databricks.yaml` as bundle config

Or use `client-template/` which has everything pre-configured.

