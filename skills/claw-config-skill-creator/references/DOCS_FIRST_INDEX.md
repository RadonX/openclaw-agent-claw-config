# Docs-first index (portable, minimal)

This is a **small set of official entry points**, not an exhaustive list.

Use either:

- Hosted docs: https://docs.openclaw.ai
- Local docs (portable repo root): `${OPENCLAW_REPO:-~/repo/apps/openclaw}/docs/...`

## The 3 entry points (cover most claw-config deep dives)

1) **Routing semantics / session keys**
- `${OPENCLAW_REPO:-~/repo/apps/openclaw}/docs/channels/channel-routing.md`

2) **Telegram activation gates** (why the bot does / doesn’t reply)
- `${OPENCLAW_REPO:-~/repo/apps/openclaw}/docs/channels/telegram.md`

3) **Exec policy / approvals / elevated** (why commands are blocked)
- `${OPENCLAW_REPO:-~/repo/apps/openclaw}/docs/tools/exec.md`
- `${OPENCLAW_REPO:-~/repo/apps/openclaw}/docs/tools/exec-approvals.md`
- `${OPENCLAW_REPO:-~/repo/apps/openclaw}/docs/tools/elevated.md`

## Discovery method (when the entry points aren’t enough)

Do not guess. Use docs-first, then code:

- Search docs by keyword:
  - `rg -n "<keyword>" ${OPENCLAW_REPO:-~/repo/apps/openclaw}/docs`

- If behavior is version-sensitive, locate the resolver/implementation:
  - `rg -n "resolve.*route|bindings" ${OPENCLAW_REPO:-~/repo/apps/openclaw}/src`

The skill you generate should include only the *relevant* entry points for its archetype, plus the discovery method above.
