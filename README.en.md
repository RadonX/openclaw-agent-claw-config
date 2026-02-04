# openclaw-agent-claw-config

English | [中文](./README.md)

A **public, sanitized OpenClaw agent workspace** focused on **OpenClaw configuration management**.

Use it as a ready-made workspace you can plug into your own OpenClaw Gateway as an **isolated agent** (separate sessions/memory/persona).

## Official docs

- Agent workspaces: https://docs.openclaw.ai/concepts/agent-workspace
- Multi-agent routing / bindings: https://docs.openclaw.ai/concepts/multi-agent
- CLI (`openclaw agents`): https://docs.openclaw.ai/cli/agents
- Onboarding / bootstrap: https://docs.openclaw.ai/start/onboarding

## Quick start (recommended): create an isolated agent via CLI

> If you installed OpenClaw from the source repo, prefer running the CLI via **pnpm**:
>
> ```bash
> cd <PATH_TO_OPENCLAW_REPO>
> pnpm openclaw ...
> ```
>
> Otherwise, use your local `openclaw` binary.

### 1) Put this workspace under `~/.openclaw/`

```bash
cp -R ./openclaw-agent-claw-config ~/.openclaw/workspace-claw-config
# or
# git clone <THIS_REPO_URL> ~/.openclaw/workspace-claw-config
```

### 2) Create the agent

```bash
pnpm openclaw agents add claw-config \
  --workspace ~/.openclaw/workspace-claw-config \
  --model openai-codex/gpt-5.2 \
  --non-interactive --json
```

### 3) Add a `bindings` rule (routing)

Edit `~/.openclaw/openclaw.json` and add a binding.

Example: route a Telegram bot account `claw_config_bot` to this agent:

```json5
{
  "agentId": "claw-config",
  "match": {
    "channel": "telegram",
    "accountId": "claw_config_bot"
  }
}
```

To route only a single group/topic:

```json5
{
  agentId: "claw-config",
  match: {
    channel: "telegram",
    accountId: "claw_config_bot",
    peer: { kind: "group", id: "-1001234567890:topic:218" }
  }
}
```

### 4) Restart the gateway and verify

```bash
pnpm openclaw gateway restart
pnpm openclaw channels status --probe --timeout 20000
```

## Bootstrap / customization (how it works in OpenClaw)

This workspace includes `BOOTSTRAP.md` for the **first-run ritual**.

The intended flow is:
- Start using the agent (send it a message).
- Follow the `BOOTSTRAP.md` conversation/ritual.
- The ritual will guide you to fill/update files like `IDENTITY.md`, `USER.md`, and `SOUL.md`.
- After finishing, delete `BOOTSTRAP.md` to avoid re-running it.

## Security / sanitization notes

This repo intentionally avoids:
- bot tokens / API keys
- device identifiers and account ids
- real usernames / machine-specific absolute paths
- runtime artifacts (sessions/log/db)

Keep secrets out of git.
