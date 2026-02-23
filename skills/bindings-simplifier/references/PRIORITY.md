# Binding resolution priority

Understanding how OpenClaw selects which agent handles a message is critical for safe simplification.

## Resolution order (highest to lowest)

From `src/routing/resolve-route.ts`:

1. **`binding.peer`** (exact match)
   - Matches exact `peer.id` (including `groupId:topic:X`)
   - Example: `{ id: "-1003795580197:topic:66" }`

2. **`binding.peer.parent`** (thread inheritance)
   - Matches parent peer if thread doesn't match directly

3. **`binding.guild + roles`** (Discord-specific)
   - Matches guild + role combination

4. **`binding.guild`** (Discord-specific)
   - Matches guild without role constraint

5. **`binding.team`** (Slack-specific)
   - Matches team ID

6. **`binding.account`** (account-level, no peer)
   - Matches all peers for the given `accountId`
   - Example: `{ accountId: "claw_3po" }` (no `peer` field)

7. **`binding.channel`** (channel-level, `accountId: "*"`)
   - Wildcard account match

8. **`default`** (fallback)
   - Uses agent with `default: true`

## Key implications for simplification

### 1) Topic-level > Group-level > Account-level

```
Specific → General
topic:66  >  group  >  account
```

**Example**:
```json5
// Account-level (lowest priority for this account)
{ agentId: "default-agent", match: { accountId: "bot" }},

// Group-level (overrides account for this group)
{ agentId: "group-agent", match: { accountId: "bot", peer: { id: "-1003795580197" }}},

// Topic-level (overrides both for this topic)
{ agentId: "topic-agent", match: { accountId: "bot", peer: { id: "-1003795580197:topic:66" }}},
```

Result:
- Messages to `topic:66` → `topic-agent`
- Messages to other topics in `-1003795580197` → `group-agent`
- Messages to other groups via `bot` → `default-agent`

### 2) Merging topic bindings is safe when...

- All topics for a group map to the same agent
- No topic has a `requireMention` or `allowFrom` exception in `channels.telegram.groups.<id>.topics`
- No other agent has a competing binding for that group

### 3) Account-level bindings are safe when...

- The `accountId` is used by only one agent
- All groups using that account should route to the same agent
- Any exception groups have explicit peer-level bindings (and will override)

## Verification checklist

After simplification, verify routing:

```bash
# For each critical group, check which agent it routes to
jq --arg group "<group-id>" '
  .bindings | 
  map(select(.match.peer.id == $group or .match.peer.id == ($group + ":topic:66"))) |
  "Agent: " + .agentId + ", Peer: " + .match.peer.id
' ~/.openclaw/openclaw.json
```

**Expected**: Output should show the correct agent for each peer.
