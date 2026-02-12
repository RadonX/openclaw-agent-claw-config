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
from lib.bot_api import create_forum_topic, send_message, get_chat


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
    res = send_message(
        token=token,
        chat_id=args.chat,
        text=args.text,
        message_thread_id=args.topic,
        disable_notification=args.silent,
    )
    mid = res.get("message_id")
    print(f"sent ok=true message_id={mid}")
    return 0


def cmd_ping_topics(args: argparse.Namespace) -> int:
    """Send probe messages to multiple topics to validate bot permissions."""
    import time
    token = resolve_bot_token(args.account)
    topics = [int(t.strip()) for t in args.topics.split(",") if t.strip()]
    if not topics:
        raise SystemExit("--topics must be a comma-separated list of topic ids")

    failed = 0
    for i, tid in enumerate(topics):
        try:
            res = send_message(
                token=token,
                chat_id=args.chat,
                text=args.text,
                message_thread_id=tid,
                disable_notification=args.silent,
            )
            mid = res.get("message_id")
            print(f"[OK] topic={tid} message_id={mid}")
        except RuntimeError as e:
            print(f"[FAIL] topic={tid} {e}")
            failed += 1

        if i < len(topics) - 1:
            time.sleep(args.delay_ms / 1000.0)

    return 1 if failed else 0


def cmd_get_chat(args: argparse.Namespace) -> int:
    """Get chat info."""
    import json as json_mod
    token = resolve_bot_token(args.account)
    try:
        res = get_chat(token=token, chat_id=args.chat)
        if args.json:
            print(json_mod.dumps(res, indent=2, ensure_ascii=False))
        else:
            print(f"id: {res.get('id')}")
            print(f"type: {res.get('type')}")
            print(f"title: {res.get('title', '(none)')}")
            if res.get("username"):
                print(f"username: @{res['username']}")
            if res.get("is_forum"):
                print("is_forum: true")
        return 0
    except RuntimeError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1


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
    p_send.add_argument("--silent", action="store_true", help="Send without notification")
    p_send.set_defaults(fn=cmd_send)

    p_ping = sub.add_parser("ping-topics", help="Send probe messages to multiple topics")
    p_ping.add_argument("--account", required=True)
    p_ping.add_argument("--chat", required=True)
    p_ping.add_argument("--topics", required=True, help="Comma-separated topic ids (e.g. 66,80,97)")
    p_ping.add_argument("--text", required=True)
    p_ping.add_argument("--silent", action="store_true", help="Send without notification")
    p_ping.add_argument("--delay-ms", type=int, default=350, help="Delay between topics (default: 350)")
    p_ping.set_defaults(fn=cmd_ping_topics)

    p_chat = sub.add_parser("get-chat", help="Get chat info")
    p_chat.add_argument("--account", required=True)
    p_chat.add_argument("--chat", required=True)
    p_chat.add_argument("--json", action="store_true", help="Output raw JSON")
    p_chat.set_defaults(fn=cmd_get_chat)

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
