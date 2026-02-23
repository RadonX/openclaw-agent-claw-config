---
name: bindings-simplifier
description: Safely simplify OpenClaw `bindings` (routing rules) while preserving behavior. Use when bindings are redundant (per-topic spam), when accounts are exclusive to a single agent, or when you need to reduce binding count without breaking routing/activation.
compatibility: OpenClaw JSON5 config.
metadata:
  author: claw-config
  version: "2.0"
  openclaw:
    emoji: "🧭"
---

# bindings-simplifier

This skill is about **routing** (`bindings`) simplification with **consistency guarantees**.

> Mental model first:
> - `bindings` decides **which agent** receives an inbound message.
> - `channels.*` decides **whether** the bot is allowed/activated to reply (requireMention, allowFrom, groupPolicy, dmPolicy...).
> - You can simplify routing perfectly and still “break” behavior if activation gates differ per topic/group.

## Interface

- `/bindings-simplifier help`
- `/bindings-simplifier propose [--scope telegram|all] [--target-account <accountId>]`
- `/bindings-simplifier audit [--scope telegram|all]`

Default: **proposal-only**. Never writes config automatically.

## Hard parsing rules

- First token after `/bindings-simplifier` must be one of:
  - `help` | `audit` | `propose`
- Unknown tokens → show help and ask the user to restate.

## Which official docs to consult (source-of-truth)

When solving deep routing/consistency issues, read these first (in order):

1. **Routing priority + session key shapes**
   - `~/repo/apps/openclaw/docs/channels/channel-routing.md`

2. **Telegram activation gates (requireMention, allowFrom, groupPolicy, topics overrides)**
   - `~/repo/apps/openclaw/docs/channels/telegram.md`

3. **Gateway config patterns / gotchas** (when unsure where a setting lives)
   - `~/repo/apps/openclaw/docs/gateway/configuration.md` (if present in your version)

If there is a mismatch between expectations and behavior: **docs first, then source grep**.

## Guardrails (non-negotiable)

- **Consistency > reduction**: do not delete/merge a binding unless you can explain why behavior remains identical.
- **Separate routing from activation**: always audit `channels.<provider>` gates for the same peers you simplify.
- **Account-level binding only when exclusive**: convert to account-level only if that `accountId` routes to exactly one agent *or* you keep explicit peer exceptions.
- **Keep exception topics explicit**: if a topic has different activation or different agent, keep a dedicated binding.
- **Proposal-first**: output “before → after” mapping + risk list before applying changes.

## What this skill produces

A safe simplification proposal containing:

1. **Coverage map** (before): which peers/topics/accounts are handled by which agent
2. **Proposed bindings** (after)
3. **Diff summary**: removed/merged bindings list
4. **Consistency checks** to run (routing + activation)
5. **Focused manual tests** (1–3 high-risk peers)

## Routing simplification patterns (high-signal)

- **Account exclusive → account-level binding**
  - Example: `claw_3po` is only used by `claw-config` → keep one account-level binding.

- **Same agent across many topics → merge to group-level**
  - Only if `channels.telegram.groups.<gid>.topics` has no activation overrides that would change behavior.

- **One special topic → keep as exception**
  - Topic-level binding overrides group/account-level.

## References

- Always read: `references/PROCESS.md`
- For checklists: `references/CHECKLISTS.md`
- For examples: `references/PATTERNS.md`
