# Contributing to telegram-kit

This skill ships **operational automation**. Please optimize for safety, predictability, and minimal surface area.

## Core rules

1) **Hard boundary:** never mix MTProto user flows and Bot API flows.
   - `scripts/tg_user.py` (Telethon) is *high risk*.
   - `scripts/tg_bot.py` (Bot API) is *lower risk*.

2) **No secrets in repo**
   - No bot tokens, API keys, phone numbers, session strings, or exported sessions.
   - User creds must be read from `~/.openclaw/.env`.
   - Bot tokens must be resolved from `~/.openclaw/openclaw.json` via `accountId`.

3) **Linus-style CLI**
   - Prefer subcommands over mode flags.
   - One command does one thing.
   - Keep scans bounded (no unbounded history walks).

4) **Stable output contract**
   - Preserve machine-friendly lines (see `references/PRINCIPLES.md`).
   - Avoid printing raw JSON except behind an explicit `--json` flag.

## Dev environment

Use uv:

```bash
uv lock
uv run scripts/tg_bot.py --help
uv run scripts/tg_user.py --help
```

## Testing guidelines

- Prefer `--help` and dry-run style checks.
- Do not add tests that require logging in to Telegram by default.
- Any change that touches Telethon request signatures should note the minimum supported Telethon version.

## PR checklist

- [ ] No secrets or sessions added
- [ ] References updated if CLI changes
- [ ] `uv lock` still resolves cleanly
- [ ] `python -m py_compile` succeeds (via `uv run` if needed)
