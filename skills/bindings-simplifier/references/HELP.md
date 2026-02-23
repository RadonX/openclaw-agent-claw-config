# bindings-simplifier help

## Quick mental model

- `bindings` = routing (peer/topic/account → agent)
- `channels.*` = activation (whether OpenClaw replies)

A safe simplification must preserve **both**.

## Default behavior (`/bindings-simplifier`)

Runs the job in **plan-only** mode:

1) Build a **before coverage map** (routing)
2) Audit **activation gates** for the same peers
3) Propose safe simplifications
4) Output:
   - removed/merged bindings list
   - minimal JSON5 patch
   - verification checklist

## Apply (follow-up step)

After the plan is printed, reply with **`apply`**.
The skill must re-print the patch, ask for a final yes/no, then apply.
## Read first (official docs)

- Routing: `${OPENCLAW_REPO:-~/repo/apps/openclaw}/docs/channels/channel-routing.md`
- Telegram gates: `${OPENCLAW_REPO:-~/repo/apps/openclaw}/docs/channels/telegram.md`

## References

- `references/PROCESS.md`
- `references/CHECKLISTS.md`
- `references/PATTERNS.md`
