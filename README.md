# openclaw-agent-claw-config

A **public, sanitized OpenClaw agent workspace** focused on **OpenClaw configuration management**.

Use it as a ready-made workspace you can plug into your own OpenClaw Gateway as an **isolated agent**.

## What’s inside

- Persona/policy: `SOUL.md`, `AGENTS.md`, `USER.md`, `IDENTITY.md`, `TOOLS.md`, `HEARTBEAT.md`
- One-time ritual: `BOOTSTRAP.md` (delete it after you finish the ritual)
- Debug runbooks (skills): `skills/telegram-*/SKILL.md`
- Utility scripts/examples: `tools/`

## Quick start (recommended): create an isolated agent via CLI

Official docs (recommended reading):
- Agent workspaces: https://docs.openclaw.ai/concepts/agent-workspace
- Multi-agent routing / bindings: https://docs.openclaw.ai/concepts/multi-agent
- CLI (`openclaw agents`): https://docs.openclaw.ai/cli/agents
- Onboarding/bootstrap overview: https://docs.openclaw.ai/start/onboarding

> Tip: If you installed OpenClaw from the source repo, prefer running the CLI via **pnpm**:
>
> ```bash
> cd /Users/ruonan/repo/apps/openclaw
> pnpm openclaw ...
> ```
>
> Otherwise, use your local `openclaw` binary.

### 1) Copy (or clone) this workspace into `~/.openclaw/`

**Option A: copy (simple)**

```bash
cp -R ./openclaw-agent-claw-config ~/.openclaw/workspace-claw-config
```

**Option B: git clone (recommended if you want updates)**

```bash
git clone <THIS_REPO_URL> ~/.openclaw/workspace-claw-config
```

### 2) Create the agent

```bash
pnpm openclaw agents add claw-config \
  --workspace ~/.openclaw/workspace-claw-config \
  --model openai-codex/gpt-5.2 \
  --non-interactive --json
```

This writes `agents.list[]` into `~/.openclaw/openclaw.json`.

### 3) Bind a channel/account to the agent (routing)

Add a `bindings` rule in `~/.openclaw/openclaw.json` to route messages to this agent.

**Example: route a Telegram bot account `claw_config_bot` to this agent**

```json5
{
  "agentId": "claw-config",
  "match": {
    "channel": "telegram",
    "accountId": "claw_config_bot"
  }
}
```

> Want to route only a single group/topic? Use `match.peer`:
>
> ```json5
> {
>   agentId: "claw-config",
>   match: {
>     channel: "telegram",
>     accountId: "claw_config_bot",
>     peer: { kind: "group", id: "-1001234567890:topic:218" }
>   }
> }
> ```

### 4) Restart the gateway and verify

```bash
pnpm openclaw gateway restart
pnpm openclaw channels status --probe --timeout 20000
```

Then send a test message in the target chat (DM/group/topic) to confirm routing.

## Local-only customization (do not commit secrets)

- Edit `USER.md` and `TOOLS.md` to match your environment.
- Put secrets (bot tokens, API keys) in **`~/.openclaw/openclaw.json`** or non-committed env files.

## Notes on `BOOTSTRAP.md`

- `BOOTSTRAP.md` is a **one-time ritual** for a brand-new workspace.
- After the ritual is complete, delete `BOOTSTRAP.md` so it doesn’t run again.

## Security / Sanitization notes

This workspace intentionally avoids:

- bot tokens / API keys
- device identifiers and account ids
- local absolute paths specific to the original author
- runtime artifacts (sessions/log/db)

If you add sensitive data, keep it out of git.
