#!/bin/bash
set -euo pipefail

###################################################################################
# install-watchdog.sh
# Install the OpenClaw Gateway Watchdog as a macOS LaunchAgent.
#
# Usage:
#   ./tools/install-watchdog.sh [/path/to/workspace]
#
# If no path is given, defaults to ~/.openclaw/workspace-claw-config
###################################################################################

WORKSPACE="${1:-${HOME}/.openclaw/workspace-claw-config}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLIST_TEMPLATE="${SCRIPT_DIR}/../config/launchd/com.user.clawconfig.watchdog.plist.template"
PLIST_DEST="${HOME}/Library/LaunchAgents/com.user.clawconfig.watchdog.plist"
LABEL="com.user.clawconfig.watchdog"

# Validate
if [ ! -f "${PLIST_TEMPLATE}" ]; then
  echo "ERROR: Template not found at ${PLIST_TEMPLATE}" >&2
  exit 1
fi

if [ ! -f "${WORKSPACE}/tools/watchdog.sh" ]; then
  echo "ERROR: watchdog.sh not found at ${WORKSPACE}/tools/watchdog.sh" >&2
  exit 1
fi

# Ensure watchdog.sh is executable
chmod +x "${WORKSPACE}/tools/watchdog.sh"

# Generate plist from template
mkdir -p "${HOME}/Library/LaunchAgents"
sed -e "s|__WORKSPACE_PATH__|${WORKSPACE}|g" \
    -e "s|__HOME__|${HOME}|g" \
    "${PLIST_TEMPLATE}" > "${PLIST_DEST}"

echo "✅ Plist installed: ${PLIST_DEST}"

# Unload if already loaded (ignore errors)
launchctl unload "${PLIST_DEST}" 2>/dev/null || true

# Load the agent
launchctl load "${PLIST_DEST}"
echo "✅ Watchdog loaded and running."

# Verify
sleep 1
if launchctl list | grep -q "${LABEL}"; then
  echo "✅ Verified: ${LABEL} is in launchctl list."
else
  echo "⚠️  Warning: ${LABEL} not found in launchctl list." >&2
fi

echo ""
echo "Management:"
echo "  Status:  launchctl list | grep clawconfig"
echo "  Logs:    tail -f ~/.openclaw/logs/claw-config-watchdog.log"
echo "  Stop:    launchctl unload ${PLIST_DEST}"
echo "  Restart: launchctl unload ${PLIST_DEST} && launchctl load ${PLIST_DEST}"
