# Bot API (lower-risk): `telegram-kit bot …`

This mode uses Telegram **Bot API**.

## Token source

Bot token is resolved from `~/.openclaw/openclaw.json` using `--account <accountId>`.

## Commands

### Create topics

```bash
python3 skills/telegram-kit/scripts/tg_bot.py create-topics \
  --account claw_3po \
  --chat -100... \
  --names "Decision,Maxim,Pipeline"
```

Outputs:
- `topic=Decision message_thread_id=6`

### Send message to a topic

```bash
python3 skills/telegram-kit/scripts/tg_bot.py send \
  --account claw_3po \
  --chat -100... \
  --topic 6 \
  --text "Hello"
```

## Prereqs

- The bot must be a member and admin of the group (at least `manage_topics` / `post_messages`).
