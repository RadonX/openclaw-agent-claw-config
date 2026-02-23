# bindings-simplifier

When your OpenClaw `bindings` have grown into a tangled mess (per-topic spam, duplicated rules, unclear ownership), this skill helps you **simplify them safely**—without accidentally changing which agent handles which chat.

## What you get

- Fewer bindings (often 30–60% reduction)
- A clear “before → after” routing summary
- A minimal patch you can apply with confidence
- A short verification checklist so you don’t discover breakage later

## When you want this

Use it when:
- you keep adding new groups/topics and `bindings` keeps growing
- the same agent is bound to many topics in the same group
- a bot account is dedicated to one agent (good candidate for account-level binding)
- you want to refactor routing but **cannot afford downtime / mis-routing**

## How to use

1) Run:
- `/bindings-simplifier`

2) Review the plan (it prints a patch + risks + verification).

3) If you agree, reply:
- `apply`

You’ll still get a final confirmation prompt before anything is written.

## Why this is safer than “just deleting duplicates”

Routing issues usually come from mixing up two different layers:

- **Routing** (`bindings`): decides which agent receives the message.
- **Activation** (`channels.*`): decides whether the bot replies (e.g. mention required, allowlists, per-topic overrides).

This skill forces an explicit check of both so you don’t “successfully refactor bindings” while silently changing reply behavior.

## References (if you need to go deeper)

- Routing rules: `${OPENCLAW_REPO:-~/repo/apps/openclaw}/docs/channels/channel-routing.md`
- Telegram activation gates: `${OPENCLAW_REPO:-~/repo/apps/openclaw}/docs/channels/telegram.md`

## License

Same as the repository license.
