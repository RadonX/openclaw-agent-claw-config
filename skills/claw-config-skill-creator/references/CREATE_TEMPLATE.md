# Create template (what create-mode should generate)

This is the minimal template the creator should instantiate.

## Suggested file tree

```
<new-skill-name>/
  SKILL.md
  README.md
  references/
    HELP.md
    PROCESS.md
    CHECKLISTS.md
```

## SKILL.md requirements

- Clear `description` that triggers on user intent.
- Interface includes:
  - default mode does the job (plan-only)
  - apply is a follow-up step (explicit confirm)
- Guardrails:
  - docs-first
  - routing vs activation
  - rollback
- Doc pointers using `${OPENCLAW_REPO:-~/repo/apps/openclaw}`

## README requirements (human-facing)

- Why someone wants this skill
- When to use / when not to use
- How to run it in one line

## References requirements

- PROCESS: step-by-step workflow
- CHECKLISTS: pre/post-flight checks
