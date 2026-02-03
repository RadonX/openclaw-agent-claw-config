# BOOTSTRAP.md - Fill-in Checklist (Public Workspace)

This workspace is designed to be **shareable**.

Do the following after copying it into your OpenClaw workspaces.

## 0) Decide where this workspace lives

Recommended:

- `~/.openclaw/workspace-claw-config/`

## 1) Fill in user + local notes

- `USER.md`
  - your name / timezone
  - what you want this agent to optimize for

- `TOOLS.md`
  - **do not commit secrets**
  - put bot tokens/API keys in OpenClaw config or local env files

## 2) Add agent entry in `~/.openclaw/openclaw.json`

Minimal example (conceptual):

- `agents.list += { id: "claw-config", workspace: "~/.openclaw/workspace-claw-config", model: { primary: "<your-model>" } }`

## 3) Bind channels/accounts

Telegram example (conceptual):

- Create a Telegram bot token via BotFather
- Add it under `channels.telegram.accounts[]`
- Add a binding mapping that account+peer → `agentId: claw-config`

## 4) Run a smoke test

- `openclaw gateway status`
- Send a test message in your target chat/topic
- Confirm the agent responds and logs show no `not-allowed` / `409 Conflict`

## 5) Optional: customize skills

See `skills/telegram-*/SKILL.md` for runbooks.

## Redaction rule of thumb

If you are about to commit:

- tokens, keys, cookies → don’t
- real chat ids, phone numbers, emails → replace with placeholders
- local absolute paths → replace with `~` or env vars
