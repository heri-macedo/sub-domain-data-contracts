#!/usr/bin/env python
"""
Wrapper script to run databricks-contracts CLI from Databricks job.

This script is executed by Databricks jobs to apply data contracts.
It wraps the CLI entry point from the installed databricks-contracts library.

Usage (from Databricks job):
    python scripts/apply_contract.py apply contract <name> --env <env>
"""

import sys

from databricks_contracts.cli.main import app

if __name__ == "__main__":
    sys.exit(app())
