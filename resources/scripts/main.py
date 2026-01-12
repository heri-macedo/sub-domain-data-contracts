#!/usr/bin/env python
"""
Entry point for Databricks jobs to apply data contracts.

This script is executed by Databricks jobs created via DAB.
It wraps the CLI entry point from the installed databricks-contracts library.

Usage (from Databricks job):
    python resources/scripts/main.py apply contract <name> --env <env>
"""

import sys

from databricks_contracts.commands.main import app

if __name__ == "__main__":
    try:
        app()
    except SystemExit as e:
        # Typer/Click raises SystemExit(0) on success
        # Only re-raise if it's an actual error (non-zero exit code)
        if e.code != 0:
            sys.exit(e.code)
