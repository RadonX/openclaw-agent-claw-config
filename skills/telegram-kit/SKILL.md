---
name: telegram-kit
description: >-
  Telegram group/forum provisioning and management. USE WHEN: inviting bots to
  a group, promoting bots to admin, creating groups/forums, creating topics,
  sending messages as user or bot, checking bot permissions. DON'T use raw
  curl/Telegram API for these — this skill wraps safe Telethon (user) and Bot
  API (bot) scripts. Also use when: you need to add/remove/manage members in a
  Telegram group where you have admin rights. Triggers on: invite bot, add bot
  to group, promote bot, create topic, telegram group setup, forum setup.
  Safety: user API (MTProto) = high-risk, bot API = low-risk, never mix.
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
