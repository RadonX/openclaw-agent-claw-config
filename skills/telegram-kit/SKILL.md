---
name: telegram-kit
description: Telegram Bot API CLI tools. Small, focused utilities for interacting with Telegram bots - token resolution, sending messages, getting chat info. Use when you need to validate bot permissions, send probe messages, or query chat metadata.
---

# Telegram Kit

A collection of small, focused CLI tools for Telegram Bot API operations.

> **Philosophy**: Do one thing well. Composable. No magic.

## Tools

| Tool | Purpose |
|------|---------|
| `bin/tg-topic-ping` | Send probe messages to forum topics |
| `bin/tg-get-chat` | Get chat info (id, title, type) |

## Shared Library

`lib/telegram.mjs` provides:
- `resolveToken()` — Multi-source token resolution (env, .env, OpenClaw config)
- `sendMessage()` — Send message to chat/topic
- `getChat()` — Get chat metadata

## Quick Reference

### tg-topic-ping

Validate bot can post to specific forum topics:

```bash
# Using env token
TG_TOKEN=xxx ./bin/tg-topic-ping --chat -100XXXXXXXXXX --topics 66,80 --text "/status"

# Using OpenClaw account
./bin/tg-topic-ping --account platinum --chat -100XXXXXXXXXX --topics 66,80 --text "ping" --silent
```

Options:
- `--chat <id>` — Supergroup chat_id (required)
- `--topics <ids>` — Comma-separated topic ids (required)
- `--text <msg>` — Message body (required)
- `--account <id>` — Load token from OpenClaw config
- `--token <token>` — Explicit token
- `--silent` — No notification
- `--delay-ms <n>` — Delay between topics (default: 350)

### tg-get-chat

Query chat metadata:

```bash
./bin/tg-get-chat --account platinum --chat -100XXXXXXXXXX
./bin/tg-get-chat --account platinum --chat -100XXXXXXXXXX --json
```

## Token Resolution

Tools resolve tokens in this order:
1. `--token <token>` explicit arg
2. `TG_TOKEN` or `TELEGRAM_BOT_TOKEN` env var
3. `.env` file in current directory
4. OpenClaw config (`~/.openclaw/openclaw.json`) via `--account <id>`

## Exit Codes

- `0` — Success
- `1` — Operation failed (API error)
- `2` — Invalid args or missing token
