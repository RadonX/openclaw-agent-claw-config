# Public skill hygiene

## Must

- Keep doc/path references portable (no private absolute paths).
- Keep `SKILL.md` as a router (short). Put detail in `references/`.
- Keep README human-oriented: why someone wants this skill.

## Must not

- No private absolute paths (e.g., `/Users/<name>/...`).
- Do not copy version-sensitive routing priority logic into the skill; point to official docs instead.
- Do not assume a specific deployment layout; state assumptions explicitly.

## PR hygiene

- No unrelated changes in the same PR (stash, new branch).
- Avoid committing session artifacts (`*.session`, logs).
