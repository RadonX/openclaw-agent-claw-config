#!/usr/bin/env python3
"""tg_user_topic_trigger.py

DANGER / IMPORTANT
-----------------
This tool logs in as a REAL Telegram *user* account (your main account) via MTProto
and sends messages into forum topics to trigger a bot (e.g. /status).

Because it uses a human account session, it is higher-risk than bot-token tools:
- Do NOT put this into cron / scheduled jobs.
- Do NOT run unattended.
- Keep the session file private (it is equivalent to a login).
- Prefer a dedicated test account if possible.

Why this exists
--------------
Telegram Bot API cannot "fake inbound updates" to trigger OpenClaw commands.
To trigger OpenClaw's /status in a Telegram forum topic automatically, we must
send a real user message in that topic (MTProto client).

Env
---
We load credentials from ~/.openclaw/.env (NOT printed):
- TG_API_ID
- TG_API_HASH
- TG_PHONE
- (optional) TG_2FA_PASSWORD

Usage
-----
cd tools
uv run tg_user_topic_trigger.py \
  --chat -1001234567890 \
  --topics 66,80,97,145 \
  --bot @rero_rero_bot \
  --text "/status" \
  --mention

Notes
-----
- For forum topics, Telethon needs the *message_thread_id* for posting. We do this
  by replying to the topic's root message (top message of the thread). We fetch it
  with GetForumTopicsRequest and use its `top_message`.
- Some topics may be hidden/archived; you may need to unarchive / make visible.
"""

import argparse
import asyncio
import os
from pathlib import Path

from dotenv import dotenv_values
from telethon import TelegramClient
from telethon.tl import functions
from telethon.tl.types import InputPeerChannel


def parse_topics(raw: str) -> list[int]:
    out: list[int] = []
    for s in raw.split(","):
        s = s.strip()
        if not s:
            continue
        out.append(int(s))
    if not out:
        raise ValueError("--topics must include at least one id")
    return out


def load_openclaw_env() -> dict:
    env_path = Path.home() / ".openclaw" / ".env"
    if not env_path.exists():
        raise SystemExit(f"Missing env file: {env_path}")
    vals = dotenv_values(env_path)
    # Also allow process env to override
    merged = {**vals, **os.environ}
    return merged


async def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--chat", required=True, help="Target supergroup chat_id, e.g. -100...")
    ap.add_argument("--topics", required=True, help="Comma-separated forum topic ids (message_thread_id)")
    ap.add_argument("--bot", required=True, help="Bot username to mention, e.g. @rero_rero_bot")
    ap.add_argument("--text", required=True, help="Command to send, e.g. /status")
    ap.add_argument("--mention", action="store_true", help="Prefix message with @bot")
    ap.add_argument("--delay-ms", type=int, default=350)
    ap.add_argument("--session", default=str(Path(__file__).with_suffix(".session")), help="Session file path")

    args = ap.parse_args()

    env = load_openclaw_env()

    api_id = env.get("TG_API_ID")
    api_hash = env.get("TG_API_HASH")
    phone = env.get("TG_PHONE")
    password = env.get("TG_2FA_PASSWORD")

    if not api_id or not api_hash or not phone:
        raise SystemExit("Missing TG_API_ID/TG_API_HASH/TG_PHONE in ~/.openclaw/.env")

    api_id_i = int(str(api_id).strip())
    api_hash_s = str(api_hash).strip()
    phone_s = str(phone).strip()

    session_path = args.session
    client = TelegramClient(session_path, api_id_i, api_hash_s)

    await client.connect()
    if not await client.is_user_authorized():
        # Interactive login (may prompt).
        # For safety: do not echo secrets; Telethon handles code/password prompts.
        await client.start(phone=phone_s, password=password)

    chat_id = int(args.chat)
    topics = parse_topics(args.topics)

    # Resolve entity (supergroup/channel)
    entity = await client.get_entity(chat_id)

    # We need an InputPeerChannel for GetForumTopicsRequest
    if not isinstance(entity, InputPeerChannel):
        peer = await client.get_input_entity(entity)
        if not isinstance(peer, InputPeerChannel):
            raise SystemExit("Target chat is not a channel/supergroup InputPeerChannel")
    else:
        peer = entity

    # Fetch forum topics list (batch); we'll map topic_id -> top_message id.
    # NOTE: offset_* are for pagination. We'll just fetch a reasonable chunk.
    res = await client(
        functions.messages.GetForumTopicsRequest(
            peer=peer,
            offset_date=0,
            offset_id=0,
            offset_topic=0,
            limit=200,
            q="",
        )
    )

    topic_to_top: dict[int, int] = {}
    for t in res.topics:
        # t.id is the forum topic id, t.top_message is the message id to reply to.
        topic_to_top[int(t.id)] = int(t.top_message)

    missing = [t for t in topics if t not in topic_to_top]
    if missing:
        # Not fatal: topic might be older than first page or hidden/archived.
        print(f"[WARN] Could not find top_message for topics: {missing} (maybe archived/older than limit)")

    msg_text = (f"{args.bot} {args.text}" if args.mention else args.text)

    for idx, topic_id in enumerate(topics):
        top_msg = topic_to_top.get(topic_id)
        if not top_msg:
            print(f"[SKIP] topic={topic_id} (no top_message found)")
        else:
            try:
                sent = await client.send_message(entity, msg_text, reply_to=top_msg)
                print(f"[OK] topic={topic_id} sent_message_id={sent.id}")
            except Exception as e:
                print(f"[FAIL] topic={topic_id} {type(e).__name__}: {e}")

        if idx < len(topics) - 1:
            await asyncio.sleep(args.delay_ms / 1000)

    await client.disconnect()


if __name__ == "__main__":
    asyncio.run(main())
