# bindings-simplifier

A **docs-first, safety-first** skill for simplifying OpenClaw `bindings` (routing rules) while preserving behavior.

## Why this exists

Bindings tend to grow into per-topic/per-group redundancy. Simplifying them is high-risk because:

- `bindings` controls **routing** (which agent receives a message)
- `channels.*` controls **activation** (whether the bot replies): `requireMention`, `allowFrom`, `groupPolicy`, per-topic overrides, etc.

A routing-only refactor can still “break the config” from the user’s perspective if activation differs per topic/group.

## Mental model (tl;dr)

- **Routing**: `bindings` → peer/topic/account → agent
- **Activation**: `channels.<provider>` → reply gating

Always preserve **both**.

## Interface

- `/bindings-simplifier`
  - Default: run the full workflow in **plan-only** mode (analyze → propose → print a minimal JSON5 patch + verification steps).
- `/bindings-simplifier help`
  - Show how it works.

### Apply (follow-up step)

After a plan is printed, reply with:

- `apply`

The skill must then re-print the patch, ask for a final yes/no, and only then write config.

## Official docs (source of truth)

Use a portable repo root variable:

- `${OPENCLAW_REPO:-~/repo/apps/openclaw}/docs/channels/channel-routing.md`
- `${OPENCLAW_REPO:-~/repo/apps/openclaw}/docs/channels/telegram.md`

## What the workflow outputs

1. **Before coverage map**: what routes where
2. **After coverage map**: what will route where
3. **Removed/merged bindings list**
4. **Minimal JSON5 patch** (copy/paste)
5. **Verification checklist** + suggested manual tests

## Files

- `SKILL.md`: router + guardrails + doc pointers
- `references/PROCESS.md`: end-to-end method (routing + activation)
- `references/CHECKLISTS.md`: pre/post-flight checks
- `references/PATTERNS.md`: safe patterns + anti-patterns
- `references/HELP.md`: usage notes

## Non-goals

- Not a fully automated refactoring engine.
- Does not execute `git` / restarts by itself unless explicitly asked and appropriately authorized.

## License

Same as the repository license.
