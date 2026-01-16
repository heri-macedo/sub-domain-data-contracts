# Sub-Domain Data Contracts - Template Repository

> **📋 Este repositório é um template/exemplo** a ser seguido pelos times que irão implementar contratos de dados em seus subdomínios.

## Visão Geral

Este repositório demonstra a estrutura padrão para gerenciar contratos de dados usando a CLI `databricks-contracts`. Os times devem usar este repositório como referência para criar seus próprios repositórios de contratos.

## Estrutura do Projeto

```
your-subdomain-contracts/
├── data_contracts/
│   └── assets/                     # Contratos de tabelas (um arquivo por tabela)
│       ├── table_name_1.yaml
│       ├── table_name_2.yaml
│       └── table_name_3.yaml
├── resources/                      # Python resources para DAB
│   ├── __init__.py                 # load_resources() entry point
│   └── scripts/
│       └── main.py                 # Job runtime entry point
├── templates/                      # Templates de contratos
│   ├── contract.minimal.yaml       # Campos mínimos obrigatórios
│   └── contract.full.yaml          # Todos os campos (incluindo opcionais)
├── .github/
│   └── workflows/
│       ├── on-pull-request.yml     # Validação em PRs
│       └── on-push.yml             # Deploy em push (develop/master)
├── databricks.yaml                 # Configuração do Databricks Bundle
├── datacontract.config.yaml        # Configuração do domínio (OBRIGATÓRIO)
├── requirements.txt                # Dependências Python
└── Makefile                        # Comandos de automação
```

## Configuração Obrigatória

### `datacontract.config.yaml`

Este arquivo **deve existir na raiz** do repositório e define:

```yaml
domain:
  name: "seu_catalogo"              # Nome base do catálogo (Unity Catalog)
  sub_domain: "seu_schema"          # Nome do schema
  description: "Descrição do domínio"

environments:
  dev:
    catalog_suffix: ""              # dev: catalog = "seu_catalogo"
  prod:
    catalog_suffix: "_prod"         # prod: catalog = "seu_catalogo_prod"

ownership:
  data_owner: "Time Responsável"
  bds: "Nome do BDS"
  tds: "Nome do TDS"
  purview_collection: "Collection Name"
```

**Resolução de nomes:**
- `--env dev` → `seu_catalogo.seu_schema.nome_tabela`
- `--env prod` → `seu_catalogo_prod.seu_schema.nome_tabela`

---

## 🧪 Comandos Dry-Run para Validação Local

Antes de fazer push, utilize os comandos dry-run para validar suas alterações localmente.

### 1. Validar Contratos (Sintaxe YAML)

Valida a estrutura e sintaxe dos contratos sem executar nada no Databricks:

```bash
# Validar todos os contratos
databricks-contracts validate all

# Validar um contrato específico
databricks-contracts validate contract table_name_1

# Via Makefile
make validate-contracts
make validate-contract CONTRACT=table_name_1
```

### 2. Apply Dry-Run (Preview de DDL)

Gera o DDL que seria executado sem aplicar no Databricks:

```bash
# Preview DDL para um contrato (dev)
databricks-contracts apply contract table_name_1 --dry-run --env dev

# Preview DDL para um contrato (prod)
databricks-contracts apply contract table_name_1 --dry-run --env prod

# Via Makefile
make dry-run-contract CONTRACT=table_name_1
```

**Exemplo de output:**
```sql
-- DRY RUN: DDL for table_name_1
CREATE TABLE IF NOT EXISTS seu_catalogo.seu_schema.table_name_1 (
    id BIGINT NOT NULL COMMENT 'Identificador único',
    name STRING COMMENT 'Nome do registro',
    created_at TIMESTAMP COMMENT 'Data de criação'
)
USING DELTA
COMMENT 'Descrição da tabela'
TBLPROPERTIES (
    'data_owner' = 'Time Responsável',
    'refresh_frequency' = 'daily'
);
```

### 3. Trigger Dry-Run (Preview de Jobs)

Mostra quais jobs seriam disparados sem executá-los:

```bash
# Preview de jobs para contratos modificados (baseado no git diff)
databricks-contracts trigger modified --dry-run

# Preview de jobs para todos os contratos
databricks-contracts trigger all --dry-run

# Preview de jobs para contratos específicos
databricks-contracts trigger contracts table_name_1 --dry-run
databricks-contracts trigger contracts table_name_1 table_name_2 --dry-run

# Via Makefile
make trigger-dry           # Contratos modificados
make trigger-all-dry       # Todos os contratos
```

**Exemplo de output:**
```
🔍 DRY RUN - Jobs that would be triggered:

  📋 table_name_1
     Job: seu_catalogo_seu_schema_table_name_1_job
     Reason: Contract modified

  📋 table_name_2
     Job: seu_catalogo_seu_schema_table_name_2_job
     Reason: Contract modified

Total: 2 jobs would be triggered
```

### 4. Publish Dry-Run (Preview de Publicação no Purview)

Mostra o que seria publicado no Purview sem enviar:

```bash
# Preview de publicação para contratos modificados
databricks-contracts publish purview-modified --dry-run --env dev

# Preview de publicação para todos os contratos
databricks-contracts publish purview-all --dry-run --env dev

# Preview de publicação para contratos específicos
databricks-contracts publish purview table_name_1 --dry-run --env dev
databricks-contracts publish purview table_name_1 table_name_2 --dry-run --env dev
```

