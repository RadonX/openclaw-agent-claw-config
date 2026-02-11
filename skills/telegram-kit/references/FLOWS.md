# End-to-end flow (forum supergroup bootstrap)

## 0) Create forum supergroup (user API)

- `telegram-kit user create-group --forum …`
- Save printed `chat_id=-100…`

## 1) Invite + promote the bot (user API)

- `telegram-kit user invite-bot --chat -100… --bot @…`
- `telegram-kit user promote-bot --chat -100… --bot @…`

## 2) Create topics (bot API)

- `telegram-kit bot create-topics --account <accountId> --chat -100… --names "Decision,Maxim,Pipeline"`

## 3) Hand-off to OpenClaw routing

- Add `bindings` for `<accountId>` + `peer` to target agent.
- Add per-account group allowlist / requireMention as needed.
