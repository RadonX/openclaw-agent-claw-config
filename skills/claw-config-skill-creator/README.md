# claw-config-skill-creator

This skill helps you **draft and review** OpenClaw skills intended for a "claw-config" agent (a conservative config operator with change control and docs-first diagnosis).

## Why you want this

Config skills are high-impact:

- they can silently change routing (bindings)
- they can break activation expectations (Telegram mention/allowlist/topic overrides)
- they often touch privileged tools (exec / approvals)

This skill makes sure new skills are:

- docs-first (no guessing)
- safe-by-default (plan first, apply gated)
- public-ready (portable paths, no private machine assumptions)

## Usage

- Create (proposal-only):
  - `/claw-config-skill-creator <new-skill-name>`

- Review:
  - `/claw-config-skill-creator review <skill-path-or-name>`

## What it outputs

- In create mode: a complete skill proposal (tree + full file contents).
- In review mode: a checklist-based audit with concrete fixes.

## License

Same as the repository license.
