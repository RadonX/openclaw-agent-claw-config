---
name: telegram-kit
description: Telegram provisioning toolkit that unifies a safe, Linus-style workflow for forum supergroups: (A) MTProto *user* API (high-risk) to create groups, enable forum, invite/promote bots; (B) Telegram Bot API (low-risk) to create forum topics and send messages. Use when setting up a new Telegram supergroup/forum for an OpenClaw agent, or when you need to create topics / verify/manage bot permissions. Strictly separate user vs bot operations.
---

# telegram-kit

## Safety invariants (do not violate)

- **Hard split:** `user` = MTProto human account (high-risk). `bot` = Bot API token (lower-risk). Never mix.
- **User API rules:** never run unattended; never schedule; expect login/2FA/code prompts; minimize write actions.
- **Secrets:** do not store credentials inside this skill. Read from `~/.openclaw/.env` and `~/.openclaw/openclaw.json` only.

## Interface (CLI-like subcommands)

- `telegram-kit user …` → read `references/USER.md`
- `telegram-kit bot  …` → read `references/BOT.md`
- End-to-end flow → read `references/FLOWS.md`
- Failures / gotchas → read `references/TROUBLESHOOT.md`

## Implementation notes

- Scripts live in `scripts/`:
  - MTProto (Telethon): `scripts/tg_user.py`
  - Bot API (stdlib urllib): `scripts/tg_bot.py`

When executing scripts, run them directly (do not copy/paste code into chat).
