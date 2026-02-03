#!/usr/bin/env bash
set -euo pipefail

# Extract a time window from OpenClaw logs.
# - Input: local timestamp + tz
# - Converts to UTC window
# - Greps relevant lines from gateway.err.log and gateway.log

OPENCLAW_ROOT="${OPENCLAW_ROOT:-$HOME/.openclaw}"
LOG_ERR="$OPENCLAW_ROOT/logs/gateway.err.log"
LOG_OUT="$OPENCLAW_ROOT/logs/gateway.log"

LOCAL_TS=""
TZNAME="America/Los_Angeles"
MINUTES=10
TAIL_LINES=200000
GREP_RE=""

usage() {
  cat <<'EOF'
Usage:
  extract-window.sh --local "YYYY-MM-DD HH:MM" [--tz "Area/City"] [--minutes N] [--tail N] [--grep "regex"]

Examples:
  ./extract-window.sh --local "2026-02-03 00:36" --tz "America/Los_Angeles" --minutes 10 \
    --grep "telegram|sendMessage failed|fetch failed|409|LLM request timed out"
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --local)
      LOCAL_TS="$2"; shift 2;;
    --tz)
      TZNAME="$2"; shift 2;;
    --minutes)
      MINUTES="$2"; shift 2;;
    --grep)
      GREP_RE="$2"; shift 2;;
    --tail)
      TAIL_LINES="$2"; shift 2;;
    -h|--help)
      usage; exit 0;;
    *)
      echo "Unknown arg: $1" >&2
      usage; exit 2;;
  esac
done

if [[ -z "$LOCAL_TS" ]]; then
  echo "--local is required" >&2
  usage
  exit 2
fi

if ! command -v gdate >/dev/null 2>&1; then
  echo "gdate not found. Install coreutils (brew install coreutils)." >&2
  exit 2
fi

# Convert local timestamp -> epoch seconds, then format UTC window.
CENTER_EPOCH=$(TZ="$TZNAME" gdate -d "$LOCAL_TS" +%s)
START_EPOCH=$((CENTER_EPOCH - MINUTES*60))
END_EPOCH=$((CENTER_EPOCH + MINUTES*60))

UTC_CENTER=$(gdate -u -d "@${CENTER_EPOCH}" +"%Y-%m-%dT%H:%M:%S")
UTC_START=$(gdate -u -d "@${START_EPOCH}" +"%Y-%m-%dT%H:%M:%S")
UTC_END=$(gdate -u -d "@${END_EPOCH}" +"%Y-%m-%dT%H:%M:%S")

echo "# extract-window"
echo "local:  $LOCAL_TS ($TZNAME)"
echo "utc:    $UTC_CENTER"
echo "window: ${UTC_START}Z .. ${UTC_END}Z"
echo

# Helper: filter lines by UTC window using prefix compare
# Log lines start with: YYYY-MM-DDTHH:MM:SS.sssZ
filter_window() {
  local file="$1"
  # These logs can be multi-GB. Default to scanning only the recent tail.
  # For historical incidents, increase --tail or pre-split logs.
  tail -n "$TAIL_LINES" "$file" \
    | awk -v start="$UTC_START" -v end="$UTC_END" 'length($0)>20 {ts=substr($0,1,19); if (ts>=start && ts<=end) print $0}'
}

run_grep() {
  if [[ -n "$GREP_RE" ]]; then
    # Read from stdin; -u avoids any binary heuristics.
    rg -u -n "$GREP_RE" - || true
  else
    cat
  fi
}

echo "## gateway.err.log ($LOG_ERR)"
if [[ -f "$LOG_ERR" ]]; then
  filter_window "$LOG_ERR" | run_grep
else
  echo "(missing)"
fi

echo

echo "## gateway.log ($LOG_OUT)"
if [[ -f "$LOG_OUT" ]]; then
  filter_window "$LOG_OUT" | run_grep
else
  echo "(missing)"
fi
