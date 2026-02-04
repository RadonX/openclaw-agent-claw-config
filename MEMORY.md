# MEMORY.md - Public (sanitized)

This file captures **portable decisions and mental models** for an OpenClaw *configuration-management* agent.

It intentionally avoids:
- deployment-specific agent ids / bot account names (e.g. internal “platinum”)
- tokens, chat ids, usernames

## Decisions (portable)

- Create a dedicated **config-management agent workspace** to avoid mixing responsibilities with general-purpose agents.
- Prefer **explicit naming** for accounts/agents to reduce confusion (instead of ambiguous defaults).
- Maintain a clear *source of truth* for where skills come from.

## Architecture mental model

### Agents vs Bindings vs Channels

- **agents.list**: defines agents (workspace + model config)
- **bindings**: routes incoming/outgoing channel traffic to agents
- **channels.telegram.accounts**: defines Telegram bot accounts (token + policy)

### How OpenClaw “knows” a bot

- OpenClaw knows **bot tokens**, not @username.
- @username is fetched via Telegram `getMe()` and is mainly for logs.
- A single token cannot be polled by multiple processes at the same time (**409 Conflict**).

## Common issues

### “Why is this agent speaking with the wrong persona?” (session + group systemPrompt gotchas)

Portable mental model:

- Persona comes from **workspace bootstrap files** (e.g. `SOUL.md`, `AGENTS.md`, `IDENTITY.md`, `USER.md`).
- However, providers can also inject **group-scoped `systemPrompt`** (e.g. `channels.telegram.groups.<id>.systemPrompt` or per-account group config).
- If a group `systemPrompt` is too specific, it can **override the intended workspace persona** for that room/topic.

Practical guideline:
- Keep group `systemPrompt` minimal (e.g. “You are in <group name>”) and put detailed behavior in the agent workspace.
- If you’re testing a “fresh bootstrap”, remember that **sessions are sticky**: an existing session may keep old system messages.
  - For a truly fresh test, clear the relevant session (or start a new session) after changing persona/config.


### 409 Conflict

- Cause: the same bot token is being used by multiple pollers
- Fix: ensure only one OpenClaw instance is using that token
- Diagnose: inspect `bindings` + `channels.telegram.accounts`

### Workspace defaults

- `agents.defaults.workspace`: `~/.openclaw/workspace`
- If an agent doesn’t specify a workspace, it inherits the default
- Best practice: each agent should have its own workspace
