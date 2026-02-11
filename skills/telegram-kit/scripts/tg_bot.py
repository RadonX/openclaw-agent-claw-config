#!/usr/bin/env python3
"""tg_bot.py - Telegram Bot API utilities (lower-risk).

- Token source: ~/.openclaw/openclaw.json (by accountId)
- Implementation: stdlib urllib (no requests dependency)

Output contract (stable lines):
- topic=<name> message_thread_id=<id>
"""

from __future__ import annotations

import argparse
import sys

from lib.openclaw_config import resolve_bot_token
from lib.bot_api import create_forum_topic, send_message


def cmd_create_topics(args: argparse.Namespace) -> int:
    token = resolve_bot_token(args.account)
    names = [s.strip() for s in args.names.split(",") if s.strip()]
    if not names:
        raise SystemExit("--names must be a comma-separated list")

    for name in names:
        res = create_forum_topic(token=token, chat_id=args.chat, name=name)
        tid = res.get("message_thread_id")
        print(f"topic={name} message_thread_id={tid}")
    return 0


def cmd_send(args: argparse.Namespace) -> int:
    token = resolve_bot_token(args.account)
    res = send_message(token=token, chat_id=args.chat, text=args.text, message_thread_id=args.topic)
    mid = res.get("message_id")
    print(f"sent ok=true message_id={mid}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(prog="tg_bot.py", description="Telegram Bot API utilities (lower-risk).")
    sub = p.add_subparsers(dest="cmd", required=True)

    p_topics = sub.add_parser("create-topics", help="Create forum topics")
    p_topics.add_argument("--account", required=True, help="OpenClaw telegram accountId (to resolve botToken)")
    p_topics.add_argument("--chat", required=True, help="Target supergroup chat_id (e.g., -100...)")
    p_topics.add_argument("--names", required=True, help='Comma-separated topic names (e.g. "Decision,Maxim,Pipeline")')
    p_topics.set_defaults(fn=cmd_create_topics)

    p_send = sub.add_parser("send", help="Send a message (optionally to a topic)")
    p_send.add_argument("--account", required=True)
    p_send.add_argument("--chat", required=True)
    p_send.add_argument("--topic", type=int, default=None, help="message_thread_id")
    p_send.add_argument("--text", required=True)
    p_send.set_defaults(fn=cmd_send)

    return p


def main() -> int:
    args = build_parser().parse_args()
    try:
        return int(args.fn(args))
    except RuntimeError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