---

## 🚀 Execução Real (Requer Credenciais)

Para executar os comandos de fato, você precisa das credenciais configuradas:

```bash
# Configurar credenciais (via .env ou export)
export DATABRICKS_HOST="https://your-workspace.databricks.com"
export DATABRICKS_CLIENT_ID="your-client-id"
export DATABRICKS_CLIENT_SECRET="your-client-secret"

# Aplicar contrato
databricks-contracts apply contract table_name_1 --env dev
make apply-contract CONTRACT=table_name_1 ENVIRONMENT=dev

# Disparar jobs
databricks-contracts trigger modified
databricks-contracts trigger all
databricks-contracts trigger contracts table_name_1 table_name_2
make trigger

# Publicar no Purview (requer credenciais Purview)
export PURVIEW_ACCOUNT_NAME="your-purview-account"
export PURVIEW_CLIENT_ID="your-purview-client-id"
export PURVIEW_CLIENT_SECRET="your-purview-secret"
export PURVIEW_TENANT_ID="your-tenant-id"

databricks-contracts publish purview table_name_1 --env dev
databricks-contracts publish purview-modified --env dev
databricks-contracts publish purview-all --env dev
make publish-purview CONTRACT=table_name_1 ENVIRONMENT=dev
```

---

## 📦 Deploy via Bundle

O deploy do bundle também pode ser validado e executado:

```bash
# Validar bundle (requer credenciais)
databricks bundle validate -t dev
make validate-bundle ENVIRONMENT=dev

# Deploy do bundle
databricks bundle deploy -t dev
make deploy ENVIRONMENT=dev
```

---

## 🔄 Fluxo CI/CD

O pipeline é executado automaticamente:

| Branch    | Ambiente | Ações                                      |
|-----------|----------|-------------------------------------------|
| `develop` | dev      | validate → deploy → trigger → publish     |
| `master`  | prod     | validate → deploy → trigger → publish     |

### Passos do Pipeline:

1. **Validate Contracts** - Valida sintaxe YAML dos contratos
2. **Validate Bundle** - Valida configuração do Databricks Bundle
3. **Deploy Bundle** - Faz deploy dos jobs/recursos no Databricks
4. **Trigger Modified** - Dispara jobs dos contratos modificados
5. **Publish to Purview** - Publica metadados no Microsoft Purview

---

## 📚 Comandos Makefile Disponíveis

```bash
make help                    # Lista todos os comandos disponíveis

# Setup
make setup                   # Instala dependências
make install-dev             # Instala dependências de desenvolvimento

# Validação
make validate-contracts                  # Valida todos os contratos
make validate-contract CONTRACT=name     # Valida um contrato específico
make validate-bundle                     # Valida bundle do Databricks

# Apply (DDL)
make dry-run-contract CONTRACT=name      # Preview DDL
make apply-contract CONTRACT=name        # Aplica contrato

# Trigger (Jobs)
make trigger                             # Dispara jobs modificados
make trigger-all                         # Dispara todos os jobs
make trigger-contracts CONTRACTS="a b"   # Dispara jobs específicos
make trigger-dry                         # Dry-run jobs modificados
make trigger-all-dry                     # Dry-run todos os jobs
make trigger-contracts-dry CONTRACTS="a" # Dry-run jobs específicos

# Deploy
make deploy                              # Deploy do bundle

# Purview
make publish-purview CONTRACTS="a b"     # Publica contratos específicos
make publish-purview-modified            # Publica contratos modificados
make publish-purview-all                 # Publica todos os contratos
make publish-purview-dry CONTRACTS="a"   # Dry-run publicação específica
make publish-purview-modified-dry        # Dry-run publicação modificados
make publish-purview-all-dry             # Dry-run publicação todos
```

---

## 🏁 Como Começar

1. **Clone este repositório** como template para seu subdomínio
2. **Customize o `datacontract.config.yaml`** com seu catálogo/schema
3. **Adicione seus contratos** em `data_contracts/assets/`
4. **Valide localmente** usando os comandos dry-run
5. **Configure os secrets** no GitHub Actions
6. **Faça push** e deixe o CI/CD fazer o deploy

### Secrets Necessários no GitHub:

```
# Databricks
DATABRICKS_HOST_DEV
DATABRICKS_HOST_PROD
DATABRICKS_SP_CLIENT_ID_DEV
DATABRICKS_SP_CLIENT_ID_PROD
DATABRICKS_SP_SECRET_DEV
DATABRICKS_SP_SECRET_PROD

# Purview
PURVIEW_ACCOUNT_NAME_DEV
PURVIEW_ACCOUNT_NAME_PROD
PURVIEW_CLIENT_ID_DEV
PURVIEW_CLIENT_ID_PROD
PURVIEW_CLIENT_SECRET_DEV
PURVIEW_CLIENT_SECRET_PROD
PURVIEW_TENANT_ID_DEV
PURVIEW_TENANT_ID_PROD

# GitHub (para dependências privadas)
GH_PAT
```

---

## 📖 Referências

- Veja `templates/contract.minimal.yaml` para o mínimo necessário em um contrato
- Veja `templates/contract.full.yaml` para todas as opções disponíveis
- Veja `data_contracts/assets/` para exemplos completos