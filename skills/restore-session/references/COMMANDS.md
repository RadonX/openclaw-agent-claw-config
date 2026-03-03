# Session Restoration Commands Reference

## jq Commands for Session Analysis

### List Sessions by Date
```bash
for f in ~/.openclaw/agents/<agent-id>/sessions/*.jsonl; do
  [[ "$f" == *".backup"* ]] && continue
  date=$(head -1 "$f" 2>/dev/null | jq -r '.timestamp[0:10] // "unknown"')
  size=$(ls -lh "$f" 2>/dev/null | awk '{print $5}')
  id=$(basename "$f" .jsonl)
  echo "$date $size $id"
done | sort -r
```

### Find Sessions for Specific Topic
```bash
ls ~/.openclaw/agents/<agent-id>/sessions/*topic-214.jsonl
```

### Extract Session Header
```bash
head -1 ~/.openclaw/agents/<agent-id>/sessions/<session-id>.jsonl | jq
```

### Count Messages by Role
```bash
jq -s '{
  total: length,
  user: [.[] | select(.message.role=="user")] | length,
  assistant: [.[] | select(.message.role=="assistant")] | length
}' ~/.openclaw/agents/<agent-id>/sessions/<session-id>.jsonl
```

### Find Sessions by Date Range
```bash
for f in ~/.openclaw/agents/<agent-id>/sessions/*.jsonl; do
  head -1 "$f" | jq -r '.timestamp' | grep -q "2026-02-0[5-7]" && echo "$f"
done
```

## Session Key to File Resolution

### Get Session ID from Key
```bash
# From sessions.json index
jq -r '.["agent:claw-config:telegram:group:-1003797724681:topic:214"].sessionId' \
  ~/.openclaw/agents/claw-config/sessions/sessions.json
```

### Get All Session Keys
```bash
jq 'keys[]' ~/.openclaw/agents/<agent-id>/sessions/sessions.json
```

### Get Session Entry Details
```bash
jq '.["<session-key>"]' \
  ~/.openclaw/agents/<agent-id>/sessions/sessions.json
```

## Manual Restoration Commands

### Method 1: Simple Copy (Same Agent, No Cleanup Needed)
```bash
SOURCE="~/.openclaw/agents/<agent>/sessions/<source-id>.jsonl"
TARGET="~/.openclaw/agents/<agent>/sessions/<target-id>.jsonl"
BACKUP="~/.openclaw/agents/<agent>/sessions/.backups/$(date +%Y%m%d-%H%M%S)/"

# Backup
mkdir -p "$BACKUP"
cp "$TARGET" "$BACKUP/$(basename $TARGET).backup"

# Replace
cat "$SOURCE" > "$TARGET"

# Verify
wc -l "$SOURCE" "$TARGET"
```

### Method 2: Preserve Target Header (Recommended)
```bash
SOURCE="~/.openclaw/agents/<agent>/sessions/<source-id>.jsonl"
TARGET="~/.openclaw/agents/<agent>/sessions/<target-id>.jsonl"
TARGET_WORKSPACE="$(head -1 "$TARGET" | jq -r '.cwd')"
TEMP="/tmp/restore-$(date +%s).jsonl"

# Preserve target header, replace content
tail -n +2 "$SOURCE" > "$TEMP"
cat <(head -1 "$TARGET") "$TEMP" > "$TARGET.new"
mv "$TARGET.new" "$TARGET"
rm "$TEMP"
```

### Method 3: Cross-Agent with Path Fix
```bash
SOURCE_AGENT="ginmoni"
TARGET_AGENT="claw-config"
SOURCE_ID="af3226eb-e0c2-46ac-aa88-cefa802ede21"
TARGET_ID="1c2cb849-5298-45a4-aed9-8d5553b3f2df"

SOURCE_FILE="~/.openclaw/agents/$SOURCE_AGENT/sessions/$SOURCE_ID.jsonl"
TARGET_FILE="~/.openclaw/agents/$TARGET_AGENT/sessions/$TARGET_ID.jsonl"
TARGET_WORKSPACE="~/.openclaw/workspace-$TARGET_AGENT"
TEMP="/tmp/fixed-$(date +%s).jsonl"

# Fix workspace path
head -1 "$SOURCE_FILE" | jq ".cwd = \"$TARGET_WORKSPACE\"" > "$TEMP"
tail -n +2 "$SOURCE_FILE" >> "$TEMP"

# Backup and replace
cp "$TARGET_FILE" "${TARGET_FILE}.backup.$(date +%s)"
cp "$TEMP" "$TARGET_FILE"
rm "$TEMP"
```

## Verification Commands

### Check File Integrity
```bash
# Verify JSONL format
jq -c '.' ~/.openclaw/agents/<agent>/sessions/<session-id>.jsonl > /dev/null \
  && echo "Valid JSONL" || echo "Parse Error"

# Count parseable lines
good=$(jq -c '.' ~/.openclaw/agents/<agent>/sessions/<session-id>.jsonl 2>/dev/null | wc -l)
total=$(wc -l < ~/.openclaw/agents/<agent>/sessions/<session-id>.jsonl)
echo "$good/$total lines parsable"
```

### Compare Source and Target
```bash
# After restoration, verify line counts match
SOURCE_LINES=$(wc -l < "$SOURCE_FILE")
TARGET_LINES=$(wc -l < "$TARGET_FILE")
echo "Source: $SOURCE_LINES lines, Target: $TARGET_LINES lines"

# Check first messages match
diff <(jq -s '.[1]' "$SOURCE_FILE") \
     <(jq -s '.[1]' "$TARGET_FILE") \
  && echo "First message matches" || echo "Mismatch detected"
```

## Emergency Recovery

### Session File Corrupted
```bash
CORRUPTED="~/.openclaw/agents/<agent>/sessions/<session-id>.jsonl"

# Find most recent backup
BACKUP=$(ls -t ~/.openclaw/agents/<agent>/sessions/.backups/*/<session-id>.jsonl* 2>/dev/null | head -1)

if [[ -n "$BACKUP" ]]; then
  cp "$BACKUP" "$CORRUPTED"
  echo "Restored from $BACKUP"
else
  echo "No backup found!"
fi
```

### Session ID Mismatch
```bash
# Find which session ID should be used
SESSION_KEY="agent:<agent>:<provider>:<type>:<id>:topic:<topic-id>"
jq -r ".[\"$SESSION_KEY\"].sessionId" \
  ~/.openclaw/agents/<agent>/sessions/sessions.json

# List available session files
ls -la ~/.openclaw/agents/<agent>/sessions/*.jsonl | grep -v backup
```

## Workspace Session vs Agent Session

### Agent Sessions (main storage)
```
~/.openclaw/agents/<agent-id>/sessions/
├── sessions.json              # Session index
├── <session-id>.jsonl         # Conversation history
└── <session-id>-topic-<n>.jsonl  # Topic-specific sessions
```

### Workspace Sessions (.sessions, runtime)
```
~/.openclaw/workspace-<agent>/.sessions/
├── <session-id>-topic-<n>.jsonl  # Session working copies
```

**Key difference:**
- Agent sessions: Persistent storage, shared across restarts
- Workspace sessions: Runtime copies, may diverge during operation

**Sync command:**
```bash
# Sync workspace session to agent storage
cp ~/.openclaw/workspace-<agent>/.sessions/<id>-topic-<n>.jsonl \
  ~/.openclaw/agents/<agent>/sessions/<id>-topic-<n>.jsonl
```
