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

## Configuration

### Bot API Token (`openclaw.json`)

Bot API operations require a bot token. The scripts resolve this from `~/.openclaw/openclaw.json` using the `--account <account_id>` argument.

### User API Credentials (`~/.openclaw/.env`)

MTProto user API operations (`tg_user.py`) require credentials for a real Telegram user account. Create a file at `~/.openclaw/.env` with the following:

```dotenv
# Get from my.telegram.org -> API development tools
TG_API_ID=12345678
TG_API_HASH=0123456789abcdef0123456789abcdef

# Your phone number in international format
TG_PHONE=+14155552671
```

**Note:** The first time you run `tg_user.py`, Telethon will prompt for a login code and 2FA password in the terminal. It will create a `.session` file to stay logged in.

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
