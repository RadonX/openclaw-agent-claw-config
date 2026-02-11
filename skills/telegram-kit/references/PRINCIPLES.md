# telegram-kit principles

## Linus-style design goals

- **Small, sharp tools.** Prefer subcommands over mode flags. One command does one thing.
- **Predictable behavior.** Explicit inputs; bounded scans; stable output lines suitable for parsing.
- **Make the dangerous path explicit.** User API is opt-in via `user` subcommands.

## Security: user API vs bot API

### MTProto user API (`telegram-kit user …`)

- Uses a **real Telegram user account** (Telethon). Treat session files as passwords.
- Never run in cron / unattended.
- Expect Telegram risk controls (blocked attempts) when retrying codes.

### Bot API (`telegram-kit bot …`)

- Uses a **bot token** (from `~/.openclaw/openclaw.json`).
- Safe for automation, but still requires bot admin rights in target chat.

## Secrets and configuration

- **Telethon creds:** read from `~/.openclaw/.env`:
  - `TG_API_ID`, `TG_API_HASH`, `TG_PHONE`, optional `TG_2FA_PASSWORD`
- **Bot token:** read from `~/.openclaw/openclaw.json` via `accountId`.
- Never write secrets into the repo.

## Output contract (important)

Print machine-friendly lines for key artifacts:

- `chat_id=-100…`
- `topic=<name> message_thread_id=<id>`
- `admin_promoted bot=@… ok=true`

This enables future workflow skills to orchestrate steps without merging implementations.
