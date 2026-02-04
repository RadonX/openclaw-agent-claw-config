---
name: openclaw-source-of-truth
description: Enforce “docs-first, code-second” behavior for OpenClaw configuration/behavior questions. Use when answering questions about OpenClaw config options, routing, precedence, CLI behavior, outages, or implementation details. Prefer official docs; if unclear or version-sensitive, confirm in source code (rg). Fall back to asking the user to run copy-paste commands when local repo/tools are unavailable.
---

# OpenClaw Source of Truth (docs-first, code-second)

Goal: make answers **evidence-driven** and reduce hallucinations.

## Decision rule (always follow)

1) **Prefer official docs** (fast + stable)
   - If you have local docs: search them first.
   - Otherwise: use https://docs.openclaw.ai.

2) **If docs are unclear / version-sensitive → confirm in source code**
   - Use `rg` in the OpenClaw repo (`src/` and `docs/`).
   - Quote file path + relevant lines.

3) **If you cannot access repo/tools**
   - Provide a copy-paste command for the user to run, and ask them to paste the output.

## Minimal commands (copy-paste friendly)

### A) Search docs

If OpenClaw repo is available locally:

```bash
cd <PATH_TO_OPENCLAW_REPO>
rg -n "<keyword>" docs | head -n 80
```

### B) Confirm in source

```bash
cd <PATH_TO_OPENCLAW_REPO>
rg -n "<keyword>" src | head -n 80
```

### C) Validate runtime behavior

```bash
openclaw status
openclaw channels status --probe --timeout 20000
openclaw logs --limit 200 --plain
```

(If installed from source, prefer `pnpm openclaw ...`.)

## Answer format (what to say)

- **Conclusion** (1–2 lines)
- **Evidence**
  - docs link(s) OR code path(s) + snippet
- **Next action** (what the user should do / what config to change)

## Notes

- Don’t invent CLI flags; if unsure, run `openclaw <cmd> --help` and quote it.
- When discussing precedence (bindings, requireMention, etc.), prefer citing docs first and then validating in `src/`.
