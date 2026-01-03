# Data Contracts - [Team Name]

Repository for data contracts of [Team Name] domain.

## Setup

### 1. Install dependencies

```bash
# Create virtual environment
pyenv virtualenv 3.12.7 data-contracts-[team]
pyenv activate data-contracts-[team]

# Install dependencies
pip install -r requirements.txt
```

### 2. Configure environment

```bash
cp env.example .env
# Edit .env with your Databricks credentials
```

### 3. Update datacontract.config.yaml

Edit `datacontract.config.yaml` with your domain settings:
- `domain.catalog`: Your Unity Catalog name
- `domain.schema`: Your schema name
- `ownership`: Default ownership for contracts

## Usage

### Validate contracts

```bash
databricks-contracts validate all
```

### Preview DDL

```bash
databricks-contracts apply ddl my_table
```

### Deploy bundle

```bash
# Validate
databricks bundle validate -t dev

# Deploy
databricks bundle deploy -t dev
```

## Creating a new contract

1. Copy template:
   ```bash
   cp templates/contract.minimal.yaml data_contracts/assets/my_new_table.yaml
   ```

2. Edit the contract with your table definition

3. Validate:
   ```bash
   databricks-contracts validate contract my_new_table
   ```

4. Commit and push to trigger CI/CD

## CI/CD

| Event | Action |
|-------|--------|
| Pull Request | Lint + Validate contracts |
| Merge to develop | Deploy to dev + Trigger modified |
| Merge to main | Deploy to prod + Trigger modified |

## Project Structure

```
├── data_contracts/
│   └── assets/           # Your contracts (.yaml)
├── resources/            # DAB Python resources
├── templates/            # Contract templates
├── datacontract.config.yaml  # Domain configuration
├── databricks.yaml       # Bundle configuration
└── requirements.txt
```

