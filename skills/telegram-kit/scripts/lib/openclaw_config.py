from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any, Dict


def load_openclaw_config() -> Dict[str, Any]:
    path = Path.home() / ".openclaw" / "openclaw.json"
    if not path.exists():
        sys.exit(f"Missing OpenClaw config: {path}")
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception as e:
        sys.exit(f"Failed to parse {path}: {e}")


def resolve_bot_token(account_id: str) -> str:
    cfg = load_openclaw_config()
    try:
        token = cfg["channels"]["telegram"]["accounts"][account_id]["botToken"]
    except Exception:
        sys.exit(f"Cannot find channels.telegram.accounts.{account_id}.botToken in ~/.openclaw/openclaw.json")
    if not token or not isinstance(token, str):
        sys.exit(f"Invalid botToken for accountId={account_id}")
    return token
