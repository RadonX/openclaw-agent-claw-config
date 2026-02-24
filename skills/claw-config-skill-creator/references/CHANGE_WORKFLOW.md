# Standard change workflow (claw-config)

This workflow is mandatory for skills that can modify config, bindings, policies, or restart services.

## Plan-first default

Default output must include:

1) **Proposed change** (minimal patch)
2) **Why** (what problem it solves)
3) **Consistency invariants** (what must remain true)
4) **Verification** commands / tests
5) **Rollback**

## Apply (follow-up)

Apply must be a follow-up step initiated by the user (e.g. reply `apply`).
Before writing:

- show the exact patch again
- ask for a final yes/no

## Verification sequence (typical)

1) `git status` (avoid mixing unrelated changes)
2) validate config (e.g. `openclaw doctor` or equivalent)
3) restart/reload if required
4) minimal runtime test (send a message / check routing)

## Safe deletion

If deleting files, prefer reversible deletion (`trash`) over `rm`.

## After-action report (in-chat)

After applying:

- what changed (file + keys)
- how verified (commands + expected outcome)
- whether effective (restarted? scope)
- rollback pointer (commit hash / backup file)
