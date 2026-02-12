# Bot API (lower-risk): `telegram-kit bot …`

This mode uses Telegram **Bot API**.

## Token source

Bot token is resolved from `~/.openclaw/openclaw.json` using `--account <accountId>`.

## Commands

### Create topics

```bash
uv run scripts/tg_bot.py create-topics \
  --account <account_id> \
  --chat -100... \
  --names "Decision,Maxim,Pipeline"
```

Outputs:
- `topic=Decision message_thread_id=6`

### Send message to a topic

```bash
uv run scripts/tg_bot.py send \
  --account <account_id> \
  --chat -100... \
  --topic 6 \
  --text "Hello" \
  --silent  # optional: no notification
```

### Ping topics (validate bot permissions)

Send probe messages to multiple topics at once:

```bash
uv run scripts/tg_bot.py ping-topics \
  --account <account_id> \
  --chat -100... \
  --topics 66,80,97,145 \
  --text "/status" \
  --silent
```

Outputs:
- `[OK] topic=66 message_id=123`
- `[FAIL] topic=80 <error>`

Options:
- `--delay-ms <n>`: delay between topics (default: 350)

### Get chat info

```bash
uv run scripts/tg_bot.py get-chat \
  --account <account_id> \
  --chat -100...

# JSON output
uv run scripts/tg_bot.py get-chat \
  --account <account_id> \
  --chat -100... \
  --json
```

Outputs:
- `id: -100...`
- `type: supergroup`
- `title: Group Name`
- `is_forum: true`

## Prereqs

- The bot must be a member and admin of the group (at least `manage_topics` / `post_messages`).
