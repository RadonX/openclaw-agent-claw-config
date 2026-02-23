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

- `/bindings-simplifier`
  - Default behavior (**plan-only**): do the binding job (analyze → propose a safe simplification plan) and print a minimal JSON5 patch.
- `/bindings-simplifier help`
  - Show how it works + what to verify.

### Apply (follow-up step, not a subcommand)

After the plan is printed, the user can reply with **`apply`** (or “apply it”) to proceed.
The skill must then:
1) re-print the exact patch it is about to apply
2) ask for a final explicit confirmation (yes/no)
3) only then write the config and request a gateway restart if needed

## Hard parsing rules

- If no args: run default workflow (plan-only).
- If `help`: show help.
- Any other args: show help.

Apply is triggered only by a follow-up user message (`apply`) after a plan was produced.

## Which official docs to consult (source-of-truth)

When solving deep routing/consistency issues, read these first (in order):

1. **Routing priority + session key shapes**
   - `${OPENCLAW_REPO:-~/repo/apps/openclaw}/docs/channels/channel-routing.md`

2. **Telegram activation gates (requireMention, allowFrom, groupPolicy, topics overrides)**
   - `${OPENCLAW_REPO:-~/repo/apps/openclaw}/docs/channels/telegram.md`

3. **Gateway config patterns / gotchas** (when unsure where a setting lives)
   - `${OPENCLAW_REPO:-~/repo/apps/openclaw}/docs/gateway/configuration.md` (if present in your version)

If there is a mismatch between expectations and behavior: **docs first, then source grep**.

## Guardrails (non-negotiable)

- **Consistency > reduction**: do not delete/merge a binding unless you can show routing equivalence.
- **Separate routing from activation**: always audit `channels.<provider>` gates for the same peers you simplify.
- **Account-level binding only when exclusive**: convert to account-level only if that `accountId` routes to exactly one agent *or* you keep explicit peer exceptions.
- **Keep exception topics explicit**: if a topic has different activation or different agent, keep a dedicated binding.
- **Plan-first (always)**: default mode must output:
  1) before coverage map (what routes where)
  2) after coverage map
  3) a minimal patch (JSON5 snippet)
  4) verification steps
- **Apply is gated**: apply is never implicit; it must ask for final confirmation.

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
- For patterns/examples: `references/PATTERNS.md`
- For usage: `references/HELP.md`
