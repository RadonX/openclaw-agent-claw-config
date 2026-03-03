# MTProto user API (high-risk): `telegram-kit user …`

This mode uses a **real Telegram user account** via Telethon.

## Never do

- Do not run in cron.
- Do not run unattended.
- Do not store `.env` or sessions inside this repo.

## Credentials

Read from `~/.openclaw/.env`:

- `TG_API_ID`
- `TG_API_HASH`
- `TG_PHONE`
- optional `TG_2FA_PASSWORD`

## Commands

### Create a supergroup (optionally enable forum)

```bash
uv run scripts/tg_user.py create-group \
  --title "Pensieve · Loop Lab" \
  --about "Decision / Maxim / Pipeline" \
  --forum
```

Outputs:
- `chat_id=-100…`

### Invite a bot

```bash
uv run scripts/tg_user.py invite-bot --chat -100... --bot @Claw3PObot
```

### Promote bot to admin (recommended)

```bash
uv run scripts/tg_user.py promote-bot --chat -100... --bot @Claw3PObot
```

### Send message as user (to trigger bot commands)

Send a message to forum topics as a user. Useful for triggering bot commands like `/status`:

```bash
# Send to multiple topics
uv run scripts/tg_user.py send \
  --chat -100... \
  --topics 66,80,97 \
  --text "/status" \
  --mention @Claw3PObot

# Send to main chat (no topic)
uv run scripts/tg_user.py send \
  --chat -100... \
  --text "Hello"
```

Options:
- `--topics`: comma-separated topic ids (optional)
- `--mention`: @BotUsername to prefix (optional)
- `--delay-ms`: delay between topics (default: 350)

## Notes

- Forum enable requires Telethon API that currently needs `tabs` param; the script handles this.
- If you see “attempt was blocked”, cool down and confirm via Telegram security prompts.
