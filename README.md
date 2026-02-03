# openclaw-agent-claw-config

A **public, sanitized OpenClaw agent workspace** focused on **OpenClaw configuration management**.

This is intended to be copied into your own `~/.openclaw/workspace-.../` and then wired into your `openclaw.json` as an agent workspace.

## What’s inside

- Persona/policy files: `SOUL.md`, `AGENTS.md`, `HEARTBEAT.md`, `MEMORY.md`
- Debug runbooks (skills): `skills/telegram-*/SKILL.md`
- Utility scripts/examples: `tools/`

## Setup (bootstrap)

1) Copy this folder into your OpenClaw workspaces

```bash
cp -R ./openclaw-agent-claw-config ~/.openclaw/workspace-claw-config
```

2) Fill in local-only values

- Edit `USER.md` and `TOOLS.md` (both are templates)
- Put secrets in **your OpenClaw config** (`~/.openclaw/openclaw.json`) or env files **that are not committed**.

3) Wire the workspace into OpenClaw

In `~/.openclaw/openclaw.json`:

- Add an agent with `workspace: "~/.openclaw/workspace-claw-config"`
- Bind your desired channel/account to that agent (Telegram/Discord/etc.)

## Security / Sanitization notes

This repo intentionally avoids:

- bot tokens / API keys
- device identifiers and account ids
- local absolute paths specific to the original author
- runtime artifacts (venv/session/log/db)

If you add sensitive data, keep it in non-committed files.
