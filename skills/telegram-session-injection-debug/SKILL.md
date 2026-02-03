---
name: telegram-session-injection-debug
description: Debug Telegram forum topic routing and control-plane message injection (sessions_send) in OpenClaw, including seeding topics (message_thread_id), verifying who sends (deliveryContext.accountId), diagnosing stuck/pending announces, and using diagnostics flags (telegram.http) to confirm sendMessage failures.
---

# Telegram session injection + topic routing debug

This is a **runbook skill** distilled from a real incident while testing:
- **Plan A**: use `sessions_send(sessionKey, message)` to make a proxy bot/agent post in another group/topic.
- **Reality**: forum topics require `message_thread_id`; without prior inbound, session metadata may be incomplete.
- **Gotchas**: “pending announce” can mean *generated* but not actually delivered.

## Key mental model

### 1) SessionKey decides *where* the message goes

- Group: `telegram:group:<chatId>`
- Forum topic: `telegram:group:<chatId>:topic:<threadId>`

### 2) deliveryContext.accountId decides *who* sends

Even if **you** (some agent) created the content, the visible Telegram sender is the **accountId bound to the target session**.

Typical co-existing sessions in the same topic:
- `agent:claw-config:telegram:group:-100…:topic:279` → `accountId: claw_config_bot`
- `agent:ginmoni:telegram:group:-100…:topic:279` → `accountId: ginmoni`
- `telegram:group:-100…:topic:279` → usually a default account (often `platinum`)

Rule of thumb: **message is “to” the sessionKey, not “to” an agent**.

### 3) `sessions_send` reply != Telegram delivery

- `sessions_send` returns a `reply` (agent output) for control-plane visibility.
- External delivery is a separate step (“announce”). It can fail independently.

## Procedure: Validate Plan A (sessions_send) on Telegram topics

### Step 0 — Preflight

- Ensure the target bot is in the target group and can speak.
- Ensure OpenClaw allowlist/groupPolicy does not block the group.

### Step 1 — Seed the topic (critical)

Symptoms of missing seed:
- replies go to topic 1 (General), or
- nothing shows up in the target topic.

Why: without a prior inbound update that includes `message_thread_id`, OpenClaw may lack topic metadata.

Minimum seed action:
- In the target topic: `@<bot> ping` (blue mention).

(If you use MTProto/user tooling to seed, note this changes the object being tested; prefer real bot inbound when validating bot routing.)

### Step 2 — Inject a unique marker via sessions_send

Send a message that forces an exact reply so you can attribute causality:

- Ask the bot to reply *exactly* `SS-OK-<random>`.
- Do not send any other messages during this window.

Expected:
- The bot posts `SS-OK-<random>` in the same topic.

### Step 3 — If you see “pending announce” but nothing in Telegram

Do **not** assume it’s “just delay”. Treat it as “delivery unknown” until proven.

Common causes:
- Bot API network errors.
- `chat not found` (wrong chat id / bot removed / permissions).
- Topic/thread mismatch.
- Rate limits.

## Diagnostics: targeted logs without global verbosity

OpenClaw supports diagnostics flags (requires restart).

Recommended temporary flags:

```json5
{
  diagnostics: {
    flags: ["telegram.http", "gateway.*"],
  }
}
```

Where to look:
- `/tmp/openclaw/openclaw-YYYY-MM-DD.log`

What to grep for:
- `telegram ... sendMessage failed`
- `Delivery failed (telegram to telegram:-100...)`
- `chat not found`
- `Network request for 'sendMessage' failed!`
- `429`

Important: **turn flags back off** after debugging:

```json5
{ diagnostics: { flags: [] } }
```

## Lesson learned checklist

- ✅ Topic routing depends on `message_thread_id` → **seed first**.
- ✅ Use unique reply markers to attribute causality.
- ✅ Control-plane `reply` is not proof of Telegram delivery.
- ✅ For delivery truth, rely on Telegram API errors in diagnostics logs.
- ✅ “Who posted” is determined by `deliveryContext.accountId` for that sessionKey.
