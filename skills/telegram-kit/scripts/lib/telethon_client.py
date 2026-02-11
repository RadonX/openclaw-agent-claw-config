from __future__ import annotations

import sys
from pathlib import Path
from typing import Dict

from .env import load_openclaw_env


def connect_client(*, session_path: str) -> "TelegramClient":
    """Connect and authorize Telethon client.

    Interactive login may prompt for code / 2FA.
    """
    try:
        from telethon import TelegramClient
    except ImportError:
        sys.exit("Error: telethon is not installed. Install it in the venv that runs this script.")

    env: Dict[str, str] = load_openclaw_env()
    api_id = env.get("TG_API_ID")
    api_hash = env.get("TG_API_HASH")
    phone = env.get("TG_PHONE")
    password = env.get("TG_2FA_PASSWORD")

    if not all([api_id, api_hash, phone]):
        sys.exit("Missing TG_API_ID, TG_API_HASH, or TG_PHONE in ~/.openclaw/.env")

    client = TelegramClient(session_path, int(str(api_id).strip()), str(api_hash).strip())
    return client, str(phone).strip(), password


async def ensure_login(client, phone: str, password: str | None):
    await client.connect()
    if not await client.is_user_authorized():
        print("First-time login or session expired. Please follow the prompts.", file=sys.stderr)
        try:
            await client.start(phone=lambda: phone, password=lambda: password)
        except Exception as e:
            await client.disconnect()
            raise RuntimeError(f"Login failed: {e}")
