# Process: simplify bindings without breaking behavior

This is the playbook the claw-config agent should follow.

## 0) Definitions (keep them separate)

- **Routing**: chooses *agent* → `bindings`.
- **Activation**: decides *whether OpenClaw replies* → `channels.<provider>` gating like:
  - Telegram: `requireMention`, `allowFrom`, `groupPolicy`, per-topic overrides, DM policy.

If you simplify routing but ignore activation, you'll “break config” in the user’s eyes.

## 1) Identify target state (success criteria)

A simplification is successful only if:

- Every inbound peer that previously routed to agent **A** still routes to **A** after.
- Any peer/topic that had special handling keeps it.
- Activation behavior stays the same (mention required vs not; allowFrom restrictions).

## 2) Snapshot current behavior (before)

Produce a **coverage map** (conceptually):

- By provider/channel
- By accountId
- By peer (group/channel)
- By topic/thread where relevant

And explicitly list:

- Account-level bindings (no peer)
- Group-level bindings
- Topic/thread-level bindings

## 3) Audit activation gates for the same peers

For Telegram, for each group you touch, check:

- `channels.telegram.groups.<gid>.requireMention`
- `channels.telegram.groups.<gid>.groupPolicy`
- `channels.telegram.groups.<gid>.groupAllowFrom` (or `allowFrom` fallback)
- `channels.telegram.groups.<gid>.topics.<topicId>.*` overrides

If a topic override exists, treat it as an **exception** until proven safe to merge.

## 4) Apply simplification transformations

Apply only transformations that preserve semantics:

### T1) Account-exclusive → account-level

Condition:
- `accountId` is only used by a single `agentId` OR exceptions are kept as peer-level bindings.

Action:
- Replace multiple peer/topic bindings for that account with one `{accountId}` binding.

### T2) Many topics → group-level

Condition:
- All those topics route to the same agent, AND
- No activation overrides differ per topic.

Action:
- Replace the per-topic bindings with a group-level binding.

### T3) Keep exceptions

If a single topic routes to different agent or has different activation, keep explicit topic binding.

## 5) Consistency check (after)

The output of step (2) and step (5) must match (except reduced redundancy). Validate:

- Routing equivalence (peer → agent)
- Activation equivalence (peer/topic gates)

## 6) Rollout safety

- Always keep a rollback point (git commit or timestamped backup).
- Restart gateway only after config validates.

Recommended sequence:
1. `openclaw doctor` (or validation command for your version)
2. Restart gateway
3. Test 1–3 high-risk peers/topics

## 7) What to do when something feels off

Stop simplifying and switch to docs + source-of-truth:

- Read: `${OPENCLAW_REPO:-~/repo/apps/openclaw}/docs/channels/channel-routing.md`
- Read: `${OPENCLAW_REPO:-~/repo/apps/openclaw}/docs/channels/telegram.md`

Then re-derive the binding priority and activation semantics.
