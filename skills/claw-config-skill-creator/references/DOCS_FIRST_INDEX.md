# Docs-first index (portable, minimal)

This file is **not** a fixed doc list.

It provides:

- a portable way to reference official docs, and
- a small set of *optional* entry points you can pick from **based on the skill archetype**.

Use either:

- Hosted docs: https://docs.openclaw.ai
- Local docs (portable repo root): `${OPENCLAW_REPO:-~/repo/apps/openclaw}/docs/...`

## Entry points (pick what fits; do not copy all)

### Routing / bindings skills

- `${OPENCLAW_REPO:-~/repo/apps/openclaw}/docs/channels/channel-routing.md`

### Telegram behavior / activation skills

- `${OPENCLAW_REPO:-~/repo/apps/openclaw}/docs/channels/telegram.md`

### Exec / approvals / elevated skills

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
