# Bindings Simplifier

Simplify OpenClaw `bindings` configuration by eliminating redundancy while preserving functionality.

## Quick start

```bash
# Analyze current bindings
cd ~/.openclaw
jq '.bindings | length' openclaw.json

# Show binding summary by agent
jq '.bindings | group_by(.agentId) | map({agent: .[0].agentId, count: length})' openclaw.json
```

## Common use cases

### Case 1: Account-level simplification

**When**: An `accountId` maps to only one agent.

**Example**:
```bash
# Check if claw_3po is exclusive to claw-config
jq '.bindings[] | select(.match.accountId == "claw_3po") | .agentId' openclaw.json | uniq
# Output: ["claw-config"]

# Simplify all claw_3po bindings to single account-level entry
```

See `references/EXAMPLES.md#Pattern-1` for details.

### Case 2: Merge topic bindings

**When**: Same agent binds to multiple topics of the same group.

**Example**:
```bash
# Find groups with many topic bindings
jq '.bindings[] | select(.match.peer.id | test(":topic:")) | .match.peer.id | split(":topic:")[0]' openclaw.json | sort | uniq -c
```

See `references/EXAMPLES.md#Pattern-2` for details.

### Case 3: Pre-simplification audit

**Before simplifying**:

1. Backup config:
   ```bash
   cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup.$(date +%Y%m%d_%H%M%S)
   ```

2. Check account exclusivity:
   ```bash
   jq '.bindings[] | {agentId, accountId: .match.accountId}' openclaw.json | jq -s 'group_by(.accountId) | map({accountId: .[0].accountId, agents: [.[].agentId | unique]})'
   ```

3. Verify activation consistency:
   ```bash
   jq '.channels.telegram.groups."<group-id>"' openclaw.json
   ```

See `references/AUDIT.md` for complete checklist.

## Safety checks

- [ ] Account exclusivity verified
- [ ] Activation consistency checked  
- [ ] No exception topics in target group
- [ ] Route collision check passed
- [ ] Backup created

## What to read next

- **Mandatory**: `references/AUDIT.md` (pre-flight checks)
- **Mandatory**: `references/PRIORITY.md` (binding resolution order)
- **Recommended**: `references/EXAMPLES.md` (common patterns)

## Advanced

Understanding binding priority is critical for safe simplification. See `references/PRIORITY.md` for the complete resolution order.

**Key rule**: Specific matches override general matches.
- `topic:66` > `group` > `account` > `default`
