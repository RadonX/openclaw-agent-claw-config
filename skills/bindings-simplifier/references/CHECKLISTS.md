# Checklists

## Pre-flight (before touching bindings)

- [ ] Confirm config format is JSON5 and you are editing the correct file.
- [ ] Create rollback point:
  - [ ] `git status` is clean OR commit current state
  - [ ] (optional) timestamped backup of `openclaw.json`
- [ ] Build a **before coverage map** (bindings).
- [ ] Build an **activation map** (channels gates) for the same peers.

## Safe transformations

### Account-level binding

- [ ] `accountId` is exclusive to a single agent OR exceptions are explicit.
- [ ] No other agent uses the same `accountId` for any peer you care about.

### Topic → group merge

- [ ] All topics route to the same agent.
- [ ] No per-topic activation overrides under `channels.telegram.groups.<gid>.topics`.
- [ ] No per-topic binding routes to a different agent.

### Keeping exceptions

- [ ] Any topic with unique routing stays explicit.
- [ ] Any topic with unique activation stays explicit.

## Post-change validation

- [ ] Config parses / validates (doctor).
- [ ] Routing equivalence spot-check for 1–3 critical peers.
- [ ] Activation equivalence spot-check:
  - mention required vs not
  - allowFrom restrictions
- [ ] Gateway restarted (if required by your deployment).

## If something breaks

- [ ] Roll back to the last known good commit/backup.
- [ ] Re-read official docs:
  - `docs/channels/channel-routing.md`
  - `docs/channels/telegram.md`
