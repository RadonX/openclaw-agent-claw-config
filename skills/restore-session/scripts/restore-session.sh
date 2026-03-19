#!/bin/bash
#
# restore-session.sh
# Restore conversation history from a source session to a target session
# Usage: ./restore-session.sh <agent-id> <source-session-id> [target-session-key] [--delay] [--dry-run]
#
# WARNING: This modifies session files directly. Always backup first.
#
# DESIGN PRINCIPLES:
# - Non-interactive by default (no prompts)
# - Atomic operations: write to temp, verify, then move
# - Fail fast: set -euo pipefail
# - Self-contained: minimize external dependencies (only jq required)

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Parse arguments
DELAY_MODE=false
DRY_RUN=false
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --delay)
      DELAY_MODE=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 <agent-id> <source-session-id> [target-session-key] [--delay] [--dry-run]"
      echo ""
      echo "Restore conversation history from source session to target session."
      echo ""
      echo "Arguments:"
      echo "  agent-id              Target agent ID (e.g., claw-config)"
      echo "  source-session-id     Session ID to restore from"
      echo "  target-session-key    Optional: specific session key"
      echo ""
      echo "Options:"
      echo "  --delay     Add 45s delay after restoration"
      echo "  --dry-run   Show what would be done without making changes"
      echo "  --help, -h  Show this help"
      exit 0
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}"

AGENT_ID="${1:-}"
SOURCE_ID="${2:-}"
TARGET_SESSION_KEY="${3:-}"

if [[ -z "$AGENT_ID" || -z "$SOURCE_ID" ]]; then
  echo "Usage: $0 <agent-id> <source-session-id> [target-session-key] [--delay] [--dry-run]"
  exit 1
fi

OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
AGENT_DIR="$OPENCLAW_HOME/agents/$AGENT_ID"
SESSIONS_DIR="$AGENT_DIR/sessions"
BACKUP_DIR="$SESSIONS_DIR/.backups/$(date +%Y%m%d-%H%M%S)"

if [[ ! -d "$AGENT_DIR" ]]; then
  echo "ERROR: Agent '$AGENT_ID' not found"
  exit 1
fi

if [[ ! -d "$SESSIONS_DIR" ]]; then
  echo "ERROR: Sessions directory not found"
  exit 1
fi

# Resolve source session file
# Support .jsonl.reset.<timestamp> archive files as source
FUZZY_MATCHED=false

if [[ "$SOURCE_ID" == *.jsonl.reset.* ]]; then
  # Direct archive file reference (no .jsonl suffix needed)
  SOURCE_FILE="$SESSIONS_DIR/$SOURCE_ID"
elif [[ -f "$SESSIONS_DIR/$SOURCE_ID" ]]; then
  # Exact path match
  SOURCE_FILE="$SESSIONS_DIR/$SOURCE_ID"
else
  SOURCE_FILE="$SESSIONS_DIR/$SOURCE_ID.jsonl"
fi

if [[ ! -f "$SOURCE_FILE" ]]; then
  MATCHES=($(ls "$SESSIONS_DIR/$SOURCE_ID"*.jsonl 2>/dev/null || true))
  if [[ ${#MATCHES[@]} -eq 0 ]]; then
    echo "ERROR: Source session not found: $SOURCE_ID"
    exit 1
  elif [[ ${#MATCHES[@]} -eq 1 ]]; then
    SOURCE_FILE="${MATCHES[0]}"
    FUZZY_MATCHED=true
    echo "NOTICE: Using fuzzy match: $(basename "$SOURCE_FILE" .jsonl)"
  else
    echo "Multiple matches found. Specify full session ID."
    exit 1
  fi
fi

if [[ -z "$TARGET_SESSION_KEY" ]]; then
  TARGET_SESSION_KEY="agent:$AGENT_ID:main"
fi

SESSIONS_JSON="$SESSIONS_DIR/sessions.json"
if [[ ! -f "$SESSIONS_JSON" ]]; then
  echo "ERROR: sessions.json not found"
  exit 1
fi

TARGET_ID=$(jq -r ".[\"$TARGET_SESSION_KEY\"].sessionId // empty" "$SESSIONS_JSON")
if [[ -z "$TARGET_ID" ]]; then
  echo "ERROR: Session key not found: $TARGET_SESSION_KEY"
  exit 1
fi

# Target transcript file name differs for Telegram forum topics.
# If the session key ends with :topic:<id>, the transcript is typically stored as:
#   <sessionId>-topic-<topicId>.jsonl
# Otherwise it is:
#   <sessionId>.jsonl
TARGET_FILE="$SESSIONS_DIR/$TARGET_ID.jsonl"
if [[ "$TARGET_SESSION_KEY" =~ :topic:([0-9]+)$ ]]; then
  TOPIC_ID="${BASH_REMATCH[1]}"
  TARGET_FILE="$SESSIONS_DIR/${TARGET_ID}-topic-${TOPIC_ID}.jsonl"
fi

if [[ ! -f "$TARGET_FILE" ]]; then
  echo "Creating new target file..."
  mkdir -p "$(dirname "$TARGET_FILE")"
  touch "$TARGET_FILE"
fi

if ! head -1 "$SOURCE_FILE" | jq . > /dev/null 2>&1; then
  echo "ERROR: Source file is not valid JSONL"
  exit 1
fi

SOURCE_LINES=$(wc -l < "$SOURCE_FILE")
TARGET_LINES=$(wc -l < "$TARGET_FILE")

echo "==================================="
echo "Restoration Plan"
echo "==================================="
echo "Source: $SOURCE_ID ($SOURCE_LINES lines)"
echo "Target: $TARGET_SESSION_KEY ($TARGET_LINES lines)"
echo "Backup: $BACKUP_DIR"
echo ""

if [[ "$DRY_RUN" == true ]]; then
  echo "DRY RUN - No changes made"
  exit 0
fi

echo "Creating backup..."
mkdir -p "$BACKUP_DIR"
cp "$TARGET_FILE" "$BACKUP_DIR/$(basename "$TARGET_FILE").backup"

# Build restored content
TARGET_HEADER=$(head -1 "$TARGET_FILE")
CORRECT_WORKSPACE="$OPENCLAW_HOME/workspace-$AGENT_ID"
SOURCE_WORKSPACE=$(head -1 "$SOURCE_FILE" | jq -r '.cwd // empty')

TEMP_FILE=$(mktemp)
trap "rm -f $TEMP_FILE" EXIT

FIXED_HEADER=$(echo "$TARGET_HEADER" | jq -c ".cwd = \"$CORRECT_WORKSPACE\"")
echo "$FIXED_HEADER" > "$TEMP_FILE"
tail -n +2 "$SOURCE_FILE" >> "$TEMP_FILE"

echo "Writing to target..."
cp "$TEMP_FILE" "$TARGET_FILE"

NEW_LINES=$(wc -l < "$TARGET_FILE")
echo ""
echo "Restoration complete: $TARGET_LINES -> $NEW_LINES lines"
echo "Backup: $BACKUP_DIR/$(basename "$TARGET_FILE").backup"

if [[ "$DELAY_MODE" == true ]]; then
  echo "Waiting 45s..."
  sleep 45
fi

echo "Done."
exit 0
