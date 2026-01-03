"""
Contract jobs generator - Creates Databricks jobs from contract files.

Uses the official databricks-bundles package to define jobs programmatically.
Each contract in data_contracts/assets/ gets its own job.

Reference: https://docs.databricks.com/aws/en/dev-tools/bundles/python/
"""

from pathlib import Path

from databricks.bundles.core import Bundle
from databricks.bundles.jobs import Job

# Path to contracts relative to bundle root
CONTRACTS_PATH = Path("data_contracts/assets")


def get_contract_names() -> list[str]:
    """Get list of contract names from YAML files."""
    if not CONTRACTS_PATH.exists():
        return []

    return [path.stem for path in CONTRACTS_PATH.glob("*.yaml") if not path.name.startswith("_")]


def create_job_for_contract(contract_name: str, bundle: Bundle) -> Job:
    """
    Create a Databricks job for a single contract.

    Args:
        contract_name: Name of the contract (without .yaml extension).
        bundle: Bundle context for accessing variables and target.

    Returns:
        Job configuration for the contract.
    """
    return Job.from_dict(
        {
            "name": f"Apply Contract - {contract_name}",
            "description": f"Applies data contract '{contract_name}' to Unity Catalog",
            "tasks": [
                {
                    "task_key": "apply_contract",
                    "spark_python_task": {
                        "python_file": "scripts/apply_contract.py",
                        "parameters": [
                            "apply",
                            "contract",
                            contract_name,
                            "--env",
                            "${bundle.target}",
                        ],
                    },
                    "new_cluster": {
                        "spark_version": "14.3.x-scala2.12",
                        "num_workers": 0,
                        "node_type_id": "Standard_DS3_v2",
                        "spark_conf": {
                            "spark.databricks.cluster.profile": "singleNode",
                            "spark.master": "local[*]",
                        },
                        "spark_env_vars": {
                            "DATABRICKS_HOST": "${workspace.host}",
                        },
                        "custom_tags": {
                            "ResourceClass": "SingleNode",
                        },
                    },
                }
            ],
            "tags": {
                "contract": contract_name,
                "managed_by": "databricks-contracts",
            },
        }
    )


def create_contract_jobs(bundle: Bundle) -> dict[str, Job]:
    """
    Create jobs for all contracts.

    Args:
        bundle: Bundle context.

    Returns:
        Dictionary mapping job keys to Job objects.
    """
    jobs = {}

    for contract_name in get_contract_names():
        # Job key must be valid Python identifier (no hyphens)
        job_key = f"apply_{contract_name}".replace("-", "_")
        jobs[job_key] = create_job_for_contract(contract_name, bundle)

    return jobs
