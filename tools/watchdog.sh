#!/bin/bash
###################################################################################
# Claw Config Watchdog
###################################################################################
# Purpose:
#   This script acts as a watchdog daemon for the OpenClaw Gateway service.
#   It monitors the 'openclaw-gateway' process and automatically restarts it
#   if it stops unexpectedly.
#
# Usage:
#   This script is designed to be run as a user LaunchAgent.
#
# Installation:
#   1. Ensure this script is executable: `chmod +x tools/watchdog.sh`
#   2. Install the LaunchAgent plist provided in this workspace.
#   3. Load the agent: `launchctl load ~/Library/LaunchAgents/com.user.clawconfig.watchdog.plist`
#
# Management:
#   - Status: `launchctl list | grep clawconfig`
#   - Stop:   `launchctl unload ~/Library/LaunchAgents/com.user.clawconfig.watchdog.plist`
#   - Logs:   `tail -f ~/.openclaw/logs/claw-config-watchdog.log`
#
# Configuration:
#   - GATEWAY_PROCESS_NAME: The process name to monitor.
#   - CHECK_INTERVAL:        The time in seconds between health checks.
#   - LOG_FILE:              The location of the watchdog's log file.
###################################################################################

# Configuration
# NOTE: launchd service label for the OpenClaw Gateway LaunchAgent
GATEWAY_LAUNCHD_LABEL="ai.openclaw.gateway"
GATEWAY_PLIST="${HOME}/Library/LaunchAgents/ai.openclaw.gateway.plist"
LAUNCHCTL_BIN="/bin/launchctl"
LOG_FILE="${HOME}/.openclaw/logs/claw-config-watchdog.log"
CHECK_INTERVAL=60  # seconds

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Function to log messages with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Rotate previous log to /tmp so it can be auto-cleaned by the OS.
# (Keeps the active log in ~/.openclaw/logs/ for easy tailing.)
if [ -f "$LOG_FILE" ] && [ -s "$LOG_FILE" ]; then
  ROTATED="/tmp/openclaw-watchdog.$(date +%Y%m%d-%H%M%S).log"
  mv "$LOG_FILE" "$ROTATED" 2>/dev/null || true
fi

log "Watchdog started."

# Helpers
job_path() {
  echo "gui/$(id -u)/${GATEWAY_LAUNCHD_LABEL}"
}

job_is_running() {
  # launchctl print exits nonzero if the job is not loaded
  ${LAUNCHCTL_BIN} print "$(job_path)" 2>/dev/null | grep -q "state = running"
}

job_is_loaded() {
  ${LAUNCHCTL_BIN} print "$(job_path)" >/dev/null 2>&1
}

restart_job() {
  # If the job isn't loaded, bootstrap it from the plist.
  if ! job_is_loaded; then
    if [ -f "${GATEWAY_PLIST}" ]; then
      log "Gateway job not loaded. Bootstrapping from ${GATEWAY_PLIST} ..."
      ${LAUNCHCTL_BIN} bootstrap "gui/$(id -u)" "${GATEWAY_PLIST}" >>"$LOG_FILE" 2>&1 || return 1
    else
      log "Gateway plist not found at ${GATEWAY_PLIST}; cannot bootstrap."
      return 1
    fi
  fi

  log "Kickstarting gateway job $(job_path) ..."
  ${LAUNCHCTL_BIN} kickstart -k "$(job_path)" >>"$LOG_FILE" 2>&1
}

# Main loop
while true; do
  if job_is_running; then
    :
  else
    log "Gateway not running (launchd). Attempting recovery..."
    if restart_job; then
      log "Recovery command issued."
    else
      log "Recovery failed."
    fi
  fi

  sleep "$CHECK_INTERVAL"
done
