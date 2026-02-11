# Troubleshooting

## MTProto login issues

- **Invalid code**: code expired or wrong format (sometimes includes hyphen). Wait for a new code.
- **Attempt was blocked**: Telegram risk control. Cool down (5–15m), approve security prompt, try again.
- **2FA enabled**: set `TG_2FA_PASSWORD` in `~/.openclaw/.env` or be ready to type interactively.

## Bot API issues

- `createForumTopic` fails: bot is not admin or lacks manage topics permissions.
- UI shows bot not admin: client cache; re-open admin list; verify via API if needed.
