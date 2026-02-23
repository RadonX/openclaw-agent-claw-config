# Contributing

This skill is meant to improve safety and predictability. Keep it short, strict, and actionable.

## Principles

- Prefer official docs over folklore.
- Separate routing (`bindings`) from activation (`channels.*`).
- Do not add auto-apply behavior without explicit confirmation and rollback guidance.
- Keep public docs path-portable (`${OPENCLAW_REPO:-~/repo/apps/openclaw}`) and avoid private absolute paths.

## Submitting changes

- Keep PRs scoped to this skill.
- Add/adjust checklists rather than adding long narrative.
- If you change the interface, explain how it affects safety.
