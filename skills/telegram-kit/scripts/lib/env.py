from __future__ import annotations

import os
import sys
from pathlib import Path


def load_openclaw_env() -> dict:
    """Load ~/.openclaw/.env (dotenv format) with process env override.

    Intentionally does NOT support skill-local .env files.
    """
    try:
        from dotenv import dotenv_values
    except ImportError:
        sys.exit("Error: python-dotenv is not installed. Install it in the venv that runs this script.")

    env_path = Path.home() / ".openclaw" / ".env"
    if not env_path.exists():
        sys.exit(f"Missing env file: {env_path}")

    vals = dotenv_values(env_path)
    return {**vals, **os.environ}
