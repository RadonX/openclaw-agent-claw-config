# telegram-kit

A small, Linus-style Telegram provisioning toolkit for OpenClaw.

It is intentionally split into **two surfaces**:

- **`user` (MTProto / Telethon)**: high-risk operations using a *real Telegram user account*.
- **`bot` (Bot API)**: lower-risk operations using a bot token.

## Safety model (read this first)

- Do **not** run MTProto user operations unattended or in cron.
- Do **not** store secrets in this repo. Credentials live in:
  - `~/.openclaw/.env` (Telethon user creds)
  - `~/.openclaw/openclaw.json` (bot token, resolved by `accountId`)

## Requirements

- `uv`
- Python (uv will manage an isolated venv)

## Quick start

From this directory:

```bash
uv run scripts/tg_bot.py --help
uv run scripts/tg_user.py --help
```

### Create topics (Bot API)

```bash
uv run scripts/tg_bot.py create-topics \
  --account <account_id> \
  --chat -100... \
  --names "Decision,Maxim,Pipeline"
```

### Create a forum supergroup (MTProto user API)

```bash
uv run scripts/tg_user.py create-group \
  --title "Pensieve · Loop Lab" \
  --about "Decision / Maxim / Pipeline" \
  --forum
```

## Docs

- Skill router: `SKILL.md`
- Detailed references: `references/`
  - `PRINCIPLES.md` (design + safety)
  - `FLOWS.md` (end-to-end)
  - `TROUBLESHOOT.md`
