# Review checklist (claw-config skills)

## A) Docs-first

- [ ] Deep behavior claims are backed by official docs links.
- [ ] No hand-wavy guesses when uncertainty exists.

## B) Mental model correctness

- [ ] Routing (`bindings`) is separated from activation (`channels.*`).
- [ ] Telegram: mentions/allowlists/topic overrides are acknowledged.

## C) Safety defaults (claw-config)

- [ ] Default action is plan/proposal, not silent apply.
- [ ] Apply is a follow-up step (`apply`) + final yes/no.
- [ ] Rollback pointer is present (git commit hash / backup file).
- [ ] Verification steps are explicit (doctor/validate + restart + minimal runtime test).
- [ ] Post-change report format exists (what/verify/effective/risk).

## D) Public readiness

- [ ] No private absolute paths.
- [ ] Uses `${OPENCLAW_REPO:-~/repo/apps/openclaw}` placeholder.
- [ ] README explains user value, not implementation.

## E) Minimalism

- [ ] No dead-pointer reference files.
- [ ] `SKILL.md` is short; complexity is in references.
