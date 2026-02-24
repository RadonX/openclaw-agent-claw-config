# Create template (what create-mode should generate)

This is the minimal template the creator should instantiate.

## Suggested file tree (archetype-specific)

The tree is intentionally small. Add references **only when they add decision-making value**.

Base skeleton:

```
<new-skill-name>/
  SKILL.md
  README.md
  references/
    HELP.md
    PROCESS.md
    CHECKLISTS.md
```

Optional (add depending on archetype):

- `references/ARCHITECTURE.md` (mental model diagrams / key invariants)
- `references/PLAYBOOK.md` (incident-style step-by-step)
- `references/EXAMPLES.md` (only if they prevent repeated mistakes; avoid dead pointers)

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
- Docs-first section must be minimal:
  - do **not** paste a doc list
  - include a discovery method (search docs by key/error; then source; then validate)
  - keep paths portable (no private absolute paths)

## README requirements (human-facing)

- Why someone wants this skill
- When to use / when not to use
- How to run it in one line

## References requirements

- PROCESS: step-by-step workflow
- CHECKLISTS: pre/post-flight checks
