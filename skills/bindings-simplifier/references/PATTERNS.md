# Patterns (routing simplification)

## Pattern A: Exclusive account

When a bot account is dedicated to one agent (common for “ops/config bots”).

**Before**: repeated per-group binds.

**After**: one account-level bind:
```json5
{ agentId: "claw-config", match: { channel: "telegram", accountId: "claw_3po" } }
```

**Why safe**: the account cannot route to another agent because no other binding uses that account.

## Pattern B: Many topics, same agent

If all topics under a group route to the same agent and there are no per-topic activation overrides:

**After**:
```json5
{ agentId: "tg-botbot", match: { channel: "telegram", accountId: "platinum", peer: { kind: "group", id: "-1003795580197" } } }
```

Keep exceptions explicit.

## Pattern C: “Default + exception topic”

```json5
{ agentId: "main", match: { channel: "telegram", accountId: "platinum" } },
{ agentId: "davinci", match: { channel: "telegram", accountId: "platinum", peer: { kind: "group", id: "-1003797724681:topic:218" } } },
```

Specific match wins.

## Pattern D: Shared account across agents

Example: one account used by multiple agents (main + tg-botbot). This is the most dangerous area.

Rules:
- Prefer peer-specific bindings.
- Only add account-level binding if you *want* that account’s remaining traffic to fall through to that agent.

## Anti-patterns

- Merging topics when `channels.telegram.groups.<gid>.topics` contains overrides.
- Converting shared accounts to account-level binding without an explicit exception map.
- “Looks redundant” changes without a before/after coverage map.
