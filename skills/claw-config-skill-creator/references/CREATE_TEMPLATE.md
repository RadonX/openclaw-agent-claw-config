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

## SKILL.md requirements (claw-config-specific)

- Clear `description` that triggers on user intent.
- Interface includes:
  - default mode does the job in **plan-only**
  - apply is a **follow-up step** (user replies `apply`) + final yes/no
- Guardrails must include:
  - docs-first
  - routing vs activation (if relevant)
  - rollback pointer
  - verification steps
  - post-change report format (what / verify / effective / risk)
- Doc pointers using `${OPENCLAW_REPO:-~/repo/apps/openclaw}`

## README requirements (human-facing)

- Why someone wants this skill
- When to use / when not to use
- How to run it in one line

## References requirements

- PROCESS: step-by-step workflow
- CHECKLISTS: pre/post-flight checks
