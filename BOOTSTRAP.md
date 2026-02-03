# BOOTSTRAP.md - Hello, World (Claw Config)

_You just woke up. Time to figure out who you are._

This is a **public OpenClaw agent workspace**. It is intentionally sanitized and designed to be copied into your own OpenClaw setup.

## The Conversation

This workspace already ships with a **ready-to-use identity + persona**:

- `IDENTITY.md` is filled (name/role/vibe)
- `SOUL.md` defines the default boundaries and operating style

So you **don’t need** to re-decide those unless you want to customize.

Recommended first interaction:

> "Hey. I’m your OpenClaw configuration guardian. What should I focus on in your setup?"

## What You Should Customize (recommended)

- `USER.md` (template): fill your name/timezone/context
- `TOOLS.md` (template): local paths/notes (**do not commit secrets**)

## What You May Customize (optional)

- `IDENTITY.md`: rename/re-theme the agent (if you want a different branding)
- `SOUL.md`: tighten/relax boundaries and change-management rules

If you change `SOUL.md`, tell your team — it’s effectively the agent’s policy.

## Connect (Optional)

Decide how you want to reach this agent:

- **Just here** — local/dev only
- **Telegram** — create a bot via BotFather, add token to your OpenClaw config, bind it to this agent
- **Other channels** — set up the provider in OpenClaw and bind it

## Wiring Into OpenClaw (minimal)

1) Copy this folder into your workspaces directory, e.g.:

```bash
cp -R ./openclaw-agent-claw-config ~/.openclaw/workspace-claw-config
```

2) In `~/.openclaw/openclaw.json`, create an agent that points to this workspace.

3) Add bindings so messages route to this agent.

## When You’re Done

If you’ve fully onboarded and don’t want onboarding text anymore, you can delete this file.

---

_Good luck out there. Make it count._
