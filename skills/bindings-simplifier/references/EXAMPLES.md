# Common binding patterns

Recognize these patterns to simplify safely.

## Pattern 1: Single-account exclusive

**Symptom**: An `accountId` appears in only one agent's bindings.

**Before**:
```json5
// claw-config is the ONLY user of claw_3po
{ agentId: "claw-config", match: { accountId: "claw_3po", peer: { id: "-1003792208107" }}},
{ agentId: "claw-config", match: { accountId: "claw_3po", peer: { id: "-1003593489589" }}},
{ agentId: "claw-config", match: { accountId: "claw_3po", peer: { id: "-1003797724681" }}},
```

**After**:
```json5
{ agentId: "claw-config", match: { accountId: "claw_3po" }},
```

**Verification**: `jq '.bindings[] | select(.match.accountId == "claw_3po") | .agentId' ~/.openclaw/openclaw.json | uniq` should return `["claw-config"]` only.

## Pattern 2: Repetitive topic bindings

**Symptom**: Same agent binds to multiple topics of the same group.

**Before**:
```json5
{ agentId: "tg-botbot", match: { accountId: "platinum", peer: { id: "-1003795580197:topic:66" }}},
{ agentId: "tg-botbot", match: { accountId: "platinum", peer: { id: "-1003795580197:topic:80" }}},
{ agentId: "tg-botbot", match: { accountId: "platinum", peer: { id: "-1003795580197:topic:97" }}},
{ agentId: "tg-botbot", match: { accountId: "platinum", peer: { id: "-1003795580197:topic:145" }}},
```

**After**:
```json5
{ agentId: "tg-botbot", match: { accountId: "platinum", peer: { id: "-1003795580197" }}},
```

**Condition**: Verify no topic-level `requireMention` or `allowFrom` exceptions in `channels.telegram.groups["-1003795580197"].topics`.

## Pattern 3: Exception topics

**Symptom**: Most topics go to Agent A, but one topic goes to Agent B.

**Keep as-is**:
```json5
// Default agent for the group
{ agentId: "default-agent", match: { accountId: "bot", peer: { id: "-1003795580197" }}},

// Exception topic (different agent)
{ agentId: "special-agent", match: { accountId: "bot", peer: { id: "-1003795580197:topic:218" }}},
```

**Do NOT merge** these. The topic-level binding is intentional.

## Pattern 4: Shared account with peer exclusivity

**Symptom**: Multiple agents use the same account, but bind to different peers.

**Keep as-is**:
```json5
// platinum account is shared between main and tg-botbot
{ agentId: "main", match: { accountId: "platinum", peer: { id: "-1003593489589:topic:39" }}},
{ agentId: "tg-botbot", match: { accountId: "platinum", peer: { id: "-1003795580197" }}},
{ agentId: "main", match: { accountId: "platinum" }},  // DM fallback
```

**Do NOT** convert `main` to account-level binding without checking peer overlap.

## Pattern 5: Group-level overrides

**Symptom**: Account-level binding exists, but one group needs a different agent.

**Correct order**:
```json5
// Account-level (catch-all for this account)
{ agentId: "default-agent", match: { accountId: "bot" }},

// Group-level override (higher priority)
{ agentId: "group-agent", match: { accountId: "bot", peer: { id: "-1003797724681" }}},
```

**Verification**: Group-level binding comes **after** account-level in config order doesn't matter—priority is based on match specificity.

## Quick checklist

- [ ] Account exclusivity verified (`accountId` used by only one agent)
- [ ] Activation consistency checked (`requireMention`, `allowFrom`)
- [ ] No exception topics in target group
- [ ] Route collision check passed
- [ ] Backup created

See `references/AUDIT.md` for detailed checks.
