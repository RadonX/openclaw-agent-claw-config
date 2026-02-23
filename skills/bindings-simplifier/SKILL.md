---
name: bindings-simplifier
description: Simplify OpenClaw bindings configuration by eliminating redundancy while preserving functionality. Use when: (1) bindings have grown too large, (2) there are repetitive per-topic bindings, (3) an account is only used by one agent. Triggered by requests like "simplify bindings", "reduce binding count", or "clean up redundant topic bindings".
metadata:
  author: RadonX
  version: "1.0"
  openclaw:
    emoji: "📦"
---

# bindings-simplifier

Simplify OpenClaw `bindings` configuration by eliminating redundancy while ensuring functional consistency.

## Interface

```
/bindings-simplifier [--dry-run] [--show-changes]
```

- `--dry-run`: Show proposed changes without writing
- `--show-changes`: Display before/after comparison

## When to use

Use when:
- Bindings have grown too large (>30 entries)
- There are repetitive per-topic bindings for the same agent
- An account (`accountId`) is only used by one agent
- Multiple agents bind to the same group with similar patterns

Do NOT use when:
- Each binding has unique, non-mergeable logic
- Account is shared across multiple agents with complex routing
- Unsure about activation implications

## Core simplification strategies

### 1) Account-level bindings

Use when an `accountId` maps to only one agent:

**Before** (redundant):
```json5
{ agentId: "claw-config", match: { channel: "telegram", accountId: "claw_3po", peer: { id: "-1003792208107" }}},
{ agentId: "claw-config", match: { channel: "telegram", accountId: "claw_3po", peer: { id: "-1003593489589" }}},
{ agentId: "claw-config", match: { channel: "telegram", accountId: "claw_3po", peer: { id: "-1003797724681" }}},
```

**After** (simplified):
```json5
{ agentId: "claw-config", match: { channel: "telegram", accountId: "claw_3po" }},
```

**Verification**: Check that the `accountId` appears in no other agent's bindings.

### 2) Merge topic-level bindings

When multiple topics for the same group map to the same agent:

**Before** (redundant):
```json5
{ agentId: "agent", match: { channel: "telegram", accountId: "bot", peer: { id: "-1003795580197:topic:66" }}},
{ agentId: "agent", match: { channel: "telegram", accountId: "bot", peer: { id: "-1003795580197:topic:80" }}},
{ agentId: "agent", match: { channel: "telegram", accountId: "bot", peer: { id: "-1003795580197:topic:97" }}},
```

**After** (merged):
```json5
{ agentId: "agent", match: { channel: "telegram", accountId: "bot", peer: { id: "-1003795580197" }}},
```

**Verification**: Ensure activation behavior (`requireMention`, `allowFrom`) is consistent across topics. See `references/AUDIT.md`.

### 3) Preserve exception topics

When a single topic needs special handling, keep it explicit:

**Pattern**:
```json5
// Group-level binding (covers most topics)
{ agentId: "default-agent", match: { channel: "telegram", accountId: "bot", peer: { id: "-1003795580197" }}},

// Exception topic (different agent)
{ agentId: "special-agent", match: { channel: "telegram", accountId: "bot", peer: { id: "-1003795580197:topic:218" }}},
```

**Verification**: Topic-level bindings have priority over group-level (see `references/PRIORITY.md`).

## Pre-simplification checklist

Before simplifying, verify:

1. **Account exclusivity**: Confirm `accountId` is not shared
   ```bash
   jq '.bindings[] | .match.accountId' ~/.openclaw/openclaw.json | sort -u
   ```

2. **Activation consistency**: Check `channels.telegram.groups.<id>` for:
   - `requireMention` values
   - `allowFrom` lists
   - `topics` with special settings

3. **Backup config**:
   ```bash
   cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup.$(date +%Y%m%d_%H%M%S)
   ```

## What references to read

- **Mandatory**: `references/AUDIT.md` (pre-flight checks)
- **Mandatory**: `references/PRIORITY.md` (binding resolution order)
- **Optional**: `references/EXAMPLES.md` (common patterns)

## Global guardrails

- **Never** remove a binding without verifying its agent is still reachable
- **Always** check activation config (`channels.telegram.groups`) before merging topic bindings
- **Ask** before simplifying when:
  - A group has `requireMention` or `allowFrom` settings
  - An account is used by multiple agents
  - You're unsure about priority implications

## Output proposal

Before writing, show:
1. Current count vs. proposed count
2. List of removed bindings (with peer IDs)
3. Any activation inconsistencies found
4. Prompt for confirmation: `Apply these changes? [y/N]`

Only write after explicit user confirmation.
