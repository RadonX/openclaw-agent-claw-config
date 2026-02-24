---
name: claw-config-skill-creator
description: Create or review OpenClaw skills for the claw-config agent. Default mode drafts a new skill (proposal-only) with docs-first mental model and safety guardrails; review mode audits an existing skill for routing/activation correctness, public hygiene, and apply-gating.
compatibility: OpenClaw
metadata:
  author: claw-config
  version: "1.0"
  openclaw:
    emoji: "🧱"
---

# claw-config-skill-creator

A blueprint skill for creating **claw-config-specific** skills: conservative config operations with docs-first diagnosis, change control, and consistency guarantees.

## Interface

### Default: create (proposal-only)

```
/claw-config-skill-creator <new-skill-name>
```

Produces a complete **PROPOSAL** (file tree + full contents) for a new skill.

### Review: audit an existing skill

```
/claw-config-skill-creator review <skill-path-or-name>
```

Outputs a review report: issues, risks, and concrete edits.

## Hard parsing rules

- First token after `/claw-config-skill-creator` is either:
  - `review`, or
  - `<new-skill-name>`
- Any other subcommand-like token is unsupported → show help (in `references/HELP.md`) and ask the user to restate.

## Output contract

### Create mode

Must output:

1. Target skill name + intended trigger description
2. Proposed file tree
3. Full contents of every file
4. Any open questions (only if blocking)

Default is **proposal-only** (no writes).

### Review mode

Must output:

- Summary: pass/fail + risk level
- Findings grouped by category (docs-first, routing vs activation, apply gating, public hygiene)
- Suggested patch snippets

## Mental model (must be embedded in created skills)

A claw-config skill must clearly separate:

- **Routing**: `bindings` chooses which agent receives a message.
- **Activation / access**: `channels.*` gates whether replies happen (Telegram requireMention/allowFrom/groupPolicy/topics overrides).

## Docs-first (don’t hardcode a doc list)

Created skills should **not** copy a long list of OpenClaw docs.

Instead, they must include a short “Docs-first” section that:

- links to the *few* relevant official entry points for that skill’s archetype (routing vs telegram vs exec, etc.)
- uses portable paths like `${OPENCLAW_REPO:-~/repo/apps/openclaw}/docs/...` or links to `https://docs.openclaw.ai`
- states a discovery method for deeper dives (e.g. search/grep in the repo) rather than enumerating everything

See: `references/DOCS_FIRST_INDEX.md` for the canonical index + how to use it.

## Guardrails (non-negotiable)

- **Docs-first** for deep issues. No guessing.
- **Claw-config boundaries**: stay in config + ops; keep secrets redacted by default.
- **Plan-first defaults**: for any skill that can change config, default behavior must be plan/proposal; apply must be a gated follow-up step.
- **Rollback + verification + report**: require rollback pointer and a post-change report (what/verify/effective/risk).
- **Public hygiene**: no private absolute paths; no version-sensitive routing logic copied into skills—link to docs instead.

## References (must-read)

- `references/ROLE_AND_BOUNDARIES.md`
- `references/CHANGE_WORKFLOW.md`
- `references/TOOLING_AND_SECURITY_MODEL.md`
- `references/ARCHETYPES.md`
- `references/DOCS_FIRST_INDEX.md`
- `references/CREATE_TEMPLATE.md`
- `references/REVIEW_CHECKLIST.md`
- `references/PUBLIC_HYGIENE.md`
- `references/HELP.md`
