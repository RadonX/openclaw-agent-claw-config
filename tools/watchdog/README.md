# Gateway Watchdog

macOS LaunchAgent that keeps the OpenClaw Gateway running. If the gateway process dies, the watchdog detects it within 60 seconds and restarts it via `launchctl kickstart`.

## Files

| File | Purpose |
|------|---------|
| `watchdog.sh` | Main loop — checks gateway every 60s, restarts if down |
| `install-watchdog.sh` | One-command installer (generates plist, loads LaunchAgent) |
| `com.user.clawconfig.watchdog.plist.template` | LaunchAgent plist template |

## Install

```bash
./install-watchdog.sh [/path/to/workspace]
```

If no workspace path is given, defaults to `~/.openclaw/workspace-claw-config`.

The script will:
1. Generate a plist with correct paths from the template
2. Install it to `~/Library/LaunchAgents/`
3. Load the agent via `launchctl`

## Manage

```bash
# Status
launchctl list | grep clawconfig

# Logs
tail -f ~/.openclaw/logs/claw-config-watchdog.log

# Stop
launchctl unload ~/Library/LaunchAgents/com.user.clawconfig.watchdog.plist

# Restart
launchctl unload ~/Library/LaunchAgents/com.user.clawconfig.watchdog.plist
launchctl load ~/Library/LaunchAgents/com.user.clawconfig.watchdog.plist
```

## How It Works

1. `launchd` starts `watchdog.sh` at login (KeepAlive=true)
2. Every 60 seconds, checks if `ai.openclaw.gateway` is running
3. If not, tries `launchctl kickstart` to recover
4. If the gateway job isn't even loaded, bootstraps it from the plist first

The watchdog itself is kept alive by launchd (KeepAlive), so it won't silently die.
