# Review checklist (claw-config skills)

## A) Docs-first

- [ ] Deep behavior claims are backed by official docs links.
- [ ] No hand-wavy guesses when uncertainty exists.

## B) Mental model correctness

- [ ] Routing (`bindings`) is separated from activation (`channels.*`).
- [ ] Telegram: mentions/allowlists/topic overrides are acknowledged.

## C) Safety defaults

- [ ] Default action is plan/proposal, not silent apply.
- [ ] Apply requires explicit confirmation.
- [ ] Rollback plan is present (git commit / backup).

## D) Public readiness

- [ ] No private absolute paths.
- [ ] Uses `${OPENCLAW_REPO:-~/repo/apps/openclaw}` placeholder.
- [ ] README explains user value, not implementation.

## E) Minimalism

- [ ] No dead-pointer reference files.
- [ ] `SKILL.md` is short; complexity is in references.
