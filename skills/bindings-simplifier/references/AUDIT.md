# Pre-simplification audit checks

Before simplifying bindings, verify these safety conditions.

## 1) Account exclusivity check

**Goal**: Ensure an `accountId` maps to only one agent before converting to account-level binding.

```bash
# Check which agents use each account
jq '.bindings[] | {agentId, accountId: .match.accountId}' ~/.openclaw/openclaw.json | jq -s 'group_by(.accountId) | map({accountId: .[0].accountId, agents: [.[].agentId | unique]})'
```

**Safe to simplify** if `accountId` appears in only one agent's bindings.

**NOT safe** if account is shared (e.g., `platinum` used by both `main` and `tg-botbot`).

## 2) Activation consistency check

**Goal**: Ensure merging topic bindings won't break activation behavior.

For each target group, check `channels.telegram.groups.<id>`:

```bash
# Show activation config for a group
jq '.channels.telegram.groups."<group-id>"' ~/.openclaw/openclaw.json
```

**Check for**:
- `requireMention`: Should be consistent across topics you're merging
- `allowFrom`: Should not conflict (e.g., one topic allows `*`, another allows specific user)
- `topics.<id>.requireMention`: Exception topics that must remain separate

**Inconsistency examples**:

❌ **Don't merge** if:
```json5
{
  "-1003795580197": {
    "requireMention": false,  // Group-level: no mention needed
    "topics": {
      "66": { "requireMention": true },  // Topic-level: mention required
    }
  }
}
```

✅ **Safe to merge** if:
```json5
{
  "-1003795580197": {
    "requireMention": true,  // Consistent
    "topics": {
      "66": {},  // No override
      "80": {},  // No override
    }
  }
}
```

## 3) Route collision check

**Goal**: Ensure simplified bindings won't cause unexpected routing changes.

For each proposed account-level binding, verify:

```bash
# Find all bindings for the target account
jq '.bindings[] | select(.match.accountId == "<account-id>")' ~/.openclaw/openclaw.json
```

**Check**:
- Are there any peer-specific bindings that would override the account-level one?
- Will the account-level binding match peers that should route elsewhere?

**Example collision**:

❌ **Don't simplify** if:
```json5
// Account binds to all groups
{ agentId: "agent-a", match: { channel: "telegram", accountId: "bot" }},

// But one group needs a different agent
{ agentId: "agent-b", match: { channel: "telegram", accountId: "bot", peer: { id: "-1003797724681" }}},
```

In this case, keep peer-specific binding for `-1003797724681`.

## 4) Count before/after

Track your progress:

```bash
# Current count
jq '.bindings | length' ~/.openclaw/openclaw.json

# After simplification, re-run to compare
```

**Target**: 30-50% reduction is typical for well-structured configs.
