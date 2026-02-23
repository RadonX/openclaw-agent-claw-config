# Contributing to bindings-simplifier

This skill is meant to be **boring, safe, and repeatable**.

## Design principles

1. **Docs-first**
   - If OpenClaw behavior is unclear, prefer official docs over guesswork.
   - Do not hardcode private paths. Use `${OPENCLAW_REPO:-~/repo/apps/openclaw}` in public docs.

2. **Consistency over reduction**
   - A smaller `bindings` list is not a win if routing or activation changes.
   - Any suggested simplification must include a before/after coverage explanation.

3. **Routing ≠ activation**
   - `bindings` chooses the agent.
   - `channels.*` decides whether a reply is allowed/triggered.
   - Treat per-topic overrides as exceptions unless proven safe to merge.

4. **Apply is always gated**
   - Default mode must be plan-only.
   - Applying changes must require an explicit follow-up (`apply`) plus a final yes/no.

## What to change (and what not to)

### Good contributions

- Add new safe patterns / anti-patterns (with clear conditions)
- Improve checklists to catch real-world breakages
- Update doc pointers when OpenClaw docs move
- Add small, deterministic “verification command” snippets

### Avoid

- Copying routing priority logic into this repo (version-sensitive). Point to docs instead.
- Introducing subcommands/flags that feel like an executable CLI unless they’re clearly plan-only.
- Adding auto-apply behavior without confirmation.

## Testing changes

- Ensure markdown renders cleanly.
- Ensure references are consistent and minimal (no dead pointer files).
- Manually sanity-check that:
  - `/bindings-simplifier` implies plan-only
  - apply is described as a follow-up step

## Style

- Keep `SKILL.md` short (router); push detail into `references/`.
- Prefer bullet lists and checklists.
- Use “you” language and concrete terms (group/topic/account/agent).

## Submitting

1. Make a PR with a clear summary and screenshots/snippets if helpful.
2. Keep commits scoped (skill-only changes).
3. If changing workflow semantics, explain the user impact.
