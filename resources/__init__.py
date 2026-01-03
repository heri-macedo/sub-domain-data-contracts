"""
Bundle resources loader - Dynamically creates Databricks jobs from contracts.

This module is called by Databricks CLI during bundle deployment.
It loads all contracts and creates one job per contract.

Reference: https://docs.databricks.com/aws/en/dev-tools/bundles/python/
"""

from databricks.bundles.core import Bundle, Resources

from resources.contract_jobs import create_contract_jobs


def load_resources(bundle: Bundle) -> Resources:
    """
    Load resources function referenced in databricks.yml.

    Creates Databricks jobs dynamically based on contract files.
    This function is called by Databricks CLI during bundle deployment.
    After deployment, this function is not used.

    Args:
        bundle: Bundle context with variables and target info.

    Returns:
        Resources containing all generated jobs.
    """
    resources = Resources()

    # Create jobs for all contracts
    contract_jobs = create_contract_jobs(bundle)

    for job_key, job in contract_jobs.items():
        resources.add_resource(job_key, job)

    return resources
