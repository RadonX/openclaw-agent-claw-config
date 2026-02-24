# Tooling & security model (what to encode in claw-config skills)

This is where claw-config skills differ from generic skills: they must respect tool gating.

## Key idea

"Exec denied" is often **not** an agent bug; it is policy.
A claw-config skill must diagnose by reading docs and identifying the correct layer.

## The layers to consider

1) Tool allow/deny lists (per-agent tool policy)
2) Exec host selection (sandbox vs gateway vs node)
3) Exec security mode (`deny` / `allowlist` / `full`)
4) Exec approvals allowlists (e.g. `exec-approvals.json`)
5) Elevated mode (often *not* the right fix)

## Docs-first pointers

Do not hardcode doc links here. Use the docs-first protocol:

- search official docs for the exact tool/key/error
- confirm in source if version-sensitive
- validate with a minimal repro

## Design requirements for skills

- Never assume exec will work; provide a non-exec fallback path (user runs commands and pastes output).
- When a fix is policy-related, name the exact key(s) to change.
- Prefer minimal, reversible changes.
