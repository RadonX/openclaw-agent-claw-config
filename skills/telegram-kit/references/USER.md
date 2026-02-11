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
python3 skills/telegram-kit/scripts/tg_user.py create-group \
  --title "Pensieve · Loop Lab" \
  --about "Decision / Maxim / Pipeline" \
  --forum
```

Outputs:
- `chat_id=-100…`

### Invite a bot

```bash
python3 skills/telegram-kit/scripts/tg_user.py invite-bot --chat -100... --bot @Claw3PObot
```

### Promote bot to admin (recommended)

```bash
python3 skills/telegram-kit/scripts/tg_user.py promote-bot --chat -100... --bot @Claw3PObot
```

## Notes

- Forum enable requires Telethon API that currently needs `tabs` param; the script handles this.
- If you see “attempt was blocked”, cool down and confirm via Telegram security prompts.
