#!/usr/bin/env python3
"""tg_user.py - High-risk MTProto user-account automation (Telethon).

DANGER
- Logs in as a REAL Telegram user account.
- Never run unattended / cron.
- Session files are secrets.

Design intent (Linus-style): small subcommands, explicit behavior.
"""

from __future__ import annotations

import argparse
import asyncio
import sys
from pathlib import Path

from lib.telethon_client import connect_client, ensure_login


def bot_api_chat_id(internal_id: int) -> int:
    return -1000000000000 - int(internal_id)


async def cmd_create_group(args: argparse.Namespace) -> int:
    from telethon.tl.functions.channels import CreateChannelRequest, ToggleForumRequest

    session = args.session
    client, phone, password = connect_client(session_path=session)
    async with client:
        await ensure_login(client, phone, password)

        print(f"Creating supergroup: {args.title}")
        res = await client(CreateChannelRequest(title=args.title, about=args.about, megagroup=True))
        chat = res.chats[0]
        chat_id = bot_api_chat_id(chat.id)

        print("created ok=true")
        print(f"chat_id={chat_id}")

        if args.forum:
            try:
                # Telethon 1.42+ ToggleForumRequest signature: (channel, enabled, tabs)
                await client(ToggleForumRequest(channel=chat, enabled=True, tabs=False))
                print("forum_enabled ok=true")
            except Exception as e:
                print(f"forum_enabled ok=false error={type(e).__name__}:{e}")

    return 0


async def cmd_invite_bot(args: argparse.Namespace) -> int:
    from telethon.tl.functions.channels import InviteToChannelRequest
    from telethon.errors.rpcerrorlist import UserAlreadyParticipantError

    client, phone, password = connect_client(session_path=args.session)
    async with client:
        await ensure_login(client, phone, password)

        chat = await client.get_entity(int(args.chat))
        bot = await client.get_entity(args.bot)
        try:
            await client(InviteToChannelRequest(channel=chat, users=[bot]))
            print(f"invite ok=true bot={args.bot}")
        except UserAlreadyParticipantError:
            print(f"invite ok=true bot={args.bot} already=true")

    return 0


async def cmd_promote_bot(args: argparse.Namespace) -> int:
    from telethon.tl.functions.channels import EditAdminRequest
    from telethon.tl.types import ChatAdminRights

    client, phone, password = connect_client(session_path=args.session)
    async with client:
        await ensure_login(client, phone, password)

        chat = await client.get_entity(int(args.chat))
        bot = await client.get_entity(args.bot)

        # Minimal-but-useful admin rights for provisioning forum groups.
        rights = ChatAdminRights(
            change_info=True,
            post_messages=True,
            edit_messages=True,
            delete_messages=True,
            ban_users=True,
            invite_users=True,
            pin_messages=True,
            add_admins=False,
            anonymous=False,
            manage_call=True,
            other=True,
            manage_topics=True,
        )

        await client(EditAdminRequest(channel=chat, user_id=bot, admin_rights=rights, rank=args.rank))
        print(f"admin_promoted bot={args.bot} ok=true")

    return 0


async def cmd_send(args: argparse.Namespace) -> int:
    """Send message to forum topics as a user (to trigger bot commands)."""
    from telethon.tl import functions
    from telethon.tl.types import InputPeerChannel
    import time

    client, phone, password = connect_client(session_path=args.session)
    async with client:
        await ensure_login(client, phone, password)

        chat_id = int(args.chat)
        entity = await client.get_entity(chat_id)

        # Build message text
        msg_text = f"{args.mention} {args.text}" if args.mention else args.text

        # If no topic specified, send to main chat
        if not args.topics:
            sent = await client.send_message(entity, msg_text)
            print(f"[OK] chat={chat_id} sent_message_id={sent.id}")
            return 0

        # Parse topics
        topics = [int(t.strip()) for t in args.topics.split(",") if t.strip()]

        # Get InputPeerChannel for forum topics request
        peer = await client.get_input_entity(entity)
        if not isinstance(peer, InputPeerChannel):
            raise RuntimeError("Target chat is not a channel/supergroup")

        # Fetch forum topics to get top_message ids
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
            topic_to_top[int(t.id)] = int(t.top_message)

        missing = [t for t in topics if t not in topic_to_top]
        if missing:
            print(f"[WARN] Could not find top_message for topics: {missing}")

        failed = 0
        for idx, topic_id in enumerate(topics):
            top_msg = topic_to_top.get(topic_id)
            if not top_msg:
                print(f"[SKIP] topic={topic_id} (no top_message found)")
                failed += 1
            else:
                try:
                    sent = await client.send_message(entity, msg_text, reply_to=top_msg)
                    print(f"[OK] topic={topic_id} sent_message_id={sent.id}")
                except Exception as e:
                    print(f"[FAIL] topic={topic_id} {type(e).__name__}: {e}")
                    failed += 1

            if idx < len(topics) - 1:
                time.sleep(args.delay_ms / 1000)

        return 1 if failed else 0


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(prog="tg_user.py", description="High-risk MTProto user automation (Telethon).")
    p.add_argument(
        "--session",
        default=str(Path(__file__).with_suffix(".session")),
        help="Session file path (keep it private).",
    )

    sub = p.add_subparsers(dest="cmd", required=True)

    p_c = sub.add_parser("create-group", help="Create a supergroup (optionally enable forum)")
    p_c.add_argument("--title", required=True)
    p_c.add_argument("--about", default="")
    p_c.add_argument("--forum", action="store_true")
    p_c.set_defaults(fn=cmd_create_group)

    p_i = sub.add_parser("invite-bot", help="Invite a bot to the group")
    p_i.add_argument("--chat", required=True, help="-100… chat_id")
    p_i.add_argument("--bot", required=True, help="@BotUsername")
    p_i.set_defaults(fn=cmd_invite_bot)

    p_p = sub.add_parser("promote-bot", help="Promote bot to admin")
    p_p.add_argument("--chat", required=True, help="-100… chat_id")
    p_p.add_argument("--bot", required=True, help="@BotUsername")
    p_p.add_argument("--rank", default="bot")
    p_p.set_defaults(fn=cmd_promote_bot)

    p_s = sub.add_parser("send", help="Send message as user (to trigger bot commands)")
    p_s.add_argument("--chat", required=True, help="-100… chat_id")
    p_s.add_argument("--topics", default="", help="Comma-separated topic ids (optional)")
    p_s.add_argument("--text", required=True, help="Message text")
    p_s.add_argument("--mention", default="", help="@BotUsername to mention (optional)")
    p_s.add_argument("--delay-ms", type=int, default=350, help="Delay between topics")
    p_s.set_defaults(fn=cmd_send)

    return p


def main() -> int:
    args = build_parser().parse_args()
    try:
        return asyncio.run(args.fn(args))
    except RuntimeError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
