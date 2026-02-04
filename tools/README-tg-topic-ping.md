# tg-topic-ping

Send a probe message to one or more **Telegram forum topics** (aka `message_thread_id`) directly via the Telegram Bot API.

This is useful when you **switched routing/bindings** and want to validate that a bot can post in specific topics **without needing any inbound message/session**.

## Usage

```bash
# Option 1) token via env (recommended)
export TG_TOKEN='***'

./tg-topic-ping.mjs \
  --chat -1001234567890 \
  --topics 66,80,97,145 \
  --text "/status" \
  --silent

# Option 2) token via .env in this directory
cp .env.example .env
$EDITOR .env   # set TG_TOKEN=...
./tg-topic-ping.mjs --chat -1001234567890 --topics 66,80,97,145 --text "/status" --silent

# Option 3) read token from OpenClaw config (default: ~/.openclaw/openclaw.json)
./tg-topic-ping.mjs \
  --account <accountId> \
  --chat -1001234567890 \
  --topics 66,80,97,145 \
  --text "/status" \
  --silent
```

### Options

- `--chat <chat_id>`: supergroup id (usually `-100...`)
- `--topics <id1,id2,...>`: comma-separated topic ids (`message_thread_id`)
- `--text <text>`: message body
- `--silent`: send without notification
- `--delay-ms <n>`: delay between topics (default 350ms)
- `--parse-mode <MarkdownV2|HTML|Markdown>`: default `MarkdownV2`

## Exit code

- `0`: all topics sent OK
- `1`: at least one topic failed
- `2`: invalid args/env
